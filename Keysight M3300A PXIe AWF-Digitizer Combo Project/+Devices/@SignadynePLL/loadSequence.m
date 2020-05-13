function obj = loadSequence(obj, seq)
%loadSequence   Compiles and sends given sequence to Signadyne device.
%
%   Inputs
%       seq   Sequence object

% todo: check that pll reference pin is never changed
% todo: include optimal control
% todo: add mutex pins
    assert( isa(seq, 'Sequence'), ...
        'Sequence object required');
    
    %% find neccessary trigger events for the signadyne device
    trigName = obj.labSettings.defaultPins.trigger.toString();
    if isfield(seq.pin, trigName)
        obj.pins.trigger = seq.pin.(trigName);
        triggerEdges = obj.pins.trigger.getEdges('rising');
        
        if ~isempty(obj.pins.trigger.values) && obj.pins.trigger.values(1)>0
            triggerEdges = [triggerEdges];
        end
        
        if isempty(triggerEdges)
            fprintf('No external SD trigger signal found in sequence. Use software triggering instead.\n');
        else
            fprintf('Found %i SD triggers at time (s): %s\n', length(triggerEdges), num2str(triggerEdges));
        end
    else
        obj.pins.trigger = DigitalOut(obj.pins.trigger);
        triggerEdges = [];
        warning('Trigger pin not found in sequence. Use software triggering instead.');
    end
    
    
    %% flush old pins and loadedWaveforms
    for module = fieldnames(obj.modules)'
        for i = 1:length(obj.modules.(module{:}))
            obj.compiledPins.(module{:}) = [];
            obj.modules.(module{:}).waveformFlush();
            obj.loadedWaveforms.(module{:}) = [];
        end
    end

    obj.nextWaveformID = 1; 
    
    %% find vector pins in sequence
    %  - run through all signadyne pins and try to find them in the given sequence
    
    for k = 1:length(obj.pins.vector)
        pinName = obj.pins.vector{k,3}.toString();
        if ~isfield(seq.pin, pinName)
            continue;
        end
        
        module = obj.pins.vector{k,1};
        chan   = obj.pins.vector{k,2}+1;
        pin    = seq.pin.(pinName);
        
        % adapt new evolution and settings
        obj.pins.vector{k,3} = seq.pin.(pinName);
        obj.compiledPins.(module) = [obj.compiledPins.(module), chan];

        % set modulations 
%         max_vals = pin.getLargestValues();       %% not used, talk to
%         stefan...
        maxAmplitudeValue = 1;%obj.calculateMagnitude(max_vals(1));
        
        switch pin.amplitudeModulation
            case 'AC'
                obj.modules.(module).modulationAmplitudeConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_AM, 1);
            case 'DC'
                obj.modules.(module).modulationAmplitudeConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_OFFSET, 1);
            otherwise
                error('Amplitude modulation type ''%s'' of pin %s unknown.', pin.amplitudeModulation, pin.toString());
        end
%         fprintf('Amplitude modulation (%s) set to ''%s'': %f\n', pin.toString(), pin.amplitudeModulation, maxAmplitudeValue);
        
        switch pin.angleModulation
            case 'phase'
                maxAngleValue = 1;
                obj.modules.(module).modulationAngleConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_PHASE, 180);
            case 'frequency'
                maxAngleValue = 1;
                obj.modules.(module).modulationAngleConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_FM, 1e6);
            otherwise
                error('Angle modulation type ''%s'' of pin %s unknown.', pin.angleModulation, pin.toString());
        end
%         fprintf('Angle modulation (%s) set to ''%s'': %f\n', pin.toString(), pin.angleModulation, maxAngleValue);
        
        
        %% split waveshapes if necessary due to triggering events
        triggerEventIds = pin.splitWaveformsAtTimes(triggerEdges);
        

        %% creating waveshapes for each pin
        mapID = struct('sdId', [], 'pinId', []); %mapping from pin waveform ID to signadynePLL waveform ID
        for wtype = fieldnames(pin.waveformList)'
            if isempty(pin.waveformList.(wtype{:})) % continue for waveform ID
                continue;
            end
            
%             if ~isfield(obj.waveforms,wtype{:})
            obj.waveforms.(wtype{:}) = [];
