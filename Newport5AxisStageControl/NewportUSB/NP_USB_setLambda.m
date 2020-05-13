function NP_USB_setLambda(lambdaset, NP_USB, USBADDR )
% NP_USB_SETLAMBDA set wavelength on 1936-R
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 3)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector wavelength set
NP_USB_reperror(NP_USB.Write(USBADDR, ['PM:Lambda ' num2str(lambdaset)]), ['PD lambda set ' num2str(lambdaset) ' nm']);

end

