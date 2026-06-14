fx_version 'cerulean'
game 'gta5'

name 'esv_emotes'
description 'ESV Framework – Emote & Animations-System'
author 'ESV Development'
version '1.0.0'

shared_scripts {
    '@esv_core/shared/config.lua',
    '@esv_core/shared/functions.lua',
    '@esv_core/shared/items.lua',
    '@esv_core/shared/jobs.lua',
    '@esv_core/shared/vehicles.lua',
    'shared/emotes.lua',
}

client_scripts {
    '@esv_core/client/functions.lua',
    'client/main.lua',
}

dependencies { 'esv_core' }
lua54 'yes'
