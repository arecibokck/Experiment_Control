classdef Signadyne %#ok
    %SIGNADYNE signadyne debug constants that are otherwise given by .NET library
    
    properties (Constant)
        SD_Error = struct('STATUS_DEMO',1, 'OPENING_MODULE',-8000, 'CLOSING_MODULE',-8001, 'OPENING_HVI',-8002, 'CLOSING_HVI',-8003, 'MODULE_NOT_OPENED',-8004, 'MODULE_NOT_OPENED_BY_USER',-8005, 'MODULE_ALREADY_OPENED',-8006, 'HVI_NOT_OPENED',-8007, 'INVALID_OBJECTID',-8008, 'INVALID_MODULEID',-8009, 'INVALID_MODULEUSERNAME',-8010, 'INVALID_HVIID',-8011, 'INVALID_OBJECT',-8012, 'INVALID_NCHANNEL',-8013, 'BUS_DOES_NOT_EXIST',-8014, 'BITMAP_ASSIGNED_DOES_NOT_EXIST',-8015, 'BUS_INVALID_SIZE',-8016, 'BUS_INVALID_DATA',-8017, 'INVALID_VALUE',-8018, 'CREATING_WAVE',-8019, 'NOT_VALID_PARAMETERS',-8020, 'AWG_FAILED',-8021, 'DAQ_INVALID_FUNCTIONALITY',-8022, 'DAQ_POOL_ALREADY_RUNNING',-8023, 'UNKNOWN',-8024, 'INVALID_PARAMETERS',-8025, 'MODULE_NOT_FOUND',-8026, 'DRIVER_RESOURCE_BUSY',-8027, 'DRIVER_RESOURCE_NOT_READY',-8028, 'DRIVER_ALLOCATE_BUFFER',-8029, 'ALLOCATE_BUFFER',-8030, 'RESOURCE_NOT_READY',-8031, 'HARDWARE',-8032, 'INVALID_OPERATION',-8033, 'NO_COMPILED_CODE',-8034, 'FW_VERIFICATION',-8035, 'COMPATIBILITY',-8036, 'INVALID_TYPE',-8037, 'DEMO_MODULE',-8038, 'INVALID_BUFFER',-8039, 'INVALID_INDEX',-8040, 'INVALID_NHISTOGRAM',-8041, 'INVALID_NBINS',-8042, 'INVALID_MASK',-8043, 'INVALID_WAVEFORM',-8044, 'INVALID_STROBE',-8045, 'INVALID_STROBE_VALUE',-8046, 'INVALID_DEBOUNCING',-8047, 'INVALID_PRESCALER',-8048, 'INVALID_PORT',-8049, 'INVALID_DIRECTION',-8050, 'INVALID_MODE',-8051, 'INVALID_FREQUENCY',-8052, 'INVALID_IMPEDANCE',-8053, 'INVALID_GAIN',-8054, 'INVALID_FULLSCALE',-8055, 'INVALID_FILE',-8056, 'INVALID_SLOT',-8057, 'INVALID_NAME',-8058, 'INVALID_SERIAL',-8059, 'INVALID_START',-8060, 'INVALID_END',-8061, 'INVALID_CYCLES',-8062, 'HVI_INVALID_NUMBER_MODULES',-8063);
        SD_Object_Type = struct('HVI',1, 'AOU',2, 'TDC',3, 'DIO',4, 'WAVE',5, 'AIN',6, 'AIO',7);
        SD_Waveshapes = struct('AOU_OFF',-1, 'AOU_SINUSOIDAL',1, 'AOU_TRIANGULAR',2, 'AOU_SQUARE',4, 'AOU_DC',5, 'AOU_AWG',6, 'AOU_PARTNER',8);
        SD_WaveformTypes = struct('WAVE_ANALOG',0, 'WAVE_IQ',2, 'WAVE_IQPOLAR',3, 'WAVE_DIGITAL',5, 'WAVE_ANALOG_DUAL',7);
        SD_ModulationTypes = struct('AOU_MOD_OFF',0, 'AOU_MOD_FM',1, 'AOU_MOD_PHASE',2, 'AOU_MOD_AM', 1, 'AOU_MOD_OFFSET',2);
        SD_TriggerDirections = struct('AOU_TRG_OUT',1, 'AOU_TRG_IN',0);
        SD_TriggerBehaviors = struct('TRIGGER_NONE',0, 'TRIGGER_HIGH',1, 'TRIGGER_LOW',2, 'TRIGGER_RISE',3, 'TRIGGER_FALL',4);
        SD_MarkerModes = struct(); % todo
        SD_TriggerValue = struct('LOW',0, 'HIGH',1);
        SD_SyncModes = struct('SYNC_NONE',0, 'SYNC_CLK10',1);
        SD_AddressingMode = struct('AUTOINCREMENT',0, 'FIXED',1);
        SD_AccessMode = struct('NONDMA',0, 'DMA', 1);
        SD_TriggerModes = struct('AUTOTRIG',0, 'VIHVITRIG',1,	'SWHVITRIG',1, 'EXTTRIG',2, 'ANALOGTRIG',3, 'SWHVITRIG_CYCLE',5, 'EXTTRIG_CYCLE',6, 'ANALOGAUTOTRIG',7);
        SD_TriggerExternalSources = struct('TRIGGER_EXTERN',0, 'TRIGGER_PXI',4000, 'TRIGGER_PXI0',4000, 'TRIGGER_PXI1',4001, 'TRIGGER_PXI2',4002, 'TRIGGER_PXI3',4003, 'TRIGGER_PXI4',4004, 'TRIGGER_PXI5',4005, 'TRIGGER_PXI6',4006, 'TRIGGER_PXI7',4007);
    end %properties
    
    methods (Static)
        
        function wave = SD_Wave(type, data1, data2)
            wave = Devices.SD_WaveDebug(type, data1, data2);
        end %SD_Wave
        
        function module = SD_AIO()
            module = Devices.SD_AIODebug();
        end %SD_AIO
        
    end %methods
    
end
