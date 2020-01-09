local lgi = require 'lgi'
local NM = lgi.NM

local devicehelper = {}

local function get_device_ip(device, ip_type)
    local ip_addresses = {}
    local ip_cfg = ip_type == 4 and device:get_ip4_config() or device:get_ip6_config()    
    if (ip_cfg) then        
        for i, ip_address in ipairs(ip_cfg:get_addresses()) do
            ip_addresses[i] = ip_address:get_address()
        end
    end
    return ip_addresses

end

function devicehelper.get_device_ip4(device)
    return get_device_ip(device, 4)
end

function devicehelper.get_device_ip6(device)
    return get_device_ip(device, 6)
end

function devicehelper.get_device_name(device)
    return device[NM.DEVICE_INTERFACE]
end

return devicehelper