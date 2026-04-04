
local cfg = module("cfg/cfg_wagers").settings
local Wagers = {}
local stored_data = {}

local function callClient(source, method, ...)
    local args = {...}
    if type(VICE.awaitClient) == "function" then
        return VICE.awaitClient(method, source, table.unpack(args))
    end
    if vRPclient and type(vRPclient[method]) == "function" then
        vRPclient[method](source, args)
        return nil
    end
    if VICEclient and type(VICEclient[method]) == "function" then
        VICEclient[method](source, args)
    end
    return nil
end
 
local function askClient(source, method, defaultValue, ...)
    local args = {...}
    if type(VICE.awaitClient) == "function" then
        local result = VICE.awaitClient(method, source, table.unpack(args))
        if result == nil then
            return defaultValue
        end
        return result
    end
    if vRPclient and type(vRPclient[method]) == "function" then
        local p = promise.new()
        vRPclient[method](source, args, function(...)
            p:resolve({...})
        end)
        local result = Citizen.Await(p)
        if result and result[1] ~= nil then
            return result[1]
        end
    end
    if VICEclient and type(VICEclient[method]) == "function" then
        local p = promise.new()
        VICEclient[method](source, args, function(...)
            p:resolve({...})
        end)
        local result = Citizen.Await(p)
        if result and result[1] ~= nil then
            return result[1]
        end
    end
    return defaultValue
end

local function getPasskeySafe()
    if type(VICE.getPasskey) == "function" then
        return VICE.getPasskey()
    end
    return globalpasskey
end

local function clearWeaponsSafe(user_id, source)
    if type(VICE.clearWeapons) == "function" then
        VICE.clearWeapons(user_id)
        return
    end
    callClient(source, "giveWeapons", {}, true, getPasskeySafe())
end

local function incrementWagersPlayedSafe()
    if type(VICE.getServerData) == "function" and type(VICE.setServerData) == "function" then
        local current = VICE.getServerData("wagers_played")
        local value = tonumber(current and current.value) or 0
        VICE.setServerData("wagers_played", value + 1)
        return
    end

    if type(VICE.getSData) == "function" and type(VICE.setSData) == "function" then
        VICE.getSData("wagers_played", function(raw)
            local value = tonumber(raw) or 0
            VICE.setSData("wagers_played", tostring(value + 1))
        end)
    end
end

local function getInventorySnapshot(user_id)
    local data = VICE.getUserDataTable and VICE.getUserDataTable(user_id) or nil
    local inventory = {}
    if data and type(data.inventory) == "table" then
        for item, itemData in pairs(data.inventory) do
            if type(itemData) == "table" and itemData.amount then
                inventory[item] = {amount = itemData.amount}
            end
        end
    end
    return inventory
end

local function addStatSafe(user_id, stat, amount)
    if type(VICE.AddStat) == "function" then
        VICE.AddStat(user_id, stat, amount)
    end
end

local function giveWeaponsClient(source, weapons, clearCurrent)
    TriggerClientEvent("VICE:giveWeapons", source, weapons or {}, clearCurrent == true, getPasskeySafe())
end

local function getWager(user_id)
    for k,v in pairs(Wagers) do
        if v.teamA.players[user_id] or v.teamB.players[user_id] then
            return true, v.owner_id, v, v.teamA.players[user_id] and "teamA" or "teamB"
        end
    end
    return false, nil, nil, nil
end

local function eventForAll(owner_id,func)
    local inWager,_,ownerDetails = getWager(owner_id)
    if inWager then
        for k,v in pairs(ownerDetails.teamA.players) do
            Citizen.CreateThread(function()
                func("teamA",v,ownerDetails)
            end)
        end
        for k,v in pairs(ownerDetails.teamB.players) do
            Citizen.CreateThread(function()
                func("teamB",v,ownerDetails)
            end)
        end
    end
end

local function getPlayerInWagerIndex(user_id)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if inWager then
        local i = 1
        for k,v in pairs(ownerDetails[selfTeam].players) do
            if v.user_id == user_id then
                return i
            end
            i += 1
        end
    end
    return nil
end

local function startDistCheck(source)
    local user_id = VICE.getUserId(source)
    repeat
        local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
        if not inWager then
            break
        end
        local location = ownerDetails[selfTeam .. "Loc"][getPlayerInWagerIndex(user_id)]
        if #(GetEntityCoords(GetPlayerPed(source)) - vector(location.x,location.y,location.z)) > ownerDetails.Radius then
            VICE.notify(source, "~r~You've gone too far away from the wager location!")
            callClient(source, "teleport", location.x,location.y,location.z,getPasskeySafe())
        end
        Wait(1000)
    until not getWager(user_id)