%             else 
            
            for pinWshape = pin.waveformList.(wtype{:})
                wave = []; % loaded waveshape/waveform object
                
                % test if waveshape alreday exists
                switch wtype{:}
                    case 'arbitrary'
                        % nothing to do since hard to compare
                        wave = [];
                    case 'compensation'
                        % nothing to do since hard to compare
                        wave = [];
                        
                    case {'linear', 'sinusoidal'}
                        res = 1e-10;
                        for wshape = obj.waveforms.(wtype{:})
                            if all(abs(wshape.initialState-pinWshape.initialState)<res) ...
                                    && all(abs(wshape.finalState-pinWshape.finalState)<res) ...
                                    && abs(wshape.duration-pinWshape.duration)<res ...
                                    && abs(wshape.samplingTime-pinWshape.samplingTime)<res ...
                                    
%                                     && abs(wshape.amplitudeMagnification-maxAmplitudeValue)<res
                                
                                wave = wshape; % loaded waveshape/waveform object
                                mapID.sdId(end+1) = wave.id;
                                mapID.pinId(end+1) = pinWshape.id;
                                break;
                            end
                        end
                        
                    case 'state'
                        for wshape = obj.waveforms.(wtype{:})
                            res = 1e-10;
                            if all(abs(wshape.state-pinWshape.state)<res) ...
                                    && abs(wshape.duration-pinWshape.duration)<res 
%                                     && abs(wshape.amplitudeMagnification-maxAmplitudeValue)<res
                                
                                wave = wshape; % loaded waveshape/waveform object
                                mapID.sdId(end+1) = wave.id;
                                mapID.pinId(end+1) = pinWshape.id;
                                break;
                            end
                        end
                        
                    case 'vector'
                        for wshape = obj.waveforms.(wtype{:})
                            res = 1e-10;
                            if all(abs(wshape.times<pinWshape.times)<res) ...
                                    && all(abs(wshape.states(:)<pinWshape.states(:))<res)
%                                     && abs(wshape.amplitudeMagnification-maxAmplitudeValue)<res
                                
                                wave = wshape; % loaded waveshape/waveform objects
                                mapID.sdId(end+1) = wave.id;
                                mapID.pinId(end+1) = pinWshape.id;
                                break;
                            end
                        end
                        
                    otherwise
                        error('unsupported waveform type');
                end % switch
                
                % generate new waveform for signadyne if necessary
                if isempty(wave)
                    wave = pinWshape;
