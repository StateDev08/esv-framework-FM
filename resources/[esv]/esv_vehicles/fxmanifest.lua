fx_version 'cerulean'
game 'gta5'

name 'esv_vehicles'
description 'ESV Framework – Fahrzeugsystem (Garage, Haendler, Tanken, Schluessel)'
author 'ESV Development'
version '1.0.0'

client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }

ui_page 'html/index.html'
files { 'html/index.html', 'html/css/style.css', 'html/js/app.js' }

dependencies { 'esv_core' }
lua54 'yes'
