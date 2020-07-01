% class for communicating with an Keysight 33522B arbitrary waveform
% generator and upload an arbitrary voltage ramp for triggered execution

classdef K33522BDevice < Devices.Device
    
    properties (SetAccess=immutable)
    	% specifies, wheter devices is in debug-mode
        debug;
        DEFAULTID = 'TCPIP::131.220.157.72::INSTR';
    end
    
    properties
        vi
        deviceID
        Model
        NumberOfChannels
        channels=Devices.KeysightWaveGen.K33522BChannel.empty;
    end
    
    properties (Dependent)
        % slope of trigger (Pos)|Neg
        TriggerSlope
        % source of Trigger ={'IMM','BUS','EXT','INT'};
        TriggerSource
        % NumberOfTriggers accepted (will do measurement this many times)
        TriggerCount
    end % - Trigger
    
    properties (Dependent)
        VoltageDCRange
        VoltageDCRangeAuto
        VoltageImpedanceAuto
        VoltageResolution
        VoltageZeroAuto
    end % - DC-Voltage
    
    properties (Dependent)
       Burst
       BurstCyc
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %- Methods
    methods 
        function this = K33522BDevice(DeviceID)
            %
            disp('Constructing Keysight33522B object...')
            
            % - set DeviceID
            switch DeviceID
                case 'DEFAULTID'
                    this.deviceID = this.DEFAULTID;
                case 'debug'
                    this.deviceID = 'debug';
                otherwise
                    this.deviceID = DeviceID;
            end
            
            % - create and init Visa-Object
            if strcmp(this.deviceID,'debug')
                this.vi=Devices.DebugVisa('agilent', this.deviceID);
            else
                this.vi = visa('agilent', this.deviceID);
            end
            this.vi.InputBufferSize = 10000000; %Input buffer 10MB
            this.vi.Timeout = 10;
            this.vi.ByteOrder = 'littleEndian';
            
            this.NumberOfChannels     =        2;
            this.Model                = '33522B';
            
            % - connect
            this.connect;
            
            % - Initialize Channels
            this.channels(1) = Devices.KeysightWaveGen.K33522BChannel(this, 1);
            this.channels(2) = Devices.KeysightWaveGen.K33522BChannel(this, 2);
            
            % notify success
            disp('Keysight 33522B Wave Generator online & Keysight 33522B Device object constructed.');
            
        end% Class Constructor
        function connect(this)
            switch this.vi.status
                case 'closed'
                    fopen(this.vi);
                    disp('33522B connected')
                case 'open'
                    disp('33522B already connected')
                otherwise
                    error(['Invalid Value of this.vi.status: ' this.vi.status])
            end
        end% - Connect to the VISA object specified in deviceID
        function disconnect(this)
            fclose(this.vi);
            disp('33522B disconnected')
        end% - Disconnect from the VISA object
        function delete(this)
            this.disconnect();
            disp('33522B object deleted')
        end% - Destructor
    end % - Lifecycle functions     
    methods 
        function write(this, cmd)
            send(this, cmd);
        end % - write for compatability
        function send(this, data)
            fprintf(this.vi, [data '\n']);
        end% - Send a string to the VISA object
        function ret=read(this)
            ret=fgetl(this.vi);
        end % - Communication functions
        function ret=readDouble(this)
            ret=str2double(this.read());
        end % - Read a string from the VISA interface and convert it do double
        function ret=query(this, query)
            this.send(query);
            ret=this.read();
        end % - Send a query to the VISA object and return the result
        function ret=queryInt(this, query)
            this.send(query);
            ret=str2num(this.read());
        end % - Send a query to the VISA object and convert the result to an integer
        function ret=queryDouble(this, query)
            this.send(query);
            ret=this.readDouble();
        end % - Send a query to the VISA object and convert the result to a double precision floating point number
    end % - read/write/query
    methods 
        function clearStatus(this)
            this.write('*CLS');
        end % - ClearStatus
        function resetDevice(this) 
            this.write('*RST');
        end % - *RST -commmand
        function ret=queryIdentification(this)
            ret=this.query('*IDN?');
            ret=ret(1:end-1);
        end
        function ret=selfTest(this)
            % ret=SelfTest(this) sends '*TST?'-command and returns 1 iff
            this.write('*TST?');
            ret=this.read;
            ret=ret(1:end-1);
        end
        function ret=getError(this)
            % ret=getError(this) queries for Errors 
        % returns Error-Message  (e.g.: '+0,"No error"')
            ret=this.query('SYST:ERR?');
            ret=ret(1:end-1);
        end % - ret=getError(this) queries for Errors 
        function Abort(this)
            this.send('ABORt');
        end
    end % - Basic 
    methods (Static)
        [Network_Devices_List,Network_Devices_List_Structured] = enumerateETHERNET;
        [USB_Devices_List,USB_Devices_List_Structured] = enumerateUSB(~, szFilter);
        function [isConnected, Address] = findDevice(MacAdress,ConnectionType)
            
            % - input handling
            if nargin ==1
                ConnectionType = 'Ethernet';
            end
            
            assert(any(strcmpi(MacAdress,{'Ethernet','USB'})),'ConnectionType must be "" or ""')
            
            % - find Device
            switch ConnectionType
                case 'USB'
                    %-Get list of Connected USB-Devices
                    [USB_Devices_List,USB_Devices_List_Structured] = enumerateUSB('USBTestAndMeasurementDevice');
                    %-Check which ControllerDevice are Connected
                    disp('Checking which AWG Devices are connected via USB...')
                    Temp_ListOfConnectedDevices = struct2cell(USB_Devices_List_Structured);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(2,:,:);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(:);
                    
                    for Index = 1:length(this.AWGDeviceInfo)
                        Temp_productID = AWGDeviceInfo(Index).productID;
                        if any(contains(vertcat(Temp_ListOfConnectedDevices{:}), ['PID_' Temp_productID]))
                            IsConnected2PCViaUSB=1;
                        disp([AWGDeviceInfo.Alias ' with PID: ', Temp_productID, ' connected to PC via USB.'])
                        else
                            disp(['Warning: ' this.AWGDeviceInfo.Alias ' not connected to PC via USB.'])
                        end
                    end
                    %-Create objects for each ControllerDevice and open connection
                    for Index=1:length(this.AWGDeviceInfo)
                        %-Create objects for each ControllerDevice and open connection
                        Temp_Name         = this.AWGDeviceInfo(Index).Alias;
                        Temp_productID    = this.AWGDeviceInfo(Index).productID;
                        Temp_USBAddress   = this.AWGDeviceInfo(Index).USBAddress;
                        if this.AWGDeviceInfo(Index).IsConnected2PCViaUSB==1
                            %Establish USB-Connection
                            this.ConnectToDevice('USB');
                            disp(['USB-connection to AWG Device (',Temp_Name,'; PID: ',Temp_productID, ') established!'])
                        end
                    end
                    clear Index
                case 'ETHERNET'
                    [this.Network_Devices_List,this.Network_Devices_List_Structured] = this.enumerateETHERNET;
                    %-Check which AWGDevice are Connected
                    disp('Checking which AWGs are connected via ETHERNET...')
                    Temp_ListOfConnectedDevices = struct2cell(this.Network_Devices_List_Structured);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(2,:,:);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(:);
                    
                    for Index = 1:length(this.AWGDeviceInfo)
                        Temp_MACAddress = this.AWGDeviceInfo(Index).MACAddress;
                        if any(contains(Temp_ListOfConnectedDevices, Temp_MACAddress))
                            Temp_IPAddress = this.Network_Devices_List_Structured(contains(Temp_ListOfConnectedDevices, Temp_MACAddress)).IPADDR ;
                            if ~strcmp(Temp_IPAddress, this.AWGDeviceInfo(Index).IPAddress)
                               this.AWGDeviceInfo(Index).IPAddress = Temp_IPAddress;
                            end
                            this.AWGDeviceInfo(Index).IsConnected2PCViaETHERNET=1;
                            disp([this.AWGDeviceInfo(Index).Alias ' with IP Address ' Temp_IPAddress ' connected to PC via ETHERNET.'])
                        else
                            warning([this.AWGDeviceInfo(Index).Alias ' not connected to PC via ETHERNET.'])
                        end
                    end
                    clear Index
                    %-Create objects for each AWGDevice and open connection
                    for Index=1:length(this.AWGDeviceInfo)
                        Temp_Name               = this.AWGDeviceInfo(Index).Alias;
                        Temp_productID          = this.AWGDeviceInfo(Index).productID;
                        Temp_IPAddress          = this.AWGDeviceInfo(Index).IPAddress;
                        Temp_Port               = this.AWGDeviceInfo(Index).Port;
                        if this.AWGDeviceInfo(Index).IsConnected2PCViaETHERNET==1
                            %Establish Ethernet-Connection
                            this.AWGDevice.ConnectToDevice('ETHERNET');
                            disp(['ETHERNET-connection to AWG Device', '(',Temp_Name,'; PID_ ',Temp_productID, ') with IP addr', Temp_IPAddress, 'at Port ', Temp_Port, ' established'])
                        end
                    end
                    clear Index
            end
            
        end
    end %- Static methods
end