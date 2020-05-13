%% hello 
%this is a script to test a phase locked cable connection
lockfreq=10e6;
% sd.init();

mod = 'module2';
sd.selectmodule(mod);

%% Configure the trigger lines



%% step sequence
s = Sequence;
s.addPin(sd.getTriggerPin());
s.addPin(DigitalOut('mutex'));


s.addPin(sd.getVectorPin('HDT1L'));
s.addPin(sd.getVectorPin('HDT1R'));


% s.HDT2.linearRamp([0;.9],2e-8,2e-9);

s.HDT1L.state([0.2;0],4);

s.HDT1L.state([0.2;.2],1);



sd.settings.triggerMode='AUTO';
% sd.settings.debug = 1 ;

%% start sequence
sd.loadSequence(s);

sd.(mod).AWGstartMultiple(255);
