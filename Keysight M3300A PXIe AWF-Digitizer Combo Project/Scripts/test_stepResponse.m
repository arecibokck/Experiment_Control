%% Initialization
%sd = Devices.SignadynePLL.getInstance([2 5 7]) - operate the slot 2,5,7.
sd = Devices.SignadynePLL.getInstance([2]); %operate the slot 2
sd.selectModule('module2'); %turn on the specified module
sd.init(); %initialize the signadyne.

%% Variables
PID_channel = 0;  
AOM_channel = 1;
AOM_Frequency = 80e06;
AOM_Amplitude = 0.9;
AOM_Phase = 0;

%% set PID Configuration
p = 5000;
i = 250000;
d = 0;
sd.setPIDconfig(PID_channel, p, i, d);

%% Ramp with Lock - AOMstate command has PID lock enabled unless explicitly unlocked
for j  = 1: 1000000
    sd.AOMstate(1,0.01);
    sd.AOMstate(1,0.3);
    pause(0.001)
end