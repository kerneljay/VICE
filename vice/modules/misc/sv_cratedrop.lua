local crateLocations = {
    vector3(2558.714, 6155.399, 161.8665), -- Rebel 
    vector3(-880.6389, 4414.064, 20.36799), -- Large arms
    vector3(-3032.489, 3402.802, 8.417397), -- mil base 
    vector3(-119.2925, 3022.1, 32.18053), -- diamond mine river
    vector3(36.50002, 4344.443, 41.47789), -- Large arms bridge 
    vector3(-1518.191, 2140.92, 55.53791), -- wine mansion
    vector3(-191.0104, 1477.419, 288.4325), -- Vinewood 1
    vector3(828.4253, 1300.878, 363.6823), -- Vinewood sign
    vector3(2348.622, 2138.061, 104.3607), -- wind turbines
    vector3(1877.604, 352.0831, 162.9319), -- Vinewood lake
    vector3(2836.016, -1447.626, 10.45845), -- island near lsd
    vector3(2543.626, 3615.884, 96.89672), -- Youtool hill
    vector3(2856.744, 4631.319, 48.39237), -- H Bunker
    vector3(4784.917, -5530.945, 19.46264), -- Cayo Perico
    vector3(254.3428, 3583.882, 33.73079), -- Biker city
    vector3(215.38623046875,6897.9873046875,14.624218940735), --zen pal 
}
local rigLocations = {
    vector3(-1716.5004882812,8886.94921875,27.144144058228), -- oil rig
}
local activeCrates = {}
local spawnTime = 30*60 -- Time between each airdrop (Its a 30min timer)
local PURGE_UNLOCK_DELAY = 10 * 60
local PURGE_COMMAND_UNLOCK_DELAY = 60 -- temporary test value, set to 10 * 60 when ready
local PURGE_OPEN_DURATION = 60
local PURGE_EVENT_DURATION = 30 * 60
local PURGE_SCHEDULE_HOUR = 21
local PURGE_SCHEDULE_MINUTE = 0
local purgeRedzoneLocations = {
    {name = "Rebel", pos = vector3(1468.5318603516, 6328.529296875, 18.894895553589)},
    {name = "Heroin", pos = vector3(3545.048828125, 3724.0776367188, 36.64262008667)},
    {name = "Large Arms", pos = vector3(-1118.4926757813, 4926.1889648438, 218.35691833496)},
    {name = "Large Arms Cayo", pos = vector3(5115.7465820312, -4623.2915039062, 2.642692565918)},
    {name = "LSD North", pos = vector3(1317.0300292969, 4309.8359375, 38.005485534668)},
    {name = "LSD South", pos = vector3(2539.0964355469, -376.51586914063, 92.986785888672)},
    {name = "Oil Rig", pos = vector3(-1716.5004882812, 8886.94921875, 28.144144058228)}
}

local availableItems = {
    {"wbody|WEAPON_MOSINCMG", 1},
    {"wbody|WEAPON_UZI", 2},
    {"7.62mm Bullets", 250},
    {"9mm Bullets", 250},
    {".308 Sniper Rounds", 250}

}

-- Easy edit loot pools.
local normalDropLootPool = {
    items = {
        {"wbody|AK74KASHNARCMG", 1},
        {"wbody|WEAPON_MOSINCMG", 1},
        {"wbody|WEAPON_UZI", 2},
        {"7.62mm Bullets", 250},
        {"9mm Bullets", 250},
        {".308 Sniper Rounds", 250}
    },
    money = 1000000
}

local purgeDropLootPool = {
    items = {
        {"wbody|AK74KASHNARCMG", 1},
        {"wbody|WEAPON_MOSINCMG", 1},
        {"wbody|WEAPON_UZI", 2},
        {"wbody|WEAPON_G36CMG", 1},
        {"7.62mm Bullets", 700},
        {"9mm Bullets", 700},
        {".308 Sniper Rounds", 700}
    },
    money = 2500000
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for k,v in pairs(activeCrates) do
            if activeCrates[k].timeTillOpen > 0 then
                activeCrates[k].timeTillOpen = activeCrates[k].timeTillOpen - 1
            end
        end
    end
end)


AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
       if next(activeCrates) then
            for k,v in pairs(activeCrates) do
                local location = v.coords or (v.oilrig and rigLocations[k] or crateLocations[k])
                if location then
                    TriggerClientEvent('VICE:addCrateDropRedzone', source, k, location, v.model, v.skipRadiusBlip)
                end
            end
       end
    end
end)

local crateLoot = {}

