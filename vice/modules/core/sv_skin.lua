RegisterNetEvent("VICE:saveFaceData")
AddEventHandler("VICE:saveFaceData", function(faceSaveData)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.setUData(user_id, "VICE:Face:Data", json.encode(faceSaveData))
end)

RegisterNetEvent("VICE:saveClothingHairData") -- this updates hair from clothing stores
AddEventHandler("VICE:saveClothingHairData", function(hairtype, haircolour)
    local source = source
    local user_id = VICE.getUserId(source)
    local facesavedata = {}
    VICE.getUData(user_id, "VICE:Face:Data", function(data)
        if data and data ~= 0 and hairtype and haircolour then
            facesavedata = json.decode(data)
            if facesavedata == nil then
                facesavedata = {}
            end
            facesavedata["hair"] = hairtype
            facesavedata["haircolor"] = haircolour
            VICE.setUData(user_id, "VICE:Face:Data", json.encode(facesavedata))
        end
    end)
end)

RegisterNetEvent("VICE:getPlayerHairstyle")
AddEventHandler("VICE:getPlayerHairstyle", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:Face:Data", function(data)
        if data and data ~= 0 then
            TriggerClientEvent("VICE:setHairstyle", source, json.decode(data))
        end
    end)
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    SetTimeout(1000, function() 
        local source = source
        local user_id = VICE.getUserId(source)
        VICE.getUData(user_id, "VICE:Face:Data", function(data)
            if data and data ~= 0 then
                TriggerClientEvent("VICE:setHairstyle", source, json.decode(data))
            end
        end)
    end)
end)