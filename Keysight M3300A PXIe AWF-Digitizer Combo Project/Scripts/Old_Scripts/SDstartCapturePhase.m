function SDstartCapturePhase(sd,nDAQ, thresh,varargin) 
if nargin > 3
    sd.data.points = varargin{1};
end
mod = sd.defmod;
sd.writeport(1,thresh*2^15,3);
sd.(mod).DAQtriggerConfig(nDAQ+6,0,0,bitshift(1,nDAQ));

sd.(mod).DAQconfig(nDAQ+6,sd.data.points,1,0,3);

sd.startDAQ(nDAQ+6);
end
