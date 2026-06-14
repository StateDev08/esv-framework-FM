fx_version 'cerulean'
game 'gta5'

name 'esv_jobs'
description 'ESV Framework – Job-System (Polizei, EMS, Mechaniker)'
author 'ESV Development'
version '1.0.0'

shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'esv_core' }
lua54 'yes'
