
config.enable_carui = true -- enable/disable the car UI (THIS WILL DISABLE ALL VEHICLE FUNCTION AS WELL)
config.carui = 'simple' -- Choose a Carui Version ( simple, minimal, modern )
config.carui_metric = 'mph' -- Speed Metrics to Use 'kmh' or 'mph'
config.WaypointMarkerLarge = false -- disable / enable large marker while on vehicle waypoint
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

--start car map
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound) (MP3 not implemented yet..lazy..)
config.mapversion = 'satellite' -- available ( satellite, atlas, oldschool )
config.usecustomlink = true -- use custom url of image map // use this for now , self hosted is remove due to file size issue
config.push_start = false -- enable/disable push to start for modern UI
config.mapurl = 'https://github.com/renzuzu/carmap/blob/main/carmap/atlas.webp?raw=true' -- if use custom url define it
--atlas link https://github.com/renzuzu/carmap/blob/main/carmap/oldschool.webp?raw=true
--satellite link https://github.com/renzuzu/carmap/blob/main/carmap/satellite.webp
--credits https://github.com/jgardner117/gtav-interactive-map

--OVERHEAT FUNC
config.engineoverheat = false -- ENGINE EXPLODE AND OVERHEAT FEATURE (IF REVING 9200 RPM ABOVE Engine Temperature will rise, explode it if too hot , temp value = 150)
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
config.boost = 1.15 -- Boost Level when sports mode is activated eg. 1.5 Bar, you can put upt o 3.0 or even 5.0 but pretty sure it will be unrealistic acceleration ( this affect Fuel Consumption )
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

config.enablecarcontrol = false -- car functions
config.allowoutsideofvehicle = true -- allow car control outside of vehicle (nearest vehicle and lastvehicle)
config.enableairsuspension = true -- adjustable vehicle height
config.airsuspension_item = true -- if true airsuspension func will not work if its not installed
config.enableneontoggle = true -- toggable neon lights
config.wheelstancer = true -- allow players to adjust the wheelxoffset and wheelyrotation
--NITRO
config.enablenitro = false
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
config.enabletiresystem = false -- Enable Tire System, Custom Tire Health System, Saved in DB, Sync all to player, using adv_stat table in database
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

--carstatus
config.carstatus = false -- use car status system, shows vehicle infos etc..
config.carstatus_jobonly = false -- allowed the car status ui only to designated jobs
config.carstatus_job = 'mechanic'

--ENGINE SYSTEM
config.customengine = false -- enable/disable custom vehicle engine, custom sounds
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

config.manualhud = true -- enable manual gears hud
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
config.drift_handlings = {
	{'fInitialDriveMaxFlatVel',380.000000},
	-- {'fDriveInertia', 3.000000},
	-- {'fInitialDriveForce', 2.200000},
	{'fMass', 700.000000},
	{'fInitialDragCoeff',0.500000},
	{'fPercentSubmerged',85.000000},
	{'vecCentreOfMassOffset', vector3(0.000000,-0.100000,-0.100000)},
	{'vecInertiaMultiplier', vector3(1.200000,1.400000,2.000000)},
	{'fDriveBiasFront',0.000000},
	{'fClutchChangeRateScaleUpShift',51.300000},
	{'fClutchChangeRateScaleDownShift',51.300000},
	--{'fInitialDriveMaxFlatVel',380.000000},
	{'fSteeringLock',55.000000},
	{'fTractionCurveMax',1.040000,0.840000},
	{'fTractionCurveMin',1.200000,1.400000},
	{'fTractionCurveLateral',45.500000},
	{'fTractionSpringDeltaMax',0.110000},
	{'fLowSpeedTractionLossMult',0.200000},
	{'fCamberStiffnesss',0.000000},
	{'fTractionBiasFront',0.420000},
	{'fTractionLossMult',0.950000},
	{'fSuspensionForce',2.200000},
	{'fSuspensionCompDamp',2.200000},
	{'fSuspensionReboundDamp',2.100000},
	{'fSuspensionUpperLimit',0.030000},
	{'fSuspensionLowerLimit',-0.030000},
	{'fSuspensionRaise',-0.000000},
	{'fSuspensionBiasFront',0.550000},
	{'fAntiRollBarForce',0.800000},
	{'fAntiRollBarBiasFront',0.430000},
	{'fRollCentreHeightFront',0.150000},
	{'fRollCentreHeightRear',0.150000},
}
-- if not config.driftmodeAddpower then
-- 	-- print(config.drift_handlings[1][1])
-- 	-- config.drift_handlings[1][1] = nil
-- 	-- config.drift_handlings[1][2] = nil
-- 	-- print(config.drift_handlings[1][1])
-- end