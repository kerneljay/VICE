local flaggedVehicles = {}

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if VICE.hasPermission(user_id, 'police.armoury') then
            TriggerClientEvent('VICE:setFlagVehicles', source, flaggedVehicles)
        end
    end
end)

RegisterServerEvent("VICE:flagVehicleAnpr")
AddEventHandler("VICE:flagVehicleAnpr", function(plate, reason)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        flaggedVehicles[plate] = reason
        TriggerClientEvent('VICE:setFlagVehicles', -1, flaggedVehicles)
    end
end)