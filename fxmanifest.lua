--[[----------------------------------
Creation Date:	27/02/21
]]------------------------------------
fx_version 'cerulean'
game 'gta5'
author 'Leah#0001'
version '1.3.1'

shared_scripts {
	'@es_extended/imports.lua', -- Remove this if you're on an ESX version less than 1.3
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
    "AreHandsUp",
    "IsZiptied"
}