--local cfg = module("cfg/survival")
local lang = VICE.lang


-- handlers

-- init values
AddEventHandler("VICE:playerJoin", function(user_id, source, name, last_login)
    local data = VICE.getUserDataTable(user_id)
end)


---- revive
local revive_seq = {{"amb@medic@standing@kneel@enter", "enter", 1}, {"amb@medic@standing@kneel@idle_a", "idle_a", 1},{"amb@medic@standing@kneel@exit", "exit", 1}}

local choice_revive = {function(player, choice)
    local user_id = VICE.getUserId(player)
    if user_id then
        VICEclient.getNearestPlayer(player, {10}, function(nplayer)
            local nuser_id = VICE.getUserId(nplayer)
            if nuser_id then
                VICEclient.isInComa(nplayer, {}, function(in_coma)
                    if in_coma then
                        if VICE.tryGetInventoryItem(user_id, "medkit", 1, true) then
                            VICEclient.playAnim(player, {false, revive_seq, false}) -- anim
                            SetTimeout(15000, function()
                                VICEclient.varyHealth(nplayer, {50}) -- heal 50
                            end)
                        end
                    else
                        VICE.notify(player, lang.emergency.menu.revive.not_in_coma())
                    end
                end)
            else
                VICE.notify(player, lang.common.no_player_near())
            end
        end)
    end
end, lang.emergency.menu.revive.description()}

RegisterNetEvent('VICE:SearchForPlayer')
AddEventHandler('VICE:SearchForPlayer', function()
    TriggerClientEvent('VICE:ReceiveSearch', -1, source)
end)


