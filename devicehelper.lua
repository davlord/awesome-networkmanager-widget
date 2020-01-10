local lgi = require 'lgi'
local NM = lgi.NM

local devicehelper = {}

function devicehelper.get_ips(device, ip_type)
    local ip_addresses = {}
    local ip_cfg = devicehelper.get_ip_config(device, ip_type)    
    if (ip_cfg) then        
        for i, ip_address in ipairs(ip_cfg:get_addresses()) do
            ip_addresses[i] = ip_address:get_address()
        end
    end
    return ip_addresses

end

function devicehelper.get_gateway(device, ip_type)
    local ip_config = devicehelper.get_ip_config(device, ip_type)
    return ip_config and ip_config:get_gateway() or nil
end

function devicehelper.get_nameservers(device, ip_type)
    local ip_config = devicehelper.get_ip_config(device, ip_type)
    return ip_config and ip_config:get_nameservers() or {}
end

function devicehelper.get_nameservers(device, ip_type)
    local ip_config = devicehelper.get_ip_config(device, ip_type)
    return ip_config and ip_config:get_nameservers() or {}
end

function devicehelper.get_domains(device, ip_type)
    local ip_config = devicehelper.get_ip_config(device, ip_type)
    return ip_config and ip_config:get_domains() or {}
end

function devicehelper.get_ip_config(device, ip_type)
    return ip_type == 4 and device:get_ip4_config() or device:get_ip6_config()
end

function devicehelper.get_device_name(device)
    return device[NM.DEVICE_INTERFACE]
end

return devicehelper