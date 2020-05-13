classdef VectorOut < Pin
    %VectorOut    Class for RF output pins of the Signadyne device
    
    properties (SetAccess = private)
        amplitudeModulation = 'AC';   % indication of amplitude modulation ('DC'/'AC');
        angleModulation = 'phase';           % indication of angle modulation ('phase'/'frequency');
        offset = [0; 0; 0];            % offset for amplitude [in case DC] / [offset in case AC] (V), frequency (Hz) and phase (degree)
        partnerPin = struct(); 
        partnerDelay = 0;
        phaseFactor = 1;
        responseWidth = 1;
        waveforms = [];  % vector of waveform ids, complements properties 'times' and 'values' of base class
        
        % quick access to last assigned states / waveforms
        lastValue = [0; 0];
        lastTime  = 0;
        lastWaveform = struct();%'duration',0,'type','arbitrary','state',[0;0]);
        lastWaveformListIndex = [];
        
        waveformList = struct(), % struct of waveformTypes storing waveform lists
        
        max_value = [1.5; 200e6; 180];  % maximum values for dc offset/ampltitude in V, frequency in Hz, and phase in deg
        min_value = [-1.5; 0; -180];    % minimum values for dc offset/ampltitude in V, frequency in Hz, and phase in deg
        smallestSamplingTime = 20e-9;  % smallest sampling time in seconds
        largestSamplingTime  = 4e-5;   % smallest sampling time in seconds
    end % properties
    
    properties (Access = private, Hidden)
        adapted_max_value = []; % two component vector that takes values from max_value depending on angle/frequency setting
        adapted_min_value = []; % two component vector that takes values from max_value depending on angle/frequency setting
        waveformTypes = {'arbitrary', 'linear', 'sinusoidal', 'state', 'vector','compensation','modulation'};
    end % properties
    
    
    methods (Access=public, Static)
        function ret = getWaveformIdentificationNumber(varargin)
            %GET_WAVEFORM_IDENTIFICATION_NUMBER  Get unique identification number for new waveforms
            %
            %  Input:
            %    generateNew  (optional) idicator whether new waveform number should be generated
            persistent id;
            
            if isempty(id)
                id = uint64(0);
            end
            
            if nargin>0
                id = uint64(id + 1);
            end
            ret = id;
        end % getWaveformIdentificationNumber
    end % methods


    methods(Static)
      
               

        function [values, times] = sampleWaveform(waveform, varargin)
            %SAMPLE_WAVEFORM  returns waveform samples
            %
            % Inputs
            %    waveform     Struct containing waveform data
            %    numSamples   (optional) Number of samples in time interval
            %    timeVector   (optional) Vector of times to sample the waveform,
            %                            renders argument numSamples irrelevant
            if ~isstruct(waveform)
                error('No valid waveform found.');
            end
            if nargin>2
                times = varargin{2};
                if ~isnumeric(times) || any(times<0)  % optional: check for duration
                    error('Positive number (vector) required for timeVector.');
                end
            elseif nargin>1
                samples = varargin{1};
                if ~isnumeric(samples) || ~isscalar(samples) || samples<1
                    error('Positive real integer required for numSamples.');
                end
                times = linspace(waveform.duration./samples,waveform.duration,samples); % mostly for plotting...
            else
                times = waveform.samplingTime:waveform.samplingTime:waveform.duration; % used for signadyne class
            end
            
            switch waveform.type
                case 'arbitrary'
                    values = waveform.functionHandle(times);
                    
                case 'linear'
                    xi = waveform.initialState;
                    xf = waveform.finalState;
                    values = xi + (xf-xi).*times/waveform.duration;
                    
                case 'sinusoidal'
                    xi = waveform.initialState;
                    xf = waveform.finalState;
                    values = xi - (xf-xi).*(cos(times/waveform.duration*pi)-1)/2;
                    
                case 'state'
                    values = repmat(waveform.state, 1, numel(times));
                    
                case 'vector'
                    values = [interp1(waveform.times, waveform.states(1,:), times, 'linear', 'extrap'); ...
                              interp1(waveform.times, waveform.states(2,:), times, 'linear', 'extrap');];
                case 'compensation' 
                    values = [interp1(1:length(waveform.functionHandle),waveform.functionHandle(1,:),times.*length(waveform.functionHandle)./times(end));...
                            interp1(1:length(waveform.functionHandle),waveform.functionHandle(2,:),times.*length(waveform.functionHandle)./times(end))];
                case 'modulation'
                    times = linspace(1,waveform.samples);
                    values = waveform.Amplitude.*sin(times*2*pi);
                    
                otherwise
                    error('unsupported waveform type');
            end
        end % sampleWaveform
    end % methods
    
    methods
        function obj = VectorOut(c, varargin)
            %VectorOut   Default constructor
            %
            %   Inputs:
            %            c    Pin name (default constructor)
            %                   or existing pin (copy constructor)
            %          mag    magnification vector (amplitude and phase/frequency)
            %     angleMod    angle modulation type: 'phase' or 'frequency'
            % amplitudeMod    amplitude modulation type: 'DC' (offset) or 'AC' (amplitude)
            %     userName    (optional) user defined name, set in default
            %                   constructor mode
            
            if isa(c, 'VectorOut')
                angleModNew = c.angleModulation;
                amplModNew = c.amplitudeModulation;
                offNew = c.offset;
            else
                assert( nargin>3, ...
                        'too few arguments given.');
                angleModNew = varargin{1};
                amplModNew = varargin{2};
                offNew = varargin{3};
                
                varargin(1:3) = [];
            end
            obj = obj@Pin(c, varargin{:});
            
            if isa(c, 'VectorOut')
                obj.max_value = c.max_value;
            end
            
            obj.setAngleModulation(angleModNew);
            obj.setAmplitudeModulation(amplModNew);
            obj.setOffsets(offNew);
            
            for type = obj.waveformTypes
                obj.waveformList.(type{:}) = [];
            end
        end % VectorOut
        
        
        function convWave = getGaussConv(obj,wave, sigma)
            % calculate the convolution with the gaussian beam shape
             width = 3*sigma/10;
             x = linspace(-width,width,2*width+1);
             mu = mod(obj.partnerDelay,1);
             gauss = normpdf(x,mu,sigma/10)-normpdf(x(1),mu,sigma/10);      % check this out
             gauss = gauss/sum(gauss);
             if ~strcmp(wave.type,'state')
                samples = obj.sampleWaveform(wave);
                start = wave.initialState;
