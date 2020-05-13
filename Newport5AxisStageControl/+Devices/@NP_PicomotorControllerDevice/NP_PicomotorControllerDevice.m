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
        IsReady = false;                                                        %true if device ready to perform next command        
        IsMoving;                                                               %true if at least one Axis is moving
        NumberOfStepsStillToBePerformed; 
        ActiveChannel;                                                          %int, number of active Demultiplexer channel
        
        %-DeviceSettings:
        MaxNumberOfSteps = 30000;                                               %Upper limit of steps per Move-Command
                
        %-DeviceData
        TotalNumberOfStepsForwards  = 0;
        TotalNumberOfStepsBackwards = 0;
        
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
                             'TargetPositionMove', 'PA', ...
                             'TargetPositionQuery', 'PA?', ...
                             'RelativeMove', 'PR', ...
                             'RelativeTargetPositionQuery', 'PR?', ...
                             'SetMotorType', 'QM', ...
                             'MotorTypeQuery', 'QM?', ...
                             'SaveSettings', 'SM', ...
                             'StopMotion', 'ST', ...
                             'ErrorMessageQuery', 'TB?', ...
                             'ErrorCodeQuery', 'TE?', ...
                             'ActualPositionQuery', 'TP?', ...
                             'SetVelocity', 'VA', ...
                             'VelocityQuery', 'VA?', ...
                             'ControllerFirmwareQuery', 'VE?', ...
                             'PurgeSettings', 'XX', ...
                             'SetConfigurationRegister', 'ZZ', ...
                             'ConfigurationRegisterQuery', 'ZZ');
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
                this.StopAll

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
        function [IsReady] = IsPicomotorReady(this)
            % Asks controller for ready status
            
            %-Check if Connection is Open
            assert(this.ID~=-1,'The controller is not connected')
            
            this.write(this.CommandList.MotorCheck);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.query(this.CommandList.ErrorCodeQuery) == '0', ErrorMessage)
                IsReady = true;
            catch
                disp(['ErrorMessage = ', ErrorMessage])
                disp('No catch-routine for this. StopAll implemented')
                IsReady = false;
            end
            
            this.IsReady = IsReady;
        end
        
        %% Get number of steps still to be performed 
        
        %% Test if any axis of ControllerDevice is moving
        
        %% WaitForStopOfMovement(this,varargin)
        
        %% SetActiveChannel(DemultiplexerChannelNumber)
        
        %% GetActiveChannel
        
        %% MoveActiveChannel(NumberOfSteps)
        
        %% Move(DemultiplexerChannelNumber,NumberOfSteps,varargin)
        
        %% Stop movement of all Axes
        function StopAll(this)
            % Success=StopAll(this) stops movement of all Picomotor-channels
            % immediately
            % 
            disp('Stopping motion of all axes...');            
            this.write(this.CommandList.StopMotion);
            
            %- Error Handling
            ErrorMessage = this.GetErrors;
            
            try
                assert(this.query(this.CommandList.ErrorCodeQuery) == '0',ErrorMessage)
            catch
                disp(['ErrorMessage = ',ErrorMessage])
                disp(' ')
                disp('No catch-routine for this. StopAll implemented')
            end
        end
        
        %% Get TotalNumberOfSteps
        
        %% Set TotalNumberOfSteps
        
        %% Reset TotalNumberOfSteps
        
        %% Reset Device
        function reset(this)
            this.write(this.CommandList.Reset);
        end
        
        %% Disconnect Device
        function USB_disconnect(this)
            disp('Disconnecting...');
            this.IsConnected=0;
            this.NP_USB.CloseDevices();
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
                    fprintf([optext ' operation correctly executed \n'])
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