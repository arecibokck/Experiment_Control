%% - create and test device
if true
    %% -create object
    DeviceID = 'TCPIP0::131.220.157.72::inst0::INSTR';
    WaveGen = Devices.KeysightWaveGen.K33522BDevice(DeviceID);
    %%
    Channel_1 = WaveGen.channels(1);
    Channel_2 = WaveGen.channels(2);
    %%
    Channel_1.ChannelNumber
    %% 
    WaveGen.NumberOfChannels
    %% - query *Idn?
    ret = WaveGen.queryIdentification
    %% - self test (starts self test, but there is no return because of a visa timeout) 
    ret = WaveGen.selfTest
    %% - reset Device  (throws error)
    WaveGen.resetDevice
    %% - getError
    ret = WaveGen.getError
    %% - Abort
    WaveGen.Abort
end


%% - test Channel
if true
   ChannelNumber = 1; 
%%
    WaveGen.channels(ChannelNumber).Amplitude
%%
    WaveGen.channels(ChannelNumber).Offset
%%
    WaveGen.channels(ChannelNumber).HighLevel
%%
    WaveGen.channels(ChannelNumber).LowLevel
%%
    WaveGen.channels(ChannelNumber).AutoRange
%%
    WaveGen.channels(ChannelNumber).VoltageCouplingState
%%
    WaveGen.channels(ChannelNumber).VoltageUnits
%%
    WaveGen.channels(ChannelNumber).TriggerCount
%%
    WaveGen.channels(ChannelNumber).TriggerDelay
%%
    WaveGen.channels(ChannelNumber).TriggerSlope
%%
    WaveGen.channels(ChannelNumber).TriggerSource
%%
    WaveGen.channels(ChannelNumber).TriggerTimer
%%
    WaveGen.channels(ChannelNumber).BurstCycles
%%
    WaveGen.channels(ChannelNumber).BurstGatePolarity
%%
    WaveGen.channels(ChannelNumber).BurstInternalPeriod
%%
    WaveGen.channels(ChannelNumber).BurstMode
%%
    WaveGen.channels(ChannelNumber).BurstPhase
%%
    WaveGen.channels(ChannelNumber).BurstState
%%
    WaveGen.channels(ChannelNumber).Frequency
%%
    WaveGen.channels(ChannelNumber).FrequencyCenter
%%
    WaveGen.channels(ChannelNumber).FrequencyDwellTime
%%
    WaveGen.channels(ChannelNumber).FrequencyMode
%%
    WaveGen.channels(ChannelNumber).FrequencySpan
%%
    WaveGen.channels(ChannelNumber).FrequencyStart
%%
    WaveGen.channels(ChannelNumber).FrequencyCouplingMode
%%
    WaveGen.channels(ChannelNumber).FrequencyCouplingOffset
%%
    WaveGen.channels(ChannelNumber).FrequencyCouplingRatio
%%
    WaveGen.channels(ChannelNumber).FrequencyCouplingState
%%
    WaveGen.channels(ChannelNumber).SweepHoldTime
%%
    WaveGen.channels(ChannelNumber).SweepReturnTime
%%
    WaveGen.channels(ChannelNumber).SweepSpacing
%%
    WaveGen.channels(ChannelNumber).SweepState
%%
    WaveGen.channels(ChannelNumber).SweepTime
%%
    WaveGen.channels(ChannelNumber).OutputLoad
%%
    WaveGen.channels(ChannelNumber).OutputMode
%%
    WaveGen.channels(ChannelNumber).OutputPolarity
%%
    WaveGen.channels(ChannelNumber).OutputState
%%
    WaveGen.channels(ChannelNumber).OutputSync
%%
    WaveGen.channels(ChannelNumber).OutputSyncMode
%%
    WaveGen.channels(ChannelNumber).OutputSyncPolarity
%%
    WaveGen.channels(ChannelNumber).OutputSyncSource
