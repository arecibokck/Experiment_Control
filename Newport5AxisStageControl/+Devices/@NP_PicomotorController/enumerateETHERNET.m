function varargout = enumerateETHERNET(~)

    try
        DeviceInfoStruct(1).IPADDR    ='';
        DeviceInfoStruct(1).PADDR     ='';
        DeviceInfoStruct(1).IPMODE    ='';
        [devCount,NetworkDevices] = NetworkDevicesListParser;
        for n = 1:devCount
            DeviceItems = cell2mat(NetworkDevices(n));
            DeviceInfoStruct(n).IPADDR = DeviceItems.IPAddress;
            DeviceInfoStruct(n).PADDR  = DeviceItems.PhysicalAddress;
            DeviceInfoStruct(n).IPMODE = DeviceItems.Type;
        end
        
    catch ME
        rethrow(ME);
    end

    % Handle vararout
    if nargout >= 1
        varargout{1} = NetworkDevices;
    end
    if nargout == 2
        varargout{2} = DeviceInfoStruct;
    end
    if nargout >3
        error('Error: Too many Output Arguments!')
    end

end

function [devCount, NetworkDevices] = NetworkDevicesListParser()

    parsedcommandOutput = struct( 'IPAddress',[], ...
                                  'PhysicalAddress',[], ...
                                  'Type',[]);

    command = 'powershell -command arp -a';
    [~,cmdout] = system(command);

    NetworkDevices = {};
    remain = splitlines(string(cmdout));
    remain(cellfun('isempty',remain)) = [];
    fields = fieldnames(parsedcommandOutput);
    for i = 3:length(remain)
        for j = 1:3
            vals = split(strtrim(remain(i)));
            parsedcommandOutput.(fields{j}) = char(vals(j));
        end
        NetworkDevices{end+1} = parsedcommandOutput;
    end
    clear i j vals

    if ~isempty(NetworkDevices)
        devCount = length(NetworkDevices);
    else
        devCount = 0;
    end
end
