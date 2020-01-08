local lgi = require 'lgi'
local GLib = lgi.GLib
local NM = lgi.NM
local awful = require("awful")
local wibox = require("wibox")

local network = { mt = {} }
local nm = nil

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

--{{{ Icons
local icon_theme = lgi.Gtk.IconTheme.get_default()
local IconLookupFlags = lgi.Gtk.IconLookupFlags

local function lookup_icon(name)
    return icon_theme:lookup_icon(name, 64, {IconLookupFlags.GENERIC_FALLBACK})
end

local icon = {
    ethernet = lookup_icon("network-wired-symbolic"),
    wifi = lookup_icon("network-wireless-symbolic"),
    offline = lookup_icon("network-offline-symbolic"),
}

local function get_device_icon(device)
    if device:get_device_type() == "ETHERNET" then return icon.ethernet end
    if device:get_device_type() == "WIFI" then return icon.wifi end
end
--{{{

--- {{{ Widget
local function create_device_widget()
    local widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 2,
        {
            id = "imagebox",
            widget = wibox.widget.imagebox,
            resize = true,
        },
        {
            id = "textbox",
            widget = wibox.widget.textbox,
        }        
    }
    widget.tooltip = awful.tooltip({ objects = { widget },})

    return widget
end

local function get_or_create_device_widget(container, device)
    -- cache widget by name
    local device_name = get_device_name(device)
    container._private[device_name] = container._private[device_name] or create_device_widget()

    return container._private[device_name]
end

local function update_device(widget, device)
    local ips4 = get_device_ip4(device)
    local icon = get_device_icon(device)
    
    widget.imagebox.image = icon:load_surface()
    widget.textbox.text = table.concat(ips4,",")
    widget.visible = visibility_filter(device)
end

local function update_tooltip(widget, device)
    local name = get_device_name(device)
    local mac = device:get_hw_address()
    local driver = device:get_driver()

    local text = string.format("%s (%s)\n%s", name, driver, mac)
    widget.tooltip:set_text(text)
end

local function update(container)
    container:reset()
    foreach_device(function(device)
        local device_widget = get_or_create_device_widget(container, device)
        container:add(device_widget)
        update_device(device_widget, device)
        update_tooltip(device_widget, device)
    end)
end

local function init(nm_new_res, container)
    nm = NM.Client.new_finish(nm_new_res)

    function nm:on_active_connection_added(connection) 
        connection.on_state_changed = function() update(container) end
    end
    function nm:on_active_connection_removed(connection) 
        update(container)
    end

    function nm:on_device_added()
        update(container)
    end
    function nm:on_device_removed()
        update(container)
    end
   
    update(container)
end

local function new()
    local container = wibox.layout.fixed.horizontal()
    container.spacing = 2

    NM.Client.new_async(nil, function(src, res) init(res, container) end)    

    return container
end
--}}}

function network.mt:__call(...)
    return new(...)
end

return setmetatable(network, network.mt)