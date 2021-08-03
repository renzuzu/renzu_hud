--STATUS CONFIG
config.statusv1sleep = 1000 -- 1 second update
config.statusui = 'simple' -- UI LOOK ( simple, normal ) -- NORMAL = with pedface, Simple = Only Icons
config.status_type = 'progressbar' -- circle progress bar = progressbar, fontawsome icon = icons
config.statusv2 = true -- enable this if you want the status toggle mode (TOGGLE VIA INSERT) (THIS INCLUDE RP PURPOSE HUD like job,money,etc.)
config.statusplace = 'bottom-left' -- available option top-right,top-left,bottom-right,bottom-left,top-center,bottom-center
config.uidesign = 'circle' -- octagon (default), circle, square
config.QbcoreStatusDefault = true -- if true will use metadatas as default you can stop renzu_status
--CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD

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
config.firing_statusaddval = 5000 -- value to add when firing a weapons
config.firing_bullets = 100 -- number of bullets or firing events to trigger the status function.
config.killing_affect_status = true -- do you want the status to be affected when you kill some player , ped, animals.
config.killing_affected_status = 'sanity'
config.killing_status_mode = 'add' -- (add,remove) add will add a value to status, remove will remove a status value.
config.killing_status_val = 5000 -- status value to add/remove per kill
config.running_affect_status = true -- if player is running (not sprint) status will affected?
config.running_affected_status = 'thirst' -- change this to whatever status you wanted to be affected
config.running_status_mode = 'remove' -- should add or remove? its up to you. affected status if running
config.running_status_val = 100 -- how much we add / remove to the status?
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

--if you want to add more status and reorder it.
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