local function isPurgeCrate(crateID)
    return activeCrates[crateID] and activeCrates[crateID].crateType == "purge"
end

local function hasActivePurgeCrate()
    for crateID, data in pairs(activeCrates) do
        if data and data.crateType == "purge" then
            return true, crateID
        end
    end
    return false, nil
end

local function generatePurgeCrateId()
    local crateID = math.random(9001, 9999)
    while activeCrates[crateID] do
        crateID = math.random(9001, 9999)
    end
    return crateID
end

local function clearCrate(crateID)
    if isPurgeCrate(crateID) then
        TriggerClientEvent("VICE:stopPurgeLootSound", -1, crateID)
    end
    crateLoot[crateID] = nil
    activeCrates[crateID] = nil
    TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
    TriggerClientEvent("VICE:removeCrateDropRedzone", -1, crateID)
    TriggerClientEvent("VICE:removeCrateRedzone", -1)
end

local function givePurgeLoot(user_id)
    for _, item in pairs(purgeDropLootPool.items) do
        VICE.giveInventoryItem(user_id, item[1], item[2], true)
    end
    if purgeDropLootPool.money and purgeDropLootPool.money > 0 then
        VICE.giveMoney(user_id, purgeDropLootPool.money)
    end
end

local function giveNormalDropLoot(user_id)
    for _, item in pairs(normalDropLootPool.items) do
        VICE.giveInventoryItem(user_id, item[1], item[2], true)
    end
    if normalDropLootPool.money and normalDropLootPool.money > 0 then
        VICE.giveMoney(user_id, normalDropLootPool.money)
    end
end

