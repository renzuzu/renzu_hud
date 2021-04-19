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
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound)
config.engineoverheat = true -- ENGINE EXPLODE AND OVERHEAT FEATURE (IF REVING 9200 RPM ABOVE Engine Temperature will rise, explode it if too hot , temp value = 150)
config.dangerrpm = 0.92 -- 9200 rpm, above this level temp will rise
config.addheat = 10 -- additional temp for everytime the dangerrpm is reach
config.overheatmin = 150 -- engine will explode when the temperature rise to this level
config.overheatadd = 500 -- additional temperature when engine explodes
--STATUS MODE ( disabled v2 if you want optimize version ( FETCH ONLY The Player Status if Toggled ) else v2 is running loop default of 1sec)
config.statusv2 = true -- enable this if you want the status hud in bottom part , false if toggle mode
config.statusv2_sleep = 1000 -- 1sec
config.status = {
	'energy',
	'thirst',
	'sanity',
	'hunger'
}

config.fueldecor = "_FUEL_LEVEL"

config.classes = {
	[0] = 0.6, -- Compacts
	[1] = 0.6, -- Sedans
	[2] = 0.6, -- SUVs
	[3] = 0.6, -- Coupes
	[4] = 0.6, -- Muscle
	[5] = 0.6, -- Sports Classics
	[6] = 0.6, -- Sports
	[7] = 0.6, -- Super
	[8] = 0.6, -- Motorcycles
	[9] = 0.6, -- Off-road
	[10] = 0.6, -- Industrial
	[11] = 0.6, -- Utility
	[12] = 0.6, -- Vans
	[13] = 0.0, -- Cycles
	[14] = 0.0, -- Boats
	[15] = 0.0, -- Helicopters
	[16] = 0.0, -- Planes
	[17] = 0.3, -- Service
	[18] = 0.3, -- Emergency
	[19] = 0.6, -- Military
	[20] = 0.6, -- Commercial
	[21] = 0.6, -- Trains
}

config.fuelusage = {
	[1.4] = 2.7,
	[1.3] = 2.5,
	[1.2] = 2.4,
	[1.1] = 2.2,
	[1.0] = 2.0,
	[0.9] = 1.8,
	[0.8] = 1.6,
	[0.7] = 1.4,
	[0.6] = 1.2,
	[0.5] = 1.0,
	[0.4] = 0.8,
	[0.3] = 0.6,
	[0.2] = 0.4,
	[0.1] = 0.2,
	[0.0] = 0.0,
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
	entering = 'F',
	mode = 'RSHIFT'
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
	entering = 'entervehicle',
	mode = 'mode'
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