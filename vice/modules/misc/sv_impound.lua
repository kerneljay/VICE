local cfg = module("VICEVeh", "cfg_garages")
local impoundcfg = module("cfg/cfg_impound")

MySQL.createCommand("VICE/get_impounded_vehicles", "SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND impounded = 1")
MySQL.createCommand("VICE/get_all_impounded_vehicles", "SELECT * FROM vice_user_vehicles WHERE impounded = 1")
MySQL.createCommand("VICE/get_vehicles_impounded", "SELECT vehicle, rentedtime, vehicle_plate, fuel_level FROM vice_user_vehicles WHERE user_id = @user_id AND rented = 0")
MySQL.createCommand("VICE/unimpound_vehicle", "UPDATE vice_user_vehicles SET impounded = 0, impound_info = null, impound_time = null WHERE vehicle = @vehicle AND user_id = @user_id")
MySQL.createCommand("VICE/impound_vehicle", "UPDATE vice_user_vehicles SET impounded = 1, impound_info = @impound_info, impound_time = @impound_time WHERE vehicle = @vehicle AND user_id = @user_id")



RegisterNetEvent('VICE:getImpoundedVehicles')
AddEventHandler('VICE:getImpoundedVehicles', function()
    local source = source
    local user_id = VICE.getUserId(source)
    local returned_table = {}
    if user_id then
        MySQL.query("VICE/get_impounded_vehicles", {user_id = user_id}, function(impoundedvehicles)
            for k,v in pairs(impoundedvehicles) do
                if impoundedvehicles[k]['impound_info'] ~= '' then
                    data = json.decode(impoundedvehicles[k]['impound_info'])
                    returned_table[v.vehicle] = {vehicle = v.vehicle, vehicle_name = data.vehicle_name, impounded_by_name = data.impounded_by_name, impounder = data.impounder, reasons = data.reasons}
                end
            end
            TriggerClientEvent('VICE:receiveImpoundedVehicles', source, returned_table)
        end)
    end
end)


