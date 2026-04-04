RegisterNetEvent('VICE:sendSharedEmoteRequest')
AddEventHandler('VICE:sendSharedEmoteRequest', function(playersrc, emote)
    local source = source
    TriggerClientEvent('VICE:sendSharedEmoteRequest', playersrc, source, emote)
end)

RegisterNetEvent('VICE:receiveSharedEmoteRequest')
AddEventHandler('VICE:receiveSharedEmoteRequest', function(i, a)
    local source = source
    TriggerClientEvent('VICE:receiveSharedEmoteRequestSource', i)
    TriggerClientEvent('VICE:receiveSharedEmoteRequest', source, a)
end)

local shavedPlayers = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for k,v in pairs(shavedPlayers) do
            if shavedPlayers[k] then
                if shavedPlayers[k].cooldown > 0 then
                    shavedPlayers[k].cooldown = shavedPlayers[k].cooldown - 1
                else
                    shavedPlayers[k] = nil
                end
            end
        end
    end
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    SetTimeout(1000, function() 
        local source = source
        local user_id = VICE.getUserId(source)
        if first_spawn and shavedPlayers[user_id] then
            TriggerClientEvent('VICE:setAsShaved', source, (shavedPlayers[user_id].cooldown*60*1000))
        end
    end)
end)

function VICE.ShaveHead(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.getInventoryItemAmount(user_id, 'Shaver') >= 1 then
        VICEclient.getNearestPlayer(source,{4},function(nplayer)
            if nplayer then
                VICEclient.globalSurrenderring(nplayer,{},function(globalSurrenderring)
                    if globalSurrenderring then
                        VICE.tryGetInventoryItem(user_id, 'Shaver', 1)
                        TriggerClientEvent('VICE:startShavingPlayer', source, nplayer)
                        TriggerClientEvent('VICE:startBeingShaved', nplayer, source)
                        TriggerClientEvent('VICE:playDelayedShave', -1, source)
                        shavedPlayers[VICE.getUserId(nplayer)] = {
                            cooldown = 30,
                        }
                    else
                        VICE.notify(source, '~r~This player is not on their knees.')
                    end
                end)
            else
                VICE.notify(source, "~r~No one nearby.")
            end
        end)
    end
end
