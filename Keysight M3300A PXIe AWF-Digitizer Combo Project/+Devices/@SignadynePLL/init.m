function obj = init(obj, varargin)
% init Stops Waveform generation and deactivates all channels
%
% Input
%   exttrig(optional)  Adwin DigitalOut pin to trigger Signadyne device

% set external trigger pin
    
    if nargin>1
        exttrig = varargin{2};
        assert( isa(exttrig, 'DigitalOut'), ...
            'DigitalOut pin as external trigger pin required');

        obj.pins.trigger = exttrig;
    end
    
    % set default properties
%     obj.settings = obj.labSettings.defaultSettings;

    obj.configureAllInputChannels();

    % init modules
    for modName = fieldnames(obj.modules)'
        module = obj.modules.(modName{1});
        
        obj.selectModule(modName{1});
        
        module.waveformFlush();
        module.triggerIOconfig(KeysightSD1.SD_TriggerDirections.AOU_TRG_IN, KeysightSD1.SD_SyncModes.SYNC_NONE);
        module.triggerIOdirection(KeysightSD1.SD_TriggerDirections.AOU_TRG_IN);
        obj.setRegister();
        % init channels
        for chan = 0:3
            obj.initializeChannel(chan);
        end
        
    end

    % select active module
    if isempty(fieldnames(obj.modules))
        error('Empty list of modules.');
    end
    availableModules = fieldnames(obj.modules)';
    obj.selectModule(availableModules{1});

    obj.clearPins();

    obj.clearWaveforms();
    obj.writePIDport(3,12,0)
    
end %init