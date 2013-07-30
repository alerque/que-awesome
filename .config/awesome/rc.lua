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

beautiful.init(theme_path)

theme.border_width = "0"
--theme.wallpaper_cmd = "feh --bg-fill greece_flower_bg.jpg"

--terminal = "urxvt"
terminal = "gnome-terminal"
browser = "chrome"
editor = os.getenv("EDITOR") or "gvim.gnome"
editor_cmd = editor

winkey = "Mod4"
control = "Control"
shift = "Shift"

naughty.config.default_preset.position = "bottom_right"

kbdcfg = {}
kbdcfg.widget = widget({ type = "textbox", align = "right" })

kbdcfg.switch_en = function ()
	kbdcfg.widget.text = " en "
	os.execute( "setxkbmap us" )
	os.execute( "setxkbmap -option 'nbsp:zwnj2nb3nnb4'" )
	os.execute( "xmodmap ~/.xmodmaprc" )
	os.execute( "xmodmap -e 'keycode 66 = Mode_switch'" )
end

kbdcfg.switch_tr = function ()
	kbdcfg.widget.text = " tr "
	os.execute( "setxkbmap tr" )
	os.execute( "setxkbmap -option 'nbsp:zwnj2nb3nnb4'" )
	os.execute( "xmodmap ~/.xmodmaprc" )
	os.execute( "xmodmap -e 'keycode 66 = ISO_Level3_Shift'" )
end


layouts =
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

textclock = awful.widget.textclock({ align = "right" })
systray = widget({ type = "systray" })

stats = awful.widget.graph({})
stats:set_width(10)
--bashets.register("load.sh")
--bashets.register("awesome_load.zsh", {widget = stats})
--bashets.start()

globalbuttons = awful.util.table.join(
    awful.button({ }, 6, awful.tag.viewprev),
    awful.button({ }, 7, awful.tag.viewnext)
)

globalkeys = awful.util.table.join(
	awful.key({ winkey }, "Return", function () awful.util.spawn(terminal) end),
	awful.key({ winkey }, "\\", function () awful.util.spawn(browser) end),

    awful.key({ winkey }, "n",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),
    awful.key({ winkey }, "p", awful.tag.history.restore),

    awful.key({ winkey }, "h", awful.tag.viewprev),
    awful.key({ winkey }, "l", awful.tag.viewnext),

    awful.key({ winkey }, "j",
        function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ winkey }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

	awful.key({ winkey }, "b", awful.tag.viewnone),

    awful.key({ winkey }, "u", function () awful.screen.focus_relative(1) end),
    awful.key({ winkey }, "i", function () awful.screen.focus_relative(-1) end),
    awful.key({ winkey }, "ı", function () awful.screen.focus_relative(-1) end),

    awful.key({ winkey }, ";", awful.client.urgent.jumpto),
    awful.key({ winkey }, "ş", awful.client.urgent.jumpto),

	awful.key({ winkey }, "e", function () kbdcfg.switch_en() end),
	awful.key({ winkey }, "t", function () kbdcfg.switch_tr() end),

    awful.key({ winkey, control }, "r", awesome.restart),
    awful.key({ winkey, control }, "q", awesome.quit),

	awful.key({ winkey }, "=", function () awful.tag.incncol( 1) end),
	awful.key({ winkey }, "*", function () awful.tag.incncol( 1) end),
    awful.key({ winkey }, "-", function () awful.tag.incncol(-1) end),

    awful.key({ winkey }, ".", function () awful.tag.incmwfact( 0.1) end),
    awful.key({ winkey }, "ç", function () awful.tag.incmwfact( 0.1) end),
    awful.key({ winkey }, ",", function () awful.tag.incmwfact(-0.1) end),
    awful.key({ winkey }, "ö", function () awful.tag.incmwfact(-0.1) end),

    awful.key({ winkey, control }, ".", function () awful.tag.incnmaster( 1) end),
    awful.key({ winkey, control }, "ç", function () awful.tag.incnmaster( 1) end),
    awful.key({ winkey, control }, ",", function () awful.tag.incnmaster(-1) end),
    awful.key({ winkey, control }, "ö", function () awful.tag.incnmaster(-1) end),

    awful.key({ winkey }, "space", function () awful.layout.inc(layouts, 1) end),
    awful.key({ winkey, control }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ winkey }, "r", function () promptbox:run() end),

    awful.key({ winkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  promptbox.widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

tags = {}
for i = 1, 9 do
    globalkeys = awful.util.table.join(
		globalkeys,
        awful.key({ winkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ winkey, control, shift }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ winkey, shift }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ winkey, control }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ winkey }, "z",
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][10])
                      end
                  end)
	)
end

taglist = {}
taglist.buttons = awful.util.table.join(
		globalbuttons,
		awful.button({ }, 1, awful.tag.viewonly),
		awful.button({ }, 3, awful.tag.viewtoggle),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
	)

tasklist = {}
tasklist.buttons = awful.util.table.join(
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

promptbox = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright})
promptbox.widget.width = 200

tasklist = awful.widget.tasklist(function(c)
	return awful.widget.tasklist.label.allscreen(c, lastscreen)
	end, tasklist.buttons
)

layoutbox = {}
tagswidget = {}
for s = 1, screen.count() do
	tags[s] = awful.tag({ " 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 ", " bg " }, s, awful.layout.suit.spiral)
	tags[s][1].selected = true

	layoutbox[s] = awful.widget.layoutbox(s)
	layoutbox[s]:buttons(awful.util.table.join(
			awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
		))
	tagswidget[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)

end

require("gigamo");

wibox = awful.wibox({ position = "top", screen = lastscreen})

wibox.widgets = {
	textclock,
	systray,
	kbdcfg.widget,
	battery,
	{
		layoutbox[1],
		tagswidget[1],
		lastscreen == 2 and layoutbox[2] or nil,
		lastscreen == 2 and tagswidget[2] or nil,
		promptbox,
		-- stats,
		tasklist,
		layout = awful.widget.layout.horizontal.leftright
	},
	layout = awful.widget.layout.horizontal.rightleft
}

--bashets.start()

clientkeys = awful.util.table.join(
	globalkeys,
    awful.key({ winkey }, "f", function (c) c.fullscreen = not c.fullscreen end),
    awful.key({ winkey }, "q", function (c) c:kill() end),
    awful.key({ winkey }, "g", function (c) c.floating = not c.floating end),
	awful.key({ winkey }, "t", function (c) c.ontop = not c.ontop end),
    awful.key({ winkey }, "o", awful.client.movetoscreen ),
    awful.key({ winkey }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical = not c.maximized_vertical
        end)
)

clientbuttons = awful.util.table.join(
	globalbuttons,
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ winkey }, 1, awful.mouse.client.move),
    awful.button({ winkey, control }, 1, awful.mouse.client.resize)
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
    { rule = { class = "pidgin" },
      properties = { tag = tags[lastscreen][1] } },
    { rule = { class = "skype" },
      properties = { tag = tags[lastscreen][1] } },
    { rule = { class = "Lyricue_display" },
      properties = { tag = tags[1][9],
					 maximized_horizontal = false,
					 maximized_vertical = false,
					 floating = true } }
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

kbdcfg.switch_en()

root.keys(globalkeys)
root.buttons(globalbuttons)

-- vim: ft=lua
