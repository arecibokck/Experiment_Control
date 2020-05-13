function varargout = enumerateUSB(~, szFilter)
%
% Lists the identification strings of all controllers available via USB 
% interfaces
%
%Arguments:     szFilter    only controllers whose descriptions match 
%                           the filter are returned in the buffer. 
%                           
%Returns:       >= 0:       the number of controllers in the list
%               
% 
    try
        DeviceInfoStruct(1).ControllerName='';
        DeviceInfoStruct(1).deviceID='';
        DeviceInfoStruct(1).Vendor='';
        
        [bRet,szDevices] = PnPEntitiesListParser(szFilter);
        assert(bRet~=0, ['No ' szFilter ' found!']);
        
        for n = 1:bRet
            DeviceItems = cell2mat(szDevices(n));
            DeviceInfoStruct(n).ControllerName=DeviceItems.Description;
            DeviceInfoStruct(n).deviceID=DeviceItems.DeviceID;
            DeviceInfoStruct(n).Vendor=DeviceItems.Manufacturer;
        end
        
    catch ME
        rethrow(ME);
    end

    % Handle vararout
    if nargout >= 1
        varargout{1} = szDevices;
    end
    if nargout == 2
        varargout{2} = DeviceInfoStruct;
    end
    if nargout >3
        error('Error: Too many Output Arguments!')
    end

end

function [bRet, szDevices] = PnPEntitiesListParser(szFilter)

    parsedcommandOutput = struct( 'GENUS',[], ...
                            'CLASS',[], ...
                            'SUPERCLASS',[], ...
                            'DYNASTY',[], ...
                            'RELPATH',[], ...
                            'PROPERTY_COUNT',[],... 
                            'DERIVATION',[], ...
                            'SERVER',[], ...
                            'NAMESPACE',[], ... 
                            'PATH',[], ... 
                            'Availability',[], ...
                            'Caption',[], ... 
                            'ClassGuid',[], ... 
                            'CompatibleID',[], ... 
                            'ConfigManagerErrorCode',[], ... 
                            'ConfigManagerUserConfig',[], ... 
                            'CreationClassName',[], ...
                            'Description',[], ... 
                            'DeviceID',[], ...
                            'ErrorCleared',[], ... 
                            'ErrorDescription',[], ... 
                            'HardwareID',[], ... 
                            'InstallDate',[], ... 
                            'LastErrorCode',[], ...
                            'Manufacturer',[], ... 
                            'Name',[], ... 
                            'PNPClass',[], ... 
                            'PNPDeviceID',[], ... 
                            'PowerManagementCapabilities',[], ... 
                            'PowerManagementSupported',[], ... 
                            'Present',[], ... 
                            'Service',[], ... 
                            'Status',[], ... 
                            'StatusInfo',[], ... 
                            'SystemCreationClassName',[], ... 
                            'SystemName',[], ... 
                            'PSComputerName',[]);

    command = 'powershell -command "gwmi Win32_USBControllerDevice |%{[wmi]($_.Dependent)} | Sort Manufacturer,Description,DeviceID"';
    [~,cmdout] = system(command);
    
    PnPList = {};
    remain = splitlines(string(cmdout));
    remain(cellfun('isempty',remain)) = [];
    fields = fieldnames(parsedcommandOutput);
    j = 1;
    for i = 1:length(remain)
        if (j <= numel(fieldnames(parsedcommandOutput)))
            if (contains(remain(i), ": "))
                temp = extractAfter(remain(i), ": ");
                if(startsWith(temp, "("))
                    parsedcommandOutput.(fields{j}) = strip(strip(temp, "("), ")");
                else
                    parsedcommandOutput.(fields{j}) = temp;
                end
                j = j + 1;
            end
        end
        if j > numel(fieldnames(parsedcommandOutput))
            PnPList{end+1} = parsedcommandOutput;
            j = 1;
        end
    end    
    clear i j temp
    
    szDevices = {};
    for i=1:length(PnPList)
        temp = cell2mat(PnPList(i));
        if (strcmp(temp.PNPClass,string(szFilter)))
            szDevices{end+1} = temp;
        end
    end
    clear i temp
    
    if ~isempty(szDevices)
        bRet = length(szDevices);
    else
        bRet = 0;
    end
end
