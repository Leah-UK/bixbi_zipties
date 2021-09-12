--[[----------------------------------
Creation Date:	27/02/21
]]------------------------------------
fx_version 'adamant'
game 'gta5'
author 'Leah#0001'
version '1.2.1'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
    'client/client.lua'
} 
 
server_scripts {
    'server/server.lua'
} 

exports {
	"ToggleHandsUp",
    "AreHandsUp"
}