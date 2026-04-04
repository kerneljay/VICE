local cfg=module("cfg/cfg_simeons")
local inventory=module("VICEVeh", "inventory")


RegisterNetEvent("VICE:refreshSimeonsPermissions")
AddEventHandler("VICE:refreshSimeonsPermissions",function()
    local source=source
    local simeonsCategories={}
    local user_id = VICE.getUserId(source)
    for k,v in pairs(cfg.simeonsCategories) do
        for a,b in pairs(v) do
            if a == "_config" then
                if b.permissionTable[1] then
                    if VICE.hasPermission(VICE.getUserId(source),b.permissionTable[1])then
                        for c,d in pairs(v) do
                            if inventory.vehicle_chest_weights[c] then
                                table.insert(v[c],inventory.vehicle_chest_weights[c])
                            else
                                table.insert(v[c],30)
                            end
                        end
                        simeonsCategories[k] = v
                    end
                else
                    for c,d in pairs(v) do
                        if inventory.vehicle_chest_weights[c] then
                            table.insert(v[c],inventory.vehicle_chest_weights[c])
                        else
                            table.insert(v[c],30)
                        end
                    end
                    simeonsCategories[k] = v
                end
            end
        end
    end
    TriggerClientEvent("VICE:gotCarDealerInstances",source,cfg.simeonsInstances)
    TriggerClientEvent("VICE:gotCarDealerCategories",source,simeonsCategories)
end)

RegisterNetEvent('VICE:purchaseCarDealerVehicle')
AddEventHandler('VICE:purchaseCarDealerVehicle', function(vehicleclass, vehicle)
    local source = source
    local user_id = VICE.getUserId(source)
    local playerName = VICE.getPlayerName(VICE.getUserId(source))   
    for k,v in pairs(cfg.simeonsCategories[vehicleclass]) do
        if k == vehicle then
            local vehicle_name = v[1]
            local vehicle_price = v[2]
            MySQL.query("VICE/get_vehicle", {user_id = user_id, vehicle = vehicle}, function(pvehicle, affected)
                if #pvehicle > 0 then
                    VICE.notify(source, "~r~Vehicle already owned.")
                else
                    if VICE.tryFullPayment(user_id, vehicle_price) then
                        VICEclient.generateUUID(source, {"plate", 5, "alphanumeric"}, function(uuid)
                            local uuid = string.upper(uuid)
                            MySQL.execute("VICE/add_vehicle", {user_id = user_id, vehicle = vehicle, registration = 'P'..uuid})
                            if tVICE.GetPlayTime(user_id) <= 48 then
                                VICE.notify(source, "~g~Vehicle purchased! Pick up your vehicle from the nearest garage!")
                            elseif vehicle_price == 0 then
                                VICE.notify(source, "~g~You got "..vehicle_name.." for free.")
                            else
                                VICE.notify(source, "~g~You paid £"..vehicle_price.." for "..vehicle_name..".")
                            end
                            TriggerEvent("VICE:tutorialStageServerUpdate", source, "simeons")
                            TriggerClientEvent("VICE:tutorialSimeonsVehiclePurchased", source)
                            TriggerClientEvent("vice:PlaySound", source, "playMoney")
                        end)
                    else
                        VICE.notify(source, "~r~Not enough money.")
                        TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
                    end
                end
            end)
        end
    end
end)
