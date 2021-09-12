local isCuffed = false
local handcuffTimer = {}
RegisterNetEvent('esx:playerLoaded')
AddEventHandler("esx:playerLoaded", function(xPlayer)
    ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
	ZiptieLoop()
end)

RegisterNetEvent('esx:onPlayerLogout')
AddEventHandler('esx:onPlayerLogout', function()
	ESX.PlayerLoaded = false
	ESX.PlayerData = {}
end)

--[[---------------------------------------------------------------------
Ziptie Code
]]-----------------------------------------------------------------------
RegisterNetEvent('bixbi_zipties:startziptie')
AddEventHandler("bixbi_zipties:startziptie", function(targetId)
	if (targetId == nil) then
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 2.0 then targetId = GetPlayerServerId(closestPlayer) end
	end
	
	exports['bixbi_core']:Loading(Config.ZiptieSpeed * 1000, 'Applying zipties to person')
	Citizen.Wait(Config.ZiptieSpeed * 1000)
	TriggerServerEvent('bixbi_zipties:ApplyZipties', targetId)
	exports['bixbi_core']:Notify('info', 'You have ziptied the target.')
end)

RegisterNetEvent('bixbi_zipties:startziptieremove')
AddEventHandler("bixbi_zipties:startziptieremove", function(type, targetId)
	if (targetId == nil) then
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 2.0 then targetId = GetPlayerServerId(closestPlayer) end
	end
	local tool = Config.ZiptieRemovers[type]
	exports['bixbi_core']:Loading(tool.timer * 1000, 'Removing zipties from person')
	Citizen.Wait(tool.timer * 1000)
	
	exports['bixbi_core']:Notify('info', 'You have removed the ziptie.')
	TriggerServerEvent('bixbi_zipties:RemoveZipties', targetId)
end)

function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		exports['bixbi_core']:Notify('info', 'You feel the zipties slowly losing grip and fading away.')
		TriggerEvent('bixbi_zipties:removeziptie')
		handcuffTimer.active = false
	end)
end

RegisterNetEvent('bixbi_zipties:ziptie')
AddEventHandler("bixbi_zipties:ziptie", function(source, tool)
	local playerPed = PlayerPedId()
	exports['bixbi_core']:Notify('error', 'You have been ziptied.')

	if not isCuffed then
		isCuffed = true
		exports['bixbi_core']:playAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', -1)
		
		SetEnableHandcuffs(playerPed, true)
		DisablePlayerFiring(playerPed, true)
		SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
		SetPedCanPlayGestureAnims(playerPed, false)
		DisplayRadar(false)

		if handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end

		StartHandcuffTimer()
	end

end)

RegisterNetEvent('bixbi_zipties:removeziptie')
AddEventHandler('bixbi_zipties:removeziptie', function()
	local playerPed = PlayerPedId()
	exports['bixbi_core']:Notify('', 'You are free again.')
	if isCuffed then
		isCuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		DisplayRadar(true)

		if handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

function ZiptieLoop()
	Citizen.CreateThread(function()
		while (ESX.PlayerLoaded) do
			Citizen.Wait(0)
	
			if isCuffed then
				EnableControlAction(0, 47, true)
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
	
				DisableControlAction(2, 36, true) -- Disable going stealth
	
				DisableControlAction(0, 47, true)  -- Disable weapon
				DisableControlAction(0, 264, true) -- Disable melee
				DisableControlAction(0, 257, true) -- Disable melee
				DisableControlAction(0, 140, true) -- Disable melee
				DisableControlAction(0, 141, true) -- Disable melee
				DisableControlAction(0, 142, true) -- Disable melee
				DisableControlAction(0, 143, true) -- Disable melee
	
				local playerPed = PlayerPedId()
				if IsEntityPlayingAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', 3) ~= 1 then
					RequestAnimSet("re@stag_do@idle_a")
					-- ScrappyCap: Potential Fix
					while (not HasAnimSetLoaded("re@stag_do@idle_a")) do 
						Citizen.Wait(100)
					end 
					exports['bixbi_core']:playAnim(playerPed, 're@stag_do@idle_a', 'idle_a_ped', -1)
				end
			else
				Citizen.Wait(500)
			end
		end
	end)
end

if (Config.qtarget) then
	Citizen.CreateThread(function()
		exports['qtarget']:Player({
			options = {
				{
					icon = "fak fa-handcuffs",
					label = "Ziptie",
					required_item = "zipties",
					canInteract = function(entity)
						if IsPedAPlayer(entity) then
							if (AreHandsUp(entity) and (IsPedArmed(PlayerPedId(), 4) or IsPedArmed(PlayerPedId(), 1)) and not IsPedDeadOrDying(entity, 1)) then 
								return true
							else
								return false
							end
						end
					end,
					action = function(entity)
						TriggerEvent('bixbi_zipties:startziptie', GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity)))
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
local isHandsUp = false
RegisterNetEvent('bixbi_zipties:ToggleHandsUp')
AddEventHandler('bixbi_zipties:ToggleHandsUp', function()
	local playerPed = PlayerPedId()
	if (DoesEntityExist(playerPed) and not IsEntityDead(playerPed) and not IsPauseMenuActive()) then 
		RequestAnimDict('random@mugging3')
		while not HasAnimDictLoaded('random@mugging3') do
			Citizen.Wait(100)
		end

		if isHandsUp then
			isHandsUp = false
			ClearPedSecondaryTask(playerPed)
		else
			isHandsUp = true
			TaskPlayAnim(playerPed, 'random@mugging3', 'handsup_standing_base', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
		end
		RemoveAnimDict('random@mugging3')
	else
		isHandsUp = false
		ClearPedSecondaryTask(playerPed)
	end
end)

function AreHandsUp(ped)
	if (IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)) then return true end
	return false
end