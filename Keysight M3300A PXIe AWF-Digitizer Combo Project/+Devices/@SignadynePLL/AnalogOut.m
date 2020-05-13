classdef AnalogOut < Pin
    %AnalogOut    Class for analog output pins
    
    properties (SetAccess = private)
        calibration;
        min_value = -10;
        max_value = 10;
        res_value = 20/(2^16-1);
        res_time = 1/3e8;
        
        valuesCalibrated = [];
    end % properties
    
    methods
        function obj = AnalogOut(c, varargin)
            %AnalogOut   Default constructor
            %
            %   Inputs:
            %         c    Pin name (default constructor)
            %              or existing pin (copy constructor)
            %  userName   (optional) user defined name, set in default
            %              constructor mode
            obj = obj@Pin(c, varargin{:});
        end % AnalogOut
        
        function val = eq(obj1, obj2)
            %eq  This function checks whether two pin objects refer to the same pin
            %
            %   Inputs:
            %      obj2  Pin object
            val = eq@Pin(obj1,obj2) && isa(obj2,'AnalogOut');
        end % eq
        
        function plot(obj,varargin)
            %plot    This function plots the time evolution
            %
            %    Inputs:
            %      (opional) alone   argument controls whether plotting alone (1) or with hold on (0)
            plot@Pin(obj,varargin{:});
            ylim([obj.min_value obj.max_value]);
        end % plot
        
        
        %% methods related to setting states
        
        function obj = horzcat(varargin)
            %horzcat   This function concatenates the time evolution of a given pin
            %
            %    Note:  Time offsets will be syncronized. Function is NOT commutative!
            %           Calibration of first object used
            %
            %    Inputs
            %      varying number of pin objects to be concatenated
            if nargin<2
               error('insufficient number of parameters'); 
            end
            for k = 1:length(varargin)
                if ~isa(varargin{k},'AnalogOut')
                    error('AnalogOut objects needed');
                end
            end
            
            obj = horzcat@Pin(varargin{:});
            % redo calibration on existing values
            obj.valuesCalibrated = obj.calibration.inverseInterpolate(obj.values);
        end % horzcat
        
        function obj = state(obj, x, varargin)
            %state   Set a new state in time evolution of this pin
            %
            %   Inputs
            %       x            state value or array of states to be added
            %       t(optional)  corresponding time vector with time differences
            %                    to earlier state / time offset
            if nargin==3
                if ~isnumeric(varargin{1})
                    error('time vector need to be numeric values');
                end
                t = varargin{1};
            else
                t = zeros(1,numel(x));
            end
            if ~isnumeric(x)
                error('need analog input');
            end
            
            %calibration
            calX = x;
            x = obj.calibrate(x);
            
            if any(x<obj.min_value) || any(x>obj.max_value)
                error('need valid analog input');
            end
            
            %rounding
            t = obj.res_time*floor(t/obj.res_time);
            x = obj.res_value*floor(x/obj.res_value);
            
            obj = state@Pin(obj,x,t);
            obj.valuesCalibrated = [obj.valuesCalibrated calX];
        end % state
        
        function obj = linearRamp(obj, xf, T, varargin)
            %linearRamp    Create linear ramp starting from last state to final value xf
            %
            %   Inputs
            %       xf  Stop value
            %        T  Duration in s
            %       st  (optional)  sampling time
            if ~isnumeric(xf) || ~isscalar(xf)
                error('state values expected to be of type numeric');
            end
            
            xi = obj.getLastState();
            fh = @(ti) xi + (ti/T)*(xf-xi);
            obj = obj.arbitraryRamp(fh, T, varargin{:});
        end % linearRamp
        
        function obj = sinusoidalRamp(obj, xf, T, varargin)
            %sinusoidalRamp    Create sinusoidal ramp from last state to final final value xf
            %
            %   Inputs
            %       xf  Stop value
            %        T  Duration in s
            %       st  (optional)  sampling time
            if ~isnumeric(xf) || ~isscalar(xf)
                error('state values expected to be of type numeric');
            end
                    
            xi = obj.getLastState();
            
            fh = @(ti) xi - (xf-xi).*(cos(ti/T*pi)-1)/2;
                
            obj = obj.arbitraryRamp(fh, T, varargin{:});
        end % sinusoidalRamp

        function obj = arbitraryRamp(obj, fh, T, varargin)
            %arbitryryRamp  Create ramp given by function handle
            %
            %   Inputs
            %       fh  Function handle
            %        T  Duration in s
            %       st  (optional)  sampling time, negative sampling time results in amplitude sampling with amplitude sampling step abs(st)
            if nargin>4
                error('too many input parameters given');
            elseif nargin==4
                st = varargin{1};
            else
                st = T/100;
            end
            if ~isscalar(T) || ~(T>0)
                error('time duration expected to be positive number');
            end
            if ~isscalar(st) || st==0
                error('sampling time expected to be a non-zero scalar');
            end
            if ~isa(fh, 'function_handle')
                error('function handle expected');
            end
            
            if st>0
                ti = 0.5*st : st : T;   % set nodes in the middle of sampling time interval

                if ti(end)~=T
                    ti(end+1) = T;
                end

            else
                %st = amplitude scaling
                ti = sampleAmplitudeUniform(0, T, fh, abs(st));
                ti(end+1) = T;
            end
            
            obj = obj.state(fh(ti), [st/2 diff(ti)]);
        end % arbitraryRamp
        
        
        %% methods related to getting states
        
        function [y,x] = getState(obj,t)
            %getState    This function returns the state at a given time
            %
            %   Inputs
            %        t   Time value
            if ~isscalar(t) || t<0
                error('non-negative number required for time variable');
            end
            
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            ind = find(obj.times<=t,1,'last');
            
            x = obj.times(ind);
            
            %inverse calibration
            if isempty(obj.calibration)
                y = obj.values(ind);
            else
                y = obj.valuesCalibrated(ind);
            end
        end % getState
        
        function [y,x] = getFirstState(obj)
            %getFirstState   This function returns the first state of the
            %                time evolution
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            if isempty(obj.calibration)
                y = obj.values(1);
            else
                y = obj.valuesCalibrated(1);
            end
            x = obj.times(1);
        end % getFirstState
        
        function [y,x] = getLastState(obj)
            %getLastState    This function returns the first state of the
            %                time evolution
            if isempty(obj.values)
                x = [];
                y = [];
                return;
            end
            
            if obj.timeOffset>obj.times(end)
                x = obj.timeOffset;
            else
                x = obj.times(end);
            end
            
            %inverse calibration
            if isempty(obj.calibration)
                y = obj.values(end);
            else
                y = obj.valuesCalibrated(end);
            end
        end % getLastState
        
        
        %% methods related to calibration
        
        function output = hasCalibration(obj)
            %hasCalibration   Checks if calibration object is assigned to this pin.
            
            output = ~isempty(obj.calibration);
        end % hasCalibration
        
        function obj = addCalibration(obj, cal)
            %addCalibration   Adds calibration to pin
            %
            %   Inputs
            %       cal   calibration object
            assert( isa(cal,'Calibration'), ...
                    'Calibration object expected');
            obj.calibration = cal;
            
            % redo calibration on existing values
            obj.valuesCalibrated = obj.calibration.inverseInterpolate(obj.values);
        end % addCalibration
        
        function cal = getCalibration(obj)
            %getCalibration  Returns calibration object
            if isempty(obj.calibration)
                error('no Calibration objects has been assigned to this pin');
            end
            
            cal = obj.calibration;
        end % getCalibration
        
        function obj = removeCalibration(obj)
            %removeCalibration  This function removes the calibration from pin object
            obj.calibration = [];
            
            % redo calibration on existing values
            obj.valuesCalibrated = obj.values;
        end % removeCalibration
        
        function val = calibrate(obj, x)
            %calibrate  Calibrate data to voltages if calibration object is given
            %
            %   Inputs
            %         x  Value array which will be calibrated to voltages
            assert( isnumeric(x), ...
                    'need numeric input');
            
            %calibration
            if isempty(obj.calibration)
                val = x;
            else
                val = obj.calibration.interpolate(x);
            end
            
            %check for valid value range
            if any(val<obj.min_value) || any(val>obj.max_value) || any(isfinite(val)==0)
                error('Calibration exceeds valid value range');
            end
        end % calibrate
        
    end % methods
    
end % classdef


function ti = sampleAmplitudeUniform(tbegin, tend, fh, as)
    %sampleAmplitudeUniform   Returns the time vector for a uniform amplitude sampling
    %
    %   Inputs
    %       tbegin   Starting time
    %         tend   Stop time
    %           fh   function handle
    %           as   amplitude step
    assert( isscalar(tbegin) && isscalar(tend) && tbegin>=tend, ...
            'Start time needs to be smaller than stop time.');

    % define standard amplitude sampling
    if as<=0
        as = 0.1;
    end
    
    %smallest intervall
    eps = 1e-6;
    
    err = abs( fh(tend)-fh(tbegin) );

    if (err<as) || (abs(tend-tbegin)<eps)
        %abort criterion
        ti = tbegin;
    else
        %nested intervals
        ti = [sampleAmplitudeUniform(tbegin, tbegin+(tend-tbegin)/2, fh, as) sampleAmplitudeUniform(tbegin+(tend-tbegin)/2, tend, fh, as)];
    end
    
end %sampleAmplitudeUniform
