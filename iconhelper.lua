local lgi = require 'lgi'

local icon_theme = lgi.Gtk.IconTheme.get_default()
local IconLookupFlags = lgi.Gtk.IconLookupFlags

local iconhelper = {}

local function lookup_icon(name)
    return icon_theme:lookup_icon(name, 64, {IconLookupFlags.GENERIC_FALLBACK})
end

local icon = {
    ethernet = lookup_icon("network-wired-symbolic"),
    wifi = lookup_icon("network-wireless-connected-symbolic"),
    offline = lookup_icon("network-offline-symbolic"),
}

function iconhelper.get_device_icon(device)
    if device:get_device_type() == "ETHERNET" then return icon.ethernet end
    if device:get_device_type() == "WIFI" then return icon.wifi end
end

return iconhelper