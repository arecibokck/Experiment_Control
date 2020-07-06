%% - create and test device
if true
    %% -create object
    DeviceID = 'TCPIP0::131.220.157.72::inst0::INSTR';
    WaveGen = Devices.KeysightWaveGen.K33522BDevice(DeviceID);
    %%
    Channel_1 = WaveGen.channels(1);
    Channel_2 = WaveGen.channels(2);
    %%
    Channel_1.ChannelNumber
    %% 
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
end


%% - test Channel
if true
   ChannelNumber = 1; 
%%
    WaveGen.channels(ChannelNumber).Amplitude
%%
    WaveGen.channels(ChannelNumber).Offset
%%
    WaveGen.channels(ChannelNumber).HighLevel
%%
    WaveGen.channels(ChannelNumber).LowLevel
%%
    WaveGen.channels(ChannelNumber).AutoRange
%%
    WaveGen.channels(ChannelNumber).TriggerCount
%%
    WaveGen.channels(ChannelNumber).TriggerDelay
%%
    WaveGen.channels(ChannelNumber).TriggerLevel
%%
    WaveGen.channels(ChannelNumber).TriggerSlope
%%
    WaveGen.channels(ChannelNumber).TriggerSource
%%
    WaveGen.channels(ChannelNumber).TriggerTimer
%%
    WaveGen.channels(ChannelNumber).BurstCycles
%%
    WaveGen.channels(ChannelNumber).BurstGatePolarity
%%
    WaveGen.channels(ChannelNumber).BurstInternalPeriod
%%
    WaveGen.channels(ChannelNumber).BurstMode
%%
    WaveGen.channels(ChannelNumber).BurstPhase
%%
    WaveGen.channels(ChannelNumber).BurstState
%%
    WaveGen.channels(ChannelNumber).Frequency
%%
    WaveGen.channels(ChannelNumber).FrequencyCenter
%%
    WaveGen.channels(ChannelNumber).FrequencyDwellTime
%%
    WaveGen.channels(ChannelNumber).FrequencyMode
%%
    WaveGen.channels(ChannelNumber).FrequencySpan
%%
    WaveGen.channels(ChannelNumber).FrequencyStart
%%
    WaveGen.channels(ChannelNumber).SweepHoldTime
%%
    WaveGen.channels(ChannelNumber).SweepReturnTime
%%
    WaveGen.channels(ChannelNumber).SweepSpacing
%%
    WaveGen.channels(ChannelNumber).SweepState
%%
    WaveGen.channels(ChannelNumber).SweepTime
%%
    WaveGen.channels(ChannelNumber).OutputLoad
%%
    WaveGen.channels(ChannelNumber).OutputMode
%%
    WaveGen.channels(ChannelNumber).OutputPolarity
%%
    WaveGen.channels(ChannelNumber).OutputState
%%
    WaveGen.channels(ChannelNumber).OutputSync
%%
    WaveGen.channels(ChannelNumber).OutputSyncMode
%%
    WaveGen.channels(ChannelNumber).OutputSyncPolarity
%%
    WaveGen.channels(ChannelNumber).OutputSyncSource
%%
    WaveGen.channels(ChannelNumber).OutputTriggerSlope
%%
    WaveGen.channels(ChannelNumber).OutputTriggerSource
%%
    WaveGen.channels(ChannelNumber).OutputTriggerState
%%
    WaveGen.channels(ChannelNumber).FunctionType
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunction
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionAdvanceMethod
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFrequency
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionNumberOfPoints
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeriod
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate
%%
    WaveGen.channels(ChannelNumber).NoiseFunctionBandwidth
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionBitRate
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionSequenceType
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionTransition
%%
    WaveGen.channels(ChannelNumber).PulseFunctionBothEdges
%%
    WaveGen.channels(ChannelNumber).PulseFunctionDutyCycle
%%
    WaveGen.channels(ChannelNumber).PulseFunctionHoldTime
%%
    WaveGen.channels(ChannelNumber).PulseFunctionLeadingEdge
%%
    WaveGen.channels(ChannelNumber).PulseFunctionPeriod
%%
    WaveGen.channels(ChannelNumber).PulseFunctionTrailingEdge
%%
    WaveGen.channels(ChannelNumber).PulseFunctionWidth
%%
    WaveGen.channels(ChannelNumber).RampFunctionSymmetry
%%
    WaveGen.channels(ChannelNumber).SquareFunctionDutyCycle
%%
    WaveGen.channels(ChannelNumber).DataAverage
%%
    WaveGen.channels(ChannelNumber).DataCrestFactor
%%
    WaveGen.channels(ChannelNumber).DataPeakToPeak
%%
    WaveGen.channels(ChannelNumber).DataPoints    
%% 
   WaveGen.channels(ChannelNumber).applyDCVoltage;
%%
   WaveGen.channels(ChannelNumber).applyDCVoltage('offset', 1);
%%
   WaveGen.channels(ChannelNumber).applyNoise;
%%
   WaveGen.channels(ChannelNumber).applyPRBS;
%%
   WaveGen.channels(ChannelNumber).applyPulse;
%%
   WaveGen.channels(ChannelNumber).applyPulse('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applyRamp;
%%
   WaveGen.channels(ChannelNumber).applyRamp('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applySineWave;
%%
   WaveGen.channels(ChannelNumber).applySineWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applySquareWave
%%
   WaveGen.channels(ChannelNumber).applySquareWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applyTriangleWave
%%
   WaveGen.channels(ChannelNumber).applyTriangleWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
    %% - OutputState 
    newVal = 'on'; % 1  | 0 | 'On' | 'Off' 
    WaveGen.channels(ChannelNumber).OutputState = newVal;
    WaveGen.channels(ChannelNumber).OutputState
end

%% - test external trigger
if true
    %% - Arbitrary waveform example 
    ChannelNumber = 2;
    WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
    WaveGen.channels(ChannelNumber).Amplitude = 3;
    WaveGen.channels(ChannelNumber).Offset    = 1;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
    %WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
    %WaveGen.channels(ChannelNumber).OutputState = 'ON';
    
    % - set trigger source
    WaveGen.channels(ChannelNumber).TriggerSource = 'EXT';
    % - set trigger level
    %WaveGen.channels(1).TriggerLevel; Unable to set trig level? Throws
    %error, option not available on device? option could not be accessed it locally
    % - set trigger edge 
    WaveGen.channels(ChannelNumber).TriggerSlope = 'POS';
    % - set burst mode
    WaveGen.channels(ChannelNumber).BurstMode = 'TRIG';
    % - set number of bursts
    WaveGen.channels(ChannelNumber).BurstCycles = 2;
    % - start execution
    
end


%%  - Examples From Manual
if true
    %% - Arbitrary waveform example 
    ChannelNumber = 2;
    WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
    WaveGen.channels(ChannelNumber).setAmplitude('amplitude', 3, 'offset', 1);
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

%%
if true
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 10e+03;
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter = 'OFF';
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak = 10;
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc_ramp, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc5v, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc2_5v, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc0v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0');
    WaveGen.wait;
    %WaveGen.channels(ChannelNumber).createDataSequence('#3128"seqExample","dc_ramp",0,once,highAtStart,5,"dc5v",2,repeat,maintain,5,"dc2_v",2,repeat,lowAtStart,5,"dc0v",2,repeat,maintain,5');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc_ramp';
    WaveGen.channels(ChannelNumber).storeData('INT:\dc_ramp.arb');
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
