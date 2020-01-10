local setmetatable = setmetatable
local next = next
local wibox = require("wibox")
local awful = require("awful")
local iconhelper = require("awesome-networkmanager-widget.iconhelper")
local devicehelper = require("awesome-networkmanager-widget.devicehelper")

local devicewidget = { mt = {}}

devicewidget.MODE_IP4 = 4
devicewidget.MODE_IP6 = 6

local function visibility_filter(device)
    return device:get_state() == "ACTIVATED"
end

function devicewidget:set_mode(mode)
    self._private.mode = mode
end

function devicewidget:get_device_ips(device)
    if self._private.mode == devicewidget.MODE_IP4 then return devicehelper.get_device_ip4(device)
    elseif self._private.mode == devicewidget.MODE_IP6 then return devicehelper.get_device_ip6(device)
    else return {}
    end
end

function devicewidget:update_widget(device)
    local ips = self:get_device_ips(device)
    local icon = iconhelper.get_device_icon(device)
    local is_visible = visibility_filter(device)    

    local ip_text = ""
    if next(ips) == nil then
        ip_text = string.format("no ip%s address", self._private.mode)
    else
        ip_text = table.concat(ips,", ")
    end

    self.imagebox.image = icon:load_surface()
    self.textbox.text = ip_text
    self:set_visible(is_visible)
end

function devicewidget:update_tooltip(device)
    local name = devicehelper.get_device_name(device)
    local mac = device:get_hw_address()
    local driver = device:get_driver()

    local text = string.format("%s (%s)\n%s", name, driver, mac)
    self.tooltip:set_text(text)
end

function devicewidget:update(device)
    self:update_widget(device)
    self:update_tooltip(device)
end

local function new(args)
    local w = wibox.widget {
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
    w.tooltip = awful.tooltip({ objects = { w },})

    w._private.mode = args and args.mode or devicewidget.MODE_IP4

    setmetatable(w, {__index = devicewidget})

    return w
end

function devicewidget.mt:__call(...)
    return new(...)
end

return setmetatable(devicewidget, devicewidget.mt)