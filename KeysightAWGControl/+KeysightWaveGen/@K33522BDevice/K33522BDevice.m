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
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %- Methods
    methods
        function this = K33522BDevice(DeviceID)
            % - Class Constructor
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
            this.vi.InputBufferSize  = 10000000; %Input buffer 10MB
            this.vi.OutputBufferSize = 10000000;
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
            
        end
        function connect(this)
            % - Connect to the VISA object specified in deviceID
            switch this.vi.status
                case 'closed'
                    fopen(this.vi);
                    disp('33522B connected')
                case 'open'
                    disp('33522B already connected')
                otherwise
                    error(['Invalid Value of this.vi.status: ' this.vi.status])
            end
        end
        function disconnect(this)
            % - Disconnect from the VISA object
            fclose(this.vi);
            disp('33522B disconnected')
        end
        function delete(this)
            % - Destructor
            this.disconnect();
            disp('33522B object deleted')
        end
    end % - Lifecycle functions
    methods
        function write(this, cmd)
            % - write for compatability
            send(this, cmd);
        end
        function send(this, data)
            % - Send a string to the VISA object
            fprintf(this.vi, [data '\n']);
        end
        function ret=read(this)
            % - Communication functions
            ret=fgetl(this.vi);
            ret = strtrim(ret); % remove carriage return
        end 
        function ret=readDouble(this)
            % - Read a string from the VISA interface and convert it do double
            ret=str2double(this.read());
        end 
        function ret=query(this, query)
            % - Send a query to the VISA object and return the result
            this.send(query);
            ret=this.read();
        end 
        function ret=queryInt(this, query)
            % - Send a query to the VISA object and convert the result to an integer
            this.send(query);
            ret=str2double(this.read());
        end 
        function ret=queryDouble(this, query)
            % - Send a query to the VISA object and convert the result to a double precision floating point number
            this.send(query);
            ret=this.readDouble();
        end 
    end % - read/write/query
    methods
        function ret=queryIdentification(this)
            % - get device ID
            ret=this.query('*IDN?');
        end 
        function ret=selfTest(this)
            % Performs a complete instrument self-test. If test fails,
            % one or more error messages will provide additional information
            this.write('*TST?');
            ret=this.read;
        end
        function resetDevice(this)
            % - reset device
            this.write('*RST');
        end 
        function ret=getError(this)
            % - queries for Errors
            % returns Error-Message  (e.g.: '+0,"No error"')
            ret=this.query('SYSTem:ERRor?');
        end 
        function Abort(this)
            this.send('ABORt');
        end
        function clearStatus(this)
            % - Clear device status
            this.write('*CLS');
        end 
        function ret = checkOPC(this)
            % - determine when the sweep or burst is complete. The *OPC? query returns 1 to the output buffer when the sweep or burst is complete
            ret = this.queryDouble('*OPC?');
        end    
        function busTrigger(this)
            % - send bus trigger
            this.write('*TRG');
        end  
        function wait(this)
            % Wait for all pending operations to complete
            this.write('*WAI');
        end
    end % - Basic
    methods
        function inititateImmediateTrigger(this,ChannelNumber)
            % Initiates immediate state for all channels
            if nargin ==1
                ChannelNumber = 'ALL';
            end
            if ischar(ChannelNumber)
            	assert(strcmpi(ChannelNumber,'ALL'),'Input Error: Channel must be 1,2 or "ALL"')
                 this.send('INITiate:IMMediate:ALL');
            else
                assert(numel(ChannelNumber)==1 && any(ChannelNumber ==[1,2]),'Input Error: Channel must be 1,2 or "ALL"')
                this.send(sprintf('INITiate%d:IMMediate',ChannelNumber));
            end
            
           
        end 
        function setContinuousTrigState(this, state)
            % Changes continuous trigger state for all channels
            assert(any(strcmpi(state, {'ON','OFF'})), ...
                'Trigger state must be specified as either "ON","OFF"');
            this.send(sprintf('INITiate:CONTinuous:ALL %s', state));
        end 
    end % - initiate 
    methods
        function ret = queryUpload(this, filename)
            % Uploads the contents of a file from the instrument to the host computer.
            assert(ischar(filename), 'Input Error: Provide filename as a character string!');
            ret = this.query(sprintf('MMEMory:UPLoad? "%s"', filename));
        end
        function downloadDataFile(this, filename)
            % - specifies file name for downloading data from the computer to instrument's Mass Memory
            assert(ischar(filename), 'Input Error: Provide filename as a character string!');
            this.send(sprintf('MMEMory:DOWNload:FNAMe "%s"', filename));
        end 
        function downloadBinBlockData(this, dat)
            % -downloads data from the host computer to instrument's Mass Memory
            assert(ischar(dat), 'Input Error: Provide bin block data as a character string!');
            this.send(sprintf('MMEMory:DOWNload:DATA %s', dat));
        end
        function deleteData(this, filename)
            % - removes files from Mass Memory device
            assert(ischar(dat), 'Input Error: Provide filename as a character string!');
            this.send(sprintf('MMEMory:DELete "%s"', filename));
        end
    end % - MMEMory:  Up- and  download data to mass memory
    methods
        function syncChannels(this)
            % Causes two independent arbitrary waveforms to synchronize to first point 
            % of each waveform (two-channel instruments only).
            this.send('FUNCtion:ARBitrary:SYNChronize');
        end 
        
    end % - arbitrary waveforms
    methods
        function fig = preview(this,varargin)
            
            fig =1;
        end
        
    end % - plotting  
    methods (Static)
        %[Network_Devices_List,Network_Devices_List_Structured] = enumerateETHERNET;
        %[USB_Devices_List,USB_Devices_List_Structured] = enumerateUSB(~, szFilter);
        function findAndConnectToDevice(this, MacAdress,ConnectionType)
            
            % - input handling
            if nargin ==1
                ConnectionType = 'Ethernet';
            end
            
            assert(any(strcmpi(MacAdress,{'Ethernet','USB'})),'ConnectionType must be "" or ""')
            
            % - find Device
            switch ConnectionType
                case 'USB'
                    %-Get list of Connected USB-Devices
                    [~,USB_Devices_List_Structured] = enumerateUSB('USBTestAndMeasurementDevice');
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