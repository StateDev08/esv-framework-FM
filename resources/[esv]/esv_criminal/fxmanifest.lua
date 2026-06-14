fx_version 'cerulean'
game 'gta5'

name 'esv_criminal'
description 'ESV Framework – Kriminelles System (Drogen, Ueberfaelle, Gefaengnis)'
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

server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'esv_core', 'esv_inventory' }
lua54 'yes'
