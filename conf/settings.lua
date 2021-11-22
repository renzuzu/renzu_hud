-- SETTINGS UI
config.statusbackup = {['table'] = config.statusordering, ['float'] = config.statusplace}

config.settingcommand = 'hud'
config.userconfig = {
	['statusver'] = config.status_type,
	['uilook'] = config.statusui,
	['iconshape'] = config.uidesign,
	['status'] = {['data'] = config.statusordering, ['float'] = config.statusplace},
	['carhud'] = {
		version = config.carui, 
		speedmetric = config.carui_metric, 
		turbohud = config.turbogauge, 
		manualhud = config.manualhud, refreshrate = config.Rpm_sleep},
	['streethud'] = config.enablecompass,
	['weaponhud'] = config.weaponsui,
}

--$('#weaponui').append(weaponstring)