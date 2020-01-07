# awesome-networkmanager-widget
A network-manager widget for Awesome WM

![awesome-networkmanager-widget screenshot](awesome-networkmanager-widget.png)

## features

* Lightweight (no constant polling but event based updates)
* Support multiple devices
* Additional details on tooltip

## install

1.Clone in your config directory (`~/.config/awesome/`)
```bash
cd ~/.config/awesome/
git clone https://github.com/davlord/awesome-networkmanager-widget.git
```

2.Add to your wibar widgets (`~/.config/awesome/rc.lua`)

```lua
local network_widget = require("awesome-networkmanager-widget")

-- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            network_widget(),
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
```
3. Reload Awesome WM
