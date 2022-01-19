ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

local isCuffed = false
local handcuffTimer = {}
RegisterNetEvent('bixbi_zipties:startZiptie')
AddEventHandler("bixbi_zipties:startZiptie", function(targetId)
	if (targetId == nil) then
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 2.0 then 
			targetId = GetPlayerServerId(closestPlayer)
		else
			exports['bixbi_core']:Notify('error', 'There isn\'t anyone nearby')
			return
		end
	end
	while (targetId == nil) do Citizen.Wait(100) end
    local targetPed = GetPlayerFromServerId(targetId)
	if (AreHandsUp(GetPlayerPed(targetPed))) then
	-- if (Player(targetId).state.handsup ~= nil and Player(targetId).state.handsup) then
		exports['bixbi_core']:Loading(Config.ZiptieSpeed * 1000, 'Applying zipties to person')
		Citizen.Wait(Config.ZiptieSpeed * 1000)
		TriggerServerEvent('bixbi_zipties:ApplyZipties', targetId)
		exports['bixbi_core']:Notify('success', 'You have ziptied the target.')
	else
		exports['bixbi_core']:Notify('error', 'This person doesn\'t have their hands up.')
	end
	
end)

RegisterNetEvent('bixbi_zipties:startziptieremove')
AddEventHandler("bixbi_zipties:startziptieremove", function(tool, targetId)
	if (targetId == nil) then
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 2.0 then 
			targetId = GetPlayerServerId(closestPlayer) 
		else
			exports['bixbi_core']:Notify('error', 'There isn\'t anyone nearby')
			return
		end
	end
	exports['bixbi_core']:Loading(tool.timer * 1000, 'Removing zipties from person')
	Citizen.Wait(tool.timer * 1000)
	
	exports['bixbi_core']:Notify('', 'You have removed the ziptie.')
	TriggerServerEvent('bixbi_zipties:RemoveZipties', targetId)
end)

function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then ESX.ClearTimeout(handcuffTimer.task) end
	handcuffTimer.active = true
	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		exports['bixbi_core']:Notify('', 'You feel the zipties slowly losing grip and fading away.')
		TriggerEvent('bixbi_zipties:removeziptie')
		handcuffTimer.active = false
	end)
end

-- local isZiptied = false
RegisterNetEvent('bixbi_zipties:ziptie')
AddEventHandler("bixbi_zipties:ziptie", function(source, tool)
	local playerPed = PlayerPedId()
	exports['bixbi_core']:Notify('error', 'You have been ziptied.')

	if (not LocalPlayer.state.ziptied) then
        LocalPlayer.state:set('ziptied', true, true)
		exports['bixbi_core']:playAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', -1)
		
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
		SetPedCanPlayGestureAnims(playerPed, false)
		DisplayRadar(false)

		if handcuffTimer.active then ESX.ClearTimeout(handcuffTimer.task) end

		StartHandcuffTimer()
		ZiptieLoop()
	end
end)

RegisterNetEvent('bixbi_zipties:removeziptie')
AddEventHandler('bixbi_zipties:removeziptie', function()
	local playerPed = PlayerPedId()
	exports['bixbi_core']:Notify('', 'You are free again.')
	if (LocalPlayer.state.ziptied) then
		LocalPlayer.state:set('ziptied', false, true)

		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		ClearPedTasks(playerPed)
		ClearPedSecondaryTask(playerPed)
		DisplayRadar(true)

		if handcuffTimer.active then ESX.ClearTimeout(handcuffTimer.task) end
	end
end)

function ZiptieLoop()
	Citizen.CreateThread(function()
		while (LocalPlayer.state.ziptied) do
			Citizen.Wait(0)

			-- EnableControlAction(0, 47, true)
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee

			local playerPed = PlayerPedId()
			if (IsEntityPlayingAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', 3) ~= 1 and LocalPlayer.state.ziptied) then
				exports['bixbi_core']:playAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', -1)
			end
		end
	end)
end

-- function IsZiptied(ped)
-- 	if (IsEntityPlayingAnim(ped, 're@stag_do@idle_a', 'idle_a_ped', 3)) then return true end
-- 	return false
-- end

if (Config.qtarget) then
	Citizen.CreateThread(function()
		exports['qtarget']:Player({
			options = {
				{
					icon = "fak fa-handcuffs",
					label = "Ziptie",
					item = "zipties",
					canInteract = function(entity)
						if IsPedAPlayer(entity) then
							if (AreHandsUp(entity) and not IsPedDeadOrDying(entity, 1)) then return true end
                            return false
                        end
					end,
					action = function(entity)
						TriggerEvent('bixbi_zipties:startZiptie', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
					end
				},
			},
			distance = 2.0
		})
	end)
end
--[[---------------------------------------------------------------------
Hands Up Code
]]-----------------------------------------------------------------------
-- local isHandsup = false
RegisterCommand('handsup', function()
	local playerPed = PlayerPedId()
	if (DoesEntityExist(playerPed) and not IsEntityDead(playerPed) and not IsPauseMenuActive()) then 
		if (LocalPlayer.state.handsup) then
			ClearPedSecondaryTask(playerPed)
		else
			exports['bixbi_core']:playAnim(playerPed, 'random@mugging3', 'handsup_standing_base', -1)
		end
        LocalPlayer.state:set('handsup', not LocalPlayer.state.handsup, true)
	else
		LocalPlayer.state:set('handsup', false, true)
		ClearPedSecondaryTask(playerPed)
	end
end, false)
RegisterKeyMapping('handsup', 'Handsup', 'keyboard', 'x')

function AreHandsUp(ped)
	if (IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)) then return true end
	return false
end
--[[--------------------------------------------------
Setup
--]]--------------------------------------------------
RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function(xPlayer)
    ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)