%                     wave.amplitudeMagnification = maxAmplitudeValue; % add new field to indicate amplitude modulation magnitude
                    wave.id = obj.nextWaveformID;
                    
                    switch wtype{:}
                        case {'arbitrary', 'linear', 'sinusoidal', 'vector'}
                            values = pin.sampleWaveform(wave);
                            wave.cycles = 1;
                        case 'compensation'
                            values = wave.functionHandle;
                            if mod(length(values),5) ~= 0
                                values =  [values values(:,end)*ones(1,5-mod(length(values),5))];
                            end
                            wave.cycles = 1; 
                        case 'modulation'
                            values = pin.sampleWaveform(wave,wave.samples);
                            wave.cycles = wave.duration*wave.frequency;
                        case 'state'
                            if wave.duration == 0 %ignore states queued without a duration...
                                wave.duration = pin.timeOffset - pin.lastTime;
                            end
                            waves = obj.calculateStateWaveforms(round(2*wave.duration/pin.smallestSamplingTime));
                            if numel(waves)>1
                                for idx = 1:numel(waves)
                                    waves(idx).samplingTime = waves(idx).samplingTime.*pin.smallestSamplingTime; % rescale to seconds
                                end
                                wave.delay = waves(1).delay;
                                wave.samplingTime = waves(1).samplingTime;
                                wave.cycles = waves(1).cycles;
                                wave.samples = waves(1).samples;
                                wave.additionalWaveforms = waves(2:end);
                                
                                for idx = 1:numel(wave.additionalWaveforms)
                                    values = ones(2,wave.additionalWaveforms(idx).samples).*wave.state;
                                    
                                    if isprop(obj,'DebugObject')
                                        newWave = Devices.SD_WaveDebug(...
                                        KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
                                        values(1,:), ...
                                        mod(values(2,:)/maxAngleValue+(2^15-1)/2^15,2)-(2^15-1)/2^15); % waveform type, points witihn range [-1 +1) = [-180degree +180degree)
                                    else
                                        newWave = KeysightSD1.SD_Wave( ...
                                        KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
                                        values(1,:), ...
                                        mod(values(2,:)/maxAngleValue+(2^15-1)/2^15,2)-(2^15-1)/2^15); % waveform type, points witihn range [-1 +1) = [-180degree +180degree)
                                    end
                                    obj.nextWaveformID = obj.nextWaveformID + 1;
                                    wave.additionalWaveforms(idx).wave = newWave;
                                    wave.additionalWaveforms(idx).id = obj.nextWaveformID;
                                end
                            else
                                wave.delay = waves.delay;
                                wave.samplingTime = waves.samplingTime*pin.smallestSamplingTime;
                                wave.cycles = waves.cycles;
                                wave.samples = waves.samples;
                                wave.additionalWaveforms = struct([]);
                            end
                            values = ones(2,wave.samples).*wave.state;
                        otherwise
                            error('waveshape type ''%s'' not supported.', wtype{:});
                    end
                    values = [values(1,:); mod(values(2,:)/maxAngleValue+1,2)-1];
                    % -
                    if isprop(obj,'DebugObject')
                        wave.wave = Devices.SD_WaveDebug(...
                                       KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
                                       values(1,:), ...
                                       values(2,:)); % waveform type, points witihn range [-1 +1) = [-180degree +180degree)
                    else
                        wave.wave = KeysightSD1.SD_Wave( ...
                                       KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ...
                                       values(1,:), ...
                                       values(2,:)); % waveform type, points witihn range [-1 +1) = [-180degree +180degree)
                    end
                    obj.nextWaveformID = obj.nextWaveformID + 1;

                    obj.waveforms.(wtype{:}) = [obj.waveforms.(wtype{:}) wave];
                    newMappingElem = struct( ...
                                       'id',wave.id, ...
                                       'type',wtype{:}, ...
                                       'listElement',numel(obj.waveforms.(wtype{:})));
                    obj.waveformMapping = [obj.waveformMapping, newMappingElem];
                    mapID.sdId(end+1) = wave.id;
                    mapID.pinId(end+1) = pinWshape.id;
                end
                
                % load to module if necessary
                % since for optimal control, we need to convolute the
                % amplitude/phase with the corresponding transfer function
                % this should later be shifted to separate loop
                if ~ismember(wave.id, obj.loadedWaveforms.(module))
                    if wave.wave.getStatus()>=0
                        if obj.modules.(module).waveformLoad(wave.wave, wave.id) >= 0
                            obj.loadedWaveforms.(module) = [obj.loadedWaveforms.(module) wave.id];
                        else
                            error('Error loading Waveform #%i', wave.id);
                        end
                    else
                        error('Error creating Waveform #%i: status %i', wave.id, wave.wave.getStatus());
                    end
                end
                
                % more loading required for splitted waveforms in case of
                % states
                if isfield(wave,'additionalWaveforms')
                    for additionalWave = wave.additionalWaveforms
                        if ~ismember(additionalWave.id, obj.loadedWaveforms.(module))
                            if additionalWave.wave.getStatus()>=0
                                if obj.modules.(module).waveformLoad(additionalWave.wave, additionalWave.id) >= 0
                                    obj.loadedWaveforms.(module) = [obj.loadedWaveforms.(module) additionalWave.id];
                                else
                                    error('Error loading Waveform #%i', additionalWave.id);
                                end
                            else
                                error('Error creating Waveform #%i: status %i', additionalWave.id, additionalWave.getStatus());
                            end
                        end
                    end
                end
                
            end
        end
        
        
        %% queue by looping through time vector
        delay = 0;
        timeOffset = 0; 
%         carryDelay = 0; 
        for kk = 1:numel(pin.times)
            % set triggers
             if kk==1  % trigger for first waveform
                switch obj.settings.triggerMode
                    case 'EXTTRIG'
                        trig = KeysightSD1.SD_TriggerModes.EXTTRIG;
                        trigger = 'ext(first)';
                    case 'AUTOTRIG'
                        trig = KeysightSD1.SD_TriggerModes.AUTOTRIG;
                        trigger = 'auto';
                    case 'SWHVITRIG'
                        trig = KeysightSD1.SD_TriggerModes.SWHVITRIG;
                        trigger = 'auto';
                    otherwise
                        error('unknown trigger mode ''%s'' ', obj.settings.triggerMode);
                end

%              elseif kk==2  % trigger for first waveform
%                 switch obj.settings.triggerMode
%                     case 'EXTTRIG'
%                         trig = KeysightSD1.SD_TriggerModes.EXTTRIG;
%                         trigger = 'ext(first)';
%                     case 'AUTOTRIG'
%                         trig = KeysightSD1.SD_TriggerModes.EXTTRIG;
%                         trigger = 'ext(test)';
%                     case 'SWHVITRIG'
%                         trig = KeysightSD1.SD_TriggerModes.SWHVITRIG;
%                         trigger = 'auto';
%                     otherwise
%                         error('unknown trigger mode ''%s'' ', obj.settings.triggerMode);
%                 end

            elseif any(kk==triggerEventIds)  % check for trigger events
                trig = KeysightSD1.SD_TriggerModes.EXTTRIG;
                trigger = 'ext(sdTrig found)';
                
            else  % default trigger for waveforms in the middle of a sequence
                trig = KeysightSD1.SD_TriggerModes.AUTOTRIG;
                trigger = 'auto';
            end
            
            %% queueing
            wID = mapID.sdId(find([mapID.pinId]==pin.waveforms(kk), 1, 'first'));
            idx = find([obj.waveformMapping.id]==wID, 1, 'first');
            wave = obj.waveforms.(obj.waveformMapping(idx).type)(obj.waveformMapping(idx).listElement);
            
        
            if strcmp(wave.type, 'state')
                if wave.samples == 0
                    wave.delay = delay + wave.delay; 
                    delay = wave.delay; 
                    continue;
                end
            end
                
            if isfield(wave,'delay')
                delayNew = wave.delay;
            else
                delayNew = 0; 
            end
            
            prescaler = round(wave.samplingTime/pin.smallestSamplingTime);
