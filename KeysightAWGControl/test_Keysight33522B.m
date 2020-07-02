%% - create and test device
if true
    %% -create object
    DeviceID = 'TCPIP0::131.220.157.72::inst0::INSTR';
    WaveGen = Devices.KeysightWaveGen.K33522BDevice(DeviceID);
    %%
    Channel_1 = WaveGen.channels(1);
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
    
%%
    Channel_1.setFrequency(1+e04);
%%
    Channel_1.getFrequency
%%    
    Channel_1.setAmplitude(1);
%%
    Channel_1.setAmplitude('amplitude', 2, 'offset', 1);
%%
    Channel_1.setAmplitude('high', 2, 'low', 1);
%%
    Channel_1.getAmplitude('amplitude')
%%
    Channel_1.getAmplitude('offset')
%%
    Channel_1.getAmplitude('autorange')
%% 
    Channel_1.applyDCVoltage;
%%
    Channel_1.applyDCVoltage('offset', 1);
%%
    Channel_1.applyNoise;
%%
    Channel_1.applyPRBS;
%%
    Channel_1.applyPulse;
%%
    Channel_1.applyPulse('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
    Channel_1.applyRamp;
%%
    Channel_1.applyRamp('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
    Channel_1.applySineWave;
%%
    Channel_1.applySineWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
    Channel_1.applySquareWave
%%
    Channel_1.applySquareWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
    Channel_1.applyTriangleWave
%%
    Channel_1.applyTriangleWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
    Channel_1.setOutput('ON')
%%
    Channel_1.setOutput('OFF')
end

%%
if true
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

    %%
    WaveGen.send('OUTPut OFF')

end
