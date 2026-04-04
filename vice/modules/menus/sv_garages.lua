local lang = VICE.lang
local cfg = module("VICEVeh", "cfg_garages")
local inventory = module("VICEVeh", "inventory")
local vehicle_groups = cfg.garages
local limit = cfg.limit or 100000000
MySQL.createCommand("VICE/add_vehicle","INSERT IGNORE INTO vice_user_vehicles(user_id,vehicle,vehicle_plate,locked) VALUES(@user_id,@vehicle,@registration,@locked)")
MySQL.createCommand("VICE/remove_vehicle","DELETE FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("VICE/get_vehicles", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level, impounded FROM vice_user_vehicles WHERE user_id = @user_id")
MySQL.createCommand("VICE/get_vehicle_by_plate", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level, impounded FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle_plate = @plate")
MySQL.createCommand("VICE/get_rented_vehicles_in", "SELECT vehicle, rentedtime, user_id FROM vice_user_vehicles WHERE user_id = @user_id AND rented = 1")
MySQL.createCommand("VICE/get_rented_vehicles_out", "SELECT vehicle, rentedtime, user_id FROM vice_user_vehicles WHERE rentedid = @user_id AND rented = 1")
MySQL.createCommand("VICE/get_vehicle","SELECT vehicle FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("VICE/get_vehicle_fuellevel","SELECT fuel_level FROM vice_user_vehicles WHERE vehicle = @vehicle")
MySQL.createCommand("VICE/check_rented","SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND rented = 1")

MySQL.createCommand("VICE/sell_vehicle_player","UPDATE vice_user_vehicles SET user_id = @user_id, vehicle_plate = @registration WHERE user_id = @oldUser AND vehicle = @vehicle")
MySQL.createCommand("VICE/update_vehicle_mods","UPDATE vice_vehicle_mods SET user_id = @user_id WHERE user_id = @oldUser AND spawncode = @spawncode")
MySQL.createCommand("VICE/update_vehicle_stancer","UPDATE vice_vehicle_stancer SET user_id = @user_id WHERE user_id = @oldUser AND spawncode = @spawncode")

MySQL.createCommand("VICE/rentedupdate", "UPDATE vice_user_vehicles SET user_id = @id, rented = @rented, rentedid = @rentedid, rentedtime = @rentedunix WHERE user_id = @user_id AND vehicle = @veh")
MySQL.createCommand("VICE/rentedupdate_mods", "UPDATE vice_vehicle_mods SET user_id = @id WHERE user_id = @user_id AND spawncode = @veh")
MySQL.createCommand("VICE/rentedupdate_stancer", "UPDATE vice_vehicle_stancer SET user_id = @id WHERE user_id = @user_id AND spawncode = @veh")

MySQL.createCommand("VICE/fetch_rented_vehs", "SELECT * FROM vice_user_vehicles WHERE rented = 1")
MySQL.createCommand("VICE/get_vehicle_count","SELECT vehicle FROM vice_user_vehicles WHERE vehicle = @vehicle")

RegisterServerEvent("VICE:spawnPersonalVehicle")
AddEventHandler('VICE:spawnPersonalVehicle', function(vehicle)
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            for k,v in pairs(result) do
                if v.vehicle == vehicle then
                    if v.impounded then
                        VICE.notify(source, '~r~This vehicle is currently impounded.')
                        return
                    else
                        VICE.sendDCLog("vehicle", "VICE Spawn Vehicle Logs", "> Vehicle Spawncode: " .. vehicle .. " \n> Players Name: " .. VICE.getPlayerName(user_id) .. " \n> Players TempID: " .. source .. " \n> Players PermID: " .. user_id)
                        TriggerClientEvent('VICE:spawnPersonalVehicle', source, v.vehicle, VICE.GetMods(v.vehicle,user_id), false, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                        return
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent('phone:garage:getVehicles')
AddEventHandler('phone:garage:getVehicles', function()
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            local vehicles = {}
            for i, vehicle in ipairs(result) do
                vehicles[i] = {model = vehicle.vehicle, plate = vehicle.vehicle_plate}
            end

            TriggerClientEvent('phone:garage:receiveVehicles', source, vehicles)
        end
    end)
end)

valetCooldown = {}
RegisterServerEvent("VICE:valetSpawnVehicle")
AddEventHandler('VICE:valetSpawnVehicle', function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    VICEclient.isPlusClub(source,{},function(plusclub)
        VICEclient.isPlatClub(source,{},function(platclub)
            if plusclub or platclub then
                if valetCooldown[source] and not (os.time() > valetCooldown[source]) then
                    TriggerClientEvent("VICE:SpawnValetSuccess", source, false)
                    return VICE.notify(source, "~r~You are being rate limited, please wait.")
                else
                    valetCooldown[source] = nil
                end
                MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(result)
                    if result then 
                        for k,v in pairs(result) do
                            if v.vehicle == spawncode then
                                TriggerClientEvent("VICE:SpawnValetSuccess", source, true)
                                TriggerClientEvent('VICE:spawnPersonalVehicle', source, v.vehicle, VICE.GetMods(v.vehicle,user_id), true, GetEntityCoords(GetPlayerPed(source)), v.vehicle_plate, v.fuel_level)
                                valetCooldown[source] = os.time() + 60
                                return
                            end
                        end
                    end
                end)
            else
                TriggerClientEvent("VICE:SpawnValetSuccess", source, false)
                VICE.notify(source, "~g~You are not a subscriber of VICE Plus or VICE Platinum.")
            end
        end)
    end)
end)

RegisterServerEvent("VICE:getVehicleRarity")
AddEventHandler('VICE:getVehicleRarity', function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_vehicle_count", {vehicle = spawncode}, function(result)
        if result then 
            TriggerClientEvent('VICE:setVehicleRarity', source, spawncode, #result)
        end
    end)
end)

RegisterServerEvent("VICE:displayVehicleBlip")
AddEventHandler('VICE:displayVehicleBlip', function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    local mods = VICE.GetDefaultMods()
    VICEclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
        if vector3(x,y,z) ~= vector3(0,0,0) then
            if mods.security_blips then
                local position = {}
                position.x, position.y, position.z = x,y,z
                if next(position) then
                    TriggerClientEvent('VICE:displayVehicleBlip', source, position)
                    VICE.notify(source, "~g~Vehicle blip enabled.")
                    return
                end
            else
                VICE.notify(source, "~r~This vehicle does not have a remote vehicle blip installed.")
            end
        else
            VICE.notify(source, "~r~Can not locate vehicle with the plate "..mods.vehicle_plate.." in this city.")
        end
    end)
end)

RegisterServerEvent("VICE:viewRemoteDashcam")
AddEventHandler('VICE:viewRemoteDashcam', function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    local mods = VICE.GetDefaultMods()
    VICEclient.getOwnedVehiclePosition(source, {spawncode}, function(x,y,z)
        if vector3(x,y,z) ~= vector3(0,0,0) then
            if mods.security_dashcam then
                local position = table.pack(x,y,z)
                if next(position) then
                    for k,v in pairs(netObjects) do
                        TriggerClientEvent('VICE:viewRemoteDashcam', source, position, k)
                        return
                    end
                end
            else
                VICE.notify(source, "~r~This vehicle does not have a remote dashcam installed.")
            end
        else
            VICE.notify(source, "~r~Can not locate vehicle with the plate "..mods.vehicle_plate.." in this city.")
        end
    end)
end)

RegisterServerEvent("VICE:updateFuel")
AddEventHandler('VICE:updateFuel', function(vehicle, fuel_level)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("UPDATE vice_user_vehicles SET fuel_level = @fuel_level WHERE user_id = @user_id AND vehicle = @vehicle", {fuel_level = fuel_level, user_id = user_id, vehicle = vehicle}, function() end)
end)

RegisterServerEvent("VICE:getCustomFolders")
AddEventHandler('VICE:getCustomFolders', function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * from `vice_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            TriggerClientEvent("VICE:sendFolders", source, json.decode(Result[1].folder))
        end
    end)
end)


RegisterServerEvent("VICE:updateFolders")
AddEventHandler('VICE:updateFolders', function(FolderUpdated)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * from `vice_custom_garages` WHERE user_id = @user_id", {user_id = user_id}, function(Result)
        if #Result > 0 then
            exports['vice']:execute("UPDATE vice_custom_garages SET folder = @folder WHERE user_id = @user_id", {folder = json.encode(FolderUpdated), user_id = user_id}, function() end)
        else
            exports['vice']:execute("INSERT INTO vice_custom_garages (`user_id`, `folder`) VALUES (@user_id, @folder);", {user_id = user_id, folder = json.encode(FolderUpdated)}, function() end)
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        MySQL.query('VICE/fetch_rented_vehs', {}, function(pvehicles)
            if pvehicles then
                for i,v in pairs(pvehicles) do 
                    if os.time() > tonumber(v.rentedtime) then
                        MySQL.asyncQuery('VICE/rentedupdate', {id = v.rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = v.user_id, veh = v.vehicle})
                        MySQL.asyncQuery('VICE/rentedupdate_mods', {id = v.rentedid,user_id = v.user_id, veh = v.vehicle})
                        MySQL.asyncQuery('VICE/rentedupdate_stancer', {id = v.rentedid, user_id = v.user_id, veh = v.vehicle})
                        if VICE.getUserSource(v.rentedid) then
                            VICE.notify(VICE.getUserSource(v.rentedid), "~r~Your rented vehicle has been returned.")
                        end
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('VICE:FetchCars')
AddEventHandler('VICE:FetchCars', function(type)
    local source = source
    local user_id = VICE.getUserId(source)
    local returned_table = {}
    local fuellevels = {}
    local vehicleweights = {}
    local vehicledata = {total = 0,processed = 0}
    if user_id then
        MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local perms = false
                    local config = vehicle_groups[i]._config
                    if config.type == vehicle_groups[type]._config.type then 
                        local perm = config.permissions or nil
                        if next(perm) then
                            for i, v in pairs(perm) do
                                if VICE.hasPermission(user_id, v) then
                                    perms = true
                                end
                            end
                        else
                            perms = true
                        end
                        if perms then 
                            for a, z in pairs(v) do
                                if a ~= "_config" and veh.vehicle == a then
                                    vehicledata.total = vehicledata.total + 1
                                    if not returned_table[i] then 
                                        returned_table[i] = {["_config"] = config}
                                    end
                                    if not returned_table[i].vehicles then 
                                        returned_table[i].vehicles = {}
                                    end
                                    returned_table[i].vehicles[a] = {z[1], z[2], veh.vehicle_plate, veh.fuel_level}
                                    fuellevels[a] = veh.fuel_level
                                end
                            end
                            for a, z in pairs(v) do
                                if a ~= "_config" and veh.vehicle == a then
                                    VICE.getSData("chest:u1veh_"..a.."|" ..user_id,function(data)
                                        if data then
                                            vehicleweights[a] = VICE.computeItemsWeight(json.decode(data) or {})
                                        end
                                        vehicledata.processed = vehicledata.processed + 1
                                        if vehicledata.processed == vehicledata.total then
                                            TriggerClientEvent('VICE:ReturnFetchedCars', source, returned_table, fuellevels, vehicleweights)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('VICE:ReturnFetchedCars', source, returned_table, fuellevels, vehicleweights)
        end)
    end
end)

RegisterNetEvent('VICE:CrushVehicle')
AddEventHandler('VICE:CrushVehicle', function(vehicle)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then 
        MySQL.query("VICE/check_rented", {user_id = user_id, vehicle = vehicle}, function(pvehicles)
            MySQL.query("VICE/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pveh)
                if #pveh < 0 then 
                    VICE.notify(source, "~r~You cannot destroy a vehicle you do not own")
                    return
                end
                if #pvehicles > 0 then 
                    VICE.notify(source, "~r~You cannot destroy a rented vehicle!")
                    return
                end
                VICE.sendDCLog('vehicle', "VICE Crush Vehicle Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Vehicle: **"..vehicle.."**")
                MySQL.asyncQuery('VICE/remove_vehicle', {user_id = user_id, vehicle = vehicle})
                TriggerClientEvent('VICE:CloseGarage', source)
            end)
        end)
    end
end)

RegisterNetEvent('VICE:SellVehicle')
AddEventHandler('VICE:SellVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = VICE.getUserId(source)
    if playerID then
		VICEclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. VICE.getUserId(k) .. "]" .. VICE.getPlayerName(VICE.getUserId(k)) .. " | "
			end
			if usrList ~= "" then
				VICE.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id and user_id ~= "" then 
						local target = VICE.getUserSource(tonumber(user_id))
						if target then
							VICE.prompt(player,"Price £: ","",function(player,amount)
								if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
									MySQL.query("VICE/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
										if #pvehicle > 0 then
											VICE.notify(player, "~r~The player already has this vehicle type.")
										else
											local tmpdata = VICE.getUserTmpTable(playerID)
											MySQL.query("VICE/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                if #pvehicles > 0 then 
                                                    VICE.notify(player, "~r~You cannot sell a rented vehicle!")
                                                    return
                                                else
                                                    VICE.request(target,VICE.getPlayerName(VICE.getUserId(player)).." wants to sell: " ..name.. " Price: £"..getMoneyStringFormatted(amount), 10, function(target,ok)
                                                        if ok then
                                                            local pID = VICE.getUserId(target)
                                                            amount = tonumber(amount)
                                                            if VICE.tryFullPayment(pID,amount) then
                                                                VICEclient.despawnGarageVehicle(player,{'car',15}) 
                                                                VICE.getUserIdentity(pID, function(identity)
                                                                    MySQL.asyncQuery("VICE/sell_vehicle_player", {user_id = user_id, registration = "P "..identity.registration, oldUser = playerID, vehicle = name}) 
                                                                    MySQL.asyncQuery("VICE/update_vehicle_mods", {user_id = user_id, oldUser = playerID, spawncode = name}) 
                                                                    MySQL.asyncQuery("VICE/update_vehicle_stancer", {user_id = user_id, oldUser = playerID, spawncode = name}) 
                                                                end)
                                                                VICE.giveBankMoney(playerID, amount)
                                                                VICE.notify(player, "~g~You have successfully sold the vehicle to ".. VICE.getPlayerName(VICE.getUserId(target)).." for £"..getMoneyStringFormatted(amount).."!")
                                                                VICE.notify(target, "~g~"..VICE.getPlayerName(VICE.getUserId(player)).." has successfully sold you the car for £"..getMoneyStringFormatted(amount).."!")
                                                                VICE.sendDCLog('vehicle', "VICE Sell Vehicle Logs", "> Seller Name: **"..VICE.getPlayerName(VICE.getUserId(player)).."**\n> Seller TempID: **"..player.."**\n> Seller PermID: **"..playerID.."**\n> Buyer Name: **"..VICE.getPlayerName(VICE.getUserId(target)).."**\n> Buyer TempID: **"..target.."**\n> Buyer PermID: **"..user_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Vehicle: **"..veh.."**")
                                                                TriggerClientEvent('VICE:CloseGarage', player)
                                                            else
                                                                VICE.notify(player, "~r~".. VICE.getPlayerName(VICE.getUserId(target)).." doesn't have enough money!")
                                                                VICE.notify(target, "~r~You don't have enough money!")
                                                            end
                                                        else
                                                            VICE.notify(player, "~r~"..VICE.getPlayerName(VICE.getUserId(target)).." has refused to buy the car.")
                                                            VICE.notify(target, "~r~You have refused to buy "..VICE.getPlayerName(VICE.getUserId(player)).."'s car.")
                                                        end
                                                    end)
                                                end
                                            end)
										end
									end) 
								else
									VICE.notify(player, "~r~The price of the car has to be a number.")
								end
							end)
						else
							VICE.notify(player, "~r~That ID seems invalid.")
						end
					else
						VICE.notify(player, "~r~No player ID selected.")
					end
				end)
			else
				VICE.notify(player, "~r~No players nearby.")
			end
		end)
    end
end)


RegisterNetEvent('VICE:RentVehicle')
AddEventHandler('VICE:RentVehicle', function(veh)
    local name = veh
    local player = source 
    local playerID = VICE.getUserId(source)
    if playerID then
		VICEclient.getNearestPlayers(player,{15},function(nplayers)
			usrList = ""
			for k,v in pairs(nplayers) do
				usrList = usrList .. "[" .. VICE.getUserId(k) .. "]" .. VICE.getPlayerName(VICE.getUserId(k)) .. " | "
			end
			if usrList ~= "" then
				VICE.prompt(player,"Players Nearby: " .. usrList .. "","",function(player,user_id) 
					user_id = user_id
					if user_id and user_id ~= "" then 
						local target = VICE.getUserSource(tonumber(user_id))
						if target then
							VICE.prompt(player,"Price £: ","",function(player,amount)
                                VICE.prompt(player,"Rent time (in hours): ","",function(player,rent)
                                    if tonumber(rent) and tonumber(rent) >  0 then 
                                        if tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) < limit then
                                            MySQL.query("VICE/get_vehicle", {user_id = user_id, vehicle = name}, function(pvehicle, affected)
                                                if #pvehicle > 0 then
                                                    VICE.notify(player, "~r~The player already has this vehicle.")
                                                else
                                                    local tmpdata = VICE.getUserTmpTable(playerID)
                                                    MySQL.query("VICE/check_rented", {user_id = playerID, vehicle = veh}, function(pvehicles)
                                                        if #pvehicles > 0 then 
                                                            return
                                                        else
                                                            VICE.prompt(player, "Please replace text with YES or NO to confirm", "Rent Details:\nVehicle: "..name.."\nRent Cost: "..getMoneyStringFormatted(amount).."\nDuration: "..rent.." hours\nRenting to player: "..VICE.getPlayerName(VICE.getUserId(target)).."("..VICE.getUserId(target)..")",function(player,details)
                                                                if string.upper(details) == 'YES' then
                                                                    VICE.notify(player, '~g~Rent offer sent!')
                                                                    VICE.request(target,VICE.getPlayerName(VICE.getUserId(player)).." wants to rent: " ..name.. " Price: £"..getMoneyStringFormatted(amount) .. ' | for: ' .. rent .. 'hours', 10, function(target,ok)
                                                                        if ok then
                                                                            local pID = VICE.getUserId(target)
                                                                            amount = tonumber(amount)
                                                                            if VICE.tryFullPayment(pID,amount) then
                                                                                VICEclient.despawnGarageVehicle(player,{'car',15}) 
                                                                                VICE.getUserIdentity(pID, function(identity)
                                                                                    local rentedTime = os.time()
                                                                                    rentedTime = rentedTime  + (60 * 60 * tonumber(rent)) 
                                                                                    MySQL.asyncQuery("VICE/rentedupdate", {user_id = playerID, veh = name, id = pID, rented = 1, rentedid = playerID, rentedunix =  rentedTime }) 
                                                                                    MySQL.asyncQuery('VICE/rentedupdate_mods', {user_id = playerID, veh = name, id = pID})
                                                                                    MySQL.asyncQuery('VICE/rentedupdate_stancer', {user_id = playerID, veh = name, id = pID})
                                                                                end)
                                                                                VICE.giveBankMoney(playerID, amount)
                                                                                VICE.notify(player, "~g~You have successfully rented the vehicle to "..VICE.getPlayerName(VICE.getUserId(target)).." for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours')
                                                                                VICE.notify(target, "~g~"..VICE.getPlayerName(VICE.getUserId(player)).." has successfully rented you the car for £"..getMoneyStringFormatted(amount)..' for ' ..rent.. 'hours')
                                                                                VICE.sendDCLog('vehicle', "VICE Rent Vehicle Logs", "> Renter Name: **"..VICE.getPlayerName(VICE.getUserId(player)).."**\n> Renter TempID: **"..player.."**\n> Renter PermID: **"..playerID.."**\n> Rentee Name: **"..VICE.getPlayerName(VICE.getUserId(target)).."**\n> Rentee TempID: **"..target.."**\n> Rentee PermID: **"..pID.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**\n> Duration: **"..rent.." hours**\n> Vehicle: **"..veh.."**")
                                                                                --TriggerClientEvent('VICE:CloseGarage', player)
                                                                            else
                                                                                VICE.notify(player, "~r~".. VICE.getPlayerName(VICE.getUserId(target)).." doesn't have enough money!")
                                                                                VICE.notify(target, "~r~You don't have enough money!")
                                                                            end
                                                                        else
                                                                            VICE.notify(player, "~r~"..VICE.getPlayerName(VICE.getUserId(target)).." has refused to rent the car.")
                                                                            VICE.notify(target, "~r~You have refused to rent "..VICE.getPlayerName(VICE.getUserId(player)).."'s car.")
                                                                        end
                                                                    end)
                                                                else
                                                                    VICE.notify(player, '~r~Rent offer cancelled!')
                                                                end
                                                            end)
                                                        end
                                                    end)
                                                end
                                            end) 
                                        else
                                            VICE.notify(player, "~r~The price of the car has to be a number.")
                                        end
                                    else 
                                        VICE.notify(player, "~r~The rent time of the car has to be in hours and a number.")
                                    end
                                end)
							end)
						else
							VICE.notify(player, "~r~That ID seems invalid.")
						end
					else
						VICE.notify(player, "~r~No player ID selected.")
					end
				end)
			else
				VICE.notify(player, "~r~No players nearby.")
			end
		end)
    end
end)



RegisterNetEvent('VICE:FetchRented')
AddEventHandler('VICE:FetchRented', function()
    local rentedin = {}
    local rentedout = {}
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_rented_vehicles_in", {user_id = user_id}, function(pvehicles, affected)
        for _, veh in pairs(pvehicles) do
            for i, v in pairs(vehicle_groups) do
                local config = vehicle_groups[i]._config
                local perm = config.permissions or nil
                if perm then
                    for i, v in pairs(perm) do
                        if not VICE.hasPermission(user_id, v) then
                            break
                        end
                    end
                end
                for a, z in pairs(v) do
                    if a ~= "_config" and veh.vehicle == a then
                        if not rentedin.vehicles then 
                            rentedin.vehicles = {}
                        end
                        local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                        local minutesLeft = nil
                        if hoursLeft < 1 then
                            minutesLeft = hoursLeft * 60
                            minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                            datetime = minutesLeft .. " mins" 
                        else
                            hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                            datetime = hoursLeft .. " hours" 
                        end
                        rentedin.vehicles[a] = {z[1], datetime, veh.user_id, a}
                    end
                end
            end
        end
        MySQL.query("VICE/get_rented_vehicles_out", {user_id = user_id}, function(pvehicles, affected)
            for _, veh in pairs(pvehicles) do
                for i, v in pairs(vehicle_groups) do
                    local config = vehicle_groups[i]._config
                    local perm = config.permissions or nil
                    if perm then
                        for i, v in pairs(perm) do
                            if not VICE.hasPermission(user_id, v) then
                                break
                            end
                        end
                    end
                    for a, z in pairs(v) do
                        if a ~= "_config" and veh.vehicle == a then
                            if not rentedout.vehicles then 
                                rentedout.vehicles = {}
                            end
                            local hoursLeft = ((tonumber(veh.rentedtime)-os.time()))/3600
                            local minutesLeft = nil
                            if hoursLeft < 1 then
                                minutesLeft = hoursLeft * 60
                                minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
                                datetime = minutesLeft .. " mins" 
                            else
                                hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
                                datetime = hoursLeft .. " hours" 
                            end
                            rentedout.vehicles[a] = {z[1], datetime, veh.user_id, a}
                        end
                    end
                end
            end
            TriggerClientEvent('VICE:ReturnedRentedCars', source, rentedin, rentedout)
        end)
    end)
end)

RegisterNetEvent('VICE:CancelRent')
AddEventHandler('VICE:CancelRent', function(spawncode, VehicleName, a)
    local source = source
    local user_id = VICE.getUserId(source)
    if a == 'owner' then
        exports['vice']:execute("SELECT * FROM vice_user_vehicles WHERE rentedid = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local target = VICE.getUserSource(result[i].user_id)
                        if target then
                            VICE.request(target,VICE.getPlayerName(user_id).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.asyncQuery('VICE/rentedupdate', {id = user_id, rented = 0, rentedid = "", rentedunix = "", user_id = result[i].user_id, veh = spawncode})
                                    MySQL.asyncQuery('VICE/rentedupdate_mods', {id = user_id, user_id = result[i].user_id, veh = spawncode})
                                    MySQL.asyncQuery('VICE/rentedupdate_stancer', {id = user_id, user_id = result[i].user_id, veh = spawncode})
                                    VICE.notify(target, "~r~" ..VehicleName.." has been returned to the vehicle owner.")
                                    VICE.notify(source, "~r~" ..VehicleName.." has been returned to your garage.")
                                else
                                    VICE.notify(source, "~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName)
                                end
                            end)
                        else
                            VICE.notify(source, "~r~The player is not online.")
                        end
                    end
                end
            end
        end)
    elseif a == 'renter' then
        exports['vice']:execute("SELECT * FROM vice_user_vehicles WHERE user_id = @id", {id = user_id}, function(result)
            if #result > 0 then 
                for i = 1, #result do 
                    if result[i].vehicle == spawncode and result[i].rented then
                        local rentedid = tonumber(result[i].rentedid)
                        local target = VICE.getUserSource(rentedid)
                        if target then
                            VICE.request(target,VICE.getPlayerName(user_id).." would like to cancel the rent on the vehicle: ", 10, function(target,ok)
                                if ok then
                                    MySQL.asyncQuery('VICE/rentedupdate', {id = rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = user_id, veh = spawncode})
                                    MySQL.asyncQuery('VICE/rentedupdate_mods', {id = rentedid, user_id = user_id, veh = spawncode})
                                    MySQL.asyncQuery('VICE/rentedupdate_stancer', {id = rentedid, user_id = user_id, veh = spawncode})
                                    VICE.notify(source, "~r~" ..VehicleName.." has been returned to the vehicle owner.")
                                    VICE.notify(target, "~r~" ..VehicleName.." has been returned to your garage.")
                                else
                                    VICE.notify(source, "~r~User has declined the request to cancel the rental of vehicle: " ..VehicleName)
                                end
                            end)
                        else
                            VICE.notify(source, "~r~The player is not online.")
                        end
                    end
                end
            end
        end)
    end
end)

-- repair nearest vehicle
RegisterNetEvent("VICE:attemptRepairVehicle")
AddEventHandler("VICE:attemptRepairVehicle", function(entityNetworkId)
    local source = source
    local user_id = VICE.getUserId(source)
    local ai = NetworkGetEntityFromNetworkId(entityNetworkId)
    if ai then
        if VICE.tryGetInventoryItem(user_id, "repairkit", 1, true) then
            VICEclient.playAnim(source, {false, {task = "WORLD_HUMAN_WELDING"}, false})
            VICEclient.startCircularProgressBar(source, {"", 15000, nil})
            SetTimeout(15000, function()
                VICEclient.fixeNearestVehicle(source, {7}, ai)
                VICEclient.stopAnim(source, {false})
            end)
        else
            --VICE.notify(source, "~r~Missing DIY Repair Kit 1.") 
        end
    else
        VICE.notify(source, "~r~No vehicle nearby to repair.") 
    end
    -- else
    --     VICE.ACBan(15,user_id,"VICE:attemptRepairVehicle")
    -- end
end)

RegisterNetEvent("VICE:PayVehicleTax")
AddEventHandler("VICE:PayVehicleTax", function()
    local user_id = VICE.getUserId(source)
    if user_id then
        local bank = VICE.getBankMoney(user_id)
        local payment = bank / 10000

        if payment > 0 then
            if VICE.tryBankPayment(user_id, payment) then
                VICE.notify(source, "~g~Paid £"..getMoneyStringFormatted(math.floor(payment)).." vehicle tax.")
                TriggerEvent('VICE:addToCommunityPot', math.floor(payment))
            else
                VICE.notify(source, "~r~Vehicle tax paid kindly via the government.")
            end
        else
            VICE.notify(source, "~r~Vehicle tax paid kindly via the government.")
        end
    end
end)


RegisterNetEvent("VICE:refreshGaragePermissions")
AddEventHandler("VICE:refreshGaragePermissions",function()
    local source=source
    local garageTable={}
    local user_id = VICE.getUserId(source)
    for k,v in pairs(cfg.garages) do
        for a,b in pairs(v) do
            if a == "_config" then
                if json.encode(b.permissions) ~= '[""]' then
                    local hasPermissions = 0
                    for c,d in pairs(b.permissions) do
                        if VICE.hasPermission(user_id, d) then
                            hasPermissions = hasPermissions + 1
                        end
                    end
                    if hasPermissions == #b.permissions then
                        table.insert(garageTable, k)
                    end
                else
                    table.insert(garageTable, k)
                end
            end
        end
    end
    local ownedVehicles = {}
    if user_id then
        MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(pvehicles, affected)
            for k,v in pairs(pvehicles) do
                table.insert(ownedVehicles, v.vehicle)
            end
            TriggerClientEvent('VICE:updateOwnedVehicles', source, ownedVehicles)
        end)
    end
    TriggerClientEvent("VICE:receivedRefreshedGaragePermissions",source,garageTable)
end)


RegisterNetEvent("VICE:getGarageFolders")
AddEventHandler("VICE:getGarageFolders",function()
    local source = source
    local user_id = VICE.getUserId(source)
    local garageFolders = {}
    local addedFolders = {}
    MySQL.query("VICE/get_vehicles", {user_id = user_id}, function(result)
        if result then 
            for k,v in pairs(result) do
                local spawncode = v.vehicle 
                for a,b in pairs(vehicle_groups) do
                    if not string.find(a,"Aircraft") and not string.find(a,"Helicopters") and not string.find(a,"Boats") then
                        local hasPerm = true
                        if next(b._config.permissions) then
                            if not VICE.hasPermission(user_id, b._config.permissions[1]) then
                                hasPerm = false
                            end
                        end
                        if hasPerm then
                            for c,d in pairs(b) do
                                if c == spawncode and not v.impounded then
                                    if not addedFolders[a] then
                                        table.insert(garageFolders, {display = a})
                                        addedFolders[a] = true
                                    end
                                    for e,f in pairs (garageFolders) do
                                        if f.display == a then
                                            if f.vehicles == nil then
                                                f.vehicles = {}
                                            end
                                            table.insert(f.vehicles, {display = d[1], spawncode = spawncode})
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            TriggerClientEvent('VICE:setVehicleFolders', source, garageFolders)
        end
    end)
end)

local cfg_weapons = module("cfg/weapons")

RegisterServerEvent("VICE:searchVehicle")
AddEventHandler('VICE:searchVehicle', function(entity, permid)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'ukbf.armoury') then
        if VICE.getUserSource(permid) then
            VICEclient.getNetworkedVehicleInfos(VICE.getUserSource(permid), {entity}, function(owner, spawncode)
                if spawncode and owner == permid then
                    local vehformat = 'chest:u1veh_'..spawncode..'|'..permid
                    VICE.getSData(vehformat, function(cdata)
                        if cdata then
                            cdata = json.decode(cdata)
                            if next(cdata) then
                                for a,b in pairs(cdata) do
                                    if string.find(a, 'wbody|') then
                                        c = a:gsub('wbody|', '')
                                        cdata[c] = b
                                        cdata[a] = nil
                                    end
                                end
                                for k,v in pairs(cfg_weapons.weapons) do
                                    if cdata[k] then
                                        if not v.policeWeapon then
                                            VICE.notify(source, '~r~Seized '..v.name..' x'..cdata[k].amount..'.')
                                            cdata[k] = nil
                                        end
                                    end
                                end
                                for c,d in pairs(cdata) do
                                    if seizeBullets[c] then
                                        VICE.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                        cdata[c] = nil
                                    end
                                    if seizeDrugs[c] then
                                        VICE.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                        cdata[c] = nil
                                    end
                                end
                                VICE.setSData(vehformat, json.encode(cdata))
                                VICE.sendDCLog('seize-boot', 'VICE Seize Boot Logs', "> Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Vehicle: **"..spawncode.."**\n> Owner ID: **"..permid.."**")
                            else
                                VICE.notify(source, '~r~This vehicle is empty.')
                            end
                        else
                            VICE.notify(source, '~r~This vehicle is empty.')
                        end
                    end)
                end
            end)
        end
    end
end)


Citizen.CreateThread(function()
    Wait(1500)
    exports['vice']:execute([[
        CREATE TABLE IF NOT EXISTS `vice_custom_garages` (
            `user_id` INT(11) NOT NULL AUTO_INCREMENT,
            `folder` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
            PRIMARY KEY (`user_id`) USING BTREE
        );
    ]])
end)



-- function tVICE.CreateVehicle(hash, x, y, z, heading, isNetwork, netMissionEntity)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if source and user_id then
--         local vehicle = CreateVehicle(hash, x, y, z, heading, isNetwork, netMissionEntity)
--         Wait(100)
--         if DoesEntityExist(vehicle) then
--             SetPedIntoVehicle(GetPlayerPed(source), vehicle, -1)
--             return NetworkGetNetworkIdFromEntity(vehicle)
--         end
--     end
--     return nil
-- end


function tVICE.CreateVehicle(hash, x, y, z, heading, isNetwork, netMissionEntity)
    local veh = CreateVehicle(hash, x, y, z, heading, isNetwork, netMissionEntity)
    Wait(100)
    if DoesEntityExist(veh) then
        -- SetEntityAsMissionEntity(veh, true, true)
        -- SetVehicleHasBeenOwnedByPlayer(veh, true)
        local netId = NetworkGetNetworkIdFromEntity(veh)
        return netId
    end
    return nil
end


RegisterCommand("car", function (src,args)
    local user_id = VICE.getUserId(src)
    if VICE.hasGroup(user_id,"Founder") then
        local ped = GetPlayerPed(src)
        local heading = GetEntityHeading(ped)
        local coords = GetEntityCoords(ped)
        local model = args[1]
        local vehicleHash = GetHashKey(model)
        local vehicle = tVICE.CreateVehicle(vehicleHash, coords.x, coords.y, coords.z, heading, true, false)
        Wait(250)
        SetPedIntoVehicle(ped,vehicle,-1)
    end
end)

