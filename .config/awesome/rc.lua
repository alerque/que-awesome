-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
--local volume = require("volume")
local eminent = require("eminent")
local revelation =  require("revelation")

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
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
theme_path = ".config/awesome/theme.lua"

beautiful.init(theme_path)
revelation.init()

hostname = awful.util.pread("uname -n")

lastscreen = screen.count()

mykbdcfg = {}
mykbdcfg.widget = wibox.widget.textbox()

mykbdcfg.switch_dvp = function ()
	mykbdcfg.widget:set_text(" dvp ")
	os.execute( "setxkbmap dvp" )
	os.execute( "setxkbmap -option" )
	os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
	os.execute( "setxkbmap -option compose:menu" )
	os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_us = function ()
	mykbdcfg.widget:set_text(" us ")
	os.execute( "setxkbmap us" )
	os.execute( "setxkbmap -option" )
	os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
	os.execute( "setxkbmap -option compose:menu" )
	os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_tr = function ()
	mykbdcfg.widget:set_text(" tr ")
	os.execute( "setxkbmap tr" )
	os.execute( "setxkbmap -option" )
	os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
	os.execute( "setxkbmap -option compose:menu" )
	os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_trf = function ()
	mykbdcfg.widget:set_text(" tr-f ")
	os.execute( "setxkbmap tr f" )
	os.execute( "setxkbmap -option" )
	os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
	os.execute( "setxkbmap -option compose:menu" )
	os.execute( "setxkbmap -option lv3:caps_switch" )
end

mykbdcfg.switch_ptf = function ()
	mykbdcfg.widget:set_text(" ptf ")
	os.execute( "setxkbmap ptf" )
	os.execute( "setxkbmap -option" )
	os.execute( "setxkbmap -option nbsp:zwnj2nb3nnb4" )
	os.execute( "setxkbmap -option compose:menu" )
	os.execute( "setxkbmap -option lv3:caps_switch" )
end

-- This is used later as the default terminal and editor to run.
terminal_login = "urxvt"
terminal_plain = "env TMUX=/dev/null urxvt"
firefox = "firefox"
chrome = "chromium"
editor = "gvim"
editor_cmd = editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.spiral,
    awful.layout.suit.tile,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
	tags[s] = awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", " bg " }, s, awful.layout.suit.tile)
	tags[s][1].selected = true
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal_plain .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal_plain }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal_plain .. "-e " -- Set the terminal for applications that require it
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
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
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
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

-- Create the wibox
mywibox = awful.wibox({ position = "top", screen = lastscreen })

mypromptbox = awful.widget.prompt()

-- Widgets that are aligned to the left
local left_layout = wibox.layout.fixed.horizontal()
left_layout:add(mylauncher)

-- Widgets that are aligned to the right
local right_layout = wibox.layout.fixed.horizontal()
right_layout:add(wibox.widget.systray())
right_layout:add(mykbdcfg.widget)
right_layout:add(mytextclock)

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget

    left_layout:add(mylayoutbox[s])
    left_layout:add(mytaglist[s])
end

left_layout:add(mypromptbox)
mytasklist = awful.widget.tasklist(lastscreen, awful.widget.tasklist.filter.allscreen, mytasklist.buttons)

-- Now bring it all together (with the tasklist in the middle)
local layout = wibox.layout.align.horizontal()
layout:set_left(left_layout)
layout:set_middle(mytasklist)
layout:set_right(right_layout)

mywibox:set_widget(layout)
-- }}}

