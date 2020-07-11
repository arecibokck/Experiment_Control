%% - Description:
%
%
% Open: 
%   - Strange:  the "FUNCtion:ARBitrary:FREQuency" (and "...Period") and
%               "FUNCtion:ARBitrary:SRATe" are not coupled !
%               What is the meaning of the former two?
%   - Which "ArbitraryFunctionFilter" to use ? 'NORM', 'STEP', 'OFF'
%   - Misc-Commands:
%           - How to go about initiat-subsystem ?
%           - Unit-Subsystem ? 
%           - What is the Source:Phase:Arbitrary?
%   - Example-Code: Device-Class: 
%           - ret = queryUpload
%           - downloadDataFile
%           - downloadBinBlockData
%           - deleteData
%   - Example-Code: Channel-Class: 
%           - MMemory:
%               - loadList
%               - storeList
%               - loadData
%               - storeData
%   - Arbitrary WaveForms for Wigner-functions
%       - redo Karthik's examples (assertions etc.)
%   - Porting the class into the Secondary controller
%   
%
%


%% - Test Device
if true
    %% - methods: lifecylce
    if true
        %% - create object
        DeviceID = 'TCPIP0::131.220.157.72::inst0::INSTR';
        WaveGen = Devices.KeysightWaveGen.K33522BDevice(DeviceID);
        %% - connect
        WaveGen.connect
        %% - disconnect
        WaveGen.disconnect
        %% - delete
        WaveGen.delete
    end
    %% - methods: basic
    if true
        %% - get handle to channel objects
        Channel_1 = WaveGen.channels(1);
        Channel_2 = WaveGen.channels(2);
        %% - query channelnumber from channelobject
        Channel_1.ChannelNumber
        %% - get Number of Channels
        WaveGen.NumberOfChannels
        %% - query *Idn?
        ret = WaveGen.queryIdentification
        %% - self test (starts self test, but there is no return because of a visa timeout)
        ret = WaveGen.selfTest
        %% - reset Device  (throws error)
        WaveGen.resetDevice
        %% - getError
        ret = WaveGen.getError
        %% - Abort
        WaveGen.Abort
        %% - ClearStatus
        WaveGen.clearStatus
        %% - checkOPC
        ret = WaveGen.checkOPC
        %% - busTrigger
        WaveGen.busTrigger;
        %% - wait (Wait for all pending operations to complete)
        WaveGen.wait
    end
    %% - methods: initiate
    if true
        %% - inititateImmediateTrigger
        if true
            %%
            WaveGen.inititateImmediateTrigger; %
            %%
            %WaveGen.inititateImmediateTrigger('ALL');WaveGen.getError
            WaveGen.inititateImmediateTrigger(2);WaveGen.getError
            %%
        end
        %% - setContinuousTrigState(this, state)
    end
    %% - methods: arbitrary waveform
    if true
        %% syncChannels
        WaveGen.syncChannels;
    end