%                 padding = obj.getLastState();
           
             else 
                samples = wave.state;
                if ~isempty(obj.partnerPin.pin.waveforms)
                    prevWave = obj.partnerPin.pin.getWaveformById(obj.partnerPin.pin.waveforms(end-1));
                else 
                    prevWave = struct();
                    prevWave.type = 'state';
                    prevWave.state = [0;0];
                end
                if ~strcmp(prevWave.type,'state')
                    start = prevWave.finalState;
                else
                    start = prevWave.state;
                end
%                 padding = obj.getLastState();
%                 if abs(padding(2)- start(2)) > 2^-15
%                     samples(2) = samples(2) - start(2) + padding(2);
%                 end
                
             end
             padding = obj.getLastState();

             if abs(padding(1) - start(1)) > 2^-15
                 samples(1,:) = samples(1,:)-start(1)+padding(1);
             end
             if abs(padding(2) - start(2)) > 2^-15
                 samples(2,:) = samples(2,:)-start(2)+padding(2);
             end
             if sigma ~= 0
                 
                 samplesAmp = [padding(1)*ones(1,length(x)) samples(1,:) samples(1,end)*ones(1,length(x))];
                 samplesPhase = [padding(2)*ones(1,length(x)) samples(2,:) samples(2,end)*ones(1,length(x))]/obj.phaseFactor;
                 convWaveAmp = conv(samplesAmp,gauss);
                 convWavePhase = conv(samplesPhase,gauss);
                 convWave = [convWaveAmp;convWavePhase];
                 convWave = convWave(:,length(x):end-1*length(x));   % cutting at 2*x before the end serves for equal legth of ramp and compensation but introduces a nonzero discrepancy between the amplitude of the last points of the ramp --> modulo introduces artifacts
                 convWave(2,:) = mod(convWave(2,:)+(2^15)/2^15,2+2^-15)-(2^15)/2^15;
             else
                 convWave = [samples(1,:) ;samples(2,:)/obj.phaseFactor];
             end
        end
        
        function obj = addPartnerPin(obj,pin,varargin)
            if nargin > 2 &&strcmp(varargin{1},'slave')
                obj.partnerPin.pin = pin;
                obj.partnerPin.enabled = 0; 
                obj.partnerPin.isSlave = 1;
                obj.partnerPin.response = 1;
            else            
                if isa(pin,'VectorOut')
                    obj.partnerPin.pin = pin;
                    obj.partnerPin.enabled = 1; 
                    obj.partnerPin.isSlave = 0;
                    obj.partnerPin.response = 1;
                    pin.addPartnerPin(obj,'slave');
                else
                    error('received non-VerctorOut object as Partner Pin');
                end
            end
            
            
        end
        
          
            
           
        function val = eq(obj1, obj2)
            %eq  This function checks whether two pin objects refer to the same pin
            %
            %   Inputs:
            %      obj2  Pin object
            val = eq@Pin(obj1,obj2) && isa(obj2,'VectorOut');
        end % eq
        
        function obj = horzcat(varargin) %TODO
            %horzcat   This function concatenates the time evolution of a given pin
            %
            %    Note:  Time offsets syncronized. Function is NOT commutative!
            %
            %    Inputs
            %      varying number of pin objects to be concatenated
            if nargin<2
               error('insufficient number of parameters'); 
            end
            
            for k = 1:length(varargin)
                if ~isa(varargin{k},'VectorOut')
                    error('VectorOut objects needed');
                end
                if k>1 && ~(varargin{k}==varargin{k-1})
                    error('VectorOut objects are for different pins');
                end
            end
            
            obj = varargin{1}.copy();
            
            for k = 2:length(varargin)
                obj.timeOffset = obj.timeOffset + varargin{k}.times(1);
                
                for kk = 1:length(varargin{k}.waveforms)
                   wave = varargin{k}.getWaveformById(varargin{k}.waveforms(kk));
                   % compare to existing waveforms
                   [idx, ~] = obj.getWaveformIndex(wave);
                   
                   if idx==0
                       wave.id = obj.getWaveformIdentificationNumber(1);
                   end
                   obj.addWaveform(wave); 
                end
            end % for
            
            if length(obj.times)>1 && any(obj.times(2:end)<=0)
                warning('Some values of the sequence will be ignored due to zero delay conditions.'); 
            end
        end % horzcat
        function setPartnerPinMode(obj, mode)
            assert( isscalar(mode),...
                    'need a time as delay input');
            obj.partnerDelay = mode;
            obj.partnerPin.enabled = mode;
            obj.partnerPin.pin.partnerPin.enabled = mode;
        end % setPartnerPinMode
        
        function setPartnerDelay(obj, delay)
            assert( isscalar(delay),...
                    'need a time as delay input');
            obj.partnerDelay = delay;
        end % setPartnerDelay
        function obj = setAmplitudeModulation(obj, mode)
            assert( (strcmp(mode,'AC') || strcmp(mode,'DC')),...
                    'need AC or DC for Amplitude modulation mode');
            obj.amplitudeModulation = mode;
        end % setAmplitudeModulation
        
        function obj = setAngleModulation(obj, mode)
            assert( (strcmp(mode,'phase') || strcmp(mode,'frequency')), ...
                    'Indication of modulation for phase/frequency mising or wrong.');
            obj.angleModulation = mode;
            
            if strcmp(obj.angleModulation, 'phase')
                obj.adapted_max_value = obj.max_value([1 3]);
                obj.adapted_min_value = obj.min_value([1 3]);
            else
                obj.adapted_max_value = obj.max_value([1 2]);
                obj.adapted_min_value = obj.min_value([1 2]);
            end
        end % setAngleModulation
        
        function obj = setOffsets(obj, offsets)
            assert( isnumeric(offsets) && numel(offsets)==3, ...
                    'amplitude, frequency and phase offset required.');
            assert( all(offsets(:)>=obj.min_value) && all(offsets(:)<=obj.max_value), ...
                    'offset values out of range');
            obj.offset = offsets(:);
            
            if strcmp(obj.angleModulation, 'phase')
                obj.adapted_max_value = obj.max_value([1 2]);
                obj.adapted_min_value = obj.min_value([1 2]);
            else
                obj.adapted_max_value = obj.max_value([1 3]);
                obj.adapted_min_value = obj.min_value([1 3]);
            end
        end % setOffsets
        
        function obj = setCompensationParameters(obj, delay)
            assert( isnumeric(delay) && numel(delay)==2, ...
                    'delay and duration of the response funciton required');
            obj.partnerDelay = delay(1);
            obj.responseWidth = delay(2);
        end % setCompensation
        
        function obj = setPhaseScale(obj, factor)
            assert( isnumeric(factor) && numel(factor)==1, ...
                    'delay and duration of the response funciton required');
            obj.phaseFactor = factor;
        end % setPhaseScale
                
        function plot(obj, varargin)
            %plot    This function plots the time evolution of the pin
            fillcolor = [0.8 0.8 0.8];
            WFcolor = [1 0 0];
            timeOffsetcolor = [0 0.7 0];
            
            clf;
            
            if isempty(obj.times)
                return;
            end
            
            % create sampled time and value vectors
            [allvalues, alltimes] = obj.sampleAllWaveforms(200);
            
            % amplitude plot
            ax(1) = subplot(2,1,1);
            [xx,yy] = stairs(alltimes, allvalues(1,:));
            patch([0 xx' obj.timeOffset obj.timeOffset],[0 yy' yy(end) 0],fillcolor);
            line([obj.timeOffset obj.timeOffset],[0 1],'LineWidth',4,'Color',timeOffsetcolor);
            
            for k = 1:length(obj.times)
                line([obj.times(k) obj.times(k)], [0 .2],'LineWidth',1,'Color',WFcolor,'Linestyle', '--');
                text(obj.times(k),0.2,['\leftarrow' num2str(obj.waveforms(k))])
            end
            
            hold on
            stairs(alltimes,allvalues(1,:),'r');
            hold off
            
            if obj.timeOffset>0
                xlim([0 obj.timeOffset]);
            end
            if strcmp(obj.amplitudeModulation, 'AC')
                ylabel('amplitude (V)');
            else
                ylabel('offset voltage (V)');
            end
            xlabel('time (s)');
            grid on
            
            title(strcat(obj.getName(),' [',obj.toString(),']'));
            
            % phase plot
            ax(2)=subplot(2,1,2);
            [xx,yy] = stairs(alltimes,allvalues(2,:));
            patch([0 xx' obj.timeOffset obj.timeOffset],[0 yy' yy(end) 0],fillcolor);
            line([obj.timeOffset obj.timeOffset],[0 1],'LineWidth',4,'Color',timeOffsetcolor);
            
            for k = 1:length(obj.times)
                line([obj.times(k) obj.times(k)], [0 .2],'LineWidth',1,'Color',WFcolor,'Linestyle', '--');
                text(obj.times(k),0.2,['\leftarrow' num2str(obj.waveforms(k))])
            end
            
            hold on
            stairs(alltimes,allvalues(2,:),'r');
            hold off
            
            if obj.timeOffset>0
                xlim([0 obj.timeOffset]);
            end
            if strcmp(obj.angleModulation, 'phase')
                ylabel('phase (rad)');
            else
                ylabel('frequency (MHz)');
            end
            xlabel('time (s)');
            grid on
            
            linkaxes(ax, 'x');
        end % plot
        
        function [values, times] = sampleAllWaveforms(obj, samplesPerWaveform)
            %SAMPLE_ALL_WAVEFORMS  Calculates time and value vector for the full time evolution of the VectorOut pin
            assert( isnumeric(samplesPerWaveform) && isscalar(samplesPerWaveform) && samplesPerWaveform>0, ...
                    'Positive integer number required for samples per waveform');
            times = zeros(1,numel(obj.times)*samplesPerWaveform);
            values = zeros(2,numel(obj.times)*samplesPerWaveform);
            for k = 1:numel(obj.times)
                [val, ti] = obj.sampleWaveform(obj.getWaveformById(obj.waveforms(k)), samplesPerWaveform);
                idx = (k-1)*samplesPerWaveform+(1:samplesPerWaveform);
                times(idx) = obj.times(k)+ti;
                values(:,idx) = val;
            end
        end % sampleAllWaveforms
        
        
        %% methods related to setting states
        
        function obj = state(obj, x, varargin)
            %state   Set a new state in time evolution of this pin, call
            %        without any time will update the issue the latest state
            %        waveform
            %
            %   Inputs
            %       x            state values or array of state values to be added
            %       t(optional)  corresponding time vector with time differences
            %                    to earlier state / time offset
            if ~isnumeric(x) || size(x,1)~=2
                error('need frequency and phase input');
            end
            if nargin>2
                t = cumsum(varargin{1});
                if ~isnumeric(t)
                    error('time vector need to be numeric values');
                end
                if size(x,2)~= numel(t)
                    error('value and time vector need to have same length');
                end

                obj.timeOffset = obj.timeOffset + t(1); % to guarantee that first time delay is zero
                t = t-t(1);
            else
                t = 0;
            end
