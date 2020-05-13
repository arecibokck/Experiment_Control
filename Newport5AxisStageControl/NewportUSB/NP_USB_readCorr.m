function [ Corr ] = NP_USB_readCorr(NP_USB, USBADDR )
% NP_USB_READCORR read powermeter correction settings 1936-R
    % Corrected measurement = ((Actual Measurement * value1) + value2) * value3
    %
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
querydata = System.Text.StringBuilder(64);
NP_USB_reperror(NP_USB.Query(USBADDR, 'PM:CORR?', querydata),'Powermeter correction query');
Corr = str2num(char(ToString(querydata)));

end

