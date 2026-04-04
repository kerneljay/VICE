local spikes = 0
local speedzones = 0

RegisterNetEvent("VICE:placeSpike")
AddEventHandler("VICE:placeSpike", function(heading, coords)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        TriggerClientEvent('VICE:addSpike', -1, coords, heading)
    end
end)

RegisterNetEvent("VICE:removeSpike")
AddEventHandler("VICE:removeSpike", function(entity)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        TriggerClientEvent('VICE:deleteSpike', -1, entity)
        TriggerClientEvent("VICE:deletePropClient", -1, entity)
    end
end)

RegisterNetEvent("VICE:requestSceneObjectDelete")
AddEventHandler("VICE:requestSceneObjectDelete", function(prop)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
        TriggerClientEvent("VICE:deletePropClient", -1, prop)
    end
end)

RegisterNetEvent("VICE:createSpeedZone")
AddEventHandler("VICE:createSpeedZone", function(coords, radius, speed)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') or VICE.hasPermission(user_id, 'dev.menu')then
        speedzones = speedzones + 1
        TriggerClientEvent('VICE:createSpeedZone', -1, speedzones, coords, radius, speed)
    end
end)

RegisterNetEvent("VICE:deleteSpeedZone")
AddEventHandler("VICE:deleteSpeedZone", function(speedzone)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
        TriggerClientEvent('VICE:deleteSpeedZone', -1, speedzones, coords, radius, speed)
    end
end)

