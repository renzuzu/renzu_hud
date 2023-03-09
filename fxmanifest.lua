fx_version 'cerulean'
game 'gta5'
lua54 'on'
ui_page {
    'ui/index.html',
}
shared_scripts {
	'conf/main.lua',
	'conf/status.lua',
	'conf/keybinds.lua',
	'conf/optimizing.lua',
	'conf/voice.lua',
	'conf/vehicle.lua',
	'conf/weapon.lua',
	'conf/settings.lua'
}

client_scripts {
	'client/function.lua',
	"client/client.lua",
	"client/street.lua",
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
}