local function startPurgeZoneDrop(unlockDelaySeconds)
    local alreadyActive = hasActivePurgeCrate()
    if alreadyActive then
        return false
    end

    local crateID = generatePurgeCrateId()
    local selectedRedzone = purgeRedzoneLocations[math.random(1, #purgeRedzoneLocations)]
    local crateCoords = selectedRedzone.pos
    local unlockTime = unlockDelaySeconds or PURGE_UNLOCK_DELAY

    activeCrates[crateID] = {
        oilrig = false,
        crateType = "purge",
        model = "prop_box_wood02a_pu",
        skipRadiusBlip = true,
        coords = crateCoords,
        redzoneName = selectedRedzone.name,
        timeTillOpen = unlockTime
    }
    crateLoot[crateID] = nil

    TriggerClientEvent('VICE:addCrateDropRedzone', -1, crateID, crateCoords, "prop_box_wood02a_pu", true)
    TriggerClientEvent("VICE:announcePurgeZoneStart", -1, selectedRedzone.name)

    if unlockTime <= 0 then
        TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1Purge Zone has started at ^3"..selectedRedzone.name.."^1. The crate is unlocked now.")
    else
        local unlockMinutes = math.floor(unlockTime / 60)
        local unlockSeconds = unlockTime % 60
        local unlockText = unlockMinutes > 0 and (unlockMinutes.." minute(s)") or (unlockSeconds.." second(s)")
        TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1Purge Zone has started at ^3"..selectedRedzone.name.."^1. The crate unlocks in "..unlockText..".")
    end

    Citizen.CreateThread(function()
        Wait(PURGE_EVENT_DURATION * 1000)
        if isPurgeCrate(crateID) then
            TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1The Purge crate has disappeared.")
            clearCrate(crateID)
        end
    end)

    return true
end

function ProcessCrateDrop(name)
    if not string.find(name, "CrateDrop") then return end
    local crateID = string.gsub(name, "CrateDrop", "")
    crateID = tonumber(crateID)
    TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The Crate drop has been looted!")
    TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
    activeCrates[crateID] = nil
end

RegisterServerEvent('VICE:openCrate', function(crateID)
    local source = source
    local user_id = VICE.getUserId(source)
    if not crateLocations[crateID] and not rigLocations[crateID] and not isPurgeCrate(crateID) then 
        return 
    end
    if activeCrates[crateID] and activeCrates[crateID].timeTillOpen > 0 then
        VICE.notify(source, '~r~Loot crate unlocking in '..activeCrates[crateID].timeTillOpen..' seconds.')
    else
        local nearStandardDrop = crateLocations[crateID] and #(GetEntityCoords(GetPlayerPed(source)) - crateLocations[crateID]) < 3.5
        local nearRigDrop = rigLocations[crateID] and #(GetEntityCoords(GetPlayerPed(source)) - rigLocations[crateID]) < 3.5
        local nearPurgeDrop = isPurgeCrate(crateID) and activeCrates[crateID].coords and #(GetEntityCoords(GetPlayerPed(source)) - activeCrates[crateID].coords) < 3.5
        if not VICEclient.InMainEvent(user_id) and (nearStandardDrop or nearRigDrop or nearPurgeDrop) then
            if not crateLoot[crateID] then
                if isPurgeCrate(crateID) then
                    if activeCrates[crateID].isOpening then
                        VICE.notify(source, "~r~Someone is already trying to loot this Purge crate.")
                        return
                    end

                    activeCrates[crateID].isOpening = true
                    activeCrates[crateID].openingBy = user_id
                    activeCrates[crateID].openToken = (activeCrates[crateID].openToken or 0) + 1
                    local openToken = activeCrates[crateID].openToken
                    local playerName = VICE.getPlayerName(user_id) or GetPlayerName(source) or ("ID "..user_id)
                    TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1"..playerName.." is trying to loot the Purge crate!")
                    TriggerClientEvent("VICE:startPurgeLootSound", -1, crateID)
                    VICE.notify(source, "~r~Hold this area for 60 seconds to loot the Purge crate.")
                    TriggerClientEvent("VICE:startPurgeCrateTimer", source, crateID, PURGE_OPEN_DURATION * 1000)

                    SetTimeout((PURGE_OPEN_DURATION + 5) * 1000, function()
                        if isPurgeCrate(crateID) and activeCrates[crateID].isOpening and activeCrates[crateID].openToken == openToken then
                            activeCrates[crateID].isOpening = false
                            activeCrates[crateID].openingBy = nil
                            TriggerClientEvent("VICE:stopPurgeLootSound", -1, crateID)
                            TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1The Purge crate looting attempt was interrupted.")
                        end
                    end)
                else
                    giveNormalDropLoot(user_id)
                    
                    crateLoot[crateID] = true
                    TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The Crate drop has been looted!")
                    clearCrate(crateID)
                end
            end
        end
    end
end)

RegisterServerEvent("VICE:finishPurgeCrateLoot", function(crateID)
    local source = source
    local user_id = VICE.getUserId(source)
    if not isPurgeCrate(crateID) then return end
    if not activeCrates[crateID].isOpening or activeCrates[crateID].openingBy ~= user_id then return end

    local crateCoords = activeCrates[crateID].coords
    if not crateCoords or #(GetEntityCoords(GetPlayerPed(source)) - crateCoords) > 5.0 or GetEntityHealth(GetPlayerPed(source)) <= 102 then
        activeCrates[crateID].isOpening = false
        activeCrates[crateID].openingBy = nil
        TriggerClientEvent("VICE:stopPurgeLootSound", -1, crateID)
        TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1The Purge crate looting attempt was interrupted.")
        return
    end

    givePurgeLoot(user_id)
    crateLoot[crateID] = true
    local looterName = VICE.getPlayerName(user_id) or GetPlayerName(source) or ("ID "..user_id)
    TriggerClientEvent('chatMessage', -1, "^2PURGE | ", {0, 255, 120}, "^2Congratulations! "..looterName.." has looted the Purge crate!")
    clearCrate(crateID)
end)

RegisterServerEvent("VICE:cancelPurgeCrateLoot", function(crateID)
    local source = source
    local user_id = VICE.getUserId(source)
    if not isPurgeCrate(crateID) then return end
    if not activeCrates[crateID].isOpening or activeCrates[crateID].openingBy ~= user_id then return end
    activeCrates[crateID].isOpening = false
    activeCrates[crateID].openingBy = nil
    TriggerClientEvent("VICE:stopPurgeLootSound", -1, crateID)
    TriggerClientEvent('chatMessage', -1, "^1PURGE | ", {255, 30, 30}, "^1The Purge crate looting attempt was interrupted.")
end)

Citizen.CreateThread(function()
    local lastAutoPurgeDate = nil
    while true do
        local now = os.date("*t")
        local dateKey = string.format("%04d-%02d-%02d", now.year, now.month, now.day)
        if now.hour == PURGE_SCHEDULE_HOUR and now.min == PURGE_SCHEDULE_MINUTE and lastAutoPurgeDate ~= dateKey then
            startPurgeZoneDrop(PURGE_UNLOCK_DELAY)
            lastAutoPurgeDate = dateKey
        end
        Wait(20000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(45 * 60 * 1000)
        local crateID = math.random(1, #crateLocations)
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, false)
        activeCrates[crateID] = { oilrig = false, timeTillOpen = 300 }
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "A cartel plane carrying supplies has had to bail and is parachuting to the ground! Get to it quick, check your GPS!")
        Wait(20 * 60 * 1000)
        if activeCrates[crateID] then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(6 * 60 * 60 * 1000)
        local crateID = math.random(1, #rigLocations)
        local crateCoords = rigLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, true)
        activeCrates[crateID] = { oilrig = true, timeTillOpen = 300 }
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "An Oil Rig off the coast of paleto is hiding a hidden cache of high tier weaponry and money. Get to it quick, check your GPS!")
        Wait(20 * 60 * 1000)
        if activeCrates[crateID] then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The Oil Rig has been looted!")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    end
end)

RegisterCommand('startrig', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=7 then
        local crateID = math.random(1, #rigLocations)
        local crateCoords = rigLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, true)
        activeCrates[crateID] = {oilrig = true, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "An Oil Rig off the coast of paleto is hiding a hidden cache of high tier weaponry and money. Get to it quick, check your GPS!","alert")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", { 66, 72, 245 }, "The Oil Rig has disappeared.")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        VICE.notify(source, {'You do not have permission to do this.'})
    end
end)

RegisterCommand('startdrop', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=7 then
        local crateID = math.random(1, #crateLocations)
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, false)
        activeCrates[crateID] = {oilrig = false, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "A cartel plane carrying supplies has had to bail and is parachuting to the ground! Get to it quick, check your GPS!","alert")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        VICE.notify(source, {'You do not have permission to do this.'})
    end
end)

-- Add city and paleto drop locations to crateLocations
local cityDropCoords = vector3(591.08483886719, -849.99114990234, 41.349731445312)
table.insert(crateLocations, cityDropCoords)
local cityDropIndex = #crateLocations

local paletoDropCoords = vector3(-491.25283813477, 5459.8627929688, 82.467864990234)
table.insert(crateLocations, paletoDropCoords)
local paletoDropIndex = #crateLocations

RegisterCommand('startdropcity', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >= 4 then
        local crateID = cityDropIndex
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, false)
        activeCrates[crateID] = {oilrig = false, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "A cartel plane carrying supplies has had to bail and is parachuting to the city! Get to it quick, check your GPS!")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        VICE.notify(source, {'You do not have permission to do this.'})
    end
end)

