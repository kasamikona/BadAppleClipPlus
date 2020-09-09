require("actions")
require("rbsettings")
require("settings")
--mathex=require("math_ex")
do_play=true

datafile = nil

function prepare_data(vidfn,audfn)
	-- video
	root = rb.current_path()
	datafile = io.open(root..vidfn,"rb")
	rb.sleep(rb.HZ/10)
	-- audio
	audfile=io.open(root..'_.m3u','w')
	audfile:write(root..audfn..'\n')
	audfile:close()
	rb.playlist('create',root,'_.m3u')
	rb.yield()
	rb.playlist('start',0,0*1000,0)
	rb.audio("pause") -- immediately pause - add silence at the start to avoid click
end

function play()
	if datafile == nil then return end
	do_play = true
	-- get that data flowing! not sure why this helps. cache?
	for i = 1,50 do
		datafile:read(1024)
	end
	datafile:seek("set",0)
	rb.lcd_clear_display() -- blank screen
	rb.lcd_update()
	rb.sleep(rb.HZ/2)
	rb.yield()
	collectgarbage("collect")
	lastframe = -1
	dat = nil
	rb.audio("resume")
	while do_play do
		if rb.get_plugin_action(0)==rb.actions.PLA_CANCEL then break end -- kill on button
		if rb.audio("status") == 0 then break end -- kill on stop
		playtime = rb.audio("elapsed")
		if playtime == nil then break end
		timeframe = (playtime / 10) + 20 -- 100fps data
		if timeframe >= 0 then
			if lastframe > timeframe then break end -- kill on repeat
			if lastframe < timeframe then
				while lastframe < timeframe-20 do -- pos sync
					datafile:seek("cur",1024)
					lastframe = lastframe + 1
				end
				dat = datafile:read(1024)
				lastframe = lastframe + 1
			end
			if dat == nil then break end -- kill on data end
			rb.lcd_blit_mono(dat,nil,0,0,128,8,128)
			rb.sleep(rb.HZ/100) -- rate sync
		end
	end
	datafile:close()
end

--MAIN PROGRAM
rb.backlight_force_on() -- disable timeout
rb.cpu_boost(true) -- enable overclock
rb.audio('stop') -- clear currently playing
rb.sound_set_pitch(10000) -- reset pitch to +0
rb.lcd_clear_display() -- blank screen
rb.lcd_update()
rb.lcd_set_contrast(999) -- full brightness
prepare_data("vid.bin","vid.mp3") -- get files ready
play() -- play video
rb.audio('stop') -- stop music
os.remove(rb.current_path()..'_.m3u') -- remove temp playlist
rb.lcd_set_contrast(rb.settings.read("global_settings",rb.system.global_settings.contrast,"system")) -- restore brightness
rb.backlight_use_settings() -- restore timeout
rb.lcd_clear_display() -- blank screen
rb.lcd_update()
rb.sleep(20) -- wait a moment
rb.cpu_boost(false) -- disable overclock
