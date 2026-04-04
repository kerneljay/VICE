RegisterCommand('k9', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('VICE:policeDogMenu', source)
    end
end)

RegisterCommand('k9attack', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('VICE:policeDogAttack', source)
    end
end)

RegisterNetEvent("VICE:serverDogAttack")
AddEventHandler("VICE:serverDogAttack", function(player)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'K9 Trained') then
        TriggerClientEvent('VICE:sendClientRagdoll', player)
    end
end)

RegisterNetEvent("VICE:policeDogSniffPlayer")
AddEventHandler("VICE:policeDogSniffPlayer", function(playerSrc)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'K9 Trained') then
       -- check for drugs
        local player_id = VICE.getUserId(playerSrc)
        local cdata = VICE.getUserDataTable(player_id)
        for a,b in pairs(cdata.inventory) do
            for c,d in pairs(seizeDrugs) do
                if a == c then
                    TriggerClientEvent('VICE:policeDogIndicate', source, playerSrc)
                end
            end
        end
    end
end)

RegisterNetEvent("VICE:performDogLog")
AddEventHandler("VICE:performDogLog", function(text)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'K9 Trained') then
        VICE.sendDCLog('police-k9', 'VICE Police Dog Logs',"> Officer Name: **"..VICE.getPlayerName(VICE.getUserId(source)).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Info: **"..text.."**")
    end
end)