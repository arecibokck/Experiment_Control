classdef  NP_PicomotorScrews < Devices.Device 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Properties
    
    properties (SetAccess=immutable) % Can only be set in Constructor
        
        %-Input to Constructor
        Alias;                             % AliasName of Picomotor
        ControllerDeviceChannelNumber;     % ChannelNumber of ControllerDevice to which Picomotor is connected to
        
        
        %-ControllerDeviceStatus
        ControllerDeviceNumber=-1;         % ControllerDevice can be called using ControllerDevice(ControllerDeviceNumber)
    end
    
    properties (Access=private) % Can only be set by members of same class
        
        %-ControllerDeviceStatus
        ControllerDeviceConnected=false;                % true, if USB connection to ControllerDevice is open
        ControllerDeviceReady=false;                    % true, if ControllerDevice is ready to perform next command
        
        %-PicomotorScrewStatus
        IsConnected=0;                                  % 1, move(this,0) does not throw an error, 0 otherwise
        

    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Methods 
    methods 
        %% Class Constructor
        function this = NP_PicomotorScrews(Alias,MotorProperties,varargin)
            disp('NP_PicomotorScrews object is being constructed...')
            this@Devices.Device;
            
            assert(ischar(Alias),'Error: input Alias is not of type: char')
            
            if isnan(MotorProperties.ChannelNumber)
                warning('One of the axes is not connected to any channel of the Controller device!');
            else
                assert(any(MotorProperties.ChannelNumber==[1,2,3,4,5]),'Error: input Channel Number must be in [1,2,3,4,5]');
                
                narginchk(2,3)  %nargin==3 -> ControllerDeviceNumber=varargin{1}
            
                %-from Input
                this.Alias=Alias;        
                this.ControllerDeviceChannelNumber=MotorProperties.ChannelNumber;


                if nargin==3
                    %-Get ControllerDeviceNumber from Input
                    this.ControllerDeviceNumber=varargin{1};

                else
                    error('Error: Invalid Controller device number!')
                end

                disp([Alias ' successfully initialized!'])
                
            end
        end
        
        %% Class Destructor
        function delete(this)
            className = class(this);
            disp(['Destructor called for class ',className])
            
            try
%                 %-GetHandle, to get Access to NP-Class
%                 TempHandle=Devices.NP_PicomotorController.getInstance();
%             
%                 %-Stop all motion
%                 TempHandle.ControllerDevice{this.ControllerDeviceNumber}.StopAll
% 
%                 %-Close Connection
%                 if(this.IsConnected)
%                     TempHandle.ControllerDevice{this.ControllerDeviceNumber}.USB_disconnect;
%                 end
                
                disp(['Deleting ' className ' object...']);
                
                %-delete PicomotorScrews-Objects
                this.delete
                
                disp(['Stopped all motion, closed connection and deleted ' className ' object.']);
                 
            catch ME
                warning(ME.message)
            end
            
        end
        
        %% Move Indefinitely
        function MoveIndefinitely(this,Direction)
            % Move(NumberOfSteps,varargin) moves PiezoDrive NumberOfSteps 
            % Steps if abs(NumberOfSteps)<min(MaxNumberOfSteps,varargin{1})
            % where MaxNumberOfSteps is a Property of the ControllerDevice
            % 
            %input  NumberOfSteps   
            %varargin
            %       nargin=0        MaxNumberOfSteps=this.MaxNumberOfSteps
            %       nargin=1        MaxNumberOfSteps=vargin{1}
            %
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveIndefinitely(this.ControllerDeviceChannelNumber,Direction);
            
        end
        
        %% Move to target position
        function AbsoluteMoveToTargetPosition(this,NumberOfSteps,Direction)
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            TempHandle.ControllerDevice{this.ControllerDeviceNumber}.AbsoluteMoveToTargetPosition(this.ControllerDeviceChannelNumber,NumberOfSteps,Direction);
            
        end
        
        %% Stop Movement
        function ErrorStatus=Stop(this)
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            ErrorStatus=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.StopAll;

        end
               
        %% Get Motion done Status
        function IsMoving = GetMotionDoneStatus(this)
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            IsMoving=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.GetMotionDoneStatus(this.ControllerDeviceChannelNumber);
        end
        
        %% Get Connection status
        function IsConnected = GetConnectionStatus(this)
            % IsConnected = GetConnectionStatus(this) checks whether PicomotorScrew is
            % properly connected by ordering the ControllerDevice to move
            % 'ControllerDeviceDemultiplexerChannelNumber' by 0 steps
            % output:    1       if no error occured
            %            0       otherwise
            
            %- tries to send the move-command
            try
                this.AbsoluteMoveToTargetPosition(0,'+')
                IsConnected = 1;
            catch ME
                %-if an error occures, its text will be shown as a warning
                warning(ME.message)
                IsConnected=0;
            end
            
            %- Update IsConnected-Property
            this.IsConnected=IsConnected;
            
        end
                    
        %% -SETTERS/GETTERS
        
        % ======= START SETTERS/GETTERS ========
        %
        % These functions are used to validate the configuration parameters.
    end
end

