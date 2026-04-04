fx_version 'cerulean'
games { 'gta5' }
author 'VICE'
description 'This is a discord bot made by VICE.'

server_only 'yes'

dependency 'vice'

server_scripts {
    "@vice/util/server/utils.lua",
    "bot.js"
}

server_exports {
    'dmUser',
}