end
%% - Test Channel
if true
    %% - methods: Basic
    if true
        %% - initiateImmediateTrigger
        WaveGen.channels(ChannelNumber).initiateImmediateTrigger;
    end 
    %% - methods: Data
    if true
        %% - loadArbitraryData to volatile memory of the channel
        ChannelNumber = 2;
        RampName = 'dc5v';
        RampAsString = [RampName ', 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0'];
        Format = 'DAC';
        WaveGen.channels(ChannelNumber).loadArbitraryData(RampAsString,Format);
        %% - clear volatile memory
        WaveGen.channels(ChannelNumber).clearVolatilememory
        %% - createDataSequence(this, newval)
        if true
            ChannelNumber = 1;
            %% - some info
            % Options for Sync signal generation include:
            % - assert Sync at the beginning of the segment
            % - negate Sync at the beginning of the segment
            % - maintain the current Sync state throughout the segment
            % - assert Sync at the beginning of the segment and negate it at a defined point within the segment
            % To start a sequence on a trigger, place a brief DC waveform of 0 V (or any other desired value) in front of
            % the other waveforms in the sequence, and set the segment to wait for a trigger before advancing. For
            % 33500 Series instruments, the minimum segment length is 8 Sa, and for 33600 Series instruments, the
            % minimum segment length is 32 Sa.

            %% - prepare device
            WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 10e+03;
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter = 'OFF';
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak = 10;
            WaveGen.wait;
            %% - load Ramps:   % Arb data are fractions of PeakToPeak spaced in time by 1/SamplingRate
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc_ramp, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0'); %load an arbitrary waveform in internal memory like this
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc5v, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc2_5v, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc0v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0');
            WaveGen.wait;
            %% - generate Sequence
            %<block_descriptor> is of the format #<n><n digits><sequence name>,<arb name1>,<repeat count1>,<play control1>,<marker mode1>, <marker point1>, <arb name2>,<repeat count2>,<play control2>,<marker mode2>, <marker point2>, and so on
            % In this example, the size of the IEEE Definite Length Arbitrary Block of sequence written as a character string below is 128, which requires 3 digits to represent – hence the #3128 header.
            SequenceAsAString = ['#3128"seqExample",' ...
                                                                '"dc_ramp",0,once,highAtStart,5,'...
                                                                '"dc5v",2,repeat,maintain,5,'...
                                                                '"dc2_5v",2,repeat,lowAtStart,5,'...
                                                                '"dc0v",2,repeat,maintain,5'];
            WaveGen.channels(ChannelNumber).createDataSequence(SequenceAsAString);
            %% - set as active Waveform
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'seqExample'; 
            ret = WaveGen.channels(ChannelNumber).ArbitraryFunction
            %% - 
            WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
            WaveGen.channels(ChannelNumber).OutputState = 'ON';
            %% - set external trigger
            WaveGen.channels(ChannelNumber).TriggerSource = 'IMM';
            ret = WaveGen.channels(ChannelNumber).TriggerSource
            %% - 
            WaveGen.channels(ChannelNumber).initiateImmediateTrigger
            WaveGen.channels(ChannelNumber).ArbitraryFunctionAdvanceMethod = 'SRat';
            %% - set to burst mode
            WaveGen.channels(ChannelNumber).BurstState = 1;
            ret = WaveGen.channels(ChannelNumber).BurstState
            %%
            WaveGen.setContinuousTrigState('On')
            %%
            ret = WaveGen.query(sprintf('INITiate%d:CONTinuous? ', ChannelNumber))
            
        end 
    end
    %% - methods: Load/Store channel-specific data/list from on-board memory
    if true
        %% - loadList
        %% - storeList
        %% - loadData
        %% - storeData
    end
    %% - methods: Apply Arbitrary waveforms
    if true
        %% - sync(this)
        ChannelNumber =2;
        WaveGen.channels(ChannelNumber).sync;
        %% - upload
        %% - preview
    end
    %% - MMEMory:  Up- and  download data to mass memory
    if true
        %% queryUpload(this, filename)
        %% downloadDataFile(this, filename)
        %% downloadBinBlockData(this, dat)
        %% deleteData(this, filename)
    end
    %% - plotting
    if true
    end
    %% - static(mostly Network)
    if true
        %% [Network_Devices_List,Network_Devices_List_Structured] = enumerateETHERNET;
        %% [USB_Devices_List,USB_Devices_List_Structured] = enumerateUSB(~, szFilter);
        %% function findAndConnectToDevice(MacAdress,ConnectionType)
    end
    
    
    
    
    
    %% - Channel Properties
    if true
        ChannelNumber = 1; 
        %% - Voltage options
        if true
            %% - set/get  get Amplitude
                WaveGen.channels(ChannelNumber).Amplitude
            %% - set/get  get Offset
                WaveGen.channels(ChannelNumber).Offset
            %% - set/get  get HighLevel
                WaveGen.channels(ChannelNumber).HighLevel
            %% - set/get  get LowLevel
                WaveGen.channels(ChannelNumber).LowLevel
            %% - set/get  Autorange
                WaveGen.channels(ChannelNumber).AutoRange
            %% - set/get  VoltageCouplingState
            % flag whether Channel 1 and 2 are coupled
                WaveGen.channels(ChannelNumber).VoltageCouplingState
            %% - set/get VoltageUnits of the amplitude ('VPP') | 'VRMS'  | 'DBM'
                WaveGen.channels(ChannelNumber).VoltageUnits = 'VPP';
                ret = WaveGen.channels(ChannelNumber).VoltageUnits
        end
        %% - Trigger options
        if true
        %% - set/get 
            WaveGen.channels(ChannelNumber).TriggerCount
        %% - set/get 
            WaveGen.channels(ChannelNumber).TriggerDelay
        %% - set/get 
            WaveGen.channels(ChannelNumber).TriggerSlope
        %% - set/get 
            WaveGen.channels(ChannelNumber).TriggerSource
        %% - set/get 
            WaveGen.channels(ChannelNumber).TriggerTimer
       end
        %% - Burst options
        if true
            %% - set/get 
                WaveGen.channels(ChannelNumber).BurstCycles
            %%
                WaveGen.channels(ChannelNumber).BurstGatePolarity
            %% - set/get 
                WaveGen.channels(ChannelNumber).BurstInternalPeriod
            %% - set/get 
                WaveGen.channels(ChannelNumber).BurstMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).BurstPhase
            %% - set/get 
                WaveGen.channels(ChannelNumber).BurstState
        end
        %% - General options
        if true
        end
        %% - Frequency(-sweep) options
        if true
            %% - set/get 
                WaveGen.channels(ChannelNumber).Frequency
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyCenter
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyDwellTime
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencySpan
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyStart
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyCouplingMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyCouplingOffset
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyCouplingRatio
            %% - set/get 
                WaveGen.channels(ChannelNumber).FrequencyCouplingState
            %% - set/get 
                WaveGen.channels(ChannelNumber).SweepHoldTime
            %% - set/get 
                WaveGen.channels(ChannelNumber).SweepReturnTime
            %% - set/get 
                WaveGen.channels(ChannelNumber).SweepSpacing
            %% - set/get 
                WaveGen.channels(ChannelNumber).SweepState
            %% - set/get 
                WaveGen.channels(ChannelNumber).SweepTime
        end
        %% - Output options
        if true
            %% - set/get  OutputState 
                newVal = 'on'; % 1  | 0 | 'On' | 'Off' 
                WaveGen.channels(ChannelNumber).OutputState = newVal;
                WaveGen.channels(ChannelNumber).OutputState
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputLoad
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputPolarity
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputState
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputSync
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputSyncMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputSyncPolarity
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputSyncSource
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputTriggerSlope
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputTriggerSource
            %% - set/get 
                WaveGen.channels(ChannelNumber).OutputTriggerState
        end
        %% - Function options
        if true
            %% - set/get 
                WaveGen.channels(ChannelNumber).FunctionType
            %%
            if true
                %% - set/get to ArbitraryFunction
                WaveGen.channels(ChannelNumber).ArbitraryFunction
                %% set/get ArbitraryFunctionSamplingRate
                WaveGen.channels(1).ArbitraryFunctionSamplingRate = 10E6;
                ret = WaveGen.channels(1).ArbitraryFunctionSamplingRate;
                disp(['The sampling rate is set to ' num2str(ret*1E-6) ' MSamples'])
