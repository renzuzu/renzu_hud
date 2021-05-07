config = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
identifier = nil
veh_stats = nil
Renzuzu = Citizen
entering = false
mode = 'NORMAL'
ismapopen = false
date = "00:00"
plate = nil
degrade = 1.0
playerloaded = false
manual = false
vehicletopspeed = nil
uimove = false
reverse = false
savegear = 0
rpm = 0.2
hour = 0
vali = false
minute = 0
globaltopspeed = nil
segundos = 0
month = ""
dayOfMonth = 0
voice = 2
voiceDisplay = 2
proximity = 25.0
belt = false
ExNoCarro = false
sBuffer = {}
vBuffer = {}
displayValue = true
gasolina = 0
street = nil
vehicle = nil
hp = 0
shifter = false
hasNitro = true
k_nitro = 70
n_boost = 15.0
boost = 1.0
nitro_state = 100
isBlack = "false"
invehicle = false
topspeedmodifier = 1.0
switch = false
life = 100
receive = 'new'
bodystatus = {}
bonecategory = {}
parts = {}
bodyui = false
body = false
arm = false
armbone = 0
armbone2 = 0
leg = false
head = false
shooting = false
manualstatus = false
traction = nil
traction2 = nil

config.framework = 'ESX' -- ESX | VRP | QSHIT | STANDALONE