%             if any(any(x<obj.adapted_min_value)) || any(any(x>obj.adapted_max_value))
%                 error('Amplitude or Angle values are out of range.');
%             end
            
            if numel(t)==1 % a single state
                
                % add new state or override old one
                if isempty(obj.times) || obj.timeOffset>obj.lastTime
                    wave = struct( ...
                               'type', 'state', ...
                               'id', obj.getWaveformIdentificationNumber(1), ...
                               'duration', 0, ...
                               'state', x(:) ...
                              );
                          
                    obj.addWaveform(wave);
                else
                    warning('overriding old waveform %i of VetorOut pin ''%s'' due to zero time delay.', obj.lastWaveform.id, obj.toString());
                    obj.lastWaveform.state = x(:);
                    obj.waveformList.(obj.lastWaveform.type)(obj.lastWaveformListIndex) = obj.lastWaveform;
                end
                
            else % create vector waveshape (maybe used for optimal control ramps)
                %t = obj.getSamplingTime(t(end)-t(1), t);
                
                t = obj.smallestSamplingTime*(round(t/obj.smallestSamplingTime));
                
                % test validity
                test = t(2:end)<obj.smallestSamplingTime;
                if any(test)
                    t(test+1) = obj.smallestSamplingTime;
                    warning('Sampling time too small. Using smallest time of %i ns instead.', obj.smallestSamplingTime*1e9);
                end

                wave = struct( ...
                               'type', 'vector', ...
                               'id', obj.getWaveformIdentificationNumber(1), ...
                               'duration', t(end)-t(1), ...
                               'times', t, ...
                               'states', x ...
                              );

                obj.addWaveform(wave);
            end
        end % state
        
        function obj = linearRamp(obj, xf, T, varargin)
            %linearRamp    Create linear ramp starting from last state to final value xf
            %
            %   Inputs
            %       xf  Final value
            %        T  Duration in s
            %       st  (optional)  sampling time
            obj = obj.arbLinearRamp(obj.getLastState(), xf, T, varargin{:});
        end % linearRamp
        
        function obj = arbLinearRamp(obj, xi, xf, T, varargin)
            %linearRamp    Create linear ramp starting from initial state xi to final value xf
            %
            %   Inputs
            %       xi  Initial value
            %       xf  Final value
            %        T  Duration in s
            %       st  (optional)  sampling time
            if ~isnumeric(xi) || numel(xi)~=2
                error('initial state values expected to be of type numeric [Offset/Amplitude; Phase/frequency]');
            end
            if ~isnumeric(xf) || numel(xf)~=2
                error('final state values expected to be of type numeric [Offset/Amplitude; Phase/frequency]');
            end
            if ~isscalar(T) || T<obj.smallestSamplingTime
                error('time duration expected to be positive number');
            end
            st = obj.getSamplingTime(T,varargin{:});
