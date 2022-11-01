lua54 'yes'
fx_version 'cerulean'
game 'gta5'

name 'K-Stocks'
description 'Crazy Stock System! Based off society funcds'
author 'KamuiKody'
contact 'https://discord.gg/3j9b439TeY'

shared_script 'config.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/CircleZone.lua',
    'client.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server.lua'
}
escrow_ignore {
    "config.lua"
}