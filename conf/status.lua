-- STATUS CONFIG
config.statusv1sleep = 1000 -- 1 second update
config.registerautostatus = true -- register all status from config.statusordering setting below to ESX STATUS or RENZU_STATUS (only the status with custom bool will be registered example: line 60:status.lua) (ESX STATUS ONLY, RENZU_STATUS ALREADY HAVE A AUTO REGISTER FUNC)
config.statusui = 'simple' -- UI LOOK ( simple, normal ) -- NORMAL = with pedface, Simple = Only Icons
config.status_type = 'progressbar' -- circle progress bar = progressbar, fontawsome icon = icons
config.statusv2 = true -- enable this if you want the status toggle mode (TOGGLE VIA INSERT) (THIS INCLUDE RP PURPOSE HUD like job,money,etc.)
config.statusplace = 'bottom-left' -- available option top-right,top-left,bottom-right,bottom-left,top-center,bottom-center
config.uidesign = 'circle' -- octagon (default), circle, square
config.QbcoreStatusDefault = false -- if true will use metadatas as default you can stop renzu_status
-- CHANGE ACCORDING TO YOUR STATUS ESX STATUS OR ANY STATUS MOD

-- STATUS ( disabled v2 if you want the optimize version ( FETCH ONLY The Player Status if Toggled ) else v2 is running loop default of 1sec)
config.statusv2_sleep = 1000 -- 1sec
config.statusnotify = true
config.driving_affect_status = true -- should the status will be affected during Driving a vehicle?
config.driving_affected_status = 'stress' -- change whatever status you want to be affected during driving
config.driving_status_mode = 'remove' -- (add, remove) add will add a value to status, remove will remove a status value.
config.driving_status_val = 10000 -- status value to add/remove
config.driving_status_radius = 200 -- driving distance to add status
config.firing_affect_status = true -- Firing Weapons affects status?
config.firing_affected_status = 'stress' -- Affected Status during gunplay
config.firing_status_mode = 'add' -- Status Function (add,remove) add will add a value to status, remove will remove a status value.
config.firing_statusaddval = 5000 -- value to add when firing a weapons
config.firing_bullets = 100 -- number of bullets or firing events to trigger the status function.
config.killing_affect_status = true -- do you want the status to be affected when you kill some player , ped, animals.
config.killing_affected_status = 'stress'
config.killing_status_mode = 'add' -- (add,remove) add will add a value to status, remove will remove a status value.
config.killing_status_val = 5000 -- status value to add/remove per kill
config.running_affect_status = true -- if player is running (not sprint) status will affected?
config.running_affected_status = 'thirst' -- change this to whatever status you wanted to be affected
config.running_status_mode = 'remove' -- should add or remove? its up to you. affected status if running
config.running_status_val = 100 -- how much we add / remove to the status?
config.melee_combat_affect_status = true -- melee attack like punch,kick,pistolwhiping,etc can affect the status?
config.melee_combat_affected_status = 'stress' -- type of status
config.melee_combat_status_mode = 'remove' -- status remove or add?
config.melee_combat_status_val = 10000 -- value to add/remove
config.parachute_affect_status = true -- while parachuting mode can add status?
config.parachute_affected_status = 'stress' -- type of status
config.parachute_status_mode = 'remove' -- status remove or add?
config.parachute_status_val = 10000 -- value to add/remove
-- status standalone purpose (use this only if you need it)
-- Add / Remove Status when playing some animations
config.playing_animation_affect_status = true
config.status_animation = {
    -- this is a DICT
    {
        dict = 'mp_player_inteat@burger',
        name = 'mp_player_int_eat_burger',
        status = 'hunger',
        mode = 'add',
        val = '300000'
    }, {
        dict = 'mp_player_inteat@burger',
        name = 'mp_player_int_eat_burger_fp',
        status = 'hunger',
        mode = 'add',
        val = '300000'
    }, {
        dict = 'mp_player_intdrink',
        name = 'loop_bottle',
        status = 'thirst',
        mode = 'add',
        val = '300000'
    }, {
        dict = 'mp_player_intdrink',
        name = 'loop_bottle_fp',
        status = 'thirst',
        mode = 'add',
        val = '300000'
    }, {
        dict = 'amb@world_human_aa_smoke@male@idle_a',
        name = 'idle_c',
        status = 'sanity',
        mode = 'remove',
        val = '10000'
    }

    -- you can add as many animation as you want
}

-- if you want to add more status and reorder it.
-- the config have the div id's, offsets, colors, classes per status.
-- if config.registerautostatus is enable:
-- startvalue is important and default to 1000000, and remove value per tick is default for 100

