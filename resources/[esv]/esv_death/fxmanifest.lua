fx_version 'cerulean'
game 'gta5'

name 'esv_death'
description 'ESV Framework – Tod & Respawn System'
author 'ESV Development'
version '1.0.0'

client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'esv_core' }
lua54 'yes'
