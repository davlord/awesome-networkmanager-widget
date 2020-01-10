local setmetatable = setmetatable
local lgi = require 'lgi'
local GLib = lgi.GLib
local NM = lgi.NM
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
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

function network:toggle_mode()
    if self._private.mode == devicewidget.MODE_IP4 then self._private.mode = devicewidget.MODE_IP6
    elseif self._private.mode == devicewidget.MODE_IP6 then self._private.mode = devicewidget.MODE_IP4
    end
    foreach_device(function(device)
        local device_widget = self:get_or_create_device_widget(device)
        device_widget:set_mode(self._private.mode)
        device_widget:update(device)
    end)
end

function network:get_or_create_device_widget(device)
    -- cache widget by name
    local device_name = devicehelper.get_device_name(device)
    self._private[device_name] = self._private[device_name] or devicewidget({ mode = self._private.mode})

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

    -- add listeners on network manager events
    local update = function() self:update() end

    for _, connection in ipairs(nm:get_active_connections()) do
        connection.on_state_changed = update
    end
    nm.on_active_connection_added = function(_, connection)
        connection.on_state_changed = update
    end
    nm.on_active_connection_removed = update
    nm.on_device_added = update
    nm.on_device_removed = update

    -- add listeners on widget events
    self:buttons(gears.table.join(
        awful.button({ }, 1, function() self:toggle_mode() end)
    ))

    -- update widget now
    self:update()
end

local function new(args)
    local container = wibox.layout.fixed.horizontal()
    container.spacing = 2
    container._private.mode = args and args.mode or devicewidget.MODE_IP4

    setmetatable(container, {__index = network})

    NM.Client.new_async(nil, function(src, res) container:init(res) end)    
    
    return container
end

function network.mt:__call(...)
    return new(...)
end

return setmetatable(network, network.mt)