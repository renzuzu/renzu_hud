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
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"config.lua",
	"server.lua"
}
client_scripts {
	"config.lua",
	'handling.lua',
	'function.lua',
	"client.lua",
	"street.lua",
	"manual.lua",
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
	'ui/css/fontawsome/*.css',
	'ui/js/*.js',
	'ui/img/*.png',
	'ui/img/*.webp',
	'ui/img/weapons/*.png',
	'ui/sounds/*.ogg',
	'ui/shifter/*.png',
	'stream/*.ydr',
	'handling.min.json',
	'popgroups.ymt',
	--"turbo.ytyp"
}

--data_file 'DLC_ITYP_REQUEST' 'turbo.ytyp'
--data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups'
--data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt'
--data_file 'DLC_POP_GROUPS' 'popgroups.ymt'