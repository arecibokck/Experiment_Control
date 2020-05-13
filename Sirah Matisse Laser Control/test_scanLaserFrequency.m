% $LastChangedDate$
% $Rev$

%% Helper Function to scan Sirah Matisse laser frequency synced to external trigger
function scanLaserFrequency(lasername, ScanDevice, varargin)
%% Defaults and Input Parsing
global daqSession CounterInputChannel DigitalOutputChannel

p = inputParser;

addRequired (p, 'lasername' , @ ischar);
addRequired (p, 'ScanDevice' , @ isnumeric);

defaultLowerLimit = 0.34;
defaultUpperLimit = 0.34;

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

%% Connect to and initialize Matisse Laser

Laser = Devices.SirahMatisseLasers.LaserControl(LaserID);

% Laser.connect();
% Laser.clearErrors();
% 
% if strcmp(Laser.getScanStatus, 'RUN')
%     Laser.setScanStatus('STOP');
% end
% 
% pause(0.5)
% 
% if str2double(Laser.getScanDevice()) ~= p.Results.ScanDevice
%     Laser.setScanDevice(p.Results.ScanDevice)
% end
% 
% if str2double(Laser.getScanPosition()) ~= round(p.Results.LowerLimit, 4)
%     Laser.setScanPosition(p.Results.LowerLimit)
%     
%     while str2double(Laser.getScanPosition()) ~= round(p.Results.LowerLimit, 4)
%         pause(2);
%     end
% end
% 
% Laser.setScanLowerLimit(p.Results.LowerLimit)
% Laser.setScanUpperLimit(p.Results.UpperLimit)
% 
% Laser.setScanRisingSpeed(p.Results.RisingSpeed)
% Laser.setScanFallingSpeed(p.Results.FallingSpeed)

%% Initialize NI DAQ

deviceList = daq.getDevices();
for i = 1:length(deviceList)
    if strcmp(deviceList(i).Model, 'USB-6000')
        daqSession = daq.createSession(deviceList(i).Vendor.ID);
        CounterInputChannel = addCounterInputChannel(daqSession,  deviceList(i).ID, 'ctr0', 'EdgeCount');
        DigitalOutputChannel = addDigitalChannel(daqSession, deviceList(i).ID, 'Port0/Line2:2', 'OutputOnly');
    end
end

if ~isvalid(daqSession) || isempty(daqSession) 
    Laser.disconnect();
    delete(Laser)
    delete(daqSession);
    error('Could not find DAQ device. Make sure it is connected and the correct model identifier is entered!');
end

%% Detect external trigger and toggle Scan - Start scan on High, Stop scan on Low

daqSession.IsContinuous = true;

count = 0;
CounterInputChannel.ActiveEdge = 'Rising';
while count ~= 1
    count = inputSingleScan(daqSession);
end

if count == 1
%     Laser.setScanStatus('RUN');
    outputSingleScan(daqSession, 1)
    disp('Rising')
    count = 0;
    resetCounters(daqSession);
end

CounterInputChannel.ActiveEdge = 'Falling';  
while count ~= 1
    count = inputSingleScan(daqSession);
end

if count == 1
%     Laser.setScanStatus('STOP')
%     pause(0.5)
%     Laser.setScanDevice(0);
    outputSingleScan(daqSession, 0)
    disp('Falling')
    resetCounters(daqSession);
end

wait(daqSession);
release(daqSession);

%% Disconnect from Laser and delete objects
Laser.disconnect();
delete(Laser);
delete(daqSession);

end

