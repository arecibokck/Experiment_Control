function [ PDpower ] = NP_USB_readPD(NP_USB, USBADDR )
% NP_USB_READPD read photodiode power on 1936-R
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector power query
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:Power?', querydata);
NP_USB_reperror(qstatus,'PD power query');
PDpower = str2double(char(ToString(querydata)));

end

