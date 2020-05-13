function ret = SD_scanDelay_optic(sd, delay)%% delay in µs
%this is a script to test a phase locked cable connection
%to run setFreq, SetAmp and enable the PLL
% sd.init();

% if delay<1
%     delay = 1e-3;
%     warning('too short delay');
% end
% if delay>2000
%     delay = 2e2;
%     warning('too long delay');
% end
nCH = 1;
P = 40000;
I = 10000;
D =  0;
p = @(t) [t-t+0.5;phaseFunctionHandle(t)/(pi)];
% sd.init;
% sd.setChannelFrequency(nCH,10e6);
% sd.setChannelAmplitude(nCH,1);
% sd.enablePLL(nCH);
mod = 'module2';
sd.selectModule(mod);
sd.data.points = 40000;
sd.setRegisterEntry(7,1)
sd.setRegisterEntry(11,1)
sd.setRegisterEntry(1,.45*2^15)



%% configure the DAQs: phase error of Channel 1 is on DAQ 7; Ch 4,5 are monitoring the phase ramp/compensation ramp
trig = 2;
for nDAQ = [nCH+6, 4,5]
    sd.modules.(mod).DAQtriggerConfig(nDAQ,0,0,bitshift(1,trig));

    sd.modules.(mod).DAQconfig(nDAQ,sd.data.points,1,0,3)

    sd.startDAQ(nDAQ);
end

%% step sequence
s = Sequence;
s.addPin(sd.getTriggerPin());
s.addPin(DigitalOut('mutex'));

%% initialize Vector pin names
pin = {'one','two','three','four'};
for chan = 0:3
    pin{chan+1} = sd.getVectorPinName(mod,chan);
    s.addPin(sd.getVectorPin(pin{chan+1})); 
end
s.(pin{3}).addPartnerPin(s.(pin{1}));   %assign compensation pin according to FPGA firmware
s.(pin{1}).setCompensationParameters([delay,30])
s.(pin{1}).setPhaseScale(1);          %direct modulation needs to be 
                                        %scaled according to the dp AOM-
                                        %set to 1 when teting
                                        %electronically

%% sequence programming
s.(pin{1}).state([0.2;0]);
s.(pin{2}).state([0.2;0]);

s.(pin{3}).state([0;0]);
s.(pin{3}).state([0.5;0],0.01);          % trigger event

s.sync()
% s.(pin{3}).wait(10e-6);                  %time offset for plotting
s.wait(20e-6)

% s.(pin{3}).state([.5;0.4])             %chose ramp to test

% s.(pin{3}).arbitraryRamp(p,6e-6)
% s.(pin{1}).state([0.2;0.2],0.001);

s.(pin{1}).sinusoidalRamp([.2;4],30e-6);
% % s.(pin{3}).state([0;0.46],0.001);
s.wait(0.01);                           %resolve all started waveforms



% s.(pin{3}).setAmplitudeModulation('DC');
sd.settings.triggerMode='AUTOTRIG';

%% start sequence
sd.settings.debug = 1 ;
sd.loadSequence(s);

sd.startExecution();
sd.setPLLconfig(nCH,P,I,D);
% sd.modules.(mod).AWGstartMultiple(255);           %use this if testing
                                                    % without AOMs

%% plot response
channels = [ 5,4,nCH+6];
titles = {'direct phase ramp' 'compensation phase ramp' 'resulting error signal'};
figure(20)
% hold on
for i = 1:length(channels)
    subplot(length(channels),1,i)
%     hold on
    n = channels(i);
    sd.readDAQ(n);
    plot(double(sd.data.read_data{n+1}),'-');
    title((titles{i}));
    if any(i == [1,2])
        ylim([-2^15,2^15]);
        
%         xlim([1000;1100])
    else
        ylim([-2^15,2^15])
        xlim([0,200])
    end

end
ret = max(abs(double(sd.data.read_data{nCH+7})))*180/2^15;
drawnow
pause(1);

%% start execution
end




