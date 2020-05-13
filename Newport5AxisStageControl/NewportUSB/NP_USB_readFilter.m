function [ PMfilter ] = NP_USB_readFilter( NP_USB, USBADDR )
% NP_USB_READFILTER read powermeter Filter mode on 1936-R
    % 0     -   No Filtering
    % 1     -   Analog Filter
    % 2     -   Digital Filter
    % 3     -   Analog and Digital Filter

    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector power query
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:Filter?', querydata);
NP_USB_reperror(qstatus,'PM Filter mode');
PMfilter = str2double(char(ToString(querydata)));

end

