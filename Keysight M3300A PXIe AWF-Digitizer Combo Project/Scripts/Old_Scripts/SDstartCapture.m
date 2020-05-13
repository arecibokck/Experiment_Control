function SDstartCapture(sd,nDAQ, thresh,varargin) 
if nargin > 3
    sd.data.points = varargin{1};
end
mod = sd.selectedModule;
sd.writeport(1,thresh*2^15,3);
sd.modules.(mod).DAQtriggerConfig(nDAQ,0,0,bitshift(1,nDAQ));

sd.modules.(mod).DAQconfig(nDAQ,sd.data.points,1,0,3);

sd.startDAQ(nDAQ);
end
