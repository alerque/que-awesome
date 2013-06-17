mybattery = widget({type = "textbox", name = "batterywidget", align = "right" })

function batteryInfo(widget, adapter)
	local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")
	local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full_design")
	local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
	local cur = fcur:read()
	local cap = fcap:read()
	local sta = fsta:read()
	local charge = math.floor(cur * 100 / cap)
	if sta:match("Charging") then
		battery = "+" .. charge .. "%"
	elseif sta:match("Discharging") then
		if tonumber(charge) < 25 then
			if tonumber(charge) < 10 then
				naughty.notify({ title      = "Battery Warning"
							, text       = "Battery low!"..charge.."%".."left!"
							, timeout    = 5
							, position   = "top_right"
							, fg         = beautiful.fg_focus
							, bg         = beautiful.bg_focus
							})
			end
		end
		battery = "-" .. charge .. "%"
	else
		battery = "A/C"
	end
	widget.text = "<span color='orange'>" .. battery .. "</span>"
	fcur:close()
	fcap:close()
	fsta:close()
end

local fpres = io.open("/sys/class/power_supply/BAT0/present", "r")
if fpres then
	awful.hooks.timer.register(15, function() batteryInfo(mybattery, "BAT0") end)
--	fpres.close()
end
