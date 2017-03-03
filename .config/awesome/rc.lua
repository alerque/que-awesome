-- {{{ Includes

hostname = io.popen("uname -n"):read("l")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

-- Plugins (Arch packages)
local revelation  = require("revelation")

-- Plugins (git submodules))
local vicious     = require("vicious")
local lain        = require("lain")
local cyclefocus  = require('cyclefocus')

local remote      = require('awful.remote')

-- {{{ Theme setup

-- Use pretty Unicode characters to represent special keys in hotkey hinter
hotkeys_popup.default_widget.labels.Mod4 = " ⊞ "
hotkeys_popup.default_widget.labels.Mod1 = " ⎇ "
hotkeys_popup.default_widget.labels.Shift = " ⇧ "
hotkeys_popup.default_widget.labels.Control = " ⎈ "
hotkeys_popup.default_widget.labels.Left = " ◀ "
hotkeys_popup.default_widget.labels.Right = " ▶ "
hotkeys_popup.default_widget.labels.Up = " ▲ "
hotkeys_popup.default_widget.labels.Down = " ▼ "
hotkeys_popup.default_widget.labels.Page_Down = " ↧ "
hotkeys_popup.default_widget.labels.Page_Up = " ↥ "
hotkeys_popup.default_widget.labels.Escape = " ⎋ "
hotkeys_popup.default_widget.labels.Return = " ⏎ "
hotkeys_popup.default_widget.labels.Backspace = " ⌫ "
hotkeys_popup.default_widget.labels.Delete = " ⌦ "
hotkeys_popup.default_widget.labels.Insert = " ⎀ "
hotkeys_popup.default_widget.labels.space = " ⍽ "
hotkeys_popup.default_widget.labels.Tab = " ⇆ "
hotkeys_popup.default_widget.labels['#108'] = " ⌨ "
-- ["#14"] = "#",
-- ["&"] = "＆", -- ampersands break the html formatting in naughty

hotkeys_popup.default_widget.title_font = "Hack Bold 9"
hotkeys_popup.default_widget.description_font = "Hack 8"

-- local theme_name = "pro-dark"
-- beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/" .. theme_name .. "/theme.lua")
local theme_name = "grey-new"
beautiful.init("/usr/share/awesome/themes/" .. theme_name .. "/theme.lua")
local theme = beautiful.get()

if hostname == "emircik" then
    beautiful.wallpaper = "/etc/share/kingfisher.jpg"
end

-- }}}

-- {{{ Misc fixes

-- Lua 5.2 depricated this fuction which many awesome configs use
if not table.foreach then
  table.foreach = function(t, f)
    for k, v in pairs(t) do if f(k, v)~=nil then break end end
  end
end

-- Java GUI's fix:
awful.spawn.with_shell("wmname LG3D")

-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

revelation.init()

-- {{{ Variable definitions

local hidpi = {}
for s = 1, screen.count() do
    local wa = screen[s].workarea
    hidpi[s] = wa.width == 3200
end

theme.font = hidpi[1] and "Hack 16" or "Hack 8"
-- awesome.font = theme.font
theme.emojifont = hidpi[1] and "Emoji One Color 22" or "Emoji One Color 11"
theme.border_width = 0

local home   = os.getenv("HOME")

lastscreen = screen.count()

mykbdcfg = {}
mykbdcfg.widget = wibox.widget.textbox()
-- mykbdcfg.widget = awful.widget.keyboardlayout()
mykbdcfg.widget:set_font(theme.emojifont)

mykbdcfg.options = function ()
  local options = " -option -option nbsp:zwnj2nb3zwj4 -option grp_led:caps -option grp:rshift_toggle"
  if hostname == "emircik" then
    options = options .. " -option compose:rctrl -option lv3:ralt_switch -option caps:ctrl_modifier"
    -- awful.spawn( "setxkbmap -option ctrl:swapcaps" )
    -- awful.spawn( "setxkbmap -option caps:shiftlock" )
  elseif hostname == "jaguar" or hostname == "lemur" then
    options = options .. " -option compose:menu -option lv3:caps_switch"
  else
    options = options .. " -option caps:swapescape"
  end
  return options
end

mykbdcfg.switch_dvp = function ()
  mykbdcfg.widget:set_text("🇺🇸")
  awful.spawn( "setxkbmap dvp" .. mykbdcfg.options() )
end

mykbdcfg.switch_ptf = function ()
  mykbdcfg.widget:set_text("🇹🇷")
  awful.spawn( "setxkbmap ptf" .. mykbdcfg.options() )
end

-- Run or switch to...
local keepass_autotype = function()
  local ismydb = function (c) return awful.rules.match(c, { name = "caleb - KeePassX" }) end
  for c in awful.client.iterate(ismydb) do
    awful.spawn.with_shell("sleep 0.2 && xdotool key ctrl+shift+p")
    return true
  end
  local isrunning = function (c) return awful.rules.match(c, { class = "Keepassx2" }) end
  return awful.client.run_or_raise("keepassx2", isrunning)
end

-- Run or switch to...
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
function set_wallpaper(screen)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(screen)
    end
    gears.wallpaper.maximized(wallpaper, screen, true)
  end
end
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
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

-- {{{ Menu
-- Create a laucher widget and a main menu
systemmenu = {
  { "hibernate", "uyut " .. hostname },
  { "poweroff",  "sudo systemctl poweroff"     },
  { "reboot",    "sudo systemctl reboot"       },
  { "logout", function () awesome.quit() end }
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

-- | Mail | --

--mail_widget = wibox.widget.textbox()
--vicious.register(mail_widget, vicious.widgets.gmail, "${count}", 1200)

widget_mail = wibox.widget.imagebox()
widget_mail:set_image(beautiful.widget_mail)
mailwidget = wibox.widget.background()
--mailwidget:set_widget(mail_widget)
mailwidget:set_bgimage(beautiful.widget_display)

-- | CPU / TMP | --

cpu_widget = lain.widgets.cpu({
  settings = function()
    widget:set_markup(cpu_now.usage .. "%")
  end
})

widget_cpu = wibox.widget.imagebox()
widget_cpu:set_image(beautiful.widget_cpu)
cpuwidget = wibox.widget.background()
cpuwidget:set_widget(cpu_widget)
cpuwidget:set_bgimage(beautiful.widget_display)

-- tmp_widget = wibox.widget.textbox()
-- vicious.register(tmp_widget, vicious.widgets.thermal, "$1°C", 9, "thermal_zone0")

-- widget_tmp = wibox.widget.imagebox()
-- widget_tmp:set_image(beautiful.widget_tmp)
-- tmpwidget = wibox.widget.background()
-- tmpwidget:set_widget(tmp_widget)
-- tmpwidget:set_bgimage(beautiful.widget_display)

-- | MEM | --

mem_widget = lain.widgets.mem({
  settings = function()
    widget:set_markup(
      mem_now.used .. "MB"
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
vicious.register(fs_widget, vicious.widgets.fs, "${/ avail_gb}GB", 2)

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
        widget:set_markup(net_now.sent)
        net_widgetdl:set_markup(net_now.received)
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

mytextclock    = wibox.widget.textclock(markup.font(theme.font, "%H:%M"))
mytextcalendar = awful.widget.textclock(markup.font(theme.font, "%a %d %b"))

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

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
  awful.button(mods.____, 1, function (t) t:view_only() end),
  awful.button(mods.W___, 1, function (t) if client.focus then client.focus:move_to_tag(t) end end),
  awful.button(mods.____, 3, awful.tag.viewtoggle),
  awful.button(mods.W___, 3, awful.client.toggletag),
  awful.button(mods.____, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button(mods.____, 5, function(t) awful.tag.viewprev(t.screen) end)
)
mytasklist = {}
local tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      -- Without this, the following
      -- :isvisible() makes no sense
      c.minimized = false
      if not c:isvisible() and c.first_tag then
        c.first_tag:view_only()
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
        theme = { width = 500 }
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
mywibox = awful.wibox({ position = "left", orientation="north", screen = lastscreen, width = hidpi[lastscreen] and 36 or 18 })

local wa = awful.screen.focused().workarea
mypopup = wibox({
    ontop = true,
    visible = false,
    width = wa.width / 3,
    height = hidpi[awful.screen.focused().index] and 76 or 62
  })
local mypopupcontainer = wibox.container.margin()
mypopupcontainer.margins = 20
mypromptbox = awful.widget.prompt()
mypopupcontainer.widget = mypromptbox
mypopup:set_widget(mypopupcontainer)
local mypopoupprompt = function (args)
  mypopup.screen = awful.screen.focused()
  local wa = awful.screen.focused().workarea
  mypopup:geometry({
      x = wa.x + wa.width / 2 - wa.width / 6,
      y = wa.y + wa.height / 2 - 50
    })
  mypopup.visible = true
  args = args or {}
  args.prompt = args.prompt or "Run: "
  args.done_callback = args.done_callback or function () mypopup.visible = false end
  args.completion_callback = awful.completion.shell
  args.textbox = args.textbox or mypromptbox.widget
  args.exe_callback = args.exe_callback or awful.spawn
  awful.prompt.run(args)
end

-- Widgets that are aligned to the left
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(spr5px)
left_layout:add(mykbdcfg.widget)
left_layout:add(spr5px)

--left_layout:add(spr)

--left_layout:add(spr5px)
--left_layout:add(mylauncher)
--left_layout:add(spr5px)

-- {{{ Tags
-- Define a tag tables which hold each screens tags.
tags = {}
for s = 1, screen.count() do
  tags[s] = awful.tag({ "  ", "  ", "  ", "  ", "  " }, s, layouts[1])
  tags[s][1].selected = true
end
-- }}}

awful.screen.connect_for_each_screen(function (s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "  ", "  ", "  ", "  ", "  " }, s, layouts[1])

    -- Create a promptbox for each screen

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.layoutbox = awful.widget.layoutbox(s)
    s.layoutbox:buttons(awful.util.table.join(
      awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
    ))
    -- Create a taglist widget
    s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget

    left_layout:add(spr)

    left_layout:add(spr5px)
    left_layout:add(s.layoutbox)
    left_layout:add(s.taglist)
    left_layout:add(spr5px)
end)

left_layout:add(spr5px)

-- Widgets that are aligned to the right
local right_layout = wibox.layout.fixed.horizontal()

right_layout:add(spr)

right_layout:add(spr5px)
right_layout:add(wibox.widget.systray())
right_layout:add(spr5px)

right_layout:add(spr)

right_layout:add(widget_clock)
right_layout:add(widget_display_l)
right_layout:add(clockwidget)
right_layout:add(widget_display_r)
right_layout:add(spr5px)

mytasklist = awful.widget.tasklist(lastscreen, awful.widget.tasklist.filter.allscreen, tasklist_buttons)

-- Now bring it all together (with the tasklist in the middle)
local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_middle(mytasklist)
layout:set_right(right_layout)

-- Rotate entire wibox: http://unix.stackexchange.com/a/297984/1925
local rotate = wibox.layout.rotate()
rotate:set_direction("west")
rotate:set_widget(layout)

mywibox:set_bg(beautiful.panel)
mywibox:set_widget(rotate)

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
  awful.key(mods.W___, "e", function () mykbdcfg.switch_dvp() end, { description="Programmers Dvorak", group="Keyboard Layout" }),
  awful.key(mods.W___, "u", function () mykbdcfg.switch_ptf() end, { description="Programmers Turkish F", group="Keyboard Layout" }),
  awful.key(mods.W___, "a", function () mykbdcfg.switch_ptf() end, { description="Programmers Turkish F", group="Keyboard Layout" }),

  awful.key(mods.W___, "Up", awful.tag.viewprev, { description="View previous tag", group="Tag Navigation" }),
  awful.key(mods.W___, "Down", awful.tag.viewnext, { description="View next tag", group="Tag Navigation" }),
  awful.key(mods.W___, "Escape", awful.tag.history.restore, { description="Restore tag history", group="Tag Navigation" }),
  awful.key(mods.W___, "b", awful.tag.viewnone, { description="Hide all", group="Tag Navigation" }),
  awful.key(mods.W___, "v", revelation, { description="Revelation", group="Tag Navigation" }),
  awful.key(mods.W___, "#15", function()
      awful.tag.viewmore(awful.tag.gettags(1),  1)
  end, { description="Show all tags on screen 1", group="Tag Navigation" }),
  awful.key(mods.W___, "#16", function()
      awful.tag.viewmore(awful.tag.gettags(2),  2)
  end, { description="Show all tags on screen 2", group="Tag Navigation" }),

  awful.key(mods.W___, ";", function() awful.menu.clients( { theme = { width = 500 } } ) end, { description="Show list of all windows", group="Window Navigation" }),
  awful.key(mods.W___, "Tab", function ()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, { description="Switch focus", group="Window Navigation" }),
  awful.key(mods.W___, "h",      function() awful.client.focus.global_bydirection("left")  end, { description="Focus window to the left", group="Window Navigation" }),
  awful.key(mods.W___, "l",      function() awful.client.focus.global_bydirection("right") end, { description="Focus window to the right", group="Window Navigation" }),
  awful.key(mods.W___, "j",      function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
  end, { description="Focus previous window", group="Window Navigation" }),
  awful.key(mods.W___, "k",      function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end, { description="Focus next window", group="Window Navigation" }),
  awful.key(mods.W___, "o",      function () awful.screen.focus_relative(-1) end, { description="Focus previous screen", group="Window Navigation" }),
  awful.key(mods.W___, "w",      function () mymainmenu:show() end, { description="Close window", group="Window Navigation" }),

  awful.key(mods.WC__, "j",      function () awful.client.swap.byidx(1) end, { description="Swap window with previous", group="Layout Manipulation" }),
  awful.key(mods.WC__, "k",      function () awful.client.swap.byidx(-1) end, { description="Swap window with next", group="Layout Manipulation" }),
  awful.key(mods.W_S_, "g",      function () awful.tag.incmwfact(0.05) end, { description="Grow master window size", group="Layout Manipulation" }),
  awful.key(mods.W_S_, "s",      function () awful.tag.incmwfact(-0.05) end, { description="Shrink master window size", group="Layout Manipulation" }),
  awful.key(mods.W_S_, "h",      function () awful.tag.incnmaster(1) end, { description="Increase number of master windows", group="Layout Manipulation" }),
  awful.key(mods.WCS_, "s",      function () awful.client.incwfact(-0.05) end, { description="Shrink slave window size", group="Layout Manipulation" }),
  awful.key(mods.WCS_, "g",      function () awful.client.incwfact(0.05) end, { description="Grow slave window size", group="Layout Manipulation" }),
  awful.key(mods.W_S_, "l",      function () awful.tag.incnmaster(-1) end, { description="Decrease number of master windows", group="Layout Manipulation" }),
  awful.key(mods.WC__, "h",      function () awful.tag.incncol( 1) end, { description="Increase sumber of column windows", group="Layout Manipulation" }),
  awful.key(mods.WC__, "l",      function () awful.tag.incncol(-1) end, { description="Decrease sumber of column windows", group="Layout Manipulation" }),

  awful.key(mods.W___, "space",  function () awful.layout.inc(layouts, 1) end, { description="Use next layout", group="Layout Navigation" }),
  awful.key(mods.W_S_, "space",  function () awful.layout.inc(layouts, -1) end, { description="Use previous layout", group="Layout Navigation" }),
  awful.key(mods.W___, "#14",    function() return end, { description="Display just tag #", group="Layout Navigation" }),
  awful.key(mods.WC__, "#14",    function() return end, { description="Add tag # to display", group="Layout Navigation" }),
  awful.key(mods.W_S_, "#14",    function() return end, { description="Move window to tag #", group="Layout Navigation" }),
  awful.key(mods.WCS_, "#14",    function() return end, { description="Add window to tag #", group="Layout Navigation" }),
  awful.key(mods.W___, "z", function()
    if client.focus then
      if client.focus.screen == 2 then i = 5 else i = 1 end
      bgtag = awful.tag.gettags(mouse.screen)[i]
      awful.client.movetotag(bgtag)
    end
  end, { description="Send to background", group="Layout Navigation" }),

  awful.key(mods.____, "Insert", function() quakeconsole["top"][awful.screen.focused().index]:toggle() end, { description="Dropdown terminal", group="Launchers" }),
  awful.key(mods.W___, "Insert", function() quakeconsole["right"][awful.screen.focused().index]:toggle() end, { description="Right sidebar terminal", group="Launchers" }),
  awful.key(mods.WC__, "Insert", function() quakeconsole["bottom"][awful.screen.focused().index]:toggle() end, { description="Pullup terminal", group="Launchers" }),
  awful.key(mods._C__, "Insert", function() quakeconsole["left"][awful.screen.focused().index]:toggle() end, { description="Left sidebar terminal", group="Launchers" }),
  awful.key(mods.W___, "p",      function() menubar.show() end, { description="Applications menubar", group="Launchers" }),
  awful.key(mods.W___, "y",      keepass_autotype, { description="Autotype from keepass", group="Launchers" }),
  awful.key(mods.W___, "Return", function() awful.spawn(terminal_login) end, { description="Terminal + TMUX", group="Launchers" }),
  awful.key(mods.WC__, "Return", function() awful.spawn(terminal_plain) end, { description="Terminal", group="Launchers" }),
  awful.key(mods.W___, "/",      function() runOnce(browser) end, { description="Firefox", group="Launchers" }),
  awful.key(mods.W_S_, "z",      function() awful.spawn(zathura) end, { description="Zathura", group="Launchers" }),
  awful.key(mods.WC__, "/",      function() runOnce(altbrowser) end, { description="Chromium", group="Launchers" }),
  awful.key(mods.W___, "r",      function ()
    mypopoupprompt({
        history_path = awful.util.get_cache_dir() .. "/history_run"
      })
  end, { description="Run prompt", group="Launchers" }),
  awful.key(mods.W___, "s",      function()
    mypopoupprompt({
      prompt = "SSH to host: ",
      exe_callback = function(h) awful.spawn(terminal_plain .. " -e 'mosh " .. h .. "'") end,
      history_callback = function(cmd, cur_pos, ncomp)
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
      history_path = awful.util.get_cache_dir() .. "/history_ssh"
    })
  end, { description="SSH promt", group="Launchers" }),
  awful.key(mods.W___, "x", function ()
    mypopoupprompt({
      prompt = "Run Lua code: ",
      exe_callback = awful.util.eval,
      history_path = awful.util.get_cache_dir() .. "/history_eval"
    })
  end, { description="Lua promt", group="Launchers" }),

  awful.key(mods.WC__, "r", awesome.restart, { description="Restart Awesome", group="Session" }),
  awful.key(mods.W_S_, "q", awesome.quit, { description="Quit Awesome", group="Session" }),
  awful.key(mods.W___, "F1", hotkeys_popup.show_help, { description="Keybinding hinter", group="Session" }),
  awful.key(mods.WC__, "n", awful.client.restore, { description="Restore minimized windows", group="Window Management" })
)

ww = function()
    local wa = awful.screen.focused().workarea
    return wa.width
end
wh = function()
    local wa = awful.screen.focused().workarea
    return wa.height
end
ph = function() -- get panel height for screen
    local s = awful.screen.focused()
    return hidpi[s] and 36 or 22
end

clientkeys = awful.util.table.join(
    awful.key(mods.W___, "Page_Down", function () awful.client.moveresize( 20,  20, -40, -40) end, { description="Scale down", group="Window Management" }),
    awful.key(mods.W___, "Page_Up", function () awful.client.moveresize(-20, -20,  40,  40) end, { description="Scale up", group="Window Management" }),
    awful.key(mods.W___, "Down", function () awful.client.moveresize(  0,  20,   0,   0) end, { description="Move down", group="Window Management" }),
    awful.key(mods.W___, "Up", function () awful.client.moveresize(  0, -20,   0,   0) end, { description="Move up", group="Window Management" }),
    awful.key(mods.W___, "Left", function () awful.client.moveresize(-20,   0,   0,   0) end, { description="Move Left", group="Window Management" }),
    awful.key(mods.W___, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end, { description="Move Right", group="Window Management" }),
    awful.key(mods.WC__, "KP_Left", function (c) c:geometry( { width = ww() / 2, height = wh(), x = 0, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Right", function (c) c:geometry( { width = ww() / 2, height = wh(), x = ww() / 2, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Up", function (c) c:geometry( { width = ww(), height = wh() / 2, x = 0, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Down", function (c) c:geometry( { width = ww(), height = wh() / 2, x = 0, y = wh() / 2 + ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Prior", function (c) c:geometry( { width = ww() / 2, height = wh() / 2, x = ww() / 2, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Next", function (c) c:geometry( { width = ww() / 2, height = wh() / 2, x = ww() / 2, y = wh() / 2 + ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Home", function (c) c:geometry( { width = ww() / 2, height = wh() / 2, x = 0, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_End", function (c) c:geometry( { width = ww() / 2, height = wh() / 2, x = 0, y = wh() / 2 + ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.WC__, "KP_Begin", function (c) c:geometry( { width = ww(), height = wh(), x = 0, y = ph() } ) end, { description="thing", group="Window Management" }),
    awful.key(mods.W___, "f", function (c) c.fullscreen = not c.fullscreen end, { description="Toggle fullscreen", group="Window Management" }),
    awful.key(mods.W___, "q", function (c) c:kill() end, { description="Kill", group="Window Management" }),
    awful.key(mods.W___, "g", awful.client.floating.toggle, { description="Toggle floating", group="Window Management" }),
    awful.key(mods.WC__, "a", function (c) if c.opacity == 1 then c.opacity = 0.6 else c.opacity = 1 end end, { description="Toggle opacity", group="Window Management" }),
    awful.key(mods.W_S_, "Return", function (c) c:swap(awful.client.getmaster()) end, { description="Swap with master", group="Window Management" }),
    awful.key(mods.WC__, "o", function (c) c:move_to_screen() end, { description="Move to other screen", group="Window Management" }),
    awful.key(mods.W___, "t", function (c) c.ontop = not c.ontop end, { description="Toggle on-top", group="Window Management" }),
    awful.key(mods.WC__, "t", function (c) c.sticky = not c.sticky end, { description="Toggle tag sticky", group="Window Management" }),
    awful.key(mods.W___, "n", function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
    end, { description="Minimize", group="Window Management" }),
    awful.key(mods.W___, "m", function (c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
    end, { description="Maximize", group="Window Management" })
)

-- Bind all key numbers to tags.
-- I'm using programmer's dvorak, so the keys to get to these will be:
--     1, 3, 5, 7, and %
-- for left (or single) layouts and:
--     2, 4, 6, 8, and `
-- for right (or second screen) layouts. keys 9 and 0 will map to "all tags"
-- for their respective tags. However these are hard coded to keycodes so they
-- will work in any layout (so PTF won't trp up on the symbal ones)
DVPTagKeys = {}
DVPTagKeys[1] = { "#10", "#11", "#12", "#13", "#14" }
DVPTagKeys[2] = { "#17", "#18", "#19", "#20", "#21" }
for s = 1, screen.count() do
  for i = 1, 5 do
    local key = DVPTagKeys[s][i]
    local tag = awful.tag.gettags(s)[i]
    globalkeys = awful.util.table.join(
      globalkeys,
      awful.key(mods.W___, key, function()
        awful.screen.focus(s)
        awful.tag.viewonly(tag)
      end, { description="Isolate tag " .. i .. " on screen " .. s, group="Workspace" }),
      awful.key(mods.WC__, key, function()
        awful.screen.focus(s)
        awful.tag.viewtoggle(tag)
      end, { description="Toggle visibility tag " .. i .. " on screen " .. s, group="Workspace" }),
      awful.key(mods.W_S_, key, function()
        if client.focus then
          awful.client.movetotag(tag)
        end
      end), -- { description="Move to tag " .. i .. " on screen " .. s, group="Workspace" }),
      awful.key(mods.WCS_, key, function()
        if client.focus then
          awful.client.toggletag(tag)
        end
      end) -- { description="Toggle tagging with tag " .. i .. " on screen " .. s, group="Workspace" })
    )
  end
end

clientbuttons = awful.util.table.join(
    globalButtons,
    awful.button(mods.____, 1, function (c) client.focus = c; c:raise() end),
    awful.button(mods.W___, 1, awful.mouse.client.move),
    awful.button(mods.W___, 3, awful.mouse.client.resize))

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
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     size_hints_honor = false,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "plugin-container",
          "exe"
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "MPlayer",
          "Shutter",
          "SimpleScreenRecorder",
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          "GtkFileChooserDialog"
      },
      type = {
          "dialog"
      }
  }, properties = {
      floating = true,
      size_hints_honor = true,
  }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "dialog" }
      }, properties = { titlebars_enabled = true }
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
            class = { "rdesktop" }
        },
        properties = {
            floating = true,
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
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Unminimize anything we try to activate
client.connect_signal("request::activate", function(c)
    c.minimized = false
end)
-- }}}

mykbdcfg.switch_dvp()

-- vim: ft=lua ts=4 sw=4 expandtab fdm=marker
