function obj = setAWGstate(obj, chan, amplitude, varargin)
    %AWG_STATE  Enforce immediate setting of RF output pin state
    %           i.e. it also activates the output channel on the selected
    %           module
    %
    % Inputs
    %       chan   channel number on selected module
    %  amplitude   amplitude of the RF output in percent of full level
    %      phase   (optional) phase of the RF output in degree, default: 0
    %       mode   (optional) DC or AC, default: AC
    assert(isnumeric(amplitude) && isscalar(amplitude), ...
               'Numeric number required as amplitude.');
    
    modulation = Signadyne.SD_ModulationTypes.AOU_MOD_AM;
    
    if nargin>3
        phase = varargin{1};
        
        assert(isnumeric(phase) && isscalar(phase), ...
               'Numeric number required as phase.');
        assert(isnumeric(phase) && isscalar(phase) && phase<=180 && phase>=-180, ...
               'Numeric number required as phase.');
    else
        phase = 0;
    end
    
    if nargin>4 % should be replaced by pin properties?
        switch(varargin{2})
            case 'DC'
                modulation = Signadyne.SD_ModulationTypes.AOU_MOD_OFFSET;
            case 'AC'
                assert(amplitude>=0, ...
                       'Non-negative number required for amplitude.');
            otherwise
                error('Unsupported mode');
        end
    end
            
    module = obj.selectedModule;
    
    assert(amplitude>=-1.5 && amplitude<=1.5, ...
           'Amplitude value (%f) is out of range.', amplitude);
    
    % deactivate channel
    if amplitude == 0
        fprintf('channel %i off', chan);
        obj.initializeChannel(chan);
    
    % activate channel
    else
        obj.modules.(module).waveformFlush();
        
        pin = obj.getVectorPin(obj.getVectorPinName(module,chan));
        
        obj.modules.(module).channelWaveShape(chan, Signadyne.SD_Waveshapes.AOU_SINUSOIDAL);
        obj.modules.(module).channelFrequency(chan, pin.offset(2));
        obj.modules.(module).channelAmplitude(chan, 0.0);
        obj.modules.(module).channelOffset(chan, 0.0);
        obj.modules.(module).channelPhase( chan, 0.0);
        obj.modules.(module).modulationAmplitudeConfig(chan, modulation, 1);
        obj.modules.(module).modulationAngleConfig(chan, Signadyne.SD_ModulationTypes.AOU_MOD_PHASE, 1);
%         disp(amplitude)
        % create waveform
        wave = Signadyne.SD_Wave(Signadyne.SD_WaveformTypes.WAVE_ANALOG_DUAL, ones(1,20)*amplitude, ones(1,20)*phase/360);
        if wave.getStatus() <= 0
            err = wave.getStatus();
            error('Error (%i) creating Waveform', err);
        end
        
        % sequence waveforms, ID=0 reserved for this purpose
        if obj.modules.(module).waveformLoad(wave, 0) <= 0
            error('Error loading Waveform');
        end
        
        err = obj.modules.(module).AWGqueueWaveform(chan,1,Signadyne.SD_TriggerModes.AUTOTRIG,0,100,0) ;
        if err<0
            error('Error queueing Waveform to AWG %i. Errorcode: %i', chan, err);
        end
        
        obj.modules.(module).AWGstart(chan);
    end
end %setAWGstate