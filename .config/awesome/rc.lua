-- {{{ Includes

-- Standard awesome library
local gears       = require("gears")
local awful       = require("awful")
      awful.rules = require("awful.rules")
                    require("awful.autofocus")

-- Widget and layout library
local wibox       = require("wibox")

-- Theme handling library
local beautiful   = require("beautiful")

-- Notification library
local naughty     = require("naughty")
local menubar     = require("menubar")
--local volume = require("volume")

local eminent     = require("eminent")
local revelation  = require("revelation")

-- External libraries as git submodules
local vicious     = require("vicious")
local lain        = require("lain")
local cyclefocus  = require('cyclefocus')

-- Keybinding docstring hinter
local keydoc      = require('keydoc')
local remote      = require('awful.remote')

-- {{{ Theme setup

local theme = "pro-dark"
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme .. "/theme.lua")

-- Keydoc requires some things not set in my theme
beautiful.fg_widget_value = beautiful.fg_normal
beautiful.fg_widget_clock = beautiful.fg_focus
beautiful.fg_widget_value_important = beautiful.fg_urgent

-- }}}

-- {{{ Misc fixes

-- Lua 5.2 depricated this fuction which many awesome configs use
if not table.foreach then
  table.foreach = function(t, f)
    for k, v in pairs(t) do if f(k, v)~=nil then break end end
  end
end

-- Disable cursor animation:
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
  oldspawn(s, false)
end

-- Java GUI's fix:
awful.util.spawn_with_shell("wmname LG3D")

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors
  })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true
    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = err
    })
    in_error = false
  end)
end
-- }}}

revelation.init()