------OTHER IMPORTANT CONFIG FOR STATUS ------
-- custom = registered status from esx_status and renzu_status
-- type = 1 (circular icon) type = 0 ( progress WIP)
-- enable = true (enable the status UI for this status)
-- hideifmax == only show this status if its not max
-- min_val_hide == combination with hideifmax only show this status if min_val_hide == 50 (50%)
-- notify_lessthan = Show notify if status is low
-- notify_value = combination with notifylessthan (20 = 20% of status to show notify)
-- notify_message == show this status message
-- value == leave it default 0
-- status = the status name
-- OTHER OPTION ARE ICON CUSTOMIZATION for Colors, Fontawsome etc..
config.statusordering =
    { -- SET enable = false to disable the status (the status must be registered from your esx_status) i highly suggest to use my standalone_status (https://github.com/renzuzu/renzu_status) so you wont have to edit the special events and exports needed for the status System!
        [0] = {
            type = 1,
            enable = true,
            status = 'health',
            hideifmax = false,
            custom = false,
            value = 100,
            notify_lessthan = false,
            notify_message = 'i am very hungry',
            notify_value = 20,
            display = 'none',
            offset = '275',
            i_id_1_color = 'rgb(101, 255, 131)',
            bg = 'rgb(20,23,26)',
            fa = 'fas fa-heartbeat',
            i_id_2_color = 'rgba(251, 29, 9, 0.3)'
        },
        [1] = {
            type = 1,
            enable = true,
            status = 'armor',
            hideifmax = true,
            custom = false,
            value = 0,
            notify_lessthan = false,
            notify_message = 'i am very hungry',
            notify_value = 20,
            display = 'none',
            offset = '275',
            i_id_1_color = 'rgb(1, 103, 255)',
            bg = 'rgb(20,23,26)',
            fa = 'far fa-shield-alt',
            i_id_2_color = 'rgb(0, 41, 129)'
        },
        [2] = {
            type = 1,
            enable = true,
            status = 'hunger',
            hideifmax = false,
            custom = true,
            value = 0,
            startvalue = 1000000,
            statusremove = 100,
            notify_lessthan = false,
            notify_message = 'i am very hungry',
            notify_value = 20,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(255, 155, 39)',
            bg = 'rgb(20,23,26)',
            fa = 'fas fa-cheeseburger',
            i_id_2_color = 'rgb(114, 68, 0)'
        },
        [3] = {
            type = 1,
            enable = true,
            status = 'thirst',
            hideifmax = false,
            custom = true,
            value = 0,
            startvalue = 1000000,
            statusremove = 100,
            notify_lessthan = false,
            notify_message = 'i am very thirsty',
            notify_value = 20,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(36, 113, 255)',
            bg = 'rgb(20,23,26)',
            fa = 'fad fa-glass',
            i_id_2_color = 'rgb(0, 11, 112)'
        },
        [4] = {
            type = 1,
            enable = false,
            status = 'stress',
            hideifmax = false,
            min_val_hide = 50,
            custom = true,
            value = 0,
            startvalue = 0,
            statusremove = 0,
            notify_lessthan = true,
            notify_message = 'i see some dragons',
            notify_value = 80,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(255, 16, 68)',
            bg = 'rgb(20,23,26)',
            fa = 'fad fa-head-side-brain',
            i_id_2_color = 'rgba(35, 255, 101, 0.84)'
        },
        [5] = {
            type = 1,
            enable = true,
            status = 'stamina',
            hideifmax = true,
            min_val_hide = 100,
            custom = false,
            value = 0,
            notify_lessthan = false,
            notify_message = 'running makes me thirsty',
            notify_value = 20,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(16, 255, 136)',
            bg = 'rgb(20,23,26)',
            fa = 'fad fa-running',
            i_id_2_color = 'rgba(0, 119, 57, 0.94)'
        },
        [6] = {
            type = 1,
            enable = true,
            status = 'oxygen',
            hideifmax = true,
            min_val_hide = 100,
            custom = false,
            value = 0,
            notify_lessthan = false,
            notify_message = 'my oxygen is almost gone',
            notify_value = 20,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(15, 227, 255)',
            bg = 'rgb(20,23,26)',
            fa = 'fad fa-lungs',
            i_id_2_color = 'rgba(8, 76, 85, 0.78)'
        },
        [7] = {
            type = 1,
            enable = true,
            status = 'energy',
            hideifmax = false,
            min_val_hide = 50,
            custom = true,
            value = 0,
            startvalue = 1000000,
            statusremove = 100,
            notify_lessthan = false,
            notify_message = 'i am very tired',
            notify_value = 20,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(233, 233, 233)',
            bg = 'rgb(20,23,26)',
            fa = 'fas fa-snooze',
            i_id_2_color = 'color:rgb(243, 57, 0)'
        },
        [8] = {
            type = 1,
            enable = true,
            status = 'voip',
            hideifmax = false,
            custom = false,
            value = 0,
            notify_lessthan = false,
            notify_message = 'silent mode',
            notify_value = 0,
            display = 'block',
            offset = '275',
            i_id_1_color = 'rgb(255, 255, 255)',
            bg = 'rgb(20,23,26)',
            fa = 'fas fa-microphone',
            i_id_2_color = 'rgba(251, 29, 9, 0.3)'
        },

        -- SAMPLE ONLY
        [9] = {
            type = 1, -- 1 = circle progress or 0 = flat progress bar
            enable = false, -- enable or disable status
            status = 'poop', -- status name from esx_status or renzu_status
            hideifmax = false, -- hide the status if its max (stress and armor is inverted)
            min_val_hide = 50, -- works only if hideifmax == true (show/hide the status if value is met)
            custom = true, -- native (ex. oxygen) or custom (Esx status/renzu_status)
            value = 0, -- leave default 0
            startvalue = 1000000,
            statusremove = 100, -- this will be register to esx_status or renzu_status, ( this is the remove value per tick )
            notify_lessthan = false, -- inverted ?
            notify_message = 'my poop is cumming', -- notify message
            notify_value = 25, -- notify percentage trigger
            display = 'block', -- dont change
            offset = '275', -- default offset
            fa = 'fas fa-poo', -- font awsome
            i_id_1_color = 'rgb(255, 199, 102)', -- progress color
            i_id_2_color = 'rgba(251, 29, 9, 0.3)', -- use if icons type
            bg = 'rgb(20,23,26)'
        },
        [10] = {
            type = 1,
            enable = false,
            status = 'pee',
            hideifmax = false,
            min_val_hide = 50,
            custom = true,
            value = 0,
            startvalue = 1000000,
            statusremove = 100, -- this will be register to esx_status or renzu_status, ( this is the remove value per tick )
            notify_lessthan = false,
            notify_message = 'my pee is cumming',
            notify_value = 25,
            display = 'block',
            offset = '275',
            fa = 'fas fa-restroom', -- font awsome
            i_id_1_color = 'rgb(255, 245, 112)', -- progress color
            i_id_2_color = 'rgba(251, 29, 9, 0.3)', -- bg color
            bg = 'rgb(20,23,26)'
        },
        [11] = {
            type = 1,
            enable = false,
            status = 'hygiene',
            hideifmax = false,
            min_val_hide = 50,
            custom = true,
            value = 0,
            startvalue = 1000000,
            statusremove = 100, -- this will be register to esx_status or renzu_status, ( this is the remove value per tick )
            notify_lessthan = false,
            notify_message = 'i smell fucking bad',
            notify_value = 25,
            display = 'block',
            offset = '275',
            fa = 'fad fa-shower', -- font awsome
            i_id_1_color = 'rgb(102, 196, 255)', -- progress color
            i_id_2_color = 'rgba(251, 29, 9, 0.3)', -- bg color
            bg = 'rgb(20,23,26)'
        }
    }

-- RegisterCommand('statusadd', function()
-- 	TriggerEvent('esx_status:add', 'stress', 520000)
-- end)

-- RegisterCommand('statusremove', function()
-- 	TriggerEvent('esx_status:remove', 'stress', 520000)
-- end)

-- GUIDE status ordering (variables needs to edit if your gonna reconfigure it)
-- type = 1 use icons/circle status -- type = 0 use WIP progressbars (longbars)
-- enable = true/false -- enable/disable the status
-- hideifmax = true/false -- eg. if stamina is max hide the icons, show it if you are currently sprinting
-- custom = true/false -- this define if the status is registered to esx_status/renzu_status/ -- if false its a native status example: oxygen,stamina
-- notify_lessthan = true/false -- if true notify only if status is max else notify if status is nearly 20%
-- value = do not edit, this is automatic
-- notify_message = a message to notify if condition is met
-- notify_value = the percentage of total status to trigger the notify system
-- id = the divid of uistatus v1 the toggable version
-- offset = unused and deprecated
-- i_id_1 = the id of div, rename this to a unique one.
-- i_id_1_color = color of circle status bar
-- i_id_1_class = the fontawsome icon to use
-- fa = fontawsome icons to use
-- others are relative to fontawsome and other not mention here is might be deprecated
