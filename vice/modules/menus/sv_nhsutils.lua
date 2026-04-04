local bodyBags = {}

RegisterServerEvent("VICE:requestBodyBag")
AddEventHandler('VICE:requestBodyBag', function(playerToBodyBag)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:placeBodyBag', playerToBodyBag)
        VICE.AddStat(user_id,"bodybagged",1)
    end
end)

RegisterServerEvent("VICE:removeBodybag")
AddEventHandler('VICE:removeBodybag', function(bodybagObject)
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:removeIfOwned', -1, NetworkGetEntityFromNetworkId(bodybagObject))
end)

RegisterServerEvent("VICE:playNhsSound")
AddEventHandler('VICE:playNhsSound', function(sound)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        TriggerClientEvent('VICE:clientPlayNhsSound', -1, GetEntityCoords(GetPlayerPed(source)), sound)
    else
        VICE.ACBan(15,user_id,"VICE:playNhsSound")
    end
end)

-- a = coma
-- c = userid
-- b = permid
-- 4th ready to revive
-- name

local lifePaksConnected = {}

RegisterServerEvent("VICE:attachLifepakServer")
AddEventHandler('VICE:attachLifepakServer', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        VICEclient.getNearestPlayer(source, {3}, function(nplayer)
            local nuser_id = VICE.getUserId(nplayer)
            if nuser_id then
                VICEclient.isInComa(nplayer, {}, function(in_coma)
                    TriggerClientEvent('VICE:attachLifepak', source, in_coma, nuser_id, nplayer, VICE.getPlayerName(nuser_id))
                    lifePaksConnected[user_id] = {permid = nuser_id} 
                end)
            else
                VICE.notify(source, "~r~There is no player nearby")
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:attachLifepakServer")
    end
end)


RegisterServerEvent("VICE:finishRevive")
AddEventHandler('VICE:finishRevive', function(permid)
    local source = source
    local user_id = VICE.getUserId(source)
    local nuser_id = VICE.getUserSource(permid)
    if VICE.hasPermission(user_id, 'nhs.menu') then 
        for k,v in pairs(lifePaksConnected) do
            if k == user_id and v.permid == permid then
                TriggerClientEvent('VICE:returnRevive', source)
                lifePaksConnected[k] = nil
                TriggerClientEvent('VICE:attemptCPR', source)
                Wait(15000)
                VICE.giveBankMoney(user_id, 5000)
                TriggerClientEvent('TriggerTazer', nuser_id)
                VICE.notify(source, "~g~Successfully shocked patient " .. VICE.getPlayerName(permid) .. "!")
                TriggerClientEvent('VICE:cancelCPRAttempt', source)
                VICEclient.RevivePlayer(nuser_id, {})
                VICE.notify(nuser_id, "~g~You have been medically treated. Please remember to thank the NHS!")
                VICE.AddStat(user_id,"revives",1)
                VICE.sendDCLog('nhs-cpr', 'VICE NHS CPR Logs',"> NHS Name: **"..VICE.getPlayerName(user_id).."**\n> NHS TempID: **"..source.."**\n> NHS PermID: **"..user_id.."**\n> Paitent PermID: **"..permid.."**")
            end
        end
    else
        VICE.ACBan(15,user_id,"VICE:finishRevive")
    end
end)


RegisterServerEvent("VICE:nhsRevive") -- nhs radial revive
AddEventHandler('VICE:nhsRevive', function(playersrc)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'nhs.menu') then
        VICEclient.isInComa(playersrc, {}, function(in_coma)
            if in_coma then
                TriggerClientEvent('VICE:beginRevive', source, in_coma, VICE.getUserId(playersrc), playersrc, VICE.getPlayerName(VICE.getUserId(playersrc)))
                lifePaksConnected[user_id] = {permid = VICE.getUserId(playersrc)} 
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:nhsRevive")
    end
end)

local playersInCPR = {}
RegisterServerEvent("VICE:attemptCPR")
AddEventHandler('VICE:attemptCPR', function(playersrc)
    local source = source
    local user_id = VICE.getUserId(source)
    VICEclient.getNearestPlayers(source,{15},function(nplayers)
        if nplayers[playersrc] then
            if GetEntityHealth(GetPlayerPed(playersrc)) > 102 then
                VICE.notify(source, "~r~This person has passed away. and can no longer be saved.")
            else
                playersInCPR[user_id] = true
                TriggerClientEvent('VICE:attemptCPR', source)
                Wait(15000)
                if playersInCPR[user_id] then
                    if VICE.tryGetInventoryItem(user_id,"medkit",1) then
                        VICEclient.RevivePlayer(playersrc, {})
                        VICE.notify(playersrc, "~b~" .. VICE.getPlayerName(VICE.getUserId(source)) .." saved your life with a medkit.")
                        VICE.notify(source, "~b~You saved " .. VICE.getPlayerName(VICE.getUserId(playersrc)) .."'s life.")
                    else
                        local cprChance = math.random(1,5)
                        if cprChance == 1 then 
                            VICEclient.RevivePlayer(playersrc, {})
                            VICE.notify(playersrc, "~b~" .. VICE.getPlayerName(VICE.getUserId(source)) .." saved your life.")
                            VICE.notify(source, "~b~You saved " .. VICE.getPlayerName(VICE.getUserId(playersrc)) .."'s life.")
                        else
                            VICE.notify(source, '~b~You tried to save this persons life, but you have failed.')
                        end
                        VICE.notify(source, "~r~CPR attempt has been canceled.")
                    end
                    playersInCPR[user_id] = nil
                    TriggerClientEvent('VICE:cancelCPRAttempt', source)
                end
            end
        else
            VICE.notify(source, "Player not found.")
        end
    end)
end)

RegisterServerEvent("VICE:cancelCPRAttempt")
AddEventHandler('VICE:cancelCPRAttempt', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if playersInCPR[user_id] then
        playersInCPR[user_id] = nil
        VICE.notify(source, "~r~CPR attempt has been canceled.")
        TriggerClientEvent('VICE:cancelCPRAttempt', source)
    end
end)

RegisterServerEvent("VICE:syncWheelchairPosition")
AddEventHandler('VICE:syncWheelchairPosition', function(netid, coords, heading)
    local source = source
    local user_id = VICE.getUserId(source)
    entity = NetworkGetEntityFromNetworkId(netid)
    SetEntityCoords(entity, coords.x, coords.y, coords.z)
    SetEntityHeading(entity, heading)
end)

RegisterServerEvent("VICE:wheelchairAttachPlayer")
AddEventHandler('VICE:wheelchairAttachPlayer', function(entity)
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:wheelchairAttachPlayer', -1, entity, source)
end)