-- {{{ Variable definitions

local home   = os.getenv("HOME")
local exec   = function (s) oldspawn(s, false) end
local shexec = awful.util.spawn_with_shell

hostname = awful.util.pread("uname -n")

lastscreen = screen.count()

mykbdcfg = {}
mykbdcfg.widget = wibox.widget.textbox()

mykbdcfg.switch_dvp = function ()
  mykbdcfg.widget:set_text("🇺🇸")
  os.execute( "setxkbmap dvp" )
  os.execute( "setxkbmap -option" )
  os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
  os.execute( "setxkbmap -option compose:menu" )
  os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_us = function ()
  mykbdcfg.widget:set_text("us ")
  os.execute( "setxkbmap us" )
  os.execute( "setxkbmap -option" )
  os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
  os.execute( "setxkbmap -option compose:menu" )
  os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_tr = function ()
  mykbdcfg.widget:set_text("tr ")
  os.execute( "setxkbmap tr" )
  os.execute( "setxkbmap -option" )
  os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
  os.execute( "setxkbmap -option compose:menu" )
  os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_trf = function ()
  mykbdcfg.widget:set_text("trf")
  os.execute( "setxkbmap tr f" )
  os.execute( "setxkbmap -option" )
  os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
  os.execute( "setxkbmap -option compose:menu" )
  os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_ptf = function ()
  mykbdcfg.widget:set_text("🇹🇷")
  os.execute( "setxkbmap ptf" )
  os.execute( "setxkbmap -option" )
  os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
  os.execute( "setxkbmap -option compose:menu" )
  os.execute( "setxkbmap -option lv3:caps_switch" )
end

-- Run or switche to...
runOnce = function(n)
  local matcher = function(c)
    return awful.rules.match(c, { class = n[2] })
  end
  return awful.client.run_or_raise(n[1], matcher)
end

-- This is used later as the default terminal and editor to run.
terminal_login = "termite"
terminal_plain = "env TMUX=/dev/null termite"
terminal_fancy = "gnome-terminal"
browser        = { "firefox", "Firefox" }
altbrowser     = { "chromium", "chromium" }
filemanager    = "nautilus"
editor         = "gvim"
zathura        = "zathura"
editor_cmd     = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey  = "Mod4"
shift   = "Shift"
control = "Control"
alt     = "Alt"

-- Shortcut variables for key-bindings
mods = {
  ____ = { },
  W___ = { modkey },
  _C__ = { control },
  __S_ = { shift },
  WC__ = { modkey, control },
  WCS_ = { modkey, control, shift },
  W_S_ = { modkey, shift },
  _CS_ = { control, shift }
}

-- Markup
markup = lain.util.markup
space3 = markup.font("Terminus 3", " ")
space2 = markup.font("Terminus 2", " ")
vspace1 = '<span font="Terminus 3"> </span>'
vspace2 = '<span font="Terminus 3">  </span>'
clockgf = beautiful.clockgf

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
  awful.layout.suit.tile,
  --awful.layout.suit.tile.left,
  --awful.layout.suit.tile.bottom,
  --awful.layout.suit.tile.top
  awful.layout.suit.spiral,
  --awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral.dwindle,
  --awful.layout.suit.max,
  --awful.layout.suit.magnifier,
  awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    --gears.wallpaper.tiled(beautiful.wallpaper, s)
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Dropdown terminal (and other directions)
local quake = require('quake')
quakeconsole = {
  top = {},
  right = {},
  bottom = {},
  left = {}
}
for s = 1, screen.count() do
  quakeconsole["top"][s] = quake({
    terminal = "env tmux_session=quake " .. terminal_login,
    name = "QuakeTop",
    argname = "--name %s",
    width = 0.95,
    height = 0.6,
    horiz = "center",
    vert = "top",
    screen = s
  })
  quakeconsole["right"][s] = quake({
    terminal = "env tmux_session=scratch " .. terminal_login,
    name = "QuakeRight",
    argname = "--name %s",
    height = 0.95,
    width = 0.6,
    horiz = "right",
    vert = "center",
    screen = s
  })
  quakeconsole["bottom"][s] = quake({
    terminal = "env tmux_session=system " .. terminal_login,
    name = "QuakeBottom",
    argname = "--name %s",
    width = 0.95,
    height = 0.6,
    horiz = "center",
    vert = "bottom",
    screen = s
  })
  quakeconsole["left"][s] = quake({
    terminal = "env tmux_session=comms " .. terminal_login,
    name = "QuakeLeft",
    argname = "--name %s",
    height = 0.95,
    width = 0.6,
    horiz = "left",
    vert = "center",
    screen = s
  })
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  --tags[s] = awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", " bg " }, s, awful.layout.suit.tile)
  tags[s] = awful.tag({ "  ", "  ", "  ", "  ", "  " }, s, layouts[1])
  tags[s][1].selected = true
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
systemmenu = {
  { "hibernate", "uyut " .. hostname },
  { "poweroff",  "sudo systemctl poweroff"     },
  { "reboot",    "sudo systemctl reboot"       },
  { "logout",      awesome.quit        }
}
awesomemenu = {
  { "restart",   awesome.restart     },
  { "edit config", editor_cmd .. " " .. awesome.conffile }
}

mymainmenu = awful.menu({ items = {
  { "system",   systemmenu     },
  { "system",   awesomemenu, beautiful.awesome_icon },
  { filemanager, filemanager    },
  { "tmux",     terminal_login },
  { "fancy terminal", terminal_fancy },
  { "plain terminal", terminal_plain }
} })

mylauncher = awful.widget.launcher({
  image = beautiful.awesome_icon,
  menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = terminal_plain .. "-e " -- Set the terminal for applications that require it
-- }}}

-- {{{ Setup utility widgets
spr = wibox.widget.imagebox()
spr:set_image(beautiful.spr)
spr4px = wibox.widget.imagebox()
spr4px:set_image(beautiful.spr4px)
spr5px = wibox.widget.imagebox()
spr5px:set_image(beautiful.spr5px)

widget_display = wibox.widget.imagebox()
widget_display:set_image(beautiful.widget_display)
widget_display_r = wibox.widget.imagebox()
widget_display_r:set_image(beautiful.widget_display_r)
widget_display_l = wibox.widget.imagebox()
widget_display_l:set_image(beautiful.widget_display_l)
widget_display_c = wibox.widget.imagebox()
widget_display_c:set_image(beautiful.widget_display_c)

-- | MPD | --
prev_icon = wibox.widget.imagebox()
prev_icon:set_image(beautiful.mpd_prev)
next_icon = wibox.widget.imagebox()
next_icon:set_image(beautiful.mpd_nex)
stop_icon = wibox.widget.imagebox()
stop_icon:set_image(beautiful.mpd_stop)
pause_icon = wibox.widget.imagebox()
pause_icon:set_image(beautiful.mpd_pause)
play_pause_icon = wibox.widget.imagebox()
play_pause_icon:set_image(beautiful.mpd_play)
mpd_sepl = wibox.widget.imagebox()
mpd_sepl:set_image(beautiful.mpd_sepl)
mpd_sepr = wibox.widget.imagebox()
mpd_sepr:set_image(beautiful.mpd_sepr)

mpdwidget = lain.widgets.mpd({
  settings = function ()
    if mpd_now.state == "play" then
      mpd_now.artist = mpd_now.artist:upper():gsub("&.-;", string.lower)
      mpd_now.title = mpd_now.title:upper():gsub("&.-;", string.lower)
      widget:set_markup(
        markup.font("Tamsyn 3", " ") ..
        markup.font(
          "Tamsyn 7", mpd_now.artist .. " - " ..  mpd_now.title ..
          markup.font("Tamsyn 2", " ")
        )
      )
      play_pause_icon:set_image(beautiful.mpd_pause)
      mpd_sepl:set_image(beautiful.mpd_sepl)
      mpd_sepr:set_image(beautiful.mpd_sepr)
    elseif mpd_now.state == "pause" then
      widget:set_markup(
        markup.font("Tamsyn 4", "") ..
        markup.font("Tamsyn 7", "MPD PAUSED") ..
        markup.font("Tamsyn 10", "")
      )
      play_pause_icon:set_image(beautiful.mpd_play)
      mpd_sepl:set_image(beautiful.mpd_sepl)
      mpd_sepr:set_image(beautiful.mpd_sepr)
    else
      widget:set_markup("")
      play_pause_icon:set_image(beautiful.mpd_play)
      mpd_sepl:set_image(nil)
      mpd_sepr:set_image(nil)
    end
  end
})

musicwidget = wibox.widget.background()
musicwidget:set_widget(mpdwidget)
musicwidget:set_bgimage(beautiful.widget_display)
musicwidget:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    awful.util.spawn_with_shell(ncmpcpp)
  end
)))
prev_icon:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    awful.util.spawn_with_shell("mpc prev || ncmpcpp prev")
    mpdwidget.update()
  end
)))
next_icon:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    awful.util.spawn_with_shell("mpc next || ncmpcpp next")
    mpdwidget.update()
  end
)))
stop_icon:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    play_pause_icon:set_image(beautiful.play)
    awful.util.spawn_with_shell("mpc stop || ncmpcpp stop")
    mpdwidget.update()
  end
)))
play_pause_icon:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    awful.util.spawn_with_shell("mpc toggle || ncmpcpp toggle")
    mpdwidget.update()
  end
)))

