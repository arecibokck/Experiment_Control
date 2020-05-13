function aomCalib(sd,chan)
mod = sd.selectedModule;
sd.init
sd.selectModule(mod);
maxOut = 1.1;
sd.setChannelFrequency(chan,80e6)
sd.modules.(sd.selectedModule).channelInputConfig(chan,10,0,0);

sampling = 2^10;
volt = maxOut*[0:1:sampling-1]/sampling;
P = zeros(1,sampling);
for i = 1:sampling
    sd.setChannelAmplitude(chan,maxOut*i/sampling);
    pause(1e-3);
    sd.DAQread(chan,'p');
    P(i) = mean(sd.data.read_data{chan+1});
%     if any(P(i)<=P) 
%         P = [P(1:i-1),max(P)+1,P(i+1:end)];
%         
%     end
    
    if P(i) >= 2^15-1 
        disp(['aborting:1 V reached at ' num2str(i/sampling) ' Volts output!']);
        P=P(1:i);
        volt=volt(1:i);
        break
    end 
    
    clc
    disp(i*100/sampling);
    
end
% sd.setChannelAmplitude(chan,0);
figure(3)
P=P/(2^15)*sd.modules.(sd.selectedModule).channelFullScale(chan);
% round(P);
% volt2=interp1(P,volt,0:1:2^10-1,'linear');
plot(volt,P);
xlabel 'output voltage'
ylabel 'input voltage'
% title
P=P/max(P);
% sd.init();
% plot(volt,P);
% axis([0,1,-2^10,2^10]);
% figure(4)
% plot(volt2)

% for i = 1:1024
%     sd.setAmplitude(chan,volt2(i));
%     pause(1e-3);
%     sd.DAQread(input);
%     P(i) = sum(sd.data.read_data{input+1})/sd.data.points;
% 
%   
%     
%     clc
%     disp(i*100/sampling);
%     
% end
% P=P/2^15;
% plot(P)
%   
% curves = [curves; P];
end