RegisterNetEvent('VICE:fetchInfoForVehicleToImpound')
AddEventHandler('VICE:fetchInfoForVehicleToImpound', function(userid, spawncode, entityid)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        for k,v in pairs(cfg.garages) do
            for a,b in pairs(v) do
                if a == spawncode then
                    vehicle = spawncode
                    vehicle_name = b[1]
                    owner_id = userid
                    vehiclenetid = entityid
                    if VICE.getUserSource(userid) then
                        owner_name = VICE.getPlayerName(VICE.getUserSource(userid))
                        TriggerClientEvent('VICE:receiveInfoForVehicleToImpound', source, owner_id, owner_name, vehicle, vehicle_name, vehiclenetid)
                        return
                    else
                        VICE.notify(source, '~r~Unable to locate owner.')
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('VICE:releaseImpoundedVehicle')
AddEventHandler('VICE:releaseImpoundedVehicle', function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_impounded_vehicles", { user_id = user_id }, function(impoundedvehicles)
        for k, v in pairs(impoundedvehicles) do
            if impoundedvehicles[k]['impound_time'] ~= '' then
                if os.time() >= tonumber(impoundedvehicles[k]['impound_time']) + 600 then
                    if VICE.tryFullPayment(user_id, 25000) then
                        local fixedSpawnPos = impoundcfg.positions["City"][math.random(1, #impoundcfg.positions["City"])]
                        if #(GetEntityCoords(GetPlayerPed(source)) - vector3(-442.59323120117,5994.7045898438,30.490104675293)) <= 10.0 then
                            fixedSpawnPos = impoundcfg.positions["Paleto"][math.random(1, #impoundcfg.positions["Paleto"])]
                        end
                        MySQL.query("VICE/unimpound_vehicle", { vehicle = spawncode, user_id = user_id }, function(result)
                            MySQL.query("VICE/get_vehicles_impounded", { user_id = user_id }, function(result)
                                if result then 
                                    for k, v in pairs(result) do
                                        if v.vehicle == spawncode then
                                            TriggerClientEvent('VICE:spawnPersonalVehicle', source, v.vehicle, VICE.GetMods(v.vehicle,user_id), false, vector3(fixedSpawnPos.x,fixedSpawnPos.y,fixedSpawnPos.z), v.vehicle_plate, v.fuel_level)
                                            TriggerEvent('VICE:addToCommunityPot', 10000)
                                            VICE.notifyPicture(source, "polnotification", "notification", "Your vehicle has been released from the impound at the cost of ~g~£10,000~w~.", "MetPD", "Vehicle Impound")
                                            return
                                        end
                                    end
                                end
                            end)
                        end)
                    else
                        VICE.notify(source, '~r~You do not have enough money to retrieve your vehicle from the impound.')
                    end
                else
                    VICE.notifyPicture(source, "polnotification", "notification", "This vehicle cannot be unimpounded for another " .. math.floor((tonumber(impoundedvehicles[k]['impound_time']) + 600 - os.time()) / 60) .. " minutes ~w~.")
                end
            end
        end
    end)
end)

RegisterNetEvent('VICE:impoundVehicle')
AddEventHandler('VICE:impoundVehicle', function(userid, name, spawncode, vehiclename, reasons, entityid)
    local source = source
    local user_id = VICE.getUserId(source)
    local entitynetid = NetworkGetEntityFromNetworkId(entityid)
    if VICE.hasPermission(user_id, 'police.armoury') then
        local m = {}
        for k,v in pairs(impoundcfg.reasonsForImpound) do 
            for a,b in pairs(reasons) do
                if k == a then
                    table.insert(m, v.option)
                end
            end
        end
        MySQL.execute("VICE/impound_vehicle", {impound_info = json.encode({vehicle_name = vehiclename, impounded_by_name = VICE.getPlayerName(user_id), impounder = user_id, reasons = m}), impound_time = os.time(), vehicle = spawncode, user_id = userid})
        local A,B = GetVehicleColours(entitynetid)
        TriggerClientEvent('VICE:impoundSuccess', source, entityid, vehiclename, VICE.getPlayerName(VICE.getUserSource(userid)), spawncode, A, B, GetEntityCoords(entitynetid), GetEntityHeading(entitynetid))
        VICE.notifyPicture(VICE.getUserSource(userid), "polnotification","notification","Your "..vehiclename.." has been impounded by ~b~"..VICE.getPlayerName(user_id).." \n\n~w~For more information please visit the impound.","Metropolitan Police","Impound",nil,nil)
        VICE.sendDCLog('impound', 'VICE Seize Boot Logs', "> Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Vehicle: **"..spawncode.."**\n> Vehicle Name: **"..vehiclename.."**\n> Owner ID: **"..userid.."**")
    end
end)

local vehiclesOut = {}

AddEventHandler('VICE:spawnRandomImpoundedVehicle', function(source)
    MySQL.query("VICE/get_all_impounded_vehicles", {}, function(impoundedvehicles)
        if #impoundedvehicles > 0 then
            for k,v in pairs(impoundedvehicles) do
                if v['impound_info'] ~= '' and not vehiclesOut[v.vehicle] then
                    VICE.notify(source, '~o~You have requested a vehicle from the impound.')
                    TriggerClientEvent("VICE:spawnRandomImpound", source, v.vehicle)
                    vehiclesOut[v.vehicle] = true
                    return
                end
            end
            VICE.notify(source, '~r~No impounded vehicles found.')
        else
            VICE.notify(source, '~r~Vehicle is already out.')
        end
    end)
end)

RegisterCommand("requestimpounded", function(source, args, rawCommand)
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        TriggerEvent('VICE:spawnRandomImpoundedVehicle', source)
    else
        VICE.notify(source, '~r~You have to be clocked on duty.')
    end
end)

RegisterServerEvent("VICE:deleteImpoundEntities")
AddEventHandler("VICE:deleteImpoundEntities", function(a,b,c)
    TriggerClientEvent("VICE:deletePropClient", -1, a)
    TriggerClientEvent("VICE:deletePropClient", -1, b)
    TriggerClientEvent("VICE:deletePropClient", -1, c)
end)

RegisterServerEvent("VICE:awaitTowTruckArrival")
AddEventHandler("VICE:awaitTowTruckArrival", function(vehicle, flatbed, ped)
    local count = 0
    while count < 30 do
        Citizen.Wait(1000)
        count = count + 1
    end
    if count == 30 then
        TriggerClientEvent("VICE:deletePropClient", -1, vehicle)
        TriggerClientEvent("VICE:deletePropClient", -1, flatbed)
        TriggerClientEvent("VICE:deletePropClient", -1, ped)
    end
end)
