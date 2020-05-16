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
    %% - Destroy Object
    clear Controller
    %% - delete Object
    Controller.delete()
end

%% - Testing the ControllerDevice-Class
%%%%%%%%%
%%%
%%% Testing the ControllerDevice-Class
%%%
%%%%%%%%%
if true
    %% - Test: ControllerDevice-Method: Open USB-Connection
    Controller.ControllerDevice{1}.USB_connect()
    %% - Test: ControllerDevice-Method: Close USB-Connection
    Controller.disconnectPicomotorController(1);
    % Controller.ControllerDevice{1}.USB_disconnect
    %% - Test: ControllerDevice-Method: reconnect PicomotorControllerDevice
    Controller.reconnectPicomotorController(1); 
    %% - Test: ControllerDevice-Method: IsPicomotorReady
    Controller.ControllerDevice{1}.IsPicomotorReady
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
    Controller.ControllerDevice{1}.SetHome(1)
    %% - Test: ControllerDevice-Method: Get Target Position
    Controller.ControllerDevice{1}.GetAbsoluteTargetPosition(1)
    Controller.ControllerDevice{1}.GetRelativeTargetPosition(1)
    %% - Test: ControllerDevice-Method: Move
    ChannelNumber = 1;
    Target = 0;
    Controller.ControllerDevice{1}.MoveAbsolute(ChannelNumber,Target)
    [F,B] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber);      
    %% - Test: ControllerDevice-Method: IsPicomotorMoving
    Controller.ControllerDevice{1}.IsPicomotorMoving(1) % ControllerDeviceIndex==1, Axis==1
    %% - Test: ControllerDevice-Method: GetNumberOfStepsStillToBePerformed
    Controller.ControllerDevice{1}.GetNumberOfStepsStillToBePerformed(1)
    %% - Test: ControllerDevice-Method: Stop motion of one axis (Currently NOT functional)
    %- Move
    Target=500;
    DelayTime=0.5;  %in sec

    Controller.ControllerDevice{1}.MoveRelative(ChannelNumber,Target) % ControllerDeviceIndex==1
    %-stop after delay-time
    pause(DelayTime)
    Controller.ControllerDevice{1}.StopMotion(ChannelNumber) % ControllerDeviceIndex==1, Axis==1
    %% - Test: ControllerDevice-Method: ResetTotalNumberOfSteps
    ChannelNumber = 1;
    [F_Old,B_Old] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber);
    [F,B] = Controller.ControllerDevice{1}.ResetTotalNumberOfSteps(ChannelNumber);
    assert(F_Old-F==0)
    assert(B_Old-B==0)
end

%% - Testing the PicomotorScrews-Class
%%%%%%%%%
%%%
%%% Testing the PicomotorScrews-Class
%%% 
%%%
%%%%%%%%% 
if true
    
end