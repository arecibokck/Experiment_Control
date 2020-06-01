% NP_8742_Controller class to communicate with Controllers from
% New Focus Piezo Controller 8742. It connects to the controllers via USB or ethernet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef  NP_PicomotorController < Devices.Device
    
    %- Properties
    
    properties (Constant)
        
        ControllerDeviceInfoDefault = struct('Alias',     'Picomotor 8742 Controller Device_1', ...
                                             'productID',                               '4000', ...
                                             'deviceKey',                         '8742-65992', ...
                                             'USBAddress',                                   1, ...
                                             'IPAddress',                     '131.220.157.42', ...
                                             'MACAddress',                 '58-ec-e1-00-ea-b8', ...
                                             'Port',                                        23, ...
                                             'IsConnected2PCViaUSB',                         0, ...
                                             'IsConnected2PCViaETHERNET',                    0);
        PicomotorScrewsInfoDefault=[...
            ...
            ...
            ...
            ...            --- 5AxisStage ---
            ...
            ... Axis 01
                struct('Alias',         'OptPol_x_front',             ...
                       'ControllerProductID',       '4000',             ...
                       'ControllerDeviceKey', '8742-65992',             ...
                       'MotorProperties',...
                        struct('ChannelNumber',  1,             ...
                               'MotorType',      2,             ...
                               'HomePosition',   0,             ...
                               'Velocity',     400,             ...
                               'Acceleration', 100));           ...
            
            ... Axis 02
                struct('Alias',         'OptPol_x_back',             ...
                       'ControllerProductID',       '4000',             ...
                       'ControllerDeviceKey', '8742-65992',             ...
                       'MotorProperties',...
                        struct('ChannelNumber',NaN,            ...
                               'MotorType',      2,             ...
                               'HomePosition',   0,             ...
                               'Velocity',     400,             ...
                               'Acceleration', 100));           ...
            
            ... Axis 03
                struct('Alias',         'OptPol_y_front',             ...
                       'ControllerProductID',       '4000',             ...
                       'ControllerDeviceKey', '8742-65992',             ...
                       'MotorProperties',                               ...
                        struct('ChannelNumber',  3,             ...
                               'MotorType',      2,             ...
                               'HomePosition',   0,             ...
                               'Velocity',     400,             ...
                               'Acceleration', 100));           ...
            
            ... Axis 04
                struct('Alias',         'OptPol_y_back',             ...
                       'ControllerProductID',       '4000',             ...
                       'ControllerDeviceKey', '8742-65992',             ...
                       'MotorProperties',...
                        struct('ChannelNumber',  4,             ...
                               'MotorType',      2,             ...
                               'HomePosition',   0,             ...
                               'Velocity',     400,             ...
                               'Acceleration', 100));           ...
            
            %... Axis 05 Not connected
                struct('Alias',         'OptPol_z',             ...
                       'ControllerProductID',       '4000',             ...
                       'ControllerDeviceKey', '8742-65992',             ...
                       'MotorProperties',                               ...
                        struct('ChannelNumber',  2,             ...
                               'MotorType',      2,             ...
                               'HomePosition',   0,             ...
                               'Velocity',       400,             ...
                               'Acceleration',   100));           ...
            
            ];
    end
    
    properties
        ConnectionType = 'ETHERNET';        %Toggle connection between either via USB or ETHERNET
        USB_Devices_List;                   %Char array, each row contains Info on connected USB-Controllers
        USB_Devices_List_Structured;        %Struct  of Chars, Each row of "USB_Devices_List"
        Network_Devices_List;
        Network_Devices_List_Structured;
    end % - connection
    
    properties
        ControllerDevice={};                %Contains ControllerDevice objects
        ControllerDeviceInfo=struct();      %Contains Information
        PicomotorScrewsInfo=struct();       %Contains structs with Info
        %about Picomotor screws
        
        
        %-PicomotorScrews
        PicomotorScrews=struct(...
            'OptPol_x_front',[],...
            'OptPol_x_back',[],...
            'OptPol_y_front',[],...
            'OptPol_y_back',[],....
            'OptPol_z',[]....
            );
    end % - public
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %- Methods
    methods %Lifecycle functions
        %% Class Constructor
        function this = NP_PicomotorController()
            progressbar = waitbar(0, sprintf('Creating picomotor controller object...(%.f%%)', 0), 'Name','Please Wait');
            pause(1)
            disp('NP_PicomotorController object is being constructed...')
            this@Devices.Device;
            %-Load DefaultData
            this.ControllerDeviceInfo=this.ControllerDeviceInfoDefault;
            this.PicomotorScrewsInfo=this.PicomotorScrewsInfoDefault;
            switch this.ConnectionType
                case 'USB'
                    %-Get list of Connected USB-Devices
                    [this.USB_Devices_List,this.USB_Devices_List_Structured] = this.enumerateUSB('USBDevice');
                    %-Check which ControllerDevice are Connected
                    disp('Checking which ControllerDevices are connected via USB...')
                    Temp_ListOfConnectedDevices = struct2cell(this.USB_Devices_List_Structured);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(2,:,:);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(:);
                    for Index = 1:length(this.ControllerDeviceInfo)
                        Temp_productID = this.ControllerDeviceInfo(Index).productID;
                        if any(contains(vertcat(Temp_ListOfConnectedDevices{:}), ['PID_' Temp_productID]))
                            this.ControllerDeviceInfo(Index).IsConnected2PCViaUSB=1;
                            disp([this.ControllerDeviceInfo(Index).Alias ' with product class ID ' Temp_productID ' connected to PC via USB.'])
                        else
                            disp(['Warning: ' this.ControllerDeviceInfo(Index).Alias ' not connected to PC via USB.'])
                        end
                    end
                    clear Index
                    %-Create objects for each ControllerDevice and open connection
                    for Index=1:length(this.ControllerDeviceInfo)
                        Temp_productID    = this.ControllerDeviceInfo(Index).productID;
                        Temp_deviceKey    = this.ControllerDeviceInfo(Index).deviceKey;
                        Temp_USBAddress   = this.ControllerDeviceInfo(Index).USBAddress;
                        Temp_Name         = this.ControllerDeviceInfo(Index).Alias;
                        if this.ControllerDeviceInfo(Index).IsConnected2PCViaUSB==1
                            disp('NP_PicomotorControllerDevice object is being constructed...')
                            %create object
                            this.ControllerDevice{Index}=Devices.NP_PicomotorControllerDevice(Temp_productID, Temp_deviceKey, 'USBADDR', Temp_USBAddress);
                            disp('NP_PicomotorControllerDevice object created.')
                            if Index == 1
                                %Establish USB-Connection
                                this.ControllerDevice{Index}.ConnectToDevice('USB');
                            end
                            disp(['USB-connection to ControllerDevice ',num2str(Index),'(',Temp_Name,') established'])
                        end
                    end
                    clear Index
                case 'ETHERNET'
                    %-Get list of Connected USB-Devices
                    [this.Network_Devices_List,this.Network_Devices_List_Structured] = this.enumerateETHERNET;
                    %-Check which ControllerDevice are Connected
                    disp('Checking which ControllerDevices are connected via ETHERNET...')
                    Temp_ListOfConnectedDevices = struct2cell(this.Network_Devices_List_Structured);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(2,:,:);
                    Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(:);
                    for Index = 1:length(this.ControllerDeviceInfo)
                        Temp_MACAddress = this.ControllerDeviceInfo(Index).MACAddress;
                        if any(contains(Temp_ListOfConnectedDevices, Temp_MACAddress))
                            Temp_IPAddress = this.Network_Devices_List_Structured(contains(Temp_ListOfConnectedDevices, Temp_MACAddress)).IPADDR ;
                            if ~strcmp(Temp_IPAddress, this.ControllerDeviceInfo(Index).IPAddress)
                               this.ControllerDeviceInfo(Index).IPAddress = Temp_IPAddress;
                            end
                            this.ControllerDeviceInfo(Index).IsConnected2PCViaETHERNET=1;
                            disp([this.ControllerDeviceInfo(Index).Alias ' with IP Address ' Temp_IPAddress ' connected to PC via ETHERNET.'])
                        else
                            warning([this.ControllerDeviceInfo(Index).Alias ' not connected to PC via ETHERNET.'])
                        end
                    end
                    clear Index
                    waitbar(.02, progressbar, sprintf('Creating controller device objects...(%.f%%)', 2));
                    pause(1)
                    %-Create objects for each ControllerDevice and open connection
                    for Index=1:length(this.ControllerDeviceInfo)
                        Temp_productID          = this.ControllerDeviceInfo(Index).productID;
                        Temp_deviceKey          = this.ControllerDeviceInfo(Index).deviceKey;
                        Temp_IPAddress          = this.ControllerDeviceInfo(Index).IPAddress;
                        Temp_Port          = this.ControllerDeviceInfo(Index).Port;
                        Temp_Name               = this.ControllerDeviceInfo(Index).Alias;
                        if this.ControllerDeviceInfo(Index).IsConnected2PCViaETHERNET==1
                            disp('NP_PicomotorControllerDevice object is being constructed...')
                            %create object
                            this.ControllerDevice{Index}=Devices.NP_PicomotorControllerDevice(Temp_productID, Temp_deviceKey, 'IPADDR', Temp_IPAddress, 'Port', Temp_Port);
                            disp('NP_PicomotorControllerDevice object created.')
                            this.ControllerDevice{Index}.ConnectToDevice('ETHERNET');
                            disp(['ETHERNET-connection to ControllerDevice ',num2str(Index),'(',Temp_Name,') established'])
                        end
                    end
                    clear Index
            end
            
            waitbar(.04, progressbar, sprintf('Creating & initializing picomotor screw objects...(%.f%%)', 4));
            pause(1)
            %-Create objects for each PicomotorScrew
            for Index=1:length(this.PicomotorScrewsInfo)
                %-Get temporary Variables
                Alias = this.PicomotorScrewsInfo(Index).Alias;
                Temp_ControllerDeviceKey = this.PicomotorScrewsInfo(Index).ControllerDeviceKey;
                MotorProperties=this.PicomotorScrewsInfo(Index).MotorProperties;
                Temp_ControllerDeviceNumber = double.empty;
                %-Get Temp_ControllerDeviceNumber
                %-search list of Controller-Devices
                for IndexTwo=1:length(this.ControllerDevice)
                    Temp_deviceKey=this.ControllerDevice{IndexTwo}.deviceKey;
                    Temp_IsConnected = this.ControllerDeviceInfo(IndexTwo).IsConnected2PCViaUSB || this.ControllerDeviceInfo(IndexTwo).IsConnected2PCViaETHERNET ;
                    if(strcmp(Temp_deviceKey,Temp_ControllerDeviceKey)) && Temp_IsConnected == 1
                        Temp_ControllerDeviceNumber=IndexTwo;
                    end
                end
                if ~isempty(Temp_ControllerDeviceNumber)
                    %-Test if 'Alias' is declared as Property
                    assert(isfield(this.PicomotorScrews,Alias),'Error: Alias of PicomotorScrews does not exist as Property, check Properties.')
                    disp('NP_PicomotorScrews object is being constructed...')
                    %-Create object
                    this.PicomotorScrews.(Alias) = Devices.NP_PicomotorScrews(Alias, MotorProperties, Temp_ControllerDeviceNumber, 'ControllerDeviceObject', this.ControllerDevice{Temp_ControllerDeviceNumber});
                    disp([Alias ' NP_PicomotorScrews object created.'])
                else
                    warning(['NP_PicomotorScrews object for ' Alias ' not created since its controller is not connected to PC!'])
                end
                if Index ~= length(this.PicomotorScrewsInfo)
                    p = Index/length(this.PicomotorScrewsInfo);
                    waitbar(p, progressbar, sprintf('Creating & initializing picomotor screw objects...(%.f%%)', p*100));
                    pause(1)
                end
            end
            waitbar(1, progressbar,sprintf('Finishing...(%.f%%)', 100));
            pause(1)
            %- Show finish message:
            disp('NP_PicomotorController object created.')
            close(progressbar)
        end
        %% Class Destructor (Closes Connection, Clears object)
        function delete(this)
            className = class(this);
            disp(['Destructor called for class ',className])
            %-delete all Controller objects
            if (~isempty(this.ControllerDevice))
                cellfun(@(m)m.delete,this.ControllerDevice);
            end
        end
        %% Create GUI
        function GUI(~)
        % GUI(this) invokes the Graphical User Interface (GUI) by calling
        % the script 'NF8082StageControllerGui' which currently is for
        % individual controller devices  
            NF8082StageControllerGuiV2
        end
        %% Disconnect from specified controller
        function disconnectPicomotorController(this,NumberOfDevice)
            % disconnects from ControllerDevice number "NumberOfDevice"
            % input     NumberOfDevice   1|2|3
            % - input control
            assert(isnumeric(NumberOfDevice) && isscalar(NumberOfDevice) && mod(NumberOfDevice,1)==0,...
                'InputError:  NumberOfDevice must be an integer corresponding to each plugged device.')
            % - disconnect
            if this.ControllerDevice{NumberOfDevice}.IsControllerReady
                this.ControllerDevice{NumberOfDevice}.DisconnectFromDevice();
            end
        end
        %% Reconnects to specified controller
        function reconnectPicomotorController(this,NumberOfDevice)
            % reconnects to ControllerDevice number "NumberOfDevice"
            % input     NumberOfDevice   1|2|3
            % - input control
            assert(isnumeric(NumberOfDevice) && isscalar(NumberOfDevice) && mod(NumberOfDevice,1)==0,...
                'InputError:  NumberOfDevice must be an integer corresponding to each plugged device.')
            % - reconnect if necessary
            if ~(this.ControllerDevice{NumberOfDevice}.IsControllerReady)
                this.ControllerDevice{NumberOfDevice}.ConnectToDevice(this.ControllerDevice{NumberOfDevice}.ConnectionType);
%                 switch this.ConnectionType
%                     case 'USB'
%                         this.ControllerDevice{NumberOfDevice}.ConnectToDevice('USB');
%                     case 'ETHERNET'
%                         this.ControllerDevice{NumberOfDevice}.ConnectToDevice('ETHERNET');
%                 end
%                 disp('Reconnected!');
            else 
                disp(['ControllerDevice(' num2str(NumberOfDevice) ') still connected']);
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Methods (Static)
    methods (Static)
        
        % Creates an Instance of Class, ensures singleton behaviour (that there
        % can only be one Instance of this class
        function singleObj = getInstance(varargin)
            % Creates an Instance of Class, ensures singleton behaviour
            persistent localObj;
            if isempty(localObj) || ~isvalid(localObj)
                localObj =  Devices.NP_PicomotorController(varargin{:});
            end
            singleObj = localObj;
        end
    end
end