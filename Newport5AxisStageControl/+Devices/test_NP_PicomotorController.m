%% This script is testing the functionalities of the NP_PicomotorController-Class
%  by creating one instance and running example-code for each method
%
%  Important:  Run only sectionwise!! 

%% - Testing the Controller-Class
%%%%%%%%%
%%%
%%% Testing the Controller-Class
%%%
%%%%%%%%%
if true
    %% - Create Object with Default ID
    Controller = Devices.NP_PicomotorController.getInstance();
    %% - delete Object
    Controller.delete()
    %% - Destroy Object
    clear Controller
end

%% - Testing the ControllerDevice-Class
%%%%%%%%%
%%%
%%% Testing the ControllerDevice-Class
%%%
%%%%%%%%%
if true
    %% - Test: ControllerDevice-Method: Open Connection
    Controller.ControllerDevice{1}.ConnectToDevice()
    %% - Test: ControllerDevice-Method: Close Connection
    Controller.disconnectPicomotorController(1);
    % Controller.ControllerDevice{1}.DisconnectFromDevice
    %% - Test: ControllerDevice-Method: reconnect PicomotorControllerDevice
    Controller.reconnectPicomotorController(1); 
    %% - Test: ControllerDevice-Method: IsControllerReady
    isReady = Controller.ControllerDevice{1}.IsControllerReady;
    %% - Test: ControllerDevice-Method: Get and Set MotorType
    Controller.ControllerDevice{1}.GetMotorType(1)
    Controller.ControllerDevice{1}.SetMotorType(1,2)
    %% - Test: ControllerDevice-Method: Get and Set Acceleration
    Controller.ControllerDevice{1}.GetAcceleration(1)
    Controller.ControllerDevice{1}.SetAcceleration(1,200);
    %% - Test: ControllerDevice-Method: Get and Set Velocity
    Controller.ControllerDevice{1}.GetVelocity(1)
    Controller.ControllerDevice{1}.SetVelocity(1,400);
    %% - Test: ControllerDevice-Method: Get and Set Home position
    Controller.ControllerDevice{1}.GetHome(1)
    %Controller.ControllerDevice{1}.SetHome(1)
    %% - Test: ControllerDevice-Method: Get Target Position
    Controller.ControllerDevice{1}.GetAbsoluteTargetPosition(1)
    Controller.ControllerDevice{1}.GetRelativeTargetPosition(1)
    %% - Test: ControllerDevice-Method: Move
    ChannelNumber = 4;
    Target = 0;
    Controller.ControllerDevice{1}.MoveAbsolute(ChannelNumber,Target)
    [Forwards,Backwards] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber);     
    %% - Test: ControllerDevice-Method: IsPicomotorMoving
    Controller.ControllerDevice{1}.IsPicomotorMoving(1) % ControllerDeviceIndex==1, Axis==1
    %% - Test: ControllerDevice-Method: GetNumberOfStepsStillToBePerformed
    Controller.ControllerDevice{1}.GetNumberOfStepsStillToBePerformed(1)
    %% - Test: ControllerDevice-Method: Stop motion of one axis (Currently NOT functioning as expected. needs to be debugged)
    %- Move
    Target=500;
    DelayTime=0.1;  %in sec

    Controller.ControllerDevice{1}.MoveRelative(ChannelNumber,Target) % ControllerDeviceIndex==1
    %-stop after delay-time
    pause(DelayTime)
    Controller.ControllerDevice{1}.StopMotion(ChannelNumber) % ControllerDeviceIndex==1, Axis==1
    %% - Test: ControllerDevice-Method: Abort
    Controller.ControllerDevice{1}.AbortMotion;
    %% - Test: ControllerDevice-Method: ResetTotalNumberOfSteps
    ChannelNumber = 1;
    [Forwards_Old,Backwards_Old] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber)
    [Forwards,Backwards] = Controller.ControllerDevice{1}.ResetTotalNumberOfSteps(ChannelNumber)
    assert(Forwards_Old-Forwards==0)
    assert(Backwards_Old-Backwards==0)
end

