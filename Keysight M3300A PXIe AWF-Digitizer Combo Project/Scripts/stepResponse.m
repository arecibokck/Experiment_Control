function stepResponse(nCH) % delay in µs
%% Initialization
    sd = Devices.SignadynePLL.getInstance([2]); 
    mod = 'module2';
    sd.selectModule(mod); %turn on the specified module
    sd.init();
    
    %% Configure Waveform params
    V1 = 0.2;
    n1 =5000;
    delay1=0;

    V2 = 0.5;
    n2 = 5000;
    delay2 = 0;

    phase = 0;

    %% Configure the trigger lines
    nDAQ = nCH;
    trig = nCH;

    %% configure the DAQ
    sd.selectModule(mod);
    sd.flushDAQ();
    sd.data.points = 3000;
    sd.modules.(mod).DAQtriggerConfig(nDAQ,0,0,bitshift(1,trig));
    sd.modules.(mod).DAQconfig(nDAQ,sd.data.points,1,0,3);
    sd.startDAQ(nDAQ);

    %% configure modulation
    sd.modules.(mod).waveformFlush();
    sd.modules.(mod).modulationAmplitudeConfig(nCH, KeysightSD1.SD_ModulationTypes.AOU_MOD_AM, 1);
    sd.modules.(mod).modulationAngleConfig(nCH, KeysightSD1.SD_ModulationTypes.AOU_MOD_PHASE,180);



    %% Configure the queue
    trig = KeysightSD1.SD_TriggerModes.AUTOTRIG;

    values = [V1*ones(1,n1);zeros(1,n1)];
    newWave1 = KeysightSD1.SD_Wave( ...
    KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
    values(1,:), ...
    values(2,:));

    values = [V2*ones(1,n2);phase*ones(1,n2)];
    newWave2 = KeysightSD1.SD_Wave( ...
    KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
    values(1,:), ...
    values(2,:));

    sd.modules.(mod).waveformLoad(newWave1, 1);
    sd.modules.(mod).waveformLoad(newWave2, 2);

    err1 = sd.modules.(mod).AWGqueueWaveform(nCH, 1, trig, delay1, 10, 1);
    err2 = sd.modules.(mod).AWGqueueWaveform(nCH, 2, trig, delay2, 10, 1);

    if any([err1 err2]<0)
    disp('error queueing waveforms');
    end

    sd.writePIDport(3,1,(V2-(V2-V1)/2)*2^15) %configure trigger threshhold            
    sd.enablePID(nCH);
    sd.setChannelFrequency(nCH,80e6);
    sd.modules.(mod).AWGstartMultiple(255);
    sd.startExecution();

    %% Read and Plot data 
    sd.readDAQ(nDAQ);
    sd.plotData(nDAQ)
    fig = gcf;
    fs = sd.modules.(mod).channelFullScale(nCH);
    ylim([(V1-0.1)*fs,(V2+0.1)*fs]);

    % sd.readDAQ(1)
    % sd.plotData(1)
    % % figure(1);

    % figure(1)
    % clf;
    % plot((1:1:length(sd.data.read_data{nDAQ+1})), double(sd.data.read_data{nDAQ+1})/double(2^15),'.-');
    % title('Step response CH %i',nCH);


end