%             if any(xi(:)<obj.adapted_min_value) || any(xi(:)>obj.adapted_max_value) ... rough check on values
%                 || any(xf(:)<obj.adapted_min_value) || any(xf(:)>obj.adapted_max_value)
%                 error('State values are out of range.');
%             end

            wave = struct( ...
                           'type', 'linear', ...
                           'id', obj.getWaveformIdentificationNumber(1), ...
                           'duration', T, ...
                           'samplingTime', st, ...
                           'initialState', xi(:), ...
                           'finalState', xf(:), ...
                           'samples', T/st ...
                          );
            
            obj.addWaveform(wave);
        end % arbitrary linearRamp
        
        function obj = sinusoidalRamp(obj, xf, T, varargin)
            %sinusoidalRamp    Create sinusoidal ramp from last state to final final value xf
            %
            %   Inputs
            %       xf  Final value
            %        T  Duration in s
            %       st  (optional)  sampling time
            obj.arbSinusoidalRamp(obj.getLastState, xf, T, varargin{:});
        end % sinusoidalRamp
        
        function obj = arbSinusoidalRamp(obj, xi, xf, T, varargin)
            %sinusoidalRamp    Create sinusoidal ramp from initial state xi to final final value xf
            %
            %   Inputs
            %       xi  Initial state
            %       xf  Final value
            %        T  Duration in s
            %       st  (optional)  sampling time
            if ~isnumeric(xi) || numel(xi)~=2
                error('initial state values expected to be of type numeric [Offset/Amplitude; Phase/frequency]');
            end
            if ~isnumeric(xf) || numel(xf)~=2
                error('final state values expected to be of type numeric [Offset/Amplitude; Phase/frequency]');
            end
            if ~isscalar(T) || T<obj.smallestSamplingTime
                error('time duration expected to be positive number');
            end
            st = obj.getSamplingTime(T,varargin{:});
