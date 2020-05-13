%% - get Picomotor-Object
picomotor = Devices.NP_PicomotorController;

%% - Write to and Read from Picomotor


%% Write to and Read from Picomotor through Built-In Handlers

set = '2AC400';
query = 'TB?';
movesteps= '1PR-100';

picomotor.write(set)
picomotor.query(query)
picomotor.getErrors()
picomotor.IsControllerReady()

%% Delete Picomotor Object
picomotor.delete();

%% Clear Workspace
clear all;