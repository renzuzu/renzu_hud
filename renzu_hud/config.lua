---------------------------------------------------------https://github.com/renzuzu/renzu_hud------------------------------------------
config = {}
config.gamebuild = 2060 -- if 2189 pedshot transparent and 1604 or < 2000 = Enter vehicle game event will not work, we will use normal pedshot ( gamebuild is what you set on your server start example: +set sv_enforceGameBuild 2189, available build 1604, 2060, 2189 and more.) this is important if you are using UI Normal with Ped Face.
config.framework = 'ESX' -- ESX | VRP | STANDALONE (VRP not supported yet, but you can use standalone, it will work!)
config.weight_type = false -- ESX item weight or limit type
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
config.multichar = true -- KASHACTERS, cd_multicharacter, etc...
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
config.statusui = 'normal' -- UI LOOK ( simple, normal ) -- NORMAL = with pedface, Simple = Only Icons
config.status_type = 'progressbar' -- circle progress bar = progressbar, fontawsome icon = icons
config.statusv2 = true -- enable this if you want the status toggle mode (TOGGLE VIA INSERT) (THIS INCLUDE RP PURPOSE HUD like job,money,etc.)
config.statusplace = 'top-right' -- available option top-right,top-left,bottom-right,bottom-left,top-center,bottom-center
config.uidesign = 'octagon' -- octagon (default), circle, square
--CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD
--UI CONFIG END
--start car map
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound) (MP3 not implemented yet..lazy..)
config.mapversion = 'satellite' -- available ( satellite, atlas, oldschool )
config.usecustomlink = false -- use custom url of image map
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
config.firing_statusaddval = 10000 -- value to add when firing a weapons
config.firing_bullets = 100 -- number of bullets or firing events to trigger the status function.
config.killing_affect_status = true -- do you want the status to be affected when you kill some player , ped, animals.
config.killing_affected_status = 'sanity'
config.killing_status_mode = 'add' -- (add,remove) add will add a value to status, remove will remove a status value.
config.killing_status_val = 5000 -- status value to add/remove per kill
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
	[0] = {enable = true, status = 'health', rpuidiv = 'null', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'none', id = 'uisimplehp', offset = '275', i_id_1 = 'healthsimple', i_id_1_color = 'rgb(251, 29, 9)', i_id_1_class = 'fas fa-heartbeat fa-stack-1x', i_id_2 = 'healthsimplebg', i_id_2_color = 'rgba(251, 29, 9, 0.3)', i_id_2_class = 'fas fa-heartbeat fa-stack-1x', id_3 = 'health_blink'},
	[1] = {enable = true, status = 'armor', rpuidiv = 'null', hideifmax = true, custom = false, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'none', id = 'uisimplearmor', offset = '275', i_id_1 = 'armorsimple', i_id_1_color = 'rgb(1, 103, 255)', i_id_1_class = 'far fa-shield-alt fa-stack-1x', i_id_2 = 'armorsimplebg', i_id_2_color = 'rgb(0, 41, 129)', i_id_2_class = 'far fa-shield-alt fa-stack-1x', id_3 = 'armor_blink'},
	[2] = {enable = true, status = 'hunger', rpuidiv = 'hunger', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very hungry', notify_value = 20, display = 'block', id = 'uisimplehunger', offset = '275', i_id_1 = 'food2', i_id_1_color = 'rgb(221, 144, 0)', i_id_1_class = 'fad fa-cheeseburger fa-stack-1x', i_id_2 = 'food2bg', i_id_2_color = 'rgb(114, 68, 0)', i_id_2_class = 'fad fa-cheeseburger fa-stack-1x', id_3 = 'hunger_blink'},
	[3] = {enable = true, status = 'thirst', rpuidiv = 'thirst', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very thirsty', notify_value = 20, display = 'block', id = 'uisimplethirst', offset = '275', i_id_1 = 'water2', i_id_1_color = 'rgb(36, 113, 255)', i_id_1_class = 'fad fa-glass fa-stack-1x', i_id_2 = 'water2bg', i_id_2_color = 'rgb(0, 11, 112)', i_id_2_class = 'fad fa-glass fa-stack-1x', id_3 = 'thirst_blink'},
	[4] = {enable = true, status = 'sanity', rpuidiv = 'stressbar', hideifmax = false, custom = true, value = 0, notify_lessthan = true, notify_message = 'i see some dragons', notify_value = 80, display = 'block', id = 'uisimplesanity', offset = '275', i_id_1 = 'stress2', i_id_1_color = 'rgb(255, 16, 68)', i_id_1_class = 'fad fa-head-side-brain fa-stack-1x', i_id_2 = 'stress2bg', i_id_2_color = 'rgba(35, 255, 101, 0.842)', i_id_2_class = 'fad fa-head-side-brain fa-stack-1x', id_3 = 'stress_blink'},
	[5] = {enable = true, status = 'stamina', rpuidiv = 'staminabar', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'running makes me thirsty', notify_value = 20, display = 'block', id = 'uisimplestamina', offset = '275', i_id_1 = 'stamina2', i_id_1_color = 'rgb(16, 255, 136)', i_id_1_class = 'fad fa-running fa-stack-1x', i_id_2 = 'stamina2bg', i_id_2_color = 'rgba(0, 119, 57, 0.945)', i_id_2_class = 'fad fa-running fa-stack-1x', id_3 = 'stamina_blink'},
	[6] = {enable = true, status = 'oxygen', rpuidiv = 'oxygenbar', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'my oxygen is almost gone', notify_value = 20, display = 'block', id = 'uisimpleoxygen', offset = '275', i_id_1 = 'oxygen2', i_id_1_color = 'rgb(15, 227, 255)', i_id_1_class = 'fad fa-lungs fa-stack-1x', i_id_2 = 'oxygen2bg', i_id_2_color = 'rgba(8, 76, 85, 0.788)', i_id_2_class = 'fad fa-lungs fa-stack-1x', id_3 = 'oxygen_blink'},
	[7] = {enable = true, status = 'energy', rpuidiv = 'energybar', hideifmax = false, custom = true, value = 0, notify_lessthan = false, notify_message = 'i am very tired', notify_value = 20, display = 'block', id = 'uisimpleenergy', offset = '275', i_id_1 = 'energy2', i_id_1_color = 'rgb(233, 233, 233)', i_id_1_class = 'fas fa-snooze fa-stack-1x', i_id_2 = 'energy2bg', i_id_2_color = 'color:rgb(243, 57, 0)', i_id_2_class = 'fas fa-snooze fa-stack-1x', id_3 = 'energy_blink'},
	[8] = {enable = true, status = 'voip', rpuidiv = 'null', hideifmax = false, custom = false, value = 0, notify_lessthan = false, notify_message = 'silent mode', notify_value = 0, display = 'block', id = 'voip_2', offset = '275', i_id_1 = 'microphone', i_id_1_color = 'rgb(251, 29, 9)', i_id_1_class = 'fas fa-microphone fa-stack-1x', i_id_2 = 'voipsimplebg', i_id_2_color = 'rgba(251, 29, 9, 0.3)', i_id_2_class = 'fas fa-microphone fa-stack-1x', id_3 = 'voip_blink'},
}
--UTILS UI SETTINGS -- the default settings is optimized for CPU usage, (DEFAULT: false,false,0ms,'') Use this if you know else leave default.
config.acceleration = 'none' -- (none,gpu,hardware) use hardware acceleration = cpu / gpu = gpu resource to some UI animation and effects?, option = hardware,gpu (looks like this is the same result)
config.animation_ms = '0ms' -- animation delay ( this affects cpu usage of animations )
config.transition = 'unset' -- ease, linear, or leave it like = '' (blank) or unset
-- DEFAULT UTIL SETTING is the optimize for CPU in task manager not in resmon!, but the animation or transition is sucks, you may want to configure the transition and animation_ms to your desire settings and desire beautiful transition of circlebars,carhud etc.
config.uiconfig = {acceleration = config.acceleration, animation_ms = config.animation_ms, transition = config.transition}
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
config.headbone_status_value = 40000 -- value to add or remove
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
config.purge_size = 40.0
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
	['glasses_1'] = {
		['skin'] = {
			['glasses_1'] = 0, ['glasses_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
	['chain_1'] = {
		['skin'] = {
			['chain_1'] = 0, ['chain_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
	['watches_1'] = {
		['skin'] = {
			['watches_1'] = -1, ['watches_2'] = 0
		},
		['default'] = -1,
		['taskplay'] = {dictionary = "nmt_3_rcm-10", name = "cs_nigel_dual-10", speed = 51, duration = 1200}
	},
	--right
	['torso_1'] = {
		['skin'] = {
			['torso_1'] = 15, ['torso_2'] = 0,
			['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['tshirt_1'] = {
		['skin'] = {
			['tshirt_1'] = 15, ['tshirt_2'] = 0
			--['arms'] = 15, ['arms_2'] = 0
		},
		['default'] = 15,
		['taskplay'] = {dictionary = "missmic4", name = "michael_tux_fidget", speed = 51, duration = 1500}
	},
	['bproof_1'] = {
		['skin'] = {
			['bproof_1'] = 0, ['bproof_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "clothingtie", name = "try_tie_positive_a", speed = 51, duration = 2100}
	},
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
	--top
	['mask_1'] = {
		['skin'] = {
			['mask_1'] = 0, ['mask_2'] = 0
		},
		['default'] = 0,
		['taskplay'] = {dictionary = "mp_masks@standard_car@ds@", name = "put_on_mask", speed = 51, duration = 800}
	},
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
config.engine={['adder']='0x0xB779A091',['airbus']='0x0x4C80EB0E',['airtug']='0x0x5D0AAC8F',['akula']='0x0x46699F47',['akuma']='0x0x63ABADE7',['alkonost']='0x0xEA313705',['alpha']='0x0x2DB8D1AA',['alphaz1']='0x0xA52F6866',['ambulance']='0x0x45D56ADA',['annihilator']='0x0x31F0B376',['annihilator2']='0x0x11962E49',['apc']='0x0x2189D250',['ardent']='0x0x97E5533',['armytanker']='0x0xB8081009',['armytrailer']='0x0xA7FF33F5',['armytrailer2']='0x0x9E6B14D6',['asbo']='0x0x42ACA95F',['asea']='0x0x94204D89',['asea2']='0x0x9441D8D5',['asterope']='0x0x8E9254FB',['autarch']='0x0xED552C74',['avarus']='0x0x81E38F7F',['avenger']='0x0x81BD2ED0',['avenger2']='0x0x18606535',['avisa']='0x0x9A474B5E',['bagger']='0x0x806B9CC3',['baletrailer']='0x0xE82AE656',['baller']='0x0xCFCA3668',['baller2']='0x0x8852855',['baller3']='0x0x6FF0F727',['baller4']='0x0x25CBE2E2',['baller5']='0x0x1C09CF5E',['baller6']='0x0x27B4E6B0',['banshee']='0x0xC1E908D2',['banshee2']='0x0x25C5AF13',['barracks']='0x0xCEEA3F4B',['barracks2']='0x0x4008EABB',['barracks3']='0x0x2592B5CF',['barrage']='0x0xF34DFB25',['bati']='0x0xF9300CC5',['bati2']='0x0xCADD5D2D',['benson']='0x0x7A61B330',['besra']='0x0x6CBD1D6D',['bestiagts']='0x0x4BFCF28B',['bf400']='0x0x5283265',['bfinjection']='0x0x432AA566',['biff']='0x0x32B91AE8',['bifta']='0x0xEB298297',['bison']='0x0xFEFD644F',['bison2']='0x0x7B8297C5',['bison3']='0x0x67B3F020',['bjxl']='0x0x32B29A4B',['blade']='0x0xB820ED5E',['blazer']='0x0x8125BCF9',['blazer2']='0x0xFD231729',['blazer3']='0x0xB44F0582',['blazer4']='0x0xE5BA6858',['blazer5']='0x0xA1355F67',['blimp']='0x0xF7004C86',['blimp2']='0x0xDB6B4924',['blimp3']='0x0xEDA4ED97',['blista']='0x0xEB70965F',['blista2']='0x0x3DEE5EDA',['blista3']='0x0xDCBC1C3B',['bmx']='0x0x43779C54',['boattrailer']='0x0x1F3D44B5',['bobcatxl']='0x0x3FC5D440',['bodhi2']='0x0xAA699BB6',['bombushka']='0x0xFE0A508C',['boxville']='0x0x898ECCEA',['boxville2']='0x0xF21B33BE',['boxville3']='0x0x7405E08',['boxville4']='0x0x1A79847A',['boxville5']='0x0x28AD20E1',['brawler']='0x0xA7CE1BC5',['brickade']='0x0xEDC6F847',['brioso']='0x0x5C55CB39',['brioso2']='0x0x55365079',['bruiser']='0x0x27D79225',['bruiser2']='0x0x9B065C9E',['bruiser3']='0x0x8644331A',['brutus']='0x0x7F81A829',['brutus2']='0x0x8F49AE28',['brutus3']='0x0x798682A2',['btype']='0x0x6FF6914',['btype2']='0x0xCE6B35A4',['btype3']='0x0xDC19D101',['buccaneer']='0x0xD756460C',['buccaneer2']='0x0xC397F748',['buffalo']='0x0xEDD516C6',['buffalo2']='0x0x2BEC3CBE',['buffalo3']='0x0xE2C013E',['bulldozer']='0x0x7074F39D',['bullet']='0x0x9AE6DDA1',['burrito']='0x0xAFBB2CA4',['burrito2']='0x0xC9E8FF76',['burrito3']='0x0x98171BD3',['burrito4']='0x0x353B561D',['burrito5']='0x0x437CF2A0',['bus']='0x0xD577C962',['buzzard']='0x0x2F03547B',['buzzard2']='0x0x2C75F0DD',['cablecar']='0x0xC6C3242D',['caddy']='0x0x44623884',['caddy2']='0x0xDFF0594C',['caddy3']='0x0xD227BDBB',['camper']='0x0x6FD95F68',['caracara']='0x0x4ABEBF23',['caracara2']='0x0xAF966F3C',['carbonizzare']='0x0x7B8AB45F',['carbonrs']='0x0xABB0C0',['cargobob']='0x0xFCFCB68B',['cargobob2']='0x0x60A7EA10',['cargobob3']='0x0x53174EEF',['cargobob4']='0x0x78BC1A3C',['cargoplane']='0x0x15F27762',['casco']='0x0x3822BDFE',['cavalcade']='0x0x779F23AA',['cavalcade2']='0x0xD0EB2BE5',['cerberus']='0x0xD039510B',['cerberus2']='0x0x287FA449',['cerberus3']='0x0x71D3B6F0',['cheburek']='0x0xC514AAE0',['cheetah']='0x0xB1D95DA0',['cheetah2']='0x0xD4E5F4D',['chernobog']='0x0xD6BC7523',['chimera']='0x0x675ED7',['chino']='0x0x14D69010',['chino2']='0x0xAED64A63',['cliffhanger']='0x0x17420102',['clique']='0x0xA29F78B0',['club']='0x0x82E47E85',['coach']='0x0x84718D34',['cog55']='0x0x360A438E',['cog552']='0x0x29FCD3E4',['cogcabrio']='0x0x13B57D8A',['cognoscenti']='0x0x86FE0B60',['cognoscenti2']='0x0xDBF2D57A',['comet2']='0x0xC1AE4D16',['comet3']='0x0x877358AD',['comet4']='0x0x5D1903F9',['comet5']='0x0x276D98A3',['contender']='0x0x28B67ACA',['coquette']='0x0x67BC037',['coquette2']='0x0x3C4E2113',['coquette3']='0x0x2EC385FE',['coquette4']='0x0x98F65A5E',['cruiser']='0x0x1ABA13B5',['crusader']='0x0x132D5A1A',['cuban800']='0x0xD9927FE3',['cutter']='0x0xC3FBA120',['cyclone']='0x0x52FF9437',['daemon']='0x0x77934CEE',['daemon2']='0x0xAC4E93C9',['deathbike']='0x0xFE5F0722',['deathbike2']='0x0x93F09558',['deathbike3']='0x0xAE12C99C',['defiler']='0x0x30FF0190',['deluxo']='0x0x586765FB',['deveste']='0x0x5EE005DA',['deviant']='0x0x4C3FFF49',['diablous']='0x0xF1B44F44',['diablous2']='0x0x6ABDF65E',['dilettante']='0x0xBC993509',['dilettante2']='0x0x64430650',['dinghy']='0x0x3D961290',['dinghy2']='0x0x107F392C',['dinghy3']='0x0x1E5E54EA',['dinghy4']='0x0x33B47F96',['dinghy5']='0x0xC58DA34A',['dloader']='0x0x698521E3',['docktrailer']='0x0x806EFBEE',['docktug']='0x0xCB44B1CA',['dodo']='0x0xCA495705',['dominator']='0x0x4CE68AC',['dominator2']='0x0xC96B73D9',['dominator3']='0x0xC52C6B93',['dominator4']='0x0xD6FB0F30',['dominator5']='0x0xAE0A3D4F',['dominator6']='0x0xB2E046FB',['double']='0x0x9C669788',['drafter']='0x0x28EAB80F',['dubsta']='0x0x462FE277',['dubsta2']='0x0xE882E5F6',['dubsta3']='0x0xB6410173',['dukes']='0x0x2B26F456',['dukes2']='0x0xEC8F7094',['dukes3']='0x0x7F3415E3',['dump']='0x0x810369E2',['dune']='0x0x9CF21E0F',['dune2']='0x0x1FD824AF',['dune3']='0x0x711D4738',['dune4']='0x0xCEB28249',['dune5']='0x0xED62BFA9',['duster']='0x0x39D6779E',['dynasty']='0x0x127E90D5',['elegy']='0x0xBBA2261',['elegy2']='0x0xDE3D9D22',['ellie']='0x0xB472D2B5',['emerus']='0x0x4EE74355',['emperor']='0x0xD7278283',['emperor2']='0x0x8FC3AADC',['emperor3']='0x0xB5FCF74E',['enduro']='0x0x6882FA73',['entity2']='0x0x8198AEDC',['entityxf']='0x0xB2FE5CF9',['esskey']='0x0x794CB30C',['everon']='0x0x97553C28',['exemplar']='0x0xFFB15B5E',['f620']='0x0xDCBCBE48',['faction']='0x0x81A9CDDF',['faction2']='0x0x95466BDB',['faction3']='0x0x866BCE26',['fagaloa']='0x0x6068AD86',['faggio']='0x0x9229E4EB',['faggio2']='0x0x350D1AB',['faggio3']='0x0xB328B188',['fbi']='0x0x432EA949',['fbi2']='0x0x9DC66994',['fcr']='0x0x25676EAF',['fcr2']='0x0xD2D5E00E',['felon']='0x0xE8A8BDA8',['felon2']='0x0xFAAD85EE',['feltzer2']='0x0x8911B9F5',['feltzer3']='0x0xA29D6D10',['firetruk']='0x0x73920F8E',['fixter']='0x0xCE23D3BF',['flashgt']='0x0xB4F32118',['flatbed']='0x0x50B0215A',['fmj']='0x0x5502626C',['forklift']='0x0x58E49664',['formula']='0x0x1446590A',['formula2']='0x0x8B213907',['fq2']='0x0xBC32A33B',['freecrawler']='0x0xFCC2F483',['freight']='0x0x3D6AAA9B',['freightcar']='0x0xAFD22A6',['freightcont1']='0x0x36DCFF98',['freightcont2']='0x0xE512E79',['freightgrain']='0x0x264D9262',['freighttrailer']='0x0xD1ABB666',['frogger']='0x0x2C634FBD',['frogger2']='0x0x742E9AC0',['fugitive']='0x0x71CB2FFB',['furia']='0x0x3944D5A0',['furoregt']='0x0xBF1691E0',['fusilade']='0x0x1DC0BA53',['futo']='0x0x7836CE2F',['gargoyle']='0x0x2C2C2324',['gauntlet']='0x0x94B395C5',['gauntlet2']='0x0x14D22159',['gauntlet3']='0x0x2B0C4DCD',['gauntlet4']='0x0x734C5E50',['gauntlet5']='0x0x817AFAAD',['gb200']='0x0x71CBEA98',['gburrito']='0x0x97FA4F36',['gburrito2']='0x0x11AA0E14',['glendale']='0x0x47A6BC1',['glendale2']='0x0xC98BBAD6',['gp1']='0x0x4992196C',['graintrailer']='0x0x3CC7F596',['granger']='0x0x9628879C',['gresley']='0x0xA3FC0F4D',['gt500']='0x0x8408F33A',['guardian']='0x0x825A9F4C',['habanero']='0x0x34B7390F',['hakuchou']='0x0x4B6C568A',['hakuchou2']='0x0xF0C2A91F',['halftrack']='0x0xFE141DA6',['handler']='0x0x1A7FCEFA',['hauler']='0x0x5A82F9AE',['hauler2']='0x0x171C92C4',['havok']='0x0x89BA59F5',['hellion']='0x0xEA6A047F',['hermes']='0x0xE83C17',['hexer']='0x0x11F76C14',['hotknife']='0x0x239E390',['hotring']='0x0x42836BE5',['howard']='0x0xC3F25753',['hunter']='0x0xFD707EDE',['huntley']='0x0x1D06D681',['hustler']='0x0x23CA25F2',['hydra']='0x0x39D6E83F',['imorgon']='0x0xBC7C0A00',['impaler']='0x0x83070B62',['impaler2']='0x0x3C26BD0C',['impaler3']='0x0x8D45DF49',['impaler4']='0x0x9804F4C7',['imperator']='0x0x1A861243',['imperator2']='0x0x619C1B82',['imperator3']='0x0xD2F77E37',['infernus']='0x0x18F25AC7',['infernus2']='0x0xAC33179C',['ingot']='0x0xB3206692',['innovation']='0x0xF683EACA',['insurgent']='0x0x9114EADA',['insurgent2']='0x0x7B7E56F0',['insurgent3']='0x0x8D4B7A8A',['intruder']='0x0x34DD8AA1',['issi2']='0x0xB9CB3B69',['issi3']='0x0x378236E1',['issi4']='0x0x256E92BA',['issi5']='0x0x5BA0FF1E',['issi6']='0x0x49E25BA1',['issi7']='0x0x6E8DA4F7',['italigtb']='0x0x85E8E76B',['italigtb2']='0x0xE33A477B',['italigto']='0x0xEC3E3404',['italirsx']='0x0xBB78956A',['jackal']='0x0xDAC67112',['jb700']='0x0x3EAB5555',['jb7002']='0x0x177DA45C',['jester']='0x0xB2A716A3',['jester2']='0x0xBE0E6126',['jester3']='0x0xF330CB6A',['jet']='0x0x3F119114',['jetmax']='0x0x33581161',['journey']='0x0xF8D48E7A',['jugular']='0x0xF38C4245',['kalahari']='0x0x5852838',['kamacho']='0x0xF8C2E0E7',['kanjo']='0x0x18619B7E',['khamelion']='0x0x206D1B68',['khanjali']='0x0xAA6F980A',['komoda']='0x0xCE44C4B9',['kosatka']='0x0x4FAF0D70',['krieger']='0x0xD86A0247',['kuruma']='0x0xAE2BFE94',['kuruma2']='0x0x187D938D',['landstalker']='0x0x4BA4E8DC',['landstalker2']='0x0xCE0B9F22',['lazer']='0x0xB39B0AE6',['le7b']='0x0xB6846A55',['lectro']='0x0x26321E67',['lguard']='0x0x1BF8D381',['limo2']='0x0xF92AEC4D',['locust']='0x0xC7E55211',['longfin']='0x0x6EF89CCC',['lurcher']='0x0x7B47A6A7',['luxor']='0x0x250B0C5E',['luxor2']='0x0xB79F589E',['lynx']='0x0x1CBDC10B',['mamba']='0x0x9CFFFC56',['mammatus']='0x0x97E55D11',['manana']='0x0x81634188',['manana2']='0x0x665F785D',['manchez']='0x0xA5325278',['manchez2']='0x0x40C332A3',['marquis']='0x0xC1CE1183',['marshall']='0x0x49863E9C',['massacro']='0x0xF77ADE32',['massacro2']='0x0xDA5819A3',['maverick']='0x0x9D0450CA',['menacer']='0x0x79DD18AE',['mesa']='0x0x36848602',['mesa2']='0x0xD36A4B44',['mesa3']='0x0x84F42E51',['metrotrain']='0x0x33C9E158',['michelli']='0x0x3E5BD8D9',['microlight']='0x0x96E24857',['miljet']='0x0x9D80F93',['minitank']='0x0xB53C6C52',['minivan']='0x0xED7EADA4',['minivan2']='0x0xBCDE91F0',['mixer']='0x0xD138A6BB',['mixer2']='0x0x1C534995',['mogul']='0x0xD35698EF',['molotok']='0x0x5D56F01B',['monroe']='0x0xE62B361B',['monster']='0x0xCD93A7DB',['monster3']='0x0x669EB40A',['monster4']='0x0x32174AFC',['monster5']='0x0xD556917C',['moonbeam']='0x0x1F52A43F',['moonbeam2']='0x0x710A2B9B',['mower']='0x0x6A4BD8F6',['mule']='0x0x35ED670B',['mule2']='0x0xC1632BEB',['mule3']='0x0x85A5B471',['mule4']='0x0x73F4110E',['nebula']='0x0xCB642637',['nemesis']='0x0xDA288376',['neo']='0x0x9F6ED5A2',['neon']='0x0x91CA96EE',['nero']='0x0x3DA47243',['nero2']='0x0x4131F378',['nightblade']='0x0xA0438767',['nightshade']='0x0x8C2BD0DC',['nightshark']='0x0x19DD9ED1',['nimbus']='0x0xB2CF7250',['ninef']='0x0x3D8FA25C',['ninef2']='0x0xA8E38B01',['nokota']='0x0x3DC92356',['novak']='0x0x92F5024E',['omnis']='0x0xD1AD4937',['openwheel1']='0x0x58F77553',['openwheel2']='0x0x4669D038',['oppressor']='0x0x34B82784',['oppressor2']='0x0x7B54A9D3',['oracle']='0x0x506434F6',['oracle2']='0x0xE18195B2',['osiris']='0x0x767164D6',['outlaw']='0x0x185E2FF3',['packer']='0x0x21EEE87D',['panto']='0x0xE644E480',['paradise']='0x0x58B3979C',['paragon']='0x0xE550775B',['paragon2']='0x0x546D8EEE',['pariah']='0x0x33B98FE2',['patriot']='0x0xCFCFEB3B',['patriot2']='0x0xE6E967F8',['patrolboat']='0x0xEF813606',['pbus']='0x0x885F3671',['pbus2']='0x0x149BD32A',['pcj']='0x0xC9CEAF06',['penetrator']='0x0x9734F3EA',['penumbra']='0x0xE9805550',['penumbra2']='0x0xDA5EC7DA',['peyote']='0x0x6D19CCBC',['peyote2']='0x0x9472CD24',['peyote3']='0x0x4201A843',['pfister811']='0x0x92EF6E04',['phantom']='0x0x809AA4CB',['phantom2']='0x0x9DAE1398',['phantom3']='0x0xA90ED5C',['phoenix']='0x0x831A21D5',['picador']='0x0x59E0FBF3',['pigalle']='0x0x404B6381',['police']='0x0x79FBB0C5',['police2']='0x0x9F05F101',['police3']='0x0x71FA16EA',['police4']='0x0x8A63C7B9',['policeb']='0x0xFDEFAEC3',['policeold1']='0x0xA46462F7',['policeold2']='0x0x95F4C618',['policet']='0x0x1B38E955',['polmav']='0x0x1517D4D9',['pony']='0x0xF8DE29A8',['pony2']='0x0x38408341',['pounder']='0x0x7DE35E7D',['pounder2']='0x0x6290F15B',['prairie']='0x0xA988D3A2',['pranger']='0x0x2C33B46E',['predator']='0x0xE2E7D4AB',['premier']='0x0x8FB66F9B',['primo']='0x0xBB6B404F',['primo2']='0x0x86618EDA',['proptrailer']='0x0x153E1B0A',['prototipo']='0x0x7E8F677F',['pyro']='0x0xAD6065C0',['radi']='0x0x9D96B45B',['raiden']='0x0xA4D99B7D',['raketrailer']='0x0x174CB172',['rallytruck']='0x0x829A3C44',['rancherxl']='0x0x6210CBB0',['rancherxl2']='0x0x7341576B',['rapidgt']='0x0x8CB29A14',['rapidgt2']='0x0x679450AF',['rapidgt3']='0x0x7A2EF5E4',['raptor']='0x0xD7C56D39',['ratbike']='0x0x6FACDF31',['ratloader']='0x0xD83C13CE',['ratloader2']='0x0xDCE1D9F7',['rcbandito']='0x0xEEF345EC',['reaper']='0x0xDF381E5',['rebel']='0x0xB802DD46',['rebel2']='0x0x8612B64B',['rebla']='0x0x4F48FC4',['regina']='0x0xFF22D208',['rentalbus']='0x0xBE819C63',['retinue']='0x0x6DBD6C0A',['retinue2']='0x0x79178F0A',['revolter']='0x0xE78CC3D9',['rhapsody']='0x0x322CF98F',['rhino']='0x0x2EA68690',['riata']='0x0xA4A4E453',['riot']='0x0xB822A1AA',['riot2']='0x0x9B16A3B4',['ripley']='0x0xCD935EF9',['rocoto']='0x0x7F5C91F1',['rogue']='0x0xC5DD6967',['romero']='0x0x2560B2FC',['rrocket']='0x0x36A167E0',['rubble']='0x0x9A5B1DCC',['ruffian']='0x0xCABD11E8',['ruiner']='0x0xF26CEFF9',['ruiner2']='0x0x381E10BD',['ruiner3']='0x0x2E5AFD37',['rumpo']='0x0x4543B74D',['rumpo2']='0x0x961AFEF7',['rumpo3']='0x0x57F682AF',['ruston']='0x0x2AE524A8',['s80']='0x0xECA6B6A3',['sabregt']='0x0x9B909C94',['sabregt2']='0x0xD4EA603',['sadler']='0x0xDC434E51',['sadler2']='0x0x2BC345D1',['sanchez']='0x0x2EF89E46',['sanchez2']='0x0xA960B13E',['sanctus']='0x0x58E316C7',['sandking']='0x0xB9210FD0',['sandking2']='0x0x3AF8C345',['savage']='0x0xFB133A17',['savestra']='0x0x35DED0DD',['sc1']='0x0x5097F589',['scarab']='0x0xBBA2A2F7',['scarab2']='0x0x5BEB3CE0',['scarab3']='0x0xDD71BFEB',['schafter2']='0x0xB52B5113',['schafter3']='0x0xA774B5A6',['schafter4']='0x0x58CF185C',['schafter5']='0x0xCB0E7CD9',['schafter6']='0x0x72934BE4',['schlagen']='0x0xE1C03AB0',['schwarzer']='0x0xD37B7976',['scorcher']='0x0xF4E1AA15',['scramjet']='0x0xD9F0503D',['scrap']='0x0x9A9FD3DF',['seabreeze']='0x0xE8983F9F',['seashark']='0x0xC2974024',['seashark2']='0x0xDB4388E4',['seashark3']='0x0xED762D49',['seasparrow']='0x0xD4AE63D9',['seasparrow2']='0x0x494752F7',['seasparrow3']='0x0x5F017E6B',['seminole']='0x0x48CECED3',['seminole2']='0x0x94114926',['sentinel']='0x0x50732C82',['sentinel2']='0x0x3412AE2D',['sentinel3']='0x0x41D149AA',['serrano']='0x0x4FB1A214',['seven70']='0x0x97398A4B',['shamal']='0x0xB79C1BF5',['sheava']='0x0x30D3F6D8',['sheriff']='0x0x9BAA707C',['sheriff2']='0x0x72935408',['shotaro']='0x0xE7D2A16E',['skylift']='0x0x3E48BF23',['slamtruck']='0x0xC1A8A914',['slamvan']='0x0x2B7F9DE3',['slamvan2']='0x0x31ADBBFC',['slamvan3']='0x0x42BC5E19',['slamvan4']='0x0x8526E2F5',['slamvan5']='0x0x163F8520',['slamvan6']='0x0x67D52852',['sovereign']='0x0x2C509634',['specter']='0x0x706E2B40',['specter2']='0x0x400F5147',['speeder']='0x0xDC60D2B',['speeder2']='0x0x1A144F2A',['speedo']='0x0xCFB3870C',['speedo2']='0x0x2B6DC64A',['speedo4']='0x0xD17099D',['squaddie']='0x0xF9E67C05',['squalo']='0x0x17DF5EC2',['stafford']='0x0x1324E960',['stalion']='0x0x72A4C31E',['stalion2']='0x0xE80F67EE',['stanier']='0x0xA7EDE74D',['starling']='0x0x9A9EB7DE',['stinger']='0x0x5C23AF9B',['stingergt']='0x0x82E499FA',['stockade']='0x0x6827CF72',['stockade3']='0x0xF337AB36',['stratum']='0x0x66B4FC45',['streiter']='0x0x67D2B389',['stretch']='0x0x8B13F083',['strikeforce']='0x0x64DE07A1',['stromberg']='0x0x34DBA661',['stryder']='0x0x11F58A5A',['stunt']='0x0x81794C70',['submersible']='0x0x2DFF622F',['submersible2']='0x0xC07107EE',['sugoi']='0x0x3ADB9758',['sultan']='0x0x39DA2754',['sultan2']='0x0x3404691C',['sultanrs']='0x0xEE6024BC',['suntrap']='0x0xEF2295C9',['superd']='0x0x42F2ED16',['supervolito']='0x0x2A54C47D',['supervolito2']='0x0x9C5E5644',['surano']='0x0x16E478C1',['surfer']='0x0x29B0DA97',['surfer2']='0x0xB1D80E06',['surge']='0x0x8F0E3594',['swift']='0x0xEBC24DF2',['swift2']='0x0x4019CB4C',['swinger']='0x0x1DD4C0FF',['t20']='0x0x6322B39A',['taco']='0x0x744CA80D',['tailgater']='0x0xC3DDFDCE',['taipan']='0x0xBC5DC07E',['tampa']='0x0x39F9C898',['tampa2']='0x0xC0240885',['tampa3']='0x0xB7D9F7F1',['tanker']='0x0xD46F4737',['tanker2']='0x0x74998082',['tankercar']='0x0x22EDDC30',['taxi']='0x0xC703DB5F',['technical']='0x0x83051506',['technical2']='0x0x4662BCBB',['technical3']='0x0x50D4D19F',['tempesta']='0x0x1044926F',['terbyte']='0x0x897AFC65',['tezeract']='0x0x3D7C6410',['thrax']='0x0x3E3D1F59',['thrust']='0x0x6D6F8F43',['thruster']='0x0x58CDAF30',['tigon']='0x0xAF0B8D48',['tiptruck']='0x0x2E19879',['tiptruck2']='0x0xC7824E5E',['titan']='0x0x761E2AD3',['toreador']='0x0x56C8A5EF',['torero']='0x0x59A9E570',['tornado']='0x0x1BB290BC',['tornado2']='0x0x5B42A5C4',['tornado3']='0x0x690A4153',['tornado4']='0x0x86CF7CDD',['tornado5']='0x0x94DA98EF',['tornado6']='0x0xA31CB573',['toro']='0x0x3FD5AA2F',['toro2']='0x0x362CAC6D',['toros']='0x0xBA5334AC',['tourbus']='0x0x73B1C3CB',['towtruck']='0x0xB12314E0',['towtruck2']='0x0xE5A2D6C6',['tr2']='0x0x7BE032C6',['tr3']='0x0x6A59902D',['tr4']='0x0x7CAB34D0',['tractor']='0x0x61D6BA8C',['tractor2']='0x0x843B73DE',['tractor3']='0x0x562A97BD',['trailerlarge']='0x0x5993F939',['trailerlogs']='0x0x782A236D',['trailers']='0x0xCBB2BE0E',['trailers2']='0x0xA1DA3C91',['trailers3']='0x0x8548036D',['trailers4']='0x0xBE66F5AA',['trailersmall']='0x0x2A72BEAB',['trailersmall2']='0x0x8FD54EBB',['trash']='0x0x72435A19',['trash2']='0x0xB527915C',['trflat']='0x0xAF62F6B2',['tribike']='0x0x4339CD69',['tribike2']='0x0xB67597EC',['tribike3']='0x0xE823FB48',['trophytruck']='0x0x612F4B6',['trophytruck2']='0x0xD876DBE2',['tropic']='0x0x1149422F',['tropic2']='0x0x56590FE9',['tropos']='0x0x707E63A4',['tug']='0x0x82CAC433',['tula']='0x0x3E2E4F8A',['tulip']='0x0x56D42971',['turismo2']='0x0xC575DF11',['turismor']='0x0x185484E1',['tvtrailer']='0x0x967620BE',['tyrant']='0x0xE99011C2',['tyrus']='0x0x7B406EFB',['utillitruck']='0x0x1ED0A534',['utillitruck2']='0x0x34E6BF6B',['utillitruck3']='0x0x7F2153DF',['vacca']='0x0x142E0DC3',['vader']='0x0xF79A00F7',['vagner']='0x0x7397224C',['vagrant']='0x0x2C1FEA99',['valkyrie']='0x0xA09E15FD',['valkyrie2']='0x0x5BFA5C4B',['vamos']='0x0xFD128DFD',['velum']='0x0x9C429B6A',['velum2']='0x0x403820E8',['verlierer2']='0x0x41B77FA4',['verus']='0x0x11CBC051',['vestra']='0x0x4FF77E37',['vetir']='0x0x780FFBD2',['veto']='0x0xCCE5C8FA',['veto2']='0x0xA703E4A9',['vigero']='0x0xCEC6B9B7',['vigilante']='0x0xB5EF4C33',['vindicator']='0x0xAF599F01',['virgo']='0x0xE2504942',['virgo2']='0x0xCA62927A',['virgo3']='0x0xFDFFB0',['viseris']='0x0xE8A8BA94',['visione']='0x0xC4810400',['volatol']='0x0x1AAD0DED',['volatus']='0x0x920016F1',['voltic']='0x0x9F4B77BE',['voltic2']='0x0x3AF76F4A',['voodoo']='0x0x779B4F2D',['voodoo2']='0x0x1F3766E3',['vortex']='0x0xDBA9DBFC',['vstr']='0x0x56CDEE7D',['warrener']='0x0x51D83328',['washington']='0x0x69F06B57',['wastelander']='0x0x8E08EC82',['weevil']='0x0x61FE4D6A',['windsor']='0x0x5E4327C8',['windsor2']='0x0x8CF5CAE1',['winky']='0x0xF376F1E6',['wolfsbane']='0x0xDB20A373',['xa21']='0x0x36B4A8A9',['xls']='0x0x47BBCF2E',['xls2']='0x0xE6401328',['yosemite']='0x0x6F946279',['yosemite2']='0x0x64F49967',['yosemite3']='0x0x409D787',['youga']='0x0x3E5F6B8',['youga2']='0x0x3D29CD2B',['youga3']='0x0x6B73A9BE',['z190']='0x0x3201DD49',['zentorno']='0x0xAC5DF515',['zhaba']='0x0x4C8DBA51',['zion']='0x0xBD1B39C3',['zion2']='0x0xB8E2AE18',['zion3']='0x0x6F039A67',['zombiea']='0x0xC3D7C72B',['zombieb']='0x0xDE05FB87',['zorrusso']='0x0xD757D97D',['zr380']='0x0x20314B42',['zr3802']='0x0xBE11EFC6',['zr3803']='0x0xA7DCC35C',['ztype']='0x0x2D3BD401'}
config.custom_engine_enable = true -- enable custom engine
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
	[`b16b`] = {custom = true, turboinstall = false, handlingName = 'b16b', label = 'Ek9 B16b Type R', soundname = 'ruston', fMass = '800.000000', nInitialDriveGears = 5, fInitialDriveForce = 0.425000, fDriveInertia = 1.200000, fClutchChangeRateScaleUpShift = 8.200000, fClutchChangeRateScaleDownShift = 8.200000, fInitialDriveMaxFlatVel = 178.000000, },
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
        [2] = 0.57,
        [3] = 0.84,
        [4] = 1.08,
        [5] = 1.28,
        [6] = 1.42,
        [7] = 1.75,
        [8] = 1.97
    }
}
config.firstgear = 0.33 -- DEFAULT 0.33
config.secondgear = 0.57 -- DEFAULT 0.57
config.thirdgear = 0.84 -- DEFAULT 0.84
config.fourthgear = 1.22 -- DEFAULT 1.22
config.fifthgear = 1.45 -- DEFAULT 1.45
config.sixthgear = 1.60 -- DEFAULT 1.60
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
config.rpm_speed_loop = 52
config.idle_rpm_speed_sleep = 151
config.Rpm_sleep = 250
config.Rpm_sleep_2 = 52
config.Speed_sleep = 151
config.Speed_sleep_2 = 52
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
    ForceVehicleGear(vehicle, gear)
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
-------------------------------------------https://github.com/renzuzu/renzu_hud----------------------------------------------------------
--------------------------------------------------------------VARIABLES------------------------------------------------------------------
identifier=nil;lastveh = nil;newdate = nil;healing=nil;alreadyblackout = false;regdecor=false;busy = false;turbosound = 0;oldgear = 0;newgear = 0;rpm2 = 0;propturbo = nil;boost = 1.0;old_diff = nil;togglediff = false;cruising = false;lastdamage = nil;oldlife = 200;windowbones = {[0] = 'window_rf',[1] = 'window_lf',[2] = 'window_rr',[3] = 'window_lr'};carcontrol = false;isbusy = false;oldweapon = nil;weaponui = false;wstatus = {};trail = {};nitromode = false;lightshit = {};light_trail_isfuck = false;purgefuck = false;purgeshit = {};pressed = false;proptire = nil;keyless = false;hasmask=false;hashelmet = false;imbusy = true;carstatus = false;enginelist = {};syncengine = {};syncveh = {};ped = nil;playerNamesDist = 3;key_holding = false;particlesfire = {};particleslight = {};charslot = nil;pedshot = false;lastped = nil;dummyskin = {};show = false;notifycd = {};statuses = {};vitals = {};statusloop = -1;garbage = 0;start = false;breakstart = false;lastplate = nil;notloaded = true;minimap=nil;shooting = false;busyplate = {};busyairsus = false;crosshair = 1;flametable = {};spool = false;shouldUpdateSkin = false;pedSkin = {};oldclothes = nil;clothestate = {};dummyskin1 = {};sounded = false;left = false;right = false;hazard = false;state = false;turbo = config.boost;newstreet = nil;newmic = nil;newhealth = 1111;newarmor = 1111;triggered = false;cansmoke = true;refresh = false;veh_stats_loaded = false;finaldrive = 0;flywheel = 0;maxspeed = 0;currentengine={};headshot = nil;enginespec=false;handlings={};vehiclehandling={};boost=1.0;correctgears=1;gear=1;plate=nil;loadedplate=false;maxgear=5;pid=nil;veh_stats=nil;Renzuzu=Citizen;entering=false;mode='NORMAL'ismapopen=false;date="00:00"plate=nil;degrade=1.0;playerloaded=false;manual=false;vehicletopspeed=nil;uimove=false;reverse=false;savegear=0;rpm=0.2;hour=0;vali=false;minute=0;globaltopspeed=nil;segundos=0;month=""dayOfMonth=0;voice=2;voiceDisplay=2;proximity=25.0;belt=false;ExNoCarro=false;sBuffer={}vBuffer={}displayValue=true;gasolina=0;street=nil;vehicle=nil;hp=0;shifter=false;hasNitro=true;k_nitro=70;n_boost=15.0;boost=1.0;nitro_state=100;isBlack="false"invehicle=false;topspeedmodifier=1.0;switch=false;life=100;receive='new'bodystatus={}bonecategory={}parts={}bodyui=false;body=false;arm=false;armbone=0;armbone2=0;leg=false;head=false;shooting=false;manualstatus=false;traction=nil;traction2=nil;alreadyturbo=false;Creation=Renzuzu.CreateThread;Renzu_Hud=Renzuzu.InvokeNative;ClientEvent=TriggerEvent;RenzuNetEvent=RegisterNetEvent;RenzuEventHandler=AddEventHandler;RenzuCommand=RegisterCommand;RenzuSendUI=SendNUIMessage;RenzuKeybinds=RegisterKeyMapping;RenzuNuiCallback=RegisterNUICallback;ReturnFloat=Renzuzu.ResultAsFloat();ReturnInt=Renzuzu.ResultAsInteger()
-----------------------------------------------------------------------------------------------------------------------------------------