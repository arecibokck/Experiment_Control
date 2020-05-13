val = [];
delays = [];
errs = [];
sd.init;
sd.setChannelFrequency(0,10e6);
sd.setChannelAmplitude(0,1);
sd.enablePLL(0);

for n = 150:151
   
    
    delay = 0+0.1*n;
    rets = zeros(1,10);
    for i = 1:10
        rets(i) = SD_scanDelay(sd,delay);
        pause(2);
    end
    val = [val mean(rets)];
    errs = [errs std(rets)];
    delays = [delays delay];
    
end
 
errorbar(delays,val,errs);