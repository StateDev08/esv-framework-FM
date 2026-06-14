fx_version 'cerulean'
game 'gta5'
name 'esv_clothing'
description 'ESV Framework – Kleidungs- & Appearance-System'
author 'ESV Development'
version '1.0.0'
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
ui_page 'html/index.html'
files { 'html/index.html', 'html/css/style.css', 'html/js/app.js' }
dependencies { 'esv_core' }
lua54 'yes'
