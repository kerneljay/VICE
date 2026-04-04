local cfg = module("cfg/cfg_pit")

local pitEventActive = false
local playersInPit = {}

local function CanPayPitGay()
    --if right time and enough players and event is active
    if os.date("%H") == cfg.timeStart and #GetPlayers() >= cfg.minPlayersOnToStart and pitEventActive then
        return true
    end
    return false
end

RegisterServerEvent("VICE:PitReceiveMoney",function(money)
    local source = source
    local user_id = VICE.getUserId(source)
    if not CanPayPitGay() then
        VICE.notify(source, "~r~Event has not started, Or there is not enough players.")
        return
    end
    VICE.giveMoney(user_id, money)
    VICE.notify(source, "~g~You have received £"..getMoneyStringFormatted(money).." from the pit!")
    TriggerClientEvent("VICE:PitReceiveMoney", source, money)
end)


RegisterServerEvent("VICE:PlayerEnteredPit",function()
    local source = source
    local user_id = VICE.getUserId(source)
    playersInPit[user_id] = true
    TriggerClientEvent("VICE:SetPitPlayers", -1, table.count(playersInPit))
    TriggerClientEvent("chatMessage", -1, "Pit Event", {255, 0, 0}, VICE.getPlayerName(VICE.getUserId(source)).." has entered the pit!", "alert")
end)

RegisterServerEvent("VICE:PlayerLeftPit",function(amountMade)
    local source = source
    local user_id = VICE.getUserId(source)
    playersInPit[user_id] = nil
    TriggerClientEvent("VICE:SetPitPlayers", -1, table.count(playersInPit))
    TriggerClientEvent("chatMessage", -1, "Pit Event", {255, 0, 0}, VICE.getPlayerName(VICE.getUserId(source)).." has left the pit! Amount made £"..getMoneyStringFormatted(amountMade), "alert")
end)

Citizen.CreateThread(function()
    while true do
        Wait(60000)
        --if the os.clock 
        if os.date("%H") == cfg.timeStart and not pitEventActive then
            pitEventActive = true
            TriggerClientEvent("VICE:SetPitEventActive", -1, pitEventActive)
            TriggerClientEvent("chatMessage", -1, "Pit Event", {255, 0, 0}, "Pit Event has started! head to the pit to get your money!", "alert")
        elseif os.date("%H") ~= cfg.timeStart and pitEventActive then
            pitEventActive = false
            TriggerClientEvent("VICE:SetPitEventActive", -1, pitEventActive)
            TriggerClientEvent("chatMessage", -1, "Pit Event", {255, 0, 0}, "Pit Event has ended! See you next time!", "alert")
        end
    end
end)


--Change below to ur on join event
AddEventHandler("VICE:playerJoin", function(user_id, source, name, last_login)
    TriggerClientEvent("VICE:SetPitEventActive", source, pitEventActive)
    if pitEventActive then
        TriggerClientEvent("VICE:SetPitPlayers", source, table.count(playersInPit))
        TriggerClientEvent("chatMessage", source, "Pit Event", {255, 0, 0}, "Pit Event is currently active! head to the pit to get your money!", "alert")
    end
end)

AddEventHandler("playerDropped",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if playersInPit[user_id] then
        playersInPit[user_id] = nil
        TriggerClientEvent("VICE:SetPitPlayers", -1, table.count(playersInPit))
    end
end)