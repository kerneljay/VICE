RegisterServerEvent("VICE:stretcherAttachPlayer")
AddEventHandler('VICE:stretcherAttachPlayer', function(playersrc)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:stretcherAttachPlayer', source, playersrc)
    end
end)

RegisterServerEvent("VICE:toggleAmbulanceDoors")
AddEventHandler('VICE:toggleAmbulanceDoors', function(stretcherNetid)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:toggleAmbulanceDoorStatus', -1, stretcherNetid)
    end
end)

RegisterServerEvent("VICE:updateHasStretcherInsideDecor")
AddEventHandler('VICE:updateHasStretcherInsideDecor', function(stretcherNetid, status)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:setHasStretcherInsideDecor', -1, stretcherNetid, status)
    end
end)

RegisterServerEvent("VICE:updateStretcherLocation")
AddEventHandler('VICE:updateStretcherLocation', function(a,b)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:setStretcherInside', -1, a,b)
    end
end)

RegisterServerEvent("VICE:removeStretcher")
AddEventHandler('VICE:removeStretcher', function(stretcher)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:deletePropClient', -1, stretcher)
    end
end)

RegisterServerEvent("VICE:forcePlayerOnToStretcher")
AddEventHandler('VICE:forcePlayerOnToStretcher', function(id, stretcher)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:forcePlayerOnToStretcher', id, stretcher)
    end
end)