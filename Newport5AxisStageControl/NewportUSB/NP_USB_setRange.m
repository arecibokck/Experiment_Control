function [Ifs, Ires] = NP_USB_setRange(auto, range, NP_USB, USBADDR )
% NP_USB_SETRANGE set range on 1936-R
    % Full-Scale current = 2.5nA * 10^range
    % Resolution = 10fA * 10^range
    %
    % Bandwidth and Frequency measurement range scale according to datasheet
    %
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 4)
    %assume default USB address
    USBADDR = 1;
end    

NP_USB_reperror(NP_USB.Write(USBADDR, ['PM:AUTO ' num2str(auto)]),'PD Auto range set');

%Detector range set
if auto    
    fprintf('Auto range mode selected, read full scale and res from readMinP and readMaxP functions. \n')
    Ires = [];
    Ifs = [];
else
    NP_USB_reperror(NP_USB.Write(USBADDR, ['PM:RANge ' num2str(range)]),'PD Range set');
    %return Full Scale and Resolution
    Ires = 10E-15 * 10^range;
    Ifs = 2.5E-9 * 10^range;
end

end

