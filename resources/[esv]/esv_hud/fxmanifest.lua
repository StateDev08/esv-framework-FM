fx_version 'cerulean'
game 'gta5'

name 'esv_hud'
description 'ESV Framework – HUD Anzeige'
author 'ESV Development'
version '1.0.0'

shared_scripts {
    '@esv_core/shared/config.lua',
    '@esv_core/shared/functions.lua',
    '@esv_core/shared/items.lua',
    '@esv_core/shared/jobs.lua',
    '@esv_core/shared/vehicles.lua',
}

client_scripts {
    '@esv_core/client/functions.lua',
    'client/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
}

dependencies { 'esv_core' }
lua54 'yes'