RegisterCommand('startdroppaleto', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >= 4 then
        local crateID = paletoDropIndex
        local crateCoords = crateLocations[crateID]
        TriggerClientEvent('VICE:crateDrop', -1, crateCoords, crateID, false)
        activeCrates[crateID] = {oilrig = false, timeTillOpen = 300}
        TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "A cartel plane carrying supplies has had to bail and is parachuting to Paleto! Get to it quick, check your GPS!")
        Wait(20*60*1000)
        if activeCrates[crateID] ~= nil then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "The airdrop has disappeared.", "alert")
            activeCrates[crateID] = nil
            TriggerClientEvent("VICE:removeLootcrate", -1, crateID)
        end
        Wait(1000)
    else
        VICE.notify(source, {'You do not have permission to do this.'})
    end
end)

RegisterCommand('enddrops', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >= 5 then
        local dropsEnded = 0
        for crateID, _ in pairs(activeCrates) do
            -- Remove the drop from the map
            TriggerClientEvent('VICE:removeLootcrate', -1, crateID)
            -- Remove the redzone
            TriggerClientEvent('VICE:removeCrateDropRedzone', -1, crateID)
            -- Remove any landing drops
            TriggerClientEvent('VICE:removeLandingDrop', -1, crateID)
            -- Remove the redzone blip
            TriggerClientEvent('VICE:removeCrateRedzone', -1)
            -- Clear from active crates
            activeCrates[crateID] = nil
            dropsEnded = dropsEnded + 1
        end
        if dropsEnded > 0 then
            TriggerClientEvent('chatMessage', -1, "^0EVENT | ", {66, 72, 245}, "All active drops have been ended by staff.")
        else
            VICE.notify(source, {'No active drops to end.'})
        end
    else
        VICE.notify(source, {'You do not have permission to do this.'})
    end
end)

RegisterCommand('startpurgezone', function(source)
    local src = source
    if src == 0 then
        if not startPurgeZoneDrop(PURGE_COMMAND_UNLOCK_DELAY) then
            print("^1[VICE] Purge Zone is already active.^0")
        end
        return
    end

    local user_id = VICE.getUserId(src)
    if VICE.GetStaffLevel(user_id) >= 7 then
        if not startPurgeZoneDrop(PURGE_COMMAND_UNLOCK_DELAY) then
            VICE.notify(src, {'Purge Zone is already active.'})
        end
    else
        VICE.notify(src, {'You do not have permission to do this.'})
    end
end)