%             if any(xi(:)<obj.adapted_min_value) || any(xi(:)>obj.adapted_max_value) ... rough check on values
%                 || any(xf(:)<obj.adapted_min_value) || any(xf(:)>obj.adapted_max_value)
%                 error('State values are out of range.');
%             end

            wave = struct( ...
                           'type', 'sinusoidal', ...
                           'id', obj.getWaveformIdentificationNumber(1), ...
                           'duration', T, ...
                           'samplingTime', st, ...
                           'initialState', xi(:), ...
                           'finalState', xf(:), ...
                           'samples', T/st ...
                          );
            
            obj.addWaveform(wave);
        end % arbitrary sinusoidalRamp

        function obj = arbitraryRamp(obj, fh, T, varargin)
            %arbitryryRamp  Create ramp given by function handle
            %
            %  Note:  The user need to make sure that the maximum absolute
            %         value is iven by the initial or final value.
            %
            %   Inputs
            %       fh  Function handle
            %        T  Duration in s
            %       st  (optional)  sampling time, negative sampling time results in amplitude sampling with amplitude sampling step abs(st)
            if ~isa(fh, 'function_handle')
                error('function handle expected');
            end
            if ~isscalar(T) || T<obj.smallestSamplingTime
                error('time duration expected to be positive number');
            end
            st = obj.getSamplingTime(T,varargin{:});
            if any(fh(0)<obj.adapted_min_value) || any(fh(0)>obj.adapted_max_value) ... rough check on values
                || any(fh(T)<obj.adapted_min_value) || any(fh(T)>obj.adapted_max_value)
                error('Amplitude values are out of range.');
            end

            wave = struct( ...
                           'type', 'arbitrary', ...
                           'id', obj.getWaveformIdentificationNumber(1), ...
                           'duration', T, ...
                           'samplingTime', st, ...
                           'functionHandle', fh, ...
                           'samples', T/st,...
                           'initialState',[0;fh(0)],...
                           'finalState',[0;fh(T)] ...                
                          );
            
            obj.addWaveform(wave);
        end % arbitraryRamp
        
        function obj = modulation(obj,Amp,freq,T) 
            %This funciton is meant to introduce modulations to the phase
            %of the beam and therefore shake the lattice with a specified
            %frequency freq. Since these modulations tend to be in a
            %frequeny regime where the PLL already introduces significant
            %distortions to the phase ramps, this function is solely meant
            %to be queued on the FFL PIN. for modulations of slower
            %frequency use the cosinusoidalRamp functionality in a loop. 
            wave = struct( ...
                           'type', 'modulation', ...
                           'id', obj.getWaveformIdentificationNumber(1), ...
                           'duration', T, ...
                           'frequency' ,freq,...
                           'amplitude' ,Amp, ...
                           'samples', (1/(freq*2e-8)),...
                           'samplingTime',2e-8...
                          );
            if isfield(obj.partnerPin.pin)
                obj.partnerPin.pin.compensationRamp(waveform,obj.timeOffset);
                obj.addWaveform(wave);
            else 
                error('no partnerPin assigned. no modulation possible');
            end
            
        end
        
    

        function obj = compensationRamp(obj, wave, lasttime)
            % this function should take the input wave and convolute it
            % with the pin specific response function. it has to be checked
            % that the time offset for the pin is not ahead of the pin
            % receiving the compensation. there should be a sync before
            % doing any ramp with this option enabled
            if ~isstruct(wave)
                error('Waveform struct required.');
            end
            if ~isscalar(lasttime)
                error('last time of pin required.');
            end
            if obj.timeOffset > lasttime           
               error('Partner Pin out of sync. syncronize pins before adding a feedforward enabled waveform.')
            end
            if obj.timeOffset < lasttime 
                obj.wait(lasttime-obj.timeOffset);
            end
            if strcmp(wave.type,'modulation')
                compensation = obj.getRepConv(wave,obj.responseWidth);
            else
                % convolution. The goal is to produce a fh that includes the
                % convolution of wave and the pin specific response.


                %include delay and width parameter specific to the pins.
                compensation = obj.getGaussConv(wave,obj.responseWidth);
                newWave = struct( ...
                               'type', 'compensation', ...
                               'id', obj.getWaveformIdentificationNumber(1), ...
                               'duration', length(compensation)*20e-9, ...
                               'samplingTime', 20e-9, ...
                               'functionHandle', compensation,...% fhNew, ...
                               'samples', length(compensation)...
                              );
            end
            
            obj.addWaveform(newWave);             
            
        end
        function obj = addWaveform(obj, waveform)
            % ADD_WAVEFORM  adds new ramp to the list of waveforms and 
            % time/value/waveform vector set states correctly
            
            % - input handling
            if ~isstruct(waveform)
                error('Waveform struct required.');
            end
            
            % check for waits 
            deltaT = obj.timeOffset-obj.lastTime;
            if deltaT>0
                % - extend old state waveform if possible
                if isfield(obj.lastWaveform,'type') && strcmp(obj.lastWaveform.type,'state') 
                    if strcmp(waveform.type,'state') && all(waveform.state==obj.lastWaveform.state) % avoid adding same state waveform again
                        obj.timeOffset = obj.timeOffset + waveform.duration;
                        obj.lastWaveform.duration = obj.timeOffset-obj.times(end);
                        obj.waveformList.(obj.lastWaveform.type)(obj.lastWaveformListIndex).duration = obj.timeOffset-obj.times(end);
                        obj.lastTime  = obj.timeOffset;
                        return;
                    end
                    obj.waveformList.(obj.lastWaveform.type)(obj.lastWaveformListIndex).duration = obj.timeOffset-obj.times(end);
                    obj.lastWaveform.duration = obj.timeOffset-obj.times(end);
                else % add new state waveform first %TODO discuss this with stefan
                    waveNew = struct( ...
                                      'type', 'state', ...
                                      'id', obj.getWaveformIdentificationNumber(1), ...
                                      'duration', deltaT, ...
                                      'state', obj.getLastState()...%obj.sampleWaveform(obj.lastWaveform, 1) ...
                                     );
                    obj.timeOffset = obj.lastTime;
                    obj.addWaveform(waveNew);
                end
            end
            
            % checks if waveform already exists
            [foundWaveformIdx, waveform] = obj.getWaveformIndex(waveform);
            
            %% adding waveform
            values = obj.sampleWaveform(waveform, 2);      
            
            obj.times  = [obj.times  obj.timeOffset];
            obj.values = [obj.values values(:,1)];
            obj.waveforms = [obj.waveforms waveform.id];
            obj.timeOffset = obj.times(end) + waveform.duration;
            
            obj.lastValue = values(:,2);
            obj.lastTime  = obj.timeOffset;
            obj.lastWaveform = waveform;
            
            
            
            if foundWaveformIdx 
                obj.lastWaveformListIndex = foundWaveformIdx;
            else
                obj.waveformList.(waveform.type) = [obj.waveformList.(waveform.type) waveform];
                obj.lastWaveformListIndex = numel(obj.waveformList.(waveform.type)); % might actually be wrong here!!! todo
            end
            if isfield(obj.partnerPin, 'pin') && obj.partnerPin.enabled && ~obj.partnerPin.isSlave 
                if strcmp(waveform.type,'state') 
                    Val = obj.getLastState();
                    if any(waveform.state ~= Val)       %check if there is a change in value.
                        obj.partnerPin.pin.compensationRamp(waveform,obj.timeOffset);
                    end
                elseif ~strcmp(waveform.type,'modulation')
                    obj.partnerPin.pin.compensationRamp(waveform,obj.timeOffset);
                end
            end
            
                
        end % addWaveform
        
        function [wave, index] = getWaveformById(obj, id)
            %GET_WAVEFORM_BY_ID  Returns waveform struct with given ID and
            %                    position (index) in waveformList array
            if ~isnumeric(id) || ~isscalar(id)
                error('Waveform ID not valid');
            end
            
            for type = fieldnames(obj.waveformList)'
                if isempty(obj.waveformList.(type{:}))
                    continue;
                end
                waveIds = [obj.waveformList.(type{:}).id];
                index = find(waveIds==uint64(id),1,'first');
                
                if ~isempty(index)
                    wave = obj.waveformList.(type{:})(index);
                    return;
                end
            end
            error('No waveform found or ID %i', id);
        end % getWaveformById
        
        function [index, wave] = getWaveformIndex(obj, waveform)
            %GET_WAVEFORM_INDEX  checks if waveform does exist in
            %                    waveformList and return array index
            %
            %  Inputs:
            %     wavform  Waveform struct to be tested
            %
            %  Outputs:
            %       index  Index of waveform in waveformList array for
            %              corresponding waveform type
            %        wave  Found waveform object / or user object
            switch waveform.type
                case {'arbitrary', 'state','compensation'}
                    % nothing to do since hard to compare
                    
                case {'linear', 'sinusoidal'}
                    for k = 1:numel(obj.waveformList.(waveform.type))
                        testWave = obj.waveformList.(waveform.type)(k);
                            
                        if all(abs(testWave.initialState-waveform.initialState)<eps) ...
                            && all(abs(testWave.finalState-waveform.finalState)<eps) ...
                            && abs(testWave.duration-waveform.duration)<eps ...
                            && abs(testWave.samplingTime-waveform.samplingTime)<eps ...
                            
                            index = k;
                            wave = testWave;
                            return;
                        end
                    end
                    
                case 'vector'
                    for k = 1:numel(obj.waveformList.(waveform.type))
                        testWave = obj.waveformList.(waveform.type)(k);
                            
                        if all(abs(testWave.times<waveform.times)<eps)...
                            && all(abs(testWave.states(:)<waveform.states(:))<eps)
                            
                            index = k;
                            wave = testWave;
                            return;
                        end
                    end
                    
                otherwise
                    error('unsupported waveform type');
            end
            
            wave = waveform;
            index = 0;
        end % getWaveformIndex
        
        function obj = sync(obj)
            %SYNC   Converts waits to waveform objects
            if exist('obj.lastWaveform.duration')
                deltaT = obj.timeOffset-(obj.lastTime+obj.lastWaveform.duration); % todo checking
            else
                deltaT = obj.timeOffset;
            end
            if deltaT>0
                if isfield(obj.lastWaveform,'type') 
                    if strcmp(obj.lastWaveform.type,'state') % extend old state waveform
                        obj.waveformList.(obj.lastWaveform.type)(obj.lastWaveformListIndex).duration = obj.timeOffset-obj.times(end);
                        obj.lastWaveform.duration = obj.timeOffset-obj.times(end);
                    else % add new state waveform
                            waveNew = struct( ...
                                      'type', 'state', ...
                                      'id', obj.getWaveformIdentificationNumber(1), ...
                                      'duration', deltaT, ...
                                      'state', obj.sampleWaveform(obj.lastWaveform, 1) ...
                                     );
                            obj.timeOffset = obj.lastTime;
                            obj.addWaveform(waveNew);
                    end
                else % add new state waveform
                    waveNew = struct( ...
                                      'type', 'state', ...
                                      'id', obj.getWaveformIdentificationNumber(1), ...
                                      'duration', deltaT, ...
                                      'state', [0;0] ...
                                     );
                    obj.timeOffset = obj.lastTime;
                    obj.addWaveform(waveNew);
                end
            end
        end % sync
        
        
        %% methods related to getting states
        
        function [y,x] = getState(obj,t)
            %getState    This function returns the state at a given time
            %
            %   Inputs
            %        t   Time value
            %
            %  Outputs
            %        y  values
            %        x  start time of corresponding waveform
            
            % find waveform id
            if ~isscalar(t) || t<0
                error('non-negative number required for time variable');
            end
            
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            ind = find(obj.times<=t,1,'last');

            x = obj.times(ind); % return time in time vector (and not within in waveform)
            y = obj.sampleWaveform(obj.getWaveformById(obj.waveforms(ind)), [], t-x);
        end % getState
        
        function [y,x] = getLastState(obj)
            %getFirstState   This function returns the last state of the
            %                time evolution
            y = obj.lastValue;
            if obj.timeOffset>obj.lastTime
                x = obj.timeOffset;
            else
                x = obj.lastTime;
            end
        end % getLastState
        
        
        function max_vals = getLargestValues(obj)
            %GET_LARGEST_VALUES  Return the largest absolute alues
            vals = zeros(2,5);
            
            for wtype = fieldnames(obj.waveformList)'
                
                if isempty(obj.waveformList.(wtype{:}))
                    continue;
                end
                
                switch wtype{:}
                    case 'arbitrary'
                        valsArb = arrayfun(@(x) [x.functionHandle(0), x.functionHandle(x.duration)] , ...
                                           obj.waveformList.(wtype{:}), 'UniformOutput', 0);
                        vals(:,1) = max(abs(cell2mat(valsArb)), [], 2);
                        
                    case 'linear'
                        valsLin = arrayfun(@(x) [x.initialState, x.finalState] , ...
                                           obj.waveformList.(wtype{:}), 'UniformOutput', 0);
                        vals(:,2) = max(abs(cell2mat(valsLin)), [], 2);
                        
                    case 'sinusoidal'
                        valsSin = arrayfun(@(x) [x.initialState, x.finalState] , ...
                                           obj.waveformList.(wtype{:}), 'UniformOutput', 0);
                        vals(:,3) = max(abs(cell2mat(valsSin)), [], 2);
                        
                    case 'state'
                        valsState = [obj.waveformList.(wtype{:}).state];
                        vals(:,4) = max(abs(valsState), [], 2);
                        
                    case 'vector'
                        valsVec = arrayfun(@(x) max(abs(x.states),[],2) , ...
                                           obj.waveformList.(wtype{:}), 'UniformOutput', 0);
                        vals(:,5) = max(cell2mat(valsVec), [], 2);
                    case 'compensation' 
                        
                    
                    otherwise
                            error('unsupported waveform type');
                end
            end
            
            max_vals = max(vals, [], 2);
        end %getLargestValues
        
        function idx = splitWaveformsAtTimes(obj, times)
            %SPLIT_WAVEFORMS_AT_TIMES  Splits waveforms at given times and
            %                          returns times vector indices of the given times
            idx = zeros(size(times));
            if ~isnumeric(times)
                warning('Times are not in the correct vector format');
                return;
            end
            
            obj.sync();
            
            for k = 1:numel(times)
                timeEdge = times(k);
                if timeEdge == 0
                    continue
                end
                               
                if timeEdge>obj.lastTime+obj.lastWaveform.duration
