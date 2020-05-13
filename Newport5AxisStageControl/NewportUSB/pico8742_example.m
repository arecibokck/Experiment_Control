function [] = pico8742_example()
    %Alex Stange 12/2017
    
    %Thanks to Adriaan Taal for very helpful MATLAB functions:
    %https://www.mathworks.com/matlabcentral/fileexchange/64704-newport-serial-device-communcation
    
    %Most of the following code is from the above link but slightly modified for the New Focus 8742.
    
    USBADDR = 1; %Set in the menu of the device, only relevant if multiple are attached

    NPasm = NET.addAssembly('C:\Program Files\Newport\Newport USB Driver\Bin\UsbDllWrap.dll'); %load UsbDllWrap.dll library
    
    NPASMtype = NPasm.AssemblyHandle.GetType('Newport.USBComm.USB'); %Get a handle on the USB class

    NP_USB = System.Activator.CreateInstance(NPASMtype); %launch the class USB, it constructs and allows to use functions in USB.h
    
    deviceID = 0;
    
    NP_USB.OpenDevices(deviceID);  %Open the USB device
    
    %Initialize Event handling
    NP_USB.EventInit(deviceID);
   
    %The Query method sends the passed in command string to the specified device and reads the response data.
    querydata = System.Text.StringBuilder(64);
    NP_USB.Query(USBADDR, '*IDN?', querydata);
    devInfo = char(ToString(querydata));
    fprintf(['Device attached is ' devInfo '\n']); %display device ID to make sure it's recognized OK
    
    %%
    %now do some controlling with serial commands given in 8742_User_Manual_revB.PDF
    NP_USB.Write(USBADDR,['1PR-100']); %e.g. relative move by -100 steps
    
    %%
    query = '*IDN?';
    querydata = System.Text.StringBuilder(64);
    NP_USB.Query(USBADDR, query, querydata);
    devInfo = char(ToString(querydata));
    disp(devInfo);
    
   
end