%%
    WaveGen.channels(ChannelNumber).OutputTriggerSlope
%%
    WaveGen.channels(ChannelNumber).OutputTriggerSource
%%
    WaveGen.channels(ChannelNumber).OutputTriggerState
%%
    WaveGen.channels(ChannelNumber).FunctionType
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunction
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionAdvanceMethod
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFrequency
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionNumberOfPoints
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeriod
%%
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate
%%
    WaveGen.channels(ChannelNumber).NoiseFunctionBandwidth
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionBitRate
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionSequenceType
%%
    WaveGen.channels(ChannelNumber).PBRSFunctionTransition
%%
    WaveGen.channels(ChannelNumber).PulseFunctionBothEdges
%%
    WaveGen.channels(ChannelNumber).PulseFunctionDutyCycle
%%
    WaveGen.channels(ChannelNumber).PulseFunctionHoldTime
%%
    WaveGen.channels(ChannelNumber).PulseFunctionLeadingEdge
%%
    WaveGen.channels(ChannelNumber).PulseFunctionPeriod
%%
    WaveGen.channels(ChannelNumber).PulseFunctionTrailingEdge
%%
    WaveGen.channels(ChannelNumber).PulseFunctionWidth
%%
    WaveGen.channels(ChannelNumber).RampFunctionSymmetry
%%
    WaveGen.channels(ChannelNumber).SquareFunctionDutyCycle
%%
    WaveGen.channels(ChannelNumber).DataAverage
%%
    WaveGen.channels(ChannelNumber).DataCrestFactor
%%
    WaveGen.channels(ChannelNumber).DataPeakToPeak
%%
    WaveGen.channels(ChannelNumber).DataPoints    
%%
    WaveGen.channels(ChannelNumber).RateCouplingMode
%%
    WaveGen.channels(ChannelNumber).RateCouplingOffset
%%
    WaveGen.channels(ChannelNumber).RateCouplingRatio
%%
    WaveGen.channels(ChannelNumber).RateCouplingState
%% 
   WaveGen.channels(ChannelNumber).applyDCVoltage;
%%
   WaveGen.channels(ChannelNumber).applyDCVoltage('offset', 1);
%%
   WaveGen.channels(ChannelNumber).applyNoise;
%%
   WaveGen.channels(ChannelNumber).applyPRBS;
%%
   WaveGen.channels(ChannelNumber).applyPulse;