%                 ret2 = WaveGen.channels(1).ArbitraryFunctionPeriod;
%                 disp(['The sampling Period is ' num2str(ret2*1E6) ' us'])
                %% - set/get ArbitraryFunctionAdvanceMethod (SRate) | 'Trig'
                ChannelNumber = 1;
                WaveGen.channels(ChannelNumber).ArbitraryFunctionAdvanceMethod = 'Trig';
                ret = WaveGen.channels(ChannelNumber).ArbitraryFunctionAdvanceMethod
                %% - set/get 'NORM', 'STEP', 'OFF'
                WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter = 'NORM';
                ret = WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter
                %% - set/get 
                WaveGen.channels(ChannelNumber).ArbitraryFunctionFrequency
                %% - set/get 
                WaveGen.channels(ChannelNumber).ArbitraryFunctionNumberOfPoints
                %% - set/get 
                WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak
                %% - set/get ArbitraryFunctionPeriod 
                WaveGen.channels(1).ArbitraryFunctionPeriod = 1000e-6;
                ret =WaveGen.channels(1).ArbitraryFunctionPeriod 
            end
            %% - Noise/PBRS
            if true
                %% - set/get NoiseFunctionBandwidth
                    WaveGen.channels(ChannelNumber).NoiseFunctionBandwidth
                    
                    
                %% - set/get PBRSFunctionBitRate
                    WaveGen.channels(ChannelNumber).PBRSFunctionBitRate
                %% - set/get PBRSFunctionSequenceType
                    WaveGen.channels(ChannelNumber).PBRSFunctionSequenceType
                %% - set/get PBRSFunctionTransition
                    WaveGen.channels(ChannelNumber).PBRSFunctionTransition
                %% - set/get PulseFunctionBothEdges
                    WaveGen.channels(ChannelNumber).PulseFunctionBothEdges
            end
            %% - PulseFunction
            if true 
                %% - set/get PulseFunctionDutyCycle
                    WaveGen.channels(ChannelNumber).PulseFunctionDutyCycle
                %% - set/get PulseFunctionHoldTime
                    WaveGen.channels(ChannelNumber).PulseFunctionHoldTime
                %% - set/get PulseFunctionLeadingEdge
                    WaveGen.channels(ChannelNumber).PulseFunctionLeadingEdge
                %% - set/get PulseFunctionPeriod
                    WaveGen.channels(ChannelNumber).PulseFunctionPeriod
                %% - set/get PulseFunctionTrailingEdge
                    WaveGen.channels(ChannelNumber).PulseFunctionTrailingEdge
                %% - set/get PulseFunctionWidth
                    WaveGen.channels(ChannelNumber).PulseFunctionWidth
            end
            %% - Ramps
            if true 
                %% - set/get RampFunctionSymmetry
                    WaveGen.channels(ChannelNumber).RampFunctionSymmetry  
                %% - set/get SquareFunctionDutyCycle
                    WaveGen.channels(ChannelNumber).SquareFunctionDutyCycle
            end
        end
        %% - Data options
        if true
            %% - set/get 
                WaveGen.channels(ChannelNumber).DataAverage
            %% - set/get 
                WaveGen.channels(ChannelNumber).DataCrestFactor
            %% - set/get 
                WaveGen.channels(ChannelNumber).DataPeakToPeak
            %% - set/get 
                WaveGen.channels(ChannelNumber).DataPoints  
        end
        %% - Rate coupling options
        if true
            %% - set/get 
                WaveGen.channels(ChannelNumber).RateCouplingMode
            %% - set/get 
                WaveGen.channels(ChannelNumber).RateCouplingOffset
            %% - set/get 
                WaveGen.channels(ChannelNumber).RateCouplingRatio
            %% - set/get 
                WaveGen.channels(ChannelNumber).RateCouplingState
        end
    end
    
    %% - ApplyCommands (Channel)
    if true
        %% - DCVoltage
        if true
            %% - no input
                WaveGen.channels(ChannelNumber).applyDCVoltage;
            %% - set offset 
            options = {};
            options = [options,{'offset',3}];
                WaveGen.channels(ChannelNumber).applyDCVoltage(options{:});
        end
        %% -  Noise (Outputs gaussian noise with the specified amplitude and DC offset.)
        if true
            %% - no input
            WaveGen.channels(ChannelNumber).applyNoise();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applyNoise(options{:});
        end
        %% - applyPRBS (Outputs a pseudo-random binary sequence with the specified bit rate, amplitude and DC offset)
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applyPRBS();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applyPRBS(options{:});
            %% - further parameters
            % - BitRate
            % - PRBS Data
            % - Edge Time

        end
        %% - applyPulse
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applyPulse();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applyPulse(options{:});
        end
        %% - applyRamp
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applyRamp();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applyRamp(options{:});
        end
        %% - applyTriangleWave
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applyTriangleWave();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applyTriangleWave(options{:});
        end
        %% - applySineWave
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applySineWave();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applySineWave(options{:});
        end
        %% - applySquareWave
        if true
            %% - no options
            WaveGen.channels(ChannelNumber).applySquareWave();
            %% - with options
            options = {};
            options = [options,{'frequency',1E3}];
            options = [options,{'amplitude',1}];
            options = [options,{'offset',2}];
            WaveGen.channels(ChannelNumber).applySquareWave(options{:});
        end
    end
    %% - test external trigger
    if true
        %% - Waveform example 
        ChannelNumber = 1;
        WaveGen.channels(ChannelNumber).FunctionType = 'SIN';
        WaveGen.channels(ChannelNumber).Frequency = 1.2e+04;
        %WaveGen.channels(ChannelNumber).Amplitude = 5;
        %WaveGen.channels(ChannelNumber).Offset    = 0;
        WaveGen.channels(ChannelNumber).HighLevel = 0;
        WaveGen.channels(ChannelNumber).LowLevel = -4;
        WaveGen.channels(ChannelNumber).BurstPhase = 90;
        %WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
        %WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
        WaveGen.channels(ChannelNumber).OutputLoad = 'INF';
        % - set trigger source
        WaveGen.channels(ChannelNumber).TriggerSource = 'EXT';
        % - set trigger level
        %WaveGen.channels(1).TriggerLevel; Unable to set trig level? Throws
        %error, option not available on device? option could not be accessed it locally
        % - set trigger edge 
        WaveGen.channels(ChannelNumber).TriggerSlope = 'POS';
        % - set trigger delay
        WaveGen.channels(ChannelNumber).TriggerDelay = 10e-06;
        % - set burst mode
        WaveGen.channels(ChannelNumber).BurstMode = 'TRIG';
        % - set number of bursts
        WaveGen.channels(ChannelNumber).BurstCycles = 1;
        % - toggle burst mode
        WaveGen.channels(ChannelNumber).BurstState = 1;
        % - start execution
        WaveGen.channels(ChannelNumber).OutputState = 'ON';
        %% - ??
        ChannelNumber = 2;
        WaveGen.channels(ChannelNumber).FunctionType = 'SIN';
        WaveGen.channels(ChannelNumber).Frequency = 1.2e+04;
        %WaveGen.channels(ChannelNumber).Amplitude = 5;
        %WaveGen.channels(ChannelNumber).Offset    = 5;
        WaveGen.channels(ChannelNumber).HighLevel = 4;
        WaveGen.channels(ChannelNumber).LowLevel = 0;
        WaveGen.channels(ChannelNumber).BurstPhase = 270;
        %WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
        %WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
        WaveGen.channels(ChannelNumber).OutputLoad = 'INF';
        % - set trigger source
        WaveGen.channels(ChannelNumber).TriggerSource = 'EXT';
        % - set trigger level
        %WaveGen.channels(1).TriggerLevel; Unable to set trig level? Throws
        %error, option not available on device? option could not be accessed it locally
        % - set trigger edge 
        WaveGen.channels(ChannelNumber).TriggerSlope = 'POS';
        % - set trigger delay
        WaveGen.channels(ChannelNumber).TriggerDelay = 10e-06;
        % - set burst mode
        WaveGen.channels(ChannelNumber).BurstMode = 'TRIG';
        % - set number of bursts
        WaveGen.channels(ChannelNumber).BurstCycles = 1;
        % - toggle burst mode
        WaveGen.channels(ChannelNumber).BurstState = 1;

        % - start execution
        WaveGen.channels(ChannelNumber).OutputState = 'ON';
    end