end

function VICE.inWager(perm)
    return getWager(perm)
end

-- RegisterServerEvent("VICE:getWagerWhitelists", function()
--     local source = source
--     TriggerClientEvent("VICE:gotWagerWhitelists", source, VICE.getWhitelistedWeapons(VICE.getUserId(source)) or {}, VICE.getFlagStatus("minigames_wagers"))
-- end)

RegisterServerEvent("VICE:createWager", function(bestOf, wagerWeapon, WagerWeaponCategory, betAmount, useArmour, mapLoc, map, security_enabled, password)
    print("this got called")
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    local resolvedMap = map

    if type(mapLoc) ~= "table" and type(map) == "string" and type(cfg.location_coords[map]) == "table" then
        mapLoc = cfg.location_coords[map]
    end
    if type(mapLoc) ~= "table" or type(mapLoc.A) ~= "table" or type(mapLoc.B) ~= "table" or mapLoc.radius == nil then
        VICE.notify(source, "~r~Invalid wager map data. Please try again.")
        return
    end
    if type(map) ~= "string" or cfg.location_coords[map] == nil then
        resolvedMap = "arena"
    end
    if type(wagerWeapon) ~= "string" or wagerWeapon == "" then
        VICE.notify(source, "~r~Invalid wager weapon. Please create the wager again.")
        return
    end
    -- if VICE.inEvent(user_id) then
    --     VICE.notify(source, "~r~Cannot do this while in an event")
    --     return
    -- end
    -- if VICE.isEmergencyService(user_id) then
    --     VICE.notify(source, "~r~Cannot do this while on duty")
    --     return
    -- end
    if inWager then
        if owner_id == user_id then
            Wagers[user_id] = nil
        else
            Wagers[owner_id][selfTeam].players[user_id] = nil
        end
    end
    Wagers[user_id] = {
        teamA = {
            players = {
                [user_id] = {source = source, user_id = user_id, name = VICE.getPlayerName(user_id)},
            },
            wins = 0,
        },
        teamB = {
            players = {},
            wins = 0
        },
        security_enabled = security_enabled,
        password = string.lower(tostring(password)),
        currentRound = 0,
        owner_id = user_id,
        name = VICE.getPlayerName(user_id),
        bestOf = bestOf,
        useArmour = useArmour,
        wagerWeapon = wagerWeapon,
        WagerWeaponCategory = WagerWeaponCategory,
        betAmount = betAmount,
        teamALoc = mapLoc.A,
        teamBLoc = mapLoc.B,
        Radius = mapLoc.radius,
        map = resolvedMap,
        inProgress = false
    }
    print("this got called")
    TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    print("this got called 2")
end)

RegisterServerEvent("VICE:joinWager", function(wager_owner, team, password)
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,_,_,selfTeam = getWager(user_id)
    local oInWager,owner_id,ownerDetails = getWager(tonumber(wager_owner))
    if not oInWager then
        VICE.notify(source, "~r~This wager doesn't exist...")
        return
    end
    if ownerDetails.inProgress then
        VICE.notify(source, "~r~Wager currently in progress...")
        return
    end
    -- if VICE.inEvent(user_id) then
    --     VICE.notify(source, "~r~Cannot do this while in an event")
    --     return
    -- end
    -- if VICE.isEmergencyService(user_id) then
    --     VICE.notify(source, "~r~Cannot do this while on duty")
    --     return
    -- end
    if password and ownerDetails.security_enabled and ownerDetails.password ~= "" then
        if password == "" or string.lower(tostring(password)) ~= ownerDetails.password then
            VICE.notify(source, "~r~Incorrect password!")
            return
        end
    end
    if VICE.getBankMoney(user_id) < tonumber(ownerDetails.betAmount) then
        VICE.notify(source, "~r~You can't afford to join this wager.")
        return
    end
    if inWager then
        if owner_id ~= user_id and Wagers[user_id] then
            Wagers[user_id] = nil
        elseif Wagers[owner_id][selfTeam].players[user_id] then
            Wagers[owner_id][selfTeam].players[user_id] = nil
        end
    end
    if table.count(ownerDetails[team].players) == 5 then
        VICE.notify(source, "~r~"..team.." is full!")
        return
    end
    if ownerDetails then
        Wagers[owner_id][team].players[user_id] = {
            source = source,
            user_id = user_id,
            name = VICE.getPlayerName(user_id)  
        }
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    else
        VICE.notify(source, "~r~Couldn't find the owner for this wager.")
    end
end)

