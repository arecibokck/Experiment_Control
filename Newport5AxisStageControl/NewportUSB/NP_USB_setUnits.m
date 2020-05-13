function [zeroReading] = NP_USB_setZero(units, NP_USB, USBADDR )
% NP_USB_SETZERO sets zero on 1936-R
    %
    %
    %
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

    
if (nargin < 3)
    %assume default USB address
    USBADDR = 1;
end    
    
NP_USB_reperror(NP_USB.Write(USBADDR, ['PM:UNITs ' num2str(units)]),'PD Units set');

end