end
%% - examples
if true
    %% - Examples From Manual
    if true
        %% - Arbitrary waveform example 
        ChannelNumber = 1;
        WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
        WaveGen.channels(ChannelNumber).Amplitude = 3;
        WaveGen.channels(ChannelNumber).Offset = 1;
        WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
        WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
        WaveGen.channels(ChannelNumber).OutputState = 'ON';
        %% - Sin wave
        WaveGen.send('FUNCtion SIN')
        WaveGen.send('FREQuency +1.0E+03')
        WaveGen.send('VOLTAGE:HIGH +2.0')
        WaveGen.send('VOLTAGE:LOW -2.0')
        WaveGen.send('OUTPut ON')
        %% - Square wave
        WaveGen.send('FUNCtion SQU')
        WaveGen.send('FUNC:SQU:DCYC +20.0')
        WaveGen.send('FREQuency +1.0E+03')
        WaveGen.send('VOLT:HIGH +4.0')
        WaveGen.send('VOLT:LOW +0.0')
        WaveGen.send('OUTP 1')
        %% - turn both channels off
        WaveGen.send('OUTPut OFF')
    end
    %% - Arbitrary waveform examples
    if true
        %% - Arbitrary waveform example Data- and MMEmory- functions 
        if true
            WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 100e+03;
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter = 'OFF';
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak = 10;
            WaveGen.wait;
            % Arb data are fractions of PeakToPeak spaced in time by 1/SamplingRate
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc_ramp, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0'); %load an arbitrary waveform in internal memory like this
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc5v, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc2_5v, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).loadArbitraryData('dc0v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0');
            WaveGen.wait;
            %<block_descriptor> is of the format #<n><n digits><sequence name>,<arb name1>,<repeat count1>,<play control1>,<marker mode1>, <marker point1>, <arb name2>,<repeat count2>,<play control2>,<marker mode2>, <marker point2>, and so on
            % In this example, the size of the IEEE Definite Length Arbitrary Block of sequence written as a character string below is 128, which requires 3 digits to represent – hence the #3128 header.
            WaveGen.channels(ChannelNumber).createDataSequence('#3128"seqExample","dc_ramp",0,once,highAtStart,5,"dc5v",2,repeat,maintain,5,"dc2_5v",2,repeat,lowAtStart,5,"dc0v",2,repeat,maintain,5');
            
            
            
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc_ramp';
            WaveGen.channels(ChannelNumber).storeData('INT:\dc_ramp.arb'); %Save arbitrary waveform as arb file in internal memory
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc5v'; 
            WaveGen.channels(ChannelNumber).storeData('INT:\dc5v.arb');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc2_5v'; 
            WaveGen.channels(ChannelNumber).storeData('INT:\dc2_5.arb');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc0v'; 
            WaveGen.channels(ChannelNumber).storeData('INT:\dc0v.arb');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'seqExample'; 
            WaveGen.channels(ChannelNumber).storeData('INT:\seqExample.seq');
            WaveGen.wait;
            WaveGen.channels(ChannelNumber).clearVolatilememory
            WaveGen.channels(ChannelNumber).loadData('INT:\seqExample.seq');
            WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\seqExample.seq';
            WaveGen.channels(ChannelNumber).OutputState = 'ON';
        end
        %% - query upload
        fileName ='INT:\dc5v.arb';
        
        ret = WaveGen.queryUpload(fileName) 
        %% - Arbitrary waveform example create and load a Sequence  
        if true
            ChannelNumber = 1;
            WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\HAVERSINE.arb'); %Load a saved arb file in internal memory
            WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\CARDIAC.arb');
            WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\GAUSSIAN.arb');
            WaveGen.channels(ChannelNumber).createDataSequence('#3164"testSeq","INT:\BUILTIN\HAVERSINE.arb",0,repeat,highAtStartGoLow,30,"INT:\BUILTIN\CARDIAC.arb",0,repeat,maintain,10,"INT:\BUILTIN\GAUSSIAN.arb",0,repeat,maintain,10');
            WaveGen.channels(ChannelNumber).ArbitraryFunction = 'testSeq';
            WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
            WaveGen.channels(ChannelNumber).OutputState = 'ON';
        end
        %% - Arbitrary ramp example with cosinosoidal modulation
        ChannelNumber =2;
        cos_ramp = @(x,p) p(2)+1/2*(p(1)-p(2))*(1+cos(pi*x));
        RampingDurationDown = 250; 
        LowDuration = 2;
        RampingDurationUp = 10;
        FinalDuration = 50;
        HIGH = 5;
        LOW = 0;
        maxSamplingPoints   = 1e6;

        % The maximum rate of the Keysight 33500B is 30 MHz. The maximum number of samples is chosen 1e6 . 
        % Find optimal rate (round up) and determine the number of datapoints
        AmplitudeRamp_Ch1 = [cos_ramp(linspace(0,1,(RampingDurationDown)),[HIGH,LOW]) ...
                    LOW .* ones(1,LowDuration) ...
                    cos_ramp(linspace(0,1,RampingDurationUp),[LOW,HIGH]) ...
                    HIGH .* ones(1,FinalDuration)];



        numberofsamples = length(AmplitudeRamp_Ch1);  
        AmplitudeRampTimeGrid = linspace(0, FinalDuration, numberofsamples);
        AmplitudeRamp_Ch1 = interp1(linspace(0,FinalDuration,numberofsamples), AmplitudeRamp_Ch1, AmplitudeRampTimeGrid);
        WaveGen.channels(ChannelNumber).preview(AmplitudeRamp_Ch1);
        %WaveGen.channels(ChannelNumber).SamplingRate = 1;
        WaveGen.channels(ChannelNumber).upload(AmplitudeRamp_Ch1,'Impedance', 'INF', 'BurstCycles', 1);
    end
