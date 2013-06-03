require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.widget.graph")
require("beautiful")
require("naughty")
--require("bashets")
--require("obvious")
--require("obvious.keymap_switch")
--require("shifty")

--bashets.set_script_path("/home/users/caleb/.config/awesome/")
--bashets.set_temporary_path("/dev/shm");

theme_path = ".config/awesome/theme.lua"
--theme_path = "/usr/share/awesome/themes/default/theme.lua"

beautiful.init(theme_path)

theme.border_width = "0"
--theme.wallpaper_cmd = "feh --bg-fill greece_flower_bg.jpg"

--terminal = "urxvt"
terminal = "gnome-terminal"
browser = "chrome"
editor = os.getenv("EDITOR") or "gvim.gnome"
editor_cmd = editor

modkey = "Mod4"

naughty.config.default_preset.position = "bottom_right"

kbdcfg = {}
kbdcfg.widget = widget({ type = "textbox", align = "right" })

kbdcfg.switch_en = function ()
	kbdcfg.widget.text = " en "
	os.execute( "setxkbmap us" )
	--os.execute( "setxkbmap -option 'lv3:caps_switch'" )
	os.execute( "setxkbmap -option 'nbsp:zwnj2nb3nnb4'" )
	os.execute( "xmodmap ~/.xmodmaprc" )
	os.execute( "xmodmap -e 'keycode 66 = Mode_switch'" )
end

kbdcfg.switch_tr = function ()
	kbdcfg.widget.text = " tr "
	os.execute( "setxkbmap tr" )
	--os.execute( "setxkbmap -option 'lv3:caps_switch'" )
	os.execute( "setxkbmap -option 'nbsp:zwnj2nb3nnb4'" )
	os.execute( "xmodmap ~/.xmodmaprc" )
	os.execute( "xmodmap -e 'keycode 66 = ISO_Level3_Shift'" )
end

kbdcfg.switch_en()

layouts =
{
    awful.layout.suit.spiral,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}

tags = {}
mylayoutbox = {}

mytextclock = awful.widget.textclock({ align = "right" })
mysystray = widget({ type = "systray" })

mystats = awful.widget.graph({})
mystats:set_width(10)
--bashets.register("load.sh")
--bashets.register("awesome_load.zsh", {widget = mystats})
--bashets.start()

globalbuttons = awful.util.table.join(
    awful.button({ }, 6, awful.tag.viewprev),
    awful.button({ }, 7, awful.tag.viewnext)
)

globalkeys = awful.util.table.join(
	awful.key({ modkey }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ modkey }, "\\", function () awful.util.spawn(browser) end),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    awful.key({ modkey }, "h", awful.tag.viewprev ),
    awful.key({ modkey }, "l", awful.tag.viewnext ),
    awful.key({ modkey }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey }, "u", function () awful.screen.focus(1) end),
    awful.key({ modkey }, "i", function () awful.screen.focus(2) end),

    awful.key({ modkey }, ";", awful.client.urgent.jumpto),
	awful.key({ modkey }, "e", function () kbdcfg.switch_en() end),
	awful.key({ modkey }, "t", function () kbdcfg.switch_tr() end),
    awful.key({ modkey }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    awful.key({ modkey, "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift" }, "q", awesome.quit),

    awful.key({ modkey }, "Right", function () awful.tag.incmwfact( 0.1) end),
    awful.key({ modkey }, "Left", function () awful.tag.incmwfact(-0.1) end),
    --awful.key({ modkey, "Shift" }, "Right", function () awful.tag.incnmaster( 1) end),
    --awful.key({ modkey, "Shift" }, "Left", function () awful.tag.incnmaster(-1) end),
    --awful.key({ modkey, "Control" }, "Up", function () awful.tag.incncol( 1) end),
    --awful.key({ modkey, "Control" }, "Down", function () awful.tag.incncol(-1) end),
    awful.key({ modkey }, "space", function () awful.layout.inc(layouts, 1) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey }, "r", function () mypromptbox:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox.widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)


mytaglist = {}
mytaglist.buttons = awful.util.table.join(
		globalbuttons,
		awful.button({ }, 1, awful.tag.viewonly),
		awful.button({ }, 3, awful.tag.viewtoggle),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
	)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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

lastscreen = screen.count()

tagswidget = {}
mypromptbox = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright})
--mykeylayout = obvious.keymap_switch({ "us", "tr" })

for s = 1, screen.count() do
	tags[s] = awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", " bg " }, s, awful.layout.suit.spiral)
	tags[s][1].selected = true

	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
			awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
		))
	tagswidget[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

	mytasklist[s] = awful.widget.tasklist(function(c)
		return awful.widget.tasklist.label.currenttags(c, s)
		end, mytasklist.buttons
	)
end

--require("fraxbat");
require("gigamo");

if screen.count() > 1 then
	wibox = awful.wibox({ position = "top", screen = 2})
	wibox.widgets = {
		mytextclock,
		mysystray,
		kbdcfg.widget,
		mybattery,
		--mykeylayout,
		{
			tagswidget[2],
			tagswidget[1],
			mystats,
			mypromptbox,
			mylayoutbox[2],
			mytasklist[2],
			mylayoutbox[1],
			mytasklist[1],
			layout = awful.widget.layout.horizontal.leftright
		},
		layout = awful.widget.layout.horizontal.rightleft
	}
else
	wibox = awful.wibox({ position = "top", screen = 1})
	wibox.widgets = {
		mytextclock,
		mysystray,
		kbdcfg.widget,
		mybattery,
		--mykeylayout,
		{
			tagswidget[1],
			mystats,
			mylayoutbox[1],
			mypromptbox,
			mytasklist[1],
			layout = awful.widget.layout.horizontal.leftright
		},
		layout = awful.widget.layout.horizontal.rightleft
	}
end

--bashets.start()

clientkeys = awful.util.table.join(
    awful.key({ modkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ modkey }, "q", function (c) c:kill() end),
    awful.key({ modkey }, "g", function (c) c.floating = not c.floating end),
	awful.key({ modkey }, "t", function (c) c.ontop = not c.ontop end),
    --awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey }, "o", awful.client.movetoscreen ),
    awful.key({ modkey, "Shift" }, "r", function (c) c:redraw() end),
    awful.key({ modkey, "Control" }, "m", function (c) c.minimized = not c.minimized end),
    awful.key({ modkey }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end)
)

for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey }, "z",
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][10])
                      end
                  end)
	)
end

clientbuttons = awful.util.table.join(
	globalbuttons,
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey, "Control" }, 1, awful.mouse.client.resize)
)

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true, tag = tags[1][2] } },
    { rule = { class = "iceweasel" },
      properties = { tag = tags[1][1] } },
    { rule = { class = "pidgin" },
      properties = { tag = tags[lastscreen][1] } },
    { rule = { class = "skype" },
      properties = { tag = tags[lastscreen][1] } },
    { rule = { class = "rhythmbox" },
      properties = { tag = tags[lastscreen][9] } }
}

client.add_signal("manage", function (c, startup)

    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

autorun = false
autorunApps = {
	"xmodmap .xmodmaprc"
}
if autorun then
	for app = 1, #autorunApps do
		awful.util.spawn(autorunApps[app])
	end
end

root.keys(globalkeys)
root.buttons(globalbuttons)

-- vim: ft=lua