--MAIN UI CONFIG START
config.enablecompass = true -- enable/disable compass
config.carui = 'modern' -- Choose a Carui Version ( simple, minimal, modern )
config.statusui = 'normal' -- UI LOOK ( simple, normal)
config.statusv2 = true -- enable this if you want the status hud in bottom part , false if toggle mode (TOGGLE VIA INSERT)
--CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD
--UI CONFIG END
--start car map
config.centercarhud = 'map' -- Feature of Car hud - MAP , MP3 (IF YOU CHOOSE MP3 you need renzu_mp3 as dependency, and renzu_mp3 need xsound)
config.mapversion = 'atlas' -- available ( satellite, atlas, oldschool )
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
-- Vehicle Mode
config.boost = 1.0 -- Boost Level when sports mode is activated eg. 1.5 Bar, you can put upt o 3.0 or even 5.0 but pretty sure it will be unrealistic acceleration ( this affect Fuel Consumption )
config.sports_increase_topspeed = true -- do you want the topspeed will be affected? some Fivem Servers Likes a demonic topspeed :D - not good in RP. Boost only affects engine torque and horsepower not the gear ratio and final drive of transmision which affects topspeed
config.topspeed_multiplier = 1.1 -- if sports_increase_topspeed is enable, multiplier 1.5 = x1.5 eg. normal top speed 200kmh if you put 1.5 the new topspeed is 300kmh
config.eco = 0.5 -- Eco Level when Eco Mode is activated (this affect the efficiency of fuel)
config.boost_sound = false
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
}
config.status = { -- maximum 4 only for now, and it is preconfigured, (this is not the ordering for ui).
	'energy',
	'thirst',
	'sanity',
	'hunger'
}
-- BODY STATUS
config.bodystatus = true -- ENABLE BODY STATUS FUNCTION AND UI?
config.damageadd = 1 -- HOW MUCH THE VALUE WE WANT TO SAVE TO DATABASE FOR EACH DAMAGE RECEIVE?
config.weaponsonly = false -- Body Status Damages applies from weapons only? eg. pistol,etc anything with bullets. else it all applies to weapons,bullets, melee combat, falling in high grounds like posts,ram by a car etc..
config.bodystatuswait = 1000 -- how fast (in ms) we need to check if player is already taken a damage?
config.headtimecycle = 'RaceTurboLight' -- timecycle effect when player head is injured
config.legeffectmovement = 0.73 -- movement speed modifier if player leg is injured ( 1.0 = 100%)
config.legeffect_disabledjump = true -- disable jump while leg is in pain
config.thirdperson_armrecoil = '0.4' -- recoil effect when player arm is injured (third person)
config.firstperson_armrecoil = '0.5' -- recoil effect when player arm is injured (first person)
config.chesteffect_healthdegrade = 1 -- reduce player health every 5 sec
config.chesteffect_minhealth = 140 -- minimum health to maintain during chest injury. 140 points = 40% (some rp server)
config.disabledregen = true -- disable health regen while chest is in pain
config.disabledsprint = true -- disable sprint while chest is in pain
config.bodyinjury_status_affected = true
config.headbone_status = 'sanity' -- Each time the Player Head Bone is damaged, status should be affected? , Select a status name: eg. stress, sanity, etc. poop!
config.headbone_status_mode = 'add' -- should we add or remove? (remove/add)
config.headbone_status_value = 40000 -- value to add or remove
config.armdamage_invehicle_effect = 5.0 -- If Arm is in injury, Steering lock is reduce? its like the player will be having a hardtime of steering the vehicle wheel.
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
config.buto = { -- do not edit (LINK https://gtaforums.com/topic/801074-list-of-entity-bone-index-hashes/) and LINK https://wiki.gtanet.work/index.php?title=Bones
  ["ped_body"] = {
    SKEL_Pelvis1 = 0xD003,
    SKEL_PelvisRoot = 0x45FC,
    SKEL_SADDLE = 0x9524,
	SKEL_ROOT = 0x0,
    SKEL_Pelvis = 0x2E28, 
    SKEL_Spine_Root = 0xE0FD,
    SM_M_BackSkirtRoll = 0xDBB,
    SM_M_FrontSkirtRoll = 0xCDBB,
    SM_CockNBalls_ROOT = 0xC67D,
    SM_CockNBalls = 0x9D34, 
    BagRoot = 0xAD09,
    BagPivotROOT = 0xB836,
    BagPivot = 0x4D11,
	SKEL_Spine0 = 0x5C01,
    SKEL_Spine1 = 0x60F0,
    SKEL_Spine2 = 0x60F1,
    SKEL_Spine3 = 0x60F2,
    SPR_L_Breast = 0xFC8E,
    SPR_R_Breast = 0x885F,
    IK_Root = 0xDD1C,
    SM_LifeSaver_Front = 0x9420,
    SM_R_Pouches_ROOT = 0x2962,
    SM_R_Pouches = 0x4141,
    SM_L_Pouches_ROOT = 0x2A02,
    SM_L_Pouches = 0x4B41,
    SM_Suit_Back_Flapper = 0xDA2D,
    SPR_CopRadio = 0x8245,
    SM_LifeSaver_Back = 0x2127,
	BagBody = 0xAB6D,
    BagBone_R = 0x937,
    BagBone_L = 0x991,
    MH_BlushSlider = 0xA0CE,
    SKEL_Tail_01 = 0x347,
    SKEL_Tail_02 = 0x348,
    MH_L_Concertina_B = 0xC988,
    SKEL_Tail_04 = 0x34A,
    SKEL_Tail_05 = 0x34B,
    SPR_Gonads_ROOT = 0xBFDE,
    SPR_Gonads = 0x1C00,
	MH_L_Concertina_A = 0xC987,
    MH_R_Concertina_B = 0xC8E8,
    MH_R_Concertina_A = 0xC8E7,
    SKEL_Tail_03 = 0x349,
  },

  ["ped_head"] = {
    SKEL_Neck_1 = 0x9995,
    SKEL_Head = 0x796E,
	FACIAL_facialRoot = 0xFE2C,
    FB_L_Brow_Out_000 = 0xE3DB,
    FB_L_Lid_Upper_000 = 0xB2B6,
    FB_R_Eye_000 = 0x6B52,
    FB_R_CheekBone_000 = 0x4B88,
    FB_R_Brow_Out_000 = 0x54C,
	IK_Head = 0x322C,
    FB_L_Eye_000 = 0x62AC,
	FB_Tongue_000 = 0xB987,
    RB_Neck_1 = 0x8B93,
    SKEL_Neck_2 = 0x5FD4,
    FACIAL_jaw = 0xB21,
    FACIAL_underChin = 0x8A95,
    FB_L_CheekBone_000 = 0x542E,
    FB_L_Lip_Corner_000 = 0x74AC,
    FB_R_Lid_Upper_000 = 0xAA10,
    FB_R_Lip_Corner_000 = 0x2BA6,
    FB_R_Lip_Top_000 = 0x4537,
    FB_Jaw_000 = 0xB4A0,
	FACIAL_L_tongueD = 0x35F1,
    FACIAL_R_tongueD = 0x2FF1,
    FACIAL_L_tongueC = 0x35F0,
    FACIAL_R_tongueC = 0x2FF0,
    FACIAL_L_tongueB = 0x35EF,
    FACIAL_R_tongueB = 0x2FEF,
	FACIAL_R_tongueA = 0x2FEE,
    FACIAL_chinSkinTop = 0x7226,
    FACIAL_L_chinSkinTop = 0x3EB3,
    FACIAL_chinSkinMid = 0x899A,
    FACIAL_L_chinSkinMid = 0x4427,
	FB_Brow_Centre_000 = 0x9149,
    FB_UpperLipRoot_000 = 0x4ED2,
    FB_UpperLip_000 = 0xF18F,
    FB_L_Lip_Top_000 = 0x4F37,
    FB_LowerLipRoot_000 = 0x4324,
    FB_LowerLip_000 = 0x508F,
	FACIAL_tongueA = 0x4A7C,
    FACIAL_tongueB = 0x4A7D,
    FACIAL_tongueC = 0x4A7E,
    FACIAL_tongueD = 0x4A7F,
    FB_L_Lip_Bot_000 = 0xB93B,
    FB_R_Lip_Bot_000 = 0xC33B,
    FACIAL_L_underChin = 0x234E,
    FACIAL_chin = 0xB578,
    FACIAL_chinSkinBottom = 0x98BC,
    FACIAL_L_chinSkinBottom = 0x3E8F,
    FACIAL_R_chinSkinBottom = 0x9E8F,
    FACIAL_tongueE = 0x4A80,
    FACIAL_L_tongueE = 0x35F2,
    FACIAL_R_tongueE = 0x2FF2,
    FACIAL_L_tongueA = 0x35EE,
    FACIAL_L_chinSide = 0x4A5E,
    FACIAL_R_chinSkinMid = 0xF5AF,
    FACIAL_R_chinSkinTop = 0xF03B,
    FACIAL_R_chinSide = 0xAA5E,
    FACIAL_R_underChin = 0x2BF4,
    FACIAL_L_lipLowerSDK = 0xB9E1,
    FACIAL_L_lipLowerAnalog = 0x244A,
    FACIAL_L_lipLowerThicknessV = 0xC749,
    FACIAL_L_lipLowerThicknessH = 0xC67B,
    FACIAL_R_lipLowerSDK = 0xA034,
    FACIAL_R_lipLowerAnalog = 0xC2D9,
    FACIAL_R_lipLowerThicknessV = 0xC6E9,
    FACIAL_R_lipLowerThicknessH = 0xC6DB,
    FACIAL_nose = 0x20F1,
    FACIAL_L_nostril = 0x7322,
    FACIAL_L_nostrilThickness = 0xC15F,
    FACIAL_noseLower = 0xE05A,
    FACIAL_L_noseLowerThickness = 0x79D5,
    FACIAL_R_noseLowerThickness = 0x7975,
    FACIAL_noseTip = 0x6A60,
    FACIAL_R_nostril = 0x7922,
	FACIAL_lipLowerSDK = 0x7285,
    FACIAL_lipLowerAnalog = 0xD97B,
    FACIAL_lipLowerThicknessV = 0xC5BB,
    FACIAL_lipLowerThicknessH = 0xC5ED,
	FACIAL_R_cheekLowerBulge1 = 0x599B,
    FACIAL_R_cheekLowerBulge2 = 0x599C,
    FACIAL_R_masseter = 0x810,
    FACIAL_R_jawRecess = 0x93D4,
    FACIAL_R_ear = 0x1137,
    FACIAL_R_earLower = 0x8031,
    FACIAL_R_nostrilThickness = 0x36FF,
    FACIAL_noseUpper = 0xA04F,
    FACIAL_L_noseUpper = 0x1FB8,
    FACIAL_noseBridge = 0x9BA3,
    FACIAL_L_nasolabialFurrow = 0x5ACA,
    FACIAL_L_nasolabialBulge = 0xCD78,
    FACIAL_L_eyeball = 0x1744,
    FACIAL_L_eyelidLower = 0x998C,
    FACIAL_L_eyelidLowerOuterSDK = 0xFE4C,
    FACIAL_L_eyelidLowerOuterAnalog = 0xB9AA,
    FACIAL_L_eyelashLowerOuter = 0xD7F6,
    FACIAL_L_eyelidLowerInnerSDK = 0xF151,
    FACIAL_L_eyelidLowerInnerAnalog = 0x8242,
    FACIAL_L_eyelashLowerInner = 0x4CCF,
    FACIAL_L_eyelidUpper = 0x97C1,
	FB_TongueC_000 = 0x4208,  
    FB_L_Brow_Out_001 = 0xE3DB,
    FB_L_Lid_Upper_001 = 0xB2B6,
	MH_MulletRoot = 0x3E73,
    MH_MulletScaler = 0xA1C2,
    MH_Hair_Scale = 0xC664,
    MH_Hair_Crown = 0x1675,
    FB_L_Eye_001 = 0x62AC,
    FACIAL_L_eyelidUpperOuterSDK = 0xAF15,
    FACIAL_L_eyelidUpperOuterAnalog = 0x67FA,
    FACIAL_L_eyelashUpperOuter = 0x27B7,
	FACIAL_L_cheekLower = 0x6907,
    FACIAL_L_cheekLowerBulge1 = 0xE3FB,
    FACIAL_L_cheekLowerBulge2 = 0xE3FC,
    FACIAL_L_cheekInner = 0xE7AB,
    FACIAL_L_cheekOuter = 0x8161,
    FACIAL_L_eyesackLower = 0x771B,
    FACIAL_L_eyelidUpperInnerSDK = 0xD341,
    FACIAL_L_eyelidUpperInnerAnalog = 0xF092,
    FACIAL_L_eyelashUpperInner = 0x9B1F,
    FACIAL_L_eyesackUpperOuterBulge = 0xA559,
    FACIAL_L_foreheadInnerBulge = 0x767C,
    FACIAL_L_foreheadOuter = 0x8DCB,
    FACIAL_skull = 0x4221,
    FACIAL_foreheadUpper = 0xF7D6,
    FACIAL_L_foreheadUpperInner = 0xCF13,
    FACIAL_L_foreheadUpperOuter = 0x509B,
    FACIAL_R_foreheadUpperInner = 0xCEF3,
    FACIAL_R_foreheadUpperOuter = 0x507B,
    FACIAL_L_temple = 0xAF79,
    FACIAL_L_ear = 0x19DD,
    FACIAL_L_earLower = 0x6031,
    FACIAL_L_masseter = 0x2810,
    FACIAL_L_jawRecess = 0x9C7A,
	FACIAL_L_eyesackUpperInnerBulge = 0x2F2A,
    FACIAL_L_eyesackUpperOuterFurrow = 0xC597,
    FACIAL_L_eyesackUpperInnerFurrow = 0x52A7,
    FACIAL_forehead = 0x9218,
    FACIAL_L_foreheadInner = 0x843,
    FACIAL_L_cheekOuterSkin = 0x14A5,
    FACIAL_R_cheekLower = 0xF367,
    FACIAL_R_eyesackLower = 0x777B,
    FACIAL_R_nasolabialBulge = 0xD61E,
    FACIAL_R_cheekOuter = 0xD32,
    FACIAL_R_cheekInner = 0x737C,
    FACIAL_R_noseUpper = 0x1CD6,
    FACIAL_R_foreheadInner = 0xE43,
    FACIAL_R_foreheadInnerBulge = 0x769C,
    FACIAL_R_foreheadOuter = 0x8FCB,
    FACIAL_R_cheekOuterSkin = 0xB334,
    FACIAL_R_eyesackUpperInnerFurrow = 0x9FAE,
    FACIAL_R_eyesackUpperOuterFurrow = 0x140F,
    FACIAL_R_eyesackUpperInnerBulge = 0xA359,
    FACIAL_R_eyesackUpperOuterBulge = 0x1AF9,
    FACIAL_R_nasolabialFurrow = 0x2CAA,
    FACIAL_R_temple = 0xAF19,
    FACIAL_R_eyeball = 0x1944,
    FACIAL_R_eyelidUpper = 0x7E14,
    FACIAL_R_eyelidUpperOuterSDK = 0xB115,
    FACIAL_R_eyelidUpperOuterAnalog = 0xF25A,
    FACIAL_R_eyelashUpperOuter = 0xE0A,
    FACIAL_R_eyelidLowerInnerAnalog = 0xE13,
    FACIAL_R_eyelashLowerInner = 0x3322,
    FACIAL_L_lipUpperSDK = 0x8F30,
    FACIAL_L_lipUpperAnalog = 0xB1CF,
    FACIAL_L_lipUpperThicknessH = 0x37CE,
    FACIAL_L_lipUpperThicknessV = 0x38BC,
    FACIAL_lipUpperSDK = 0x1774,
    FACIAL_lipUpperAnalog = 0xE064,
    FACIAL_lipUpperThicknessH = 0x7993,
    FACIAL_lipUpperThicknessV = 0x7981,
    FACIAL_L_lipCornerSDK = 0xB1C,
    FACIAL_L_lipCornerAnalog = 0xE568,
    FACIAL_L_lipCornerThicknessUpper = 0x7BC,
    FACIAL_L_lipCornerThicknessLower = 0xDD42,
    FACIAL_R_lipUpperSDK = 0x7583,
	FACIAL_R_eyelidUpperInnerSDK = 0xD541,
    FACIAL_R_eyelidUpperInnerAnalog = 0x7C63,
    FACIAL_R_eyelashUpperInner = 0x8172,
    FACIAL_R_eyelidLower = 0x7FDF,
    FACIAL_R_eyelidLowerOuterSDK = 0x1BD,
    FACIAL_R_eyelidLowerOuterAnalog = 0x457B,
    FACIAL_R_eyelashLowerOuter = 0xBE49,
    FACIAL_R_eyelidLowerInnerSDK = 0xF351,
    FACIAL_R_lipUpperAnalog = 0x51CF,
    FACIAL_R_lipUpperThicknessH = 0x382E,
    FACIAL_R_lipUpperThicknessV = 0x385C,
    FACIAL_R_lipCornerSDK = 0xB3C,
    FACIAL_R_lipCornerAnalog = 0xEE0E,
    FACIAL_R_lipCornerThicknessUpper = 0x54C3,
    FACIAL_R_lipCornerThicknessLower = 0x2BBA,
    FB_R_Ear_000 = 0x6CDF,
    SPR_R_Ear = 0x63B6,
    FB_L_Ear_000 = 0x6439,
    SPR_L_Ear = 0x5B10,
    FB_TongueA_000 = 0x4206,
    FB_TongueB_000 = 0x4207,
    FB_L_CheekBone_001 = 0x542E,
    FB_L_Lip_Corner_001 = 0x74AC,
    FB_R_Lid_Upper_001 = 0xAA10,
    FB_R_Eye_001 = 0x6B52,
    FB_L_Lip_Top_001 = 0x4F37,
    FB_R_Lip_Top_001 = 0x4537,
    FB_Jaw_001 = 0xB4A0,
    FB_LowerLipRoot_001 = 0x4324,
    FB_LowerLip_001 = 0x508F,
    FB_L_Lip_Bot_001 = 0xB93B,
    FB_R_Lip_Bot_001 = 0xC33B,
	FB_R_CheekBone_001 = 0x4B88,
    FB_R_Brow_Out_001 = 0x54C,
    FB_R_Lip_Corner_001 = 0x2BA6,
    FB_Brow_Centre_001 = 0x9149,
    FB_UpperLipRoot_001 = 0x4ED2,
    FB_UpperLip_001 = 0xF18F,
    FB_Tongue_001 = 0xB987,
  },   

  ["left_hand"] = {
    SKEL_L_Clavicle = 0xFCD9,
    SKEL_L_Hand = 0x49D9,
    SKEL_L_Finger12 = 0x104A,
    SKEL_L_Finger20 = 0x67F4,
    SKEL_L_Finger21 = 0x1059,
	SKEL_L_UpperArm = 0xB1C5,
    SKEL_L_Forearm = 0xEEEB,
    SKEL_L_Finger22 = 0x105A,
    SKEL_L_Finger30 = 0x67F5,
	MH_L_Elbow = 0x58B7,
    MH_L_Finger00 = 0x8C63,
    MH_L_FingerBulge00 = 0x5FB8,
    MH_L_Finger10 = 0x8C53,
    MH_L_FingerTop00 = 0xA244,
    MH_L_HandSide = 0xC78A,
	SKEL_L_Finger00 = 0x67F2,
    SKEL_L_Finger01 = 0xFF9,
    SKEL_L_Finger02 = 0xFFA,
    SKEL_L_Finger10 = 0x67F3,
    SKEL_L_Finger11 = 0x1049,
    SKEL_L_Finger31 = 0x1029,
    PH_L_Hand = 0xEB95,
    IK_L_Hand = 0x8CBD,
    RB_L_ForeArmRoll = 0xEE4F,
    RB_L_ArmRoll = 0x1470,
	SKEL_L_Finger32 = 0x102A,
    SKEL_L_Finger40 = 0x67F6,
    SKEL_L_Finger41 = 0x1039,
    SKEL_L_Finger42 = 0x103A,
    MH_Watch = 0x2738,
    MH_L_Sleeve = 0x933C,
  },

  ["left_leg"] = {
    SKEL_L_Thigh = 0xE39F,
    SKEL_L_Calf = 0xF9BB,
	MH_L_ThighBack = 0x600D,
    SM_L_Skirt = 0xC419,
    SM_L_BackSkirtRoll = 0x40B2,
    SM_L_FrontSkirtRoll = 0x9B69,
    SKEL_L_Toe1 = 0x1D6B,
    SKEL_L_Foot = 0x3779,
    PH_L_Foot = 0xE175,
    MH_L_Knee = 0xB3FE,
    RB_L_ThighRoll = 0x5C57,
    MH_L_CalfBack = 0x1013,
	SKEL_L_Toe0 = 0x83C,
    EO_L_Foot = 0x84C5,
    EO_L_Toe = 0x68BD,
    IK_L_Foot = 0xFEDD,
  },

  ["right_leg"] = {
    SKEL_R_Thigh = 0xCA72,
    EO_R_Toe = 0x7163,
    IK_R_Foot = 0x8AAE,
    PH_R_Foot = 0x60E6,
	SKEL_R_Toe0 = 0x512D,
    EO_R_Foot = 0x1096,
    SM_R_BackSkirtRoll = 0xC141,
    SM_R_FrontSkirtRoll = 0x86F1,
    SKEL_R_Toe1 = 0xB23F,
    MH_R_Knee = 0x3FCF,
	SKEL_R_Calf = 0x9000,
    SKEL_R_Foot = 0xCC4D,
	RB_R_ThighRoll = 0x192A,
    MH_R_CalfBack = 0xB013,
    MH_R_ThighBack = 0x51A3,
    SM_R_Skirt = 0x7712,
  },

  ["right_hand"] = {
	SKEL_R_UpperArm = 0x9D4D,
	SKEL_R_Hand = 0xDEAD,
    SKEL_R_Finger00 = 0xE5F2,
    SKEL_R_Finger01 = 0xFA10,
    SKEL_R_Clavicle = 0x29D2,
    SKEL_R_Forearm = 0x6E5C,
    SKEL_R_Finger02 = 0xFA11,
	SKEL_R_Finger31 = 0xFA40,
	MH_R_ShoulderBladeRoot = 0x3A0A,
    MH_R_ShoulderBlade = 0x54AF,
    SKEL_R_Finger40 = 0xE5F6,
    SKEL_R_Finger41 = 0xFA50,
    SKEL_R_Finger42 = 0xFA51,
    SKEL_R_Finger10 = 0xE5F3,
    SKEL_R_Finger32 = 0xFA41,
	MH_R_HandSide = 0x68FB,
    MH_R_Sleeve = 0x92DC, 
    SM_Torch = 0x8D6,
    FX_Light = 0x8959,
    FX_Light_Scale = 0x5038,
    FX_Light_Switch = 0xE18E,
    SKEL_R_Finger22 = 0xFA71,
    SKEL_R_Finger30 = 0xE5F5,
    PH_R_Hand = 0x6F06,
    IK_R_Hand = 0x188E,
    RB_R_ForeArmRoll = 0xAB22,
    RB_R_ArmRoll = 0x90FF,
    MH_R_Elbow = 0xBB0,
    MH_R_FingerTop00 = 0xEF4B,
    MH_L_ShoulderBladeRoot = 0x8711,
    MH_L_ShoulderBlade = 0x4EAF,
	MH_R_Finger00 = 0x2C63,
    MH_R_FingerBulge00 = 0x69B8,
    MH_R_Finger10 = 0x2C53,
	SKEL_R_Finger11 = 0xFA60,
    SKEL_R_Finger12 = 0xFA61,
    SKEL_R_Finger20 = 0xE5F4,
    SKEL_R_Finger21 = 0xFA70,
  },
}
--changable to status is sanity or energy you can rename it for example: stress, but it works the same way. (changing the status name is for advanced user only, dont change it if you are not sure) you might want to use renzu_status (AKA standalone_status) converted esx_status to standalone framework, using that the status will work 100%.

--WEAPON UI
config.weaponsui = true -- enable weapon ui
config.crosshairenable = true -- enable custom crosshair
config.crosshair = 1 -- index number of custom crosshair ( 1-5 )
config.ammoupdatedelay = 300 -- delay update for bullets ui
--WEAPONTABLE do not edit this (only if you will add new weapons)
config.WeaponTable = { -- do not edit! unless your gonna add new weapons ( HASHES SOURCE LINK https://wiki.rage.mp/index.php?title=Weapons)
  melee = {
    dagger = "0x92A27487",
    bat = "0x958A4A8F",
    bottle = "0xF9E6AA4B",
    crowbar = "0x84BD7BFD",
    unarmed = "0xA2719263",
    flashlight = "0x8BB05FD7",
    golfclub = "0x440E4788",
    hammer = "0x4E875F73",
    hatchet = "0xF9DCBF2D",
    knuckle = "0xD8DF3C3C",
    knife = "0x99B507EA",
    machete = "0xDD5DF8D9",
    switchblade = "0xDFE37640",
    nightstick = "0x678B81B1",
    wrench = "0x19044EE0",
    battleaxe = "0xCD274149",
    poolcue = "0x94117305",
    stone_hatchet = "0x3813FC08"
  },
  handguns = {
    pistol = "0x1B06D571",
    pistol_mk2 = "0xBFE256D4",
    combatpistol = "0x5EF9FEC4",
    appistol = "0x22D8FE39",
    stungun = "0x3656C8C1",
    pistol50 = "0x99AEEB3B",
    snspistol = "0xBFD21232",
    snspistol_mk2 = "0x88374054",
    heavypistol = "0xD205520E",
    vintagepistol = "0x83839C4",
    flaregun = "0x47757124",
    marksmanpistol = "0xDC4DB296",
    revolver = "0xC1B3C3D1",
    revolver_mk2 = "0xCB96392F",
    doubleaction = "0x97EA20B8",
    raypistol = "0xAF3696A1",
    ceramicpistol = "0x2B5EF5EC",
    navyrevolver = "0x917F6C8C"
  },
  smg = {
    microsmg = "0x13532244",
    smg = "0x2BE6766B",
    smg_mk2 = "0x78A97CD0",
    assaultsmg = "0xEFE7E2DF",
    combatpdw = "0xA3D4D34",
    machinepistol = "0xDB1AA450",
    minismg = "0xBD248B55",
    raycarbine = "0x476BF155"
  },
  shotguns = {
    pumpshotgun = "0x1D073A89",
    pumpshotgun_mk2 = "0x555AF99A",
    sawnoffshotgun = "0x7846A318",
    assaultshotgun = "0xE284C527",
    bullpupshotgun = "0x9D61E50F",
    musket = "0xA89CB99E",
    heavyshotgun = "0x3AABBBAA",
    dbshotgun = "0xEF951FBB",
    autoshotgun = "0x12E82D3D"
  },
  assault_rifles = {
    assaultrifle = "0xBFEFFF6D",
    assaultrifle_mk2 = "0x394F415C",
    carbinerifle = "0x83BF0278",
    carbinerifle_mk2 = "0xFAD1F1C9",
    advancedrifle = "0xAF113F99",
    specialcarbine = "0xC0A3098D",
    specialcarbine_mk2 = "0x969C3D67",
    bullpuprifle = "0x7F229F94",
    bullpuprifle_mk2 = "0x84D6FAFD",
    compactrifle = "0x624FE830"
  },
  machine_guns = {
    mg = "0x9D07F764",
    combatmg = "0x7FD62962",
    combatmg_mk2 = "0xDBBD7280",
    gusenberg = "0x61012683"
  },
  sniper_rifles = {
    sniperrifle = "0x5FC3C11",
    heavysniper = "0xC472FE2",
    heavysniper_mk2 = "0xA914799",
    marksmanrifle = "0xC734385A",
    marksmanrifle_mk2 = "0x6A6C02E0"
  },
  heavy_weapons = {
    rpg = "0xB1CA77B1",
    grenadelauncher = "0xA284510B",
    grenadelauncher_smoke = "0x4DD2DC56",
    minigun = "0x42BF8A85",
    firework = "0x7F7497E5",
    railgun = "0x6D544C99",
    hominglauncher = "0x63AB0442",
    compactlauncher = "0x781FE4A",
    rayminigun = "0xB62D1F67"
  },
  throwables = {
    grenade = "0x93E220BD",
    bzgas = "0xA0973D5E",
    smokegrenade = "0xFDBC8A50",
    flare = "0x497FACC3",
    molotov = "0x24B17070",
    stickybomb = "0x2C3731D9",
    proxmine = "0xAB564B93",
    snowball = "0x787F0BB",
    pipebomb = "0xBA45E8B8",
    ball = "0x23C9F95C"
  },
  misc = {
    petrolcan = "0x34A67B97",
    fireextinguisher = "0x60EC506",
    parachute = "0xFBAB5776",
    hazardcan = "0xBA536372"
  }
}
--CUSTOM FUEL SYSTEM (YOU NEED TO DISABLE Your Other Vehicle Fuel management to make this work specially for the ECO Mode)
config.usecustomfuel = true -- needed if you want to use ECO and Sports Mode Fuel Cost Effect
config.fueldecor = "_FUEL_LEVEL"

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
config.tirebrandnewhealth = 555 -- health of a brand new tires, this is not the vehicle health tires from GTA NATIVE!
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
config.repaircommand = true -- Enable Repair Command for standalone purpose, disable this if repairing via item.
-- FAQ - GTA WHEEL HEALTH IS GETTING REDUCE if Brand New Health is <= 0, so a total of 2000 health for each tires, combine with brandnewhealth + gta wheel health.

--CARLOCK
config.carlock = true -- Enable Car Keyless System -- using owned_vehicles table from mysql, fetch owner as identifier.
config.carlock_distance = 20 -- max distance to fetch the sorrounding vehicles

-- HERE YOU CAN CHANGE THE KEYBINDS
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
	car_seatbelt = 'B', -- Seatbelt ui and seatbelt function
	-- Enter Vehicle -- This is needed to throw a function and loop while entering a vehicle
	entering = 'F',
	-- Switch Vehicle mode eg. Sports mode and Eco mode
	mode = 'RSHIFT', -- Right Shift Activate vehiclde mode
	--switching differential eg. 4WD,RWD,FWD
	differential = 'RCONTROL', -- Right CTRL Change Differential eg. 4wd,fwd,rwd
	cruisecontrol = 'RMENU', -- Right Alt CRUISE CONTROL
	bodystatus = 'HOME',
    carcontrol = 'NUMLOCK',
    enablenitro = 'DELETE',
    carlock = 'L'
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
	entering = 'entervehicle',
	mode = 'mode',
	differential = 'differential',
	cruisecontrol = 'cruisecontrol',
	bodystatus = 'bodystatus',
    bodyheal = 'bodyheal',
    carcontrol = 'carcontrol',
    weaponui = 'weaponui',
    crosshair = 'crosshair',
    enablenitro = 'enablenitro',
    carlock = 'carlock'
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
        [2] = 0.57,
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
    }
}
config.firstgear = 0.33 -- DEFAULT 0.33
config.secondgear = 0.57 -- DEFAULT 0.57
config.thirdgear = 0.84 -- DEFAULT 0.84
config.fourthgear = 1.22 -- DEFAULT 1.22
config.fifthgear = 1.45 -- DEFAULT 1.45
config.sixthgear = 1.60 -- DEFAULT 1.60
config.finaldrive = 'default' -- will use the default settings from handling.meta
config.disallowed_manual = {
	'13', -- cycles
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
    [3] = 'Mechanic - Oncall Comms'
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
config.NuiCarhpandGas_sleep = 1500
config.car_mainloop_sleep = 500
config.rpm_speed_loop = 52
config.idle_rpm_speed_sleep = 151
config.Rpm_sleep = 151
config.Rpm_sleep_2 = 52
config.Speed_sleep = 151
config.Speed_sleep_2 = 52
Creation = Renzuzu.CreateThread
Renzu_Hud = Renzuzu.InvokeNative
ClientEvent = TriggerEvent
RenzuNetEvent = RegisterNetEvent
RenzuEventHandler = AddEventHandler
RenzuCommand = RegisterCommand
RenzuSendUI = SendNUIMessage
RenzuKeybinds = RegisterKeyMapping
RenzuNuiCallback = RegisterNUICallback
ReturnFloat = Renzuzu.ResultAsFloat()
ReturnInt = Renzuzu.ResultAsInteger()

-- GEAR FUNCTION
function SetRpm(veh, val)
    Renzu_Hud(0x2A01A8FC, veh, val)
end
function SetVehicleNextGear(veh, gear)
    Renzu_Hud(GetHashKey('SET_VEHICLE_NEXT_GEAR') & 0xFFFFFFFF, veh, gear)
end
function SetVehicleCurrentGear(veh, gear)
    Renzu_Hud(GetHashKey('SET_VEHICLE_CURRENT_GEAR') & 0xFFFFFFFF, veh, gear)
end

function Renzu_SetGear(vehicle, gear)
    if gear >= 6 then
        gear = 6
    end
    ForceVehicleGear(vehicle, gear)
end

function LockSpeed(veh,speed)
    Renzu_Hud(0xBAA045B4E42F3C06, veh, speed)
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