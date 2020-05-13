%% - test_Signadyne
% How-To Example code that also can be used to check different functions of Signadyne
%
%  Note:
%       -   The Channels 1-4 and 1-8 have to be adressed as  0-3 and 0-7
%       -   

%% Variables
mod = 'module2';
firmware_filename = '6_2.sbp';
clk_freq = ;
nAWG = ;
nCH = ;
address = ;
data = ;
PLL_freq = ;
PLL_phase = ;
PLL_acc = ;
PLL_range = ;
PID_channel = 0;  
AOM_channel = 1;
AOM_Frequency = 80e06;
AOM_Amplitude = 0.9;
AOM_Phase = 0;

%% Methods related to Initialization

%sd = Devices.SignadynePLL.getInstance([2 5 7]) - operate the slot 2,5,7.
sd = Devices.SignadynePLL.getInstance([2]); %operate the slot 2
sd.selectModule(mod); %turn on the specified module
sd.init(); %initialize the signadyne.

%% Methods related to Modules

sd.selectModule(mod);
sd.setModuleClockFrequency(clk_freq);
sd.loadFirmwareToModule(firmware_filename); %load FPGA firmware with name
sd.loadFirmwareToModules(firmware_filename);

%% Methods related to Channels

sd.enableChannel(nAWG);
sd.disableChannel(nAWG);
sd.setChannelOffset(nCH, offset);
sd.setChannelAmplitude(nCH, amplitude);
sd.setChannelFrequency(nCH, freq);
sd.setChannelPhase(nCH, phase);
sd.setChannelWaveshape(nCH, shape);
sd.initializeChannel(nCH);

%% Methods related to DAQ

nDAQ = 1;
nP = 5000; %number of points
sd.flushDAQ();
sd.startDAQ(nDAQ);
sd.startDAQSingle(nDAQ);
sd.configureDAQ(nP, trigger);
sd.configureDAQSingle(nP, trigger);
sd.readDAQ(nDAQ);
sd.readDAQSingle(nDAQ);
sd.DAQread(nDAQ);
sd.DAQreadSingle(nDAQ);
sd.DAQplot();
sd.plotData(nDAQ);
sd.saveData(nDAQ);

%% Methods related to Save, Plot, Clear functionality

sd.saveAll(); 
sd.saveDemo();
sd.plotAll();
sd.clearData();

%% Methods related to PID Control

sd.PIDconfig(PID_channel); % get PID Configuration
p = 5000;
i = 250000;
d = 0;
sd.setPIDconfig(PID_channel, p, i, d); % set PID Configuration
sd.enablePID(PID_channel); % Enable PID
sd.disablePID(PID_channel); % Disable PID
sd.resetPID(PID_channel); % Reset PID

sd.setRegister();
sd.getRegister();
sd.writePIDport(nCH, address, data);

%% Methods related to Intensity lock

sd.setChannelAmplitude(AOM_channel,AOM_Amplitude); %set the amplitude of RF for AOM
sd.setChannelFrequency(AOM_channel,AOM_Frequency); %set the frequency of RF for AOM
sd.DAQread(AOM_channel); %monitor the intensity lock (ch ;1 and 2 for the intensity lock, but 6 and 7 for the phase lock)
sd.AOMstate(AOM_channel,[AOM_Amplitude;AOM_Phase]); %lock the intensity at amp, and set the phase setpoint to phase
%sd.AOMstate(AOM_channel,[AOM_Amplitude;AOM_Phase], 'noLock'); for no lock

%% Methods related to Phase lock

sd.enablePLL(nCH);
sd.disablePLL(nCH);
sd.resetPLL(nCH);
sd.setPLLfrequency(nCH, PLL_freq);
sd.setPLLphase(nCH, PLL_phase);
sd.resetPLLphase(nCH);
sd.setPLLaccumulatorSize(nCH, PLL_acc);
sd.setPLLPhaseLockedRange(nCH, PLL_range);
sd.setPLLFrequencyLockedRange(nCH, PLL_range);
sd.setPLLconfig(nCH);
sd.getPLLconfig(nCH);
sd.writePLLport(nCH, address, data);


%% Methods related to Execution

sd.startExecution();
sd.stopExecution();
 
%% Methods related to VectorOut pins
 
sd.getVectorPinName(mod, nCH);
sd.getVectorPin(name);
sd.getTriggerPin();
sd.clearPins();


%% Methods related special Pins (hardcoded names involved)

sd.setPLLReferenceState();
sd.setVDTstate(amplitude);
sd.setHDTstate(amplitude, varargin);

%% FPGA design

% Use this to reset module completely. 
% Restarting SD box might cause modules to go back to initial design with no locks. --> after restarting, reload Firmware
%'.sbp' are Firmware files compiled from FPGA block architecture made in the
%Keysight M3602A Design Environment

%% Test Ramp Routine

s = Sequence( ...
              sd.getVectorPin('HDT1L'), ...
              sd.getVectorPin('VDT')    ...
             );
    

% add horizontal dipole trap aoms
s.HDT1L.state([0; 0]);
s.VDT.state([0; 0]);

s.wait_ms(1);

% ramping
for k = 1:2
    s.HDT1L.linearRamp([1; 10]/10, 0.1);
    s.VDT.linearRamp([0.5; 5]/10, 0.1);

    s.HDT1L.linearRamp([0; 0], 0.1);
    s.VDT.linearRamp([0; 0], 0.1);
end

s.VDT.linearRamp([1; 10]/10, 0.1);
s.VDT.linearRamp([0; 0], 0.1);

s.sync();

figure(1)
plot(s.VDT);

%
sd.loadSequence(s);
sd.modules.module2.displayQueues(3);
mo = sd.modules.module2;

figure(2)
mo.plotQueue(3);

% sd.startExecution();
% pause(1);
% sd.stopExecution();