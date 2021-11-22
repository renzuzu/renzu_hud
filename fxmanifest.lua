-- Copyright (c) Renzuzu
-- All rights reserved.
-- Even if 'All rights reserved' is very clear :
-- You shall not use any piece of this software in a commercial product / service
-- You shall not resell this software
-- You shall not provide any facility to install this particular software in a commercial product / service
-- If you redistribute this software, you must link to ORIGINAL repository at https://github.com/renzuzu/renzu_hud
-- This copyright should appear in every part of the project code
fx_version 'cerulean'
-- Renzu HUD 
-- https://github.com/renzuzu/renzu_hud
-- YOU ARE NOT ALLOWED TO SELL THIS
-- MADE BY Renzuzu
game 'gta5'

lua54 'on'
--is_cfxv2 'yes'
--use_fxv2_oal 'true'

ui_page {
    'ui/index.html',
}

shared_scripts {
	'conf/main.lua',
	'conf/status.lua',
	'conf/bodystatus.lua',
	'conf/keybinds.lua',
	'conf/optimizing.lua',
	'conf/clothing.lua',
	'conf/voice.lua',
	'conf/vehicle.lua',
	'conf/weapon.lua',
	'conf/settings.lua'
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server/server.lua"
}
client_scripts {
	'client/handling.lua',
	'client/function.lua',
	"client/client.lua",
	"client/street.lua",
	"client/manual.lua",
}
files {
	'ui/index.html',
	'ui/css/*.otf',
	'ui/css/*.ttf',
	'ui/css/*.woff',
	'ui/css/*.woff2',
	'ui/fonts/Azonix.otf',
	'ui/assets/icons.svg',
	'ui/css/*.css',
	'ui/js/*.js',
	'ui/img/*.png',
	'ui/img/*.webp',
	'ui/img/weapons/*.webp',
	'ui/sounds/*.ogg',
	'ui/shifter/*.webp',
	'stream/*.ydr',
	'handling.min.json',
	"turbo.ytyp"
}

data_file 'DLC_ITYP_REQUEST' 'turbo.ytyp'