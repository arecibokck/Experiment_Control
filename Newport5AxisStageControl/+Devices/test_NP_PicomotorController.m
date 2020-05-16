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
    %% - Test: ControllerDevice-Method: GetNumberOfStepsStillToBePerformed
    Controller.ControllerDevice{1}.GetNumberOfStepsStillToBePerformed(1)
    %% - Test: ControllerDevice-Method: Move(this, ChannelNumber, Target, varargin)
    ChannelNumber = 1;
    Target = 2000;
    %
    Controller.ControllerDevice{1}.AbsoluteMoveToTargetPosition(ChannelNumber,Target) 
    [F,B] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber);      
    %-
    Controller.ControllerDevice{1}.TotalNumberOfStepsForwards                         
    Controller.ControllerDevice{1}.TotalNumberOfStepsBackwards                        
    
    
    %% - Test: ControllerDevice-Method: GetMotionDoneStatus
    Controller.ControllerDevice{1}.GetMotionDoneStatus(1) % ControllerDeviceIndex==1, Axis==1
    
    %% - Test: ControllerDevice-Method: StopAll
    %- Move
    Target=2000;
    DelayTime=0.5;  %in sec

    Controller.ControllerDevice{1}.IsPicomotorReady

    %
    Controller.ControllerDevice{1}.RelativeMoveToTargetPosition(ChannelNumber,Target) % ControllerDeviceIndex==1

    %-stop after delay-time
    pause(DelayTime)
    Controller.ControllerDevice{1}.StopAll % ControllerDeviceIndex==1, Axis==1
    
    %% - Test: ControllerDevice-Method: ResetTotalNumberOfSteps

    ChannelNumber = 1;

    [ForwardsOld,BackwardsOld] = Controller.ControllerDevice{1}.GetTotalNumberOfSteps(ChannelNumber);

    [Forwards,Backwards] = Controller.ControllerDevice{1}.ResetTotalNumberOfSteps(ChannelNumber);

    assert(ForwardsOld-Forwards==0)
    assert(BackwardsOld-Backwards==0)
    
end

%% - Testing the PicomotorScrews-Class
%%%%%%%%%
%%%
%%% Testing the PicomotorScrews-Class
%%% 
%%%
%%%%%%%%% 
if true
    %% Write to and Read from Picomotor through Built-In Handlers

    % set = '2AC400';
    % query = 'TB?';
    % movesteps= '1PR-100';

    % picomotor.ControllerDevice{1}.write(set)
    % picomotor.ControllerDevice{1}.query(query)
    % picomotor.ControllerDevice{1}.GetErrors()
    % picomotor.ControllerDevice{1}.IsControllerReady()
    % picomotor.ControllerDevice{1}.GetMotorType(1)
    % picomotor.ControllerDevice{1}.SetMotorType(1)
    % picomotor.ControllerDevice{1}.GetAcceleration(1)
    % picomotor.ControllerDevice{1}.SetAcceleration(1);
    % picomotor.ControllerDevice{1}.GetAcceleration(1)
    % picomotor.ControllerDevice{1}.GetVelocity(1)
    % picomotor.ControllerDevice{1}.SetVelocity(1,400);
    % picomotor.ControllerDevice{1}.GetVelocity(1)
    % picomotor.ControllerDevice{1}.GetHome(1)
    % picomotor.ControllerDevice{1}.SetHome(1)
    % picomotor.ControllerDevice{1}.GetAbsoluteTargetPosition(1)
    % picomotor.ControllerDevice{1}.GetRelativeTargetPosition(1)
    % picomotor.ControllerDevice{1}.AbsoluteMoveToTargetPosition(1,1,'-')
    % picomotor.ControllerDevice{1}.RelativeMoveToTargetPosition(1,100,'-')
end