-- | Mail | --

--mail_widget = wibox.widget.textbox()
--vicious.register(mail_widget, vicious.widgets.gmail, vspace1 .. "${count}" .. vspace1, 1200)

widget_mail = wibox.widget.imagebox()
widget_mail:set_image(beautiful.widget_mail)
mailwidget = wibox.widget.background()
--mailwidget:set_widget(mail_widget)
mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(space3 .. cpu_now.usage .. "%" .. markup.font("Tamsyn 4", " "))
  end
})

widget_cpu = wibox.widget.imagebox()
widget_cpu:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_display)

-- tmp_widget = wibox.widget.textbox()
-- vicious.register(tmp_widget, vicious.widgets.thermal, vspace1 .. "$1°C" .. vspace1, 9, "thermal_zone0")

-- widget_tmp = wibox.widget.imagebox()
-- widget_tmp:set_image(beautiful.widget_tmp)
-- tmpwidget = wibox.widget.background()
-- tmpwidget:set_widget(tmp_widget)
-- tmpwidget:set_bgimage(beautiful.widget_display)

-- | MEM | --

mem_widget = lain.widgets.mem({
  settings = function()
    widget:set_markup(
      space3 .. mem_now.used .. "MB" .. markup.font("Tamsyn 4", " ")
    )
  end
})

