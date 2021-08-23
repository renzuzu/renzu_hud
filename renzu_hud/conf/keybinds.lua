-- IMPORTANT TO CHANGE ALL OF THIS FIRST BEFORE RUNNING THIS SCRIPT, DEPENDING ON YOUR SERVER CONFIGURATION
-- HERE YOU CAN CHANGE THE KEYBINDS
config.keybinds = {
	--TOGGLE STATUS
	showstatus = 'INSERT',-- show toggable status
	--UI VOICE
	voip = 'Z', -- if voip keymap is enable (could be deprecated in future update of this hud)
	--signal lights
	signal_left = 'LEFT',
	signal_right = 'RIGHT',
	signal_hazard = 'BACK',
	-- seatbelt
	car_seatbelt = 'B', -- Seatbelt ui and seatbelt function
	-- Enter Vehicle -- This is needed to throw a function and loop while entering a vehicle
	entering = 'F',
	-- Switch Vehicle mode eg. Sports mode and Eco mode
	mode = 'RSHIFT', -- Right Shift Activate vehiclde mode
	--switching differential eg. 4WD,RWD,FWD
	differential = 'RCONTROL', -- Right CTRL Change Differential eg. 4wd,fwd,rwd
	cruisecontrol = 'RMENU', -- Right Alt CRUISE CONTROL
	bodystatus = 'HOME', -- show body status ui
    carcontrol = 'NUMLOCK', -- show car controls and other UI.
    enablenitro = 'DELETE', -- enable/disable nitro while in vehicle ( this is a toggable nitro function ) -- Default Nitro Boost is LShift
    carlock = 'L', -- show keyless car functions ( alarm or vehicle key)
    clothing = 'K', -- show clothing UI
	car_handbrake = 'SPACE', -- beta this instantly send notification to UI. instead of using while true do loop ( this is 100% more optimize )
	vehicle_status = 'U', -- Show Car Status, Coolant, Wheel, Mileage etc..
	carheadlight = 'H',
	hudsetting = 'F9',
}

--COMMANDS FOR KEYBINDS
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
	entering = 'entervehicle', -- being used only if modern is used to trigger the Push to start function.
	mode = 'mode', -- usage: type mode or press the registered keymap to enable/disable Sports/Eco Mode while in vehicle.
	differential = 'differential', -- usage: type differential or press the registerkeymap, instantly switch ex. 4wd to Rwd, Rwd to 4WD, FWD to 4WD and vice versa.
	cruisecontrol = 'cruisecontrol', -- usage: type cruisecontrol or press the registerkeymap: this is like a boolean, if you press once it will enable the cruising mode, and press it again, function will be disable
	bodystatus = 'bodystatus',
	bodystatus_other = 'checkbody', -- usage: go near to other player, type /checkbody ( this will allow you to check the body and heal them )
    bodyheal = 'bodyheal', -- usage: bodyheal (arm,chest,head,leg), example: bodyheal arm
    carcontrol = 'carcontrol',
    weaponui = 'weaponui',
    crosshair = 'crosshair', -- usage: crosshair (1,2,3), example: crosshair 3
    enablenitro = 'enablenitro',
    carlock = 'carlock',
    clothing = 'clothing',
	car_handbrake = 'handbrake',
	vehicle_status = 'vehiclestatus', -- usage type vehiclestatus or press the register keymap
	carui = 'carui', -- usage:carui (simple,minimal,modern), example: carui simple
	dragui = 'dragui', -- usage: type dragui and cursor will appear, you can move the Status HUD anywhere you like.
	dragcarui = 'dragcarui', -- usage: type dragcarui and the cursor will appear and move the Car HUD wherever you want ( this is in BETA, carhud is not 100% fluid yet )
	uiconfig = 'uiconfig', -- usage: uiconfig (ms,transition,acceleration) (value), 
	--example: uiconfig ms 0ms
	--uiconfig transition ease
	--uiconfig acceleration gpu
	carheadlight = 'carheadlight',
}