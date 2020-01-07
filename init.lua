local lgi = require 'lgi'
local GLib = lgi.GLib
local NM = lgi.NM
local wibox = require("wibox")

local network = { mt = {} }

local nm = NM.Client.new()

---{{{ Device helper
local function get_device_name(device)
    return device[NM.DEVICE_INTERFACE]
end

local function get_device_ip(device, ip_type)
    local ip_addresses = {}
    local ip_cfg = ip_type == 4 and device:get_ip4_config() or device:get_ip4_config()    
    if (ip_cfg) then        
        for i, ip_address in ipairs(ip_cfg:get_addresses()) do
            ip_addresses[i] = ip_address:get_address()
        end
    end
    return ip_addresses

end

local function get_device_ip4(device)
    return get_device_ip(device, 4)
end

local function get_device_ip6(device)
    return get_device_ip(device, 6)
end

local function device_filter(device)
    return device:get_device_type() == "WIFI" or device:get_device_type() == "ETHERNET"
end

local function visibility_filter(device)
    return device:get_state() == "ACTIVATED"
end

local function foreach_device(fn)
    local devices = nm:get_devices()
    for _, d in ipairs(devices) do
        if device_filter(d) then
            fn(d)
        end
	end
end
---}}}

--- {{{ Widget
local function get_or_create_device_widget(container, device)
    -- cache widget by name
    local device_name = get_device_name(device)
    container._private[device_name] = container._private[device_name] or wibox.widget {
        widget = wibox.widget.textbox
    }

    return container._private[device_name]
end

local function update_device(widget, device)
    local ips4 = get_device_ip4(device)
    
    widget.text = string.format("%s (%s)", get_device_name(device),  table.concat(ips4,","))
    widget.visible = visibility_filter(device)
end

local function update(container)
    container:reset()
    foreach_device(function(device)
        local device_widget = get_or_create_device_widget(container, device)
        container:add(device_widget)
        update_device(device_widget, device)
    end)
end

local function new()

    local container = wibox.layout.fixed.horizontal()
    container.spacing = 2

    function nm:on_active_connection_added(connection) 
        connection.on_state_changed = function() update(container) end
    end
    function nm:on_active_connection_removed(connection) 
        update(container)
    end
   
    update(container)

    return container
end
--}}}

function network.mt:__call(...)
    return new(...)
end

return setmetatable(network, network.mt)