widget_mem = wibox.widget.imagebox()
widget_mem:set_image(beautiful.widget_mem)
memwidget = wibox.widget.background()
memwidget:set_widget(mem_widget)
memwidget:set_bgimage(beautiful.widget_display)

-- | FS | --

fs_widget = wibox.widget.textbox()
vicious.register(fs_widget, vicious.widgets.fs, vspace1 .. "${/ avail_gb}GB" .. vspace1, 2)

widget_fs = wibox.widget.imagebox()
widget_fs:set_image(beautiful.widget_fs)
fswidget = wibox.widget.background()
fswidget:set_widget(fs_widget)
fswidget:set_bgimage(beautiful.widget_display)

-- | NET | --

net_widgetdl = wibox.widget.textbox()
net_widgetul = lain.widgets.net({
    iface = "enp2s0",
    settings = function()
        widget:set_markup(markup.font("Tamsyn 1", "  ") .. net_now.sent)
        net_widgetdl:set_markup(
          markup.font("Tamsyn 1", " ") .. net_now.received ..
          markup.font("Tamsyn 1", " ")
        )
    end
})

widget_netdl = wibox.widget.imagebox()
widget_netdl:set_image(beautiful.widget_netdl)
netwidgetdl = wibox.widget.background()
netwidgetdl:set_widget(net_widgetdl)
netwidgetdl:set_bgimage(beautiful.widget_display)

widget_netul = wibox.widget.imagebox()
widget_netul:set_image(beautiful.widget_netul)
netwidgetul = wibox.widget.background()
netwidgetul:set_widget(net_widgetul)
netwidgetul:set_bgimage(beautiful.widget_display)

-- | Clock / Calendar | --

mytextclock    = awful.widget.textclock(markup(clockgf, space3 .. "%H:%M" .. markup.font("Tamsyn 3", " ")))
mytextcalendar = awful.widget.textclock(markup(clockgf, space3 .. "%a %d %b"))

widget_clock = wibox.widget.imagebox()
widget_clock:set_image(beautiful.widget_clock)

clockwidget = wibox.widget.background()
clockwidget:set_widget(mytextclock)
clockwidget:set_bgimage(beautiful.widget_display)

local index = 1
local loop_widgets = { mytextclock, mytextcalendar }
local loop_widgets_icons = { beautiful.widget_clock, beautiful.widget_cal }

clockwidget:buttons(awful.util.table.join(awful.button(mods.____, 1, function ()
    index = index % #loop_widgets + 1
    clockwidget:set_widget(loop_widgets[index])
    widget_clock:set_image(loop_widgets_icons[index])
  end
)))
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button(mods.____, 1, awful.tag.viewonly),
  awful.button(mods.W___, 1, awful.client.movetotag),
  awful.button(mods.____, 3, awful.tag.viewtoggle),
  awful.button(mods.W___, 3, awful.client.toggletag),
  awful.button(mods.____, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button(mods.____, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
      end
      -- This will also un-minimize
      -- the client, if needed
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, function ()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({
        theme = { width = 250 }
      })
    end
  end),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end)
)

-- Create the wibox
mywibox = awful.wibox({ position = "top", screen = lastscreen, height = "22" })

mypromptbox = awful.widget.prompt()

-- Widgets that are aligned to the left
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(spr5px)
left_layout:add(mykbdcfg.widget)
left_layout:add(spr5px)

--left_layout:add(spr)

--left_layout:add(spr5px)
--left_layout:add(mylauncher)
--left_layout:add(spr5px)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget

    left_layout:add(spr)

    left_layout:add(spr5px)
    left_layout:add(mylayoutbox[s])
    left_layout:add(mytaglist[s])
    left_layout:add(spr5px)
end

left_layout:add(spr5px)
left_layout:add(mypromptbox)
left_layout:add(spr5px)

-- Widgets that are aligned to the right
local right_layout = wibox.layout.fixed.horizontal()

right_layout:add(spr)

right_layout:add(spr5px)
right_layout:add(wibox.widget.systray())
right_layout:add(spr5px)

--right_layout:add(spr)