%                     warning('desired splitting time of %f s larger than current sequence duration %f s.', timeEdge, obj.lastTime+obj.lastWaveform.duration);
                    continue;
                end
                
                % find exact matches
                idxTmp = find(abs(obj.times-timeEdge)<eps, 1, 'first');
                
                if ~isempty(idxTmp)
                   idx(k) = idxTmp;
                   continue;
                end
                
                % splittig necesary
                idxTmp = find(obj.times<timeEdge, 1, 'last');
                
                [wave, waveIndex] = obj.getWaveformById(obj.waveforms(idxTmp));
                
                switch wave.type
                    case {'arbitrary', 'linear', 'sinusoidal', 'vector'}
                        warning('Waveshape %i of pin %s would need to be splitted due to triggering event.', idxTmp, obj.toString());
                        idx(k) = idxTmp;
                    
                    case 'state'
                        obj.waveformList.(wave.type)(waveIndex).duration = timeEdge-obj.times(idxTmp);
                        
                        waveNew = wave;
                        waveNew.id = obj.getWaveformIdentificationNumber(1);
                        waveNew.duration = obj.times(idxTmp)+wave.duration-timeEdge;
                        
                        if idxTmp==numel(obj.times)
                            obj.lastWaveform = waveNew;
                            obj.lastWaveformListIndex = numel(obj.waveformList.(wave.type))+1;
                        end
                        
                        obj.waveformList.(wave.type) = [obj.waveformList.(wave.type) waveNew];
                        obj.times(idxTmp+1:end+1)     = [timeEdge obj.times(idxTmp+1:end)];
                        obj.values(:,idxTmp+1:end+1)  = [waveNew.state(:) obj.values(:,idxTmp+1:end)];
                        obj.waveforms(idxTmp+1:end+1) = [waveNew.id obj.waveforms(idxTmp+1:end)];
                        
                        idx(k) = idxTmp+1;
                        
                    otherwise
                        error('unsupported waveform type: ''%s'' ', wave.type);
                end
            end
        end % splitWaveformsÁtTimes 
        
        
        %% helper methods
        function st = getSamplingTime(obj, duration, varargin)
            %GET_SAMPLING_TIME  Calculates standard sampling time given
            %the waveform duration time and (optional) a suggested required
            %samplingTime
            
            counts = duration/obj.smallestSamplingTime;
            st = ceil(counts/100000)*obj.smallestSamplingTime; % use prescaler above 100000 data points
            
            if nargin>2
                st = varargin{1};
                if ~isnumeric(st) ||  any(st<0)
                    error('invalid sampling time format');
                end
                
                st = obj.smallestSamplingTime*(round(st/obj.smallestSamplingTime));
                
                % test validity
                test = st<obj.smallestSamplingTime;
                if any(test)
                    st(test) = obj.smallestSamplingTime;
                    warning('Sampling time too small. Using smallest time of %i ns instead.', obj.smallestSamplingTime*1e9);
                end
                
                test = st>obj.largestSamplingTime;
                if any(test)
                    st(test) = obj.largestSamplingTime;
                    warning('Sampling time too large. Using largest time of %i ns instead.', obj.largestSamplingTime*1e9);
                end
            end
        end % getSamplingTime
        
    end %methods
    
end % classdef