end
%% - Wigner function reconstruction
if true
    %%
    clc
    %% - set sampling time/rate:
    SamplingTime = 8000E-9;
    WaveGen.channels(1).ArbitraryFunctionSamplingRate = 1/SamplingTime;
    WaveGen.channels(2).ArbitraryFunctionSamplingRate = 1/SamplingTime;
    ret = WaveGen.channels(1).ArbitraryFunctionSamplingRate;
    disp(['The sampling rate is set to ' num2str(ret*1E-6) ' MSamples'])
    ret2 = WaveGen.channels(1).ArbitraryFunctionSamplingTime;
    disp(['The sampling time is ' num2str(ret2*1E6) ' us'])
    
    assert(SamplingTime==ret2,'SamplingTime must equal 1/ArbitraryFunctionSamplingRate')
    %% - generate Parity operation ramps
    [AmplitudesSpinUp,AmplitudesSpinDown] = GenerateWignerRamp(SamplingTime);
    % AmplitudesSpinUp = (rand(size(AmplitudesSpinUp))-0.5)*20; % - random noise
    AmplitudesSpinUp = [ones(1,100)*10,zeros(1,100)-10];
    AmplitudesSpinDown = AmplitudesSpinUp;
    %% - plot Parity operation ramps
    plotParityOperationRamp(SamplingTime,AmplitudesSpinUp,AmplitudesSpinDown)  
    
    %% - configure AWG
    %WaveGen.channels(1).ArbitraryFunctionFilter = 'STEP';
    WaveGen.channels(1).ArbitraryFunctionFilter = 'STEP';
    %WaveGen.channels(1).ArbitraryFunctionFilter = 'STEP';
    %WaveGen.channels(2).ArbitraryFunctionFilter = 'STEP';
 
    
    % - upload Ramps
    clc
    WaveGen.channels(1).upload(...
        AmplitudesSpinUp,...
        ...'SamplingRate', min(numberofsamples/max(AmplitudeRampTimeGrid), 250),...
        'Impedance', 'INF',...
        'BurstCycles', 1,...
        'BurstPhase', 0);
    
    WaveGen.channels(2).upload(...
        AmplitudesSpinDown,...
        ...'SamplingRate', min(numberofsamples/max(AmplitudeRampTimeGrid), 250), ...
        'Impedance', 'INF',...
        'BurstCycles', 1,...
        'BurstPhase', 0);
