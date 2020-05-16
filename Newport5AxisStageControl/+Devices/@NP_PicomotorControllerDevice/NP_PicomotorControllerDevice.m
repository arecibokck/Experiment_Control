% NP_8742_Controller Device class to communicate with Controllers from
% New Focus Piezo Controller 8742. It connects to the controllers via USB.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef NP_PicomotorControllerDevice < Devices.Device 

%- Properties
    
    properties (Constant)
        DEFAULTID = 0;
        DEFAULTUSBADDR = 1;
    end
    
    properties
    	deviceID;
        USBADDR;
        NP_USB;
    end
    
    properties
        
        %-DeviceStatus
        ID;                                                                     %int, -1 if not connected, else ID of Connection
        IsConnected;                                                            %true if USB Connection is open
        ReadyStatus = false;                                                    %true if device ready to perform next command        
        IsMoving;                                                               %true if at least one Axis is moving
        
        
        %-DeviceSettings:
        Pause_Max_Iterations =-1;                                               %#Iterations until 'WaitforStops' sends Timeout
        Pause_Time=0.1;                                                         %Time in [s] per wait-iteration 
        
                
        %-DeviceData
        TargetPosition = 0;
        NumberOfStepsStillToBePerformed = 0; 
        TotalNumberOfStepsForwards  = [0;0;0;0];
        TotalNumberOfStepsBackwards = [0;0;0;0];
        MaxNumberOfSteps = struct('UserDefined'  ,3000, ...
                                  'HardwareLimit',2^31);                        % Upper limit of steps per Move-Command
        
    end
    
    properties
        
        CommandList = struct('IdentificationQuery','*IDN?', ...
                             'RecallParams', '*RCL', ...
                             'Reset', '*RST', ...
                             'AbortMotion', 'AB', ...
                             'SetAcceleration','AC', ...
                             'AccelerationQuery','AC?', ...
                             'SetHomePosition','DH', ...
                             'HomePositionQuery','DH?', ...
                             'MotorCheck', 'MC', ...
                             'MotorDoneStatusQuery', 'MD?', ... 
                             'IndefiniteMove', 'MV', ...
                             'AbsoluteMove', 'PA', ...
                             'AbsoluteTargetPositionQuery', 'PA?', ...
                             'RelativeMove', 'PR', ...
                             'RelativeTargetPositionQuery', 'PR?', ...
                             'SetMotorType', 'QM', ...
                             'MotorTypeQuery', 'QM?', ...
                             'SaveSettings', 'SM', ...
                             'StopMotion', 'ST', ...
                             'ErrorMessageQuery', 'TB?', ...
                             'ErrorCodeQuery', 'TE?', ...
                             'CurrentPositionQuery', 'TP?', ...
                             'SetVelocity', 'VA', ...
                             'VelocityQuery', 'VA?');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%- Methods
    methods %Lifecycle functions
        %% Class Constructor 
        function this = NP_PicomotorControllerDevice(varargin)
            %
            %
            % Inputs:
            % deviceID     -    Hex string Device ID (look up in datasheet or on device manager)
            % USBADDR	   -    Set in the menu of the device, only relevant if multiple are attached
            %
            % Outputs:
            % NP_USB       -    .NET Class of USB
            %
            %
            disp('NP_PicomotorControllerDevice object is being constructed...')
            this@Devices.Device;
            
            if (nargin == 2)
                this.deviceID = varargin{1};
                this.USBADDR = varargin{2};
            else
                if (nargin < 2)
                    %assume default USB address
                    this.USBADDR = this.DEFAULTUSBADDR;
                end    

                if (nargin < 1)
                    %assume default device ID
                    this.deviceID = this.DEFAULTID;
                end
            end
            
            %-Default values
            this.ID=-1;                 % Unknown
            this.IsConnected = 0;       % not connected
            
            %-Create Objects for each or the one Controller
            
            NPasm = NET.addAssembly('C:\Program Files\Newport\Newport USB Driver\Bin\UsbDllWrap.dll');

            %Get a handle on the USB class
            NPASMtype = NPasm.AssemblyHandle.GetType('Newport.USBComm.USB');
            %launch the class USB, it constructs and allows to use functions in USB.h
            this.NP_USB = System.Activator.CreateInstance(NPASMtype);
            
            disp('NP_PicomotorControllerDevice Object created')
        end
        
        %% Class Destructor (Closes Connection, Unloads DLL, Clears object)
        function delete(this)
            
            className = class(this);
            disp(['Destructor called for class ',className])
            
            try 
                %-Stop all motion
                this.AbortAllMotion()

                %-Close Connection
                if(this.IsConnected)
                    this.USB_disconnect;
                end
                
                disp(['Deleting ' className ' object...']);
                
                %-delete ControllerDevice-Objects
                this.delete
                
                disp(['Stopped all motion, closed connection and deleted ' className ' object.']);
                 
            catch ME
                warning(ME.message)
            end
                
        end
        
        %% Establish USB Connection
        function devInfo = USB_connect(this)
        % NP_USB_CONNECT establish connection with Newport USB device
        % Loads the Newport USB Driver .NET Wrapper
        % Established and verifies connection
        % Reports device self-identification
        % 
        % Requires a reboot of the Newport Device to ensure correct connectivity!
        %
        % Outputs:
        % devInfo      -    Device self-identification
        %                       [Newport Name Firmware Date SN]
        % 
                   
            disp('Looking for device...')
            try
                %Open the USB device(s)
                devOpen = this.NP_USB.OpenDevices();
                if (~devOpen)
                    disp('Error:  Could not find/open any device.');
                    this.ID = -1;
                else
                    %-Get list of Connected USB-Devices
                    allDevInfoList = this.NP_USB.GetDevInfoList();

                    %-Check which Controller device(s) is/are connected
                    if (allDevInfoList.Count == 0)
                        disp('No device discovered.');
                        this.ID = -1;
                        this.delete();
                        this.NP_USB.CloseDevices(); %Make sure that the system is properly shut down
                    else
                        disp('Found device.');
                        if(allDevInfoList.Count == 1)
                            this.ID = 0;
                            this.IsConnected = 1;
                            devInfo = this.query(this.CommandList.IdentificationQuery);
                            disp(['Device attached is ' devInfo '.']);
                        end
                    end
                end
            catch ME
                rethrow(ME);
            end
        end   
        
        %% Write
        function write(this, cmd)
            this.USB_reperror(this.NP_USB.Write(this.USBADDR, cmd),'Write');
        end
        
        %% Query
        function ret=query(this, query)
            %The Query method sends the passed in command string to the specified device and reads the response data.
            querydata = System.Text.StringBuilder(64);
            this.USB_reperror(this.NP_USB.Query(this.USBADDR, query, querydata),'Query');
            ret = char(ToString(querydata));
        end
        
        %% Query and convert the result to a double precision floating point number
        function ret=queryDouble(this, query)
            ret=str2double(this.query(query));
        end
        
        %% Check if Picomotor device is ready by doing a Motor and Error check
        function ReadyStatus = IsPicomotorReady(this)
            % Asks controller for ready status
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            this.write(this.CommandList.MotorCheck);
                            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.query(this.CommandList.ErrorCodeQuery) == '0', ErrorMessage)
                ReadyStatus = true;
            catch
                disp(['ErrorMessage = ', ErrorMessage])
                ReadyStatus = false;
            end
            
            this.ReadyStatus = ReadyStatus;
        end
        
        %% Get Motor Type
        function MotorType = GetMotorType(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            MotorType = this.queryDouble([num2str(ChannelNumber) this.CommandList.MotorTypeQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end    
        
        %% Set Motor Type
        function SetMotorType(this, ChannelNumber, motortype)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            TempHandle = Devices.NP_PicomotorController.getInstance();
            
            %-Input Handling
            if nargin < 3
                disp('Assuming first argument is Channel number and setting motor type to default...');
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                motortype = TempHandle.PicomotorScrewsInfoDefault(ChannelNumber).MotorProperties.MotorType;
            else
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                assert(isaninteger(motortype) & motortype < 4 ,'Invalid type number. Check if it is an integer between 0 and 3.')
            end
            
            if isequal(this.GetMotorType(ChannelNumber), motortype)
                disp('Attention: Motor type already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetMotorType num2str(motortype)]);
                disp(['Motor type set to ' num2str(motortype)]);
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end    
        
        %% Get Acceleration
        function Accn = GetAcceleration(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            Accn = this.queryDouble([num2str(ChannelNumber) this.CommandList.AccelerationQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end 
        
        %% Set Acceleration
        function SetAcceleration(this, ChannelNumber, acceleration)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            TempHandle = Devices.NP_PicomotorController.getInstance();
            
            %-Input Handling
            if nargin < 3
                disp('Assuming first argument is Channel number and setting Acceleration to default...');
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                acceleration = TempHandle.PicomotorScrewsInfoDefault(ChannelNumber).MotorProperties.Acceleration;
            else
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                assert(isaninteger(acceleration) & acceleration > 0 & acceleration < 200001 ,'Invalid Acceleration value. Check if it is an integer between 1 and 200000.')
            end
            
            if isequal(this.GetAcceleration(ChannelNumber), acceleration)
                disp('Attention: Acceleration already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetAcceleration num2str(acceleration)]);
                disp(['Acceleration set to ' num2str(acceleration)]);
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get Velocity
        function vel = GetVelocity(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            vel = this.queryDouble([num2str(ChannelNumber) this.CommandList.VelocityQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Set Velocity
        function SetVelocity(this, ChannelNumber, velocity)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            TempHandle = Devices.NP_PicomotorController.getInstance();
            
            %-Input Handling
            if nargin < 3
                disp('Assuming first argument is Channel number and setting velocity to default...');
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                velocity = TempHandle.PicomotorScrewsInfoDefault(ChannelNumber).MotorProperties.Velocity;
            else
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                assert(isaninteger(velocity) & velocity > 0 & velocity < 2001 ,'Invalid Velocity value. Check if it is an integer between 1 and 2000.')
            end
            
            if isequal(this.GetVelocity(ChannelNumber), velocity)
                disp('Attention: Velocity already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetVelocity num2str(velocity)]);
                disp(['Velocity set to ' num2str(velocity)]);
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get Home position
        function home = GetHome(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            home = this.queryDouble([num2str(ChannelNumber) this.CommandList.HomePositionQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Set Home position
        function SetHome(this, ChannelNumber, home)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            TempHandle = Devices.NP_PicomotorController.getInstance();
            
            if nargin < 3
                disp('Assuming first argument is Channel number and setting home position to default...');
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                home = TempHandle.PicomotorScrewsInfoDefault(ChannelNumber).MotorProperties.HomePosition;
            else
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                assert(isaninteger(home) & home >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                         & home <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                              ,'Invalid Home position. Check if it is an integer between -2147483648 and +2147483647.')
            end
            
            if isequal(this.GetHome(ChannelNumber), home)
                disp('Attention: Home position already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetHomePosition num2str(home)]);
                disp(['Home position set to ' num2str(home)]);
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get absolute target position
        function target = GetAbsoluteTargetPosition(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            target = this.queryDouble([num2str(ChannelNumber) this.CommandList.AbsoluteTargetPositionQuery]);
            this.TargetPosition = target;
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get relative target position
        function target = GetRelativeTargetPosition(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            target = this.queryDouble([num2str(ChannelNumber) this.CommandList.RelativeTargetPositionQuery]);
            this.TargetPosition = target;
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get current position
        function pos = GetCurrentPosition(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            pos = this.queryDouble([num2str(ChannelNumber) this.CommandList.CurrentPositionQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Check if an axis is moving
        function isMoving = IsPicomotorMoving(this, ChannelNumber)
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            isMoving = ~this.queryDouble([num2str(ChannelNumber) this.CommandList.MotorDoneStatusQuery]);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end 
        
        %% Motion of an axis
        
        % WaitForStopOfMovement(this,varargin)
        function WaitResult=WaitForStopOfMovement(this,varargin)
            % Runs a while loop until IsPicomotorMoving(this)==0, each
            % loop contains pause(Pause_Time)
            %
            %input varargin	
            %           nargin=0    Pause_Time=this.Pause_Time
            %                       MaxIter=this.Pause_Max_Iterations
            %           nargin=1    MaxIter==varagin{1}
            %           nargin=2    Pause_Time=varagin{2}
            %output WaitResult      true,   if MovementStopped  
            %                       false,  if MaxIter is reached
            %   
            %Note:     MaxIter=-1 will cause infinite loop
            
            
            %-Set default values
            MaxIter=this.Pause_Max_Iterations;
            PauseTime=this.Pause_Time;
            
            %-Input handling
            narginchk(1,4); % checks if Number of arguments is between 1 and 3
            
            if  nargin == 2
                ChannelNumber = varargin{1};
            elseif nargin == 3
                MaxIter = varargin{2}; 
                PauseTime = varargin{2}; 
            end
            
            %-Start Loop
            while MaxIter~=0
                if ~this.IsPicomotorMoving(ChannelNumber)                     % Check if Moving
                    break
                end
                pause(PauseTime)                % Wait
                MaxIter=MaxIter-1;              % CountDown
            end
         
            %-Set Output
            if MaxIter==0
                WaitResult=false;
                disp('Warning: Maximum iterations reached for WaitForStopOfMovement.')
            else
                WaitResult=true;
            end
        end
        
        %Move indefinitely
        function MoveIndefinitely(this, ChannelNumber, direction)
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
           
            isaninteger = @(x)isfinite(x) & x==floor(x);
            
            if nargin < 3
                disp('Assuming first argument is Channel number and moving indefinitely in positive direction...');
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                direction = '+';
            else
                assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
                assert(any(direction == ['+','-']),'Invalid direction. Specify as either + (positive direction) or - (negative direction).')
                if isequal(direction, '+')
                    disp('Moving indefinitely in the positive direction...');
                else
                    disp('Moving indefinitely in the negative direction...');
                end
            end
            
            this.write([num2str(ChannelNumber) this.CommandList.IndefiniteMove direction]);
            
            while this.IsPicomotorMoving(ChannelNumber)
                if this.TotalNumberOfStepsForwards(ChannelNumber) == this.MaxNumberOfSteps.UserDefined || this.TotalNumberOfStepsForwards(ChannelNumber) == -this.MaxNumberOfSteps.UserDefined
                    this.StopMotion(ChannelNumber);
                    disp('Motion stopped: Number of steps taken from home position has reached user-defined maximum in one direction.');
                    break
                end
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
                
        end
        
        %Move to target position
        function MoveAbsolute(this, ChannelNumber, target)
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
           
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(target) & target >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                       & target <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                       ,'Invalid target position. Check if it is an integer between -2147483648 and +2147483647.')
            this.TargetPosition = target;
            
            currentPos = this.GetCurrentPosition(ChannelNumber);
            NumberOfSteps = this.GetNumberOfStepsStillToBePerformed(ChannelNumber);
            
            if target ~= currentPos 
                if target == 0
                    disp('Moving to home...');
                elseif target > 0 && target <= this.MaxNumberOfSteps.UserDefined
                    disp(['Moving to +' num2str(abs(target)) '...']);
                elseif target < 0 && target >= -this.MaxNumberOfSteps.UserDefined 
                    disp(['Moving to -' num2str(abs(target)) '...']);
                else 
                    disp('Target position exceeds user-defined limit on number of steps from home position. Axis will not be moved in either direction.');
                    target = currentPos;
                end
            
                this.write([num2str(ChannelNumber) this.CommandList.AbsoluteMove num2str(target)]);
            else
                disp('Currently at target position.')
            end
            
            %-Wait till movement stops
            WaitResult=this.WaitForStopOfMovement(ChannelNumber);
            
            if WaitResult
                %-Update Total Number of Steps taken
                this.UpdateTotalNumberOfSteps(ChannelNumber, NumberOfSteps)
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %Move Relative
        function MoveRelative(this, ChannelNumber, NumberOfSteps)
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
           
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(NumberOfSteps) & NumberOfSteps >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                              & NumberOfSteps <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                              ,'Invalid number of steps. Check if it is an integer between -2147483648 and +2147483647.')
            this.TargetPosition = this.GetCurrentPosition(ChannelNumber) + NumberOfSteps;
            
            if NumberOfSteps ~= 0
                if NumberOfSteps > 0 && this.TargetPosition <= this.MaxNumberOfSteps.UserDefined
                    disp(['Moving by ' num2str(abs(NumberOfSteps)) ' steps in the positive direction...']);
                elseif NumberOfSteps < 0 && this.TargetPosition >= -this.MaxNumberOfSteps.UserDefined 
                    disp(['Moving by ' num2str(abs(NumberOfSteps)) ' steps in the negative direction...']);
                else 
                    NumberOfSteps = 0;
                    disp('Target position exceeds user-defined limit on number of steps from home position. Axis not moved in either direction.');
                end
                this.write([num2str(ChannelNumber) this.CommandList.RelativeMove num2str(NumberOfSteps)]);
            else
                disp('Axis will not be moved in either direction.');
            end
            
            %-Wait till movement stops
            WaitResult=this.WaitForStopOfMovement(ChannelNumber);
            
            if WaitResult
                %-Update Total Number of Steps taken
                this.UpdateTotalNumberOfSteps(ChannelNumber, NumberOfSteps)
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        % Stop movement of an axis with deceleration (the negative of the
        % specified acceleration)
        function StopMotion(this, ChannelNumber)
            assert(this.ID~=-1,'The controller is not connected')
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            
            if this.IsPicomotorMoving(ChannelNumber)
                disp(['Stopping motion of ' num2str(ChannelNumber) ' axes...']);            
                this.write([num2str(ChannelNumber) this.CommandList.StopMotion]);
            else
                disp('Axis has already come to a halt.');             
            end
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.query(this.CommandList.ErrorCodeQuery) == '0',ErrorMessage)
            catch
                disp(['ErrorMessage = ',ErrorMessage])
            end
        end
        
        % Abort Motion of all axes without deceleration
        function AbortAllMotion(this)
            assert(this.ID~=-1,'The controller is not connected')
            
            disp('Aborting motion of all axes...');             
            
            this.write(this.CommandList.AbortMotion);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.query(this.CommandList.ErrorCodeQuery) == '0',ErrorMessage)
            catch
                disp(['ErrorMessage = ',ErrorMessage])
            end
        end
        
        %% Get number of steps still to be performed 
        function NumberOfSteps = GetNumberOfStepsStillToBePerformed(this, ChannelNumber)
            
            % Get number of steps still to be performed 
            %varargin:      nargin=0            ChannelNumber=1
            %               nargin=1            ChannelNumber=varargin{1},
            %output:        NumberOfSteps       number of steps still to be performed
            
            assert(nargin == 2, 'Insufficient number of arguments. Need Channel number!');
            
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            NumberOfSteps =  this.TargetPosition - this.GetCurrentPosition(ChannelNumber);
            this.NumberOfStepsStillToBePerformed = NumberOfSteps;
            
            %- Error handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.queryDouble(this.CommandList.ErrorCodeQuery) == 0, ErrorMessage)
            catch
                disp(['ErrorMessage = ', ErrorMessage])
            end
        end
        
        %% Get TotalNumberOfSteps
        function [Forwards,Backwards] = GetTotalNumberOfSteps(this,ChannelNumber)
        % [Forwards,Backwards]=GetTotalNumberOfSteps(ChannelNumber)
        % returns deviceData.TotalNumberOfStepsForwards and ...Backwards for
        % specified Channel
        
            %-Input handling
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
        
            %-get Output
            Forwards=this.TotalNumberOfStepsForwards(ChannelNumber);
            Backwards=this.TotalNumberOfStepsBackwards(ChannelNumber);
        end
        
        %% Set TotalNumberOfSteps
        function UpdateTotalNumberOfSteps(this, ChannelNumber, NumberOfSteps)
            % UpdateTotalNumberOfSteps(this,DemultiplexerChannelNumber,NumberOfSteps)
            % adds abs(NumberOfSteps) to 
            % deviceData.TotalNumberOfStepsForwards/Backwards of specified
            % memultiplexer channel, depending whether NumberOfSteps is 
            % positive or negative.
        
            %- Input handling
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isnumeric(NumberOfSteps)&& length(NumberOfSteps)==1 && NumberOfSteps==int32(NumberOfSteps),'Error: NumberOfSteps must be a scalar')
            
            %- Update TotalNumberOfSteps
            if NumberOfSteps > 0
                this.TotalNumberOfStepsForwards(ChannelNumber) = this.TotalNumberOfStepsForwards(ChannelNumber) + NumberOfSteps;
            else
                this.TotalNumberOfStepsBackwards(ChannelNumber) = this.TotalNumberOfStepsBackwards(ChannelNumber) - NumberOfSteps;
            end
        end
        
        %% Reset TotalNumberOfSteps
        function [Forwards,Backwards] = ResetTotalNumberOfSteps(this, ChannelNumber)
            %[Forwards,Backwards]=ResetTotalNumberOfSteps(this,DemultiplexerChannelNumber)
            % Sets TotalNumberOfStepsForwards and -backwards of specified
            % DemultiplexerChannelNumber to 0. Returns the former values.
            % output:   [Forwards,Backwards] old TotalNumberOfSteps
            
            %- Input handling
            isaninteger = @(x)isfinite(x) & x==floor(x);
            assert(isaninteger(ChannelNumber) & ChannelNumber > 0 & ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            
            %- Old values as output
            [Forwards,Backwards] = this.GetTotalNumberOfSteps(ChannelNumber);
            
            %- set TotalNumberOfSteps to zero
            this.TotalNumberOfStepsForwards(ChannelNumber) = 0;
            this.TotalNumberOfStepsBackwards(ChannelNumber) = 0;
            
        end
        
        %% Reset Device
        function reset(this)
            this.write(this.CommandList.Reset);
        end
        
        %% Disconnect Device
        function USB_disconnect(this)
            disp('Disconnecting...');
            this.IsConnected=0;
            try
                this.NP_USB.CloseDevices()
                disp('Diconnected!');
            catch ME
                rethrow(ME);
            end
        end
        
        %% Reset Device parameters
        function recallParameters(this, binVal)
        % This command restores the controller working parameters from values saved in its non-
        % volatile memory.  It is useful when, for example, the user has been exploring and 
        % changing parameters (e.g., velocity) but then chooses to reload from previously stored, 
        % qualified settings.  Note that “*RCL 0” command just restores the working parameters to 
        % factory default settings. “*RCL 1” Restores last saved settings.  
           this.write([this.CommandList.RecallParams num2str(binVal)]) 
        end
        
        %% Query for errors 
        function ret=GetErrors(this)
            ret=this.query(this.CommandList.ErrorMessageQuery);
        end
        
        %%      ======= START SETTERS/GETTERS ========
        %
        % These functions are used to validate the configuration parameters.
        
    end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
%- Methods (Static)

    methods (Static)
    
        function USB_reperror(errorcode, optext)
        % NP_USB_REPERROR report interpretation of Newport USB firmware error code

            switch errorcode 
                case 0
                    %fprintf([optext ' operation correctly executed \n'])
                case 1
                    fprintf([optext ' error USBDUPLICATEADDRESS, More than one device on the bus has the same device ID \n'])
                case -2
                    fprintf([optext ' error USBADDRESSNOTFOUND, The device ID cannot be found among the open devices on the bus \n'])
                case -3
                    fprintf([optext ' error USBINVALIDADDRESS, The device ID is outside the valid range of 0 - 31 \n'])
                otherwise
                    fprintf([optext ' error Unknown... \n'])
            end
        end
    end
end