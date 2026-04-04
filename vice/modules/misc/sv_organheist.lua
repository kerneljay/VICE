local playersInOrganHeist = {}
local timeTillOrgan = 0
local inWaitingStage = false
local inGamePhase = false
local policeInGame = 0
local civsInGame = 0
local cfg = module('cfg/cfg_organheist')


RegisterNetEvent("VICE:joinOrganHeist")
AddEventHandler("VICE:joinOrganHeist",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not playersInOrganHeist[user_id] then
        if inWaitingStage then
            if VICE.hasPermission(user_id, 'police.armoury') then
                playersInOrganHeist[source] = {type = 'police'}
                policeInGame = policeInGame+1
                TriggerClientEvent('VICE:addOrganHeistPlayer', -1, source, 'police')
                TriggerClientEvent('VICE:teleportToOrganHeist', source, cfg.locations[1].safePositions[math.random(2)], timeTillOrgan, 'police', 1)
                VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(user_id)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **Joined Police**")
            elseif VICE.hasPermission(user_id, 'nhs.menu') then
                VICE.notify(source, 'You cannot enter Organ Heist whilst clocked on NHS.')
            else
                playersInOrganHeist[source] = {type = 'civ'}
                civsInGame = civsInGame+1
                TriggerClientEvent('VICE:addOrganHeistPlayer', -1, source, 'civ')
                TriggerClientEvent('VICE:teleportToOrganHeist', source, cfg.locations[2].safePositions[math.random(2)], timeTillOrgan, 'civ', 2)
                VICEclient.giveWeapons(source, {{['WEAPON_ROOK'] = {ammo = 250}}, false, globalpasskey})
                VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(user_id)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Status: **Joined Civ**")
            end
            VICE.setBucket(source, 15)
            VICEclient.setArmour(source, {100, true})
        else
            VICE.notify(source, 'The organ heist has already started.')
        end
    end
end)

RegisterNetEvent("VICE:diedInOrganHeist")
AddEventHandler("VICE:diedInOrganHeist",function(killer)
    local source = source
    if playersInOrganHeist[source] then
        if VICE.getUserId(killer) then
            local killerID = VICE.getUserId(killer)
            VICE.giveBankMoney(killerID, 25000)
            TriggerClientEvent('VICE:organHeistKillConfirmed', killer, VICE.getPlayerName(VICE.getUserId(source)))
        end
        TriggerClientEvent('VICE:endOrganHeist', source)
        TriggerClientEvent('VICE:removeFromOrganHeist', -1, source)
        VICE.setBucket(source, 0)
        playersInOrganHeist[source] = nil
        VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(source)).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..VICE.getUserId(source).."**\n> Killer: **" ..VICE.getPlayerName(killerID).. "**\n> Status: **Died in organ**")
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    if playersInOrganHeist[source] then
        playersInOrganHeist[source] = nil
        TriggerClientEvent('VICE:removeFromOrganHeist', -1, source)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local time = os.date("*t")
        
        if timeTillOrgan > 0 then
            timeTillOrgan = timeTillOrgan - 1
        end

        if tonumber(time["hour"]) == 18 and tonumber(time["min"]) >= 50 and tonumber(time["sec"]) == 0 then
            TriggerClientEvent("VICE:ReadyForOrgan", -1)
            inWaitingStage = true
            timeTillOrgan = ((60-tonumber(time["min"]))*60)
            TriggerClientEvent('chatMessage', -1, "^7Organ Heist begins in "..math.floor((timeTillOrgan/60)).." minutes! Make your way to the Morgue with a weapon!", { 128, 128, 128 }, message, "alert")
        elseif tonumber(time["hour"]) == 19 and tonumber(time["min"]) == 30 and tonumber(time["sec"]) == 0 then
            if civsInGame > 0 and policeInGame > 0 then
                TriggerClientEvent('VICE:startOrganHeist', -1)
                inGamePhase = true
                inWaitingStage = false
                VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Status: **Organ heist has begun!**")
            else
                for k,v in pairs(playersInOrganHeist) do
                    TriggerClientEvent('VICE:endOrganHeist', k)
                    VICE.notify(k, 'Organ Heist was cancelled as not enough players joined.')
                    SetEntityCoords(GetPlayerPed(k), 240.31098937988, -1379.8699951172, 33.741794586182)
                    VICE.setBucket(k, 0)
                    VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..VICE.getUserId(k).."**\n> Status: **Cancelled not enough players joined**")
                end
            end
        end

        if inGamePhase then
            local policeAlive = 0
            local civAlive = 0
            for k,v in pairs(playersInOrganHeist) do
                if v.type == 'police' then
                    policeAlive = policeAlive + 1
                elseif v.type == 'civ' then
                    civAlive = civAlive + 1
                end
            end
            if policeAlive == 0 or civAlive == 0 then
                for k,v in pairs(playersInOrganHeist) do
                    if policeAlive == 0 then
                        TriggerClientEvent('VICE:endOrganHeistWinner', k, 'Civillians')
                    elseif civAlive == 0 then
                        TriggerClientEvent('VICE:endOrganHeistWinner', k, 'Police')
                    end
                    TriggerClientEvent('VICE:endOrganHeist', k)
                    VICE.setBucket(k, 0)
                    VICE.giveBankMoney(VICE.getUserId(k), 250000)
                    VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..VICE.getUserId(k).."**\n> Status: **Ended, Winners rewarded £250k**")
                end
                playersInOrganHeist = {}
                inWaitingStage = false
                inGamePhase = false
            end
        end
    end
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    if first_spawn and inWaitingStage then
        Citizen.Wait(5000)
        VICE.notify(source, '~g~Organ Heist is in its waiting stage, Use /tporgan.') -- 
    end
end)

RegisterNetEvent("VICE:checkOrganHeistStart")
AddEventHandler("VICE:checkOrganHeistStart", function()
    local source = source
    if civsInGame > 0 and policeInGame > 0 then
        TriggerClientEvent('VICE:startOrganHeist', -1)
        inGamePhase = true
        inWaitingStage = false
        VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Status: **Organ heist has begun!**")
    else
        for k,v in pairs(playersInOrganHeist) do
            TriggerClientEvent('VICE:endOrganHeist', k)
            VICE.notify(k, 'Organ Heist was cancelled as not enough players joined.')
            SetEntityCoords(GetPlayerPed(k), 240.31098937988, -1379.8699951172, 33.741794586182)
            VICE.setBucket(k, 0)
            VICE.sendDCLog('organ-tp', 'VICE Organ Logs', "> Player Name: **"..VICE.getPlayerName(VICE.getUserId(k)).."**\n> Player TempID: **"..k.."**\n> Player PermID: **"..VICE.getUserId(k).."**\n> Status: **Cancelled not enough players joined**")
        end
        playersInOrganHeist = {}
        inWaitingStage = false
        inGamePhase = false
        policeInGame = 0
        civsInGame = 0
    end
end)