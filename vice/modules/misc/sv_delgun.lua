netObjects = {}

RegisterServerEvent("VICE:spawnVehicleCallback")
AddEventHandler('VICE:spawnVehicleCallback', function(a, b)
    netObjects[b] = {source = VICE.getUserSource(a), id = a, name = VICE.getPlayerName(a)}
end)

RegisterServerEvent("VICE:delGunDelete")
AddEventHandler("VICE:delGunDelete", function(object)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("VICE:deletePropClient", -1, object)
        if netObjects[object] then
            TriggerClientEvent("VICE:returnObjectDeleted", source, 'This object was created by ~b~'..netObjects[object].name..'~w~. Temp ID: ~b~'..netObjects[object].source..'~w~.\nPerm ID: ~b~'..netObjects[object].id..'~w~.')
        end
    end
end)