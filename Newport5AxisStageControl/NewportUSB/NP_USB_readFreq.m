function [ PDfreq ] = NP_USB_readFreq( NP_USB, USBADDR )
% NP_USB_READFREQ read photodiode frequency on 1936-R
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector frequency query
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:FREQuency?', querydata);
NP_USB_reperror(qstatus,'PD freq query');
PDfreq = str2double(char(ToString(querydata)));

end

