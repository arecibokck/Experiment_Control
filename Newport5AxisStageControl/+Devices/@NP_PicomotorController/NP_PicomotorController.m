% NP_8742_Controller class to communicate with Controllers from
% New Focus Piezo Controller 8742. It connects to the controllers via USB.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef  NP_PicomotorController < Devices.Device 

%- Properties
    
    properties (Constant)
        
        ControllerDeviceInfoDefault = struct('Alias','Picomotor 8742 Controller Device_1', ...
                                             'deviceID','USB\VID_104D&PID_4000\12345678',  ...
                                             'USBAddress', 1,                              ...
                                             'IsConnected2PCViaUSB','false');
        PicomotorScrewsInfoDefault=[...
                    ...
                    ...
                    ...
                    ...            --- 5AxisStage ---
                    ...
                    ... Axis 01
                    struct('Alias','placeholderName1',  ...
                           'ControllerdeviceID','USB\VID_104D&PID_4000\12345678',  ...
                           'MotorProperties',...
                                    struct('ChannelNumber',1,  ...
                                           'MotorType', 2,...
                                           'HomePosition', 0,...
                                           'Velocity', 400, ...
                                           'Acceleration', 100));        ...

                    ... Axis 02
                    struct('Alias','placeholderName2',  ...
                           'ControllerdeviceID','USB\VID_104D&PID_4000\12345678',  ...
                           'MotorProperties',...
                                    struct('ChannelNumber',2,  ...
                                           'MotorType', 2,...
                                           'HomePosition', 0,...
                                           'Velocity', 400, ...
                                           'Acceleration', 100));        ...
                           
                     ... Axis 03
                    struct('Alias','placeholderName3',  ...
                           'ControllerdeviceID','USB\VID_104D&PID_4000\12345678',  ...
                           'MotorProperties',...
                                    struct('ChannelNumber',3,  ...
                                           'MotorType', 2,...
                                           'HomePosition', 0,...
                                           'Velocity', 400, ...
                                           'Acceleration', 1000));        ...
                           
                     ... Axis 04
                    struct('Alias','placeholderName4',  ...
                           'ControllerdeviceID','USB\VID_104D&PID_4000\12345678',  ...
                           'MotorProperties',...
                                    struct('ChannelNumber',4,  ...
                                           'MotorType', 2,...
                                           'HomePosition', 0,...
                                           'Velocity', 400, ...
                                           'Acceleration', 1000));        ...

                    %... Axis 05 Not connected
                    struct('Alias','placeholderName5',  ...
                           'ControllerdeviceID','USB\VID_104D&PID_4000\12345678',  ...
                           'MotorProperties',...
                                    struct('ChannelNumber', NaN,  ...
                                           'MotorType', 2,...
                                           'HomePosition', 0,...
                                           'Velocity', 400, ...
                                           'Acceleration', 1000));        ...

                    ];
    end
    
    properties (Access=private)
        USB_Devices_List;                   %Char array, each row contains Info on connected USB-Controllers
        USB_Devices_List_Structured;        %Struct  of Chars, Each row of "USB_Devices_List"
    end
                                       
    properties 
        ControllerDevice={};                %Contains ControllerDevice Objects 
        ControllerDeviceInfo=struct();      %Contains Information 
        PicomotorScrewsInfo=struct();       %Contains structs with Info 
                                            %about Picomotor screws

        
        %-PicomotorScrews
        PicomotorScrews=struct(...
        'placeholderName1',[],...    
        'placeholderName2',[],...    
        'placeholderName3',[],...    
        'placeholderName4',[],....    
        'placeholderName5',[]....    
        );
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%- Methods
    methods %Lifecycle functions
        %% Class Constructor 
        function this = NP_PicomotorController(varargin)
            
            disp('NP_PicomotorController object is being constructed...')
            this@Devices.Device;
            
            %-Load DefaultData 
            this.ControllerDeviceInfo=this.ControllerDeviceInfoDefault;
            this.PicomotorScrewsInfo=this.PicomotorScrewsInfoDefault;
            
            %-Get list of Connected USB-Devices
            [this.USB_Devices_List,this.USB_Devices_List_Structured] = this.enumerateUSB('USBDevice');
            
            %-Check which ControllerDevice are Connected
            disp('Checking which ControllerDevices are connected via USB...')
            Temp_ListOfConnectedDevices = struct2cell(this.USB_Devices_List_Structured);
            Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(2,:,:);
            Temp_ListOfConnectedDevices = Temp_ListOfConnectedDevices(:);
            
            for Index = 1:length(this.ControllerDeviceInfo)
                Temp_deviceID = this.ControllerDeviceInfo(Index).deviceID;
                
                if any(strcmp(Temp_deviceID,vertcat(Temp_ListOfConnectedDevices{:})))
                    this.ControllerDeviceInfo(Index).IsConnected2PCViaUSB=1;
                    disp([this.ControllerDeviceInfo(Index).Alias ' connected to PC via USB.'])
                else
                    disp(['Warning: ' this.ControllerDeviceInfo(Index).Alias ' not connected to PC via USB.'])
                end  
            end
            clear Index
            
            %-Create Objects for each ControllerDevice and open connection,
            %if connected via USB
            for Index=1:length(this.ControllerDeviceInfo)
                Temp_deviceID = this.ControllerDeviceInfo(Index).deviceID;
                Temp_USBAddress   = this.ControllerDeviceInfo(Index).USBAddress;
                Temp_Name         = this.ControllerDeviceInfo(Index).Alias;
                %create Object
                this.ControllerDevice{Index}=Devices.NP_PicomotorControllerDevice(Temp_deviceID,Temp_USBAddress);
                %Establish USB-Connection
                if this.ControllerDeviceInfo(Index).IsConnected2PCViaUSB==1
                    this.ControllerDeviceInfo(Index).ID=this.ControllerDevice{Index}.USB_connect();
                    disp(['USB-connection to ControllerDevice ',num2str(Index),'(',Temp_Name,') established'])
                end
            end
            clear Index
            
            %-Create Objects for each PicomotorScrew
            for Index=1:length(this.PicomotorScrewsInfo)
                
                %-Get temporary Variables
                Alias = this.PicomotorScrewsInfo(Index).Alias;
                Temp_ControllerdeviceID = this.PicomotorScrewsInfo(Index).ControllerdeviceID;
                MotorProperties=this.PicomotorScrewsInfo(Index).MotorProperties;
                
                
                %-Get Temp_ControllerDeviceNumber 
                %-search list of Controller-Devices
                for IndexTwo=1:length(this.ControllerDevice)
                    Temp_deviceID=this.ControllerDevice{IndexTwo}.deviceID;
                    if(strcmp(Temp_deviceID,Temp_ControllerdeviceID))
                        Temp_ControllerDeviceNumber=IndexTwo;
                    end  
                end
                
                %-Test if 'Alias' is declared as Property
                assert(isfield(this.PicomotorScrews,Alias),'Error: Alias of PicomotorScrews does not exist as Property, check Properties.')
                
                %-Create Object
                this.PicomotorScrews.(Alias)=Devices.NP_PicomotorScrews(Alias,MotorProperties,Temp_ControllerDeviceNumber);
                
            end
            %}
            %- Show finish message:
            disp('NP_PicomotorController Object created.')
        end
        
        %% Class Destructor (Closes Connection, Clears object)
        function delete(this)
            className = class(this);
            disp(['Destructor called for class ',className])
            
            %-delete all Controller Objects
            if (~isempty(this.ControllerDevice))
                cellfun(@(m)m.delete,this.ControllerDevice);
            end
        end
        
        %% Disconnect from specified controller
        function disconnectPicomotorController(this,NumberOfDevice)
            % disconnects from ControllerDevice number "NumberOfDevice"
            %
            % input     NumberOfDevice   1|2|3 
            
            % - input control
            assert(isnumeric(NumberOfDevice) && isscalar(NumberOfDevice) && mod(NumberOfDevice,1)==0,...
                'InputError:  NumberOfDevice must be an integer corresponding to each plugged device.')
            % - disconnect
            if this.ControllerDevice{NumberOfDevice}.IsConnected
                this.ControllerDevice{NumberOfDevice}.USB_disconnect();
            end
        end
        
        %% Reconnects to specified controller
        function reconnectPicomotorController(this,NumberOfDevice)
            % reconnects to ControllerDevice number "NumberOfDevice"
            %
            % input     NumberOfDevice   1|2|3 
            
            % - input control
            assert(isnumeric(NumberOfDevice) && isscalar(NumberOfDevice) && mod(NumberOfDevice,1)==0,...
                'InputError:  NumberOfDevice must be an integer corresponding to each plugged device.')
            % - reconnect if necessary
            if ~(this.ControllerDevice{NumberOfDevice}.IsConnected)
                this.ControllerDevice{NumberOfDevice}.USB_connect();
                disp('Reconnected!');
            end
        end
        
        %%      ======= START SETTERS/GETTERS ========
        %
        % These functions are used to validate the configuration parameters.
        
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