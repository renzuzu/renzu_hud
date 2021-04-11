fx_version 'cerulean'

game 'gta5'

lua54 'on'
is_cfxv2 'yes'
use_fxv2_oal 'true'

ui_page {
    'ui/index.html',
}
server_scripts {
	'@mysql-async/lib/MySQL.lua',
	"server.lua"
}
client_scripts {
	"client.lua",
	"config.lua",
	"street.lua"
}
files {
	'ui/index.html',
	'ui/assets/icons.svg',
	'ui/css/*.css',
	'ui/js/*.js',
	'ui/img/*.png',
	'ui/shifter/*.png'
}