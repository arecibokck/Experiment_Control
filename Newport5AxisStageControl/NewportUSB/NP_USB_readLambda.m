function [ Lambda ] = NP_USB_readLambda(NP_USB, USBADDR )
% NP_USB_READLAMBDA read set wavelength on 1936-R
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector frequency query
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:Lambda?', querydata);
NP_USB_reperror(qstatus,'Detector lambda query');
Lambda = str2double(char(ToString(querydata)));

end

