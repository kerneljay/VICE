fx_version 'cerulean'

games { 'rdr3', 'gta5' }

author 'Knox Development'

description 'Knox Development | Anti-Tank | discord.gg/C8Vd8esa4Q | https://knox.tebex.io/ | https://github.com/KnoxDevelopment'

version '1.0'

lua54 'on'

shared_scripts {
    'Config/*.lua'
}

client_scripts {
    'Client/*.lua'
}



escrow_ignore {
    'Config/*.lua',
    'Client/*.lua',
    'Server/*.lua'
}
dependency '/assetpacks'