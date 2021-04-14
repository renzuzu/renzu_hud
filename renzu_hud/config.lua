config = {
	-- STREET LOCATION Customization options
	border = {
		r = 255;
		g = 255;
		b = 255;
		a = 0.65;
		size = 2.5;
	};

	current = {
		r = 9;
		g = 222;
		b = 1;
		a = 0.9;
		size = 1.0;
	};

	crossing = {
		r = 255;
		g = 233;
		b = 233;
		a = 0.9;
		size = 1.1;
	};

	direction = {
		r = 255;
		g = 233;
		b = 233;
		a = 0.9;
		size = 2.5;
	};

	position = {
		-- 0:100
		offsetX = 17;
		offsetY = 1.2;
	};

	vehicleCheck = true; -- Rather or not to display HUD when player(s) are inside a vehicle
}

config.framework = 'ESX' -- ESX | VRP | QSHIT | STANDALONE
--CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD

--STATUS MODE ( disabled v2 if you want optimize version ( FETCH ONLY The Player Status if Toggled ) else v2 is running loop default of 1sec)
config.statusv2 = true -- enable this if you want the status hud in bottom part , false if toggle mode
config.statusv2_sleep = 1000 -- 1sec
config.status = {
	'energy',
	'thirst',
	'sanity',
	'hunger'
}

config.keybinds = {
	--TOGGLE STATUS
	showstatus = 'INSERT',
	--UI VOICE
	voip = 'Z',
	--signal lights
	signal_left = 'LEFT',
	signal_right = 'RIGHT',
	signal_hazard = 'BACK',
	-- seatbelt
	car_seatbelt = 'B',
}

config.commands = {
	--TOGGLE STATUS
	showstatus = 'showstatus',
	--UI VOICE
	voip = 'voice',
	--signal lights
	signal_left = 'left',
	signal_right = 'right',
	signal_hazard = 'hazard',
	-- seatbelt
	car_seatbelt = 'seatbelt',
}

--OPTIMIZATION
-- DONT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING!
config.uitop_sleep = 2000
config.gear_sleep = 700
config.lights_sleep = 1000
config.direction_sleep = 2500
config.NuiCarhpandGas_sleep = 1500
config.car_mainloop_sleep = 2000
config.rpm_speed_loop = 22
config.idle_rpm_speed_sleep = 111
config.Rpm_sleep = 111
config.Rpm_sleep_2 = 22
config.Speed_sleep = 111
config.Speed_sleep_2 = 22