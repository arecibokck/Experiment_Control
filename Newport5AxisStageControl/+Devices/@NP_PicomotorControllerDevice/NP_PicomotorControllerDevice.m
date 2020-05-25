% NP_8742_Controller Device class to communicate with Controllers from
% New Focus Piezo Controller 8742. It connects to the controllers via USB  or ethernet.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef NP_PicomotorControllerDevice < Devices.Device 

%- Properties
    
    properties (Constant)
        DEFAULTPRODUCTID =           '4000';
        DEFAULTDEVICEKEY =     '8742-65992';
        DEFAULTUSBADDR   =                1;
        DEFAULTIPADDR    = '131.220.157.42'; 
        DEFAULTPORT      =               23;
    end
    
    properties
    	productID;
        deviceKey
        USBADDR;
        IPADDR;
        Port;
        NP_USB;
        NP_ETHERNET
    end
    
    properties
        
        %-DeviceStatus
        ConnectionType;                                                         %USB or ETHERNET
        IsConnected;                                                            %true if connection is open
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
        function this = NP_PicomotorControllerDevice(productID,deviceKey,varargin)
            %
            %
            % Inputs:
            % productID     -   Hex string Product ID 
            % DeviceKey     -   [Model Nr Serial Nr]
            % USBADDR	    -   0-31
            %
            %
            %
            this@Devices.Device;
            input = inputParser;
            addRequired(input,'productID',@ischar);
            addRequired(input,'deviceKey',@ischar);
            validUSBAddr = @(x) isfinite(x) && x==floor(x) && (x >= 0) && x <= 31;
            addParameter(input,'USBADDR',this.DEFAULTUSBADDR,validUSBAddr);
            addParameter(input,'IPADDR',this.DEFAULTIPADDR,@ischar);
            isaninteger = @(x)isfinite(x) && x==floor(x);
            addParameter(input,'Port',this.DEFAULTPORT,isaninteger);
            parse(input, productID, deviceKey, varargin{:});
            this.productID = input.Results.productID;
            this.deviceKey = input.Results.deviceKey;
            this.USBADDR  = input.Results.USBADDR;
            this.IPADDR = input.Results.IPADDR;
            this.Port  = input.Results.Port;
            %-Default values
            this.IsConnected = 0; % not connected
        end
        %% Class Destructor (Closes Connection, Unloads DLL, Clears object)
        function delete(this)
            className = class(this);
            disp(['Destructor called for class ',className])
            try 
                %-Abort all motion & Close Connection
                if(this.IsConnected)
                    this.AbortMotion();
                    this.DisconnectFromDevice;
                end
                disp(['Deleting ' className ' object...']);
                %-delete ControllerDevice-objects
                this.delete
                disp(['Stopped all motion, closed connection and deleted ' className ' object.']);
            catch ME
                warning(ME.message)
                rethrow(ME)
            end
        end
        %% Establish USB Connection
        function ConnectToDevice(this, ctype)
        % This method establishes connection with the controller device.
        % For connecting to the device by USB, the method loads the Newport USB Driver .NET Wrapper.
        % For connecting to the device by Ethernet, the method uses tcpip from the Instrumentation Control Toolbox.
        % Establishes and verifies connection with device self-identification [Newport Name Firmware Date SN]
        % Sometimes requires a reboot of the Newport Device to ensure connectivity!
                   
            disp('Looking for Controller device(s)...')
            this.ConnectionType = ctype;
            try
                switch this.ConnectionType
                    case 'USB'
                        %-Create objects for each or the one Controller
                        NPasm = NET.addAssembly('C:\Program Files\Newport\Newport USB Driver\Bin\UsbDllWrap.dll');
                        %Get a handle on the USB class
                        NPASMtype = NPasm.AssemblyHandle.GetType('Newport.USBComm.USB');
                        %launch the class USB, it constructs and allows to use functions in USB.h
                        this.NP_USB = System.Activator.CreateInstance(NPASMtype);

                        %Open the USB device(s)
                        devOpen = this.NP_USB.OpenDevices(hex2dec(this.productID), true);
                        if (~devOpen)
                            error('Could not find/open any Controller device(s).');
                        else
                            %-Get list of Connected USB-Devices
                            DevTable = this.NP_USB.GetDeviceTable(); %Figure out how to access the values of this hashtable which should be device keys as strings
                            %-Check which Controller device(s) is/are connected
                            if (DevTable.Count == 0)
                                this.NP_USB.CloseDevices(); %Make sure that the system is properly shut down
                                this.delete();
                                error('No Controller device(s) discovered. Troubleshoot connection issues!');
                            elseif(DevTable.Count == 1)
                                devInfo = this.query(this.CommandList.IdentificationQuery);
                                if contains(this.deviceKey,devInfo(end-4:end)) %Dirty fix: Figure out how to read out device keys 
                                    this.IsConnected = 1;
                                    disp(['Found Controller device: ' devInfo]);
                                end
                            else
                                disp('Found multiple Controller devices. All devices are now open, will proceed to only create objects for each.');
                            end
                        end
                    case 'ETHERNET'
                        this.NP_ETHERNET = tcpip(this.IPADDR, this.Port);
                        %this.NP_ETHERNET.InputBufferSize = 512; % total number of bytes that can be stored in the software input buffer during a read operation
                        %this.NP_ETHERNET.OutputBufferSize = 512;
                        this.NP_ETHERNET.Timeout =  3; % [s]
                        try
                            fopen(this.NP_ETHERNET);
                            devInfo = this.query(this.CommandList.IdentificationQuery);
                            %String cleanup: Input buffer often has unreadable ascii characters that need to be removed. Flushinput did not
                            %work so here is a nifty two-line code to pick out only those characters from the string that are ascii characters
                            %found between 32 and 127. This requires device ID to be restricted to these characters. This can be changed by
                            %increasing the range of ascii characters to check against.
                            ascii = char(32:127);
                            devInfo = devInfo(arrayfun(@(f) any(strcmp(devInfo(f),arrayfun(@(x) ascii(x), 1:length(ascii),'UniformOutput',false))), 1:length(devInfo)));
                            if contains(this.deviceKey,devInfo(end-4:end))    %Dirty fix: Hostname is by default the device key but this could be changed!
                                this.IsConnected = 1;                         %So this is a potential point of failure  
                                disp(['Found Controller device: ' devInfo]);
                            end
                        catch ME
                            warning(ME.message)
                            rethrow(ME)
                        end
                end
            catch ME
                warning(ME.message)
                rethrow(ME)
            end
        end   
        %% Write
        function write(this, cmd)
            switch this.ConnectionType
                case 'USB'
                    this.USB_reperror(this.NP_USB.Write(this.deviceKey, cmd),'Write');
                case 'ETHERNET'
                    fprintf(this.NP_ETHERNET, cmd);
            end        
        end
        %% Read
        function ret = read(this)
            switch this.ConnectionType
                case 'USB'
                    %The Query method sends the passed in command string to the specified device and reads the response data.
                    readdata = System.Text.StringBuilder(64);
                    this.USB_reperror(this.NP_USB.Read(this.deviceKey, readdata),'Read');
                    ret = char(ToString(readdata));
                case 'ETHERNET'
                    ret = strtrim(fscanf(this.NP_ETHERNET));
            end
        end
        %% Query
        function ret=query(this, query)
            this.write(query)
            ret = this.read;
        end
        %% Query and convert the result to a double precision floating point number
        function ret=queryDouble(this, query)
            ret=str2double(this.query(query));
        end
        %% Check if Controller device is ready by doing a Connection and error check if connected
        function ReadyStatus = IsControllerReady(this)
            % Asks controller for ready status
            %-Check if Connection is Open
            try
                devInfo = this.query(this.CommandList.IdentificationQuery);
                if ~isempty(devInfo) && contains(this.deviceKey,devInfo(end-4:end)) %Dirty fix: Figure out how to read out device keys 
                    this.IsConnected = 1;
                    Error = this.GetError;
                    if Error.Code == 0
                        ReadyStatus = true;
                    end
                else
                    this.IsConnected = 0;
                    ReadyStatus = false;
                    warning('Possible loss of connection! Troubleshoot connection issues!');
                end
            catch ME
                warning(ME.message)
                rethrow(ME)
            end
            this.ReadyStatus = ReadyStatus;
        end
        %% Get Motor Type
        function [MotorType, Error] = GetMotorType(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            MotorType = this.queryDouble([num2str(ChannelNumber) this.CommandList.MotorTypeQuery]);
            Error = this.GetError;
        end    
        %% Set Motor Type
        function Error = SetMotorType(this, ChannelNumber, motortype)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(motortype) && motortype < 4 ,'Invalid type number. Check if it is an integer between 0 and 3.')
            if isequal(this.GetMotorType(ChannelNumber), motortype)
                warning('Motor type already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetMotorType num2str(motortype)]);
                disp(['Motor type set to ' num2str(motortype)]);
            end
            Error = this.GetError;
        end    
        %% Get Acceleration
        function [Accn, Error] = GetAcceleration(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            Accn = this.queryDouble([num2str(ChannelNumber) this.CommandList.AccelerationQuery]);
            Error = this.GetError;
        end 
        %% Set Acceleration
        function Error = SetAcceleration(this, ChannelNumber, acceleration)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(acceleration) && acceleration > 0 && acceleration < 200001 ,'Invalid Acceleration value. Check if it is an integer between 1 and 200000.')
            if isequal(this.GetAcceleration(ChannelNumber), acceleration)
                warning('Acceleration already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetAcceleration num2str(acceleration)]);
                disp(['Acceleration set to ' num2str(acceleration)]);
            end
            Error = this.GetError;
        end
        %% Get Velocity
        function [vel, Error] = GetVelocity(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            vel = this.queryDouble([num2str(ChannelNumber) this.CommandList.VelocityQuery]);
            Error = this.GetError;
        end
        %% Set Velocity
        function Error = SetVelocity(this, ChannelNumber, velocity)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(velocity) && velocity > 0 && velocity < 2001 ,'Invalid Velocity value. Check if it is an integer between 1 and 2000.')
            if isequal(this.GetVelocity(ChannelNumber), velocity)
                warning('Velocity already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetVelocity num2str(velocity)]);
                disp(['Velocity set to ' num2str(velocity)]);
            end
            Error = this.GetError;
        end
        %% Get Home position
        function [home,Error] = GetHome(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            home = this.queryDouble([num2str(ChannelNumber) this.CommandList.HomePositionQuery]);
            Error = this.GetError;
        end
        %% Set Home position
        function Error = SetHome(this, ChannelNumber, home)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(home) && home >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                     && home <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                          ,'Invalid Home position. Check if it is an integer between -2147483648 and +2147483647.')
            if isequal(this.GetHome(ChannelNumber), home)
                warning('Home position already to set this value!');
            else
                this.write([num2str(ChannelNumber) this.CommandList.SetHomePosition num2str(home)]);
                disp(['Home position set to ' num2str(home)]);
            end
            Error = this.GetError;
        end
        %% Get absolute target position
        function [target, Error] = GetAbsoluteTargetPosition(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            target = this.queryDouble([num2str(ChannelNumber) this.CommandList.AbsoluteTargetPositionQuery]);
            this.TargetPosition = target;
            Error = this.GetError;
        end
        %% Get relative target position
        function [target, Error] = GetRelativeTargetPosition(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            target = this.queryDouble([num2str(ChannelNumber) this.CommandList.RelativeTargetPositionQuery]);
            this.TargetPosition = target;
            Error = this.GetError;
        end
        %% Get current position
        function [pos, Error] = GetCurrentPosition(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            pos = this.queryDouble([num2str(ChannelNumber) this.CommandList.CurrentPositionQuery]);
            Error = this.GetError;
        end
        %% Check if an axis is moving
        function [isMoving, Error] = IsPicomotorMoving(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            motionstatus = this.queryDouble([num2str(ChannelNumber) this.CommandList.MotorDoneStatusQuery]);
            if ~isnan(motionstatus)
                isMoving = ~motionstatus;
            elseif this.GetNumberOfStepsStillToBePerformed(ChannelNumber) ~= 0
                this.IsPicomotorMoving(ChannelNumber); % Recursion but without base case! Danger of stack overflow error! Will the conditional take care of this?
            end    
            Error = this.GetError;
        end 
        %% Motion of an axis
        % WaitForStopOfMovement(this,varargin)
        function WaitResult=WaitForStopOfMovement(this,varargin)
            % Runs a while loop until IsPicomotorMoving(this)==0, each
            % loop contains pause(Pause_Time)
            %input varargin	
            %           nargin=0    Pause_Time=this.Pause_Time
            %                       MaxIter=this.Pause_Max_Iterations
            %           nargin=1    MaxIter==varagin{1}
            %           nargin=2    Pause_Time=varagin{2}
            %output WaitResult      true,   if MovementStopped  
            %                       false,  if MaxIter is reached
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
                [isMoving, ~] = this.IsPicomotorMoving(ChannelNumber);
                if ~isMoving                    % Check if Moving
                    break
                end
                pause(PauseTime)                % Wait
                MaxIter=MaxIter-1;              % CountDown
            end
            %-Set Output
            if MaxIter==0
                WaitResult=false;
                warning('Maximum iterations reached for WaitForStopOfMovement.')
            else
                WaitResult=true;
            end
        end
        %Move indefinitely
        function Error = MoveIndefinitely(this, ChannelNumber, direction)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(any(direction == ['+','-']),'Invalid direction. Specify as either + (positive direction) or - (negative direction).')
            if isequal(direction, '+')
                disp('Moving indefinitely in the positive direction...');
            else
                disp('Moving indefinitely in the negative direction...');
            end
            this.write([num2str(ChannelNumber) this.CommandList.IndefiniteMove direction]);
            while this.IsPicomotorMoving(ChannelNumber)
                if this.TotalNumberOfStepsForwards(ChannelNumber) == this.MaxNumberOfSteps.UserDefined || this.TotalNumberOfStepsForwards(ChannelNumber) == -this.MaxNumberOfSteps.UserDefined
                    this.StopMotion(ChannelNumber);
                    warning('Motion stopped: Number of steps taken from home position has reached user-defined maximum in one direction.');
                    break
                end
            end
            Error = this.GetError;
        end
        %Move to target position
        function Error = MoveAbsolute(this, ChannelNumber, target)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(target) && target >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                       && target <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                       ,'Invalid target position. Check if it is an integer between -2147483648 and +2147483647.')
            this.TargetPosition = target;
            currentPos = this.GetCurrentPosition(ChannelNumber);
            NumberOfSteps = abs(target - currentPos);
            if target ~= currentPos 
                if NumberOfSteps < 3
                    warning('No error will be detected even if the motor is not connected for less than 3 steps! Manual check required!')
                end
                if target == 0
                    disp('Moving to home...');
                elseif target > 0 && NumberOfSteps <= this.MaxNumberOfSteps.UserDefined
                    disp(['Moving to +' num2str(abs(target)) '...']);
                elseif target < 0 && NumberOfSteps >= -this.MaxNumberOfSteps.UserDefined 
                    disp(['Moving to -' num2str(abs(target)) '...']);
                else 
                    warning('Number of steps exceeds user-defined limit. Axis will not be moved in either direction.');
                    target = currentPos;
                end            
                this.write([num2str(ChannelNumber) this.CommandList.AbsoluteMove num2str(target)]);
            else
                disp('Currently at target position.')
            end
            Error = this.GetError;
            %-Wait till movement stops
            WaitResult=this.WaitForStopOfMovement(ChannelNumber);
            if WaitResult && Error.Code==0
                %-Update Total Number of Steps taken
                this.UpdateTotalNumberOfSteps(ChannelNumber, NumberOfSteps)
            end
        end
        %Move Relative
        function Error = MoveRelative(this, ChannelNumber, NumberOfSteps)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            assert(isaninteger(NumberOfSteps) && NumberOfSteps >= -this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... -2147483648 ... 
                                              && NumberOfSteps <= +this.MaxNumberOfSteps.HardwareLimit ... 2^31 ... +2147483647 ...
                                              ,'Invalid number of steps. Check if it is an integer between -2147483648 and +2147483647.')
            this.TargetPosition = this.GetCurrentPosition(ChannelNumber) + NumberOfSteps;
            if NumberOfSteps ~= 0
                if NumberOfSteps < 3
                    warning('No error will be detected even if the motor is not connected for less than 3 steps! Manual check required!')
                end
                if NumberOfSteps > 0 && NumberOfSteps <= this.MaxNumberOfSteps.UserDefined
                    disp(['Moving by ' num2str(abs(NumberOfSteps)) ' steps in the positive direction...']);
                elseif NumberOfSteps < 0 && NumberOfSteps >= -this.MaxNumberOfSteps.UserDefined 
                    disp(['Moving by ' num2str(abs(NumberOfSteps)) ' steps in the negative direction...']);
                else 
                    NumberOfSteps = 0;
                    warning('Number of steps exceeds user-defined limit. Axis will not be moved in either direction.');
                end
                this.write([num2str(ChannelNumber) this.CommandList.RelativeMove num2str(NumberOfSteps)]);
            else
                disp('Axis will not be moved in either direction.');
            end
            Error = this.GetError;
            %-Wait till movement stops
            WaitResult=this.WaitForStopOfMovement(ChannelNumber);            
            if WaitResult && Error.Code==0
                %-Update Total Number of Steps taken
                this.UpdateTotalNumberOfSteps(ChannelNumber, NumberOfSteps)
            end
        end
        % Stop movement of an axis with deceleration (the negative of the
        % specified acceleration)
        function Error = StopMotion(this, ChannelNumber)
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            
            if this.IsPicomotorMoving(ChannelNumber)
                disp(['Stopping motion of ' num2str(ChannelNumber) ' axes...']);            
                this.write([num2str(ChannelNumber) this.CommandList.StopMotion]);
            else
                disp('Axis has already come to a halt.');             
            end
            Error = this.GetError;
        end
        % Abort Motion of all axes without deceleration
        function Error = AbortMotion(this)
            disp('Aborting motion of all axes...');             
            this.write(this.CommandList.AbortMotion);
            Error = this.GetError;
        end
        %% Get number of steps still to be performed 
        function [NumberOfSteps, Error] = GetNumberOfStepsStillToBePerformed(this, ChannelNumber)
            % Get number of steps still to be performed 
            %varargin:      nargin=0            ChannelNumber=1
            %               nargin=1            ChannelNumber=varargin{1},
            %output:        NumberOfSteps       number of steps still to be performed
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
            NumberOfSteps =  this.TargetPosition - this.GetCurrentPosition(ChannelNumber);
            this.NumberOfStepsStillToBePerformed = NumberOfSteps;
            Error = this.GetError;
        end
        %% Get TotalNumberOfSteps
        function [Forwards,Backwards] = GetTotalNumberOfSteps(this,ChannelNumber)
            % [Forwards,Backwards]=GetTotalNumberOfSteps(ChannelNumber)
            % returns deviceData.TotalNumberOfStepsForwards and ...Backwards for
            % specified Channel
            %-Input handling
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
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
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
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
            isaninteger = @(x)isfinite(x) && x==floor(x);
            assert(isaninteger(ChannelNumber) && ChannelNumber > 0 && ChannelNumber < 5 ,'Invalid channel number. Check if it is an integer between 1 and 4.');
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
        function DisconnectFromDevice(this)
            disp('Disconnecting...');
            this.IsConnected=0;
            try
                switch this.ConnectionType
                    case 'USB'
                        this.NP_USB.CloseDevices()
                    case 'ETHERNET'
                        fclose(this.NP_ETHERNET);
                        echotcpip('off');
                end 
                disp('Diconnected!');
            catch ME
                warning(ME.message)
                rethrow(ME)
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
        function ret=GetError(this)
            pause(0.4);
            err = this.query(this.CommandList.ErrorMessageQuery); 
            [token,remain] = strtok(err,',');
            code = str2double(token);
            message = extractAfter(remain, ', ');
            ret = struct('Code', code, 'Message', message);
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
                    fprintf([optext ' error USBDUPLICATEADDRESS, More than one device on the bus has the same USB address \n'])
                case -2
                    fprintf([optext ' error USBADDRESSNOTFOUND, The USB address cannot be found among the open devices on the bus \n'])
                case -3
                    fprintf([optext ' error USBINVALIDADDRESS, The USB address is outside the valid range of 0 - 31 \n'])
                otherwise
                    fprintf([optext ' error Unknown... \n'])
            end
        end
    end
end