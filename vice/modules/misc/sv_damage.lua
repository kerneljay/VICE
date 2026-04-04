local headshots = {}

function VICE.GetLatestHeadShot(user_id)
    if headshots[user_id] then
        return headshots[user_id].lastHit
    end
    return nil
end

-- Function to send headshot data for a player
function sendHeadshotData(user_id)
    if headshots[user_id] then
        local totalShots = headshots[user_id].headshots + headshots[user_id].bodyshots
        local headshotPercentage = math.floor((headshots[user_id].headshots / totalShots) * 100)
        VICE.sendDCLog('headshot', "VICE HS % Logs", "> Players Perm ID: **"..user_id.."**\n> Total Shots Hit: **"..totalShots.."**\n> Total Headshots: **"..headshots[user_id].headshots.."**\n> Total Headshot Percentage: **"..headshotPercentage.."%**\n> Please keep in mind that these are logs. Please investigate further into high headshot percentages.")
    end
end

-- Periodic check for high headshot percentages
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- Check every 5 minutes
        for user_id, data in pairs(headshots) do
            local totalShots = data.headshots + data.bodyshots
            if totalShots > 0 then
                local headshotPercentage = math.floor((data.headshots / totalShots) * 100)
                if headshotPercentage > 80 then -- Alert if headshot percentage is above 80%
                    sendHeadshotData(user_id)
                end
            end
        end
    end
end)

RegisterNetEvent("VICE:syncEntityDamage")
AddEventHandler("VICE:syncEntityDamage", function(u, v, t, s, m, n) -- s head
    local source = source
    local user_id = VICE.getUserId(source)
    local user_id2 = VICE.getUserId(t)
    if user_id2 then
        if not headshots[user_id2] then
            headshots[user_id2] = {headshots = 0, bodyshots = 0, lastHit = nil}
        end
        if s then
            headshots[user_id2].headshots = headshots[user_id2].headshots + 1
            headshots[user_id2].lastHit = user_id
        else
            headshots[user_id2].bodyshots = headshots[user_id2].bodyshots + 1
            headshots[user_id2].lastHit = nil
        end
    end
    if user_id ~= user_id2 or not VICE.FetchDisputePlayers(user_id, user_id2) then
        VICE.AddDisputePlayer(user_id2, user_id, VICE.getPlayerName(user_id))
        VICE.AddDisputePlayer(user_id, user_id2, VICE.getPlayerName(user_id2))
    end
    TriggerClientEvent('VICE:onEntityHealthChange', t, GetPlayerPed(source), u, v, s)
end)

AddEventHandler("VICE:playerLeave", function(user_id, source)
    sendHeadshotData(user_id)
    headshots[user_id] = nil
end)

-- Command for staff to check headshot statistics
RegisterCommand("checkhs", function(source, args)
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        local target_id = tonumber(args[1])
        if target_id then
            sendHeadshotData(target_id)
            VICE.notify(source, "~g~Headshot data sent to Discord logs.")
        else
            VICE.notify(source, "~r~Please specify a player ID.")
        end
    end
end)

RegisterCommand("finishoffpill", function(source, args, rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    
    if user_id then
        TriggerClientEvent("VICE:eatPill", source)
    end
end, false)
