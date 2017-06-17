--<-.(`-')               _                         <-. (`-')_  (`-')  _                          (`-')              _           (`-') (`-')  _ _(`-')    (`-')  _      (`-')
-- __( OO)      .->     (_)        .->                \( OO) ) ( OO).-/    <-.          .->   <-.(OO )     <-.     (_)         _(OO ) ( OO).-/( (OO ).-> ( OO).-/     _(OO )
--'-'---.\  ,--.'  ,-.  ,-(`-') ,---(`-')  .----.  ,--./ ,--/ (,------. (`-')-----.(`-')----. ,------,) (`-')-----.,-(`-'),--.(_/,-.\(,------. \    .'_ (,------.,--.(_/,-.\
--| .-. (/ (`-')'.'  /  | ( OO)'  .-(OO ) /  ..  \ |   \ |  |  |  .---' (OO|(_\---'( OO).-.  '|   /`. ' (OO|(_\---'| ( OO)\   \ / (_/ |  .---' '`'-..__) |  .---'\   \ / (_/
--| '-' `.)(OO \    /   |  |  )|  | .-, \|  /  \  .|  . '|  |)(|  '--.   / |  '--. ( _) | |  ||  |_.' |  / |  '--. |  |  ) \   /   / (|  '--.  |  |  ' |(|  '--.  \   /   / 
--| /`'.  | |  /   /)  (|  |_/ |  | '.(_/'  \  /  '|  |\    |  |  .--'   \_)  .--'  \|  |)|  ||  .   .'  \_)  .--'(|  |_/ _ \     /_) |  .--'  |  |  / : |  .--' _ \     /_)
--| '--'  / `-/   /`    |  |'->|  '-'  |  \  `'  / |  | \   |  |  `---.   `|  |_)    '  '-'  '|  |\  \    `|  |_)  |  |'->\-'\   /    |  `---. |  '-'  / |  `---.\-'\   /   
--`------'    `--'      `--'    `-----'    `---''  `--'  `--'  `------'    `--'       `-----' `--' '--'    `--'    `--'       `-'     `------' `------'  `------'    `-'    
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local SpawnedVehicles          = {}
local PID                      = 0
local PlayerData               = {}
local GUI                      = {}
GUI.Time                       = 0
local hasAlreadyEnteredMarker  = false;
local lastZone                 = nil;
local PoliceMenuTargetPlayerId = nil;
local PlayerIsHandcuffed       = false
local CurrentFine              = nil

function GetClosestPlayerInArea(positions, radius)

	local playerPed             = GetPlayerPed(-1)
	local playerServerId        = GetPlayerServerId(PlayerId())
	local playerCoords          = GetEntityCoords(playerPed)
	local closestPlayer         = -1
	local closestDistance       = math.huge

	for k, v in pairs(positions) do

    if tonumber(k) ~= playerServerId then
      
      local otherPlayerCoords = positions[k]
      local distance          = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, otherPlayerCoords.x, otherPlayerCoords.y, otherPlayerCoords.z, true)

      if distance <= radius and distance < closestDistance then
      	closestPlayer   = tonumber(k)
      	closestDistance = distance
      end
   	end
  end

  return closestPlayer

end

function GetClosestPlayerInAreaNotInAnyVehicle(positions, radius)

	local playerPed             = GetPlayerPed(-1)
	local playerServerId        = GetPlayerServerId(PlayerId())
	local playerCoords          = GetEntityCoords(playerPed)
	local closestPlayer         = -1
	local closestDistance       = math.huge

	for k, v in pairs(positions) do

    if tonumber(k) ~= playerServerId then
      
      local otherPlayerPed    = GetPlayerPed(GetPlayerFromServerId(tonumber(k)))
      local otherPlayerCoords = positions[k]
      local distance          = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, otherPlayerCoords.x, otherPlayerCoords.y, otherPlayerCoords.z, true)

      if distance <= radius and distance < closestDistance and not IsPedInAnyVehicle(otherPlayerPed,  false) then
      	closestPlayer   = tonumber(k)
      	closestDistance = distance
      end
   	end
  end

  return closestPlayer

end

AddEventHandler('playerSpawned', function(spawn)
	PID = GetPlayerServerId(PlayerId())
	TriggerServerEvent('esx_depanneurjob:requestPlayerData', 'playerSpawned')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	
	TriggerEvent('esx_phone:addContact', 'Dépanneur', 'depanneur', 'special', false)

	TriggerEvent('esx_phone:registerMessageCallback', 'copy_that', function(sender, phoneNumber, type, message, position)
		TriggerServerEvent('esx_phone:send', 'player', phoneNumber, GetPlayerName(PlayerId()), '~b~Bien reçu')
	end)

end)

AddEventHandler('esx_depanneurjob:hasEnteredMarker', function(zone)

	if zone == 'CloakRoom' then
		if PlayerData.job.name ~= nil and PlayerData.job.name == 'depanneur' then
			SendNUIMessage({
				showControls = true,
				controls     = 'cloakroom'
			})
		end
	end

	if zone == 'VehicleSpawner' then
		if PlayerData.job.name ~= nil and PlayerData.job.name == 'depanneur' then
			SendNUIMessage({
				showControls = true,
				controls     = 'vehiclespawner'
			})
		end
	end

	if zone == 'VehicleDeleter1' then

		local playerPed = GetPlayerPed(-1)

		if IsPedInAnyVehicle(playerPed, 0) then

			local vehicle = GetVehiclePedIsIn(playerPed,  false)

			DeleteVehicle(vehicle)

		end

	end

end)

AddEventHandler('esx_depanneurjob:hasExitedMarker', function(zone)
	SendNUIMessage({
		showControls = false,
		showMenu     = false,
	})
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
end)

RegisterNetEvent('esx_depanneurjob:responsePlayerData')
AddEventHandler('esx_depanneurjob:responsePlayerData', function(data, reason)
	PlayerData = data
end)

RegisterNUICallback('select', function(data, cb)

		if data.menu == 'cloakroom' then

			if data.val == 'civilian_wear' then
				TriggerEvent('esx_skin:loadSkin', PlayerData.skin)
			end

			if data.val == 'policeman_wear' then
				if PlayerData.skin.sex == 0 then
					TriggerEvent('esx_skin:loadJobSkin', PlayerData.skin, PlayerData.job.skin_male)
				else
					TriggerEvent('esx_skin:loadJobSkin', PlayerData.skin, PlayerData.job.skin_female)
				end
			end

		end

		if data.menu == 'vehiclespawner' then

	    local playerPed = GetPlayerPed(-1)

			Citizen.CreateThread(function()

				local coords       = Config.Zones.VehicleSpawnPoint.Pos
				local vehicleModel = GetHashKey(data.val)

				RequestModel(vehicleModel)

				while not HasModelLoaded(vehicleModel) do
					Citizen.Wait(0)
				end

				if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, 90.0, true, false)
					SetVehicleHasBeenOwnedByPlayer(vehicle,  true)
					SetEntityAsMissionEntity(vehicle,  true,  true)
					local id = NetworkGetNetworkIdFromEntity(vehicle)
					SetNetworkIdCanMigrate(id, true)
					TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
					SetVehicleMaxMods(vehicle)
				end

			end)

			SendNUIMessage({
				showControls = false,
				showMenu     = false,
			})

		end

		if data.menu == 'vehicle_interaction' then

			if data.val == 'vehicle_infos' then

				local playerPed = GetPlayerPed(-1)
	      local coords    = GetEntityCoords(playerPed)

	      if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

	        local vehicle = nil

	        if IsPedInAnyVehicle(playerPed, false) then
	          vehicle = GetVehiclePedIsIn(playerPed, false)
	        else
	          vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	        end

	        if DoesEntityExist(vehicle) then
	        	
	        	local plateText = GetVehicleNumberPlateText(vehicle)
						local items     = {}

						table.insert(items, {label = 'N°: ' .. plateText, value = nil})

						local ownerName = 'IA'

						SendNUIMessage({
							showControls = false,
							showMenu     = true,
							menu         = 'vehicle_infos',
							items        = items
						})

	        end

	      end

			end

			if data.val == 'hijack_vehicle' then

				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)

				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then

					local vehicle = nil

					if IsPedInAnyVehicle(playerPed, false) then
						vehicle = GetVehiclePedIsIn(playerPed, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end

					if DoesEntityExist(vehicle) then
						TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_WELDING", 0, true);
						Citizen.Wait(10000)
						SetVehicleDoorsLocked(vehicle, 1)
						SetVehicleDoorsLockedForAllPlayers(vehicle, false)
						ClearPedTasksImmediately(playerPed)
						TriggerEvent('esx:showNotification', '~g~Véhicule déverouillé')

					end

				end

			end
			
			if data.val == 'fix_vehicle' then
			
				local playerPed = GetPlayerPed(-1)
				local coords    = GetEntityCoords(playerPed)
				
				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
					
					local vehicle = nil

					if IsPedInAnyVehicle(playerPed, false) then
						vehicle = GetVehiclePedIsIn(playerPed, false)
					else
						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
					end
					
					if DoesEntityExist(vehicle) then
						setEntityHeadingFromEntity (vehicle, playerPed)
						TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true);
						Citizen.Wait(20000)
						SetVehicleFixed(vehicle)
						SetVehicleDeformationFixed(vehicle)
						SetVehicleUndriveable(vehicle, false)
						ClearPedTasksImmediately(playerPed)
						TriggerEvent('esx:showNotification', '~g~Véhicule réparé')
					end
				end
			end
			
			if data.val == 'del_vehicle' then
			
				local ped = GetPlayerPed( -1 )

				if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
					local pos = GetEntityCoords( ped )

					if ( IsPedSittingInAnyVehicle( ped ) ) then 
						local vehicle = GetVehiclePedIsIn( ped, false )

						if ( GetPedInVehicleSeat( vehicle, -1 ) == ped ) then 
							TriggerEvent('esx:showNotification', '~r~Vehicule mis en fourrière')
							SetEntityAsMissionEntity( vehicle, true, true )
							deleteCar( vehicle )
						else 
							TriggerEvent('esx:showNotification', '~r~Vous devez être assis du côté conducteur!')
						end 
					else
						local playerPos = GetEntityCoords( ped, 1 )
						local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( ped, 0.0, distanceToCheck, 0.0 )
						local vehicle = GetVehicleInDirection( playerPos, inFrontOfPlayer )

						if ( DoesEntityExist( vehicle ) ) then
							TriggerEvent('esx:showNotification', '~r~Vehicule mis en fourrière')
							SetEntityAsMissionEntity( vehicle, true, true )
							deleteCar( vehicle )
						else 
							TriggerEvent('esx:showNotification', '~r~Vous devez être près d\'un véhicule pour le mettre en fourrière')
						end 
					end 
				end
			end
			
			if data.val == 'dep_vehicle' then
			
				local playerped = GetPlayerPed(-1)
				local vehicle = GetVehiclePedIsIn(playerped, true)
	
				local towmodel = GetHashKey('flatbed')
				local isVehicleTow = IsVehicleModel(vehicle, towmodel)
			
				if isVehicleTow then
	
					local coordA = GetEntityCoords(playerped, 1)
					local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 5.0, 0.0)
					local targetVehicle = getVehicleInDirection(coordA, coordB)
		
					if currentlyTowedVehicle == nil then
						if targetVehicle ~= 0 then
							if not IsPedInAnyVehicle(playerped, true) then
								if vehicle ~= targetVehicle then
									AttachEntityToEntity(targetVehicle, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
									currentlyTowedVehicle = targetVehicle
									TriggerEvent('esx:showNotification', '~b~Vehicule attaché avec succès!')
								else
									TriggerEvent('esx:showNotification', '~r~Impossible d\'attacher votre propre dépanneuse')
								end
							end
						else
							TriggerEvent('esx:showNotification', '~r~Il n\'y a pas de véhicule à attacher')
						end
					else
						AttachEntityToEntity(currentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
						DetachEntity(currentlyTowedVehicle, true, true)
						currentlyTowedVehicle = nil
						TriggerEvent('esx:showNotification', '~b~Vehicule détattaché avec succès!')
					end
				end
			end
		end

		cb('ok')

end)

function setEntityHeadingFromEntity ( vehicle, playerPed )
    local heading = GetEntityHeading(vehicle)
    SetEntityHeading( playerPed, heading )
end

function getVehicleInDirection(coordFrom, coordTo)
	local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed(-1), 0)
	local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
	return vehicle
end

function deleteCar( entity )
    Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) )
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		local coords = GetEntityCoords(GetPlayerPed(-1))
		
		for k,v in pairs(Config.Zones) do

			if(PlayerData.job ~= nil and PlayerData.job.name == 'depanneur' and v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
			end
		end

	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		
		Wait(0)
		
		if(PlayerData.job ~= nil and PlayerData.job.name == 'depanneur') then

			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = true
				lastZone                = currentZone
				TriggerEvent('esx_depanneurjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_depanneurjob:hasExitedMarker', lastZone)
			end

		end

	end
end)

--[[ Create blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(371.712, -1611.93, 28.2919)
  
  SetBlipSprite (blip, 68)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipColour (blip, 5)
SetBlipAsShortRange(blip, true)
	
	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Depot des dépanneur")
  EndTextCommandSetBlipName(blip)

end)]]

Citizen.CreateThread(function()

	local blip = AddBlipForCoord(Config.Zones.CloakRoom.Pos.x, Config.Zones.CloakRoom.Pos.y, Config.Zones.CloakRoom.Pos.z)
  
  SetBlipSprite (blip, 68)
  SetBlipDisplay(blip, 4)
  SetBlipScale  (blip, 1.2)
  SetBlipColour (blip, 5)
  SetBlipAsShortRange(blip, true)
	
	BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Dépôt des dépanneurs")
  EndTextCommandSetBlipName(blip)

end)

-- Menu Controls
Citizen.CreateThread(function()
	while true do

		Wait(0)

		if PlayerData.job ~= nil and PlayerData.job.name == 'depanneur' and IsControlPressed(0, Keys['F6']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				showControls = false,
				showMenu     = true,
				menu         = 'depanneur_actions'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['ENTER']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				enterPressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['BACKSPACE']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				backspacePressed = true
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['LEFT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'LEFT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['RIGHT']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'RIGHT'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['TOP']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'UP'
			})

			GUI.Time = GetGameTimer()

		end

		if IsControlPressed(0, Keys['DOWN']) and (GetGameTimer() - GUI.Time) > 300 then

			SendNUIMessage({
				move = 'DOWN'
			})

			GUI.Time = GetGameTimer()

		end

	end
end)
