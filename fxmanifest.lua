fx_version 'cerulean'
game 'gta5'

author 'Arthiis'
description 'qb-hunting script with deer spawning and butchering'
version '1.0.0'

shared_script 'config.lua'   -- ✅ shared between client + server


client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- if you use oxmysql, else remove
    'server/server.lua'
}
