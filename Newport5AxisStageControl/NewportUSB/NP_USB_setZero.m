function [zeroReading] = NP_USB_setZero(NP_USB, USBADDR )
% NP_USB_SETZERO sets zero on 1936-R
    % Stores the zeroing value with the present reading in the Device
    % Substracts the zeroing value
    % Returns the zeroing value to MATLAB
    % 
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

    
if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
NP_USB.Write(USBADDR, 'PM:ZEROSTOre');
NP_USB.Write(USBADDR, 'PM:ZEROVALue');
querydata = System.Text.StringBuilder(64);
NP_USB_reperror(NP_USB.Query(USBADDR, 'PM:ZEROVALue?',querydata),'Query zeroing value ');
zeroReading = str2double(char(ToString(querydata)));

end