end
%% - TestBench
if true
    clc
    ChannelNumber = 1;
    WaveGen.channels(ChannelNumber).preview(AmplitudeRamp_Ch1)
    ylim([-10,10])
    %% - read out currentWaveform
end
%% - helperFunctions

function plotParityOperationRamp(SamplingTime,AmplitudeUp,AmplitudeDown)  
    
    TimeUnit = 'us';
    switch TimeUnit
        case 'us'
            TimeConversionFactor = 1E6;
    end
    AmplitudeRampTimeGrid = (1:numel(AmplitudeUp))*SamplingTime*TimeConversionFactor;
    figure(3)
    clf 
    stairs(AmplitudeRampTimeGrid,AmplitudeUp,'r-','DisplayName','Amplitude Spin up')
    hold on
    stairs(AmplitudeRampTimeGrid,AmplitudeDown,'b-','DisplayName','Amplitude Spin down')
    legend
    grid on
    ylim([min(0,min([AmplitudeUp(:)',AmplitudeDown(:)'])*1.1),...
                 max([AmplitudeUp(:)',AmplitudeDown(:)'])*1.1])
    ylabel('Voltage [V]','FontSize',16)
    xlabel(['Time [' TimeUnit ']'],'FontSize',16)
    title('Voltage ramp for Parity operation','FontSize',18)
