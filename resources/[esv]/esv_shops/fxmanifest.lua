fx_version 'cerulean'
game 'gta5'
name 'esv_shops'
description 'ESV Framework – Shop-System'
author 'ESV Development'
version '1.0.0'
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'esv_core', 'esv_inventory' }
lua54 'yes'
