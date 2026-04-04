MySQL.createCommand("VICE/get_prison_time","SELECT prison_time FROM vice_prison WHERE user_id = @user_id")
MySQL.createCommand("VICE/set_prison_time","UPDATE vice_prison SET prison_time = @prison_time WHERE user_id = @user_id")
MySQL.createCommand("VICE/add_prisoner", "INSERT IGNORE INTO vice_prison SET user_id = @user_id")
MySQL.createCommand("VICE/get_current_prisoners", "SELECT * FROM vice_prison WHERE prison_time > 0")
MySQL.createCommand("VICE/add_jail_stat","UPDATE vice_police_hours SET total_player_jailed = (total_player_jailed+1) WHERE user_id = @user_id")

local cfg = module("cfg/cfg_prison")
local newDoors = {}
for k,v in pairs(cfg.doors) do
    for a,b in pairs(v) do
        newDoors[b.doorHash] = b
        newDoors[b.doorHash].currentState = b.defaultState or 1
    end
end  
local prisonItems = {"toothbrush", "blade", "rope", "metal_rod", "spring"}
local currentprisoners = {}
local lastCellUsed = 0

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_prison SET user_id = @user_id", {user_id = user_id})
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        MySQL.query("VICE/get_prison_time", {user_id = user_id}, function(prisontime)
            if prisontime then 
                if prisontime[1] and prisontime[1].prison_time and prisontime[1].prison_time > 0 then
                    if lastCellUsed == 27 then
                        lastCellUsed = 0
                    end
                    currentprisoners[user_id] = {prisonerName = VICE.getPlayerName(user_id),prisonerSource = source,prisonerCellNumber = lastCellUsed+1,prisonerTimeLeft = prisontime[1].prison_time}
                    TriggerClientEvent('VICE:putInPrisonOnSpawn', source, lastCellUsed+1)
                    TriggerClientEvent('VICE:forcePlayerInPrison', source, true)
                    TriggerClientEvent('VICE:prisonCreateBreakOutAreas', source)
                    TriggerClientEvent('VICE:prisonUpdateClientTimer', source, prisontime[1].prison_time)
                    local prisonItemsTable = {}
                    for k,v in pairs(cfg.prisonItems) do
                        local item = math.random(1, #prisonItems)
                        prisonItemsTable[prisonItems[item]] = v
                    end
                    TriggerClientEvent('VICE:prisonCreateItemAreas', source, prisonItemsTable)
                end
            end
        end)
        TriggerClientEvent('VICE:prisonUpdateGuardNumber', -1, #VICE.getUsersByPermission('hmp.menu'))
        TriggerClientEvent('VICE:prisonSyncAllDoors', source, newDoors)
    end
end)

RegisterNetEvent("VICE:getNumOfNHSOnline")
AddEventHandler("VICE:getNumOfNHSOnline", function()
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_prison_time", {user_id = user_id}, function(prisontime)
        if prisontime and prisontime[1] and prisontime[1].prison_time > 0 then
            TriggerClientEvent('VICE:prisonSpawnInMedicalBay', source)
            VICEclient.RevivePlayer(source, {})
        else
            TriggerClientEvent('VICE:getNumberOfDocsOnline', source, #VICE.getUsersByPermission('nhs.menu'))
        end
    end)
end)

RegisterServerEvent("VICE:prisonArrivedForJail")
AddEventHandler("VICE:prisonArrivedForJail", function()
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("VICE/get_prison_time", {user_id = user_id}, function(prisontime)
        if prisontime and #prisontime > 0 then
            if prisontime[1].prison_time > 0 then
                VICE.setBucket(source, 0)
                TriggerClientEvent('VICE:forcePlayerInPrison', source, true)
                TriggerClientEvent('VICE:prisonCreateBreakOutAreas', source)
                TriggerClientEvent('VICE:prisonUpdateClientTimer', source, prisontime[1].prison_time)
            end
        end
    end)
end)

RegisterServerEvent("VICE:requestTransport")
AddEventHandler("VICE:requestTransport", function(player, playerStreet)
    local puser_id = VICE.getUserId(player)
    local psource = player
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.sendDCLog('hmp-transport', 'VICE Transport Logs',
        "> Officer Name: **"..VICE.getPlayerName(user_id).."**\n"..
        "> Officer TempID: **"..source.."**\n"..
        "> Officer PermID: **"..user_id.."**\n"..
        "> Criminal Name: **"..VICE.getPlayerName(puser_id).."**\n"..
        "> Criminal PermID: **"..puser_id.."**\n"..
        "> Criminal TempID: **"..player.."**\n"..
        "> Location: **"..playerStreet.."**"
    )
end)

local prisonPlayerJobs = {}

RegisterServerEvent("VICE:prisonStartJob")
AddEventHandler("VICE:prisonStartJob", function(job)
    local source = source
    local user_id = VICE.getUserId(source)
    prisonPlayerJobs[user_id] = job
end)

RegisterServerEvent("VICE:prisonEndJob")
AddEventHandler("VICE:prisonEndJob", function(job)
    local source = source
    local user_id = VICE.getUserId(source)
    if prisonPlayerJobs[user_id] == job then
        prisonPlayerJobs[user_id] = nil
        MySQL.query("VICE/get_prison_time", {user_id = user_id}, function(prisontime)
            if prisontime then 
                if prisontime[1].prison_time > 21 then
                    MySQL.execute("VICE/set_prison_time", {user_id = user_id, prison_time = prisontime[1].prison_time - 20})
                    TriggerClientEvent('VICE:prisonUpdateClientTimer', source, prisontime[1].prison_time - 20)
                    currentprisoners[user_id].prisonerTimeLeft = prisontime[1].prison_time - 20
                    VICE.notify(source, "~g~Prison time reduced by 20s.")
                end
            end
        end)
    end
end)

RegisterServerEvent("VICE:jailPlayer")
AddEventHandler("VICE:jailPlayer", function(player)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        VICEclient.getNearestPlayers(source,{15},function(nplayers)
            if nplayers[player] then
                VICEclient.isHandcuffed(player,{}, function(handcuffed)  -- check handcuffed
                    if handcuffed then
                        -- check for gc in cfg 
                        MySQL.query("VICE/get_prison_time", {user_id = VICE.getUserId(player)}, function(prisontime)
                            if prisontime then 
                                if prisontime[1].prison_time == 0 then
                                    VICE.prompt(source,"Jail Time (in minutes):","",function(source,jailtime) 
                                        local jailtime = math.floor(tonumber(jailtime) * 60)
                                        if jailtime > 0 and jailtime <= cfg.maxTimeNotGc then
                                            -- check if gc then compare jailtime to 
                                            -- maxTimeGc = 7200,
                                            MySQL.execute("VICE/set_prison_time", {user_id = VICE.getUserId(player), prison_time = jailtime})
                                            if lastCellUsed == 27 then
                                                lastCellUsed = 0
                                            end
                                            currentprisoners[VICE.getUserId(player)] = {prisonerName = VICE.getPlayerName(VICE.getUserId(player)),prisonerSource = player,prisonerCellNumber = lastCellUsed+1,prisonerTimeLeft = jailtime}
                                            TriggerClientEvent('VICE:prisonTransportWithBus', player, lastCellUsed+1)
                                            VICE.setBucket(player, lastCellUsed+1)
                                            local prisonItemsTable = {}
                                            for k,v in pairs(cfg.prisonItems) do
                                                local item = math.random(1, #prisonItems)
                                                prisonItemsTable[prisonItems[item]] = v
                                            end
                                            TriggerClientEvent('VICE:prisonCreateItemAreas', player, prisonItemsTable)
                                            VICE.notify(source, "~g~Jailed Player.")
                                            VICE.AddStat(user_id,"arrests",1)
                                            VICE.AddStat(VICE.getUserId(player),"jailed_time",jailtime)
                                            VICE.sendDCLog('jail-player', 'VICE Jail Logs',"> Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Criminal Name: **"..VICE.getPlayerName(VICE.getUserId(player)).."**\n> Criminal PermID: **"..VICE.getUserId(player).."**\n> Criminal TempID: **"..player.."**\n> Duration: **"..math.floor(jailtime/60).." minutes**")
                                        else
                                            VICE.notify(source, "~r~Invalid time.")
                                        end
                                    end)
                                else
                                    VICE.notify(source, "~r~Player is already in prison.")
                                end
                            end
                        end)
                    else
                        VICE.notify(source, "~r~You must have the player handcuffed.")
                    end
                end)
            else
                VICE.notify(source, "~r~Player not found.")
            end
        end)
    end
end)


RegisterCommand("addtime",function(source,args)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id,"hmp.menu") then
        print("test")
        VICE.prompt(source,"Temp ID:","",function(source,playertemp)
            if tonumber(playertemp) then
                VICE.prompt(source,"Time:","",function(source,time)
                    local time = tonumber(time)
                    if time > 0 then
                        if time <= 15 then
                            local playerperm = VICE.getUserId(tonumber(playertemp))
                            MySQL.query("VICE/get_prison_time", {user_id = playerperm}, function(prisontime)
                                if prisontime then 
                                    if prisontime[1].prison_time > 0 then
                                        MySQL.execute("VICE/set_prison_time", {user_id = playerperm, prison_time = prisontime[1].prison_time + (time*60)})
                                        VICE.notify(source, "~g~Added "..time.." minutes to "..VICE.getPlayerName(playerperm).."'s jail time.")
                                        VICE.notify(playerperm, "~g~A prison guard has added "..time.." minutes to your jail time.")
                                        currentprisoners[playerperm].prisonerTimeLeft = prisontime[1].prison_time + (time*60)
                                    else
                                        VICE.notify(source, "~r~Player is not in jail.")
                                    end
                                end
                            end)
                        else
                            VICE.notify(source, "~r~Max time is 15 minutes.")
                        end
                    else
                        VICE.notify(source, "~r~Invalid time.")
                    end
                end)
            else
                VICE.notify(source, "~r~Invalid ID.")
            end
        end)
    end
end)

RegisterCommand("removetime",function(source,args)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id,"hmp.menu") then
        VICE.prompt(source,"Temp ID:","",function(source,playertemp)
            if tonumber(playertemp) then
                VICE.prompt(source,"Time:","",function(source,time)
                    local time = tonumber(time)
                    if time > 0 then
                        if time <= 15 then
                            local playerperm = VICE.getUserId(tonumber(playertemp))
                            MySQL.query("VICE/get_prison_time", {user_id = playerperm}, function(prisontime)
                                if prisontime then 
                                    if prisontime[1].prison_time > 0 then
                                        MySQL.execute("VICE/set_prison_time", {user_id = playerperm, prison_time = prisontime[1].prison_time - (time*60)})
                                        VICE.notify(source, "~g~Removed "..time.." minutes from "..VICE.getPlayerName(playerperm).."'s jail time.")
                                        VICE.notify(playerperm, "~g~A prison guard has removed "..time.." minutes from your jail time.")
                                        currentprisoners[playerperm].prisonerTimeLeft = prisontime[1].prison_time - (time*60)
                                    else
                                        VICE.notify(source, "~r~Player is not in jail.")
                                    end
                                end
                            end)
                        else
                            VICE.notify(source, "~r~Max time is 15 minutes.")
                        end
                    else
                        VICE.notify(source, "~r~Invalid time.")
                    end
                end)
            else
                VICE.notify(source, "~r~Invalid ID.")
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        MySQL.query("VICE/get_current_prisoners", {}, function(currentPrisoners)
            if currentPrisoners and #currentPrisoners > 0 then
                for k,v in pairs(currentPrisoners) do
                    if VICE.getUserSource(v.user_id) then
                        MySQL.execute("VICE/set_prison_time", {user_id = v.user_id, prison_time = v.prison_time-1})
                        currentprisoners[v.user_id].prisonerTimeLeft = v.prison_time-1
                        if v.prison_time-1 == 0 then
                            TriggerClientEvent('VICE:prisonStopClientTimer', VICE.getUserSource(v.user_id))
                            TriggerClientEvent('VICE:prisonReleased', VICE.getUserSource(v.user_id))
                            TriggerClientEvent('VICE:forcePlayerInPrison', VICE.getUserSource(v.user_id), false)
                            currentprisoners[v.user_id] = nil
                            VICEclient.setHandcuffed(VICE.getUserSource(v.user_id), {false})
                        end
                    end
                end
            end
        end)
        Citizen.Wait(1000)
    end
end)

RegisterCommand('unjail', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        VICE.prompt(source,"Enter Temp ID:","",function(source, player) 
            local player = tonumber(player)
            if player then
                MySQL.execute("VICE/set_prison_time", {user_id = VICE.getUserId(player), prison_time = 0})
                TriggerClientEvent('VICE:prisonStopClientTimer', player)
                TriggerClientEvent('VICE:prisonReleased', player)
                TriggerClientEvent('VICE:forcePlayerInPrison', player, false)
                currentprisoners[VICE.getUserId(player)] = nil
                VICEclient.setHandcuffed(player, {false})
                VICE.notify(source, "~g~Target will be released soon.")
            else
                VICE.notify(source, "Invalid ID.")
            end
        end)
    end
end)


AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent('VICE:prisonUpdateGuardNumber', -1, #VICE.getUsersByPermission('hmp.menu'))
    end
end)

local currentLockdown = false
RegisterServerEvent("VICE:prisonToggleLockdown")
AddEventHandler("VICE:prisonToggleLockdown", function(lockdownState)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'hmp.menu') then -- change this to the hmp hq permission
        currentLockdown = lockdownState
        if currentLockdown then
            TriggerClientEvent('VICE:prisonSetAllDoorStates', -1, 1)
        else
            TriggerClientEvent('VICE:prisonSetAllDoorStates', -1)
        end
    end
end)

RegisterServerEvent("VICE:prisonSetDoorState")
AddEventHandler("VICE:prisonSetDoorState", function(doorHash, state)
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:prisonSyncDoor', -1, doorHash, state)
end)

RegisterServerEvent("VICE:enterPrisonAreaSyncDoors")
AddEventHandler("VICE:enterPrisonAreaSyncDoors", function()
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:prisonAreaSyncDoors', source, doors)
end)


VICE.RegisterServerCallback("VICE:requestPrisonerData",function(source,cb)
    return currentprisoners
end)

-- on pickup 
-- VICE:prisonRemoveItemAreas(item)

-- hmp should be able to see all prisoners
-- VICE:requestPrisonerData