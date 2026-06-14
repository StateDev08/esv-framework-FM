fx_version 'cerulean'
game 'gta5'

name 'esv_core'
description 'ESV Framework – Kern-System'
author 'ESV Development'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/vehicles.lua',
    'shared/functions.lua',
}

client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/events.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/commands.lua',
}

lua54 'yes'

dependencies {
    'spawnmanager',
    'oxmysql',
    'ox_lib',
}