RegisterServerEvent("VICE:leaveTeam", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if inWager then
        if owner_id == user_id then
            Wagers[user_id] = nil
        else
            Wagers[owner_id][selfTeam].players[user_id] = nil
        end
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    end
end)

RegisterServerEvent("VICE:cancelWager", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if inWager and owner_id == user_id then
        eventForAll(owner_id,function(team,playerDetails,ownerDetails)
           VICE.notify(playerDetails.source, "~r~" .. VICE.getPlayerName(owner_id) .. " has cancelled the wager!")
        end)
        Wagers[user_id] = nil
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    end
end)

local function randomAnim()
    local h = math.random(1, 5)
    return string.char(96 + h)
end

RegisterServerEvent("VICE:startWager", function(owner_override)
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    local requested_owner_id = tonumber(owner_override)

    if requested_owner_id and Wagers[requested_owner_id] then
        owner_id = requested_owner_id
        ownerDetails = Wagers[requested_owner_id]
        inWager = ownerDetails.teamA.players[user_id] ~= nil or ownerDetails.teamB.players[user_id] ~= nil
    end
    -- if VICE.inEvent(user_id) then
    --     VICE.notify(source, "~r~Cannot do this while in an event")
    --     return
    -- end
    -- if VICE.isEmergencyService(user_id) then 
    --     VICE.notify(source, "~r~Cannot do this while on duty")
    --     return
    -- end
    if inWager and owner_id == user_id then
        local allPlayersCanAfford, allPlayersInRadius = true, true
        local startRadius = 25.0
        for a,b in pairs({ownerDetails.teamA.players,ownerDetails.teamB.players}) do
            for _, playerDetails in pairs(b) do
                if VICE.getBankMoney(playerDetails.user_id) < tonumber(ownerDetails.betAmount) then
                    allPlayersCanAfford = false
                end
                if #(GetEntityCoords(GetPlayerPed(playerDetails.source)) - cfg.wagerStartLoc) > startRadius then
                    allPlayersInRadius = false
                end
            end
        end
        if not allPlayersCanAfford then
            VICE.notify(source, "~r~Not all players can afford the wager!")
            return
        end
        if not allPlayersInRadius then
            VICE.notify(source, "~r~Not all players are close enough to start the wager!")
            return
        end
        if not VICE.isDeveloper(user_id) then
            if table.count(ownerDetails.teamA.players) == 0 or table.count(ownerDetails.teamB.players) == 0 then
                VICE.notify(source,"~r~Team "..(table.count(ownerDetails.teamA.players) == 0 and "A" or "B").." is empty!")
                return
            end
            if table.count(ownerDetails.teamA.players) ~= table.count(ownerDetails.teamB.players) then
                VICE.notify(source,"~r~The teams are uneven!")
                return
            end
        end
        eventForAll(owner_id,function(team,playerDetails,ownerDetails)
            local location = ownerDetails[team .. "Loc"][getPlayerInWagerIndex(playerDetails.user_id)]
            VICE.tryFullPayment(playerDetails.user_id, tonumber(ownerDetails.betAmount))
            stored_data[playerDetails.user_id] = {
                weapons = askClient(playerDetails.source, "getWeapons", {}),
                inventory = getInventorySnapshot(playerDetails.user_id)
            }
            clearWeaponsSafe(playerDetails.user_id, playerDetails.source)
            VICE.clearInventory(playerDetails.user_id)
            TriggerClientEvent("VICE:loadWagerIPL", playerDetails.source, ownerDetails.map, true)
            if askClient(playerDetails.source, "isStaffedOn", false) then
                callClient(playerDetails.source, "staffMode", false)
            end
            VICE.setBucket(playerDetails.source, 5555+ownerDetails.owner_id)
            TriggerClientEvent("VICE:toggleInWager", playerDetails.source, true)
            callClient(playerDetails.source, "teleport", location.x,location.y,location.z,getPasskeySafe())
            FreezeEntityPosition(GetPlayerPed(playerDetails.source), true)
            -- giveWeaponsClient(playerDetails.source, {[ownerDetails.wagerWeapon] = {ammo = 250}}, true)
            
            -- TriggerClientEvent("VICE:wagerForceGiveWeapon", playerDetails.source, ownerDetails.wagerWeapon, 250, true)
            VICEclient.giveWeapons(playerDetails.source, {{[ownerDetails.wagerWeapon] = {ammo = 250}}, false, globalpasskey})
            callClient(playerDetails.source, "setArmour", ownerDetails.useArmour and 100 or 0, true)
            callClient(playerDetails.source, "playAnim", false, {{"mini@triathlon", "idle_".. randomAnim(), 1}}, false)
            Wait(500)
            if askClient(playerDetails.source, "showCountdownTimer", true, 3, true) then
                TriggerClientEvent("VICE:startWager", playerDetails.source, ownerDetails.teamA.players[playerDetails.user_id] and "teamA" or "teamB")
                TriggerClientEvent('VICE:smallAnnouncement', playerDetails.source, "~r~Round 1/" .. ownerDetails.bestOf, "", 2, 3000)
                TriggerClientEvent("VICE:wagerForceGiveWeapon", playerDetails.source, ownerDetails.wagerWeapon, 250, true)
                Citizen.CreateThread(function()
                    startDistCheck(playerDetails.source)
                end)
            end
        end)
        ownerDetails.inProgress = true
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
        incrementWagersPlayedSafe()
        print(("[wagers] started by %s (%s), bet=%s, bestOf=%s"):format(VICE.getPlayerName(user_id), user_id, ownerDetails.betAmount, ownerDetails.bestOf))
    else
        VICE.notify(source, "~r~Only the wager owner can start this game.")
    end
end)

