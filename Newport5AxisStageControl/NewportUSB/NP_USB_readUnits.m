function [ units ] = NP_USB_readUnits( NP_USB, USBADDR )
% NP_USB_READUNITS read powermeter set units on 1936-R
    % 0     -   Amps
    % 1     -   Volts
    % 2     -   Watts
    % 3     -   Watts/cm2
    % 4     -   Joules
    % 5     -   Joules/cm2
    % 6     -   dBm
    % 11    -   Sun
    
    % Part of the Newport USB device Matlab code
    % Adriaan Taal, Electrical Engineering - Columbia University

if (nargin < 2)
    %assume default USB address
    USBADDR = 1;
end    
    
%Detector power query
querydata = System.Text.StringBuilder(64);
qstatus = NP_USB.Query(USBADDR, 'PM:UNITs?', querydata);
NP_USB_reperror(qstatus,'PD Units');
units = str2double(char(ToString(querydata)));

end

