config.enableproximityfunc = false -- if false = will be using Voice UI Only, no Voice Function
config.voicecommandandkeybind = false -- disable by default!, enabling this will register a keybinds to your fivem client settings. so use this only if you are really going to use this.
config.radiochanel = true -- Enable Radio UI
config.radiochannels = { -- this will appear in Radio Channel UI if enable, example in config: chanel 1 = Ambulance Comms
    [0] = {},
    [1] = {job = 'police', text = 'Police - Robbery Comms'}, -- Limit the words or else it may overlap
    [2] =  {job = 'ambulance', text = 'EMS Comms'},
    [3] =  {job = 'mechanic', text = 'Mechanic Comms'},
    [4] =  {job = 'all', text = 'Public Comms'},

	-- you can add more radio channels here, this settings must be sync or the same with your radio channels permmision
}
config.defaultchannelname = 'Public Channel'
--if voicecommandandkeybind is disable
-- the system is listening to the following events of proxymity to change the mic UI in HUD
--pma-voice:setTalkingMode (from pma-voice)
--setVoice from MumbleVoip