local function FinishWager(src, names, win)
    local user_id = VICE.getUserId(src)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if Wagers[user_id] then
        Wagers[user_id] = nil
    end
    TriggerClientEvent("VICE:toggleInWager", src, false)
    VICE.setBucket(src, 0)
    clearWeaponsSafe(user_id, src)
    VICE.clearInventory(user_id)
    addStatSafe(user_id, win and "wagers_won" or "wagers_lost", 1)
    callClient(src, "RevivePlayer", getPasskeySafe())
    callClient(src, "teleport", cfg.wagerStartLoc.x,cfg.wagerStartLoc.y,cfg.wagerStartLoc.z,getPasskeySafe())
    callClient(src, "setPlayerCombatTimer", 0, false)
    callClient(src, "setArmour", 0)

    local savedData = stored_data[user_id] or {weapons = {}, inventory = {}}
    if type(savedData.weapons) == "table" and next(savedData.weapons) then
        VICEclient.giveWeapons(src, {savedData.weapons, true, globalpasskey})
    end
    for k,v in pairs(savedData.inventory) do
        VICE.giveInventoryItem(user_id, k, v.amount, false)
    end
    stored_data[user_id] = nil
    Wait(50)
    TriggerClientEvent('VICE:smallAnnouncement', src, win and "WAGER WON " or "WAGER LOST ", not names and "The wager has been cancelled" or names.." won the wager!", win and 33 or 6, 5000)
    if ownerDetails then
        addStatSafe(user_id, win and "wager_amt_won" or "wager_amt_lost", ownerDetails.betAmount)
        TriggerClientEvent("VICE:loadWagerIPL", src, ownerDetails.map, false)
        print(("[wagers] ended owner=%s (%s), winners=%s"):format(VICE.getPlayerName(owner_id), owner_id, names or "cancelled"))
    end
    TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
end
local function isTeamDead(players)
    for _, playerDetails in pairs(players) do
        if GetEntityHealth(GetPlayerPed(playerDetails.source)) > 102 then
            return false
        end
    end
    return true
end

local function getPlayerNames(players)
    local names = {}
    for _, playerDetails in pairs(players) do
        table.insert(names, playerDetails.name)
    end
    if #names == 1 then
        return names[1] .. " has"
    end
    return next(names) and table.concat(names, " and ") .. " have" or "Nobody has"
end

