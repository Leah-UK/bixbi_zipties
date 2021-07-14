ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem('zipties', function(source)
    TriggerClientEvent('bixbi_zipties:startziptie', source)
end)

for k,v in pairs(Config.ZiptieRemovers) do
	ESX.RegisterUsableItem(k, function(source)
		local tool = Config.ZiptieRemovers[k]
		TriggerClientEvent('bixbi_zipties:startziptieremove', source, k)

		if tool.OneTimeUse == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			xPlayer.removeInventoryItem(k, 1)
		end

	end)
end

RegisterServerEvent('bixbi_zipties:ApplyZipties')
AddEventHandler('bixbi_zipties:ApplyZipties', function(target)
	local xPlayer = ESX.GetPlayerFromId(source)
	local sourceItem = xPlayer.getInventoryItem('zipties')

	if sourceItem.count >= 1 then
		xPlayer.removeInventoryItem('zipties', 1)
		TriggerClientEvent('bixbi_zipties:ziptie', target)
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, "You do not have zipties.")
	end
end)

RegisterServerEvent('bixbi_zipties:RemoveZipties')
AddEventHandler('bixbi_zipties:RemoveZipties', function(source)
	TriggerClientEvent('bixbi_zipties:removeziptie', source)
end)

AddEventHandler('onResourceStart', function(resourceName)
	if (GetResourceState('bixbi_core') ~= 'started' ) then
        print('Bixbi_Zipties - ERROR: Bixbi_Core hasn\'t been found! This could cause errors!')
        StopResource(resourceName)
    end
end)