%%
   WaveGen.channels(ChannelNumber).applyPulse('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applyRamp;
%%
   WaveGen.channels(ChannelNumber).applyRamp('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applySineWave;
%%
   WaveGen.channels(ChannelNumber).applySineWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applySquareWave
%%
   WaveGen.channels(ChannelNumber).applySquareWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
%%
   WaveGen.channels(ChannelNumber).applyTriangleWave
%%
   WaveGen.channels(ChannelNumber).applyTriangleWave('frequency', 1+e03,'amplitude', 2, 'offset', 0.5);
    %% - OutputState 
    newVal = 'on'; % 1  | 0 | 'On' | 'Off' 
    WaveGen.channels(ChannelNumber).OutputState = newVal;
    WaveGen.channels(ChannelNumber).OutputState
end

%% - test external trigger
if true
    %% - Waveform example 
    ChannelNumber = 1;
    WaveGen.channels(ChannelNumber).FunctionType = 'SIN';
    WaveGen.channels(ChannelNumber).Frequency = 1.2e+04;
    %WaveGen.channels(ChannelNumber).Amplitude = 5;
    %WaveGen.channels(ChannelNumber).Offset    = 0;
    WaveGen.channels(ChannelNumber).HighLevel = 0;
    WaveGen.channels(ChannelNumber).LowLevel = -4;
    WaveGen.channels(ChannelNumber).BurstPhase = 90;
    %WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
    %WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
    WaveGen.channels(ChannelNumber).OutputLoad = 'INF';
    % - set trigger source
    WaveGen.channels(ChannelNumber).TriggerSource = 'EXT';
    % - set trigger level
    %WaveGen.channels(1).TriggerLevel; Unable to set trig level? Throws
    %error, option not available on device? option could not be accessed it locally
    % - set trigger edge 
    WaveGen.channels(ChannelNumber).TriggerSlope = 'POS';
    % - set trigger delay
    WaveGen.channels(ChannelNumber).TriggerDelay = 10e-06;
    % - set burst mode
    WaveGen.channels(ChannelNumber).BurstMode = 'TRIG';
    % - set number of bursts
    WaveGen.channels(ChannelNumber).BurstCycles = 1;
    % - toggle burst mode
    WaveGen.channels(ChannelNumber).BurstState = 1;
    % - start execution
    WaveGen.channels(ChannelNumber).OutputState = 'ON';
    %%
    ChannelNumber = 2;
    WaveGen.channels(ChannelNumber).FunctionType = 'SIN';
    WaveGen.channels(ChannelNumber).Frequency = 1.2e+04;
    %WaveGen.channels(ChannelNumber).Amplitude = 5;
    %WaveGen.channels(ChannelNumber).Offset    = 5;
    WaveGen.channels(ChannelNumber).HighLevel = 4;
    WaveGen.channels(ChannelNumber).LowLevel = 0;
    WaveGen.channels(ChannelNumber).BurstPhase = 270;
    %WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
    %WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
    WaveGen.channels(ChannelNumber).OutputLoad = 'INF';
    % - set trigger source
    WaveGen.channels(ChannelNumber).TriggerSource = 'EXT';
    % - set trigger level
    %WaveGen.channels(1).TriggerLevel; Unable to set trig level? Throws
    %error, option not available on device? option could not be accessed it locally
    % - set trigger edge 
    WaveGen.channels(ChannelNumber).TriggerSlope = 'POS';
    % - set trigger delay
    WaveGen.channels(ChannelNumber).TriggerDelay = 10e-06;
    % - set burst mode
    WaveGen.channels(ChannelNumber).BurstMode = 'TRIG';
    % - set number of bursts
    WaveGen.channels(ChannelNumber).BurstCycles = 1;
    % - toggle burst mode
    WaveGen.channels(ChannelNumber).BurstState = 1;
    
    % - start execution
    WaveGen.channels(ChannelNumber).OutputState = 'ON';
end


%%  - Examples From Manual
if true
    %% - Arbitrary waveform example 
    ChannelNumber = 1;
    WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
    WaveGen.channels(ChannelNumber).Amplitude = 3;
    WaveGen.channels(ChannelNumber).Offset = 1;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 1e+05;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\BUILTIN\EXP_RISE.ARB';
    WaveGen.channels(ChannelNumber).OutputState = 'ON';
    %% - Sin wave
    WaveGen.send('FUNCtion SIN')
    WaveGen.send('FREQuency +1.0E+03')
    WaveGen.send('VOLTAGE:HIGH +2.0')
    WaveGen.send('VOLTAGE:LOW -2.0')
    WaveGen.send('OUTPut ON')
    %% - Square wave
    WaveGen.send('FUNCtion SQU')
    WaveGen.send('FUNC:SQU:DCYC +20.0')
    WaveGen.send('FREQuency +1.0E+03')
    WaveGen.send('VOLT:HIGH +4.0')
    WaveGen.send('VOLT:LOW +0.0')
    WaveGen.send('OUTP 1')
    %% - turn both channels off
    WaveGen.send('OUTPut OFF')
end

%% - Arbitrary waveform example 
if true
    WaveGen.channels(ChannelNumber).ArbitraryFunctionSamplingRate = 100e+03;
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionFilter = 'OFF';
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunctionPeakToPeak = 10;
    WaveGen.wait;
    % Arb data are fractions of PeakToPeak spaced in time by 1/SamplingRate
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc_ramp, 0.1, 0.1, 0.1, 0.1, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0'); %load an arbitrary waveform in internal memory like this
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc5v, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc2_5v, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).loadArbitraryData('dc0v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0');
    WaveGen.wait;
    %<block_descriptor> is of the format #<n><n digits><sequence name>,<arb name1>,<repeat count1>,<play control1>,<marker mode1>, <marker point1>, <arb name2>,<repeat count2>,<play control2>,<marker mode2>, <marker point2>, and so on
    % In this example, the size of the IEEE Definite Length Arbitrary Block of sequence written as a character string below is 128, which requires 3 digits to represent – hence the #3128 header.
    WaveGen.channels(ChannelNumber).createDataSequence('#3128"seqExample","dc_ramp",0,once,highAtStart,5,"dc5v",2,repeat,maintain,5,"dc2_5v",2,repeat,lowAtStart,5,"dc0v",2,repeat,maintain,5');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc_ramp';
    WaveGen.channels(ChannelNumber).storeData('INT:\dc_ramp.arb'); %Save arbitrary waveform as arb file in internal memory
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc5v'; 
    WaveGen.channels(ChannelNumber).storeData('INT:\dc5v.arb');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc2_5v'; 
    WaveGen.channels(ChannelNumber).storeData('INT:\dc2_5.arb');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'dc0v'; 
    WaveGen.channels(ChannelNumber).storeData('INT:\dc0v.arb');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'seqExample'; 
    WaveGen.channels(ChannelNumber).storeData('INT:\seqExample.seq');
    WaveGen.wait;
    WaveGen.channels(ChannelNumber).clearVolatilememory
    WaveGen.channels(ChannelNumber).loadData('INT:\seqExample.seq');
    WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'INT:\seqExample.seq';
    WaveGen.channels(ChannelNumber).OutputState = 'ON';
end

%% - Arbitrary waveform example 
if true
    ChannelNumber = 1;
    WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\HAVERSINE.arb'); %Load a saved arb file in internal memory
    WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\CARDIAC.arb');
    WaveGen.channels(ChannelNumber).loadData('INT:\BUILTIN\GAUSSIAN.arb');
    WaveGen.channels(ChannelNumber).createDataSequence('#3164"testSeq","INT:\BUILTIN\HAVERSINE.arb",0,repeat,highAtStartGoLow,30,"INT:\BUILTIN\CARDIAC.arb",0,repeat,maintain,10,"INT:\BUILTIN\GAUSSIAN.arb",0,repeat,maintain,10');
    WaveGen.channels(ChannelNumber).ArbitraryFunction = 'testSeq';
    WaveGen.channels(ChannelNumber).FunctionType = 'ARB';
    WaveGen.channels(ChannelNumber).OutputState = 'ON';
end

%%
cos_ramp = @(x,p) p(2)+1/2*(p(1)-p(2))*(1+cos(pi*x));
RampingDurationDown = 10;
LowDuration = 2;
RampingDurationUp = 10;
FinalDuration = 20;
HIGH = 5;
LOW = 0;
maxSamplingPoints   = 1e6;

% The maximum rate of the Keysight 33500B is 30 MHz. The maximum number of samples is chosen 1e6 . 
% Find optimal rate (round up) and determine the number of datapoints
AmplitudeRamp_Ch1 = [cos_ramp(linspace(0,1,(RampingDurationDown)),[HIGH,LOW]) ...
            LOW .* ones(1,LowDuration) ...
            cos_ramp(linspace(0,1,RampingDurationUp),[LOW,HIGH]) ...
            HIGH .* ones(1,FinalDuration)];
numberofsamples = length(AmplitudeRamp_Ch1);  
AmplitudeRampTimeGrid = linspace(0, FinalDuration, numberofsamples);
AmplitudeRamp_Ch1 = interp1(linspace(0,FinalDuration,numberofsamples), AmplitudeRamp_Ch1, AmplitudeRampTimeGrid);
WaveGen.channels(ChannelNumber).preview(AmplitudeRamp_Ch1);
WaveGen.channels(ChannelNumber).upload(AmplitudeRamp_Ch1, 'SamplingRate', min(floor(maxSamplingPoints*1000/FinalDuration)/1000, 30),'Impedance', 'INF', 'BurstCycles', 1);

%% Wigner function reconstruction

% Parity operation ramps

% define Simulation parameter
animate = false;
export = false;
nFrames = 200;
% define initial parameter
maxTrapDepth = 1; ...28; % [uK]
initialFockState = 0; % 0 for the ground state
% Define Durations
deltaTime = 1; % us 
DisplacementDuration = 0; % [us]
RampUpDuration = 10;% 
RampDownDuration = RampUpDuration;
HoldTime = 57.5;
ParityOperationTime = RampUpDuration+HoldTime+RampDownDuration;
PulseTimes = [0,pulseDuration+ParityOperationTime]; % [times to include a gaussian pulse]
% - define Parity-Operation-Parameters:
Imbalance = [1.2,0.9]; % rel. amplitude of Spin (up,minus) during HoldTime
% - define Displacement-Operation-Parameters
SpatialShift   = 0;  % sites
MomentumShift  = 0;  % Useful units to be found
AmplitudesSpinUp = [... % - ramping up
                    SinosoidalRamp(0,RampUpDuration  ,maxTrapDepth,maxTrapDepth*Imbalance(1),deltaTime),... 
                    ... % - waiting
                    ones(1,ceil(HoldTime/deltaTime))*maxTrapDepth*Imbalance(1) ...
                    ... % - ramping down
                    SinosoidalRamp(0,RampDownDuration,maxTrapDepth*Imbalance(1),maxTrapDepth,deltaTime)];
AmplitudesSpinDown = [... % - ramping up
                    SinosoidalRamp(0,RampUpDuration  ,maxTrapDepth,maxTrapDepth*Imbalance(2),deltaTime)... 
                    ... % - waiting
                    ones(1,ceil(HoldTime/deltaTime))*maxTrapDepth*Imbalance(2) ...
                    ... % - ramping down
                    SinosoidalRamp(0,RampDownDuration,maxTrapDepth*Imbalance(2),maxTrapDepth,deltaTime)];

assert(length(AmplitudesSpinDown) == length(AmplitudesSpinUp),'Error: AmplitudeSpinDown must be the same length as Amplitude Spin up')
numberofsamples = length(AmplitudesSpinDown);  
AmplitudeRampTimeGrid = ((1:length(AmplitudesSpinDown))-1)*deltaTime;
AmplitudeRamp_Ch1 = interp1(linspace(0,ParityOperationTime,numberofsamples), AmplitudesSpinUp, AmplitudeRampTimeGrid);
%WaveGen.channels(1).preview(AmplitudeRamp_Ch1);
WaveGen.channels(1).upload(AmplitudeRamp_Ch1, 'SamplingRate', min(floor(maxSamplingPoints*1000/ParityOperationTime)/1000, 30),'Impedance', 'INF', 'BurstCycles', 1, 'BurstPhase', 15);
AmplitudeRamp_Ch2 = interp1(linspace(0,ParityOperationTime,numberofsamples), AmplitudesSpinDown, AmplitudeRampTimeGrid);
%WaveGen.channels(2).preview(AmplitudeRamp_Ch2);
WaveGen.channels(2).upload(AmplitudeRamp_Ch2, 'SamplingRate', min(floor(maxSamplingPoints*1000/ParityOperationTime)/1000, 30),'Impedance', 'INF', 'BurstCycles', 1, 'BurstPhase', 15);

function [vals,times] = SinosoidalRamp(tstart,tend,x0,xEnd,tspacing)
    times =linspace(tstart,tend,(tend-tstart)/tspacing);
    vals = x0 - (xEnd-x0)*0.5*(cos(times*pi/(tend-tstart))-1);
end 