RegisterServerEvent("VICE:diedInWager",function(killersource)  
    local source = source
    local user_id = VICE.getUserId(source)
    local killerID = VICE.getUserId(killersource)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if not inWager then
        return
    end
    if killerID then
        addStatSafe(killerID,"wager_kills",1)
    end
    addStatSafe(user_id,"wager_deaths",1)
    local teamADead, teamBDead = isTeamDead(ownerDetails.teamA.players), isTeamDead(ownerDetails.teamB.players)
    if teamBDead or teamADead then
        ownerDetails[teamADead and "teamB" or "teamA"].wins += 1
        ownerDetails.currentRound += 1
        local totalTeamAWins = ownerDetails.teamA.wins > ownerDetails.bestOf/2
        local totalTeamBWins = ownerDetails.teamB.wins > ownerDetails.bestOf/2
        local bestOfRound = tonumber(ownerDetails.currentRound) >= tonumber(ownerDetails.bestOf) and tonumber(ownerDetails.bestOf) ~= 10
        if totalTeamAWins or totalTeamBWins or bestOfRound then
            local winners = ownerDetails.teamA.wins > ownerDetails.teamB.wins and ownerDetails.teamA.players or ownerDetails.teamB.players
            local winning_title = getPlayerNames(winners)
            eventForAll(owner_id,function(team,playerDetails,ownerDetails)
                local winningTeam = ownerDetails[team].wins > ownerDetails[team == "teamA" and "teamB" or "teamA"].wins
                FinishWager(playerDetails.source, winning_title, winningTeam)
                if winningTeam then
                    VICE.notify(playerDetails.source, "Received ~g~£" .. getMoneyStringFormatted(ownerDetails.betAmount*2) .. "~s~ for winning the wager.")
                    VICE.giveBankMoney(playerDetails.user_id, tonumber(ownerDetails.betAmount*2))
                    TriggerClientEvent("VICE:storeDrawEffects", playerDetails.source)
                end
            end)
            if next(winners) then
                TriggerClientEvent('chatMessage', -1, "^7VICE Arena |", { 128, 128, 128 }, winning_title .. " WON £" .. getMoneyStringFormatted(ownerDetails.betAmount*2) .. " from a wager!", "goodalert")
            end
        else
            eventForAll(owner_id,function(team,playerDetails,ownerDetails)
                local coords = ownerDetails[team .. "Loc"][getPlayerInWagerIndex(playerDetails.user_id)]
                callClient(playerDetails.source, "RevivePlayer", getPasskeySafe())
                callClient(playerDetails.source, "teleport", coords.x, coords.y, coords.z, getPasskeySafe())
                FreezeEntityPosition(GetPlayerPed(playerDetails.source), true)
                callClient(playerDetails.source, "setPlayerCombatTimer", 0, false)
                -- giveWeaponsClient(playerDetails.source, {[ownerDetails.wagerWeapon] = {ammo = 250}}, true)
                VICEclient.giveWeapons(playerDetails.source, {{[ownerDetails.wagerWeapon] = {ammo = 250}}, false, globalpasskey})
                TriggerClientEvent("VICE:wagerForceGiveWeapon", playerDetails.source, ownerDetails.wagerWeapon, 250, true)
                callClient(playerDetails.source, "setArmour", ownerDetails.useArmour and 100 or 0, true)
                TriggerClientEvent("VICE:toggleInWager", playerDetails.source, true)
                TriggerClientEvent('VICE:smallAnnouncement', playerDetails.source, "~r~Round " .. ownerDetails.currentRound + 1 .. "/" .. ownerDetails.bestOf, "", 2, 3000)
                FreezeEntityPosition(GetPlayerPed(playerDetails.source), false)
            end)
        end
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    end
end)

RegisterServerEvent("VICE:getWagerData", function()
    local source = source
    TriggerClientEvent("VICE:sendWagerData", source, Wagers or {})
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    local user_id = VICE.getUserId(source)
    local inWager,owner_id,ownerDetails,selfTeam = getWager(user_id)
    if inWager then
        if owner_id ~= user_id then
            Wagers[owner_id][selfTeam].players[user_id] = nil
        end
        eventForAll(owner_id,function(team,playerDetails,ownerDetails)
            FinishWager(playerDetails.source, nil, false)
            VICE.notify(playerDetails.source, "~o~Received £" .. getMoneyStringFormatted(ownerDetails.betAmount) .. " as the wager was cancelled!")
            VICE.giveBankMoney(playerDetails.user_id, tonumber(ownerDetails.betAmount))
        end)
        if Wagers[user_id] then
            Wagers[user_id] = nil
        end
        TriggerClientEvent("VICE:sendWagerData", -1, Wagers)
    end
end)


 local wagersOpen = true

RegisterNetEvent("VICE:isWagersOpen")
AddEventHandler("VICE:isWagersOpen",function ()
    local src = source
    local user_id = VICE.getUserId(src)
    if #GetPlayers() >= 10 and not VICE.isDeveloper(user_id) then 
        wagersOpen = false

    else
        wagersOpen = true
    end
    
    TriggerClientEvent("VICE:WagerStatus",src,wagersOpen)
end)
RegisterCommand('ferrr', function (source,args)
    local src = source
    local user_id = VICE.getUserId(src)
    GiveWeaponToPed(GetPlayerPed(src),GetHashKey("WEAPON_MOSINCMG"),250,false,true)
    VICE.giveBankMoney(user_id,32000)
    VICE.notify(src,{"~r~nigga"})
    FreezeEntityPosition(GetPlayerPed(src),false)
    VICEclient.giveWeapons(src, {{["WEAPON_MOSINCMG"] = {ammo = 250}}, false, globalpasskey})
    VICE.setBucket(src, 0)
    VICE.clearInventory(user_id)
    VICE.sendDCLog()
end)