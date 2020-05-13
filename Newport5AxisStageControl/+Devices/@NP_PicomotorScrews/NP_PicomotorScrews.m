classdef  NP_PicomotorScrews < Devices.Device 
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Properties
    
    properties (SetAccess=immutable) % Can only be set in Constructor
        
        %-Input to Constructor
        Alias;                                          % AliasName of PiezoDrive
        ControllerDeviceAlias;                          % AliasName of ControllerDevice
        ControllerDeviceDemultiplexerChannelNumber;     % DemultiplexerChannelNumber of ControllerDevice to which PiezoDrive is connected
        ControllerDeviceSerialNumber;                   % SerialNumber of ControllerDevice
        
        %-ControllerDeviceStatus
        ControllerDeviceNumber=-1;                      % ControllerDevice can be called using ControllerDevice(ControllerDeviceNumber)
    end
    
    properties (Access=private) % Can only be set by members of same class
        %-ControllerDeviceStatus
        ControllerDeviceConnected=false;                % true, if USB connection to ControllerDevice is open
        ControllerDeviceReady=false;                    % true, if ControllerDevice is ready to perform next command
        
        %-PicomotorScrewStatus
        IsConnected=0;                                  % 1, move(this,0) does not throw an error, 0 otherwise
        

    end
    
    properties
        TotalNumberOfStepsForwards=0;
        TotalNumberOfStepsBackwards=0;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- Methods 
    methods 
        %% Class Constructor
        function this = NP_PicomotorScrews(Alias,ControllerDeviceProperties,varargin)
            disp('NP_PicomotorScrews object is being constructed...')
            this@Devices.Device;
            
            %-Input Handling
            assert(ischar(Alias),'Error: input Alias is not of type: char')
            assert(ischar(ControllerDeviceProperties.Alias),'Error: input Alias is not of type: char')
            assert(any(ControllerDeviceProperties.DemultiplexerChannelNumber==[1,2,3,4]),'Error: input DemultiplexerChannelNumber must be in [1,2,3,4]');
            assert(ischar(ControllerDeviceProperties.SerialNumber),'Error: input deviceID is not of type: char')
            
            narginchk(2,3)  %nargin==3 -> ControllerDeviceNumber=varargin{1}
            
            %-from Input
            this.Alias=Alias;       % 
            this.ControllerDeviceAlias=ControllerDeviceProperties.Alias;       %
            this.ControllerDeviceDemultiplexerChannelNumber=ControllerDeviceProperties.DemultiplexerChannelNumber; %
            this.ControllerDeviceSerialNumber=ControllerDeviceProperties.SerialNumber; %
            
            if nargin==3
                %-Get ControllerDeviceNumber from Input
                this.ControllerDeviceNumber=varargin{1};
                
            else
                error('Bad')
            end
            
            
            %-Get TotalNumberOfSteps
            if nargin==3
                this.TotalNumberOfStepsForwards=0;
                this.TotalNumberOfStepsBackwards=0;
            else
                error('Bad')
            end
            
            %-Show Construction Message
            disp([Alias ' Object successfully constructed.'])
        end
        
        %% Class Destructor
        function delete(this)
            
        end
        
        %% Move Indefinitely
        function MoveIndefinitely(this,NumberOfSteps,varargin)
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
            TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveIndefinitely(this.ControllerDeviceDemultiplexerChannelNumber,NumberOfSteps,varargin{:});
            
            %-Update Total Numbers of Steps:
            this.GetTotalNumberOfSteps;
        end
        
        %% Move to target position
        function MoveToTargetPosition(this,NumberOfSteps,varargin)
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
            TempHandle.ControllerDevice{this.ControllerDeviceNumber}.MoveToTargetPosition(this.ControllerDeviceDemultiplexerChannelNumber,NumberOfSteps,varargin{:});
            
            %-Update Total Numbers of Steps:
            this.GetTotalNumberOfSteps;
        end
        
        %% Stop Movement
        function ErrorStatus=Stop(this)
            % Success=Stop(this) stops movement of all PI_Shift-channels
            % immediatly
            %output - ErrorStatus       true, if movement occures
            %                           false, if error occured
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            ErrorStatus=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.StopAll;

        end
               
        %% Get Motion done Status
        function [IsReady] = GetMotionDoneStatus(this)
            % [IsReady] = IsControllerReady(this)
            % Asks controller for ready status
            
            %-GetHandle, to get Access to NP-Class
            TempHandle=Devices.NP_PicomotorController.getInstance();
            
            %-Send Command
            IsReady=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.GetMotionDoneStatus;
        end
        
        %% Get Total Number Of Steps
        function [Forwards,Backwards]=GetTotalNumberOfSteps(this)
        % [Forwards,Backwards]=GetTotalNumberOfSteps(this) gets the Total
        % Number of steps taken from the ControllerDevice
        %
        
        %-GetHandle, to get Access to NP-Class
        TempHandle=Devices.NP_PicomotorController.getInstance();
        
        %-Send Command
        [Forwards,Backwards]=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.GetTotalNumberOfSteps((this.ControllerDeviceDemultiplexerChannelNumber));
        
        %-Check Consistency
        if (Forwards<this.TotalNumberOfStepsForwards)
            disp('Warning: Forwards<this.TotalNumberOfStepsForwards')
        end
        if (Backwards<this.TotalNumberOfStepsBackwards)
            disp('Warning: Backwards<this.TotalNumberOfStepsBackwards')
        end
        
        %-Save in Properties
        this.TotalNumberOfStepsForwards=Forwards;
        this.TotalNumberOfStepsBackwards=Backwards;
        end
        
        %% Reset Total Number of Steps
        function[Forwards,Backwards]=ResetTotalNumberOfSteps(this)
        % [Forwards,Backwards]=ResetTotalNumberOfSteps(this) 
        % Sets TotalNumberOfStepsForwards and -backwards of specified
        % DemultiplexerChannelNumber to 0. Returns the former values.
        % output:   [Forwards,Backwards] old TotalNumberOfSteps
        
        %-GetHandle, to get Access to NP-Class
        TempHandle=Devices.NP_PicomotorController.getInstance();
        
        %-Send Command
        %--[Forwards,Backwards]=ResetTotalNumberOfSteps(this,DemultiplexerChannelNumber)
        [Forwards,Backwards]=TempHandle.ControllerDevice{(this.ControllerDeviceNumber)}.ResetTotalNumberOfSteps((this.ControllerDeviceDemultiplexerChannelNumber));
        
        %- Set Values of this object to 0 (necessary to fulfill
        %consistency-check)
        this.TotalNumberOfStepsForwards=0;
        this.TotalNumberOfStepsBackwards=0;
        
        %- get new values from device object
        GetTotalNumberOfSteps(this);
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
                this.MoveToTargetPosition(0)
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

