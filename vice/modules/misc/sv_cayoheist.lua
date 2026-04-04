local playersInHeist = {}
local lobbiesCreated = 0

RegisterServerEvent("VICE:CayoHeist:Active", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not playersInHeist[user_id] then
        playersInHeist[user_id] = true
        print("[VICE Cayo Heist] " .. VICE.getPlayerName(user_id) .. " has entered the Cayo Perico Heist.")
        TriggerClientEvent("VICE:CayoHeist:Active", source, true, #playersInHeist)
    else
        playersInHeist[user_id] = nil
        print("[VICE Cayo Heist] " .. VICE.getPlayerName(user_id) .. " has exited the Cayo Perico Heist.")
        TriggerClientEvent("VICE:CayoHeist:Active", source, false, #playersInHeist)
    end
end)

RegisterServerEvent("VICE:CayoHeist:LobbyCreated", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if playersInHeist[user_id] then
        lobbiesCreated = lobbiesCreated + 1
        TriggerClientEvent("VICE:CayoHeist:LobbyCreated", source, lobbiesCreated)
    else
        VICE.notify(source, "~r~You have not entered the Cayo Perico Heist.")
    end
end)