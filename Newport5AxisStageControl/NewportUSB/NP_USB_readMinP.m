function [ minP ] = NP_USB_readMinP( NP_USB, USBADDR )
% NP_USB_READMIMP read minimum readable power in present range
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end


querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:MIN:Power?', querydata);
NP_USB_reperror(qstatus,'Minimum power query');
minP = str2double(char(ToString(querydata)));

end

