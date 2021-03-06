classdef K33522BChannel < handle
    
    properties
        % Object of K33522BDevice class
        Parent
        % Channel currently being addressed
        ChannelNumber
    end % - Basic containers
    
    properties (Dependent)
        % Slope of trigger (Pos)|Neg
        TriggerSlope
        % Source of Trigger ={'IMM','BUS','EXT','INT'};
        TriggerSource
        % NumberOfTriggers accepted (will do measurement this many times)
        TriggerCount
        % Sets timer used when TRIGger[1|2]:SOURce is TIMer.
        TriggerTimer
        % Sets trigger delay, (time from assertion of trigger to occurrence of triggered event)
        TriggerDelay
    end % - Trigger options
    
    properties (Dependent)
        % Enable or disable the burst mode
        BurstState
        % Select the triggered burst mode (called "N Cycle" on the front panel) or external gated burst mode
        BurstMode
        % Set the burst count (number of cycles per burst) to any value between 1 and 100,000,000 cycles (or infinite)
        BurstCycles
        % Set the starting phase of the burst from -360 to +360 degrees
        BurstPhase
        % Selects true-high (NORMal) or true-low (INVerted) logic levels on the rear-panel Ext Trig connector for an externally gated burst
        BurstGatePolarity
        % Set the burst period (the interval at which internally-triggered bursts are generated) to any value from 1 ?s to 8000 seconds
        BurstInternalPeriod
    end % - Burst options
    
    properties (Dependent)
        % Specifies whether the trigger system for one or both channels (ALL) always returns to the "wait-for-trigger"
        % state (ON) or remains in the "idle" state (OFF), ignoring triggers until INITiate:IMMediate is issued.
        ContinuousTriggerState
        % Sets the byte order used in binary data point transfers in the block mode
        FormatBorder
    end % - General options
    
    properties (Dependent)
        % Sets output amplitude
        Amplitude
        % Sets DC offset voltage
        Offset
        % Set the waveform's high and low voltage levels
        HighLevel
        % Set the waveform's high and low voltage levels
        LowLevel
        % Sets the higher limit for output voltage
        UpperLimit
        % Sets the lower limit for output voltage
        LowerLimit
        % Enables or disables output amplitude voltage limits
        LimitState
        % Disables or enables voltage autoranging for all functions. Selecting ONCE performs an immediate autorange
        % and then turns autoranging OFF
        % 
        % - In the default mode, autoranging is enabled and the instrument automatically selects the optimal settings
        %   for the output waveform generator and attenuator.
        % - With autoranging disabled (OFF), the instrument uses the instrument's current gain and attenuator settings.
        AutoRange
        % Enables or disables the maintaining of the same amplitude, offset, range, load, and units on both channels of a two-channel instrument. 
        % The command applies to both channels; the SOURce keyword is ignored.
        VoltageCouplingState
        %Selects the units for output amplitude
        VoltageUnits
    end % - Voltage options
    
    properties (Dependent)
        % Sets the output frequency. This command is paired with FUNCtion:PULSe:PERiod; whichever one is
        % executed last overrides the other.
        Frequency
        % Sets the center frequency. Used with frequency span for a frequency sweep.
        FrequencyCenter
        % Allows user to specify a frequency mode to use, including a sweep, frequency list, or fixed frequency.
        FrequencyMode
        % Sets frequency span (used in conjunction with the center frequency) for a frequency sweep.
        FrequencySpan
        % Sets the start frequency for a frequency sweep.
        FrequencyStart
        % Sets the stop frequencies for a frequency sweep.
        FrequencyStop
        % Sets amount of time each frequency in list is generated
        FrequencyDwellTime
        % Specify up to 128 frequencies as a list (frequencies may also be read from or saved to a file using MMEMory:LOAD:LIST[1|2] and MMEMory:STORe:LIST.
        FrequencyList
        % Enables/disables frequency coupling between channels in a two-channel instrument.
        FrequencyCouplingState
        % Sets the type of frequency coupling between frequency coupled channels.
        FrequencyCouplingMode
        % OFFSet specifies a constant frequency offset between channels.
        FrequencyCouplingOffset
        % RATio specifies a constant ratio between the channels' frequencies.
        FrequencyCouplingRatio
        % Sets number of seconds the sweep holds (pauses) at the stop frequency before returning to the start frequency.
        SweepHoldTime
        % Sets number of seconds the sweep takes to return from stop frequency to start frequency.
        SweepReturnTime
        % Selects linear or logarithmic spacing for sweep.
        SweepSpacing
        % Enables or disables the sweep.
        SweepState
        % Sets time (seconds) to sweep from start frequency to stop frequency.
        SweepTime
    end % - Frequency(-sweep) options
    
    properties (Dependent)
        % Enables or disables the front panel output connector.
        OutputState
        % Sets expected output termination. Should equal the load impedance attached to the output.
        OutputLoad
        % Enables (GATed) or disables (NORMal) gating of the output waveform signal on and off using the trigger input.
        OutputMode
        % Inverts waveform relative to the offset voltage.
        OutputPolarity
        % Disables or enables the front panel Sync connector.
        OutputSync
        % Specifies normal Sync behavior (NORMal), forces Sync to follow the carrier waveform (CARRier), or indicates marker position (MARKer).
        OutputSyncMode
        % Sets the desired output polarity of the Sync output to trigger external equipment that may require falling or rising edge triggers.
        OutputSyncPolarity
        % Sets the source for the Sync output connector.
        OutputSyncSource
        % Disables or enables the "trigger out" signal for sweep and burst modes.
        OutputTriggerState
        % Selects whether the instrument uses the rising edge or falling edge for the "trigger out" signal.
        OutputTriggerSlope
        % Selects the source channel used by trigger output on a two-channel instrument. The source channel
        % determines what output signal to generate on the trigger out connector.
        OutputTriggerSource
    end % - Output options
    
    properties (Dependent)
        % Selects the output function.
        FunctionType
        % Selects an arbitrary waveform (.arb/.barb) or sequence (.seq) that has previously been loaded into volatile
        % memory for the channel specified with MMEMory:LOAD:DATA[1|2] or DATA:ARBitrary. Several waveforms
        %can be in volatile memory simultaneously.
        ArbitraryFunction
        % Specifies the method for advancing to the next arbitrary waveform data point for the specified channel.
        ArbitraryFunctionAdvanceMethod
        % Specifies the filter setting for an arbitrary waveform
        ArbitraryFunctionFilter
        % Sets the frequency for the arbitrary waveform.
        ArbitraryFunctionFrequency
        % Sets the period for the arbitrary waveform.
        ArbitraryFunctionPeriod
        % Returns the number of points in the currently selected arbitrary waveform.
        ArbitraryFunctionNumberOfPoints
        % Sets peak to peak voltage.
        ArbitraryFunctionPeakToPeak
        % Sets the sample rate for the arbitrary waveform.
        ArbitraryFunctionSamplingRate
        % Sets bandwidth of noise function.
        NoiseFunctionBandwidth
        % Sets the pseudo-random binary sequence (PRBS) bit rate.
        PBRSFunctionBitRate
        % Sets the pseudo-random binary sequence (PRBS) type. Setting the sequence type sets the length and feedback values as shown below.
        PBRSFunctionSequenceType
        % Sets PRBS transition edge time on both edges of a PRBS transition.
        PBRSFunctionTransition
        % Sets pulse duty cycle.
        PulseFunctionDutyCycle
        % Sets the pulse waveform parameter (either pulse width or duty cycle) to be held constant as other para-meters are varied.
        PulseFunctionHoldTime
        % Sets the period for pulse waveforms. This command is paired with the FREQuency command; the one
        % executed last overrides the other, as frequency and period specify the same parameter.
        PulseFunctionPeriod
        % Sets the pulse edge time on the leading edge of a pulse.
        PulseFunctionLeadingEdge
        % Sets the pulse edge time on the trailing edge of a pulse.
        PulseFunctionTrailingEdge
        % Sets the pulse edge time on both edges of a pulse.
        PulseFunctionBothEdges
        % Sets pulse width.
        PulseFunctionWidth
        % Sets the symmetry percentage for ramp waves.
        RampFunctionSymmetry
        % Sets duty cycle percentage for square wave.
        SquareFunctionDutyCycle
        
    end % - Function options
    
    properties (Dependent)
        % Returns the arithmetic mean of all data points for the specified arbitrary waveform INTERNAL or USB memory, or loaded into waveform memory.
        DataAverage
        % Returns the crest factor of all data points for the specified arbitrary waveform segment in INTERNAL or USB memory, or loaded into waveform memory.
        DataCrestFactor
        % Returns the number of points in the specified arbitrary waveform segment in INTERNAL or USB memory or loaded into waveform memory.
        DataPoints
        % Calculates the peak-to-peak value of all data points for the specified arbitrary waveform segment in INTERNAL or USB memory, or loaded into waveform memory.
        DataPeakToPeak
        % Returns the contents of volatile waveform memory, including arbitrary waveforms and sequences.
        VolatileMemoryCatalog
        % Returns number of points available (free) in volatile memory. Each arbitrary waveform loaded into volatile
        % memory consumes space allocated in 128-point blocks, so a waveform of 8 to 128 points consumes one
        % such block, a waveform of 129 to 256 points consumes two blocks, and so on.
        FreeVolatileMemory
    end % - Data options
    
    properties (Dependent)
        % RATE Subsystem
        % The RATE subsystem allows you to couple the outputs' sample rates
        % on a two-channel instrument by specifying
        % the following items:
        
       % Enables or disables sample rate coupling between channels, or allows one-time copying of one channel's
       % sample rate into the other channel.
       RateCouplingState
       % Sets type of sample rate coupling to either a constant sample rate offset (OFFSet) or a constant ratio
       %(RATio) between the channels' sample rates
       RateCouplingMode
       % Sets sample rate offset when a two-channel instrument is in sample rate coupled mode OFFSet.
       RateCouplingOffset
       % Sets offset ratio between channel sample rates when a two-channel instrument is in sample rate coupled
       % mode RATio.
       RateCouplingRatio
    end % - Rate coupling options
    
    properties (Dependent)
        % 1/ArbitraryFunctionSamplingRate
        ArbitraryFunctionSamplingTime
    end % - custom
    methods
        function this =  K33522BChannel(Parent, Channel) %Constructor and initialization
            % - input handling
            this.Parent=Parent;
            this.ChannelNumber = Channel;
            disp('K33522BChannel object constructed.');
        end
    end  % - Lifecycle functions
    methods
        % Changes state of triggering system for both channels (ALL) from "idle" to "wait-for-trigger" for the number
        % of triggers specified by Trigger Count
        function initiateImmediateTrigger(this)
            this.Parent.send(sprintf('INITiate%d:IMMediate',this.ChannelNumber));
        end
    end  % - Basic
    methods
        function sync(this)
            % Causes two independent arbitrary waveforms to synchronize to first point 
            % of each waveform (two-channel instruments only).
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:SYNChronize',this.ChannelNumber));
        end 
        function upload(this, WaveformData, varargin)
            % Custom method to upload user-defined arbitrary waveform using binblockwrite.
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addRequired(p, 'WaveformData', @ismatrix);
            addParameter(p, 'SamplingRate', this.ArbitraryFunctionSamplingRate, (@(x) isnumeric(x) || ischar(x)));
            addParameter(p, 'Impedance', inf, @(x) (isnumeric(x) && (x==50 || x == inf)) || any(strcmpi(x,{'MIN','MAX','INF'})) );
            addParameter(p, 'TriggerSource', 'EXT', @ischar);
            addParameter(p, 'TriggerDelay', 'MIN', @(x) isnumeric(x) || any(strcmpi(x,{'MIN','MAX'})) );
            addParameter(p, 'BurstMode', 'TRIG', @(x) any(strcmpi(x,{'Trig','Bus','IMM'})));
            addParameter(p, 'BurstPhase', 'MIN', @(x) isnumeric(x) || any(strcmpi(x,{'MIN','MAX'})) );
            addParameter(p, 'BurstCycles', this.BurstCycles, (@(x) isnumeric(x) || ischar(x)));
            addParameter(p, 'BurstState', 'ON', @(x) any(strcmpi(x,{'ON','OFF'})));
            addParameter(p,'Filter','Norm',@(x) any(strcmpi(x,{'Norm','Step','OFF'})))
            parse(p, this, WaveformData, varargin{:});
            WaveformData = p.Results.WaveformData;
            if length(WaveformData)<8
                error('Need at least eight data points!')
            end
            if length(WaveformData) > 1e6
                error('At most one million data points can be specified!')
            end
            if (min(WaveformData) < -10 ) || (max(WaveformData) > 10)
                error('Permitted interval [-10,10] V exceeded!')
            end
            % transmit the data using SCPI commands
            this.clearVolatilememory;
            % set to LSB first
            this.FormatBorder = 'SWAP';
            RescaledWaveformList = ((WaveformData-min(WaveformData))./(max(WaveformData)-min(WaveformData)) - 0.5) * 2; % data normalized to [-1,+1]
            % upload a binary block in Agilent format, binblockwrite is an in-built function in matlab
            binblockwrite(this.Parent.vi, RescaledWaveformList, 'float32', sprintf('SOUR%d:DATA:ARB ARB_seq, ', this.ChannelNumber));
            % wait for upload to be processed
            this.Parent.wait;
            
            
            this.ArbitraryFunction = 'ARB_seq';   %select ARB_seq as current arbitrary waveform
            this.FunctionType = 'ARB'; % set generator to arbitrary waveform
            this.ArbitraryFunctionAdvanceMethod = 'SRAT';
            this.ArbitraryFunctionSamplingRate =  p.Results.SamplingRate;
            this.OutputLoad =  p.Results.Impedance;
            
            % set signal parameters
            this.Amplitude = max(WaveformData)-min(WaveformData);
            this.Offset = 0.5*(max(WaveformData)+min(WaveformData));
            % set triggering
            this.BurstMode = p.Results.BurstMode; 
            this.BurstCycles = p.Results.BurstCycles;
            this.BurstPhase = p.Results.BurstPhase;
            this.TriggerDelay = p.Results.TriggerDelay;
            this.TriggerSource = p.Results.TriggerSource;
            this.BurstState = p.Results.BurstState;
            
            % - turn 
            this.OutputState = 'ON';
            this.Parent.getError();
        end  
        function preview(this, newval)
            % Preview the arbitrary waveform.
            clf;
            t = (1:length(newval))/this.ArbitraryFunctionSamplingRate*1E6;
            stairs(t, newval);
            title(sprintf('Preview of data for channel #%d', this.ChannelNumber));
            xlabel('Time [us]');
            ylabel('Voltage [V]');
        end 
    end  % - Apply Arbitrary waveforms
    methods
        function applyDCVoltage(this, varargin)
            % Outputs a DC voltage.
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:DC %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end     
        function applyNoise(this, varargin)
            % Outputs gaussian noise with the specified amplitude and DC offset.
            % 
            % If you specify a frequency, it has no effect on the noise output, but the value is remembered when you
            % change to a different function.
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:NOISe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end         
        function applyPRBS(this, varargin)
            % Outputs a pseudo-random binary sequence with the specified bit 
            % rate, amplitude and DC offset.
            % The default waveform is a PN7 Maximum Length Shift Register generator.
            
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:PRBS %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end          
        function applyPulse(this, varargin)
            % Outputs a pulse wave with the specified frequency, amplitude, 
            % and DC offset. In addition, APPLy performs the following operations:
            %
            % - Preserves either the current pulse width setting (FUNCtion:PULSe:WIDTh) or the current 
            %   pulse duty cycle setting (FUNCtion:PULSe:DCYCle).
            % - Preserves the current transition time setting (FUNCtion:PULSe:TRANsition[:BOTH]).
            % - May cause instrument to override the pulse width or edge time setting to comply 
            %   with the specified frequency or period (FUNCtion:PULSe:PERiod).
            
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:PULSe %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end         
        function applyRamp(this, varargin)
            % Outputs a ramp wave or triangle wave with the specified frequency, amplitude, and DC offset. 
            % In addition, APPLy performs the following operations:
            % 
            % - APPLy:RAMP overrides the current symmetry setting (FUNCtion:RAMP:SYMMetry), 
            %   and sets 100% symmetry for the ramp waveform.
            % - APPLy:TRIangle is simply a special case of APPLy:RAMP. It 
            %   is equivalent to a ramp waveform with 50% symmetry.
            
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:RAMP %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end          
        function applyTriangleWave(this, varargin)
            % Outputs a ramp wave or triangle wave with the specified frequency, 
            % amplitude, and DC offset. In addition,
            % 
            % APPLy performs the following operations:
            % - APPLy:RAMP overrides the current symmetry setting 
            %   (FUNCtion:RAMP:SYMMetry), and sets 100% symmetry for the 
            %   ramp waveform.
            % - APPLy:TRIangle is simply a special case of APPLy:RAMP. It 
            %   is equivalent to a ramp waveform with 50% symmetry.
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:TRIangle %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end  
        function applySineWave(this, varargin)
            % Outputs a sine wave with the specified frequency, amplitude, 
            % and DC offset.
            
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:SINusoid %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end      
        function applySquareWave(this, varargin)
            % Outputs a square wave with the specified frequency, amplitude, 
            % and DC offset. In addition, APPLy:SQUare overrides the current 
            % duty cycle setting (FUNCtion:SQUare:DCYCle), and sets a 50% 
            % duty cycle for the square wave.
            
            p = inputParser;
            addRequired(p, 'Child', @isobject);
            addParameter(p, 'frequency', 'DEF', @isnumeric);
            addParameter(p, 'amplitude', 'DEF', @isnumeric);
            addParameter(p, 'offset', 'DEF', @isnumeric);
            parse(p, this, varargin{:});
            frequency = num2str(p.Results.frequency);
            amplitude = num2str(p.Results.amplitude);
            offset = num2str(p.Results.offset);
            this.Parent.send(sprintf('SOURce%d:APPLy:SQUare %s,%s,%s', this.ChannelNumber, frequency, amplitude, offset));
        end    
    end  % - Apply built-in waveforms
    methods
        function loadArbitraryData(this, newval,Format)
            % Downloads integer values representing DAC codes (DATA:ARBitrary[1|2]:DAC) or floating point values
            % (DATA:ARBitrary[1|2]) into waveform volatile memory as either a list of comma separated values or binary
            % block of data. The DAC codes go from -32,768 to +32,767 on both the 33500 Series and 33600 Series.
            %
            % input             newval     char-arry containing the data
            %      (optional)   Format     ('float')|'DAC' 
            if nargin ==2
                Format ='float';
            end
            assert(any(strcmpi(Format,{'float','DAC'})),...
                'input error:  Format must be "float" or "DAC"')
            switch Format
                case 'float'
                    this.Parent.send(sprintf('SOURce%d:DATA:ARBitrary %s', this.ChannelNumber, newval)); 
                case 'DAC'
                    this.Parent.send(sprintf('SOURce%d:DATA:ARBitrary:DAC %s', this.ChannelNumber, newval)); 
            end
        end
        function clearVolatilememory(this)
            % Clears waveform memory for the specified channel and reloads the default waveform.
           this.Parent.send(sprintf('SOURce%d:DATA:VOLatile:CLEar', this.ChannelNumber)); 
        end 
        function createDataSequence(this, newval)
            % Defines a sequence of waveforms already loaded into waveform memory via MMEMory:LOAD:DATA[1|2]
            % or DATA:ARBitrary. The MMEMory:LOAD:DATA[1|2] command can also load a sequence file that auto-
            % matically loads the associated arbitrary waveforms and includes the amplitude, offset, sample rate, and filter setup.
            this.Parent.send(sprintf('SOURce%d:DATA:SEQuence %s', this.ChannelNumber, newval)); 
        end
    end  % - Data: Manage user-defined arbitrary waveforms
    methods
        function loadList(this, filename)
            % Loads a frequency list file (.lst).
            assert(ischar(filename), 'Input Error: Provide filename of list as a character string!');
            this.Parent.send(sprintf('MMEMory:LOAD:LIST%d "%s"', this.ChannelNumber, filename));
        end
        function storeList(this, filename)
            % Stores a frequency list file (.lst).
            assert(ischar(filename), 'Input Error: Provide filename of list as a character string!');
            this.Parent.send(sprintf('MMEMory:STORe:LIST%d "%s"', this.ChannelNumber, filename));
        end
        function loadData(this, filename)
            % Loads the specified arb segment(.arb/.barb) or arb sequence (.seq) file in INTERNAL or USB memory into
            % volatile memory for the specified channel.
            assert(ischar(filename), 'Input Error: Provide filename of data as a character string!');
            this.Parent.send(sprintf('MMEMory:LOAD:DATA%d "%s"', this.ChannelNumber, filename));
        end
        function storeData(this, filename)
            % Stores the specified arb segment(.arb/.barb) or arb sequence (.seq) data in the channel specified volatile
            % memory (default, channel 1) in INTERNAL or USB memory.
            assert(ischar(filename), 'Input Error: Provide filename of data as a character string!');
            this.Parent.send(sprintf('MMEMory:STORe:DATA%d "%s"', this.ChannelNumber, filename));
        end
    end  % - MMemory:  Load/Store channel-specific data/list from on-board memory
    methods
        %% - General options
        function set.ContinuousTriggerState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Continuous trigger state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            endthis.Parent.send(sprintf('INITiate%d:CONTinuous %s',this.ChannelNumber, newval));
        end
        function ret = get.ContinuousTriggerState(this)
            ret = this.Parent.queryDouble(sprintf('INITiate%d:CONTinuous?',this.ChannelNumber));
        end
        function set.FormatBorder(this, newval)
            assert(any(strcmpi(newval,{'NORM','SWAP'})),...
                'Format border must be specified as "NORMal" or "SWAPped"');
            this.Parent.send(sprintf('FORMat:BORDer %s', newval));
        end
        function ret = get.FormatBorder(this)
            ret = this.Parent.query('FORMat:BORDer?');
        end
        %% - Voltage options
        function set.Amplitude(this, newval)
            assert(isnumeric(newval)&& newval>=0 || any(strcmpi(newval,{'MIN','MAX'})),...
                'Amplitude must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage %s',this.ChannelNumber, newval));
            end
        end
        function ret = get.Amplitude(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage?',this.ChannelNumber));
        end
        function set.Offset(this, newval)
            assert(isnumeric(newval)&& newval>=0 || any(strcmpi(newval,{'MIN','MAX'})),...
                'Offset must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage:OFFSet %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage:OFFSet %s',this.ChannelNumber, newval));
            end
            
        end
        function ret = get.Offset(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:OFFSet?',this.ChannelNumber));
        end
        function set.HighLevel(this, newval)
            assert(isnumeric(newval) || any(strcmpi(newval,{'MIN','MAX'})),...
                'High level must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage:HIGH %s',this.ChannelNumber, newval));
            end
        end
        function ret = get.HighLevel(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:HIGH?',this.ChannelNumber));
        end
        function set.LowLevel(this, newval)
            assert(isnumeric(newval) || any(strcmpi(newval,{'MIN','MAX'})),...
                'Low level must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage:LOW %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage:LOW %s',this.ChannelNumber, newval));
            end
            
        end
        function ret = get.LowLevel(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:LOW?',this.ChannelNumber));
        end
        function set.UpperLimit(this, newval)
            assert(isnumeric(newval) || any(strcmpi(newval,{'MIN','MAX'})),...
                'Upper limit must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage:LIMit:HIGH %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage:LIMit:HIGH %s',this.ChannelNumber, newval));
            end
        end
        function ret = get.UpperLimit(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:LIMit:HIGH?',this.ChannelNumber));
        end
        function set.LowerLimit(this, newval)
            assert(isnumeric(newval) || any(strcmpi(newval,{'MIN','MAX'})),...
                'Lower limit must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:VOLTage:LIMit:LOW %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:VOLTage:LIMit:LOW %s',this.ChannelNumber, newval));
            end
            
        end
        function ret = get.LowerLimit(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:LIMit:LOW?',this.ChannelNumber));
        end
        function set.LimitState(this,newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Limit state must be specified as either 0, 1, "ON" or "OFF"');
            if newval ==1
                newval = 'ON';
            elseif newval ==0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:VOLTage:LIMit:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.LimitState(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:LIMit:STATe?',this.ChannelNumber));
        end
        function set.AutoRange(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Voltage Autoranging must be specified as either 0, 1, "ON" or "OFF"');
            if newval ==1
                newval = 'ON';
            elseif newval ==0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:VOLTage:RANGe:AUTO %s',this.ChannelNumber, newval));
        end
        function ret = get.AutoRange(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:RANGe:AUTO?',this.ChannelNumber));
        end
        function set.VoltageCouplingState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Voltage coupling state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:VOLTage:COUPle:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.VoltageCouplingState(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:VOLTage:COUPle:STATe?',this.ChannelNumber));
        end
        function set.VoltageUnits(this, newval)
            assert(any(strcmpi(newval,{'VPP','VRMS','DBM'})),...
                'Voltage units must be specified as "VPP", "VRMS" or "DBM"');
            this.Parent.send(sprintf('SOURce%d:VOLTage:UNIT %s', this.ChannelNumber, newval));
        end
        function ret = get.VoltageUnits(this)
            ret = this.Parent.query(sprintf('SOURce%d:VOLTage:UNIT?', this.ChannelNumber));
        end
        %% - Triggering options
        function set.TriggerCount(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Trigger count must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('TRIGger%d:COUNt %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('TRIGger%d:COUNt %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.TriggerCount(this)
            ret=this.Parent.queryDouble(sprintf('TRIGger%d:COUNt?', this.ChannelNumber));
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
            ret=this.Parent.queryDouble(sprintf('TRIGger%d:DELay?', this.ChannelNumber));
        end
        function set.TriggerSlope(this,newval)
            assert(any(strcmpi(newval,{'NEG','POS'})),...
                'Trigger Slope must be "NEG" or "POS"');
            this.Parent.send(sprintf('TRIGger%d:SLOPe %s', this.ChannelNumber, newval));
        end
        function ret=get.TriggerSlope(this)
            ret=this.Parent.query(sprintf('TRIGger%d:SLOPe?', this.ChannelNumber));
        end
        function set.TriggerSource(this,newval)
            Sources={'IMM','BUS','EXT','TIM'};
            assert(any(strcmpi(newval,Sources)),...
                ['InputError: TriggerSource must be' Sources])
            this.Parent.send(sprintf('TRIGger%d:SOURce %s', this.ChannelNumber, newval));
        end
        function ret=get.TriggerSource(this)
            ret=this.Parent.query(sprintf('TRIGger%d:SOURce?', this.ChannelNumber));
        end
        function set.TriggerTimer(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Trigger time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('TRIGger%d:TIMer %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('TRIGger%d:TIMer %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.TriggerTimer(this)
            ret=this.Parent.queryDouble(sprintf('TRIGger%d:TIMer?', this.ChannelNumber));
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
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Burst internal period must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:INTernal:PERiod %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:INTernal:PERiod %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstInternalPeriod(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:BURSt:INTernal:PERiod?', this.ChannelNumber));
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
            assert(isnumeric(newval) && isscalar(newval) && newval>=1|| any(strcmpi(newval,{'INF','MIN','MAX'})),...
                'Burst cycles must be positive scalar values or be specified as "INF", "MIN", or "MAX"');
            if ~any(strcmpi(newval,{'INF','MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:NCYCles %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:NCYCles %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstCycles(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:BURSt:NCYCles?', this.ChannelNumber));
            ret=ret(1:end-1);
        end
        function set.BurstPhase(this,newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0|| any(strcmpi(newval,{'MIN','MAX'})), ...
                'Burst phase must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:BURSt:PHASe %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:BURSt:PHASe %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.BurstPhase(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:BURSt:PHASe?',this.ChannelNumber));
            ret=ret(1:end-1);
        end
        function set.BurstState(this,newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Burst mode must be specified as either 0, 1, "ON" or "OFF"');
            if newval ==1
                newval = 'ON';
            elseif newval ==0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:BURSt:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.BurstState(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:BURSt:STATe?',this.ChannelNumber));
        end
        %% - Frequency options
        function set.Frequency(this, newval)
            assert(isnumeric(newval)&& newval>=0 || any(strcmpi(newval,{'MIN','MAX'})),...
                'Frequency must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency %s',this.ChannelNumber, newval));
            end
        end
        function ret = get.Frequency(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FREQuency?',this.ChannelNumber));
        end
        function set.FrequencyCenter(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:CENTer %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:CENTer %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyCenter(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:CENTer?', this.ChannelNumber));
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
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:SPAN %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:SPAN %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencySpan(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:SPAN?', this.ChannelNumber));
        end
        function set.FrequencyStart(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:STARt %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:STARt %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyStart(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:STARt?', this.ChannelNumber));
        end
        function set.FrequencyStop(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:STOP %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:STOPs %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyStop(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:STOP?', this.ChannelNumber));
        end
        function set.FrequencyDwellTime(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency center must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:LIST:DWELl %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:LIST:DWELl %s', this.ChannelNumber, newval));
            end
        end
        function ret=get.FrequencyDwellTime(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:LIST:DWELl?', this.ChannelNumber));
        end
        function set.FrequencyList(this, newlist)
            d=sprintf(' %gE+06',newlist(1));
            d= [d sprintf(', %gE+06',newlist(2:end))];
            this.Parent.send(sprintf(['SOURce%d:LIST:FREQ' d],this.ChannelNumber));
        end  % - set the Frequency List
        function ret = get.FrequencyList(this)
            ret = this.Parent.query(sprintf('SOURce%d:LIST:FREQuency:POINts?', this.ChannelNumber));
        end
        function set.FrequencyCouplingMode(this, newval)
            assert(any(strcmpi(newval,{'OFF','RAT'})),...
                'Frequency coupling mode must be specified as "OFFset" or "RATio"');
            this.Parent.send(sprintf('SOURce%d:FREQuency:COUPle:MODE %s', this.ChannelNumber, newval));
        end
        function ret = get.FrequencyCouplingMode(this)
            ret = this.Parent.query(sprintf('SOURce%d:FREQuency:COUPle:MODE?', this.ChannelNumber));
        end
        function set.FrequencyCouplingOffset(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency coupling offset must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FREQuency:COUPle:OFFSet %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FREQuency:COUPle:OFFSet %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.FrequencyCouplingOffset(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:COUPle:OFFSet?', this.ChannelNumber));
        end
        function set.FrequencyCouplingRatio(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0,...
                'Frequency coupling ratio must be a positive numeric value');
            this.Parent.send(sprintf('SOURce%d:FREQuency:COUPle:RATio %s', this.ChannelNumber, newval));
        end
        function ret = get.FrequencyCouplingRatio(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:COUPle:RATio?', this.ChannelNumber));
        end
        function set.FrequencyCouplingState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Frequency coupling state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:FREQuency:COUPle:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.FrequencyCouplingState(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:FREQuency:COUPle:STATe?',this.ChannelNumber));
        end
        function set.SweepHoldTime(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency sweep hold time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:SWEep:HTIMe %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:SWEep:HTIMe %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.SweepHoldTime(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:SWEep:HTIMe?', this.ChannelNumber));
        end
        function set.SweepReturnTime(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency sweep return time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:SWEep:RTIMe %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:SWEep:RTIMe %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.SweepReturnTime(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:SWEep:RTIMe?', this.ChannelNumber));
        end
        function set.SweepSpacing(this, newval)
            assert(any(strcmpi(newval,{'LIN','LOG'})), ...
                'Frequency sweep spacing must be specified as either "LINear" or "LOGarithmic"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:SWEep:SPACing %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:SWEep:SPACing %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.SweepSpacing(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:SWEep:SPACing?', this.ChannelNumber));
        end
        function set.SweepState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Frequency sweep state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:SWEep:STATe %s', this.ChannelNumber, newval));
        end
        function ret = get.SweepState(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:SWEep:STATe?', this.ChannelNumber));
        end
        function set.SweepTime(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency sweep time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:SWEep:TIME %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:SWEep:TIME %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.SweepTime(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:SWEep:TIME?', this.ChannelNumber));
        end
        %% - Output options
        function set.OutputState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Output state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('OUTPut%d %s', this.ChannelNumber, newval));
        end % - set the output state
        function ret = get.OutputState(this)
            ret = this.Parent.queryDouble(sprintf('OUTPut%d?',this.ChannelNumber));
        end % - get the output state
        function set.OutputLoad(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0|| any(strcmpi(newval,{'INF','MIN','MAX'})),...
                'Output load must be positive scalar values or be specified as "INF", "MIN", or "MAX"');
            if any(strcmpi(newval,{'INF','MIN','MAX'}))
                this.Parent.send(sprintf('OUTPut%d:LOAD %s',this.ChannelNumber, newval));
            else
                this.Parent.send(sprintf('OUTPut%d:LOAD %s',this.ChannelNumber, num2str(newval)));
            end
            
        end % - set the output load
        function ret = get.OutputLoad(this)
            ret = this.Parent.queryDouble(sprintf('OUTPut%d:LOAD?',this.ChannelNumber));
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
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Output sync state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('OUTPut%d:SYNC %s',this.ChannelNumber, newval));
        end % - set the output sync
        function ret = get.OutputSync(this)
            ret = this.Parent.queryDouble(sprintf('OUTPut%d:SYNC?',this.ChannelNumber));
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
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Output trigger state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('OUTPut%d:TRIGger %s',this.ChannelNumber, newval));
        end % - set the output trigger source
        function ret = get.OutputTriggerState(this)
            ret = this.Parent.queryDouble(sprintf('OUTPut%d:TRIGger?',this.ChannelNumber));
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
        %% - Function options
        % - Function Type
        function set.FunctionType(this, newval)
            assert(any(strcmpi(newval,{'SIN', 'SQU', 'TRI', 'RAMP', 'PULS', 'PRBS', 'NOIS', 'ARB', 'DC'})), ...
                'Function type must be specified as either "SINusoid", "SQUare", "TRIangle", "RAMP", "PULSe", "PRBS", "NOISe", "ARB", "DC"');
            this.Parent.send(sprintf('SOURce%d:FUNCtion %s', this.ChannelNumber, newval));
        end
        function ret = get.FunctionType(this)
            ret = this.Parent.query(sprintf('SOURce%d:FUNCtion?', this.ChannelNumber));
        end
        
        % - Arbitrary Function
        function set.ArbitraryFunction(this, newval)
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary "%s"', this.ChannelNumber, newval));
        end
        function ret = get.ArbitraryFunction(this)
            ret = this.Parent.query(sprintf('SOURce%d:FUNCtion:ARBitrary?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionAdvanceMethod(this, newval)
            assert(any(strcmpi(newval,{'TRIG', 'SRAT'})), ...
                'Arbitrary Function Advance Method must be specified as either "TRIGger" or "SRATe"');
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:ADvance %s', this.ChannelNumber, newval));
        end
        function ret = get.ArbitraryFunctionAdvanceMethod(this)
            ret = this.Parent.query(sprintf('SOURce%d:FUNCtion:ARBitrary:ADvance?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionFilter(this, newval)
            assert(any(strcmpi(newval,{'NORM', 'STEP', 'OFF'})), ...
                'Arbitrary Function Filter must be specified as either "NORMal", "STEP" or "OFF"');
            this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:FILTer %s', this.ChannelNumber, newval));
        end
        function ret = get.ArbitraryFunctionFilter(this)
            ret = this.Parent.query(sprintf('SOURce%d:FUNCtion:ARBitrary:FILTer?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionFrequency(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Frequency must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:FREQuency %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:FREQuency %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.ArbitraryFunctionFrequency(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:ARBitrary:FREQuency?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionPeriod(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'ArbitraryFunctionPeriod must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:PERiod %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:PERiod %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.ArbitraryFunctionPeriod(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:ARBitrary:PERiod?', this.ChannelNumber));
        end
        function ret = get.ArbitraryFunctionNumberOfPoints(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:ARBitrary:POINts?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionPeakToPeak(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Peak-Peak voltage must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:PTPeak %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:PTPeak %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.ArbitraryFunctionPeakToPeak(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:ARBitrary:PTPeak?', this.ChannelNumber));
        end
        function set.ArbitraryFunctionSamplingRate(this, newval)
            assert(isnumeric(newval)&& newval>=0 || any(strcmpi(newval,{'MIN','MAX'})),...
                'Sample rate must be positive numeric value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                if strcmp(this.ArbitraryFunctionFilter(1:end-1), 'OFF')
                    warning('Sample rate set to 62.7 MSa/s since filter is off!')
                end
                if newval > 250e+06
                    error('Sample rate larger 250 MSa/s not supported!')
                end
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:SRATe %s',this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:ARBitrary:SRATe %s',this.ChannelNumber, newval));
            end
        end   % - set the sample rate
        function ret = get.ArbitraryFunctionSamplingRate(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:ARBitrary:SRATe?',this.ChannelNumber));
        end   % - get the sample rate
        
        % - Noise Function
        function set.NoiseFunctionBandwidth(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Noise Function Bandwidth must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:NOISe:BANDwidth %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:NOISe:BANDwidth %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.NoiseFunctionBandwidth(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:NOISe:BANDwidth?', this.ChannelNumber));
        end
        
        % - PBRS Function
        function set.PBRSFunctionBitRate(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'PBRS Function Bit Rate must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PRBS:BRATe %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PRBS:BRATe %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PBRSFunctionBitRate(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PRBS:BRATe?', this.ChannelNumber));
        end
        function set.PBRSFunctionSequenceType(this, newval)
            this.Parent.send(sprintf('SOURce%d:FUNCtion:PRBS:DATA %s', this.ChannelNumber, newval));
        end
        function ret = get.PBRSFunctionSequenceType(this)
            ret = this.Parent.query(sprintf('SOURce%d:FUNCtion:PRBS:DATA?', this.ChannelNumber));
        end
        function set.PBRSFunctionTransition(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'PBRS Function transition edge time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PRBS:TRANsition:BOTH %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PRBS:TRANsition:BOTH %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PBRSFunctionTransition(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PRBS:TRANsition:BOTH?', this.ChannelNumber));
        end
        
        % - Pulse Function
        function set.PulseFunctionDutyCycle(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function duty cycle must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:DCYCle %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:DCYCle %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionDutyCycle(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:DCYCle?', this.ChannelNumber));
        end
        function set.PulseFunctionHoldTime(this, newval)
            assert(any(strcmpi(newval,{'WIDT', 'DCYC'})), ...
                'Pulse function hold time must be specified as either "WIDTh" or "DCYCle"');
            this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:HOLD %s', this.ChannelNumber, newval));
        end
        function ret = get.PulseFunctionHoldTime(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:HOLD?', this.ChannelNumber));
        end
        function set.PulseFunctionPeriod(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function period must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:PERiod %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:PERiod %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionPeriod(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:PERiod?', this.ChannelNumber));
        end
        function set.PulseFunctionLeadingEdge(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function leading edge time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:LEADing %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:LEADing %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionLeadingEdge(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:LEADing?', this.ChannelNumber));
        end
        function set.PulseFunctionTrailingEdge(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function trailing edge time must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:TRAiling %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:TRAiling %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionTrailingEdge(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:TRAiling?', this.ChannelNumber));
        end
        function set.PulseFunctionBothEdges(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function edge time for both edges must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:BOTH %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:BOTH %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionBothEdges(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:TRANsition:BOTH?', this.ChannelNumber));
        end
        function set.PulseFunctionWidth(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Pulse function width must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:WIDTh %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:PULSe:WIDTh %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.PulseFunctionWidth(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:PULSe:WIDTh?', this.ChannelNumber));
        end
        
        % - Ramp Function
        function set.RampFunctionSymmetry(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Ramp symmetry percentage be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:RAMP:SYMMetry %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:RAMP:SYMMetry %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.RampFunctionSymmetry(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:RAMP:SYMMetry?', this.ChannelNumber));
        end
        
        % - Square Function
        function set.SquareFunctionDutyCycle(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Square Function Duty Cycle must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:FUNCtion:SQUare:DCYCle %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:FUNCtion:SQUare:DCYCle %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.SquareFunctionDutyCycle(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:FUNCtion:SQUare:DCYCle?', this.ChannelNumber));
        end
        %% - Data options
        function ret = get.DataCrestFactor(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:DATA:ATTRibute:CFACtor?', this.ChannelNumber));
        end
        function ret = get.DataPoints(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:DATA:ATTRibute:POINts?', this.ChannelNumber));
        end
        function ret = get.DataPeakToPeak(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:DATA:ATTRibute:PTPeak?', this.ChannelNumber));
        end
        function ret = get.DataAverage(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:DATA:ATTRibute:AVERage?', this.ChannelNumber));
        end
        function ret = get.VolatileMemoryCatalog(this)
            ret = this.Parent.query(sprintf('SOURce%d:DATA:VOLatile:CATalog?', this.ChannelNumber));
        end
        function ret = get.FreeVolatileMemory(this)
            ret = this.Parent.query(sprintf('SOURce%d:DATA:VOLatile:FREE?', this.ChannelNumber));
        end
        %% - Rate coupling options
        % RATE Subsystem
        % The RATE subsystem allows you to couple the outputs' sample rates
        % on a two-channel instrument by specifying
        % the following items:
        function set.RateCouplingMode(this, newval)
            assert(any(strcmpi(newval,{'OFF','RAT'})),...
                'Rate coupling mode must be specified as "OFFset" or "RATio"');
            this.Parent.send(sprintf('SOURce%d:RATE:COUPle:MODE %s', this.ChannelNumber, newval));
        end
        function ret = get.RateCouplingMode(this)
            ret = this.Parent.query(sprintf('SOURce%d:RATE:COUPle:MODE?', this.ChannelNumber));
        end
        function set.RateCouplingOffset(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0 || any(strcmpi(newval,{'MIN','MAX'})), ...
                'Rate coupling offset must be positive scalar value or specified as either "MIN" or "MAX"');
            if ~any(strcmpi(newval,{'MIN','MAX'}))
                this.Parent.send(sprintf('SOURce%d:RATE:COUPle:OFFSet %s', this.ChannelNumber, num2str(newval)));
            else
                this.Parent.send(sprintf('SOURce%d:RATE:COUPle:OFFSet %s', this.ChannelNumber, newval));
            end
        end
        function ret = get.RateCouplingOffset(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:RATE:COUPle:OFFSet?', this.ChannelNumber));
        end
        function set.RateCouplingRatio(this, newval)
            assert(isnumeric(newval) && isscalar(newval) && newval>=0,...
                'Rate coupling ratio must be a positive numeric value');
            this.Parent.send(sprintf('SOURce%d:RATE:COUPle:RATio %s', this.ChannelNumber, newval));
        end
        function ret = get.RateCouplingRatio(this)
            ret = this.Parent.queryDouble(sprintf('SOURce%d:RATE:COUPle:RATio?', this.ChannelNumber));
        end
        function set.RateCouplingState(this, newval)
            assert( (isnumeric(newval) && (newval == 0 || newval == 1) ) || any(strcmpi(newval, {'ON','OFF'})), ...
                'Rate coupling state must be specified as either 0, 1, "ON" or "OFF"');
            if newval == 1
                newval = 'ON';
            elseif newval == 0
                newval = 'OFF';
            end
            this.Parent.send(sprintf('SOURce%d:RATE:COUPle:STATe %s', this.ChannelNumber, newval));
        end
        function ret=get.RateCouplingState(this)
            ret=this.Parent.queryDouble(sprintf('SOURce%d:RATE:COUPle:STATe?',this.ChannelNumber));
        end
    end  % - setters & getters
    methods
        function set.ArbitraryFunctionSamplingTime(this, newval)
            assert(isnumeric(newval)&& newval>=0 || any(strcmpi(newval,{'MIN','MAX'})),...
                'Sample rate must be positive numeric value or specified as either "MIN" or "MAX"');
            if strcmpi(newval,'MAX')
                this.ArbitraryFunctionSamplingRate = 'MIN';
            elseif strcmpi(newval,'MIN')
                this.ArbitraryFunctionSamplingRate = 'MAX';
            else
                this.ArbitraryFunctionSamplingRate = 1/newval;
            end
        end   % - set the sample rate
        function ret = get.ArbitraryFunctionSamplingTime(this)
            ret = 1/this.ArbitraryFunctionSamplingRate;
        end   % - get the sample rate
    end  % - setters/getters: Custom
end