function [NP_USB, devInfo] = NP_USB_connect(dll_path,deviceID,USBADDR)
% NP_USB_CONNECT establish connection with Newport USB device
    % Loads the Newport USB Driver .NET Wrapper
    % Established and verifies connection
    % Reports device self-identification
    % 
    % Requires a reboot of the Newport Device to ensure correct connectivity!
    %
    % Inputs:
    % dll_path     -    String path to UsbDllWrap.dll
    % deviceID     -    Hex string Device ID (look up in datasheet or on device manager)
    % USBADDR	   -    Set in the menu of the device, only relevant if multiple are attached
	%
    % Outputs:
    % NP_USB       -    .NET Class of USB 
    % devInfo      -    Device self-identification
    %                       [Newport Name Firmware Date SN]
    % 
    % Created on:
        % .NET 4.7, Windows 10, Newport Driver 4.2.2, Matlab 2017A 64-bit
    % Tested device:
        % 1936-R Power meter
    % 
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 3)
    %assume default USB address
    USBADDR = 1;
end    
    
if (nargin < 2)
	%assume 1936-R Powermeter
    deviceID = hex2dec('CEC7');
end
    
NPasm = NET.addAssembly([dll_path '\UsbDllWrap.dll']);

%Get a handle on the USB class
NPASMtype = NPasm.AssemblyHandle.GetType('Newport.USBComm.USB');
%launch the class USB, it constructs and allows to use functions in USB.h
NP_USB = System.Activator.CreateInstance(NPASMtype); 

%Open the USB device
NP_USB_reperror(NP_USB.OpenDevices(deviceID),'DeviceOpen');

%Initialize Event handling
NP_USB_reperror(NP_USB.EventInit(deviceID),'EventInit');

%The Query method sends the passed in command string to the specified device and reads the response data.
querydata = System.Text.StringBuilder(64);
NP_USB_reperror(NP_USB.Query(USBADDR, '*IDN?', querydata),'Query');
devInfo = char(ToString(querydata));
fprintf(['Device attached is ' devInfo '\n']);

end

