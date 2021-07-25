-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
---------------------------------------------------------https://github.com/renzuzu/renzu_hud------------------------------------------
config = {}
config.gamebuild = 'auto' -- if 2189 pedshot transparent and 1604 or < 2000 = Enter vehicle game event will not work, we will use normal pedshot ( gamebuild is what you set on your server start example: +set sv_enforceGameBuild 2189, available build 1604, 2060, 2189 and more.) this is important if you are using UI Normal with Ped Face.
config.framework = 'STANDALONE' -- ESX | QBCORE | VRP | STANDALONE (VRP not supported yet, but you can use standalone, it will work!)
config.Mysql = 'mysql-async' -- 'ghmattisql' | 'mysql-async'
config.weight_type = false -- ESX item weight or limit type
config.vehicle_table = 'owned_vehicles' -- change this if you use different sql table for player vehicles (note identifier steam is always being used here)
config.Owner_column = 'owner' -- owner column name for identifier eg.steam hex,licensed
config.ESX_Items = { -- important to change job, weight. (job = false means its available to use for everyone) -- do not change the array name ex. ['nitro'], you can change the name = 'nitro'
	['nitro'] = {name = 'nitro', event = 'renzu_hud:addnitro', value = false, weight = 1, label = 'Nitro', job = false},
	['coolant'] = {name = 'coolant', event = 'renzu_hud:coolant', value = false, weight = 1, label = 'Coolant', job = false},
	['engineoil'] = {name = 'engineoil', event = 'renzu_hud:oil', value = false, weight = 1, label = 'Engine Oil', job = 'mechanic'},
	['turbo_street'] = {name = 'turbo_street', event = 'renzu_hud:install_turbo', value = 'street', weight = 1, label = 'Street Turbine', job = 'mechanic'},
	['turbo_sports'] = {name = 'turbo_sports', event = 'renzu_hud:install_turbo', value = 'sports', weight = 1, label = 'Sports Turbine', job = 'mechanic'},
	['turbo_racing'] = {name = 'turbo_racing', event = 'renzu_hud:install_turbo', value = 'racing', weight = 1, label = 'Racing Turbine', job = 'mechanic'},
	['head_brace'] = {name = 'head_brace', event = 'renzu_hud:healbody', value = 'head', weight = 1, label = 'Head Brace', job = false},
	['leg_bandage'] = {name = 'leg_bandage', event = 'renzu_hud:healbody', value = 'leg', weight = 1, label = 'Leg Bandage', job = false},
	['arm_bandage'] = {name = 'arm_bandage', event = 'renzu_hud:healbody', value = 'arm', weight = 1, label = 'Arm Bandage', job = false},
	['body_bandage'] = {name = 'body_bandage', event = 'renzu_hud:healbody', value = 'chest', weight = 1, label = 'Body Bandage', job = false},
	['street_tirekit'] = {name = 'street_tirekit', event = 'renzu_hud:installtire', value = 'default', weight = 1, label = 'Street Tire Kit', job = 'mechanic'},
	['sports_tirekit'] = {name = 'sports_tirekit', event = 'renzu_hud:installtire', value = 'sports', weight = 1, label = 'Sports Tire Kit', job = 'mechanic'},
	['racing_tirekit'] = {name = 'racing_tirekit', event = 'renzu_hud:installtire', value = 'racing', weight = 1, label = 'Racing Tires Kit', job = 'mechanic'},
	['drag_tirekit'] = {name = 'drag_tirekit', event = 'renzu_hud:installtire', value = 'drag', weight = 1, label = 'Drag Tires Kit', job = 'mechanic'},
	['manual_tranny'] = {name = 'manual_tranny', event = 'renzu_hud:manual', value = true, weight = 1, label = 'Manual Trannsmition', job = 'mechanic'},
	['automatic_tranny'] = {name = 'automatic_tranny', event = 'renzu_hud:manual', value = false, weight = 1, label = 'Automatic Tranny', job = 'mechanic'},
}
config.enable_commands_as_item = true -- if you are not using ESX, you can enable this, you can type /useitem nitro (for example) -- standalone purpose without ESX
config.commanditem_permission = { -- item command permission -- standalone purpose!
	'steam:11000013ec77a2e', -- steam hex id, change this to yours, you can add as many as you want
	'steam:11000013ec77a2e',
	'steam:11000013ec77a2e',
}
config.identifier = 'steam:' -- standalone purpose, ignore if using framework
--MULTI CHARACTER START -- set config.multichar = false if you are not using any multi character ( configuring this is needed to avoid problems saving to database )
config.multichar = false -- KASHACTERS, cd_multicharacter, etc...
--IMPORTANT PART IF USING Multicharacter
-- if multichar_advanced is false == using steam: format or the config.identifier
config.multichar_advanced = true -- Using Permanent Char1,Char2 up to Char5 identifier from database. ( This means the identifier reads by ESX or other framework will have Char1:BLAHBLAHBLAH instead of steam:BLAHBLAHBLAH ( from xPlayer.identifier for example))
config.characterchosenevent = 'kashactersS:CharacterChosen' -- this event contains charid (IMPORTANT and will read only if using advanced)
config.charprefix = 'Char' -- dont change unless you know what you are doing
--loadedasmp will use the charslot from user_lastcharacter, kashacters and other multicharacter have this.
config.loadedasmp = true -- if player model is mp player, pass the loaded event to server ( naturally if player model is PLAYER_ZERO its mean you are on the loading screen or in the character select page of your multicharacter script. )
--MULTI CHAR END
--MAIN UI CONFIG START
config.enablestatus = true -- enable/disable status v1 ( icons,progress status ) -- this will disable all status functions
config.enablecompass = true -- enable/disable compass
config.enable_carui = true -- enable/disable the car UI (THIS WILL DISABLE ALL VEHICLE FUNCTION AS WELL)
config.carui = 'simple' -- Choose a Carui Version ( simple, minimal, modern )
config.available_carui = {
	['simple'] = true,
	['minimal'] = true,
	['modern'] = true,
}
config.enable_carui_perclass = true -- enable/disable the Vehicle Class UI config (if this is enable , the config.carui will be ignored)
config.carui_perclass = {
	--change and define each class to show the vehicle UI class
	[0] = 'simple', -- Compacts
	[1] = 'simple', -- Sedans
	[2] = 'modern', -- SUVs
	[3] = 'minimal', -- Coupes
	[4] = 'simple', -- Muscle
	[5] = 'minimal', -- Sports Classics
	[6] = 'minimal', -- Sports
	[7] = 'minimal', -- Super
	[8] = 'simple', -- Motorcycles
	[9] = 'modern', -- Off-road
	[10] = 'modern', -- Industrial
	[11] = 'modern', -- Utility
	[12] = 'modern', -- Vans
	[13] = 'simple', -- Cycles
	[14] = 'simple', -- Boats
	[15] = 'simple', -- Helicopters
	[16] = 'simple', -- Planes
	[17] = 'modern', -- Service
	[18] = 'modern', -- Emergency
	[19] = 'modern', -- Military
	[20] = 'modern', -- Commercial
	[21] = 'simple', -- Trains
}
--STATUS CONFIG
config.statusv1sleep = 1000 -- 1 second update
config.statusui = 'simple' -- UI LOOK ( simple, normal ) -- NORMAL = with pedface, Simple = Only Icons
config.status_type = 'progressbar' -- circle progress bar = progressbar, fontawsome icon = icons
config.statusv2 = true -- enable this if you want the status toggle mode (TOGGLE VIA INSERT) (THIS INCLUDE RP PURPOSE HUD like job,money,etc.)
config.statusplace = 'bottom-left' -- available option top-right,top-left,bottom-right,bottom-left,top-center,bottom-center
config.uidesign = 'circle' -- octagon (default), circle, square
--CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD
--UI CONFIG END
--start car map
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound) (MP3 not implemented yet..lazy..)
config.mapversion = 'satellite' -- available ( satellite, atlas, oldschool )
config.usecustomlink = false -- use custom url of image map
config.push_start = true -- enable/disable push to start for modern UI
config.mapurl = 'https://github.com/jgardner117/gtav-interactive-map/blob/master/images/gtav.png?raw=true' -- if use custom url define it
--atlas link https://github.com/jgardner117/gtav-interactive-map/blob/master/images/gtav.png?raw=true
--satellite link https://github.com/jgardner117/gtav-interactive-map/blob/master/images/GTAV_SATELLITE_8192x8192.png?raw=true
--credits https://github.com/jgardner117/gtav-interactive-map
-- minimap
config.useminimapeverytime = false -- FORCE display radarmap all the time? (USE THIS ONLY IF Some of your other script use displayradar(FALSE) , its advisable to disable this config instead remove it on your other script, default GTA show the Minimap everytime)
config.usecircleminimap = true -- display oval minimap instead of box radar map?
config.removemaphealthandarmor = false -- FORCE REMOVE HEALTHBAR AND ARMOR FROM MINIMAP (This will cause more infinite loop just to disable the hp and armor, will cause more Cpu ms at resmon) -- USE THIS ONLY IF minimap.gfx is not working for you, its on the stream folder, it remove health and armor automatically
--OVERHEAT FUNC
config.engineoverheat = true -- ENGINE EXPLODE AND OVERHEAT FEATURE (IF REVING 9200 RPM ABOVE Engine Temperature will rise, explode it if too hot , temp value = 150)
config.dangerrpm = 0.92 -- 9200 rpm, above this level temp will rise
config.addheat = 10 -- additional temp for everytime the dangerrpm is reach
config.overheatmin = 150 -- engine will explode when the temperature rise to this level
config.overheatadd = 500 -- additional temperature when engine explodes
config.reduce_coolant = 1 -- Reduce Coolant  ( This will trigger if vehicle constantly reaching the maximum temperature) Like in Real Vehicle Coolant Reserve handle will reduce a water/coolant to prevent the radiator overflowing due to the Water Temperature is very hot.
config.reducetemp_onwateradd = 300 -- Reduce Engine Temperature when Coolant/Water is used
config.driftcars = { -- whitelist the driftcars to engine blown ( why? drift cars or drift handling tends to rev higher )
	[`ae866`] = true, -- backtick to get hashkey insert vehicle model here
	[`fc3s`] = true,
}
-- Vehicle Mode
--config.boost and config.turbo_boost cannot be the same high value, if you want to use turbo system, config.boost must be always lower than the config.turbo_boost
config.boost = 0.45 -- Boost Level when sports mode is activated eg. 1.5 Bar, you can put upt o 3.0 or even 5.0 but pretty sure it will be unrealistic acceleration ( this affect Fuel Consumption )
config.sports_increase_topspeed = true -- do you want the topspeed will be affected? some Fivem Servers Likes a demonic topspeed :D - not good in RP. Boost only affects engine torque and horsepower not the gear ratio and final drive of transmision which affects topspeed
config.topspeed_multiplier = 1.1 -- if sports_increase_topspeed is enable, multiplier 1.5 = x1.5 eg. normal top speed 200kmh if you put 1.5 the new topspeed is 300kmh
config.eco = 0.5 -- Eco Level when Eco Mode is activated (this affect the efficiency of fuel)
config.boost_sound = true
--TURBO if using turbo the sports vehicle mode will not add torque anymore if the current turbo power is greater than the config.boost .
config.useturboitem = true -- this is ESX only for now
config.turbogauge = true -- show turbo gauge UI (only shows if turbo boost is installed)
config.turboprop = true -- show turbo prop
config.lagamount = {
	['default'] = 20,
	['street'] = 50,
    ['sports'] = 100,
    ['racing'] = 150,
} --- affect turbo lag, more numbers mean more lag but more power produced, smaller turbo should be lower lag like 100 is good start.
config.turbo_boost = { -- turbo boost
    ['default'] = config.boost,
    ['street'] = 0.5,
    ['sports'] = 1.0,
    ['racing'] = 2.0,
}
config.turbo_health = 1000 -- turbo health, power will be reduce greatly if this numbers become 0 -- not available now
--MILEAGE
config.mileage_update = 1000 -- This will Affect the Mileage update speed
config.mileage_speed = 2.0 -- ( Lesser Number value eg . 0.5 = Less Mile age for the car) greater number like 1.5 2.0 = x1.5, x2 output, You Can Change this so you can have a RP for Changing Vehicle Oil Etc.. sooner than later.
config.needchangeoil = true -- Vehicle Oil need to be change or else performance will degrade ( ESX FRAMEWORK NEEDED else commands only for standalone )
config.mileagemax = 10000 -- Maximum mileage for vehicle before needing a Change Oil.
config.degrade_engine = 0.8 -- 0.8 = 80% of 100% Performance ex. 1.0 = no change to performance, 0.8 is minus 20% performance - Degrade Engine Performance when current mileage is greater than the mileagemax
--SEATBELT
config.enableseatbeltfunc = true -- enable custom seatbelt function
config.seatbelt_2 = true -- uses rockstar default car crash via windscreen fly. , you need to set this on your server.cfg ,  setr game_enableFlyThroughWindscreen true   ---- This is more optimized version
config.seatbeltminspeed = 15.6464 -- minimum speed (meters) to trigger the fly troughwindscreen when crash in vehicle --- convert meters to kmh = 10 meters * 3.6 = kmh
config.seatbeltmaxspeed = 55.6464 -- this is meters not kmh or mph,  this will set the maximum speed limit for the seatbelt, if > max speed player will thrown out trough windscreen
config.reducepedhealth = true -- reduce ped health when having a accident
config.shouldblackout = true -- Black out the ped
config.hazyeffect = false -- have a hazy effect after the impact
config.addsanity_stress = true -- add sanity or stress status
config.sanity_stressAdd = 40000 -- value to add
config.impactdamagetoped = 1.0 -- 0.5 = 50%, 1.0 = 100% ( Calculated based on the Vehicle Speed KMH )
config.impactdamagetoveh = true -- apply damage to vehicle, burst random tires, remove windshield
config.randomdamage = 555 -- random damage to vehicle parts, such a body, engine, petrol tank
--STATUS ( disabled v2 if you want the optimize version ( FETCH ONLY The Player Status if Toggled ) else v2 is running loop default of 1sec)
config.statusv2_sleep = 1000 -- 1sec
config.statusnotify = true
config.driving_affect_status = true -- should the status will be affected during Driving a vehicle?
config.driving_affected_status = 'sanity' -- change whatever status you want to be affected during driving
config.driving_status_mode = 'remove' -- (add, remove) add will add a value to status, remove will remove a status value.
config.driving_status_val = 10000 -- status value to add/remove
config.driving_status_radius = 200 -- driving distance to add status
config.firing_affect_status = true -- Firing Weapons affects status?
config.firing_affected_status = 'sanity' -- Affected Status during gunplay
config.firing_status_mode = 'add' -- Status Function (add,remove) add will add a value to status, remove will remove a status value.
config.firing_statusaddval = 500 -- value to add when firing a weapons
config.firing_bullets = 100 -- number of bullets or firing events to trigger the status function.
config.killing_affect_status = true -- do you want the status to be affected when you kill some player , ped, animals.
config.killing_affected_status = 'sanity'
config.killing_status_mode = 'add' -- (add,remove) add will add a value to status, remove will remove a status value.
config.killing_status_val = 100 -- status value to add/remove per kill
config.running_affect_status = true -- if player is running (not sprint) status will affected?
config.running_affected_status = 'thirst' -- change this to whatever status you wanted to be affected
config.running_status_mode = 'remove' -- should add or remove? its up to you. affected status if running
config.running_status_val = 1000 -- how much we add / remove to the status?
config.melee_combat_affect_status = true -- melee attack like punch,kick,pistolwhiping,etc can affect the status?
config.melee_combat_affected_status = 'sanity' -- type of status
config.melee_combat_status_mode = 'remove' -- status remove or add?
config.melee_combat_status_val = 10000 -- value to add/remove
config.parachute_affect_status = true -- while parachuting mode can add status?
config.parachute_affected_status = 'sanity' -- type of status
config.parachute_status_mode = 'remove' -- status remove or add?
config.parachute_status_val = 10000 -- value to add/remove
--status standalone purpose (use this only if you need it)
-- Add / Remove Status when playing some animations
config.playing_animation_affect_status = true
config.status_animation = {
	--this is a DICT
	{ dict = 'mp_player_inteat@burger', name='mp_player_int_eat_burger', status = 'hunger', mode = 'add', val = '300000'},
	{ dict = 'mp_player_inteat@burger', name='mp_player_int_eat_burger_fp', status = 'hunger', mode = 'add', val = '300000'},
	{ dict = 'mp_player_intdrink', name='loop_bottle', status = 'thirst', mode = 'add', val = '300000'},
	{ dict = 'mp_player_intdrink', name='loop_bottle_fp', status = 'thirst', mode = 'add', val = '300000'},
	{ dict = 'amb@world_human_aa_smoke@male@idle_a', name='idle_c', status = 'sanity', mode = 'remove', val = '10000'},

	-- you can add as many animation as you want
}

