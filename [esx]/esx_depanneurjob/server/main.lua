--<-.(`-')               _                         <-. (`-')_  (`-')  _                          (`-')              _           (`-') (`-')  _ _(`-')    (`-')  _      (`-')
-- __( OO)      .->     (_)        .->                \( OO) ) ( OO).-/    <-.          .->   <-.(OO )     <-.     (_)         _(OO ) ( OO).-/( (OO ).-> ( OO).-/     _(OO )
--'-'---.\  ,--.'  ,-.  ,-(`-') ,---(`-')  .----.  ,--./ ,--/ (,------. (`-')-----.(`-')----. ,------,) (`-')-----.,-(`-'),--.(_/,-.\(,------. \    .'_ (,------.,--.(_/,-.\
--| .-. (/ (`-')'.'  /  | ( OO)'  .-(OO ) /  ..  \ |   \ |  |  |  .---' (OO|(_\---'( OO).-.  '|   /`. ' (OO|(_\---'| ( OO)\   \ / (_/ |  .---' '`'-..__) |  .---'\   \ / (_/
--| '-' `.)(OO \    /   |  |  )|  | .-, \|  /  \  .|  . '|  |)(|  '--.   / |  '--. ( _) | |  ||  |_.' |  / |  '--. |  |  ) \   /   / (|  '--.  |  |  ' |(|  '--.  \   /   / 
--| /`'.  | |  /   /)  (|  |_/ |  | '.(_/'  \  /  '|  |\    |  |  .--'   \_)  .--'  \|  |)|  ||  .   .'  \_)  .--'(|  |_/ _ \     /_) |  .--'  |  |  / : |  .--' _ \     /_)
--| '--'  / `-/   /`    |  |'->|  '-'  |  \  `'  / |  | \   |  |  `---.   `|  |_)    '  '-'  '|  |\  \    `|  |_)  |  |'->\-'\   /    |  `---. |  '-'  / |  `---.\-'\   /   
--`------'    `--'      `--'    `-----'    `---''  `--'  `--'  `------'    `--'       `-----' `--' '--'    `--'    `--'       `-'     `------' `------'  `------'    `-'    
require "resources/[essential]/es_extended/lib/MySQL"
MySQL:open("127.0.0.1", "gta5_gamemode_essential", "dev", "dev12")

RegisterServerEvent('esx_depanneurjob:requestPlayerData')
AddEventHandler('esx_depanneurjob:requestPlayerData', function(reason)
	TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
		TriggerEvent('esx_skin:requestPlayerSkinInfosCb', source, function(skin, jobSkin)

			local data = {
				job       = xPlayer.job,
				inventory = xPlayer.inventory,
				skin      = skin
			}

			TriggerClientEvent('esx_depanneurjob:responsePlayerData', source, data, reason)
		end)
	end)
end)

RegisterServerEvent('esx_depanneurjob:requestOtherPlayerData')
AddEventHandler('esx_depanneurjob:requestOtherPlayerData', function(playerId, reason)
	TriggerClientEvent('esx_depanneurjob:requestPlayerWeapons', playerId, source, reason)
end)

RegisterServerEvent('esx_depanneurjob:requestPlayerPositions')
AddEventHandler('esx_depanneurjob:requestPlayerPositions', function(reason)
	
	local _source = source

	TriggerEvent('esx:getPlayers', function(xPlayers)

		local positions = {}

		for k, v in pairs(xPlayers) do
			positions[tostring(k)] = v.player.coords
		end

		TriggerClientEvent('esx_depanneurjob:responsePlayerPositions', _source, positions, reason)

	end)

end)

TriggerEvent('esx_phone:registerCallback', 'special', function(source, phoneNumber, playerName, type, message)

	if phoneNumber == 'depanneur' then

		TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
			TriggerEvent('esx:getPlayers', function(xPlayers)
				for k, v in pairs(xPlayers) do
					if v.job.name == 'depanneur' then
						
						RconPrint('Message => ' .. playerName .. ' ' .. message)
						
						TriggerClientEvent('esx_phone:onMessage', v.player.source, xPlayer.phoneNumber, playerName, type, message, xPlayer.player.coords, {
							reply     = 'Répondre',
							gps       = 'GPS',
							copy_that = 'Bien reçu'
						})
						
					end
				end
			end)
		end)

	end
end)
