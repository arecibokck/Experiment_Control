classdef K33522BChannel < handle
    
    properties
        Parent
        ChannelNumber
        WaveformList % arbitrary waveform container
        RescaledList % data normalized to [-1,+1]
    end % - Basic containers
    
    properties (Dependent)
        % slope of trigger (Pos)|Neg
        TriggerSlope
        % source of Trigger ={'IMM','BUS','EXT','INT'};
        TriggerSource
        % NumberOfTriggers accepted (will do measurement this many times)
        TriggerCount
        % - Sets timer used when TRIGger[1|2]:SOURce is TIMer.
        TriggerTimer
        % - Sets the output trigger level and input trigger threshold in volts. The trigger threshold is one-half of the trigger level
        TriggerLevel
        % - Sets trigger delay, (time from assertion of trigger to occurrence of triggered event)
        TriggerDelay
    end % - Trigger options
    
    properties (Dependent)
        % -  Enable or disable the burst mode
        BurstState
        % - Select the triggered burst mode (called "N Cycle" on the front panel) or external gated burst mode
        BurstMode
        % - Set the burst count (number of cycles per burst) to any value between 1 and 100,000,000 cycles (or infinite)
        BurstCycles
        % - Set the starting phase of the burst from -360 to +360 degrees
        BurstPhase
        % - Selects true-high (NORMal) or true-low (INVerted) logic levels on the rear-panel Ext Trig connector for an externally gated burst
        BurstGatePolarity
        % - Set the burst period (the interval at which internally-triggered bursts are generated) to any value from 1 ?s to 8000 seconds
        BurstInternalPeriod
    end % - Burst options
    
    properties (Dependent)
        SamplingRate
        Impedance
    end % - General options
    
    properties (Dependent)
        FrequencyCenter
        FrequencyMode
        FrequencySpan
        FrequencyStart
        FrequencyStop
        FrequencyDwellTime
        FrequencyList
    end % - Frequency options
    
    properties (Dependent)
        OutputState
        OutputLoad
        OutputMode
        OutputPolarity
        OutputSync
        OutputSyncMode
        OutputSyncPolarity
        OutputSyncSource
        OutputTriggerState
        OutputTriggerSlope
        OutputTriggerSource
    end % - Output options
    
    methods
        function this =  K33522BChannel(Parent, Channel) %Constructor and initialization
            % - input handling
            this.Parent=Parent;
            this.ChannelNumber = Channel;
            disp('K33522BChannel object constructed.');
        end
    end  % - Lifecycle functions
    methods
        function upload(this)
            if length(this.Waveform)<2
                error('Need at least two data')
            end
            if(this.ChannelNumber ~= 1 && this.ChannelNumber ~= 2)
                error('this.ChannelNumber must be either Ch 1 or Ch 2');
            end
            
            % transmit the data using SCPI commands
            this.Parent.send(sprintf('SOUR%d:DATA:VOL:CLE', this.ChannelNumber));
            % set to LSB first
            this.Parent.send('FORM:BORD SWAP');
            % upload a binary block in Agilent format, thankfully
            % supported in matlab
            binblockwrite(this.vi, this.Rescaled, 'float32', sprintf('SOUR%d:DATA:ARB ARB_1, ', this.ChannelNumber));
            this.Parent.send('*WAI'); % wait for upload to be processed
            
            
            this.Parent.send(sprintf('SOUR%d:FUNC:ARB ARB_1', this.ChannelNumber));   %select ARB_1 as current arbitrary waveform
            this.Parent.send(sprintf('SOUR%d:FUNC ARB', this.ChannelNumber)); % set generator to arbitrary waveform
            this.Parent.send(sprintf('SOUR%d:FUNC:ARB:SRAT %.7f', this.ChannelNumber, this.Rate*1e6));
            this.Parent.send(sprintf('SOUR%d:FUNC:ARB:ADV SRAT', this.ChannelNumber));
            
            % set signal parameters
            if(this.Impedance == 10000)
                this.Parent.send(sprintf('OUTP%d:LOAD INF',this.ChannelNumber));
            else
                this.Parent.send(sprintf('OUTP%d:LOAD 50',this.ChannelNumber));
            end
            
            this.Parent.send(sprintf('SOUR%d:VOLT %.5f', this.ChannelNumber, max(this.Waveform)-min(this.Waveform)));
            this.Parent.send(sprintf('SOUR%d:VOLT:OFFS %.5f', this.ChannelNumber, 0.5*(max(this.Waveform)+min(this.Waveform))));
            
            % set triggering
            if this.BurstState
                this.Parent.send(sprintf('SOUR%d:BURS:MODE TRIG', this.ChannelNumber));
                this.Parent.send(sprintf('SOUR%d:BURS:NCYC %d', this.ChannelNumber, this.BurstCyc));
                this.Parent.send(sprintf('SOUR%d:BURS:STAT ON', this.ChannelNumber));
                this.Parent.send(sprintf('TRIG%d:SOUR EXT', this.ChannelNumber));
            else
                this.Parent.send(sprintf('SOUR%d:BURS:STAT OFF', this.ChannelNumber));
                this.Parent.send(sprintf('TRIG%d:SOUR IMM', this.ChannelNumber));
            end
            
            this.Parent.send(sprintf('OUTP%d ON', this.ChannelNumber));
            this.getError();
        end  % - upload the arbitrary waveform
        function preview(this)
            if length(this.Waveform)<2
                error('Need at least two data')
            end
            clf;
            t = (1:length(this.Waveform))/this.Rate;
            stem(t, this.Waveform);
            title(sprintf('Preview of data for channel #%d', this.ChannelNumber));
            xlabel('Time [us]');
            ylabel('Voltage [V]');
        end % - preview the arbitrary waveform
    end  % - Upload arbitrary waveforms
    methods
        function setFrequency(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = p.Results.frequency;
            assert(isnumeric(frequency)&& frequency>=0 || any(strcmpi(frequency,{'MIN','MAX'})),...
                'Frequency must be positiv numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(frequency,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency %s',this.ChannelNumber, num2str(frequency)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency %s',this.ChannelNumber, frequency));
            end
        end      % - set the Frequency
        function setAmplitude(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'high', 'DEF', @isnumeric);
            addOptional(p, 'low', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            addOptional(p, 'autorange', 'ON', @ischar);
            parse(p, this, varargin{:});
            amplitude = num2str(p.Results.amplitude);
            high = num2str(p.Results.high);
            low = num2str(p.Results.low);
            offset = num2str(p.Results.offset);
            autorange = p.Results.autorange;
            
            if ~strcmp(amplitude, 'DEF')
                this.Parent.send(sprintf('SOURce%d:VOLTage %s',this.ChannelNumber, amplitude));
            end
            
            if ~strcmp(offset, 'DEF')
               this.Parent.send(sprintf('SOURce%d:VOLTage:OFFSet %s',this.ChannelNumber, offset)); 
            end
            
            if ~strcmp(high, 'DEF') && strcmp(low, 'DEF')
                warning('Low set to default');
                this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, high));
                this.Parent.send(sprintf('SOURce%d:VOLTage:LOW %s',this.ChannelNumber, low));
            elseif ~strcmp(low, 'DEF') && strcmp(high, 'DEF')
                warning('High set to default');
                this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, high));
                this.Parent.send(sprintf('SOURce%d:VOLTage:LOW %s',this.ChannelNumber, low));
            elseif ~strcmp(high, 'DEF') && ~strcmp(low, 'DEF')
                this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, high));
                this.Parent.send(sprintf('SOURce%d:VOLTage:LOW %s',this.ChannelNumber, low));
            end
            
            this.Parent.send(sprintf('SOURce%d:VOLTage:RANGe:AUTO %s',this.ChannelNumber, autorange));
        end      % - set the Amplitude
    end  % - Set parameters for built-in waveforms
    methods
        function ret = getFrequency(this)
            ret = this.Parent.query(sprintf('SOURce%d:FREQuency?',this.ChannelNumber));
        end      % - get the Frequency
        function ret = getAmplitude(this, querystring)
            if strcmp(querystring, 'amplitude')
                ret = this.Parent.query(sprintf('SOURce%d:VOLTage?',this.ChannelNumber));
            elseif strcmp(querystring, 'high')
                ret = this.Parent.query(sprintf('SOURce%d:VOLTage:HIGH?',this.ChannelNumber));
            elseif strcmp(querystring, 'low')
                ret = this.Parent.query(sprintf('SOURce%d:VOLTage:LOW?',this.ChannelNumber));
            elseif strcmp(querystring, 'offset')
                ret = this.Parent.query(sprintf('SOURce%d:VOLTage:OFFSet?',this.ChannelNumber));
            elseif strcmp(querystring, 'autorange')
                ret = this.Parent.query(sprintf('SOURce%d:VOLTage:RANGe:AUTO?',this.ChannelNumber));
            end
        end      % - get the Amplitude params
    end  % - Get parameters for built-in waveforms
    methods
        function applyDCVoltage(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:DC DEF,DEF,%s', this.ChannelNumber, offset));
        end     % - apply DC offset Voltage
        function applyNoise(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:NOISe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end         % - apply Noise
        function applyPRBS(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:PRBS %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end          % - apply PRBS
        function applyPulse(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:PULSe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end         % - apply Pulse
        function applyRamp(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:RAMP %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end          % - apply Ramp
        function applySineWave(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:SINusoid %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end      % - apply Sine wave
        function applySquareWave(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:SQUare %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end    % - apply Square wave
        function applyTriangleWave(this, varargin)
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addOptional(p, 'frequency', 'DEF', @isnumeric);
            addOptional(p, 'amplitude', 'DEF', @isnumeric);
            addOptional(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:TRIangle %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end  % - apply Triangle wave
    end  % - Apply built-in functions
    methods
        %% General options
        function set.SamplingRate(this, newval)
            if ~ischar(newval)
                if newval > 30
                    error('Sample rate larger 30 MHz not supported!')
                end
                newval = num2str(newval);
            end
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:SRATe %s',this.ChannelNumber, newval));
        end   % - set the sample rate
        function set.Impedance(this, newval)
            if newval == 10000
                this.Parent.send(sprintf('OUTP%d:LOAD INF',this.ChannelNumber))
            elseif newval == 50
                this.Parent.send(sprintf('OUTP%d:LOAD 50',this.ChannelNumber));
            else
                error('Impedance can only be 50 Ohm or 10000 Ohm!')
            end
        end % - set the impedance
        function set.WaveformList(this, newval)
            if length(newval)<8
                error('At least eight data!')
            end
            if length(newval) > 1e6
                error('At most one million data!')
            end
            if (min(newval) < -10 ) || (max(newval) > 10)
                error('Permitted interval [-10,10] V exceeded!')
            end
            this.WaveformList = newval;
        end % - set the Waveform List
        function set.RescaledList(this, newval)
            this.RescaledList = ((newval-min(newval))./(max(newval)-min(newval)) - 0.5) * 2;
        end
        %% - Triggering options
        function set.TriggerCount(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Trigger count must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('TRIGger%d:COUNt %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('TRIGger%d:COUNt %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.TriggerCount(this)
            ret=this.Parent.query(sprintf('TRIGger%d:COUNt?', this.ChannelNumber));
        end
        function set.TriggerDelay(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'TriggerDelay [s] must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('TRIGger%d:DELay %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('TRIGger%d:DELay %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.TriggerDelay(this)
            ret=this.Parent.query(sprintf('TRIGger%d:DELay?', this.ChannelNumber));
        end
        function set.TriggerLevel(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Trigger Level must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('TRIGger%d:LEVel %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('TRIGger%d:LEVel %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.TriggerLevel(this)
            ret=this.Parent.query(sprintf('TRIGger%d:LEVel?', this.ChannelNumber));
        end
        function set.TriggerSlope(this,newval)
            assert(any(strcmpi(newval,{'NEG','POS'})),...
                'Trigger Slope must be "NEG" or "POS"');
            this.Parent.send(sprintf('TRIGger%d:SLOPe %s', this.ChannelNumber, newval));
        end
        function ret=get.TriggerSlope(this)
            ret=this.Parent.query(sprintf('TRIGger%d:SLOPe?', this.ChannelNumber));
            ret=ret(1:end-1);
        end
        function set.TriggerSource(this,newval)
            Sources={'IMM','BUS','EXT','INT'};
            assert(any(strcmpi(newval,Sources)),...
                ['InputError: TriggerSource must be' Sources])
            this.Parent.send(sprintf('TRIGger%d:SOURce %s', this.ChannelNumber, newval));
        end
        function ret=get.TriggerSource(this)
            ret=this.Parent.query(sprintf('TRIGger%d:SOURce?', this.ChannelNumber));
            ret=ret(1:end-1);
        end
        %% - Burst options
        function set.BurstGatePolarity(this,newval)
            assert(any(strcmpi(newval,{'NORM','INV'})), ...
                'Burst gate polarity must be specified as either "NORMal" or "INVerted"');
            this.Parent.send(sprintf('SOURce%d:BURSt:GATE:POLarity %s', this.ChannelNumber, newval));
        end
        function ret=get.BurstGatePolarity(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:GATE:POLarity?', this.ChannelNumber));
        end
        function set.BurstInternalPeriod(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Burst internal period must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:INTernal:PERiod %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:INTernal:PERiod %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstInternalPeriod(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:INTernal:PERiod?', this.ChannelNumber));
        end
        function set.BurstMode(this,newval)
            assert(any(strcmpi(newval, {'TRIG','GAT'})), ...
                'Burst mode must be specified as either "TRIGgered","GATed"');
            this.Parent.send(sprintf('SOURce%d:BURSt:MODE %s', this.ChannelNumber, newval));
        end
        function ret=get.BurstMode(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:MODE?', this.ChannelNumber));
        end
        function set.BurstCycles(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0|| any(strcmpi(newval,{'INF','MIN','MAX'})),...
                'Burst cycles must be positive scalar values or be specified as "INF", "MIN", or "MAX"');
            if ~any(strcmpi(newval,{'INF','MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:NCYCles %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:NCYCles %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstCycles(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:NCYCles?', this.ChannelNumber));
            ret=ret(1:end-1);
        end
        function set.BurstPhase(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0|| any(strcmpi(newval,{'MIN','MAX'})), ...
                'Burst phase must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:PHASe %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:PHASe %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstPhase(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:PHASe?',this.ChannelNumber));
            ret=ret(1:end-1);
        end
        function set.BurstState(this,newval)
            assert(any(strcmpi(newval, {'ON','OFF'})), ...
                'Burst mode must be specified as either "ON","OFF"');
            this.Parent.send(sprintf('SOURce%d:BURSt:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.BurstState(this)
            ret=this.Parent.query(sprintf('SOURce%d:BURSt:STATe?',this.ChannelNumber));
            ret=ret(1:end-1);
        end
        %% - Frequency options
        function set.FrequencyCenter(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:CENTer %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:CENTer %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyCenter(this)
            ret=this.Parent.query(sprintf('SOURce%d:FREQuency:CENTer?', this.ChannelNumber));
        end
        function set.FrequencyMode(this, newval)
            assert(any(strcmpi(newval,{'CW','LIST', 'SWE', 'FIX'})), ...
                'Frequency mode must be specified as one of "CW", "LIST", "SWEep" or "FIX"');
            this.Parent.send(sprintf('SOURce%d:FREQuency::MODE %s', this.ChannelNumber, newval));
        end
        function ret=get.FrequencyMode(this)
            ret=this.Parent.query(sprintf('SOURce%d:FREQuency:MODE?', this.ChannelNumber));
        end
        function set.FrequencySpan(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:SPAN %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:SPAN %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencySpan(this)
            ret=this.Parent.query(sprintf('SOURce%d:FREQuency:SPAN?', this.ChannelNumber));
        end
        function set.FrequencyStart(this, newval)
           assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:STARt %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:STARt %s', this.ChannelNumber, newval));
            end 
        end
        function ret=get.FrequencyStart(this)
            ret=this.Parent.query(sprintf('SOURce%d:FREQuency:STARt?', this.ChannelNumber));
        end
        function set.FrequencyStop(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:STOP %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:STOPs %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyStop(this)
            ret=this.Parent.query(sprintf('SOURce%d:FREQuency:STOP?', this.ChannelNumber));
        end
        function set.FrequencyDwellTime(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:LIST:DWELl %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:LIST:DWELl %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyDwellTime(this)
            ret=this.Parent.query(sprintf('SOURce%d:LIST:DWELl?', this.ChannelNumber));
        end
        function set.FrequencyList(this, newlist)
            d=sprintf(' %gE+06',newlist(1));
            d= [d sprintf(', %gE+06',newlist(2:end))];
            this.Parent.send(sprintf(['SOURce%d:LIST:FREQ' d],this.ChannelNumber));
        end % - set the Frequency List
        function ret = getFrequencyList(this)
            ret = this.Parent.query(sprintf('SOURce%d:LIST:FREQuency:POINts?', this.ChannelNumber));
        end
        %% Output options
        function set.OutputState(this, newval)
            assert(any(strcmpi(newval, {'ON','OFF'})), ...
                'Output state must be specified as either "ON","OFF"');
            this.Parent.send(sprintf('OUTPut%d %s',this.ChannelNumber, newval));
        end % - set the output state
        function ret = get.OutputState(this)
            ret = this.Parent.query(sprintf('OUTPut%d?',this.ChannelNumber));
        end % - get the output state
        function set.OutputLoad(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>0|| any(strcmpi(newval,{'INF','MIN','MAX'})),...
                'Output load must be positive scalar values or be specified as "INF", "MIN", or "MAX"');
            if ~any(strcmpi(newval,{'INF','MIN','MAX'}))
                this.Parent.send(sprintf('OUTPut%d:LOAD %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('OUTPut%d:LOAD %s',this.ChannelNumber, newval));
            end
            
        end % - set the output load
        function ret = get.OutputLoad(this)
            ret = this.Parent.query(sprintf('OUTPut%d:LOAD?',this.ChannelNumber));
        end % - get the output load
        function set.OutputMode(this, newval)
            assert(any(strcmpi(newval,{'NORM','GAT'})),...
                'Output load must be specified as "NORMal" or "GATed"');
            this.Parent.send(sprintf('OUTPut%d:MODE %s',this.ChannelNumber, newval));
        end % - set the output mode
        function ret = get.OutputMode(this)
            ret = this.Parent.query(sprintf('OUTPut%d:MODE?',this.ChannelNumber));
        end % - get the output mode
        function set.OutputPolarity(this, newval)
            assert(any(strcmpi(newval,{'NORM','INV'})),...
                'Output mode must be specified as "NORMal" or "INVerted"');
            this.Parent.send(sprintf('OUTPut%d:POLarity %s',this.ChannelNumber, newval));
        end % - set the output polarity
        function ret = get.OutputPolarity(this)
            ret = this.Parent.query(sprintf('OUTPut%d:POLarity?',this.ChannelNumber));
        end % - get the output polarity
        function set.OutputSync(this, newval)
            assert(any(strcmpi(newval, {'ON','OFF'})), ...
                'Output sync must be specified as either "ON", "OFF"');
            this.Parent.send(sprintf('OUTPut%d:SYNC %s',this.ChannelNumber, newval));
        end % - set the output sync
        function ret = get.OutputSync(this)
            ret = this.Parent.query(sprintf('OUTPut%d:SYNC?',this.ChannelNumber));
        end % - get the output sync
        function set.OutputSyncMode(this, newval)
            assert(any(strcmpi(newval,{'NORM','CARR','MARK'})),...
                'Output sync mode must be specified as "NORMal", "CARRier", or "MARKer"');
            this.Parent.send(sprintf('OUTPut%d:SYNC:MODE %s',this.ChannelNumber, newval));
        end % - set the output sync mode
        function ret = get.OutputSyncMode(this)
            ret = this.Parent.query(sprintf('OUTPut%d:SYNC:MODE?',this.ChannelNumber));
        end % - get the output sync mode
        function set.OutputSyncPolarity(this, newval)
            assert(any(strcmpi(newval,{'NORM','INV'})),...
                'Output sync polarity must be specified as "NORMal" or "INVerted"');
            this.Parent.send(sprintf('OUTPut%d:SYNC:POLarity %s',this.ChannelNumber, newval));
        end % - set the output sync polarity
        function ret = get.OutputSyncPolarity(this)
            ret = this.Parent.query(sprintf('OUTPut%d:SYNC:POLarity?',this.ChannelNumber));
        end % - get the output sync polarity
        function set.OutputSyncSource(this, newval)
            assert(any(strcmpi(newval,{'CH1','CH2'})),...
                'Output sync source must be specified as "CH1" or "CH2"');
            this.Parent.send(sprintf('OUTPut%d:SYNC:SOURce %s',this.ChannelNumber, newval));
        end % - set the output sync source
        function ret = get.OutputSyncSource(this)
            ret = this.Parent.query(sprintf('OUTPut%d:SYNC:SOURce?',this.ChannelNumber));
        end % - get the output sync source
        function set.OutputTriggerState(this, newval)
            assert(any(strcmpi(newval,{'ON','OFF'})),...
                'Output trigger state must be specified as "ON" or "OFF"');
            this.Parent.send(sprintf('OUTPut%d:TRIGger %s',this.ChannelNumber, newval));
        end % - set the output trigger source
        function ret = get.OutputTriggerState(this)
            ret = this.Parent.query(sprintf('OUTPut%d:TRIGger?',this.ChannelNumber));
        end % - get the output trigger source
        function set.OutputTriggerSlope(this, newval)
            assert(any(strcmpi(newval,{'POS','NEG'})),...
                'Output trigger slope must be specified as "POSitive" or "NEGative"');
            this.Parent.send(sprintf('OUTPut%d:TRIGger:SLOPe %s',this.ChannelNumber, newval));
        end % - set the output trigger source
        function ret = get.OutputTriggerSlope(this)
            ret = this.Parent.query(sprintf('OUTPut%d:TRIGger.SLOPe?',this.ChannelNumber));
        end % - get the output trigger source
        function set.OutputTriggerSource(this, newval)
            assert(any(strcmpi(newval,{'CH1','CH2'})),...
                'Output trigger source must be specified as "CH1" or "CH2"');
            this.Parent.send(sprintf('OUTPut%d:TRIGger:SOURce %s',this.ChannelNumber, newval));
        end % - set the output trigger source
        function ret = get.OutputTriggerSource(this)
            ret = this.Parent.query(sprintf('OUTPut%d:TRIGger:SOURce?',this.ChannelNumber));
        end % - get the output trigger source
    end  % - setters & getters
end