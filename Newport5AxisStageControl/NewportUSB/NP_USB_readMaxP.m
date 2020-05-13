function [ maxP ] = NP_USB_readMaxP( NP_USB, USBADDR )
% NP_USB_READMAXP read maximum readable power in present range
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:MAX:Power?', querydata);
NP_USB_reperror(qstatus,'Maximum power query');
maxP = str2double(char(ToString(querydata)));

end