%             prescaler = wave.samplingTime;
            if strcmp(wave.type,'compensation')  % add the delay of the compensationramp at this point
                delay = delay + round(pin.partnerDelay);
            end
            
            if kk == numel(pin.times)   % This condition is added herre such that the set point of the last waveform is maintiained (in order to keep the AOMs running and the intensity lock from misbehaving
                wave.cycles = 0;
            end
            try
                err = obj.modules.(module).AWGqueueWaveform(chan, wID, trig, delay, wave.cycles, prescaler); %queue WF with triggermode, delay=0, cycles and prescaler (:=sampling rate);
            catch
                err = -1;
            end
            timeOffset = wave.cycles*wave.samplingTime*wave.samples+delay*1e-8;
            
            if err < 0
                disp(['Waveform with ID ' num2str(wID) ' failed to queue in Channel ' num2str(chan)...
                    '. Type: ' wave.type ', cycles: ' num2str(wave.cycles) ', delay: ' num2str(delay) ', prescaler: ' num2str(prescaler) ',duration: ' num2str(wave.duration)  ',trigger:' trigger...
                    '. Pin Waveform #' num2str(kk) ' of ' pin.name])
                error(['Error queueing Waveform ' num2str(wID) ' to AWG ' num2str(chan)...
                    '. Errorcode: ' num2str(err)])
            elseif obj.settings.debug == 1 
                disp(['Waveform with ID ' num2str(wID) ' queued in Channel ' num2str(chan)...
                    '. Type: ' wave.type ', cycles: ' num2str(wave.cycles) ', delay: ' num2str(delay) ', prescaler: ' num2str(prescaler) ',duration: ' num2str(wave.duration)  ',trigger:' trigger...
                    '. Pin Waveform #' num2str(kk) ' of ' pin.name])
                
            end
            delay = delayNew;

            if isfield(wave, 'additionalWaveforms') % splitted state waveforms require more queueing
%                 disp('hi');
                for additionalWave = wave.additionalWaveforms
                    prescaler = round(additionalWave.samplingTime/pin.smallestSamplingTime);
                    try
                        err = obj.modules.(module).AWGqueueWaveform(chan, additionalWave.id, KeysightSD1.SD_TriggerModes.AUTOTRIG, additionalWave.delay, additionalWave.cycles,prescaler);
                    catch
                        err = -1;
                    end
                    timeOffset = timeOffset + additionalWave.cycles*additionalWave.samplingTime*additionalWave.samples+additionalWave.delay*1e-8;

                    if err < 0
                        disp(['Waveform with ID ' num2str(additionalWave.id) 'failed to queue in Channel ' num2str(chan)...
                            '. Type: ' wave.type ', cycles: ' num2str(additionalWave.cycles) ', delay: ' num2str(additionalWave.delay) ', prescaler: ' num2str(prescaler) ',duration: ' num2str(wave.duration)  ',trigger:' trigger...
                            '. Pin Waveform #' num2str(pin.values(kk)) ' of ' pin.name])
                        error(['Error queueing Waveform ' num2str(additionalWave.id) ' to AWG ' num2str(chan)...
                            '. Errorcode: ' num2str(err)])
                    elseif obj.settings.debug == 1 
                        disp(['Additional waveform with ID ' num2str(additionalWave.id) ' queued in Channel ' num2str(chan)...
                            '. Type: ' wave.type ', cycles: ' num2str(additionalWave.cycles) ', delay: ' num2str(additionalWave.delay) ', prescaler: ' num2str(prescaler) ',duration: ' num2str(wave.duration)  ',trigger: Auto'...
                            '. Pin Waveform #' num2str(pin.values(kk)) ' of ' pin.name])     
                    end
                end
            end
            
        end %time loop

    end %pin loop
    
end   %loadseq
