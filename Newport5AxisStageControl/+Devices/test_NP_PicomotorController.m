%% - get Picomotor-Object
picomotor = Devices.NP_PicomotorController;

%% Write to and Read from Picomotor through Built-In Handlers

% set = '2AC400';
% query = 'TB?';
% movesteps= '1PR-100';

% picomotor.ControllerDevice{1}.write(set)
% picomotor.ControllerDevice{1}.query(query)
% picomotor.ControllerDevice{1}.GetErrors()
% picomotor.ControllerDevice{1}.IsReady()
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
%% Delete Picomotor Object
picomotor.delete();

%% Clear Workspace
clear all;