--right_layout:add(prev_icon)
--right_layout:add(spr)
--right_layout:add(stop_icon)
--right_layout:add(spr)
--right_layout:add(play_pause_icon)
--right_layout:add(spr)
--right_layout:add(next_icon)
--right_layout:add(mpd_sepl)
--right_layout:add(musicwidget)
--right_layout:add(mpd_sepr)

--right_layout:add(spr)

--right_layout:add(widget_mail)
--right_layout:add(widget_display_l)
--right_layout:add(mailwidget)
--right_layout:add(widget_display_r)
--right_layout:add(spr5px)

--right_layout:add(spr)

--right_layout:add(spr5px)
--right_layout:add(mytextclock)

--right_layout:add(spr)

--right_layout:add(widget_cpu)
--right_layout:add(widget_display_l)
--right_layout:add(cpuwidget)
--right_layout:add(widget_display_r)
-- right_layout:add(widget_display_c)
-- right_layout:add(tmpwidget)
-- right_layout:add(widget_tmp)
-- right_layout:add(widget_display_r)
--right_layout:add(spr5px)

--right_layout:add(spr)

--right_layout:add(widget_mem)
--right_layout:add(widget_display_l)
--right_layout:add(memwidget)
--right_layout:add(widget_display_r)
--right_layout:add(spr5px)

--right_layout:add(spr)

--right_layout:add(widget_fs)
--right_layout:add(widget_display_l)
--right_layout:add(fswidget)
--right_layout:add(widget_display_r)
--right_layout:add(spr5px)

--right_layout:add(spr)

--right_layout:add(widget_netdl)
--right_layout:add(widget_display_l)
--right_layout:add(netwidgetdl)
--right_layout:add(widget_display_c)
--right_layout:add(netwidgetul)
--right_layout:add(widget_display_r)
--right_layout:add(widget_netul)

right_layout:add(spr)

right_layout:add(widget_clock)
right_layout:add(widget_display_l)
right_layout:add(clockwidget)
right_layout:add(widget_display_r)
right_layout:add(spr5px)

mytasklist = awful.widget.tasklist(lastscreen, awful.widget.tasklist.filter.allscreen, mytasklist.buttons)

-- Now bring it all together (with the tasklist in the middle)
local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_middle(mytasklist)
layout:set_right(right_layout)

mywibox:set_bg(beautiful.panel)
mywibox:set_widget(layout)
-- }}}

