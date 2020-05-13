function NP_USB_setCorr(value1, value2, value3, NP_USB, USBADDR )
% NP_USB_SETCORR set units on 1936-R
    % ((Actual Measurement * value1) + value2) * value3
    %
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

    
if (nargin < 5)
    %assume default USB address
    USBADDR = 1;
end    
    
wrstatus = NP_USB.Write(USBADDR, ['PM:CORR ' num2str(value1) num2str(value2) num2str(value3) ]);
NP_USB_reperror(wrstatus,'PM Correction set');

end

