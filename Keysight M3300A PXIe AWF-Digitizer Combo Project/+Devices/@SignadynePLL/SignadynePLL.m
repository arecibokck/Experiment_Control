classdef SignadynePLL < Devices.Device
    %SignadynePLL This class is a handles compiling and executing sequence
    %              on Signadyne (now Keysight) system
    
    properties (SetAccess = private)
        labSettings = struct();
        modules = struct();   % list of used modulesmod((values(2,:)+pin.offset(3))/maxAngleValue+1,2)-1
        pins = struct();      % list of pins for used modules
        
        selectedModule = '';  % name of the selected (=active) module       
        
        compiledPins = struct();  % struct of modules with list of used channels of last compiled sequence
        
        waveforms =  struct(); % list of assigned waveforms
        
        nextWaveformID = 1; % index 0 reserved for setAWGstate
        waveformMapping = struct( ... % maps waveform id to position in waveforms
                                  'id', [], ...
                                  'type', [], ...
                                  'listElement', []);
        
        loadedWaveforms = struct();  % list of assigned waveforms to specific modules
    end %properties
    
    properties
        microwaveFrequency = 162.6e6; % todo: temporary bug fix
                
        data = struct()
    end %properties
    
    properties (Constant, Hidden)
%         defaultModules = struct('slots',             [2,            5,        7],  ... available modules slots and parts
%                                 'parts', {{'SD-PXE-AIO', 'SD-PXE-AIO', 'M3300A'}});
%         
        ref_freq_factor = 0.023283064365386962890625;
        ref_phase_factor = 11930464.70833333333;
   
                              
