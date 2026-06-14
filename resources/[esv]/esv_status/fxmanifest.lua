fx_version 'cerulean'
game 'gta5'

name 'esv_status'
description 'ESV Framework – Status-System (Hunger, Durst, Stress)'
author 'ESV Development'
version '1.0.0'

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'esv_core',
}

lua54 'yes'