-- {{{ Mouse bindings
globalButtons = awful.util.table.join(
    awful.button({ modkey,           }, 8, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
    awful.button({ modkey,           }, 9, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end),
	awful.button({                   }, 13, revelation)
)

root.buttons(awful.util.table.join(globalButtons,
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,           }, "e", function () mykbdcfg.switch_dvp() end), -- to EN (same on dvp/ptf)
	awful.key({ modkey,           }, "u", function () mykbdcfg.switch_ptf() end), -- to TR (dvp)
	awful.key({ modkey,           }, "a", function () mykbdcfg.switch_ptf() end), -- to TR (ptf)
	--awful.key({ modkey,           }, "e", function () mykbdcfg.switch_us() end),
    --awful.key({ modkey, "Shift"   }, "f", function () mykbdcfg.switch_trf() end),
	--awful.key({ modkey, "Shift"   }, "t", function () mykbdcfg.switch_tr() end),

    awful.key({ modkey,           }, "Up",     awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Down",   awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

	awful.key({ modkey,           }, "b", awful.tag.viewnone),
	awful.key({ modkey,           }, "a", revelation),

    awful.key({ modkey,           }, "h", function() awful.client.focus.global_bydirection("left")  end),
    awful.key({ modkey,           }, "l", function() awful.client.focus.global_bydirection("right") end),
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "o", function () awful.screen.focus_relative(-1) end),
    --awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal_login) end),
    awful.key({ modkey, "Control" }, "Return", function () awful.util.spawn(terminal_plain) end),
    awful.key({ modkey,           }, "/", function () awful.util.spawn(firefox) end),
    awful.key({ modkey, "Control" }, "/", function () awful.util.spawn(chrome) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompts
    awful.key({ modkey },            "r", function () mypromptbox:run() end),
    awful.key({ modkey },            "s", function ()
                awful.prompt.run({ prompt = "ssh: " },
                mypromptbox.widget,
                function(h) awful.util.spawn(terminal_plain .. " -e ssh " .. h) end)
               --[[ function(cmd, cur_pos, ncomp)]]
                    ---- get hosts and hostnames
                    --local hosts = {}
                    --f = io.popen("sed 's/#.*//;/[ \\t]*Host\\(Name\\)\\?[ \\t]\\+/!d;s///;/[*?]/d' " .. os.getenv("HOME") .. "/.ssh/config | sort")
                    --for host in f:lines() do
                        --table.insert(hosts, host)
                    --end
                    --f:close()
                    ---- abort completion under certain circumstances
                    --if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then
                        --return cmd, cur_pos
                    --end
                    ---- match
                    --local matches = {}
                    --table.foreach(hosts, function(x)
                        --if hosts[x]:find("^" .. cmd:sub(1, cur_pos):gsub('[-]', '[-]')) then
                            --table.insert(matches, hosts[x])
                        --end
                    --end)
                    ---- if there are no matches
                    --if #matches == 0 then
                        --return cmd, cur_pos
                    --end
                    ---- cycle
                    --while ncomp > #matches do
                        --ncomp = ncomp - #matches
                    --end
                    ---- return match and position
                    --return matches[ncomp], #matches[ncomp] + 1
                --end,
                --[[awful.util.getdir("cache") .. "/ssh_history")]]
            end),

    awful.key({ modkey },            "x", function ()
                awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox.widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
            end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "g",      awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey, "Control" }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end)),
        awful.key({ modkey,           }, "z",
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][10])
                      end
                  end)
end

clientbuttons = awful.util.table.join(globalButtons,
    awful.button({                   }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey,           }, 1, awful.mouse.client.move),
    awful.button({ modkey,           }, 3, awful.mouse.client.resize)
)


-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = {
        },
        properties = { border_width = beautiful.border_width,
                        border_color = beautiful.border_normal,
                        focus = awful.client.focus.filter,
                        keys = clientkeys,
                        size_hints_honor = false,
                        buttons = clientbuttons }
    },
    { rule_any = {
            class = { "Keepassx", "MPlayer", "Shutter" },
            instance = { "plugin-container", "exe" },
            role = { "GtkFileChooserDialog" }
        },
        properties = { floating = true },
        callback = function(c)
                awful.placement.centered(c,nil)
            end
    },
    { rule_any = {
            class = { "Keepassx" }
        },
        properties = { ontop = true }
    }
    --{ rule = { class = "Lyricue_display" },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
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
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
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