%         defaultPins = struct( ... % list of default values for pins
%                               'vector', struct( ... vector pins, pins names related to phase locks are hard coded within this class
%                                           'module2', ...
%                                             {{VectorOut('HDT1L', 'phase', 'AC', [0; 80e6; 0], 'HDT, beam 1, left handed circular polarization'), ...
%                                               VectorOut('HDT1R', 'phase', 'AC', [0; 80e6; 0], 'HDT, beam 1, left handed circular polarization'), ...
%                                               VectorOut('HDT2',  'phase', 'AC', [0; 80e6; 0], 'Horizontal dipole trap, beam 2'),                 ... fixed polarization beam
%                                               VectorOut('VDT',   'phase', 'AC', [0; 80e6; 0], 'Vertical dipole trap')}},                         ...
%                                           'module7', ...
%                                             {{VectorOut('m1ch0', 'phase', 'AC', [0; 80e6; 0],'none'),   ... not used
%                                               VectorOut('m1ch1', 'phase', 'AC', [0; 80e6; 0],'none'),   ... not used
%                                               VectorOut('m1ch2', 'phase', 'AC', [0; 80e6; 0],'none'),   ... not used
%                                               VectorOut('m1ch3', 'frequency', 'AC', [0; 80e6; 0],'none')}}, ... not connected, BE CAREFULL!
%                                           'module5', ...
%                                             {{VectorOut('HDT3L',     'phase', 'AC', [  0;  80e6; 0], 'HDT, beam 3, left handed circular polarization'),  ... next to microwave amplifier
%                                               VectorOut('HDT3R',     'phase', 'AC', [ 0;  80e6; 0], 'HDT, beam 3, right handed circular polarization'), ... next to microwave amplifier
%                                               VectorOut('PLLref',    'phase', 'AC', [1.5; 150e6; 0], 'mixing reference for phase lock, amplitude 1.5V'), ... name reserved for reference pin, do not change!
%                                               VectorOut('microwave', 'frequency', 'AC', [  0; 159e6; 0], 'microwave frequency mixed with 9.042631770GHz')}}  ...
%                                         ), ... 
%                                'trigger', DigitalOut('sdTrig', 'Trigger for Signadyne modules') ...
%                             );
%                         
%         defaultSettings = struct(...
%                             'triggerMode', 'EXTTRIG', ... options are 'EXTTRIG', 'AUTOTRIG',                    'SWHVITRIG'
%                             'debug',        0, ...
%                             'module2', struct( ... settings for module
%                                          'intensityLock', ... for individual RF channels
%                                            {{struct( ... channel 0
%                                                      'P', 35000, ...
%                                                      'I',  1600, ...
%                                                      'D',     0, ...
%                                                      'automticStart', true), ...
%                                              struct( ... channel 1
%                                                      'P', 35000, ...
%                                                      'I',  1600, ...
%                                                      'D',     0, ...
%                                                      'automticStart', true), ...
%                                              struct( ... channel 2
%                                                      'P', 35000, ...
%                                                      'I',  1600, ...
%                                                      'D',     0, ...
%                                                      'automticStart', true), ...
%                                              struct()}}, ...
%                                          'phaseLock', ... for individual RF channels
%                                            {{struct( ... channel 0
%                                                      'P', 16000,  ...
%                                                      'I',  6000,  ...
%                                                      'D',  0,  ...
%                                                      'phaseRange',      40,  ...
%                                                      'frequencyRange',  40,  ...
%                                                      'accumulatorSize', 20), ...
%                                              struct( ... channel 1
%                                                      'P', 16000,  ...
%                                                      'I',  6000,  ...
%                                                      'D',  0,  ...
%                                                      'phaseRange',      40,  ...
%                                                      'frequencyRange',  40,  ...
%                                                      'accumulatorSize', 20), ...
%                                               struct(),  ...
%                                               struct()}}, ...
%                                          'firmwareFile', '5_3.sbp', ... TODO: give precise path to signadyne class
%                                          'inputConfig', struct( ... for individual input channels
%                                                           'channel0', [0, 10, 0, 0], ...
%                                                           'channel1', [1, 10, 0, 0], ...
%                                                           'channel2', [2, 10, 0, 0], ...
%                                                           'channel6', [6, 0.24, 1, 0], ...
%                                                           'channel7', [7, 0.24, 1, 0]), ...
%                                          'registerValues', [0,...  % 0: PLL always on (don't use if not needed)
%                                                             0,...  % 1: PLL reference value for triggering 
%                                                             0,...% 2:  PLL threshholding reference
%                                                             -0.01*2^15,...  % 3: Iput Offset CH 0 
%                                                             0,...  % 4: swicht between phase/lock signal monitoring of DAQ 6/7
%                                                             -0.01*2^15 ,...  % 5: Input Offset Ch 1 
%                                                             -0.01*2^15,...  % 6: Input Offset CH 2 
%                                                             0,...  % 7: switch Ch 2 working mode (0 = normal phase/freq modulation)
%                                                             0,...  % 8: enable LUT CH0 
%                                                             0,...  % 9: enable LUT CH1
%                                                             0,...  % 10: enable LUT CH2
%                                                             0,...  % 11: enable AWG data acquisition on DAQ 4,5
%                                                             1]...  % 12: enable triggerIO connection to PXItrigger0
%                                        ), ...
%                             'module7', struct( ... lock settings for module
%                                          'intensityLock', ... for individual RF channels
%                                             {{struct(),    ...
%                                               struct(),    ...
%                                               struct(),    ...
%                                               struct()}},   ...
%                                          'phaseLock',   ... for individual RF channels
%                                             {{struct( ... channel 0
%                                                       'P', 16000,  ...
%                                                       'I',  6000,  ...
%                                                       'D',  0,  ...
%                                                       'phaseRange',      50,  ...
%                                                       'frequencyRange',  50,  ...
%                                                       'accumulatorSize', 30),  ...
%                                               struct( ... channel 0
%                                                       'P', 16000,  ...
%                                                       'I',  6000,  ...
%                                                       'D',  0,  ...
%                                                       'phaseRange',      50,  ...
%                                                       'frequencyRange',  50,  ...
%                                                       'accumulatorSize', 30),  ...
%                                               struct(),  ...
%                                               struct()}}, ...
%                                          'firmwareFile', '5_3.sbp', ... TODO: give precise path to signadyne class
%                                          'inputConfig',  struct( ... for individual input channels
%                                                           'channel0', [0, 10, 0, 0], ...
%                                                           'channel1', [1, 10, 0, 0], ...
%                                                           'channel2', [2, 10, 0, 0], ...
%                                                           'channel6', [6, 0.7, 1, 0], ...
%                                                           'channel7', [7, 0.7, 1, 0]), ...
%                                          'registerValues', [0,...  % 0: PLL always on (don't use if not needed)
%                                                             0.2*2^15,...  % 1: PLL reference value for triggering 
%                                                             0,...% 2:  PLL threshholding reference
%                                                             0,...  % 3: Iput Offset CH 0 
%                                                             0,...  % 4: swicht between phase/lock signal monitoring of DAQ 6/7
%                                                             0,...  % 5: Input Offset Ch 1 
%                                                             0,...  % 6: Input Offset CH 2 
%                                                             0,...  % 7: switch Ch 2 working mode (0 = normal phase/freq modulation)
%                                                             0,...  % 8: enable LUT CH0 
%                                                             0,...  % 9: enable LUT CH1
%                                                             0,...  % 10: enable LUT CH2
%                                                             0,...  % 11: enable AWG data acquisition on DAQ 4,5
%                                                             0]...  % 12: enable triggerIO connection to PXItrigger0
%                                        ), ...
%                             'module5', struct( ...
%                                          'intensityLock', ... for individual RF channels
%                                             {{struct( ... channel 0
%                                                       'P', 0,  ...
%                                                       'I', 800,  ...
%                                                       'D', 0),  ...
%                                               struct( ... channel 1
%                                                       'P', 0,  ...
%                                                       'I', 1200,  ...
%                                                       'D', 0), ...
%                                               struct(),  ...
%                                               struct()}}, ...
%                                          'phaseLock', ... for individual RF channels
%                                             {{struct( ... channel 0
%                                                       'P', 16000,  ...
%                                                       'I',  6000,  ...
%                                                       'D',  0,  ...
%                                                       'phaseRange',      50,  ...
%                                                       'frequencyRange',  50,  ...
%                                                       'accumulatorSize', 30), ...
%                                               struct( ... channel 1
%                                                       'P', 16000,  ...
%                                                       'I',  6000,  ...
%                                                       'D',  000,  ...
%                                                       'phaseRange',      50,  ...
%                                                       'frequencyRange',  50,  ...
%                                                       'accumulatorSize', 30), ...
%                                               struct(),  ...
%                                               struct()}}, ...
%                                          'firmwareFile', '5_3.sbp', ... TODO: give precise path to signadyne class
%                                          'inputConfig', struct( ... for individual input channel
%                                                           'channel0', [0, 10, 0, 0], ...
%                                                           'channel1', [1, 10, 0, 0], ...
%                                                           'channel6', [6, 0.21, 1, 0], ...
%                                                           'channel7', [7, 0.21, 1, 0]) , ...
%                                          'registerValues', [0,...  % 0: PLL always on (don't use if not needed)
%                                                             0,...  % 1: PLL reference value for triggering 
%                                                             0,...% 2:  PLL threshholding reference
%                                                             -0.01*2^15,...  % 3: Iput Offset CH 0 
%                                                             0,...  % 4: swicht between phase/lock signal monitoring of DAQ 6/7
%                                                             -0.01*2^15,...  % 5: Input Offset Ch 1 
%                                                             0,...  % 6: Input Offset CH 2 
%                                                             0,...  % 7: switch Ch 2 working mode (0 = normal phase/freq modulation)
%                                                             0,...  % 8: enable LUT CH0 
%                                                             0,...  % 9: enable LUT CH1
%                                                             0,...  % 10: enable LUT CH2
%                                                             0,...  % 11: enable AWG data acquisition on DAQ 4,5
%                                                             0]...  % 12: enable triggerIO connection to PXItrigger0
%                                        ) ...
%                           );
            
    end %properties
    
    methods (Access = protected)
        function obj = SignadynePLL(slot, varargin)
            %SignadynePLL Default constructor
            %
            %  Input:
            %      slot  array of used module numbers
            %     debug  (optional) set true if simulator class
            %            'AdwinDebug' should be used to implement
            %            functionality
            
            p = inputParser();
            p.addOptional('debug', false, @islogical);  
            p.parse(varargin{:});
            
            if p.Results.debug
                copyfile('+Devices/SignadyneConstants.m', './Signadyne.m');
                NET.addAssembly('C:\Program Files (x86)\Keysight\SD1\Libraries\VisualStudio.NET\KeysightSD1.dll');
            else
                % Load Visual Studio Library
                % Note: In former Matlab versions a strange error occurs if
                % this library is not defined before object is loaded.
                NET.addAssembly('C:\Program Files (x86)\Keysight\SD1\Libraries\VisualStudio.NET\KeysightSD1.dll');
            end
            
            
                
            obj.labSettings = obj.loadSettings();
            % assign and open modules
            for k = slot
                idx = find(obj.labSettings.defaultModules.slots==k, 1, 'first');
                module = ['module' num2str(k)];
                
                if isempty(idx)
                   error('module number not found'); 
                end
                
                % - load debug objects, if p.Results.debug
                if p.Results.debug
                    obj.modules.(module) = Devices.SD_AIODebug;
                else
                    obj.modules.(module) = KeysightSD1.SD_AIO();
                end
                if obj.modules.(module).isOpen()
                    warning('Signadyne Module is still open.');
                end
                
                if obj.modules.(module).open(obj.labSettings.defaultModules.parts{idx}, 0, k) < 0
                   error('Failed to open Signadyne module in slot %i.', k); 
                end
                
                fprintf('Signadyne module opened in slot %i.\n', k);
                
                if k==slot(1)
                    obj.selectedModule = module;
                end
            end
            obj.labSettings = obj.loadSettings();
            obj.settings = obj.labSettings.defaultSettings;
            obj.init();
            disp('Signadyne device started.');
        end %SignadynePLL
    end
    
    methods (Static)
        function singleObj = getInstance(slot)
            % methods to realize singelton behaviour
            persistent localObj;
            
            if isempty(localObj) || ~isvalid(localObj)
                localObj =  Devices.SignadynePLL(slot);
            end
            singleObj = localObj;
        end %getInstance
        
        function mview()
            %mview  Show original Signadyne SD_AIO-methods
            
            methodsview KeysightSD1.SD_AIO
        end % mview
        
        function ret = calculateMagnitude(val)
            %calcPresc  Calculate magnitude vector for amplitude modulation
            om = 2*10.^floor(log10(val)-eps);
            ret = om.*ceil(val./om);
            ret(ret<0.1e-3) = 1e-3;
        end % calculateMagnitude
        
        function waves = calculateStateWaveforms(counts)
            samplesActual = counts/2;
            minSamples = 10;
            maxSamples = 100;      % corresponds to ~15 positive bits, todo: check maximum of device
            maxSamplingTime = 4e3; % todo to be checked
            maxCycles = 2^16-1;       % corresponds to ~15 positive bits todo: check maximum of device
            maxDelay = 0.1*6553-10;        % todo: check maximum of device
            
            wave = struct();
            
            if counts < minSamples % 200ns % increase delay
                wave.delay = counts;
                wave.cycles = 1;
                wave.samples = 0;
                wave.samplingTime = 1;
            elseif counts < maxSamples % 300us % increase samples
                wave.delay = 0;
                wave.cycles = 1;
                wave.samples = floor(samplesActual/5)*5;   
                wave.delay = wave.delay + 2*(samplesActual-wave.samples);
                wave.samplingTime = 1;
            else % use larger sampling time and split into two wavforms if necessary
                newSamplingTime = ceil(samplesActual/maxSamples);
                if newSamplingTime>maxSamplingTime %increase cycling
                    wave.samplingTime = maxSamplingTime;
                    resampledCounts = floor(samplesActual/(5*wave.samplingTime))*5;
                    if resampledCounts > maxSamples
                        wave.samples = maxSamples;
                        wave.cycles = floor(samplesActual/(wave.samples*wave.samplingTime));
                        if wave.cycles > maxCycles
                            error('maximum length of waveform reached.');
                        end
                    else
                        wave.samples = resampledCounts;
                        wave.cycles = 1;
                    end
                else
                    wave.samplingTime = newSamplingTime;
                    wave.samples = floor(samplesActual/(5*wave.samplingTime))*5;
                    wave.cycles = 1;
                end
                
                wave.delay = counts - 2*wave.samples*wave.samplingTime*wave.cycles;
                
                if wave.delay > maxDelay % add new waveform
                    wave1 = Devices.SignadynePLL.calculateStateWaveforms(wave.delay);
                    wave.delay = 0;
                    waves = [wave wave1];
                    return;
                end
            end
            if wave.delay >= 0
%                 wave.delay = 10*wave.delay+10;
            end
            waves = wave;
            
        end %calculateStateWaveforms
        
        obj = loadSettings(obj,varargin)
        
     end % methods
    
    
    methods
        obj = init(obj, varargin) %?? TODO why not all pid paraeters?!?!
        
        obj = stepResponse(obj,module,nCH);
        
        obj = aomCalib(obj,nCH);
        function clearWaveforms(obj)
            %CLEAR_WAVEFORMS  Removes saved waveforms and mappings
            
            % delete waveforms of all types
            for type = fieldnames(obj.waveforms)'
                obj.waveforms.(type{:}) = [];
            end
            
            obj.waveformMapping(:) = [];
            
            % delete information on loaded waveforms
            for module = fieldnames(obj.loadedWaveforms)'
                obj.loadedWaveforms.(module{:}) = [];
            end
            
            obj.nextWaveformID = 1;
            
        end % clearWaveforms
%                     obj.writeport(0,1,3)
        function reloadFirmwares(obj)
            %RELOAD_FIRMWARES  Replace hardware firmwares of all Signadyne
            %                 modules by new ones as given in settings struct.
            
            for module = fieldnames(obj.modules)'
                 FWDir = [pwd filesep '+Devices\@SignadynePLL\firmware'] ;
                 oldDir = cd(FWDir);
                 re = obj.modules.(module{:}).FPGAload(obj.settings.(module{:}).firmwareFile);
                 cd(oldDir);
                 if re ~= 0
                     error('Error (%i) received during firmare update.', re);
                 end
            end
            
            obj.init()
        end %reloadFirmwares
            
        function delete(obj)
            %delete   Default destructor
            
            obj.init();
            
            for module = fieldnames(obj.modules)'
                obj.modules.(module{:}).waveformFlush();
                obj.modules.(module{:}).close();
            end
        end %delete
        
        function obj = configureAllInputChannels(obj)
            %CONFIGURE_INPUT_CHANNELS  Sets properties of input channels on
            %                          all modules depending on settings
            %                          struct 'inputConfig'
            
            for module = fieldnames(obj.modules)'
                for channel = fieldnames(obj.settings.(module{:}).inputConfig)'
                    sett = obj.settings.(module{:}).inputConfig.(channel{:});
                    obj.modules.(module{:}).channelInputConfig(sett(1), sett(2), sett(3), sett(4));
                end
            end
        end %configureAllInputChannels
        
        
        %% Methods related to modules
        
        function selectModule(obj, module)
            %SELECT_MODULE  Sets active (selected) module
            assert( ischar(module) && any(ismember(fieldnames(obj.modules),module)), ...
                    'Module unknown. Cannot select new module.');
            
            obj.selectedModule = module;
        end %selectModule
        
        function setModuleClockFrequency(obj, freq)
            %SYS_FREQ  Set frequency of the modules's system clock
            assert( isnumeric(freq) && isscalar(freq) && freq>0, ...
                    'Positive numeric value required for system clock frequency.');
            obj.modules.(obj.selectedModule).clockSetFrequency(freq)
        end %setModuleClockFrequency
        
        function loadFirmwareToModule(obj, filename)
            %LOAD_FIRMWARE  Updates firmware on selected module
            
            %load firmware after changing current directory to firmware
            %folder 
            FWDir = [pwd filesep '+Devices\@SignadynePLL\firmware'] ;
%             assert( ischar(filename) && exist(filename, 'file')==1, ...
%                     'Firmware file ''%s'' not found.\n', filename);
            module = obj.selectedModule;

            oldDir = cd(FWDir);
            err = obj.modules.(module).FPGAload(filename);
            cd(oldDir);
            if  err ~= 0 
                disp(err);
            else
                obj.init();
                obj.settings.(module).firmwareFile = filename;
                disp('Firmware loaded succesfully!');
            end
        end %loadFirmwareToModule
        
        function loadFirmwareToModules(obj, filename)
            %LOAD_FIRMWARE  Updates firmware on selected module
            
            %load firmware after changing current directory to firmware
            %folder 
          
%             assert( ischar(filename) && exist(filename, 'file')==1, ...
%                     'Firmware file ''%s'' not found.\n', filename);
            for module = fieldnames(obj.modules)'
                obj.selectModule(module{1})
                FWDir = [pwd filesep '+Devices\@SignadynePLL\firmware'] ;
                oldDir = cd(FWDir);
                err = obj.modules.(module{1}).FPGAload(filename);

                if  err ~= 0 
                    disp(err);
                else
                    obj.settings.(module{1}).firmwareFile = filename;
                    disp('Firmware loaded succesfully!');
                end
                cd(oldDir);

            end 
            obj.init();
        end %loadFirmwareToModule
        
        
        %% Methods related to channels
        
        function enableChannel(obj, nAWG)
            if obj.modules.(obj.selectedModule).AWGisRunning(nAWG) == 1 
                MSG = ['AWG ', num2str(nAWG), ' is already enabled'];
                disp(MSG)
            else
                obj.modules.(obj.selectedModule).AWGstart(nAWG);
%                 obj.modules.(obj.selectedModule).channelAmplitude(nAWG,1);
                disp(['AWG channel ' nAWG ' activated...'])
            end
        end %enableChannel
        
        function disableChannel(obj, nAWG)
            if obj.modules.(obj.selectedModule).AWGisRunning(nAWG) == 0
                MSG = ['AWG ', num2str(nAWG), ' is already disabled'];
                disp(MSG)
            else
%                 obj.modules.(obj.selectedModule).channelAmplitude(nAWG,0);
                obj.modules.(obj.selectedModule).AWGstop(nAWG);
                disp('channel disabled...')
            end
        end %disableChannel
        
        function setChannelOffset(obj, nCH, offset)
            obj.modules.(obj.selectedModule).channelOffset(nCH,offset);
        end %setChannelOffset
        
        function setChannelAmplitude(obj, nCH, amplitude)
            obj.modules.(obj.selectedModule).channelWaveShape(nCH, KeysightSD1.SD_Waveshapes.AOU_SINUSOIDAL);
            obj.modules.(obj.selectedModule).channelAmplitude(nCH, amplitude);
        end %setChannelAmplitude
          
        function setChannelFrequency(obj, nCH, freq)
            obj.modules.(obj.selectedModule).channelFrequency(nCH, freq);
        end %setChannelFrequency
        
        function setChannelPhase(obj, nCH, phase)
            %SET_CHANNEL_PHASE  Set channel phase in degrees
            obj.modules.(obj.selectedModule).channelPhase(nCH, phase);
        end %setChannelPhase
        
        function setChannelWaveshape(obj, nCH, shape)
            %SET_CHANNEL_WAVESHAPE  Set output waveform shape
            %                       See SignadyneConstants.m for all
            %                       waveshape options
            obj.modules.(obj.selectedModule).channelWaveShape(nCH, shape);
        end %setChannelWaveshape
        
        obj = setAWGstate(obj, amplitude, varargin)
        
        function initializeChannel(obj, chan)
            module = obj.selectedModule;
            if ~isempty(fieldnames(obj.settings.(module).phaseLock{chan+1}))
                obj.disablePLL(chan);
                obj.resetPLL(chan);
                obj.setPLLconfig(chan);
%                 obj.pins.vector.(module).
            end
             if ~isempty(fieldnames(obj.settings.(module).intensityLock{chan+1}))
                obj.disablePID(chan);
                obj.resetPID(chan);
                obj.setPIDconfig(chan);
            end
            obj.modules.(module).channelWaveShape(chan, KeysightSD1.SD_Waveshapes.AOU_SINUSOIDAL);
            obj.modules.(module).channelFrequency(chan, 0.0);
            obj.modules.(module).channelAmplitude(chan, 0.0);
            obj.modules.(module).channelOffset(chan, 0.0);
            obj.modules.(module).channelPhase( chan, 0.0);
            
            obj.modules.(module).modulationAmplitudeConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_OFF, 0);
            obj.modules.(module).modulationAngleConfig(    chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_OFF, 0);
            obj.modules.(module).AWGtriggerExternalConfig( chan, ... nAWG = channel
                  KeysightSD1.SD_TriggerExternalSources.TRIGGER_PXI2, ... (0)%.TRIGGER_EXTERN   Using trigger 2 for now
                  KeysightSD1.SD_TriggerBehaviors.TRIGGER_FALL ... (3) using trigger fall because the trigger goes through a not gate
                );
            obj.modules.(module).AWGflush(chan);
            
            % reset intensity controller if present on this channel
           
            
            % reset phase controller if present on this channel
            
        end %initializeChannel
        
        
        %% Methods related to intensity locking
        
        function enablePID(obj, chan)
            %ENABLE_PID  activates intensity lock for given channel.
            %
            %  Note:
            %            The assumption is that the channel has been
            %            activated before.
            obj.writePIDport(chan, 0, 1);
        end %enablePID
        
        function disablePID(obj, chan)
            obj.writePIDport(chan, 0, 0);
        end %disablePID
        
        function resetPID(obj, chan)     
            % apply rising edge
            obj.writePIDport(chan, 4, 1);
            obj.writePIDport(chan, 4, 0);
        end %resetPID
        
        function setPIDconfig(obj, chan, varargin)
            %SET_PID_CONFIG   Change lock parameters (PID) for intensity
            %                 lock of the corresponding channel of the selected module         
            %
            % Inputs:
            %      chan  channel number on module
            %        kP  proportional part
            %        kI  interal part
            %        kD  differential part
            assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
                  'Positive integer required for channel number.');
            
            % optional arguments
            p = inputParser();
            p.addOptional('kP', obj.settings.(obj.selectedModule).intensityLock{chan+1}.P, ...
                          @(x) isnumeric(x) && isscalar(x));
            p.addOptional('kI', obj.settings.(obj.selectedModule).intensityLock{chan+1}.I, ...
                          @(x) isnumeric(x) && isscalar(x));
            p.addOptional('kD', obj.settings.(obj.selectedModule).intensityLock{chan+1}.D, ...
                          @(x) isnumeric(x) && isscalar(x));      
            p.parse(varargin{:});
            
            % write to object settings
            obj.settings.(obj.selectedModule).intensityLock{chan+1}.P = p.Results.kP;
            obj.settings.(obj.selectedModule).intensityLock{chan+1}.I = p.Results.kI;
            obj.settings.(obj.selectedModule).intensityLock{chan+1}.D = p.Results.kD;
            
            % write to module
            obj.writePIDport(chan, 1, p.Results.kP);
            obj.writePIDport(chan, 2, p.Results.kI);
            obj.writePIDport(chan, 3, p.Results.kD);
        end %setPIDconfig
        
        function setRegister(obj)
            for i=1:length(obj.settings.(obj.selectedModule).registerValues)
                obj.writePIDport(3,i-1,obj.settings.(obj.selectedModule).registerValues(i));
            end
        end
        
        function setRegisterEntry(obj,address,Val)
            obj.settings.(obj.selectedModule).registerValues(address+1) = Val;
            obj.setRegister;
            obj.getRegister
        end
        
               
        
        function ret = getPIDconfig(obj, chan)
            assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
                   'Positive integer required for channel number.');
               
            pBuffer = NET.createArray('System.Int32', 15);
            address = chan*4096;
            obj.modules.(obj.selectedModule).FPGAreadPCport(0, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
            config = pBuffer;
            
            ret = struct( ...
                    'enabled', config(1), ...
                    'P',       config(2), ...
                    'I',       config(3), ...
                    'D',       config(4), ...
                    'reset',   config(5), ...
                    'unknown', config(7));
        end %getPIDconfig
         
        function ret = getRegister(obj)
          
            pBuffer = NET.createArray('System.Int32', 20);
            address = 3*4096;
            obj.modules.(obj.selectedModule).FPGAreadPCport(0, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
            config = pBuffer;
            
            ret = struct( ...
                    'PLLalwaysOn', config(1), ...
                    'TriggerThreshhold',       config(2), ...
                    'PLLenableThreshhold',       config(3), ...
                    'OffsetChannel0',       config(4), ...
                    'switchPhaseLockDAQs', config(5), ...
                    'OffsetChannel1', config(6),...
                    'OffsetChannel2', config(7),...
                    'FeedforwardEnabled', config(8),...
                    'LUT0enabled',config(9),...
                    'LUT1enabled',config(10),...
                    'LUT2enabled',config(11),...
                    'SwitchSetpointMonitoring', config(12),...
                    'AmplitdueFeedForward',config(13),...
                    'CH0PhaseOffset', config(14),...
                    'DAQ23DataAqcuisitionMode', config(15),...
                    'IntensityControlLatch', config(16)...
                    );

        end %getPIDconfig
        
        function writePIDport(obj, chan, address, data)
            assert(isnumeric(chan) && isscalar(chan) && chan>=0 && chan <=3, ...
                   'Positive integer required for channel number.');
            assert(isnumeric(address) && isscalar(address) && address>=0, ...
                   'Positive integer required for address.');
            sett = obj.settings.(obj.selectedModule).intensityLock{chan+1};
            
            if ~isstruct(sett) || isempty(fieldnames(sett))
%                 warning('intensity lock settings for channel %i on module %s not available.', ...
%                         chan, obj.selectedModule);
%                 return;
            end
            
            pBuffer = int32(data);
            address = address + chan*4096;
            
            re = obj.modules.(obj.selectedModule).FPGAwritePCport(0, pBuffer, address, KeysightSD1.SD_AddressingMode.FIXED, KeysightSD1.SD_AccessMode.NONDMA);
            if re~=0
                error('Error (%i) occured during writing to address %i for channel %i on pcPort0 located at module %s', ...
                      re, address, chan, obj.selectedModule);
            end
        end %writePIDport
 %% commented out because of conflict with other function of same name, line 1606      
% %         function writeLUT(obj,data,nCH)
% %             pBuffer = int32(data);
% %             address = nCH*4096;                       % hexadecimal address 16^3 = 4096
% %             
% % %             try
% %                 re = obj.modules.(obj.selectedModule).FPGAwritePCport(2, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
% % %             catch ME
% % %                warning('%s\n\nError in %s (%s) (line %d)\n', ...
% % %                         ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ...
% % %                         ME.stack(1).('line'));
% % %             end
% %             
% %             if re == 0
% % %                 obj.PIDconfig(nCH)
% %             else
% %                 error(['got errorcode ' re])
% %             end
% %         
% %    
% %        end
% %         
        %% methods related to phase locking
        
        function enablePLL(obj, chan)
            %ENABLE_PLL  Activates phase lock for given channel.
            %
            %  Note:
            %            The assumption is that the channel has been
            %            activated before.
            assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
                   'Positive integer required for channel number.');
               
            sett = obj.settings.(obj.selectedModule).phaseLock{chan+1};
            
            if ~isstruct(sett) || isempty(fieldnames(sett))
                warning('phase lock settings for channel %i on module %s not available.', ...
                        chan, obj.selectedModule);
                return;
            end
            if isfield(obj.modules,'module5')
                obj.setPLLReferenceState();
                refPin = obj.getVectorPin('PLLref');
            end

            obj.setPLLaccumulatorSize(chan, sett.accumulatorSize);
            obj.setPLLPhaseLockedRange(chan, sett.phaseRange);
            obj.setPLLFrequencyLockedRange(chan, sett.frequencyRange);
            
            channelPin = obj.getVectorPin(obj.getVectorPinName(obj.selectedModule, chan));
            
%             diffFreq = 2*channelPin.offset(2)-refPin.offset(2); % always assume double pass configuration
            obj.setPLLfrequency(chan, 10e6);
            
            obj.setPLLconfig(chan);
            
            obj.writePLLport(chan, 0, 1);
        end %enablePLL
        
        function disablePLL(obj, chan)
            obj.writePLLport(chan, 0, 0);
        end %disablePLL
        
        function resetPLL(obj, chan)
            % rising edge
            obj.writePLLport(chan, 10, 1);
            obj.writePLLport(chan, 10, 0);
            obj.setPLLconfig(chan,0,0,0);
            obj.writePLLport(chan, 0, 1);
            obj.disablePLL(chan);
            obj.setPLLconfig(chan);

%             obj.enablePLL(chan);
%             obj.disablePLL(chan);
        end %resetPLL
        
        function setPLLfrequency(obj, chan, freq)
            %SET_PLL_FREQUENCY  Sets the reference frequency for phase and
            %                   frequency discrimination
            assert(isnumeric(freq) && isscalar(freq) && freq>0, ...
                   'frequency needs to be positive scalar value');
            
            freqData = freq/obj.ref_freq_factor;
            
            if freqData>intmax('int32')
                error('frequency is too large (maximum is %f)', intmax('int32')/obj.ref_freq_factor);
            end
            
            obj.writePLLport(chan, 1, freqData);
        end %setPLLfrequency
        
        function setPLLphase(obj, chan, phase)
            
            obj.writePIDport(3,13,double(phase)/180.*2^15);
            obj.settings.(obj.selectedModule).registerValues(14) = double(phase)/180.*2^15;
%             obj.writePLLport(chan, 2, phase*obj.ref_phase_factor);
        end %setPLLphase
        
        function resetPLLphase(obj, chan)
            % rising edge
            obj.writePLLport(chan, 3, 1);
            obj.writePLLport(chan, 3, 0);
        end %resetPLLphase
        
        function setPLLaccumulatorSize(obj, chan, acc)
            obj.writePLLport(chan, 4, acc);
        end %setPLLaccumulatorSize
        
        function setPLLPhaseLockedRange(obj, chan, range)
            obj.writePLLport(chan, 5, range);
        end %setPLLPhaseLockedRange
        
        function setPLLFrequencyLockedRange(obj, chan, range)
            obj.writePLLport(chan, 6, range);
        end %setPLLFrequencyLockedRange
        
        function setPLLconfig(obj, chan, varargin)
            %SET_PLL_CONFIG   Change lock parameters (PID) for phase
            %                 lock of the corresponding channel of the selected module         
            %
            % Inputs:
            %      chan  channel number on module
            %        kP  proportional part
            %        kI  interal part
            %        kD  differential part
            assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
                  'Positive integer required for channel number.');
            
            % optional arguments
            p = inputParser();
            p.addOptional('kP', obj.settings.(obj.selectedModule).phaseLock{chan+1}.P, ...
                          @(x) isnumeric(x) && isscalar(x));
            p.addOptional('kI', obj.settings.(obj.selectedModule).phaseLock{chan+1}.I, ...
                          @(x) isnumeric(x) && isscalar(x));
            p.addOptional('kD', obj.settings.(obj.selectedModule).phaseLock{chan+1}.D, ...
                          @(x) isnumeric(x) && isscalar(x));      
            p.parse(varargin{:});
            
            % write to object settings
%             obj.settings.(obj.selectedModule).phaseLock{chan+1}.P = p.Results.kP;
%             obj.settings.(obj.selectedModule).phaseLock{chan+1}.I = p.Results.kI;
%             obj.settings.(obj.selectedModule).phaseLock{chan+1}.D = p.Results.kD;
            
            % write to module
            obj.writePLLport(chan, 7, p.Results.kP);
            obj.writePLLport(chan, 8, p.Results.kI);
            obj.writePLLport(chan, 9, p.Results.kD);
        end %setPLLconfig
        
        function ret = getPLLconfig(obj, chan)
            assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
                   'Positive integer required for channel number.');
            
            address = 0 + chan*4096;
            pBuffer = NET.createArray('System.Int32', 15);
            pBuffer2 = NET.createArray('System.Int32', 15);
            obj.modules.(obj.selectedModule).FPGAreadPCport(1, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
            obj.modules.(obj.selectedModule).FPGAreadPCport(0, pBuffer2, 3*4096+13, KeysightSD1.SD_AddressingMode.FIXED, KeysightSD1.SD_AccessMode.DMA);
            config = pBuffer;
            
            ret = struct( ...
                    'enabled',    config(1),...
                    'frequency',  uint32(config(2)*obj.ref_freq_factor),...
                    'phase',      double(pBuffer2(2))*180./2^15,...
                    'phaseReset', int32(config(4)),...
                    'accumulatorSize', config(5),...
                    'phaseRange',      config(6),...
                    'frequencyRange',  config(7),...
                    'P',     config(8),...
                    'I',     config(9),...
                    'D',     config(10),...
                    'reset', config(11) ...
                  );
        end %getPLLconfig
        
        function writePLLport(obj, chan, address, data)
            assert(isnumeric(chan) && isscalar(chan) && chan>=0 && chan <= 3, ...
                   'Positive integer required for channel number.');
            assert(isnumeric(address) && isscalar(address) && address>=0, ...
                   'Positive integer required for address.');
               
            sett = obj.settings.(obj.selectedModule).phaseLock{chan+1};
            
            if ~isstruct(sett) || isempty(fieldnames(sett))
                warning('phase lock settings for channel %i on module %s not available.', ...
                        chan, obj.selectedModule);
                return;
            end
            
            pBuffer = int32(data);
            address = address + chan*4096;
            re = obj.modules.(obj.selectedModule).FPGAwritePCport(1, pBuffer, address, KeysightSD1.SD_AddressingMode.FIXED, KeysightSD1.SD_AccessMode.NONDMA);
            
            if re~=0
                error('Error (%i) occured during writing to address %i for channel %i on pcPort1 located at module %s', ...
                      re, address, chan, obj.selectedModule);
            end
        end %writePLLport

        
        %% DAQ
        
        function startDAQs(obj) %TODO
            obj.modules.(obj.selectedModule).DAQstartMultiple(255);
        end %startDAQs
        
        function startDAQ(obj, nDAQ) %TODO
            if obj.modules.(obj.selectedModule).DAQstart(nDAQ)<0
                disp('error starting DAQ', num2str(nDAQ))
            end
        end %startDAQ
        
        function startDAQSingle(obj, nDAQ) %TODO
            if obj.modules.(obj.selectedModule).DAQstart(nDAQ)<0
                disp('error starting DAQ', num2str(nDAQ))
            end
        end %startDAQ
        
        function flushDAQ(obj) %TODO
            obj.modules.(obj.selectedModule).DAQstopMultiple(255);
            obj.modules.(obj.selectedModule).DAQflushMultiple(255);
        end %flushDAQ
        
        function configureDAQ(obj, nP, trigger) %TODO
            
            obj.data.points = nP;            
            trigger_mask = bitshift(1,trigger); %2= trigger: not phaselocked and active. bitshift to 00000100 -> look up trigger  register of DAQS 
%             obj.modules.(obj.selectedModule).DAQtrigger(2) ;
            for i = 1:8 
                if obj.modules.(obj.selectedModule).DAQtriggerConfig(i,0,0,trigger_mask) < 0      %configure trigger: Digital none, ANALOG = trigger mask
                    error('error configuring DAQtrigger')
                end
    
                if obj.modules.(obj.selectedModule).DAQconfig(i,nP,1,0,0) <0                      %nDAQ,points,nCyc,Delay, trMode: 3 = TRG_ANALOG, 0 = AUTO
                    error('error configuring DAQ')
                end
                
            end
%             obj.modules.(obj.selectedModule).channelInputConfig(0,1,1,0)  ;               % channel, fullScale,impedance, coupling
            
        end %configureDAQ
        
        
        function configureDAQSingle(obj,nDAQ, nP, trigger) %TODO- This function is to configure individual DAQ channels. Don't know why max was configuring all of them for every command. 
            
            obj.data.points = nP;            
            trigger_mask = bitshift(1,trigger); %2= trigger: not phaselocked and active. bitshift to 00000100 -> look up trigger  register of DAQS 
%             obj.modules.(obj.selectedModule).DAQtrigger(2) ;
          
                if obj.modules.(obj.selectedModule).DAQtriggerConfig(nDAQ,0,0,trigger_mask) < 0      %configure trigger: Digital none, ANALOG = trigger mask  -- cannot find DAQtriggerconfig in SD documentaion
                    error('error configuring DAQtrigger')
                end
                
               % if obj.modules.(obj.selectedModule).DAQtriggerExternalConfig
    
                if obj.modules.(obj.selectedModule).DAQconfig(nDAQ,nP,1,0,1) <0                      %nDAQ,points,nCyc,Delay, trMode: 3 = TRG_ANALOG, 0 = AUTO
                    error('error configuring DAQ')
                end          
%             obj.modules.(obj.selectedModule).channelInputConfig(0,1,1,0)  ;               % channel, fullScale,impedance, coupling
            
        end %configureDAQSingle
        
        function readDAQs(obj) %TODO this is a function for the initial demo version, and should not be used. 
            % This function can be used as a reference to implement
            % coordinated data accumulation in the future
            
            for i = 1:8                                    %read from all 7 DAQs
                obj.data.read_data{i+1} = NET.createArray('System.Int16', obj.data.points);
                read_points = obj.modules.(obj.selectedModule).DAQread(i,obj.data.read_data{i+1},500);
                
                if read_points ~= obj.data.points
                    MSG = [num2str(read_points),' points read instead of ',num2str(obj.data.points),' from DAQ ',num2str(i)];
                    %print('\n %i points read instead of %i from DAQ %i\n',read_points,points,i)
                    disp(MSG)
                else
                    MSG = ['DAQ ',num2str(i),' read...'];
                    disp(MSG)
                end
                
                obj.data.read_data{i+1} = int64(obj.data.read_data{i+1});
            end
            
            obj.data.read_data{3}=uint64(obj.data.read_data{3});
            obj.data.read_data{4}=uint64(obj.data.read_data{4});
            obj.data.read_data{5}=uint64(obj.data.read_data{5});
            obj.data.read_data{6}=uint64(obj.data.read_data{6});
            obj.data.read_data{7}=uint64(obj.data.read_data{7});

            %reassign DAQ data: 
            obj.data.A_data_in = obj.data.read_data{1};
            obj.data.A_phase = obj.data.read_data{8};
            obj.data.A_diff = bitor(bitshift(obj.data.read_data{6},16),obj.data.read_data{7});
            obj.data.A_diff = bitshift(obj.data.A_diff,-4);        
            obj.data.A_frq_out = bitor(bitor(bitshift(obj.data.read_data{3},32),bitshift(obj.data.read_data{4},16)),obj.data.read_data{5}); %%bitor(bitshift(data.read_data{3},16),bitshift(data.read_data{4},0));
            obj.data.A_locked = obj.data.read_data{7};
             
            obj.flushDAQ()
%              obj.startDAQ()
        end %readDAQs
        
        function ret = readDAQ(obj, nDAQ) %TODO
            obj.data.read_data{nDAQ+1} = NET.createArray('System.Int16', obj.data.points);
            read_points = obj.modules.(obj.selectedModule).DAQread(nDAQ,obj.data.read_data{nDAQ+1},1000);

            if read_points ~= obj.data.points
                MSG = [num2str(read_points),' points read instead of ',num2str(obj.data.points),' from DAQ ',num2str(nDAQ)];
                %print('\n %i points read instead of %i from DAQ %i\n',read_points,points,i)
                disp(MSG);
                ret = -1;
            else
                ret = 0;
%                 MSG = ['DAQ ',num2str(nDAQ),' read...'];
%                 disp(MSG)
            end
            obj.data.read_data{nDAQ+1} = int64(obj.data.read_data{nDAQ+1});
        end %readDAQ

        
        function ret = readDAQSingle(obj, nDAQ) %TODO
            obj.data.read_data{nDAQ+1} = NET.createArray('System.Int16', obj.data.points);
            read_points = obj.modules.(obj.selectedModule).DAQread(nDAQ,obj.data.read_data{nDAQ+1},0);

            if read_points ~= obj.data.points
                MSG = [num2str(read_points),' points read instead of ',num2str(obj.data.points),' from DAQ ',num2str(nDAQ)];
                %print('\n %i points read instead of %i from DAQ %i\n',read_points,points,i)
                disp(MSG);
                ret = -1;
            else
                ret = 0;
%                 MSG = ['DAQ ',num2str(nDAQ),' read...'];
%                 disp(MSG)
            end
            obj.data.read_data{nDAQ+1} = int64(obj.data.read_data{nDAQ+1});
        end %readDAQ

        
        function DAQplot(obj) %TODO
%             coarse_locked = A_locked & 4;
%             disp(A_diff)
%             A_frq_out_notLock=A_frq_out(coarse_locked==0);
%             lenNL = length(A_frq_out_notLock);
%             A_frq_out = [zeros(lenNL*4,1); A_frq_out(lenNL+1:length(A_frq_out))];
%             A_frq_out(1:4:lenNL*4)=A_frq_out_notLock; 
%             A_frq_out(2:4:lenNL*4)=A_frq_out_notLock;
%             A_frq_out(3:4:lenNL*4)=A_frq_out_notLock;
%             A_frq_out(4:4:lenNL*4)=A_frq_out_notLock;
% 
%             A_diff_notLock=A_diff(coarse_locked==0);
%             lenNL = length(A_diff_notLock);
%             A_diff = [zeros(lenNL*4,1); A_diff(lenNL+1:length(A_diff))];
%             A_diff(1:4:lenNL*4)=A_diff_notLock; 
%             A_diff(2:4:lenNL*4)=A_diff_notLock;
%             A_diff(3:4:lenNL*4)=A_diff_notLock;
%             A_diff(4:4:lenNL*4)=A_diff_notLock;

            %coarse_locked = [zeros(lenNL*4,1); coarse_locked(lenNL+1:length(coarse_locked))];
            
            %disp (A_diff)
%             disp(A_diff(100))
            figure(1)
            ax(1)=subplot(2,2,1);
            plot((1:1:length(obj.data.A_data_in))*0.01, double(obj.data.A_data_in)./(2^15),'.-');
            title('normalized AWG Channel 0')
            xlabel('time (탎)');
            grid on
            ax(2)=subplot(2,2,2);
            plot((1:1:length(obj.data.A_frq_out))*0.32, double(obj.data.A_frq_out)*500/2^47,'.-');
            title('Frequency OUT')
            xlabel('time (탎)');
            ylabel('MHz')
            grid on  
            ax(3)=subplot(2,2,3);
            plot((1:1:length(obj.data.A_diff))*0.32, obj.data.A_diff*(obj.ref_freq_factor),'.-');
            title('Diff freq')
            xlabel('time (탎)');
            grid on
            ax(4)=subplot(2,2,4);
            plot((1:1:length(obj.data.A_phase))*0.32, obj.data.A_phase/obj.ref_phase_factor,'.-');
            title('Phase')
            xlabel('time (탎)');
            grid on
            linkaxes(ax(2:4),'x');
        end %DAQplot
        
        function plotData(obj, nDAQ) %TODO
            figure(nDAQ+10);
            max = obj.modules.(obj.selectedModule).channelFullScale(nDAQ);
            val = mean(double(obj.data.read_data{nDAQ+1}).*max./double(2^15));
            val = round(val,3);
            plot(double(obj.data.read_data{nDAQ+1}).*max./2^15,'.-');
            title(['DAQ Channel ' num2str(nDAQ)])
            axis([0 obj.data.points (-1)*max 1*max]);
%             axis([0 obj.data.points (-1)*2^15 2^15]);
%             yticks([-2^15 -2^14 0 2^14 2^15])
%             yticklabels({max,max/2,0,max/2,max})
            xlabel('time (ns*10)');
            legend(num2str(val));
            grid on
        end %plotData
        
        function saveData(obj, nDAQ) %TODO
            c = strcat('data',num2str(nDAQ),'.dat');
            f = fopen(c,'w');
            a = obj.data.read_data{nDAQ+1};
            formatSpec = '%8.2f\n';
            fprintf(f,formatSpec,a);
        end %saveData
        
        %% some text
        function DAQread(obj,nDAQ,varargin) %TODO
            
            if nargin > 2
                obj.configureDAQSingle(nDAQ,varargin{1},0);
            else
               obj.configureDAQ(50000,0) 
               % obj.configureDAQ(200,0)  %%why only 200 points? maybe this
           % should not be fixed?, DEBUG MUHIB : EXCHANGE WITH SINGLE
           % CHANNEL CONFIGURE 19.9 /16:35 
           %DEBUG MUHIB : EXCHANGE BACK 20.9
            end 
            

            obj.configureDAQ(200,0)

            if nargin > 2
                obj.configureDAQSingle(nDAQ,varargin{1},0);
            else
            obj.configureDAQ(200,0)  %%why only 200 points? maybe this should not be fixed?
            end 
            

            obj.startDAQ(nDAQ)
            if obj.readDAQ(nDAQ) < 0 
                return
            end
            if nargin > 3
                assert(varargin{1} == 'p','too many arguments given')
                return
            else
                obj.plotData(nDAQ)
            end
        end %DAQread
        %% additional function for testing. 
        
         function DAQreadSingle(obj,nDAQ,varargin) %TODO
            
            if nargin > 2

                obj.configureDAQSingle(nDAQ,varargin{1},0);
            else
            obj.configureDAQ(50001,0)  %%why only 200 points? maybe this should not be fixed?
            end 
            
            obj.startDAQSingle(nDAQ)
            if obj.readDAQ(nDAQ) < 0 
                return
            end
            if nargin > 3


                obj.configureDAQSingle(nDAQ,varargin{1},0);
            else
            obj.configureDAQ(2500,0)  %%why only 200 points? maybe this should not be fixed?
            end 
            
            obj.startDAQSingle(nDAQ)
            if obj.readDAQ(nDAQ) < 0 
                return
            end
            if nargin > 3

                assert(varargin{1} == 'p','too many arguments given')
                return
            else
                obj.plotData(nDAQ)
            end
        end %DAQread
        
        %%
        function saveAll(obj) %TODO
            for i = 0:6
                disp(i);
                obj.saveData(i);
            end
        end %saveAll
        
        function saveDemo(obj) %TODO
            for a = [obj.data.A_diff obj.data.A_frq_out obj.data.A_phase obj.data.A_data_in]
                c = strcat(a,'.dat');
                f = fopen(c,'w');
                formatSpec = '%8.2f\n';
                fprintf(f,formatSpec,a);
            end
        end %saveDemo
        
        function plotAll(obj) %TODO
            figure(4)
            for i = 1:8
                subplot(3,3,i);
                plot((1:1:length(obj.data.read_data{i})), obj.data.read_data{i},'.-');
                axis([0,50001,-2^15,2^15]);
                title(['CH ' num2str(i-1)]);
                xlabel('time (ns*10)');
                grid on
            end
        end %plotAll

        function clearData(obj) %TODO
            
            obj.data.A_diff=[];
            obj.data.A_frq_out=[];
            obj.data.A_data_in=[];
            obj.data.A_phase=[];
            obj.data.A_locked=[];
            
            obj.data.read_data={};
            
            obj.data.points = 0;
        end %clearData
        
        
        %% Methods related to VectorOut pins
        
        function name = getVectorPinName(obj, module, channel)
            %GET_VECTOR_PIN_Name  Returns name VectourOut pin given the
            %                     module and channel number
            %
            % Inputs
            %    module  module name, e.g. ''module2''
            %   channel  channel number on module, typically between 0 and 3
            %
            % Outputs
            %      name  name of the pin
            assert(ischar(module) && isfield(obj.labSettings.defaultPins.vector,module), ...
                   'Module %s not found.', module);
            
            if ~any(cellfun(@(x) strcmp(x,module), obj.pins.vector(:,1)))
                error('Module ''%s'' is not active. Restart Signadyne object with the corresponding module', module);
            end
               
            assert(isnumeric(channel) && isscalar(channel) && channel>=0 && channel<numel(obj.labSettings.defaultPins.vector.(module)), ...
                   'Channel number %i not valid.', channel);
            
            name = obj.labSettings.defaultPins.vector.(module){channel+1}.toString();
        end %getVectorPinName
        
        function [pin, pinMod, pinChan] = getVectorPin(obj, name)
            % getVectorPin  Returns vector pin by unique name given by
            %               defaultPins structure.
            assert( ischar(name), ...
                    'Pin name required');
                
            idx = cellfun(@(x) strcmp(x.name,name), obj.pins.vector(:,3));
            id = find(idx);    
            if isempty(id)
                error('Pin (''%s'') cannot by found.', name);
            end
            id = find(idx);
            pinMod  = obj.pins.vector{id,1};
            pinChan = obj.pins.vector{id,2};
            pin     = VectorOut(obj.pins.vector{id,3});    
        end %getVectorPin
        
        function pin = getTriggerPin(obj)
            % getTriggerPin  Returns used trigger pin by unique name
                
            pin = obj.pins.trigger;
        end %getTriggerPin
        
        function obj = clearPins(obj, varargin)
            %clearPins  Clear the time evolution of all pins and set
            %           inital state 0
            %
            %   Note: This function is required to reset initial values for
            %         unassigned pins of sequences, since the may have
            %         change during older compilation processes.
            %   
            %         This function basically copies the contents of
            %         obj.labSettings.defaultPins and adds pin.state(0)
            %
            % Inputs
            %  clAll(optional) Clears also trigger pin
            if nargin>1
                clAll = varargin{1};
                assert( isnumeric(clAll) && isscalar(clAll), ...
                        'numeric scalar value required');
            else
                clAll = 0;
            end
            
            %vector channel
            idx = 1;
            for module = fieldnames(obj.modules)'
                for channel = 1:length(obj.labSettings.defaultPins.vector.(module{:}))
                    obj.pins.vector{idx,1} = module{1};
                    obj.pins.vector{idx,2} = channel-1;
                    pin = obj.labSettings.defaultPins.vector.(module{:})(channel);
                    obj.pins.vector{idx,3} = VectorOut(pin{:});
                    idx = idx + 1;
                end
            end
            
            % trigger channel
            if clAll || ~isfield(obj.pins, 'trigger')
                obj.pins.trigger = DigitalOut(obj.labSettings.defaultPins.trigger);
            else
                obj.pins.trigger = DigitalOut(obj.pins.trigger);
            end
            
            % delete compiled pins
            for module = fieldnames(obj.compiledPins)'
                obj.compiledPins.(module{:}) = [];
            end
            
        end %clearPins
        
        
        %% Methods related special Pins (hardcoded names involved)
        
        function setPLLReferenceState(obj)
            %SET_PLL_REFERENCE_STATE  Activates the reference pin which is
            %                         required for PLL locking
            
            orgModule = obj.selectedModule;
            [pin, pinMod, pinChan] = obj.getVectorPin('PLLref');
            obj.selectModule(pinMod);
            
            obj.setChannelAmplitude(pinChan, pin.offset(1));
            obj.setChannelOffset(pinChan, 0);
            obj.setChannelFrequency(pinChan, pin.offset(2));
            obj.setChannelPhase(pinChan, pin.offset(3));
            
            obj.selectModule(orgModule);
        end % setPLLReferenceState
        
        function setVDTstate(obj, amplitude)
            %SET_VDT_state  Activate vertical dipole trap with given
            %               amplitude
            orgModule = obj.selectedModule;
            
            [~, pinMod, pinChan] = obj.getVectorPin('VDT');
            obj.selectModule(pinMod);
            
            obj.AWGstate(pinChan, amplitude);
            
%             if ~obj.getPIDconfig(pinChan).enabled
%                 obj.setPIDconfig(pinChan);
%             end
%             obj.resetPID(pinChan);
%             obj.enablePID(pinChan);
            
            obj.selectModule(orgModule);
        end %setVDTstate
        
        function setHDTstate(obj, amplitude, varargin)
            %SET_HDT_STATE  Activates horizontal dipole trap beams given an
            %               amplitude
            %
            % Inputs
            %   amplitude  amplitude of photodiode signal in V
            %        arms  vector containing the lattice beams (1-3)
            if nargin>2
                arms = varargin{1};
            else 
                arms = [1 2 3];
            end
            
            if numel(amplitude) == 1
                amplitude = [amplitude;0];
            end
            
            assert(isnumeric(arms) && all(arms<4) && all(arms>0), ...
                   'Lattice arms number not known');
            
            orgModule = obj.selectedModule;
%             amplitude(2) = mod((amplitude(2)+pin.offset(3))/maxAngleValue+1,2)-1;
            for k = arms(:)'
                switch(k)
                    case 3
                        pinList = {'HDT3L', 'HDT3R'};
                        pllActive = {true true};
                    case 2
                        pinList = {'HDT2'};
                        pllActive = {false};
                    case 1
                        pinList = {'HDT1L', 'HDT1R'};
                        pllActive = {true true};
                end
                
                for kk = 1:numel(pinList)
%                     pin = 
                    [pin, pinMod, pinChan] = obj.getVectorPin(pinList{kk});
                    pinAmplitude = [amplitude(1); mod(amplitude(2)+1,2)-1];
                    obj.selectModule(pinMod);
                    obj.setChannelFrequency(pinChan,80e6);
                    obj.setChannelAmplitude(pinChan,0);
                    obj.AWGstate(pinChan,pinAmplitude);
                    
                    if ~obj.getPIDconfig(pinChan).enabled
                        obj.setPIDconfig(pinChan);
                    end
                    obj.resetPID(pinChan);
                    obj.enablePID(pinChan);
                    
                    if pllActive{kk}
                        if ~obj.getPLLconfig(pinChan).enabled
                            obj.enablePLL(kk-1);
                        end
                        obj.resetPLL(pinChan);
                        obj.enablePLL(pinChan);
                    end
                end
            end
            
            obj.selectModule(orgModule);
        end % setHDTstate
        
        
        %% Methods related to sequence execution

        obj = loadSequence(obj, seq); %TODO
            
        function obj = startExecution(obj)
            %startExecution   Starts execution of queued waveforms
            orgModule = obj.selectedModule;
            
            %find used vector pins in sequence
            for module = fieldnames(obj.compiledPins)'
                obj.selectModule(module{1});
                sett = obj.settings.(obj.selectedModule);
                AWGstartWord = 0;
                for chan = obj.compiledPins.(module{:})-1
                    %fprintf('started: %s %i\n', module{:}, chan);
                    
                    pinObject = obj.getVectorPin(obj.getVectorPinName(module{:}, chan));
                    
                    % set channel parameters
                    obj.setChannelWaveshape(chan, KeysightSD1.SD_Waveshapes.AOU_SINUSOIDAL);
                    obj.setChannelAmplitude(chan, pinObject.offset(1));
                    obj.setChannelFrequency(chan, pinObject.offset(2));
                    obj.setChannelPhase( chan, pinObject.offset(3));
                    obj.setChannelOffset(chan, 0.0);

                    
                    % check channel configs
                    if isstruct(sett.intensityLock{chan+1}) && ~isempty(fieldnames(sett.intensityLock{chan+1}))
                        obj.resetPID(chan);
                        obj.enablePID(chan);
                    end
                    
                    if isstruct(sett.phaseLock{chan+1}) && ~isempty(fieldnames(sett.phaseLock{chan+1}))
                        obj.resetPLL(chan);
                        obj.enablePLL(chan);
                    end
                    
                    % start waveform generator
                    AWGstartWord = bitor(AWGstartWord,bitshift(1,chan));
                    
                end
                if obj.modules.(module{:}).AWGstartMultiple(AWGstartWord) < 0
                        obj.stopExecution();
                        error('Error starting Signadyne sequence.');
                end
            end
            obj.selectModule(orgModule);
            disp('Signadyne sequence started. waiting for trigger.');
        end %startExecution
        
        function obj = stopExecution(obj)
            %stopExecution   Stops the Signadyne device from executing a sequence
            
            for module = fieldnames(obj.compiledPins)'
                for chan = obj.compiledPins.(module{:})
                    if obj.modules.(module{:}).AWGstop(chan) < 0
                        obj.init();
                        error('Error stopping Signadyne sequence.');
                    end
                end
            end
            disp('Signadyne sequence stopped.');
        end % stopExecution
        
        
        %% removed methods
        
        function switchMod(~, ~) 
            error('The method ''switchMod'' is deprecated. Use selectModule() instead.')
        end %switchMod
        
        function setWS(~, ~, ~)
            error('The method ''setWS'' is deprecated. Use setWaveshape() instead.')
        end %switchMod
        
        function loadFirmware(~, ~)
            error('The method ''loadFirmware'' is deprecated. Use loadFirmwareToModule() instead.')
        end %loadFirmware
        
        function reloadFirmware(~)
            error('The method ''reloadFirmware'' is deprecated. Use reloadFirmwares() instead.')
        end %reloadFirmware
        
        function sysFreq(~, ~)
            error('The method ''sysFreq'' is deprecated. Use setModuleClockFrequency() instead.')
        end %sysFreq
        
%         function PIDconfig(~, ~)
%             error('The method ''PIDconfig'' is deprecated. Use getPIDconfig() instead.')
%         end % PIDconfig
        function PIDconfig(obj,varargin)
            if length(varargin)==1
                nCH  = varargin{1};
            else
                nCH=0;
            end
            pBuffer = NET.createArray('System.Int32', 15);
            adress= nCH*4096;
            obj.modules.(obj.selectedModule).FPGAreadPCport(0, pBuffer, adress, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
            config = pBuffer;
            a = struct('enabled',config(1),...
                'P_gain',config(2),...
                'I_gain', config(3),...
                'D_gain',config(4),...
                'reset',config(5),...
                'unknown',config(7)...
                );
            disp(a)
            
        end
        
%         function writeport(~, ~, ~, varargin)
%             error('The method ''writeport'' is deprecated. Use writePIDport() instead.')
%         end % writeport
        function writeport(obj,address,data,varargin)
            if length(varargin)>= 1
                nCH  = varargin{1};
            else
                nCH = 0;
            end
            pBuffer = int32(data);
            address = address + nCH*4096;
%             try
                re = obj.modules.(obj.selectedModule).FPGAwritePCport(0, pBuffer, address, KeysightSD1.SD_AddressingMode.FIXED, KeysightSD1.SD_AccessMode.NONDMA);
%             catch ME
%                warning('%s\n\nError in %s (%s) (line %d)\n', ...
%                         ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ...
%                         ME.stack(1).('line'));
%             end
            
            if re == 0
%                 obj.PIDconfig(nCH)
            else
                error(['got errorcode ' re])
            end
        
   
        end
        
        function PLLconfig(~, varargin)
            error('The method ''PLLconfig'' is deprecated. Use getPLLconfig() instead.')
        end %PLLconfig
        
        function setPLLPID(~, ~, ~, ~, varargin)
            error('The method ''setPLLPID'' is deprecated. Use setPLLconfig() instead.')
        end %setPLLPID
        
        function setPLLFreqLockedRange(~, ~, ~)
            error('The method ''setPLLFreqLockedRange'' is deprecated. Use setPLLFrequencyLockedRange() instead.')
        end %setPLLFreqLockedRange
        
        function setPLLaccumulator(~, ~, ~)
            error('The method ''setPLLaccumulator'' is deprecated. Use setPLLaccumulatorSize() instead.')
        end %setPLLaccumulator
        
        function AWGstate(obj,chan,A,varargin)
            if nargin== 4
                
                if strcmp(varargin{1},'DC')
                    mode=KeysightSD1.SD_ModulationTypes.AOU_MOD_OFFSET;
             
                end
            else
                mode = KeysightSD1.SD_ModulationTypes.AOU_MOD_AM;
            end
            mod = obj.selectedModule;
%             assert(all(size(A) == [2 1]),'need 2 dimensional Amplitude phase vector');
            if all(size(A) == 1)
                A(2) = 0;
            end
            
                
            if A(1) == 0
                obj.modules.(mod).modulationAmplitudeConfig(chan, mode, 1);
                obj.modules.(mod).modulationAngleConfig( chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_PHASE, 180);

                obj.modules.(mod).channelWaveShape(chan, 1); 
    %             obj.(mod).channelAmplitude(chan, 0);
                wave = KeysightSD1.SD_Wave(KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ones(1,20)*A(1),ones(1,20)*A(2));
                if wave.getStatus() <= 0
                    err = wave.getStatus();
                    error(['Error creating Waveform' num2str(err)]);
                else
                     if obj.modules.(mod).waveformLoad(wave,chan) <= 0 %load new WF with ID
                        error('Error loading Waveform');
                     end %loading 
                end
                err = obj.modules.(mod).AWGqueueWaveform(chan,chan,0,0,0,0) ;
                if err < 0 
                     error(['Error queueing Waveform to AWG ' num2str(chan)...
                         '. Errorcode: ' num2str(err)])
                end
                obj.modules.(mod).AWGstart(chan);
                disp(['channel ' num2str(chan) ' off']);
                obj.modules.(mod).waveformFlush();
%               obj.(mod).channelInputConfig(chan,1,1,0)  ;
                obj.modules.(mod).channelWaveShape(chan, 1);
                obj.modules.(mod).channelFrequency(chan, 0.0);
                obj.modules.(mod).channelAmplitude(chan, 0.0);
                obj.modules.(mod).channelOffset(chan, 0.0);
                obj.modules.(mod).channelPhase( chan, 0.0);
                obj.modules.(mod).modulationAmplitudeConfig(chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_OFF, 0);
                obj.modules.(mod).modulationAngleConfig(    chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_OFF, 0);
                obj.modules.(mod).AWGtriggerExternalConfig( ...
                                                      chan, ... nAWG = channel
                                                      KeysightSD1.SD_TriggerExternalSources.TRIGGER_EXTERN, ... (0)
                                                      KeysightSD1.SD_TriggerBehaviors.TRIGGER_RISE ... (3)
                                                     );
                obj.modules.(mod).AWGflush(chan);
                obj.writeport(0,0,chan);

            else
            
%                 obj.modules.(mod).waveformFlush();
                assert(A(1)<=1,'Need voltage between 0 and 1')
                obj.modules.(mod).modulationAmplitudeConfig(chan, mode, 1);
                obj.modules.(mod).modulationAngleConfig( chan, KeysightSD1.SD_ModulationTypes.AOU_MOD_PHASE, 180);

                obj.modules.(mod).channelWaveShape(chan, 1); 
    %             obj.(mod).channelAmplitude(chan, 0);
                wave = KeysightSD1.SD_Wave(KeysightSD1.SD_WaveformTypes.WAVE_ANALOG_DUAL, ones(1,20)*A(1),ones(1,20)*A(2));
                if wave.getStatus() <= 0
                    err = wave.getStatus();
                    error(['Error creating Waveform' num2str(err)]);
                else
                     if obj.modules.(mod).waveformLoad(wave,chan) <= 0 %load new WF with ID
                        error('Error loading Waveform');
                     end %loading 
                end
                err = obj.modules.(mod).AWGqueueWaveform(chan,chan,0,0,0,0) ;
                if err < 0 
                     error(['Error queueing Waveform to AWG ' num2str(chan)...
                         '. Errorcode: ' num2str(err)])
                end
                obj.modules.(mod).AWGstart(chan);
            end
            
            
        end
        
        function HDTstate(~, ~, ~)
            error('The method ''HDTstate'' is deprecated. Use setHDTstate() instead.')
        end %HDTstate
        
        function AOMstate(obj,chan,A,varargin)
            if ~obj.modules.(obj.selectedModule).AWGisRunning(chan)
                obj.setChannelFrequency(chan,80e6);
                obj.setChannelAmplitude(chan,0);
                obj.AWGstate(chan,A);
                obj.resetPID(chan);
            else 
                obj.AWGstate(chan,A);
            end
            if ~isempty(varargin) 
                if strcmp(varargin{1},'noLock')
                    obj.disablePID(chan);
                end
            else
                obj.enablePID(chan);
            end
            
        end %AOMstate
        
        
        
% % %         %% - LUT-Stuff
% % %         function ret = getLUTconfig(obj, chan)
% % %             assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
% % %                    'Positive integer required for channel number.');             
% % %             address = chan*4096;                       % hexadecimal address 16^3 = 4096
% % %             pBuffer = NET.createArray('System.Int32', 1023);
% % %             obj.modules.(obj.selectedModule).FPGAreadPCport(2, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
% % %             ret = pBuffer;
% % %         end %getPIDconfig
% % %         function config = getLUT(obj,chan) 
% % %              
% % %             assert(isnumeric(chan) && isscalar(chan) && chan>=0, ...
% % %                    'Positive integer required for channel number.');
% % %             
% % %             address = 0 + chan*4096;
% % %             pBuffer = NET.createArray('System.Int32', 1023);
% % %             obj.modules.(obj.selectedModule).FPGAreadPCport(2, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
% % %             config = pBuffer;
% % %         end   
% % %          function writeLUT(obj,data,nCH)
% % %             pBuffer = int32(data);
% % %             address = nCH*4096;                       % hexadecimal address 16^3 = 4096
% % %             
% % % %             try
% % %                 re = obj.modules.(obj.selectedModule).FPGAwritePCport(2, pBuffer, address, KeysightSD1.SD_AddressingMode.AUTOINCREMENT, KeysightSD1.SD_AccessMode.DMA);
% % % %             catch ME
% % % %                warning('%s\n\nError in %s (%s) (line %d)\n', ...
% % % %                         ME.message, ME.stack(1).('name'), ME.stack(1).('file'), ...
% % % %                         ME.stack(1).('line'));
% % % %             end
% % %             
% % %             if re == 0
% % % %                 obj.PIDconfig(nCH)
% % %             else
% % %                 error(['got errorcode ' re])
% % %             end
% % %         
% % %    
% % %          end
% % %          
% % %          
    end % methods
end
