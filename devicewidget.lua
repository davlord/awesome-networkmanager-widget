local setmetatable = setmetatable
local wibox = require("wibox")
local awful = require("awful")
local iconhelper = require("awesome-networkmanager-widget.iconhelper")
local devicehelper = require("awesome-networkmanager-widget.devicehelper")

local devicewidget = { mt = {}}

local function visibility_filter(device)
    return device:get_state() == "ACTIVATED"
end

function devicewidget:update_widget(device)
    local ips4 = devicehelper.get_device_ip4(device)
    local icon = iconhelper.get_device_icon(device)
    local is_visible = visibility_filter(device)    

    self.imagebox.image = icon:load_surface()
    self.textbox.text = table.concat(ips4,",")
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

local function new()
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

    setmetatable(w, {__index = devicewidget})

    return w
end

function devicewidget.mt:__call(...)
    return new(...)
end

return setmetatable(devicewidget, devicewidget.mt)