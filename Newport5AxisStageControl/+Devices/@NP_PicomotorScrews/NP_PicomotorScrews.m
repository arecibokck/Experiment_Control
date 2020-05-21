classdef  NP_PicomotorScrews < Devices.Device 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Properties
    
    properties (SetAccess=immutable) % Can only be set in Constructor
        
        %-Input to Constructor
        Alias;                             % AliasName of Picomotor
        ControllerDeviceChannelNumber;     % ChannelNumber of ControllerDevice to which Picomotor is connected to
        
        
        %-ControllerDeviceStatus
        ControllerDeviceNumber;         % ControllerDevice can be called using ControllerDevice(ControllerDeviceNumber)
    end
    
    properties (Access=private) % Can only be set by members of same class
        
        %-ControllerDeviceStatus
        ControllerDeviceConnected = false;                % true, if USB connection to ControllerDevice is open
        ControllerDeviceReady = false;                    % true, if ControllerDevice is ready to perform next command
        
        %-PicomotorScrewStatus
        IsConnected=0;                                    % 1, move(this,0) does not throw an error, 0 otherwise
        

    end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Methods 
    methods 
        %% Class Constructor
        function this = NP_PicomotorScrews(Alias,MotorProperties,ControllerDeviceNumber)
            disp('NP_PicomotorScrews object is being constructed...')
            this@Devices.Device;
            assert(ischar(Alias),'Error: input Alias is not of type: char')
            if isnan(MotorProperties.ChannelNumber)
                warning([Alias ' is not connected to any channel of any Controller device!']);
            else
                isaninteger = @(x)isfinite(x) & x==floor(x);
                assert(isaninteger(MotorProperties.ChannelNumber) & MotorProperties.ChannelNumber > 0 & MotorProperties.ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            end
            %-from Input
            this.Alias=Alias;        
            this.ControllerDeviceChannelNumber=MotorProperties.ChannelNumber;
            %-Get ControllerDeviceNumber from Input
            this.ControllerDeviceNumber = ControllerDeviceNumber;
            disp([Alias ' successfully initialized!'])
        end
        
        %% Class Destructor
        function delete(this)
            className = class(this);
            disp(['Destructor called for class ' className ' object ' this.Alias])
            try
                disp(['Deleting ' className ' object...']);
                %-delete PicomotorScrews-Objects
                this.delete
                disp(['Stopped all motion, closed connection and deleted ' className ' object.']);
            catch ME
                warning(ME.message)
                rethrow(ME)
            end
        end
        
        %% Check if Picomotor device is ready by doing a Motor and Error check
        function ReadyStatus = IsControllerReady(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            ReadyStatus = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.IsControllerReady();
        end
        
        %% Get Motor Type
        function [MotorType,Error] = GetMotorType(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [MotorType, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetMotorType(this.ControllerDeviceChannelNumber);
        end
        
        %% Set Motor Type
        function Error = SetMotorType(this, motortype)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.SetMotorType(this.ControllerDeviceChannelNumber, motortype);
        end
        
        %% Get Home Position
        function [Home,Error] = GetHome(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [Home, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetHome(this.ControllerDeviceChannelNumber);
        end
        
        %% Set Home Position
        function Error = SetHome(this, home)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.SetHome(this.ControllerDeviceChannelNumber, home);
        end
        
        %% Get Velocity
        function [Velocity,Error] = GetVelocity(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [Velocity, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetVelocity(this.ControllerDeviceChannelNumber);
        end
        
        %% Set Velocity
        function Error = SetVelocity(this, velocity)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.SetVelocity(this.ControllerDeviceChannelNumber, velocity);
        end
        
        %% Get Acceleration
        function [Acceleration,Error] = GetAcceleration(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [Acceleration, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetAcceleration(this.ControllerDeviceChannelNumber);
        end
        
        %% Set Acceleration
        function Error = SetAcceleration(this, acceleration)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.SetAcceleration(this.ControllerDeviceChannelNumber, acceleration);
        end
        
        %% Move Indefinitely
        function Error = MoveIndefinitely(this,Direction)
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
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveIndefinitely(this.ControllerDeviceChannelNumber,Direction);
        end
        
        %% Absolute Move to target position
        function Error = MoveAbsolute(this,target)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveAbsolute(this.ControllerDeviceChannelNumber,target);
        end
        
        %% Relative Move to target position
        function Error = MoveRelative(this,NumberofSteps)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveRelative(this.ControllerDeviceChannelNumber,NumberofSteps);
        end
        
        %% Stop Movement
        function Error = StopMotion(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.StopMotion(this.ControllerDeviceChannelNumber);
        end
        
        %% Abort Movement
        function Error = AbortMotion(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            Error = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.AbortMotion();
        end
        
        %% Get current position
        function [currentPos,Error] = GetCurrentPosition(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [currentPos, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetCurrentPosition(this.ControllerDeviceChannelNumber);
        end
        
        %% Get number of steps still to be performed
        function NumberOfSteps = GetNumberOfStepsStillToBePerformed(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [NumberOfSteps, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetNumberOfStepsStillToBePerformed(this.ControllerDeviceChannelNumber);
        end
        
        %% Get TotalNumberOfSteps
        function [Forwards,Backwards] = GetTotalNumberOfSteps(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [Forwards,Backwards] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.GetTotalNumberOfSteps(this.ControllerDeviceChannelNumber);
        end
        
        %% Reset TotalNumberOfSteps
        function [Forwards,Backwards] = ResetTotalNumberOfSteps(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [Forwards,Backwards] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.ResetTotalNumberOfSteps(this.ControllerDeviceChannelNumber);
        end
        
        %% Get Motion done Status
        function [IsMoving,Error] = IsPicomotorMoving(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            [IsMoving, Error] = TempHandle.ControllerDevice{this.ControllerDeviceNumber}.IsPicomotorMoving(this.ControllerDeviceChannelNumber);
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
                error = this.MoveRelative(3);
                if error.Code ~= this.ControllerDeviceChannelNumber*100+8
                    this.MoveRelative(-3);
                    IsConnected = 1;
                else
                    warning('Axis not moved since motor is not connected to Controller device!');
                    IsConnected = 0;
                end
                %- Update IsConnected-Property
                this.IsConnected=IsConnected;
            catch ME
                warning(ME.message)
                rethrow(ME)
            end
        end
        
        %% Reset Controller Device
        function reset(this)
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            %-Send Command
            TempHandle.ControllerDevice{this.ControllerDeviceNumber}.reset();
        end
        
        %% Reset Device parameters
        function recallParameters(this, binVal)
        % This command restores the controller working parameters from values saved in its non-
        % volatile memory.  It is useful when, for example, the user has been exploring and 
        % changing parameters (e.g., velocity) but then chooses to reload from previously stored, 
        % qualified settings.  Note that “*RCL 0” command just restores the working parameters to 
        % factory default settings. “*RCL 1” Restores last saved settings.  
           %-GetHandle, to get Access to NP-Class
           TempHandle=Devices.NP_PicomotorController.getInstance();
           %-Send Command
           TempHandle.ControllerDevice{this.ControllerDeviceNumber}.recallParameters(binVal);
        end
        
        %% Disconnect from specified controller
        function disconnectPicomotorController(this)
            % disconnects from ControllerDevice
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
           % - disconnect
            if TempHandle.ControllerDevice{this.ControllerDeviceNumber}.IsConnected
                TempHandle.ControllerDevice{this.ControllerDeviceNumber}.USB_disconnect();
            end
        end
        
        %% Reconnects to specified controller
        function reconnectPicomotorController(this)
            % reconnects to ControllerDevice
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            % - reconnect if necessary
            if ~(TempHandle.ControllerDevice{this.ControllerDeviceNumber}.IsConnected)
                TempHandle.ControllerDevice{this.ControllerDeviceNumber}.USB_connect();
                disp('Reconnected!');
            end
        end
        
        %% -SETTERS/GETTERS
        
        % ======= START SETTERS/GETTERS ========
        %
        % These functions are used to validate the configuration parameters.
    end
end