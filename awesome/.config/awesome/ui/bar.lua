-- ## Bar ##
-- ~~~~~~~~~

-- requirements
-- ~~~~~~~~~~~~
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local clickable_container = require('widget.clickable-container')


-- Tags
-- awful.util.tagnames =  { "1", "2" , "3", "4", "5", "6", "7", "8", "9" }
-- awful.util.tagnames =  { "", " ", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "dev",  "www", "sys", "doc", "vbox", "chat", "mus", "vid", "gfx" }
-- awful.util.tagnames =  { "", "", " ", "","", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "I", "II", "III", "IV", "V", "VI" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "一", "二", "三", "四", "五", "六", "七", "八", "九" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
awful.util.tagnames =  { "", "", "", "", "", "", "", "", ""}
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", ""}

-- Pacman Taglist :
-- awful.util.tagnames = {"●", "●", "●", "●", "●", "●", "●", "●", "●", "●"}
-- awful.util.tagnames = {"", "", "", "", "", "", "", "", "", ""}
-- awful.util.tagnames = {"•", "•", "•", "•", "•", "•", "•", "•", "•", "•"}
-- awful.util.tagnames = { "","", "", "", "", "", "", "", "", "" }
-- awful.util.tagnames = { "󰮯", "󰮯", "󰮯", "󰮯", "󰮯", "󰮯", "󰮯", "󰮯", "󰮯", "󰮯" }
-- awful.util.tagnames =  { "", "", "", "", "", "", "", "", "",  "" }

-- Widgets :

-- Barcontainer :
local function barcontainer(widget)
    local container = wibox.widget
      {
        widget,
        top = dpi(4),
        bottom = dpi(4),
        left = dpi(4),
        right = dpi(4),
        widget = wibox.container.margin
    }
    local box = wibox.widget{
        {
            container,
            top = dpi(2),
            bottom = dpi(2),
            left = dpi(4),
            right = dpi(4),
            widget = wibox.container.margin
        },
        bg = colors.container,
        shape = function(cr,w,h) gears.shape.rounded_rect(cr,w,h,8) end,
        widget = wibox.container.background
    }
return wibox.widget{
        box,
        top = dpi(4),
        bottom = dpi(4),
        right = dpi(2),
        left = dpi(2),
        widget = wibox.container.margin
    }
end

local clock_widget = require('widget.clock')
-- local keyboardlayout_widget = require('widget.keyboardlayout')
--local brightness_widget = require('widget.brightness')
-- local mem_widget = require('widget.memory')
-- local cpu_widget = require('widget.cpu')
-- local temprature_widget = require('widget.temprature')
--local battery_widget = require('widget.battery')
-- local updates_widget = require('widget.updates')


awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

	-- Create a launcher for each screen
	mylauncher = wibox.container.margin(mylauncher, dpi(0), dpi(0), dpi(4), dpi(4))

    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        visible = true,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }
    s.mylayoutbox = wibox.container.margin(s.mylayoutbox, dpi(7), dpi(7), dpi(7), dpi(7))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
				if client.focus then
					client.focus:move_to_tag(t)
				end
			end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
				if client.focus then
					client.focus:toggle_tag(t)
				end
			end),
        },
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({ }, 1, function (c)
                c:activate { context = "tasklist", action = "toggle_minimization" }
            end),
            awful.button({ }, 3, function() awful.menu.client_list { theme = { width = 250 } } end),
            awful.button({ }, 4, function() awful.client.focus.byidx(-1) end),
            awful.button({ }, 5, function() awful.client.focus.byidx( 1) end),
        },
		style    = {
			border_width = 1,
			border_color = colors.black,
			-- Text Enabeld :
			shape        = function(cr,w,h) gears.shape.rounded_rect(cr, w, h, 8) end,
			-- Text disabeld :
			--shape        = gears.shape.circle,
			bg_minimize = colors.black,
			bg_normal 	= colors.brightblack,
			bg_focus	= colors.brightblack,
		},
		layout   = {
			spacing = 8,
			spacing_widget = {
				{
					forced_width = 0,
					shape        = gears.shape.circle,
					widget       = wibox.widget.separator
				},
				valign = "center",
				halign = "center",
				widget = wibox.container.place,
			},
			layout  = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						-- Icon :
						{
							id     = "clienticon",
							widget = awful.widget.clienticon,
						},
						margins = 6,
						widget  = wibox.container.margin,
					},
					-- Text :
					--{
					--	id     = "text_role",
					--	widget = wibox.widget.textbox,
					--},
					layout = wibox.layout.fixed.horizontal,
				},
				left  = 5,
				right = 5,
				widget = wibox.container.margin
			},
			id     = "background_role",
			widget = wibox.container.background,
		},
    }

	-- Systemtry :
	s.systray = wibox.widget {
		visible = false,
		base_size = dpi(24),
		horizontal = true,
		screen = 'primary',
		widget = wibox.widget.systray
	}
	s.tray_toggler  		= require('widget.tray-toggle')

	-- Create the wibar
	----------------------
	s.mywibar = awful.wibar({
		position = "top",
		type = "dock",
		ontop = false,
		stretch = false,
		visible = true,
		height = dpi(34),
		width = s.geometry.width - dpi(30),
		screen = s,
		bg = colors.transparent,
	})

	awful.placement.top(s.mywibar, { margins = beautiful.useless_gap * 2 })
	s.mywibar:struts({
		top = dpi(50),
		--bottom = dpi(10),
	})

	-- Add widgets to the wibox
	s.mywibar:setup({
		{
			{
				layout = wibox.layout.align.horizontal,
				{ -- Left widgets :
					mylauncher,
					s.mytaglist,
					spacing = dpi(8),
					layout = wibox.layout.fixed.horizontal,
				},
				{ -- Middle widget :
				  layout = wibox.layout.align.horizontal,
				  s.mytasklist,
				},
				{ -- Right widgets :
					-- Updates :
					-- barcontainer(updates_widget),
					-- # CPU TEMP :
					-- barcontainer(temprature_widget),
					-- # CPU :
					-- barcontainer(cpu_widget),
					-- # RAM :
					-- barcontainer(mem_widget),
					-- # Keybord :
					-- barcontainer(keyboardlayout_widget),
					-- # Clock :
					barcontainer(clock_widget),
					{
						s.systray,
						margins = dpi(4),
						widget = wibox.container.margin,
					},
					s.tray_toggler,
					s.mylayoutbox,
					layout = wibox.layout.fixed.horizontal,
				},
			},
			left = dpi(10),
			right = dpi(10),
			widget = wibox.container.margin,
		},
		bg = colors.black,
		shape  = function(cr,w,h) gears.shape.rounded_rect(cr, w, h, 8) end,
		widget = wibox.container.background,
	})
end)

-- Wallpaper :
--screen.connect_signal("request::wallpaper", function(s)
--    awful.wallpaper {
--        screen = s,
--        widget = {
--            {
--                image     = theme.wallpaper,
--                upscale   = true,
--                downscale = true,
--                widget    = wibox.widget.imagebox,
--            },
--            valign = "center",
--            halign = "center",
--            tiled  = false,
--            widget = wibox.container.tile,
--        }
--
--    }
--end)