end

function [vals,times] = SinosoidalRamp(tstart,tend,x0,xEnd,tspacing)
        times =linspace(tstart,tend,(tend-tstart)/tspacing);
        vals = x0 - (xEnd-x0)*0.5*(cos(times*pi/(tend-tstart))-1);
    end 
   

function [AmplitudesUp,AmplitudesDown] = GenerateWignerRamp(SamplingTime,varargin)

    SamplingTime = SamplingTime*1E6; % [us]
% define initial parameter
    maxTrapDepth = 2; ... What voltage corresponds to a trap depth of 28 uK?
    % Define Durations
    %deltaTime = 0.01; % us 
    RampUpDuration = 10;% [us]
    RampDownDuration = RampUpDuration;
    HoldTime = 57.5;
    ParityOperationTime = RampUpDuration+HoldTime+RampDownDuration;
    % - define Parity-Operation-Parameters:
    Imbalance = [1.2,0.9]; % rel. amplitude of Spin (up,minus) during HoldTime
    % - define Displacement-Operation-Parameters
    AmplitudesUp = [... % - ramping up
                        SinosoidalRamp(0,RampUpDuration  ,maxTrapDepth,maxTrapDepth*Imbalance(1),SamplingTime),... 
                        ... % - waiting
                        ones(1,ceil(HoldTime/SamplingTime))*maxTrapDepth*Imbalance(1) ...
                        ... % - ramping down
                        SinosoidalRamp(0,RampDownDuration,maxTrapDepth*Imbalance(1),maxTrapDepth,SamplingTime)];
    AmplitudesDown = [... % - ramping up
                        SinosoidalRamp(0,RampUpDuration  ,maxTrapDepth,maxTrapDepth*Imbalance(2),SamplingTime)... 
                        ... % - waiting
                        ones(1,ceil(HoldTime/SamplingTime))*maxTrapDepth*Imbalance(2) ...
                        ... % - ramping down
                        SinosoidalRamp(0,RampDownDuration,maxTrapDepth*Imbalance(2),maxTrapDepth,SamplingTime)];

    assert(length(AmplitudesDown) == length(AmplitudesUp),'Error: AmplitudeSpinDown must be the same length as Amplitude Spin up')
    
    DoReport = true;
    if DoReport
        disp(' ')
        disp(' ')
        disp(['VoltageRamps for Parity-Operation:'])
        disp(['    Number of points = ' num2str(numel(AmplitudesUp)) ])
        disp(['    Duration of Ramp = ' num2str(numel(AmplitudesUp)*SamplingTime) 'us'])
    end
    
end
