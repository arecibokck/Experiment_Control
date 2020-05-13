function scanLaserFrequency(lasername, ScanDevice, varargin)
%% Defaults and Input Parsing
global LaserID daqSession trigConfig

p = inputParser;

addRequired (p, 'lasername' , @ ischar);
addRequired (p, 'ScanDevice' , @ isnumeric);

defaultLowerLimit = 0.34;
defaultUpperLimit = 0.35;

addOptional (p, 'LowerLimit', defaultLowerLimit, @ (x) assert (isnumeric (x) && isscalar (x) && (x >= 0), ...
             'Value must be positive, scalar, and numeric in the interval [0, 0.7].'))
addOptional (p, 'UpperLimit', defaultUpperLimit, @ (x) assert (isnumeric (x) && isscalar (x) && (x <= 0.7), ...
             'Value must be positive, scalar, and numeric in the interval [0, 0.7].'))

defaultRisingSpeed  = 8.0000e-03;
defaultFallingSpeed = 8.0000e-03;

addOptional (p, 'RisingSpeed', defaultRisingSpeed, @ (x) assert (isnumeric (x) && isscalar (x) && (x > 0), ...
             'Value must be positive, scalar, and numeric.'))
addOptional (p, 'FallingSpeed', defaultFallingSpeed, @ (x) assert (isnumeric (x) && isscalar (x) && (x > 0), ...
             'Value must be positive, scalar, and numeric.'))

parse (p, lasername, ScanDevice, varargin{:});

switch p.Results.lasername
    case 'CR'
        LaserID = 'USB0::0x17E7::0x0101::19-05-02::INSTR'; % CR Laser
        if p.Results.ScanDevice > 1
            error('No scan device available other than Slow Piezo (Code: 1).');
        end
    case 'CS'
        LaserID = 'USB0::0x17E7::0x0102::19-05-31::INSTR'; % CS Laser
    otherwise
        error('ID does not match available Lasers! Re-enter correct ID to choose between CR or CS to scan.');
end

deviceInUse = 'USB-6000';
analogInputChannel = 'ai3';
measurementType = 'Voltage';

%% Initialize Matisse Laser

Laser = Devices.SirahMatisseLasers.LaserControl(LaserID);

Laser.connect();
Laser.clearErrors();

pause(1)
if strcmp(Laser.getScanStatus, 'RUN')
    Laser.setScanStatus('STOP');
end
pause(1)
if str2double(Laser.getScanDevice()) ~= p.Results.ScanDevice
    Laser.setScanDevice(p.Results.ScanDevice)
end

if str2double(Laser.getScanPosition()) ~= round(p.Results.LowerLimit, 4)
    Laser.setScanPosition(p.Results.LowerLimit)
    
    while str2double(Laser.getScanPosition()) ~= round(p.Results.LowerLimit, 4)
        pause(2);
    end
end

Laser.setScanLowerLimit(p.Results.LowerLimit)
Laser.setScanUpperLimit(p.Results.UpperLimit)

Laser.setScanRisingSpeed(p.Results.RisingSpeed)
Laser.setScanFallingSpeed(p.Results.FallingSpeed)

pause(1)

%% Initialize NI DAQ

deviceList = daq.getDevices();
for i = 1:length(deviceList)
    if strcmp(deviceList(i).Model, deviceInUse)
        daqSession = daq.createSession(deviceList(i).Vendor.ID);
        Channel = addAnalogInputChannel(daqSession, deviceList(i).ID, analogInputChannel, measurementType);
        Channel.TerminalConfig = 'SingleEnded'; % Set acquisition configuration for channel
        trigConfig.ThresholdLevel = 2;
        daqSession.Rate = 10000; % Set acquisition rate, in scans/second
    end
end

if ~isvalid(daqSession) || isempty(daqSession) 
    Laser.disconnect();
    delete(Laser)
    delete(daqSession);
    error('Could not find DAQ device. Make sure it is connected and the correct model identifier is entered!');
