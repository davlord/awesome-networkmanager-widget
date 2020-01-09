local lgi = require 'lgi'
local GLib = lgi.GLib
local NM = lgi.NM
local awful = require("awful")
local wibox = require("wibox")
local devicewidget = require("awesome-networkmanager-widget.devicewidget")
local devicehelper = require("awesome-networkmanager-widget.devicehelper")

local network = { mt = {} }
local nm = nil

local function device_filter(device)
    return device:get_device_type() == "WIFI" or device:get_device_type() == "ETHERNET"
end

local function foreach_device(fn)
    local devices = nm:get_devices()
    for _, d in ipairs(devices) do
        if device_filter(d) then
            fn(d)
        end
	end
end

function network:get_or_create_device_widget(device)
    -- cache widget by name
    local device_name = devicehelper.get_device_name(device)
    self._private[device_name] = self._private[device_name] or devicewidget()

    return self._private[device_name]
end

function network:update()   
    self:reset()
    foreach_device(function(device)
        local device_widget = self:get_or_create_device_widget(device)
        self:add(device_widget)
        device_widget:update(device)
    end)
end

function network:init(nm_new_res)
    -- finalize network-manager connexion
    nm = NM.Client.new_finish(nm_new_res)

    -- add listeners
    local update = function() self:update() end
    function nm:on_active_connection_added(connection) 
        connection.on_state_changed = update
    end
    nm.on_active_connection_removed = update
    nm.on_device_added = update
    nm.on_device_removed = update
   
    -- update widget now
    self:update()
end

local function new()
    local container = wibox.layout.fixed.horizontal()
    container.spacing = 2

    setmetatable(container, {__index = network})

    NM.Client.new_async(nil, function(src, res) container:init(res) end)    

    return container
end

function network.mt:__call(...)
    return new(...)
end

return setmetatable(network, network.mt)