-- {{{ Mouse bindings
globalButtons = awful.util.table.join(
  awful.button(mods.W___,  8, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button(mods.W___,  9, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
  awful.button(mods.____, 13, revelation)
)

root.buttons(awful.util.table.join(globalButtons,
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  keydoc.group("Keyboard Layout"),
  awful.key(mods.W___, "e", function () mykbdcfg.switch_dvp() end, "Programmers Dvorak"),
  awful.key(mods.W___, "u", function () mykbdcfg.switch_ptf() end, "Programmers Turkish F"),
  awful.key(mods.W___, "a", function () mykbdcfg.switch_ptf() end, "Programmers Turkish F"),

  keydoc.group("Tag Navigation"),
  awful.key(mods.W___, "Up", awful.tag.viewprev, "View previous tag"),
  awful.key(mods.W___, "Down", awful.tag.viewnext, "View next tag"),
  awful.key(mods.W___, "Escape", awful.tag.history.restore, "Restore tag history"),
  awful.key(mods.W___, "b", awful.tag.viewnone, "Hide all"),
  awful.key(mods.W___, "v", revelation, "Revelation"),

  keydoc.group("Window Navigation"),
  awful.key(mods.W___, ";", function() awful.menu.clients( { width = 250 }, { keygrabber = true } ) end, "Show list of all windows"),
  awful.key(mods.W___, "Tab", function ()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, "Switch focus"),
  awful.key(mods.W___, "h",      function() awful.client.focus.global_bydirection("left")  end, "Focus window to the left"),
  awful.key(mods.W___, "l",      function() awful.client.focus.global_bydirection("right") end, "Focus window to the right"),
  awful.key(mods.W___, "j",      function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end, "Focus previous window"),
  awful.key(mods.W___, "k",      function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end, "Focus next window"),
  awful.key(mods.W___, "o",      function () awful.screen.focus_relative(-1) end, "Focus previous screen"),
  awful.key(mods.W___, "w",      function () mymainmenu:show() end, "Close window"),

  keydoc.group("Layout Manipulation"),
  awful.key(mods.WC__, "j",      function () awful.client.swap.byidx(1) end, "Swap window with previous"),
  awful.key(mods.WC__, "k",      function () awful.client.swap.byidx(-1) end, "Swap window with next"),
  awful.key(mods.W_S_, "g",      function () awful.tag.incmwfact(0.05) end, "Grow master window size"),
  awful.key(mods.W_S_, "s",      function () awful.tag.incmwfact(-0.05) end, "Shrink master window size"),
  awful.key(mods.W_S_, "h",      function () awful.tag.incnmaster(1) end, "Increase number of master windows"),
  awful.key(mods.WCS_, "s",      function () awful.client.incwfact(-0.05) end, "Shrink slave window size"),
  awful.key(mods.WCS_, "g",      function () awful.client.incwfact(0.05) end, "Grow slave window size"),
  awful.key(mods.W_S_, "l",      function () awful.tag.incnmaster(-1) end, "Decrease number of master windows"),
  awful.key(mods.WC__, "h",      function () awful.tag.incncol( 1) end, "Increase sumber of column windows"),
  awful.key(mods.WC__, "l",      function () awful.tag.incncol(-1) end, "Decrease sumber of column windows"),

  keydoc.group("Layout Navigation"),
  awful.key(mods.W___, "space",  function () awful.layout.inc(layouts, 1) end, "Use next layout"),
  awful.key(mods.W_S_, "space",  function () awful.layout.inc(layouts, -1) end, "Use previous layout"),
  awful.key(mods.W___, "#14",    function() return end, "Display just tag #"),
  awful.key(mods.WC__, "#14",    function() return end, "Add tag # to display"),
  awful.key(mods.W_S_, "#14",    function() return end, "Move window to tag #"),
  awful.key(mods.WCS_, "#14",    function() return end, "Add window to tag #"),
  awful.key(mods.W___, "z",      function() return end, "Send window to background tag"),

  keydoc.group("Launchers"),
  awful.key(mods.____, "Insert", function() quakeconsole["top"][mouse.screen]:toggle() end, "Dropdown terminal"),
  awful.key(mods.W___, "Insert", function() quakeconsole["right"][mouse.screen]:toggle() end, "Right sidebar terminal"),
  awful.key(mods.WC__, "Insert", function() quakeconsole["bottom"][mouse.screen]:toggle() end, "Pullup terminal"),
  awful.key(mods._C__, "Insert", function() quakeconsole["left"][mouse.screen]:toggle() end, "Left sidebar terminal"),
  awful.key(mods.W___, "p",      function() menubar.show() end, "Applications menubar"),
  awful.key(mods.W___, "Return", function() awful.util.spawn(terminal_login) end, "Terminal + TMUX"),
  awful.key(mods.WC__, "Return", function() awful.util.spawn(terminal_plain) end, "Terminal"),
  awful.key(mods.W___, "/",      function() runOnce(browser) end, "Firefox"),
  awful.key(mods.W_S_, "z",      function() awful.util.spawn(zathura) end, "Zathura"),
  awful.key(mods.WC__, "/",      function() runOnce(altbrowser) end, "Chromium"),
  awful.key(mods.W___, "r",      function() mypromptbox:run() end, "Run prompt"),
  awful.key(mods.W___, "s",      function()
    awful.prompt.run(
      { prompt = "ssh: " },
      mypromptbox.widget,
      function(h) awful.util.spawn(terminal_plain .. " -e 'mosh " .. h .. "'") end,
      function(cmd, cur_pos, ncomp)
        -- get hosts and hostnames
        local hosts = {}
        --f = io.popen("eval echo $(sed 's/#.*//;/[ \\t]*Host\\(Name\\)\\?[ \\t]\\+/!d;s///;/[*?]/d' " .. os.getenv("HOME") .. "/.ssh/config) | sort")
        f = io.popen("sed 's/#.*//;/[ \\t]*Host\\(Name\\)\\?[ \\t]\\+/!d;s///;/[*?]/d' " .. os.getenv("HOME") .. "/.ssh/config | sort")
        for host in f:lines() do
          table.insert(hosts, host)
        end
        f:close()
        -- abort completion under certain circumstances
        if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
          return cmd, cur_pos
        end
        -- match
        local matches = {}
        for _, host in pairs(hosts) do
          if hosts[host]:find("^" .. cmd:sub(1, cur_pos):gsub('[-]', '[-]')) then
            table.insert(matches, hosts[host])
          end
        end
        -- if there are no matches
        if #matches == 0 then
          return cmd, cur_pos
        end
        -- cycle
        while ncomp > #matches do
          ncomp = ncomp - #matches
        end
        -- return match and position
        --return matches[ncomp], #matches[ncomp] + 1
        return cmd, cur_pos
      end,
      awful.util.getdir("cache") .. "/ssh_history"
    )
  end, "SSH promt"),
  awful.key(mods.W___, "x", function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox.widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
  end, "Lua promt"),

  keydoc.group("Session"),
  awful.key(mods.WC__, "r", awesome.restart, "Restart Awesome"),
  awful.key(mods.W_S_, "q", awesome.quit, "Quit Awesome"),
  awful.key(mods.W___, "F1", keydoc.display, "Keybinding hinter"),

  keydoc.group("Window Management"),
  awful.key(mods.WC__, "n", awful.client.restore, "Restore minimized windows")
)

local wa = screen[mouse.screen].workarea
ww = wa.width
wh = wa.height
ph = 22 -- (panel height)

clientkeys = awful.util.table.join(
    keydoc.group("Window Management"),
    awful.key(mods.W___, "Next", function () awful.client.moveresize( 20,  20, -40, -40) end, "Scale down"),
    awful.key(mods.W___, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end, "Scale up"),
    awful.key(mods.W___, "Down", function () awful.client.moveresize(  0,  20,   0,   0) end, "Move down"),
    awful.key(mods.W___, "Up", function () awful.client.moveresize(  0, -20,   0,   0) end, "Move up"),
    awful.key(mods.W___, "Left", function () awful.client.moveresize(-20,   0,   0,   0) end, "Move Left"),
    awful.key(mods.W___, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end, "Move Right"),
    awful.key(mods.WC__, "KP_Left", function (c) c:geometry( { width = ww / 2, height = wh, x = 0, y = ph } ) end),
    awful.key(mods.WC__, "KP_Right", function (c) c:geometry( { width = ww / 2, height = wh, x = ww / 2, y = ph } ) end),
    awful.key(mods.WC__, "KP_Up", function (c) c:geometry( { width = ww, height = wh / 2, x = 0, y = ph } ) end),
    awful.key(mods.WC__, "KP_Down", function (c) c:geometry( { width = ww, height = wh / 2, x = 0, y = wh / 2 + ph } ) end),
    awful.key(mods.WC__, "kp_prior", function (c) c:geometry( { width = ww / 2, height = wh / 2, x = ww / 2, y = ph } ) end),
    awful.key(mods.WC__, "KP_Next", function (c) c:geometry( { width = ww / 2, height = wh / 2, x = ww / 2, y = wh / 2 + ph } ) end),
    awful.key(mods.WC__, "KP_Home", function (c) c:geometry( { width = ww / 2, height = wh / 2, x = 0, y = ph } ) end),
    awful.key(mods.WC__, "KP_End", function (c) c:geometry( { width = ww / 2, height = wh / 2, x = 0, y = wh / 2 + ph } ) end),
    awful.key(mods.WC__, "KP_Begin", function (c) c:geometry( { width = ww, height = wh, x = 0, y = ph } ) end),
    awful.key(mods.W___, "f", function (c) c.fullscreen = not c.fullscreen end, "Toggle fullscreen"),
    awful.key(mods.W___, "q", function (c) c:kill() end, "Kill"),
    awful.key(mods.W___, "g", awful.client.floating.toggle, "Toggle floating"),
    awful.key(mods.W_S_, "Return", function (c) c:swap(awful.client.getmaster()) end, "Swap with master"),
    awful.key(mods.WC__, "o", awful.client.movetoscreen, "Move to other screen"),
    awful.key(mods.W___, "t", function (c) c.ontop = not c.ontop end, "Toggle on-top"),
    awful.key(mods.WC__, "t", function (c) c.sticky = not c.sticky end, "Toggle tag sticky"),
    awful.key(mods.W___, "n", function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
    end, "Minimize"),
    awful.key(mods.W___, "m", function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end, "Maximize")
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys = awful.util.table.join(
    globalkeys,
    awful.key(mods.W___, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewonly(tag)
      end
    end),
    awful.key(mods.WC__, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end),
    awful.key(mods.W_S_, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.movetotag(tag)
        end
      end
    end),
    awful.key(mods.WCS_, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then
          awful.client.toggletag(tag)
        end
      end
    end)),
    awful.key(mods.W___, "z", function ()
      if client.focus and tags[client.focus.screen][i] then
        awful.client.movetotag(tags[client.focus.screen][10])
      end
    end)
end

clientbuttons = awful.util.table.join(
  globalButtons,
  awful.button({         }, 1, function (c) client.focus = c; c:raise() end),
  awful.button(mods.W___, 1, awful.mouse.client.move),
  awful.button(mods.W___, 3, awful.mouse.client.resize)
)

awful.menu.menu_keys = {
  up    = { "k", "Up" },
  down  = { "j", "Down" },
  exec  = { "r", "Return", "Space" },
  enter = { "l", "Right", "+" },
  back  = { "h", "Left", "-" },
  close = { "q", "Escape", "Backspace" }
}

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  { rule = {
    },
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = clientkeys,
      size_hints_honor = false,
      buttons = clientbuttons
    }
  },
  { rule_any = {
      class = { "MPlayer", "Shutter", "SimpleScreenRecorder" },
      instance = { "plugin-container", "exe" },
      role = { "GtkFileChooserDialog" }
    },
    properties = {
      floating = true,
      size_hints_honor = true
    },
    callback = function(c)
      awful.placement.centered(c,nil)
    end
  },
  { rule_any = {
      name = { "^Google Play Music$" }
    },
    --callback = function(c)
      --awful.client.moveresize(3595, 945, 250, 140, c)
    --end,
    properties = {
      focusable = false,
      floating = true,
      sticky = true,
      ontop = true,
      opacity = 0.5,
      width = 250,
      height = 140,
      x = 3595,
      y = 945,
      size_hints_honor = false
    }
  },
  { rule_any = {
      instance = { "QuakeTop", "QuakeRight", "QuakeBottom", "QuakeLeft" }
    },
    properties = {
      opacity = 0.85
    }
  },
  { rule_any = {
      class = { "Gvim" }
    },
    callback = function(c)
      awful.client.setslave(c)
      awful.tag.setmwfact(0.666)
    end
  },
  { rule_any = {
      class = { "rdesktop" }
    },
    properties = {
      focus = false,
      focusable = false,
      floating = true,
      sticky = true,
      ontop = true,
      opacity = 0.5
    }
  },
  { rule_any = {
      name = { "Auto-Type - KeePassX" }
    },
    properties = {
      size_hints_honor = false,
      floating = true,
      ontop = true,
      opacity = 0.80
    },
    callback = function(c)
      awful.placement.centered(c,nil)
    end
  }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = false
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
      awful.button(mods.____, 1, function()
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)
      end),
      awful.button(mods.____, 3, function()
        client.focus = c
        c:raise()
        awful.mouse.client.resize(c)
      end)
    )

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(awful.titlebar.widget.iconwidget(c))
    left_layout:buttons(buttons)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(awful.titlebar.widget.stickybutton(c))
    right_layout:add(awful.titlebar.widget.ontopbutton(c))
    right_layout:add(awful.titlebar.widget.closebutton(c))

    -- The title goes in the middle
    local middle_layout = wibox.layout.flex.horizontal()
    local title = awful.titlebar.widget.titlewidget(c)
    title:set_align("center")
    middle_layout:add(title)
    middle_layout:buttons(buttons)

    -- Now bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    layout:set_middle(middle_layout)

    awful.titlebar(c):set_widget(layout)
  end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

mykbdcfg.switch_dvp()

-- vim: ft=lua ts=4 sw=4 expandtab fdm=marker
