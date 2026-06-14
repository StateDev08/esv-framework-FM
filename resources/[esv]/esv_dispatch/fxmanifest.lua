fx_version 'cerulean'
game 'gta5'
name 'esv_dispatch'
description 'ESV Framework – 911 Dispatch & Funk'
author 'ESV Development'
version '1.0.0'
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'esv_core' }
lua54 'yes'
