shared_script '@fiveguard/ai_module_fg-obfuscated.lua'
shared_script '@fiveguard/shared_fg-obfuscated.lua'
fx_version 'cerulean'
game 'gta5'

author 'angeelcv03'
description 'Sistema de reportes NUI'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js'
}
