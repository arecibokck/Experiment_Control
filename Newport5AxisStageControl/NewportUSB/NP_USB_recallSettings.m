function NP_USB_recallSettings(bin, NP_USB, USBADDR )
% NP_USB_SETLAMBDA set wavelength on 1936-R
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 3)
    %assume default USB address
    USBADDR = 1;
end    
    
NP_USB_reperror(NP_USB.Write(USBADDR, ['*RCL ' num2str(bin)]), ['Settings recall from state' num2str(bin)]);

end
