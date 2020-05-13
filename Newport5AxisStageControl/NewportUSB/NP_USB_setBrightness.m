function NP_USB_setBrightness(brightness, NP_USB, USBADDR )
% NP_USB_SETBRIGHTNESS sets screen brightness on 1936-R
    % Levels from 0 to 7
    %
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 3)
    %assume default USB address
    USBADDR = 1;
end    
    
NP_USB_reperror(NP_USB.Write(USBADDR, ['DISP:BRIGHT ' num2str(brightness)]), ['Brightness level set ' num2str(brightness)]);

end