--advanced usage if you want to add more status and reorder it.
--the config have the div id's, offsets, colors, classes per status.
config.statusordering = { -- SET enable = false to disable the status (the status must be registered from your esx_status) i highly suggest to use my standalone_status (https://github.com/renzuzu/renzu_status) so you wont have to edit the special events and exports needed for the status System!
	[0] = {type = 1, enable = true, status = 'health', rpuidiv = 'null', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'none', id = 'uisimplehp', offset = '275', i_id_1 = 'healthsimple', i_id_1_color = 'rgb(251, 29, 9)', i_id_1_class = 'fas fa-heartbeat fa-stack-1x', i_id_3_class = 'fas fa-heartbeat', i_id_2 = 'healthsimplebg', i_id_2_color = 'rgba(251, 29, 9, 0.3)', i_id_2_class = 'fas fa-heartbeat fa-stack-1x', id_3 = 'health_blink'},
	[1] = {type = 1, enable = true, status = 'armor', rpuidiv = 'null', hideifmax = true, custom = false, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'none', id = 'uisimplearmor', offset = '275', i_id_1 = 'armorsimple', i_id_1_color = 'rgb(1, 103, 255)', i_id_1_class = 'far fa-shield-alt fa-stack-1x', i_id_3_class = 'far fa-shield-alt', i_id_2 = 'armorsimplebg', i_id_2_color = 'rgb(0, 41, 129)', i_id_2_class = 'far fa-shield-alt fa-stack-1x', id_3 = 'armor_blink'},
	[2] = {type = 1, enable = true, status = 'hunger', rpuidiv = 'hunger', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'block', id = 'uisimplehunger', offset = '275', i_id_1 = 'food2', i_id_1_color = 'rgb(221, 144, 0)', i_id_1_class = 'fad fa-cheeseburger fa-stack-1x', i_id_3_class = 'fad fa-cheeseburger', i_id_2 = 'food2bg', i_id_2_color = 'rgb(114, 68, 0)', i_id_2_class = 'fad fa-cheeseburger fa-stack-1x', id_3 = 'hunger_blink'},
	[3] = {type = 1, enable = true, status = 'thirst', rpuidiv = 'thirst', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very thirsty', notify_value = 20, display = 'block', id = 'uisimplethirst', offset = '275', i_id_1 = 'water2', i_id_1_color = 'rgb(36, 113, 255)', i_id_1_class = 'fad fa-glass fa-stack-1x', i_id_3_class = 'fad fa-glass', i_id_2 = 'water2bg', i_id_2_color = 'rgb(0, 11, 112)', i_id_2_class = 'fad fa-glass fa-stack-1x', id_3 = 'thirst_blink'},
	[4] = {type = 1, enable = true, status = 'sanity', rpuidiv = 'stressbar', hideifmax = false, custom = true, value = 0, notify_lessthan = true, notify_message = 'i see some dragons', notify_value = 80, display = 'block', id = 'uisimplesanity', offset = '275', i_id_1 = 'stress2', i_id_1_color = 'rgb(255, 16, 68)', i_id_1_class = 'fad fa-head-side-brain fa-stack-1x', i_id_3_class = 'fad fa-head-side-brain', i_id_2 = 'stress2bg', i_id_2_color = 'rgba(35, 255, 101, 0.842)', i_id_2_class = 'fad fa-head-side-brain fa-stack-1x', id_3 = 'stress_blink'},
	[5] = {type = 1, enable = true, status = 'stamina', rpuidiv = 'staminabar', hideifmax = true, custom = false, value = 0, notify_lessthan = false, notify_message = 'running makes me thirsty', notify_value = 20, display = 'block', id = 'uisimplestamina', offset = '275', i_id_1 = 'stamina2', i_id_1_color = 'rgb(16, 255, 136)', i_id_1_class = 'fad fa-running fa-stack-1x', i_id_3_class = 'fad fa-running', i_id_2 = 'stamina2bg', i_id_2_color = 'rgba(0, 119, 57, 0.945)', i_id_2_class = 'fad fa-running fa-stack-1x', id_3 = 'stamina_blink'},
	[6] = {type = 1, enable = true, status = 'oxygen', rpuidiv = 'oxygenbar', hideifmax = true, custom = false, value = 0, notify_lessthan = false, notify_message = 'my oxygen is almost gone', notify_value = 20, display = 'block', id = 'uisimpleoxygen', offset = '275', i_id_1 = 'oxygen2', i_id_1_color = 'rgb(15, 227, 255)', i_id_1_class = 'fad fa-lungs fa-stack-1x', i_id_3_class = 'fad fa-lungs', i_id_2 = 'oxygen2bg', i_id_2_color = 'rgba(8, 76, 85, 0.788)', i_id_2_class = 'fad fa-lungs fa-stack-1x', id_3 = 'oxygen_blink'},
	[7] = {type = 1, enable = true, status = 'energy', rpuidiv = 'energybar', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very tired', notify_value = 20, display = 'block', id = 'uisimpleenergy', offset = '275', i_id_1 = 'energy2', i_id_1_color = 'rgb(233, 233, 233)', i_id_1_class = 'fas fa-snooze fa-stack-1x', i_id_3_class = 'fas fa-snooze', i_id_2 = 'energy2bg', i_id_2_color = 'color:rgb(243, 57, 0)', i_id_2_class = 'fas fa-snooze fa-stack-1x', id_3 = 'energy_blink'},
	[8] = {type = 1, enable = true, status = 'voip', rpuidiv = 'null', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'silent mode', notify_value = 0, display = 'block', id = 'voip_2', offset = '275', i_id_1 = 'microphone', i_id_1_color = 'rgb(251, 29, 9)', i_id_1_class = 'fas fa-microphone fa-stack-1x', i_id_2 = 'voipsimplebg', i_id_3_class = 'fas fa-microphone', i_id_2_color = 'rgba(251, 29, 9, 0.3)', i_id_2_class = 'fas fa-microphone fa-stack-1x', id_3 = 'voip_blink'},
}
-- BODY STATUS
config.bodystatus = true -- ENABLE BODY STATUS FUNCTION AND UI?
config.checkbodycommandjob = 'ambulance' -- allowed jobs to use the bodysystem treatment
config.damageadd = 1 -- HOW MUCH THE VALUE WE WANT TO SAVE TO DATABASE FOR EACH DAMAGE RECEIVE?
config.weaponsonly = false -- Body Status Damages applies from weapons only? eg. pistol,etc anything with bullets. else it all applies to weapons,bullets, melee combat, falling in high grounds like posts,ram by a car etc..
config.bodystatuswait = 1000 -- how fast (in ms) we need to check if player is already taken a damage? -- deprecated?
config.headtimecycle = 'RaceTurboLight' -- timecycle effect when player head is injured
config.legeffectmovement = 0.73 -- movement speed modifier if player leg is injured ( 1.0 = 100%)
config.legeffect_disabledjump = true -- disable jump while leg is in pain
config.thirdperson_armrecoil = '0.4' -- recoil effect when player arm is injured (third person)
config.firstperson_armrecoil = '0.5' -- recoil effect when player arm is injured (first person)
config.chesteffect_healthdegrade = 1 -- reduce player health every 5 sec
config.chesteffect_minhealth = 40 -- minimum health to maintain during chest injury. 40 points = 40% (some rp server)
config.disabledregen = true -- disable health regen while chest is in pain
config.disabledsprint = true -- disable sprint while chest is in pain
config.bodyinjury_status_affected = true
config.headbone_status = 'sanity' -- Each time the Player Head Bone is damaged, status should be affected? , Select a status name: eg. stress, sanity, etc. poop!
config.headbone_status_mode = 'add' -- should we add or remove? (remove/add)
config.headbone_status_value = 1000 -- value to add or remove
config.armdamage_invehicle_effect = 1.0 -- If Arm is in injury, Steering lock is reduce? its like the player will be having a hardtime of steering the vehicle wheel.
config.melee_decrease_damage = true -- decrease damage of melee attacks if arm is injured
config.melee_damage_decrease = 0.1 -- float value, 1.0 = 100%
config.enablehealcommand = true -- heal commands (standalone) example: /bodyheal head ( you can put head, chest, leg, arm)
config.enableitems = true -- FRAMEWORK NEEDED ESX For Now ( Items for such a healing bandage to cure the body injuries )
config.healtype = {
    ['chest'] = {"ped_body"},
    ['leg'] = {"left_leg","right_leg"},
    ['head'] = {"ped_head"},
    ['arm'] = {"right_hand","left_hand"}
}

-- do not edit (LINK https://gtaforums.com/topic/801074-list-of-entity-bone-index-hashes/) and LINK https://wiki.gtanet.work/index.php?title=Bones
config.buto={["ped_body"]={SKEL_Pelvis1=0xD003,SKEL_PelvisRoot=0x45FC,SKEL_SADDLE=0x9524,SKEL_ROOT=0x0,SKEL_Pelvis=0x2E28,SKEL_Spine_Root=0xE0FD,SM_M_BackSkirtRoll=0xDBB,SM_M_FrontSkirtRoll=0xCDBB,SM_CockNBalls_ROOT=0xC67D,SM_CockNBalls=0x9D34,BagRoot=0xAD09,BagPivotROOT=0xB836,BagPivot=0x4D11,SKEL_Spine0=0x5C01,SKEL_Spine1=0x60F0,SKEL_Spine2=0x60F1,SKEL_Spine3=0x60F2,SPR_L_Breast=0xFC8E,SPR_R_Breast=0x885F,IK_Root=0xDD1C,SM_LifeSaver_Front=0x9420,SM_R_Pouches_ROOT=0x2962,SM_R_Pouches=0x4141,SM_L_Pouches_ROOT=0x2A02,SM_L_Pouches=0x4B41,SM_Suit_Back_Flapper=0xDA2D,SPR_CopRadio=0x8245,SM_LifeSaver_Back=0x2127,BagBody=0xAB6D,BagBone_R=0x937,BagBone_L=0x991,MH_BlushSlider=0xA0CE,SKEL_Tail_01=0x347,SKEL_Tail_02=0x348,MH_L_Concertina_B=0xC988,SKEL_Tail_04=0x34A,SKEL_Tail_05=0x34B,SPR_Gonads_ROOT=0xBFDE,SPR_Gonads=0x1C00,MH_L_Concertina_A=0xC987,MH_R_Concertina_B=0xC8E8,MH_R_Concertina_A=0xC8E7,SKEL_Tail_03=0x349},["ped_head"]={SKEL_Neck_1=0x9995,SKEL_Head=0x796E,FACIAL_facialRoot=0xFE2C,FB_L_Brow_Out_000=0xE3DB,FB_L_Lid_Upper_000=0xB2B6,FB_R_Eye_000=0x6B52,FB_R_CheekBone_000=0x4B88,FB_R_Brow_Out_000=0x54C,IK_Head=0x322C,FB_L_Eye_000=0x62AC,FB_Tongue_000=0xB987,RB_Neck_1=0x8B93,SKEL_Neck_2=0x5FD4,FACIAL_jaw=0xB21,FACIAL_underChin=0x8A95,FB_L_CheekBone_000=0x542E,FB_L_Lip_Corner_000=0x74AC,FB_R_Lid_Upper_000=0xAA10,FB_R_Lip_Corner_000=0x2BA6,FB_R_Lip_Top_000=0x4537,FB_Jaw_000=0xB4A0,FACIAL_L_tongueD=0x35F1,FACIAL_R_tongueD=0x2FF1,FACIAL_L_tongueC=0x35F0,FACIAL_R_tongueC=0x2FF0,FACIAL_L_tongueB=0x35EF,FACIAL_R_tongueB=0x2FEF,FACIAL_R_tongueA=0x2FEE,FACIAL_chinSkinTop=0x7226,FACIAL_L_chinSkinTop=0x3EB3,FACIAL_chinSkinMid=0x899A,FACIAL_L_chinSkinMid=0x4427,FB_Brow_Centre_000=0x9149,FB_UpperLipRoot_000=0x4ED2,FB_UpperLip_000=0xF18F,FB_L_Lip_Top_000=0x4F37,FB_LowerLipRoot_000=0x4324,FB_LowerLip_000=0x508F,FACIAL_tongueA=0x4A7C,FACIAL_tongueB=0x4A7D,FACIAL_tongueC=0x4A7E,FACIAL_tongueD=0x4A7F,FB_L_Lip_Bot_000=0xB93B,FB_R_Lip_Bot_000=0xC33B,FACIAL_L_underChin=0x234E,FACIAL_chin=0xB578,FACIAL_chinSkinBottom=0x98BC,FACIAL_L_chinSkinBottom=0x3E8F,FACIAL_R_chinSkinBottom=0x9E8F,FACIAL_tongueE=0x4A80,FACIAL_L_tongueE=0x35F2,FACIAL_R_tongueE=0x2FF2,FACIAL_L_tongueA=0x35EE,FACIAL_L_chinSide=0x4A5E,FACIAL_R_chinSkinMid=0xF5AF,FACIAL_R_chinSkinTop=0xF03B,FACIAL_R_chinSide=0xAA5E,FACIAL_R_underChin=0x2BF4,FACIAL_L_lipLowerSDK=0xB9E1,FACIAL_L_lipLowerAnalog=0x244A,FACIAL_L_lipLowerThicknessV=0xC749,FACIAL_L_lipLowerThicknessH=0xC67B,FACIAL_R_lipLowerSDK=0xA034,FACIAL_R_lipLowerAnalog=0xC2D9,FACIAL_R_lipLowerThicknessV=0xC6E9,FACIAL_R_lipLowerThicknessH=0xC6DB,FACIAL_nose=0x20F1,FACIAL_L_nostril=0x7322,FACIAL_L_nostrilThickness=0xC15F,FACIAL_noseLower=0xE05A,FACIAL_L_noseLowerThickness=0x79D5,FACIAL_R_noseLowerThickness=0x7975,FACIAL_noseTip=0x6A60,FACIAL_R_nostril=0x7922,FACIAL_lipLowerSDK=0x7285,FACIAL_lipLowerAnalog=0xD97B,FACIAL_lipLowerThicknessV=0xC5BB,FACIAL_lipLowerThicknessH=0xC5ED,FACIAL_R_cheekLowerBulge1=0x599B,FACIAL_R_cheekLowerBulge2=0x599C,FACIAL_R_masseter=0x810,FACIAL_R_jawRecess=0x93D4,FACIAL_R_ear=0x1137,FACIAL_R_earLower=0x8031,FACIAL_R_nostrilThickness=0x36FF,FACIAL_noseUpper=0xA04F,FACIAL_L_noseUpper=0x1FB8,FACIAL_noseBridge=0x9BA3,FACIAL_L_nasolabialFurrow=0x5ACA,FACIAL_L_nasolabialBulge=0xCD78,FACIAL_L_eyeball=0x1744,FACIAL_L_eyelidLower=0x998C,FACIAL_L_eyelidLowerOuterSDK=0xFE4C,FACIAL_L_eyelidLowerOuterAnalog=0xB9AA,FACIAL_L_eyelashLowerOuter=0xD7F6,FACIAL_L_eyelidLowerInnerSDK=0xF151,FACIAL_L_eyelidLowerInnerAnalog=0x8242,FACIAL_L_eyelashLowerInner=0x4CCF,FACIAL_L_eyelidUpper=0x97C1,FB_TongueC_000=0x4208,FB_L_Brow_Out_001=0xE3DB,FB_L_Lid_Upper_001=0xB2B6,MH_MulletRoot=0x3E73,MH_MulletScaler=0xA1C2,MH_Hair_Scale=0xC664,MH_Hair_Crown=0x1675,FB_L_Eye_001=0x62AC,FACIAL_L_eyelidUpperOuterSDK=0xAF15,FACIAL_L_eyelidUpperOuterAnalog=0x67FA,FACIAL_L_eyelashUpperOuter=0x27B7,FACIAL_L_cheekLower=0x6907,FACIAL_L_cheekLowerBulge1=0xE3FB,FACIAL_L_cheekLowerBulge2=0xE3FC,FACIAL_L_cheekInner=0xE7AB,FACIAL_L_cheekOuter=0x8161,FACIAL_L_eyesackLower=0x771B,FACIAL_L_eyelidUpperInnerSDK=0xD341,FACIAL_L_eyelidUpperInnerAnalog=0xF092,FACIAL_L_eyelashUpperInner=0x9B1F,FACIAL_L_eyesackUpperOuterBulge=0xA559,FACIAL_L_foreheadInnerBulge=0x767C,FACIAL_L_foreheadOuter=0x8DCB,FACIAL_skull=0x4221,FACIAL_foreheadUpper=0xF7D6,FACIAL_L_foreheadUpperInner=0xCF13,FACIAL_L_foreheadUpperOuter=0x509B,FACIAL_R_foreheadUpperInner=0xCEF3,FACIAL_R_foreheadUpperOuter=0x507B,FACIAL_L_temple=0xAF79,FACIAL_L_ear=0x19DD,FACIAL_L_earLower=0x6031,FACIAL_L_masseter=0x2810,FACIAL_L_jawRecess=0x9C7A,FACIAL_L_eyesackUpperInnerBulge=0x2F2A,FACIAL_L_eyesackUpperOuterFurrow=0xC597,FACIAL_L_eyesackUpperInnerFurrow=0x52A7,FACIAL_forehead=0x9218,FACIAL_L_foreheadInner=0x843,FACIAL_L_cheekOuterSkin=0x14A5,FACIAL_R_cheekLower=0xF367,FACIAL_R_eyesackLower=0x777B,FACIAL_R_nasolabialBulge=0xD61E,FACIAL_R_cheekOuter=0xD32,FACIAL_R_cheekInner=0x737C,FACIAL_R_noseUpper=0x1CD6,FACIAL_R_foreheadInner=0xE43,FACIAL_R_foreheadInnerBulge=0x769C,FACIAL_R_foreheadOuter=0x8FCB,FACIAL_R_cheekOuterSkin=0xB334,FACIAL_R_eyesackUpperInnerFurrow=0x9FAE,FACIAL_R_eyesackUpperOuterFurrow=0x140F,FACIAL_R_eyesackUpperInnerBulge=0xA359,FACIAL_R_eyesackUpperOuterBulge=0x1AF9,FACIAL_R_nasolabialFurrow=0x2CAA,FACIAL_R_temple=0xAF19,FACIAL_R_eyeball=0x1944,FACIAL_R_eyelidUpper=0x7E14,FACIAL_R_eyelidUpperOuterSDK=0xB115,FACIAL_R_eyelidUpperOuterAnalog=0xF25A,FACIAL_R_eyelashUpperOuter=0xE0A,FACIAL_R_eyelidLowerInnerAnalog=0xE13,FACIAL_R_eyelashLowerInner=0x3322,FACIAL_L_lipUpperSDK=0x8F30,FACIAL_L_lipUpperAnalog=0xB1CF,FACIAL_L_lipUpperThicknessH=0x37CE,FACIAL_L_lipUpperThicknessV=0x38BC,FACIAL_lipUpperSDK=0x1774,FACIAL_lipUpperAnalog=0xE064,FACIAL_lipUpperThicknessH=0x7993,FACIAL_lipUpperThicknessV=0x7981,FACIAL_L_lipCornerSDK=0xB1C,FACIAL_L_lipCornerAnalog=0xE568,FACIAL_L_lipCornerThicknessUpper=0x7BC,FACIAL_L_lipCornerThicknessLower=0xDD42,FACIAL_R_lipUpperSDK=0x7583,FACIAL_R_eyelidUpperInnerSDK=0xD541,FACIAL_R_eyelidUpperInnerAnalog=0x7C63,FACIAL_R_eyelashUpperInner=0x8172,FACIAL_R_eyelidLower=0x7FDF,FACIAL_R_eyelidLowerOuterSDK=0x1BD,FACIAL_R_eyelidLowerOuterAnalog=0x457B,FACIAL_R_eyelashLowerOuter=0xBE49,FACIAL_R_eyelidLowerInnerSDK=0xF351,FACIAL_R_lipUpperAnalog=0x51CF,FACIAL_R_lipUpperThicknessH=0x382E,FACIAL_R_lipUpperThicknessV=0x385C,FACIAL_R_lipCornerSDK=0xB3C,FACIAL_R_lipCornerAnalog=0xEE0E,FACIAL_R_lipCornerThicknessUpper=0x54C3,FACIAL_R_lipCornerThicknessLower=0x2BBA,FB_R_Ear_000=0x6CDF,SPR_R_Ear=0x63B6,FB_L_Ear_000=0x6439,SPR_L_Ear=0x5B10,FB_TongueA_000=0x4206,FB_TongueB_000=0x4207,FB_L_CheekBone_001=0x542E,FB_L_Lip_Corner_001=0x74AC,FB_R_Lid_Upper_001=0xAA10,FB_R_Eye_001=0x6B52,FB_L_Lip_Top_001=0x4F37,FB_R_Lip_Top_001=0x4537,FB_Jaw_001=0xB4A0,FB_LowerLipRoot_001=0x4324,FB_LowerLip_001=0x508F,FB_L_Lip_Bot_001=0xB93B,FB_R_Lip_Bot_001=0xC33B,FB_R_CheekBone_001=0x4B88,FB_R_Brow_Out_001=0x54C,FB_R_Lip_Corner_001=0x2BA6,FB_Brow_Centre_001=0x9149,FB_UpperLipRoot_001=0x4ED2,FB_UpperLip_001=0xF18F,FB_Tongue_001=0xB987},["left_hand"]={SKEL_L_Clavicle=0xFCD9,SKEL_L_Hand=0x49D9,SKEL_L_Finger12=0x104A,SKEL_L_Finger20=0x67F4,SKEL_L_Finger21=0x1059,SKEL_L_UpperArm=0xB1C5,SKEL_L_Forearm=0xEEEB,SKEL_L_Finger22=0x105A,SKEL_L_Finger30=0x67F5,MH_L_Elbow=0x58B7,MH_L_Finger00=0x8C63,MH_L_FingerBulge00=0x5FB8,MH_L_Finger10=0x8C53,MH_L_FingerTop00=0xA244,MH_L_HandSide=0xC78A,SKEL_L_Finger00=0x67F2,SKEL_L_Finger01=0xFF9,SKEL_L_Finger02=0xFFA,SKEL_L_Finger10=0x67F3,SKEL_L_Finger11=0x1049,SKEL_L_Finger31=0x1029,PH_L_Hand=0xEB95,IK_L_Hand=0x8CBD,RB_L_ForeArmRoll=0xEE4F,RB_L_ArmRoll=0x1470,SKEL_L_Finger32=0x102A,SKEL_L_Finger40=0x67F6,SKEL_L_Finger41=0x1039,SKEL_L_Finger42=0x103A,MH_Watch=0x2738,MH_L_Sleeve=0x933C},["left_leg"]={SKEL_L_Thigh=0xE39F,SKEL_L_Calf=0xF9BB,MH_L_ThighBack=0x600D,SM_L_Skirt=0xC419,SM_L_BackSkirtRoll=0x40B2,SM_L_FrontSkirtRoll=0x9B69,SKEL_L_Toe1=0x1D6B,SKEL_L_Foot=0x3779,PH_L_Foot=0xE175,MH_L_Knee=0xB3FE,RB_L_ThighRoll=0x5C57,MH_L_CalfBack=0x1013,SKEL_L_Toe0=0x83C,EO_L_Foot=0x84C5,EO_L_Toe=0x68BD,IK_L_Foot=0xFEDD},["right_leg"]={SKEL_R_Thigh=0xCA72,EO_R_Toe=0x7163,IK_R_Foot=0x8AAE,PH_R_Foot=0x60E6,SKEL_R_Toe0=0x512D,EO_R_Foot=0x1096,SM_R_BackSkirtRoll=0xC141,SM_R_FrontSkirtRoll=0x86F1,SKEL_R_Toe1=0xB23F,MH_R_Knee=0x3FCF,SKEL_R_Calf=0x9000,SKEL_R_Foot=0xCC4D,RB_R_ThighRoll=0x192A,MH_R_CalfBack=0xB013,MH_R_ThighBack=0x51A3,SM_R_Skirt=0x7712},["right_hand"]={SKEL_R_UpperArm=0x9D4D,SKEL_R_Hand=0xDEAD,SKEL_R_Finger00=0xE5F2,SKEL_R_Finger01=0xFA10,SKEL_R_Clavicle=0x29D2,SKEL_R_Forearm=0x6E5C,SKEL_R_Finger02=0xFA11,SKEL_R_Finger31=0xFA40,MH_R_ShoulderBladeRoot=0x3A0A,MH_R_ShoulderBlade=0x54AF,SKEL_R_Finger40=0xE5F6,SKEL_R_Finger41=0xFA50,SKEL_R_Finger42=0xFA51,SKEL_R_Finger10=0xE5F3,SKEL_R_Finger32=0xFA41,MH_R_HandSide=0x68FB,MH_R_Sleeve=0x92DC,SM_Torch=0x8D6,FX_Light=0x8959,FX_Light_Scale=0x5038,FX_Light_Switch=0xE18E,SKEL_R_Finger22=0xFA71,SKEL_R_Finger30=0xE5F5,PH_R_Hand=0x6F06,IK_R_Hand=0x188E,RB_R_ForeArmRoll=0xAB22,RB_R_ArmRoll=0x90FF,MH_R_Elbow=0xBB0,MH_R_FingerTop00=0xEF4B,MH_L_ShoulderBladeRoot=0x8711,MH_L_ShoulderBlade=0x4EAF,MH_R_Finger00=0x2C63,MH_R_FingerBulge00=0x69B8,MH_R_Finger10=0x2C53,SKEL_R_Finger11=0xFA60,SKEL_R_Finger12=0xFA61,SKEL_R_Finger20=0xE5F4,SKEL_R_Finger21=0xFA70}}

--WEAPON UI
config.weaponsui = true -- enable weapon ui
config.crosshairenable = true -- enable custom crosshair
config.crosshair = 1 -- index number of custom crosshair ( 1-5 )
config.ammoupdatedelay = 300 -- delay update for bullets ui
--WEAPONTABLE do not edit this (only if you will add new weapons)
-- do not edit! unless your gonna add new weapons ( HASHES SOURCE LINK https://wiki.rage.mp/index.php?title=Weapons)
config.WeaponTable={melee={dagger="0x92A27487",bat="0x958A4A8F",bottle="0xF9E6AA4B",crowbar="0x84BD7BFD",unarmed="0xA2719263",flashlight="0x8BB05FD7",golfclub="0x440E4788",hammer="0x4E875F73",hatchet="0xF9DCBF2D",knuckle="0xD8DF3C3C",knife="0x99B507EA",machete="0xDD5DF8D9",switchblade="0xDFE37640",nightstick="0x678B81B1",wrench="0x19044EE0",battleaxe="0xCD274149",poolcue="0x94117305",stone_hatchet="0x3813FC08"},handguns={pistol="0x1B06D571",pistol_mk2="0xBFE256D4",combatpistol="0x5EF9FEC4",appistol="0x22D8FE39",stungun="0x3656C8C1",pistol50="0x99AEEB3B",snspistol="0xBFD21232",snspistol_mk2="0x88374054",heavypistol="0xD205520E",vintagepistol="0x83839C4",flaregun="0x47757124",marksmanpistol="0xDC4DB296",revolver="0xC1B3C3D1",revolver_mk2="0xCB96392F",doubleaction="0x97EA20B8",raypistol="0xAF3696A1",ceramicpistol="0x2B5EF5EC",navyrevolver="0x917F6C8C"},smg={microsmg="0x13532244",smg="0x2BE6766B",smg_mk2="0x78A97CD0",assaultsmg="0xEFE7E2DF",combatpdw="0xA3D4D34",machinepistol="0xDB1AA450",minismg="0xBD248B55",raycarbine="0x476BF155"},shotguns={pumpshotgun="0x1D073A89",pumpshotgun_mk2="0x555AF99A",sawnoffshotgun="0x7846A318",assaultshotgun="0xE284C527",bullpupshotgun="0x9D61E50F",musket="0xA89CB99E",heavyshotgun="0x3AABBBAA",dbshotgun="0xEF951FBB",autoshotgun="0x12E82D3D"},assault_rifles={assaultrifle="0xBFEFFF6D",assaultrifle_mk2="0x394F415C",carbinerifle="0x83BF0278",carbinerifle_mk2="0xFAD1F1C9",advancedrifle="0xAF113F99",specialcarbine="0xC0A3098D",specialcarbine_mk2="0x969C3D67",bullpuprifle="0x7F229F94",bullpuprifle_mk2="0x84D6FAFD",compactrifle="0x624FE830"},machine_guns={mg="0x9D07F764",combatmg="0x7FD62962",combatmg_mk2="0xDBBD7280",gusenberg="0x61012683"},sniper_rifles={sniperrifle="0x5FC3C11",heavysniper="0xC472FE2",heavysniper_mk2="0xA914799",marksmanrifle="0xC734385A",marksmanrifle_mk2="0x6A6C02E0"},heavy_weapons={rpg="0xB1CA77B1",grenadelauncher="0xA284510B",grenadelauncher_smoke="0x4DD2DC56",minigun="0x42BF8A85",firework="0x7F7497E5",railgun="0x6D544C99",hominglauncher="0x63AB0442",compactlauncher="0x781FE4A",rayminigun="0xB62D1F67"},throwables={grenade="0x93E220BD",bzgas="0xA0973D5E",smokegrenade="0xFDBC8A50",flare="0x497FACC3",molotov="0x24B17070",stickybomb="0x2C3731D9",proxmine="0xAB564B93",snowball="0x787F0BB",pipebomb="0xBA45E8B8",ball="0x23C9F95C"},misc={petrolcan="0x34A67B97",fireextinguisher="0x60EC506",parachute="0xFBAB5776",hazardcan="0xBA536372"}}
--CUSTOM FUEL SYSTEM (YOU NEED TO DISABLE Your Other Vehicle Fuel management to make this work specially for the ECO Mode,turbo fuel cost, mileage system)
--you can use my fork legacyfuel (https://github.com/renzuzu/renzu_fuel) this is NUI based, and its have a gas station coords,blips,fueling function and option to disabled fuel management (so we can use our own fuel management here)
config.usecustomfuel = true -- needed if you want to use ECO and Sports Mode Fuel Cost Effect
config.fueldecor = "_FUEL_LEVEL"
config.mileage_affect_gasusage = true -- affect fuel usage
config.turbo_boost_usage = true -- Turbo Boost Affect Usage? same formula with sports mode, but this is permanent if turbo is installed.
config.boost_min_level_usage = 1.1 -- minimum boost level to affect the gas usage

config.classes = {
	--change the value example 0.6, the greater the value the greater fuel consumption
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
	--UP TO 1.4 YES some vehicle overev to 1.4 level.
	-- change the value if need to change the main fuel consumption system
	-- the greater the value the greater consumption
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

config.enablecarcontrol = true -- car functions
config.allowoutsideofvehicle = true -- allow car control outside of vehicle (nearest vehicle and lastvehicle)
config.enableairsuspension = true -- adjustable vehicle height
config.airsuspension_item = true -- if true airsuspension func will not work if its not installed
config.enableneontoggle = true -- toggable neon lights
config.wheelstancer = true -- allow players to adjust the wheelxoffset and wheelyrotation
--NITRO
config.enablenitro = true
config.nitro_sound = true -- enable sound on nitro | default: true
config.nitrocost = 0.05 -- value to deduct per frame
config.nitroboost = 15.0 -- x15 torque
config.maxnitro = 100 -- maximum value of nitro, greater than 100 might break the nitro bar.
config.exhaust_bones = {
	"exhaust",
	"exhaust_2",
} 

config.tailights_bone = {
	"taillight_l",
	"taillight_r",
	--"taillight_m",
}
config.nitroasset = "core"

config.exhaust_particle_name = "veh_backfire" -- particle name | default: "veh_backfire"
config.trail_particle_name = "veh_light_red_trail"
config.exhaust_flame_size = 1.3
config.trail_size = 1.00
config.bannedindex = -1
config.purge_left_bone = "wheel_lf"
config.purge_right_bone = "wheel_rf"
config.purge_size = 1.0
config.purge_paticle_name = "ent_sht_steam" -- particle name | default: "ent_sht_steam"

--WHEELSYSTEM
config.enabletiresystem = true -- Enable Tire System, Custom Tire Health System, Saved in DB, Sync all to player, using adv_stat table in database
config.tirebrandnewhealth = 1000 -- health of a brand new tires, this is not the vehicle health tires from GTA NATIVE!
config.tirewear = 1 -- wear value every 100 radius
config.tirestress = 2 -- wear value everytime you stress your tire, using burnouts, curving with high speed etc...
config.bursttires = true -- burst any wear tires if health is <=0 ( GTA NATIVE WHEEL HEALTH )
config.reducetraction = true -- reduce traction during the wear mode (WEAR mode = if tire brandnew health is <= 0)
config.minrpm_wheelspin_detect = 0.7 -- minimum rpm to detect stress tires
config.minspeed_curving = 15 -- minimum speed for curving to apply stress tires (speed is in meters not kmh or mph) 15 * 3.6 = kmh
config.minimum_angle_for_curving = 2 -- minimum angle of vehicle to detect if its drifting, sharp curving a corner. greater than 2 might not detect sharp cornering.
config.wearspeedmultiplier = true -- Current Speed affect total value of tirewear.
config.curveloss = 0.7 -- 0.7 = 70%, 1.0 = 100% - Reduce Traction of Wheels Steering Control ( This will affect Cornering )
config.acceleratetractionloss = 0.5 -- 0.5 = 50%, 1.0 = 100% - Reduce the total traction of accelerating vehicle
config.repairalltires = true -- repair all tires using the command or item else Repair the tires one by one.
config.repaircommand = true -- (/yourcommand (racing,sports,default)), Enable Repair Command for standalone purpose, disable this if repairing via item.
-- FAQ - GTA WHEEL HEALTH IS GETTING REDUCE if Brand New Health is <= 0, so a total of 2000 health for each tires, combine with brandnewhealth + gta wheel health.
config.wheeltype = { -- edit this only if you are familiar with handling.meta , 1.0 = 100% - (THIS IS NOT 100% PERFECT you can tuned it)
    ['sports'] = {fLowSpeedTractionLossMult = 0.9,fTractionLossMult = 0.9,fTractionCurveMin = 1.1, fTractionCurveMax = 1.1, fTractionCurveLateral = 1.1},
    ['racing'] = {fLowSpeedTractionLossMult = 0.7,fTractionLossMult = 0.7,fTractionCurveMin = 1.25, fTractionCurveMax = 1.3, fTractionCurveLateral = 1.2},
    ['drag'] = {fLowSpeedTractionLossMult = 0.1,fTractionLossMult = 0.1,fTractionCurveMin = 2.2, fTractionCurveMax = 0.1, fTractionCurveLateral = 1.1},
}
--CARLOCK
config.carlock = true -- Enable Car Keyless System -- using owned_vehicles table from mysql, fetch owner as identifier.
config.carlock_distance = 20 -- max distance to fetch the sorrounding vehicles
config.enable_carjacking = true -- if true, pressing the Keybind for carlock when no owned vehicle in distanced the carjacking function will be used instead, with minigame from cd_keymaster resource ( DEPENDENCY )
config.carjackdistance = 5
-- you need to install cd_keymaster if you enable carjacking (my version: same func but theme color is similar to this hud https://github.com/renzuzu/cd_keymaster or default original https://github.com/dsheedes/cd_keymaster)

--clothes
config.use_esx_accesories = true -- use esx accesories for mask,helmet. (ESX FRAMEWORK)
-- PERMANENT HELMET AND MASK
-- this is optional only if you want the mask and helmet to be permanent instead of using your clothes settings, ex. wearing a cap, but you want/need a helmet soon.
-- using this https://github.com/esx-framework/esx_accessories ( saving to datastore instead from skinchanger table) -- rights belong to esx framework
-- we are using this function https://github.com/esx-framework/esx_accessories/blob/e812dde63bcb746e9b49bad704a9c9174d6329fa/client/main.lua#L30

-- configuration of animations ,variations, defaults when using Clothing UI
config.clothing = {
	--left
	['helmet_1'] = { -- parts
		['skin'] = {
			['helmet_1'] = -1, ['helmet_2'] = 0 -- variation type
		},
		['default'] = -1, -- the default variation
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800} -- animation settings
	},
	['helmet_2'] = {},
	['glasses_1'] = {
		['skin'] = {
			['glasses_1'] = 0, ['glasses_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
	['glasses_2'] = {},
	['chain_1'] = {
		['skin'] = {
			['chain_1'] = 0, ['chain_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
	['chain_1'] = {},
	['watches_1'] = {
		['skin'] = {
			['watches_1'] = -1, ['watches_2'] = 0
		},
		['default'] = -1,
		['taskplay'] = {dictionary = "nmt_3_rcm-10", name = "cs_nigel_dual-10", speed = 51, duration = 1200}
	},
	['watches_2'] = {},
	--right
	['torso_1'] = {
		['skin'] = {
			['torso_1'] = 15, ['torso_2'] = 0,
			['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['torso_2'] = {},
	['tshirt_1'] = {
		['skin'] = {
			['tshirt_1'] = 15, ['tshirt_2'] = 0,
			['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['tshirt_2'] = {},
	['bproof_1'] = {
		['skin'] = {
			['bproof_1'] = 0, ['bproof_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
	['bproof_2'] = {},
	['pants_1'] = {
		['skin'] = {
			['pants_1'] = 14, ['pants_2'] = 0
		},
		['default'] = 14,
		['taskplay'] = {dictionary = "re@construction", name = "out_of_breath", speed = 51, duration = 800}
	},
	['shoes_1'] = {
		['skin'] = {
			['shoes_1'] = 49, ['shoes_2'] = 0
		},
		['default'] = 49,
		['taskplay'] = {dictionary = "random@domestic", name = "pickup_low", speed = 51, duration = 1200}
	},
	['shoes_2'] = {},
	--top
	['mask_1'] = {
		['skin'] = {
			['mask_1'] = 0, ['mask_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
	['mask_2'] = {},
	--reset 
	['reset'] = {
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	}
}

--carstatus
config.carstatus = true -- use car status system, shows vehicle infos etc..
config.carstatus_jobonly = false -- allowed the car status ui only to designated jobs
config.carstatus_job = 'mechanic'

--ENGINE SYSTEM
config.customengine = true -- enable/disable custom vehicle engine, custom sounds
config.enable_commands = true -- standalone purpose. usage: /installengine engine_blista ( you must be near on vehicle hood/engine location )
-- commands permmision is located at config.commanditem_permission
config.enable_engine_prop = true -- use engine stand and engine prop while installing engine.
config.engine_dis = 2.5 -- distance to engine for allowing engine installation
config.engine_jobonly = true -- designated jobs only
config.engine_job = 'mechanic' -- Allowed Jobs ESX
config.enable_engine_item = true -- ESX only for now.. advisable to use esx v1 final, to use users table item json type instead of item inventory table list type, this function will insert all vehicle models from gta up to mpheist4. ( the old esx is not optimize on item functions, the user item is saved on item_inventory something and its a table list type, if you dont know what i am talking about use the commands only.)
config.weight = 5.0 -- engine weight of item ( this must be configured first before runnning the script or else you have to change the weight manually from mysql )
config.engine = { ['adder'] = 3078201489, ['airbus'] = 1283517198, ['airtug'] = 1560980623, ['akula'] = 1181327175, ['akuma'] = 1672195559, ['alpha'] = 767087018, ['alphaz1'] = 2771347558, ['alkonost'] = 3929093893, ['ambulance'] = 1171614426, ['annihilator2'] = 295054921, ['annihilator'] = 837858166, ['apc'] = 562680400, ['ardent'] = 159274291, ['armytanker'] = 3087536137, ['armytrailer2'] = 2657817814, ['armytrailer'] = 2818520053, ['asbo'] = 1118611807, ['asea2'] = 2487343317, ['asea'] = 2485144969, ['asterope'] = 2391954683, ['autarch'] = 3981782132, ['avarus'] = 2179174271, ['avenger2'] = 408970549, ['avenger'] = 2176659152, ['avisa'] = 2588363614, ['bagger'] = 2154536131, ['baletrailer'] = 3895125590, ['baller2'] = 142944341, ['baller3'] = 1878062887, ['baller4'] = 634118882, ['baller5'] = 470404958, ['baller6'] = 666166960, ['baller'] = 3486135912, ['banshee2'] = 633712403, ['banshee'] = 3253274834, ['barracks2'] = 1074326203, ['barracks3'] = 630371791, ['barracks'] = 3471458123, ['barrage'] = 4081974053, ['bati2'] = 3403504941, ['bati'] = 4180675781, ['benson'] = 2053223216, ['besra'] = 1824333165, ['bestiagts'] = 1274868363, ['bf400'] = 86520421, ['bfinjection'] = 1126868326, ['biff'] = 850991848, ['bifta'] = 3945366167, ['bison2'] = 2072156101, ['bison3'] = 1739845664, ['bison'] = 4278019151, ['bjxl'] = 850565707, ['blade'] = 3089165662, ['blazer2'] = 4246935337, ['blazer3'] = 3025077634, ['blazer4'] = 3854198872, ['blazer5'] = 2704629607, ['blazer'] = 2166734073, ['blimp2'] = 3681241380, ['blimp3'] = 3987008919, ['blimp'] = 4143991942, ['blista2'] = 1039032026, ['blista3'] = 3703315515, ['blista'] = 3950024287, ['bmx'] = 1131912276, ['boattrailer'] = 524108981, ['bobcatxl'] = 1069929536, ['bodhi2'] = 2859047862, ['bombushka'] = 4262088844, ['boxville2'] = 4061868990, ['boxville3'] = 121658888, ['boxville4'] = 444171386, ['boxville5'] = 682434785, ['boxville'] = 2307837162, ['brawler'] = 2815302597, ['brickade'] = 3989239879, ['brioso2'] = 1429622905, ['brioso'] = 1549126457, ['bruiser2'] = 2600885406, ['bruiser3'] = 2252616474, ['bruiser'] = 668439077, ['brutus2'] = 2403970600, ['brutus3'] = 2038858402, ['brutus'] = 2139203625, ['btype2'] = 3463132580, ['btype3'] = 3692679425, ['btype'] = 117401876, ['buccaneer2'] = 3281516360, ['buccaneer'] = 3612755468, ['buffalo2'] = 736902334, ['buffalo3'] = 237764926, ['buffalo'] = 3990165190, ['bulldozer'] = 1886712733, ['bullet'] = 2598821281, ['burrito2'] = 3387490166, ['burrito3'] = 2551651283, ['burrito4'] = 893081117, ['burrito5'] = 1132262048, ['burrito'] = 2948279460, ['bus'] = 3581397346, ['buzzard2'] = 745926877, ['buzzard'] = 788747387, ['cablecar'] = 3334677549, ['caddy2'] = 3757070668, ['caddy3'] = 3525819835, ['caddy'] = 1147287684, ['camper'] = 1876516712, ['calico'] = 3101054893, ['caracara2'] = 2945871676, ['caracara'] = 1254014755, ['carbonizzare'] = 2072687711, ['carbonrs'] = 11251904, ['cargobob2'] = 1621617168, ['cargobob3'] = 1394036463, ['cargobob4'] = 2025593404, ['cargobob'] = 4244420235, ['cargoplane'] = 368211810, ['casco'] = 941800958, ['cavalcade2'] = 3505073125, ['cavalcade'] = 2006918058, ['cerberus2'] = 679453769, ['cerberus3'] = 1909700336, ['cerberus'] = 3493417227, ['cheburek'] = 3306466016, ['cheetah2'] = 223240013, ['cheetah'] = 2983812512, ['chernobog'] = 3602674979, ['chimera'] = 6774487, ['chino2'] = 2933279331, ['chino'] = 349605904, ['cliffhanger'] = 390201602, ['clique'] = 2728360112, ['club'] = 2196012677, ['coach'] = 2222034228, ['cog552'] = 704435172, ['cog55'] = 906642318, ['cogcabrio'] = 330661258, ['cognoscenti2'] = 3690124666, ['cognoscenti'] = 2264796000, ['comet2'] = 3249425686, ['comet3'] = 2272483501, ['comet4'] = 1561920505, ['comet5'] = 661493923, ['comet6'] = 2568944644, ['contender'] = 683047626, ['coquette2'] = 1011753235, ['coquette3'] = 784565758, ['coquette4'] = 2566281822, ['coquette'] = 108773431, ['cruiser'] = 448402357, ['crusader'] = 321739290, ['cuban800'] = 3650256867, ['cutter'] = 3288047904, ['cyclone'] = 1392481335, ['cypher'] = 1755697647, ['daemon2'] = 2890830793, ['daemon'] = 2006142190, ['deathbike2'] = 2482017624, ['deathbike3'] = 2920466844, ['deathbike'] = 4267640610, ['defiler'] = 822018448, ['deluxo'] = 1483171323, ['deveste'] = 1591739866, ['deviant'] = 1279262537, ['diablous2'] = 1790834270, ['diablous'] = 4055125828, ['dilettante2'] = 1682114128, ['dilettante'] = 3164157193, ['dinghy2'] = 276773164, ['dinghy3'] = 509498602, ['dinghy4'] = 867467158, ['dinghy5'] = 3314393930, ['dinghy'] = 1033245328, ['dloader'] = 1770332643, ['docktrailer'] = 2154757102, ['docktug'] = 3410276810, ['dodo'] = 3393804037, ['dominator2'] = 3379262425, ['dominator3'] = 3308022675, ['dominator4'] = 3606777648, ['dominator5'] = 2919906639, ['dominator6'] = 3001042683, ['dominator7'] = 426742808, ['dominator8'] = 736672010, ['dominator'] = 80636076, ['double'] = 2623969160, ['drafter'] = 686471183, ['dubsta2'] = 3900892662, ['dubsta3'] = 3057713523, ['dubsta'] = 1177543287, ['dukes2'] = 3968823444, ['dukes3'] = 2134119907, ['dukes'] = 723973206, ['dump'] = 2164484578, ['dune2'] = 534258863, ['dune3'] = 1897744184, ['dune4'] = 3467805257, ['dune5'] = 3982671785, ['dune'] = 2633113103, ['duster'] = 970356638, ['dynasty'] = 310284501, ['elegy2'] = 3728579874, ['elegy'] = 196747873, ['ellie'] = 3027423925, ['emerus'] = 1323778901, ['emperor2'] = 2411965148, ['emperor3'] = 3053254478, ['emperor'] = 3609690755, ['enduro'] = 1753414259, ['entity2'] = 2174267100, ['entityxf'] = 3003014393, ['esskey'] = 2035069708, ['euros'] = 2038480341, ['everon'] = 2538945576, ['exemplar'] = 4289813342, ['f620'] = 3703357000, ['faction2'] = 2504420315, ['faction3'] = 2255212070, ['faction'] = 2175389151, ['fagaloa'] = 1617472902, ['faggio2'] = 55628203, ['faggio3'] = 3005788552, ['faggio'] = 2452219115, ['fbi2'] = 2647026068, ['fbi'] = 1127131465, ['fcr2'] = 3537231886, ['fcr'] = 627535535, ['felon2'] = 4205676014, ['felon'] = 3903372712, ['feltzer2'] = 2299640309, ['feltzer3'] = 2728226064, ['firetruk'] = 1938952078, ['fixter'] = 3458454463, ['flashgt'] = 3035832600, ['flatbed'] = 1353720154, ['fmj'] = 1426219628, ['forklift'] = 1491375716, ['formula2'] = 2334210311, ['formula'] = 340154634, ['fq2'] = 3157435195, ['freecrawler'] = 4240635011, ['freight'] = 1030400667, ['freightcar'] = 184361638, ['freightcar2'] = 3186376089, ['freightcont1'] = 920453016, ['freightcont2'] = 240201337, ['freightgrain'] = 642617954, ['freighttrailer'] = 3517691494, ['frogger2'] = 1949211328, ['frogger'] = 744705981, ['fugitive'] = 1909141499, ['furia'] = 960812448, ['furoregt'] = 3205927392, ['fusilade'] = 499169875, ['futo'] = 2016857647, ['futo2'] = 2787736776, ['gargoyle'] = 741090084, ['gauntlet2'] = 349315417, ['gauntlet3'] = 722226637, ['gauntlet4'] = 1934384720, ['gauntlet5'] = 2172320429, ['gauntlet'] = 2494797253, ['gb200'] = 1909189272, ['gburrito2'] = 296357396, ['gburrito'] = 2549763894, ['glendale2'] = 3381377750, ['glendale'] = 75131841, ['gp1'] = 1234311532, ['graintrailer'] = 1019737494, ['granger'] = 2519238556, ['gresley'] = 2751205197, ['growler'] = 1304459735, ['gt500'] = 2215179066, ['guardian'] = 2186977100, ['habanero'] = 884422927, ['hakuchou2'] = 4039289119, ['hakuchou'] = 1265391242, ['halftrack'] = 4262731174, ['handler'] = 444583674, ['hauler2'] = 387748548, ['hauler'] = 1518533038, ['havok'] = 2310691317, ['hellion'] = 3932816511, ['hermes'] = 15219735, ['hexer'] = 301427732, ['hotknife'] = 37348240, ['hotring'] = 1115909093, ['howard'] = 3287439187, ['hunter'] = 4252008158, ['huntley'] = 486987393, ['hustler'] = 600450546, ['hydra'] = 970385471, ['imorgon'] = 3162245632, ['impaler2'] = 1009171724, ['impaler3'] = 2370166601, ['impaler4'] = 2550461639, ['impaler'] = 3001042683, ['imperator2'] = 1637620610, ['imperator3'] = 3539435063, ['imperator'] = 444994115, ['infernus2'] = 2889029532, ['infernus'] = 418536135, ['ingot'] = 3005245074, ['innovation'] = 4135840458, ['insurgent2'] = 2071877360, ['insurgent3'] = 2370534026, ['insurgent'] = 2434067162, ['intruder'] = 886934177, ['issi2'] = 3117103977, ['issi3'] = 931280609, ['issi4'] = 628003514, ['issi5'] = 1537277726, ['issi6'] = 1239571361, ['issi7'] = 1854776567, ['italigtb2'] = 3812247419, ['italigtb'] = 2246633323, ['italigto'] = 3963499524, ['italirsx'] = 3145241962, ['jackal'] = 3670438162, ['jb7002'] = 394110044, ['jb700'] = 1051415893, ['jester4'] = 2712905841, ['jester2'] = 3188613414, ['jester3'] = 4080061290, ['jester'] = 2997294755, ['jet'] = 1058115860, ['jetmax'] = 861409633, ['journey'] = 4174679674, ['jugular'] = 4086055493, ['kalahari'] = 92612664, ['kamacho'] = 4173521127, ['kanjo'] = 409049982, ['khamelion'] = 544021352, ['khanjali'] = 2859440138, ['komoda'] = 3460613305, ['kosatka'] = 1336872304, ['krieger'] = 3630826055, ['kuruma2'] = 410882957, ['kuruma'] = 2922118804, ['landstalker2'] = 3456868130, ['landstalker'] = 1269098716, ['lazer'] = 3013282534, ['le7b'] = 3062131285, ['lectro'] = 640818791, ['lguard'] = 469291905, ['limo2'] = 4180339789, ['locust'] = 3353694737, ['longfin'] = 1861786828, ['lurcher'] = 2068293287, ['luxor2'] = 3080673438, ['luxor'] = 621481054, ['lynx'] = 482197771, ['mamba'] = 2634021974, ['mammatus'] = 2548391185, ['manana2'] = 1717532765, ['manana'] = 2170765704, ['manchez2'] = 1086534307, ['manchez'] = 2771538552, ['marquis'] = 3251507587, ['marshall'] = 1233534620, ['massacro2'] = 3663206819, ['massacro'] = 4152024626, ['maverick'] = 2634305738, ['menacer'] = 2044532910, ['mesa2'] = 3546958660, ['mesa3'] = 2230595153, ['mesa'] = 914654722, ['metrotrain'] = 868868440, ['michelli'] = 1046206681, ['microlight'] = 2531412055, ['miljet'] = 165154707, ['minitank'] = 3040635986, ['minivan2'] = 3168702960, ['minivan'] = 3984502180, ['mixer2'] = 475220373, ['mixer'] = 3510150843, ['mogul'] = 3545667823, ['molotok'] = 1565978651, ['monroe'] = 3861591579, ['monster3'] = 1721676810, ['monster4'] = 840387324, ['monster5'] = 3579220348, ['monster'] = 3449006043, ['moonbeam2'] = 1896491931, ['moonbeam'] = 525509695, ['mower'] = 1783355638, ['mule2'] = 3244501995, ['mule3'] = 2242229361, ['mule4'] = 1945374990, ['mule'] = 904750859, ['nebula'] = 3412338231, ['nexus'] = 3838718892, ['nemesis'] = 3660088182, ['neo'] = 2674840994, ['neon'] = 2445973230, ['nero2'] = 1093792632, ['nero'] = 1034187331, ['nightblade'] = 2688780135, ['nightshade'] = 2351681756, ['nightshark'] = 433954513, ['nimbus'] = 2999939664, ['ninef2'] = 2833484545, ['ninef'] = 1032823388, ['nokota'] = 1036591958, ['novak'] = 2465530446, ['omnis'] = 3517794615, ['openwheel1'] = 1492612435, ['openwheel2'] = 1181339704, ['oppressor2'] = 2069146067, ['oppressor'] = 884483972, ['oracle2'] = 3783366066, ['oracle'] = 1348744438, ['osiris'] = 1987142870, ['outlaw'] = 408825843, ['packer'] = 569305213, ['panto'] = 3863274624, ['paradise'] = 1488164764, ['paragon2'] = 1416466158, ['paragon'] = 3847255899, ['pariah'] = 867799010, ['patriot2'] = 3874056184, ['patriot'] = 3486509883, ['patrolboat'] = 4018222598, ['pbus2'] = 345756458, ['pbus'] = 2287941233, ['pcj'] = 3385765638, ['penetrator'] = 2536829930, ['penumbra2'] = 3663644634, ['penumbra'] = 3917501776, ['peyote2'] = 2490551588, ['peyote3'] = 1107404867, ['peyote'] = 1830407356, ['pfister811'] = 2465164804, ['phantom2'] = 2645431192, ['phantom3'] = 177270108, ['phantom'] = 2157618379, ['phoenix'] = 2199527893, ['picador'] = 1507916787, ['pigalle'] = 1078682497, ['police2'] = 2667966721, ['police3'] = 1912215274, ['police4'] = 2321795001, ['police'] = 2046537925, ['policeb'] = 4260343491, ['policeold1'] = 2758042359, ['policeold2'] = 2515846680, ['policet'] = 456714581, ['polmav'] = 353883353, ['pony2'] = 943752001, ['pony'] = 4175309224, ['pounder2'] = 1653666139, ['pounder'] = 2112052861, ['prairie'] = 2844316578, ['pranger'] = 741586030, ['predator'] = 3806844075, ['premier'] = 2411098011, ['previon'] = 1416471345, ['primo2'] = 2254540506, ['primo'] = 3144368207, ['proptrailer'] = 356391690, ['prototipo'] = 2123327359, ['pyro'] = 2908775872, ['radi'] = 2643899483, ['raiden'] = 2765724541, ['raketrailer'] = 390902130, ['rallytruck'] = 2191146052, ['rancherxl2'] = 1933662059, ['rancherxl'] = 1645267888, ['rapidgt2'] = 1737773231, ['rapidgt3'] = 2049897956, ['rapidgt'] = 2360515092, ['raptor'] = 3620039993, ['ratbike'] = 1873600305, ['ratloader2'] = 3705788919, ['ratloader'] = 3627815886, ['rcbandito'] = 4008920556, ['reaper'] = 234062309, ['rebel2'] = 2249373259, ['rebel'] = 3087195462, ['rebla'] = 83136452, ['regina'] = 4280472072, ['remus'] = 1377217886, ['rentalbus'] = 3196165219, ['retinue2'] = 2031587082, ['retinue'] = 1841130506, ['revolter'] = 3884762073, ['rhapsody'] = 841808271, ['rhino'] = 782665360, ['riata'] = 2762269779, ['riot2'] = 2601952180, ['riot'] = 3089277354, ['ripley'] = 3448987385, ['rocoto'] = 2136773105, ['rogue'] = 3319621991, ['romero'] = 627094268, ['rrocket'] = 916547552, ['rt3000'] = 3842363289, ['rubble'] = 2589662668, ['ruffian'] = 3401388520, ['ruiner2'] = 941494461, ['ruiner3'] = 777714999, ['ruiner'] = 4067225593, ['rumpo2'] = 2518351607, ['rumpo3'] = 1475773103, ['rumpo'] = 1162065741, ['ruston'] = 719660200, ['s80'] = 3970348707, ['sabregt2'] = 223258115, ['sabregt'] = 2609945748, ['sadler2'] = 734217681, ['sadler'] = 3695398481, ['sanchez2'] = 2841686334, ['sanchez'] = 788045382, ['sanctus'] = 1491277511, ['sandking2'] = 989381445, ['sandking'] = 3105951696, ['savage'] = 4212341271, ['savestra'] = 903794909, ['sc1'] = 1352136073, ['scarab2'] = 1542143200, ['scarab3'] = 3715219435, ['scarab'] = 3147997943, ['schafter2'] = 3039514899, ['schafter3'] = 2809443750, ['schafter4'] = 1489967196, ['schafter5'] = 3406724313, ['schafter6'] = 1922255844, ['schlagen'] = 3787471536, ['schwarzer'] = 3548084598, ['scorcher'] = 4108429845, ['scramjet'] = 3656405053, ['scrap'] = 2594165727, ['seabreeze'] = 3902291871, ['seashark2'] = 3678636260, ['seashark3'] = 3983945033, ['seashark'] = 3264692260, ['seasparrow2'] = 1229411063, ['seasparrow3'] = 1593933419, ['seasparrow'] = 3568198617, ['seminole2'] = 2484160806, ['seminole'] = 1221512915, ['sentinel2'] = 873639469, ['sentinel3'] = 1104234922, ['sentinel'] = 1349725314, ['serrano'] = 1337041428, ['seven70'] = 2537130571, ['shamal'] = 3080461301, ['sheava'] = 819197656, ['sheriff2'] = 1922257928, ['sheriff'] = 2611638396, ['shotaro'] = 3889340782, ['skylift'] = 1044954915, ['slamtruck'] = 3249056020, ['slamvan2'] = 833469436, ['slamvan3'] = 1119641113, ['slamvan4'] = 2233918197, ['slamvan5'] = 373261600, ['slamvan6'] = 1742022738, ['slamvan'] = 729783779, ['sovereign'] = 743478836, ['specter2'] = 1074745671, ['specter'] = 1886268224, ['speeder2'] = 437538602, ['speeder'] = 231083307, ['speedo2'] = 728614474, ['speedo4'] = 219613597, ['speedo'] = 3484649228, ['squaddie'] = 4192631813, ['squalo'] = 400514754, ['stafford'] = 321186144, ['stalion2'] = 3893323758, ['stalion'] = 1923400478, ['stanier'] = 2817386317, ['starling'] = 2594093022, ['stinger'] = 1545842587, ['stingergt'] = 2196019706, ['stockade3'] = 4080511798, ['stockade'] = 1747439474, ['stratum'] = 1723137093, ['streiter'] = 1741861769, ['stretch'] = 2333339779, ['strikeforce'] = 1692272545, ['stromberg'] = 886810209, ['stryder'] = 301304410, ['stunt'] = 2172210288, ['submersible2'] = 3228633070, ['submersible'] = 771711535, ['sugoi'] = 987469656, ['sultan3'] = 4003946083, ['sultan2'] = 872704284, ['sultan'] = 970598228, ['sultanrs'] = 3999278268, ['suntrap'] = 4012021193, ['superd'] = 1123216662, ['supervolito2'] = 2623428164, ['supervolito'] = 710198397, ['surano'] = 384071873, ['surfer2'] = 2983726598, ['surfer'] = 699456151, ['surge'] = 2400073108, ['swift2'] = 1075432268, ['swift'] = 3955379698, ['swinger'] = 500482303, ['t20'] = 1663218586, ['taco'] = 1951180813, ['tailgater2'] = 3050505892, ['tailgater'] = 3286105550, ['taipan'] = 3160260734, ['tampa2'] = 3223586949, ['tampa3'] = 3084515313, ['tampa'] = 972671128, ['tanker2'] = 1956216962, ['tanker'] = 3564062519, ['tankercar'] = 586013744, ['taxi'] = 3338918751, ['technical2'] = 1180875963, ['technical3'] = 1356124575, ['technical'] = 2198148358, ['tempesta'] = 272929391, ['terbyte'] = 2306538597, ['tezeract'] = 1031562256, ['thrax'] = 1044193113, ['thrust'] = 1836027715, ['thruster'] = 1489874736, ['tigon'] = 2936769864, ['tiptruck2'] = 3347205726, ['tiptruck'] = 48339065, ['titan'] = 1981688531, ['torero'] = 1504306544, ['tornado2'] = 1531094468, ['tornado3'] = 1762279763, ['tornado4'] = 2261744861, ['tornado5'] = 2497353967, ['tornado6'] = 2736567667, ['tornado'] = 464687292, ['toro2'] = 908897389, ['toro'] = 1070967343, ['toros'] = 3126015148, ['tourbus'] = 1941029835, ['towtruck2'] = 3852654278, ['towtruck'] = 2971866336, ['toreador'] = 1455990255, ['tr2'] = 2078290630, ['tr3'] = 1784254509, ['tr4'] = 2091594960, ['tractor2'] = 2218488798, ['tractor3'] = 1445631933, ['tractor'] = 1641462412, ['trailerlarge'] = 1502869817, ['trailerlogs'] = 2016027501, ['trailers2'] = 2715434129, ['trailers3'] = 2236089197, ['trailers4'] = 3194418602, ['trailers'] = 3417488910, ['trailersmall2'] = 2413121211, ['trailersmall'] = 712162987, ['trash2'] = 3039269212, ['trash'] = 1917016601, ['trflat'] = 2942498482, ['tribike2'] = 3061159916, ['tribike3'] = 3894672200, ['tribike'] = 1127861609, ['trophytruck2'] = 3631668194, ['trophytruck'] = 101905590, ['tropic2'] = 1448677353, ['tropic'] = 290013743, ['tropos'] = 1887331236, ['tug'] = 2194326579, ['tula'] = 1043222410, ['tulip'] = 1456744817, ['turismo2'] = 3312836369, ['turismor'] = 408192225, ['tvtrailer'] = 2524324030, ['tyrant'] = 3918533058, ['tyrus'] = 2067820283, ['utillitruck2'] = 887537515, ['utillitruck3'] = 2132890591, ['utillitruck'] = 516990260, ['vacca'] = 338562499, ['vader'] = 4154065143, ['vagner'] = 1939284556, ['vagrant'] = 740289177, ['valkyrie2'] = 1543134283, ['valkyrie'] = 2694714877, ['vamos'] = 4245851645, ['vectre'] = 2754593701, ['velum2'] = 1077420264, ['velum'] = 2621610858, ['verlierer2'] = 1102544804, ['verus'] = 298565713, ['vetir'] = 2014313426, ['veto'] = 3437611258, ['veto2'] = 2802050217, ['vestra'] = 1341619767, ['vigero'] = 3469130167, ['vigilante'] = 3052358707, ['vindicator'] = 2941886209, ['virgo2'] = 3395457658, ['virgo3'] = 16646064, ['virgo'] = 3796912450, ['viseris'] = 3903371924, ['visione'] = 3296789504, ['volatol'] = 447548909, ['volatus'] = 2449479409, ['voltic2'] = 989294410, ['voltic'] = 2672523198, ['voodoo2'] = 523724515, ['voodoo'] = 2006667053, ['vortex'] = 3685342204, ['vstr'] = 1456336509, ['warrener'] = 579912970, ['washington'] = 1777363799, ['wastelander'] = 2382949506, ['weevil'] = 1644055914, ['windsor2'] = 2364918497, ['windsor'] = 1581459400, ['winky'] = 4084658662, ['wolfsbane'] = 3676349299, ['xa21'] = 917809321, ['xls2'] = 3862958888, ['xls'] = 1203490606, ['yosemite2'] = 1693751655, ['yosemite3'] = 67753863, ['yosemite'] = 1871995513, ['youga2'] = 1026149675, ['youga3'] = 1802742206, ['youga'] = 65402552, ['z190'] = 838982985, ['zentorno'] = 2891838741, ['zhaba'] = 1284356689, ['zion2'] = 3101863448, ['zion3'] = 1862507111, ['zion'] = 3172678083, ['zombiea'] = 3285698347, ['zombieb'] = 3724934023, ['zorrusso'] = 3612858749, ['zr350'] = 2436313176, ['zr3802'] = 3188846534, ['zr3803'] = 2816263004, ['zr380'] = 540101442, ['ztype'] = 758895617, }config.custom_engine_enable = true -- enable custom engine
config.custom_engine = { -- advanced usage, Custom Engine, customsounds, custom handling (handling for engine speed and power only) -- the item can be spawn using engine_b16b for example. 
	-- nInitialDriveGears = total gears of engine's tranny.
	-- fInitialDriveForce = affects engine speed thats affect tranny (not topspeed), engine speed = rpm, this is like a flywheel of engine.
	-- fDriveInertia = affects engine speed again but majority is how fast you are reving for ea gears, this is like a final drive, crank.
	-- fInitialDriveMaxFlatVel = affects vehicle top speed ( value is not kmh,mph or meters ) , you can calculate the estimate ex. (200 * 1.25 or 1.3) = kmh
	-- fClutchChangeRateScaleUpShift = affects how fast you are up shifting
	-- fMass = fmass is a default vehicle weight from handling meta, our engine system using a weight ratio, if fMass is greater than the existing vehicle weight, engine will produce more power.( wont explain full why we need this , but in short explanation, i believe gta devs uses this kind of ratio formula before they produced any handling final value for any gta cars)
	-- LEARN MORE ABOUT HANDLING https://gtamods.com/wiki/Handling.meta
	-- turboinstall = default engine have turbo
	-- custom = enable custom engine
	-- handlingName = important, this will be the item name prefix (engine_handlingName or engine_b16b)
	-- soundname = important, this will be the sound hash will the system be using, example hash: blista,blista2, ruston. ( you can add custom sounds if you know how : example this toysupmk4 is a custom soundfile)
	-- label = label of the item
	-- you can add as many custom engine as you want
	-- important that the arrayname should have a backtick like this [`customengine`]
	[`b16b`] = {custom = true, turboinstall = false, handlingName = 'b16b', label = 'Ek9 B16b Type R', soundname = 'ruston', fMass = '800.000000', nInitialDriveGears = 5, fInitialDriveForce = 0.425000, fDriveInertia = 1.200000, fClutchChangeRateScaleUpShift = 8.200000, fClutchChangeRateScaleDownShift = 8.200000, fInitialDriveMaxFlatVel = 148.000000, },
	[`rb26dett`] = {custom = true, turboinstall = true, handlingName = 'rb26dett', label = 'BNR34 RB26DE Twin Turbo', soundname = 'elegyx', fMass = '1500.000000', nInitialDriveGears = 6, fInitialDriveForce = 0.525000, fDriveInertia = 1.120000, fClutchChangeRateScaleUpShift = 7.200000, fClutchChangeRateScaleDownShift = 7.200000, fInitialDriveMaxFlatVel = 198.000000, },
	[`supra2jzgtett`] = {custom = true, turboinstall = true, handlingName = 'supra2jzgtett', label = 'Supra 2JZ GTE Twin Turbo', soundname = 'toysupmk4', fMass = '1600.000000', nInitialDriveGears = 5, fInitialDriveForce = 0.475000, fDriveInertia = 0.950000, fClutchChangeRateScaleUpShift = 7.400000, fClutchChangeRateScaleDownShift = 7.500000, fInitialDriveMaxFlatVel = 189.000000, },
	[`rx713b`] = {custom = true, turboinstall = true, handlingName = 'rx713b', label = 'RX7 13B-REW twin-rotor Twin Turbo', soundname = 'rotary7', fMass = '1340.000000', nInitialDriveGears = 5, fInitialDriveForce = 0.425000, fDriveInertia = 1.090000, fClutchChangeRateScaleUpShift = 7.700000, fClutchChangeRateScaleDownShift = 7.100000, fInitialDriveMaxFlatVel = 182.000000, },
}
config.motorcycle_weight_check = 400 -- assume the engine is motorcycle engine if origin vehicle weight is equal or less than this value

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
	carheadlight = 'carheadlight'
}

-- COMPASS STREET LOCATION Customization options
config.border = {
    r = 255;
    g = 255;
    b = 255;
    a = 0.65;
    size = 2.5;
};

config.current = {
    r = 9;
    g = 222;
    b = 1;
    a = 0.9;
    size = 1.0;
};

config.crossing = {
    r = 255;
    g = 233;
    b = 233;
    a = 0.9;
    size = 1.1;
};

config.direction = {
    r = 255;
    g = 233;
    b = 233;
    a = 0.9;
    size = 2.5;
};

config.position = {
    -- 0:100
    offsetX = 17;
    offsetY = 1.2;
};

config.vehicleCheck = true;

--MANUAL TRANNY Gear Ratio ( Do not Edit if you know what you are doing ) This is not the actual Gear Ratio numbers/settings in real life!
config.gears = {
	[1.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.60,
        [3] = 0.84,
        [4] = 1.17,
        [5] = 1.45,
        [6] = 1.60
    },
	[2.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.60,
        [3] = 0.84,
        [4] = 1.17,
        [5] = 1.45,
        [6] = 1.60
    },
	[3.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.60,
        [3] = 0.84,
        [4] = 1.17,
        [5] = 1.45,
        [6] = 1.60
    },
    [4.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.60,
        [3] = 0.84,
        [4] = 1.17,
        [5] = 1.45,
        [6] = 1.60
    },
    [5.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.57,
        [3] = 0.84,
        [4] = 1.08,
        [5] = 1.45,
        [6] = 1.60
    },
    [6.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.57,
        [3] = 0.80,
        [4] = 1.02,
        [5] = 1.12,
        [6] = 1.35
    },
    [7.0] = {
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.57,
        [3] = 0.73,
        [4] = 1.02,
        [5] = 1.12,
        [6] = 1.35,
        [7] = 1.52
    },
    [8.0] = { -- some cars is 8 gears like jugular (mpheist3)
        [0] = 0.00,
        [1] = 0.33,
        [2] = 0.60,
        [3] = 0.84,
        [4] = 1.08,
        [5] = 1.28,
        [6] = 1.42,
        [7] = 1.70,
        [8] = 1.91
    }
}
config.upshift = 172 -- UP ARROW (SHIFT TO HIGHER GEAR)
config.downshift = 173 -- DOWN ARROW (SHIFT TO LOWER GEAR)
config.clutch = 73 -- Z -- Activate Clutch Mode
config.finaldrive = 'default' -- will use the default settings from handling.meta
config.blacklistvehicle = {
	'13', -- cycles
	'8', -- motorcycles
	'14', -- boats
	'15', -- helis
	'16', -- planes
	'21', -- trains
}

config.enableproximityfunc = false -- if false = will be using Voice UI Only, no Voice Function
config.voicecommandandkeybind = false -- disable by default!, enabling this will register a keybinds to your fivem client settings. so use this only if you are really going to use this.
config.radiochanel = true -- Enable Radio UI
config.radiochannels = { -- this will appear in Radio Channel UI if enable, example in config: chanel 1 = Ambulance Comms
    [1] = 'Police - Robbery Comms', -- Limit the words or else it may overlap
    [2] = 'Ambulance - EMS Comms',
    [3] = 'Mechanic - Oncall Comms',

	-- you can add more radio channels here, this settings must be sync or the same with your radio channels permmision
}
config.defaultchannelname = 'Public Channel'
--if voicecommandandkeybind is disable
-- the system is listening to the following events of proxymity to change the mic UI in HUD
--pma-voice:setTalkingMode (from pma-voice)
--setVoice from MumbleVoip

--OPTIMIZATION
-- DONT CHANGE UNLESS YOU KNOW WHAT YOU ARE DOING!
config.uitop_sleep = 2000
config.gear_sleep = 700
config.lights_sleep = 1000
config.direction_sleep = 2500
config.NuiCarhpandGas_sleep = 2500
config.car_mainloop_sleep = 1500
config.rpm_speed_loop = 10
config.idle_rpm_speed_sleep = 151
config.Rpm_sleep = 65 -- around 10-20-50-200 is a good value (depends on UTILS animation ms)
config.Rpm_sleep_2 = 5
config.Speed_sleep = 151
config.Speed_sleep_2 = 11

--UTILS UI SETTINGS -- the default settings is optimized for CPU usage, (DEFAULT: 'unset',0ms,'unset') Use this if you know else leave default.
-- THIS PART AFFECT OVERALL CPU USAGE FROM TASK MANAGER
-- NON VEHICLE CSS ANIMATION
config.acceleration = 'unset' -- (none,gpu,hardware) use hardware acceleration = cpu / gpu = gpu resource to some UI animation and effects?, option = hardware,gpu (looks like this is the same result)
config.animation_ms = '250ms' -- animation delay ( this affects cpu usage of animations ) DEFAULT '0ms'
config.transition = 'linear' -- ease, linear, or leave it like = '' (blank) or unset DEFAULT 'unset'
-- VEHICLE CSS ANIMATION
config.accelerationcar = 'unset' -- (none,gpu,hardware) use hardware acceleration = cpu / gpu = gpu resource to some UI animation and effects?, option = hardware,gpu (looks like this is the same result)
config.animation_mscar = '15ms' -- animation delay ( this affects cpu usage of animations ) DEFAULT '0ms'
config.transitioncar = 'linear' -- ease, linear, or leave it like = '' (blank) or unset DEFAULT 'unset'
-- DEFAULT UTIL SETTING is the optimize for CPU in task manager not in resmon!, but the animation or transition is sucks, you may want to configure the transition and animation_ms to your desire settings and desire beautiful transition of circlebars,carhud etc.
config.uiconfig = {acceleration = config.acceleration, animation_ms = config.animation_ms, transition = config.transition,accelerationcar = config.accelerationcar, animation_mscar = config.animation_mscar, transitioncar = config.transitioncar}
-- GEAR FUNCTION
nextgearhash = `SET_VEHICLE_NEXT_GEAR`
setcurrentgearhash = `SET_VEHICLE_CURRENT_GEAR`
function SetRpm(veh, val)
    Renzu_Hud(0x2A01A8FC, veh, val)
end
function SetVehicleNextGear(veh, gear)
    Renzu_Hud(nextgearhash & 0xFFFFFFFF, veh, gear)
end
function SetVehicleCurrentGear(veh, gear)
    Renzu_Hud(setcurrentgearhash & 0xFFFFFFFF, veh, gear)
end

function Renzu_SetGear(vehicle, gear)
    if gear >= 6 then
        gear = 6
    end
	if gear < 0 then
		gear = 1
	end
    Hud:ForceVehicleGear(vehicle, gear)
end

function LockSpeed(veh,speed)
    Renzu_Hud(0x0E46A3FCBDE2A1B1, veh, speed)
end

function VehicleSpeed(veh)
    return Renzu_Hud(0xD5037BA82E12416F, veh, ReturnFloat)
end

function VehicleRpm(veh)
    return Renzu_Hud(0xE7B12B54, veh, ReturnFloat)
end

function WheelSpeed(veh,int)
    return Renzu_Hud(0x149C9DA0, veh, int, ReturnFloat)
end

function RCR(int,pad)
    return Renzu_Hud(0x50F940259D3841E6, int, pad)
end

function RCR2(int,pad)
    return Renzu_Hud(0x648EE3E7F38877DD, int, pad)
end

function RCP(int,pad)
    return Renzu_Hud(0xF3A21BCD95725A4A, int, pad)
end

function GetVehStats(veh,field,stat)
    return Renzu_Hud(0x642FC12F, veh, field, stat, ReturnFloat)
end

function GetCamhead()
    return Renzu_Hud(0x743607648ADD4587, ReturnFloat)
end

function SetVehStats(veh,field,stat,float)
    Renzu_Hud(0x488C86D2, veh, field, stat, float)
end

function SetVehicleBoost(vehicle,val)
	Renzu_Hud(0xB59E4BD37AE292DB, vehicle,val)
end

function GetGear(vehicle)
	return Renzu_Hud(0xB4F4E566, vehicle, ReturnInt)
end
function build() ver = 1604 if IsModelInCdimage(`italirsx`) then ver = 2189 elseif IsModelInCdimage(`everon`) then ver = 2060 end return ver end
--config.gamebuild = build()
-------------------------------------------https://github.com/renzuzu/renzu_hud----------------------------------------------------------
--------------------------------------------------------------VARIABLES------------------------------------------------------------------
Hud = {
	buclothes = nil,saveclothe = {},identifier=nil,lastveh = nil,newdate = nil,underwatertime=30,healing=nil,manual2 = false,alreadyblackout = false,regdecor=false,busy = false,onlinevehicles = {},nearstancer = {},wheelsettings = {},wheeledit = false,turbosound = 0,oldgear = 0,newgear = 0,rpm2 = 0,propturbo = nil,boost = 1.0,old_diff = nil,togglediff = false,cruising = false,lastdamage = nil,oldlife = 200,windowbones = {[0] = 'window_rf',[1] = 'window_lf',[2] = 'window_rr',[3] = 'window_lr'},carcontrol = false,isbusy = false,oldweapon = nil,weaponui = false,wstatus = {},trail = {},nitromode = false,lightshit = {},light_trail_isfuck = false,purgefuck = {},purgeshit = {},pressed = false,proptire = nil,keyless = true,hasmask=false,hashelmet = false,imbusy = true,carstatus = false,enginelist = {},syncengine = {},syncveh = {},ped = nil,playerNamesDist = 3,key_holding = false,particlesfire = {},particleslight = {},charslot = nil,pedshot = false,lastped = nil,dummyskin = {},show = false,notifycd = {},statuses = {},vitals = {},statusloop = -1,garbage = 0,start = false,breakstart = false,lastplate = nil,notloaded = true,minimap=nil,shooting = false,busyplate = {},busyairsus = false,crosshair = 1,flametable = {},spool = false,shouldUpdateSkin = false,pedSkin = {},oldclothes = nil,clothestate = {},dummyskin1 = {},sounded = false,left = false,right = false,hazard = false,signal_state = false,turbo = config.boost,newstreet = nil,newmic = nil,newhealth = 1111,newarmor = 1111,triggered = false,cansmoke = true,refresh = false,veh_stats_loaded = false,finaldrive = 0,flywheel = 0,speed=0,maxspeed = 0,currentengine={},headshot = nil,enginespec=false,handlings={},vehiclehandling={},boost=1.0,correctgears=1,gear=1,plate=nil,loadedplate=false,maxgear=5,pid=nil,veh_stats=nil,Renzuzu=Citizen,entering=false,mode='NORMAL',ismapopen=false,date="00:00",plate=nil,degrade=1.0,playerloaded=false,manual=false,vehicletopspeed=nil,uimove=false,reverse=false,savegear=0,rpm=0.2,hour=0,vali=false,minute=0,globaltopspeed=nil,segundos=0,month="",dayOfMonth=0,voice=2,voiceDisplay=2,proximity=25.0,belt=false,ExNoCarro=false,sBuffer={},vBuffer={},displayValue=true,gasolina=0,street=nil,vehicle=nil,hp=0,shifter=false,hasNitro=true,k_nitro=70,n_boost=15.0,boost=1.0,nitro_state=100,isBlack="false",invehicle=false,topspeedmodifier=1.0,switch=false,life=100,receive='new',bodystatus={},bonecategory={},parts={},bodyui=false,body=false,arm=false,armbone=0,armbone2=0,leg=false,head=false,shooting=false,manualstatus=false,traction=nil,traction2=nil,alreadyturbo=false,Creation=Citizen.CreateThread,Renzu_Hud=Citizen.InvokeNative,ClientEvent=TriggerEvent,RenzuNetEvent=RegisterNetEvent,RenzuEventHandler=AddEventHandler,RenzuCommand=RegisterCommand,RenzuSendUI=SendNUIMessage,RenzuKeybinds=RegisterKeyMapping,RenzuNuiCallback=RegisterNUICallback,ReturnFloat=Citizen.ResultAsFloat(),ReturnInt=Citizen.ResultAsInteger()
}
identifier=nil;lastveh = nil;newdate = nil;underwatertime=30;healing=nil;manual2 = false;alreadyblackout = false;regdecor=false;busy = false;onlinevehicles = {};nearstancer = {};wheelsettings = {};wheeledit = false;turbosound = 0;oldgear = 0;newgear = 0;rpm2 = 0;propturbo = nil;boost = 1.0;old_diff = nil;togglediff = false;cruising = false;lastdamage = nil;oldlife = 200;windowbones = {[0] = 'window_rf',[1] = 'window_lf',[2] = 'window_rr',[3] = 'window_lr'};carcontrol = false;isbusy = false;oldweapon = nil;weaponui = false;wstatus = {};trail = {};nitromode = false;lightshit = {};light_trail_isfuck = false;purgefuck = {};purgeshit = {};pressed = false;proptire = nil;keyless = false;hasmask=false;hashelmet = false;imbusy = true;carstatus = false;enginelist = {};syncengine = {};syncveh = {};ped = nil;playerNamesDist = 3;key_holding = false;particlesfire = {};particleslight = {};charslot = nil;pedshot = false;lastped = nil;dummyskin = {};show = false;notifycd = {};statuses = {};vitals = {};statusloop = -1;garbage = 0;start = false;breakstart = false;lastplate = nil;notloaded = true;minimap=nil;shooting = false;busyplate = {};busyairsus = false;crosshair = 1;flametable = {};spool = false;shouldUpdateSkin = false;pedSkin = {};oldclothes = nil;clothestate = {};dummyskin1 = {};sounded = false;left = false;right = false;hazard = false;state = false;turbo = config.boost;newstreet = nil;newmic = nil;newhealth = 1111;newarmor = 1111;triggered = false;cansmoke = true;refresh = false;veh_stats_loaded = false;finaldrive = 0;flywheel = 0;maxspeed = 0;currentengine={};headshot = nil;enginespec=false;handlings={};vehiclehandling={};boost=1.0;correctgears=1;gear=1;plate=nil;loadedplate=false;maxgear=5;pid=nil;veh_stats=nil;entering=false;mode='NORMAL';ismapopen=false;date="00:00";plate=nil;degrade=1.0;playerloaded=false;manual=false;vehicletopspeed=nil;uimove=false;reverse=false;savegear=0;rpm=0.2;hour=0;vali=false;minute=0;globaltopspeed=nil;segundos=0;month="";dayOfMonth=0;voice=2;voiceDisplay=2;proximity=25.0;belt=false;ExNoCarro=false;sBuffer={};vBuffer={};displayValue=true;gasolina=0;street=nil;vehicle=nil;hp=0;shifter=false;hasNitro=true;k_nitro=70;n_boost=15.0;boost=1.0;nitro_state=100;isBlack="false";invehicle=false;topspeedmodifier=1.0;switch=false;life=100;receive='new';bodystatus={};bonecategory={};parts={};bodyui=false;body=false;arm=false;armbone=0;armbone2=0;leg=false;head=false;shooting=false;manualstatus=false;traction=nil;traction2=nil;alreadyturbo=false;Creation=Citizen.CreateThread;Renzu_Hud=Citizen.InvokeNative;ClientEvent=TriggerEvent;RenzuNetEvent=RegisterNetEvent;RenzuEventHandler=AddEventHandler;RenzuCommand=RegisterCommand;RenzuSendUI=SendNUIMessage;RenzuKeybinds=RegisterKeyMapping;RenzuNuiCallback=RegisterNUICallback;ReturnFloat=Citizen.ResultAsFloat();ReturnInt=Citizen.ResultAsInteger()
-----------------------------------------------------------------------------------------------------------------------------------------