%% - Testing the PicomotorScrews-Class
%%%%%%%%%
%%%
%%% Testing the PicomotorScrews-Class
%%% 
%%%
%%%%%%%%% 
if true
    NameOfPicomotorScrew = 'placeholderName4';
    %% - Get and Set MotorType
    Controller.PicomotorScrews.(NameOfPicomotorScrew).GetMotorType
    Controller.PicomotorScrews.(NameOfPicomotorScrew).SetMotorType(2)
    %% Get and Set Acceleration
    Controller.PicomotorScrews.(NameOfPicomotorScrew).GetAcceleration
    Controller.PicomotorScrews.(NameOfPicomotorScrew).SetAcceleration(200);
    %% Get and Set Velocity
    Controller.PicomotorScrews.(NameOfPicomotorScrew).GetVelocity
    Controller.PicomotorScrews.(NameOfPicomotorScrew).SetVelocity(400);
    %% Get and Set Home position
    Controller.PicomotorScrews.(NameOfPicomotorScrew).GetHome
    Controller.PicomotorScrews.(NameOfPicomotorScrew).SetHome(1)
    %% - Move Forwards to absolute position
    Controller.PicomotorScrews.(NameOfPicomotorScrew).MoveAbsolute(200)
    %% - Move Forwards to relative position
    Controller.PicomotorScrews.(NameOfPicomotorScrew).MoveRelative(10)
    %% - Move Backwards to absolute position
    Controller.PicomotorScrews.(NameOfPicomotorScrew).MoveAbsolute(-200)
    %% - Move Backwards to relative position
    Controller.PicomotorScrews.(NameOfPicomotorScrew).MoveRelative(-10)
    %% - Stop Motion
    Controller.PicomotorScrews.(NameOfPicomotorScrew).StopMotion
    %% - Abort Motion
    Controller.ControllerDevice{1}.AbortMotion
    %% - Get Total Number of Steps
    [Forwards,Backwards] = Controller.PicomotorScrews.(NameOfPicomotorScrew).GetTotalNumberOfSteps
    %% - Reset Total Number of Steps
    [Forwards,Backwards] = Controller.PicomotorScrews.(NameOfPicomotorScrew).ResetTotalNumberOfSteps
end

if true
    %% -Define alias of axis, motor properties, controller device number
    Alias = 'placeholderName1';
    MotorProperties = struct('ChannelNumber',  1,  ...
                             'MotorType',      1,  ...
                             'HomePosition',   0,  ...
                             'Velocity',     400,  ...
                             'Acceleration', 200);                                
    ControllerDeviceNumber = 1;
    %% -Create Instance (nargin==2)
    Axis = Devices.NP_PicomotorScrews(Alias, MotorProperties);
    %% Create Instance (nargin==3)
    Axis = Devices.NP_PicomotorScrews(Alias, MotorProperties, ControllerDeviceNumber);
    %% -Call ControllerDevice: Disconnect
    Axis.disconnectPicomotorController
     %% -Call ControllerDevice: Reconnect
    Axis.reconnectPicomotorController
    %% -Delete Instance
    Axis.delete
    %% -Call ControllerDevice:  IsControllerReady
    IsReady = Axis.IsControllerReady;
    %% -Call ControllerDevice: Get and Set MotorType
    Axis.GetMotorType
    Axis.SetMotorType(2)
    %% -Call ControllerDevice: Get and Set Acceleration
    Axis.GetAcceleration
    Axis.SetAcceleration(200);
    %% -Call ControllerDevice: Get and Set Velocity
    Axis.GetVelocity
    Axis.SetVelocity(400);
    %% -Call ControllerDevice: Get and Set Home position
    Axis.GetHome
    Axis.SetHome(20)
    %% -Call ControllerDevice: -Call ControllerDevice:  MoveAbsolute
    Target=0;
    Axis.MoveAbsolute(Target);
    %% -Call ControllerDevice: -Call ControllerDevice:  MoveRelative
    NumberOfSteps=1000;
    Axis.MoveRelative(NumberOfSteps); 
    %% -Call ControllerDevice:  Stop
    Axis.StopMotion;
    %% -Get Total Number Of Steps Taken
    [Forwards,Backwards] = Axis.GetTotalNumberOfSteps
    %% -Reset Total Number Of Steps Taken
    [Forwards,Backwards] = Axis.ResetTotalNumberOfSteps
end