end

%% Wait for Adwin Trigger and launch Laser Frequency Scan

% Add a listener for DataAvailable events and specify the callback function
% The specified data capture parameters are passed as additional arguments to the callback function.
dataListener = addlistener(daqSession, 'DataAvailable', @(src,event) toggleScanOnTrigger(src, event, Laser));

% Add a listener for acquisition error events which might occur during background acquisition
errorListener = addlistener(daqSession, 'ErrorOccurred', @(src,event) disp(getReport(event.Error)));

% Start continuous background data acquisition
daqSession.IsContinuous = true;
startBackground(daqSession);

while daqSession.IsRunning
    pause(0.5);
end

%% Disconnect from Laser and delete objects
Laser.disconnect();
delete(Laser);
delete(daqSession);
delete(dataListener);
delete(errorListener);

%% Methods for trigger detection and toggling Scan on trigger

function trigDetected = trigDetect(prevData, latestData, trigConfig)
    trigLevelCondition = latestData(end, 2) > trigConfig.ThresholdLevel;

    data = [prevData; latestData];

    % Calculate slope of signal data points
    % Calculate time step from timestamps
    dt = latestData(2,1)-latestData(1,1);
    slope = mean(diff(data(:, 2))/dt);

    % Condition for Rising signal trigger level
    trigCondition1 = slope > 0;

    % Condition for Falling signal trigger slope
    trigCondition2 = slope < 0;

    % If first data block acquired, slope for first data point is not defined
    if isempty(prevData)
        trigCondition1 = false;
        trigCondition2 = false;
    end
    
    % Combined trigger condition to be used
    trigCondition = (trigLevelCondition && trigCondition1) || (~trigLevelCondition && trigCondition2);
    trigDetected = any(trigCondition);
end

function toggleScanOnTrigger(src, event, Laser)
    %  Process DAQ acquired data when called by DataAvailable event and
    %  toggles action (here Laser Frequency Scan) on trigger

    %  toggleScanOnTrigger (SRC, EVENT) processes latest acquired data (EVENT.DATA)
    %  and timestamps (EVENT.TIMESTAMPS) from session (SRC), and, based on
    %  trigger condition carries out specified action.

    % The incoming data (event.Data and event.TimeStamps) is stored in a
    % persistent buffer (dataBuffer)

    % Since multiple calls to dataCapture will be needed for a triggered
    % capture, a trigger condition flag (trigActive) and a corresponding
    % data timestamp (trigMoment) are used as persistent variables.
    % Persistent variables retain their values between calls to the function.

    persistent dataBuffer trigActive scanToggle
    
    if isempty(scanToggle)
        scanToggle = true;
    end
    
    % If dataCapture is running for the first time, initialize persistent vars
    if event.TimeStamps(1)==0
        dataBuffer = [];          % data buffer
        trigActive = false;       % trigger condition flag
        prevData = [];            % last data point from previous callback execution
    else
        prevData = dataBuffer(end, :);
    end

    % Store continuous acquisition data in persistent FIFO buffer dataBuffer
    latestData = [event.TimeStamps, event.Data];
    dataBuffer = [dataBuffer; latestData];
    
    if ~trigActive
        % State: "Looking for trigger event"
        % Determine whether trigger condition is met in the latest acquired data
        % A custom trigger condition is defined in trigDetect user function
        trigActive = trigDetect(prevData, latestData, trigConfig);
        if scanToggle && trigActive
            Laser.setScanStatus('RUN')
            % Reset scanToggle and trigger flag, to allow for a new trigger capture and subsequent toggle of the scan status
            scanToggle = false;
            trigActive = false;    
        elseif ~scanToggle && trigActive
            pause(1)
            Laser.setScanStatus('STOP')
            pause(1)
            Laser.setScanDevice(0);
            stop(src);
        end
    end
end
end