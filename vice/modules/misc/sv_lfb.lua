local isWaterMonitorOn = false
local aC = 3 
local fires = {}
local fireTables = {}
local supplyLines = {}
local hoses = {}
local monitors = {}
local tents = {}
local cushions = {}
local stabilisers = {}
local fans = {}
local throwBags = {}
local liftingEntities = {}
local particleLocations = {}
local vehicleDoors = {}
local props = {}
local Jacks = {}
local Chocks = {}

RegisterServerEvent("VICE:spawnThrowBag")
AddEventHandler("VICE:spawnThrowBag", function(t, aq, bT)
    local throwBag = {t = t, aq = aq, bT = bT}
    table.insert(throwBags, throwBag)
    TriggerClientEvent("VICE:spawnThrowBag", -1, t, aq, bT)
end)

RegisterServerEvent("VICE:lfbHandlingLifting")
AddEventHandler("VICE:lfbHandlingLifting", function(bm, by, bz)
    local liftingEntity = {bm = bm, by = by, bz = bz}
    table.insert(liftingEntities, liftingEntity)
    TriggerClientEvent("VICE:lfbHandlingLifting", -1, bm, by, bz)
end)

RegisterServerEvent("VICE:lfbLiftingFreeze")
AddEventHandler("VICE:lfbLiftingFreeze", function(bm)
    for i, entity in ipairs(liftingEntities) do
        if entity.bm == bm then
            entity.isFrozen = true
        end
    end
    TriggerClientEvent("VICE:lfbLiftingFreeze", -1, bm)
end)

RegisterServerEvent("VICE:updateJackTable")
AddEventHandler("VICE:updateJackTable", function(jackId, jackData, removeJack)
    if removeJack then
        Jacks[jackId] = nil
    else
        Jacks[jackId] = jackData
    end

    TriggerClientEvent("VICE:updateJackTable", -1, jackId, Jacks[jackId], removeJack)
end)

RegisterServerEvent("VICE:updateChockTable")
AddEventHandler("VICE:updateChockTable", function(chockId, chockData, removeChock)
    if removeChock then
        Chocks[chockId] = nil
    else
        Chocks[chockId] = chockData
    end

    TriggerClientEvent("VICE:updateChockTable", -1, chockId, Chocks[chockId], removeChock)
end)

RegisterServerEvent("VICE:toggleChockWheels")
AddEventHandler("VICE:toggleChockWheels", function(vehicleId)
    TriggerClientEvent("VICE:toggleChockWheels", -1, vehicleId)
end)

RegisterServerEvent("VICE:createLFBPropLog")
AddEventHandler("VICE:createLFBPropLog", function(propName, propCoords)
    print("Prop " .. propName .. " created at " .. tostring(propCoords))
end)

RegisterServerEvent("VICE:deleteProp")
AddEventHandler("VICE:deleteProp", function(propId)
    if props[propId] then
        props[propId] = nil
        print("Prop " .. propId .. " deleted.")
    end
end)

RegisterServerEvent("VICE:updateStabilisersTable")
AddEventHandler("VICE:updateStabilisersTable", function(stabiliserId, stabiliserData, removeStabiliser)
    if removeStabiliser then
        stabilisers[stabiliserId] = nil
    else
        stabilisers[stabiliserId] = stabiliserData
    end

    TriggerClientEvent("VICE:updateStabilisersTable", -1, stabiliserId, stabilisers[stabiliserId], removeStabiliser)
end)

RegisterServerEvent("VICE:removeVehicleStablisers")
AddEventHandler("VICE:removeVehicleStablisers", function(vehicleId)
    for stabiliserId, stabiliserData in pairs(stabilisers) do
        if stabiliserData.vehicleId == vehicleId then
            stabilisers[stabiliserId] = nil
        end
    end
end)

RegisterServerEvent("VICE:updateFansTable")
AddEventHandler("VICE:updateFansTable", function(fanId, fanData, removeFan)
    if removeFan then
        fans[fanId] = nil
    else
        fans[fanId] = fanData
    end

    TriggerClientEvent("VICE:updateFansTable", -1, fanId, fans[fanId], removeFan)
end)

RegisterServerEvent("VICE:stopRtcParticles")
AddEventHandler("VICE:stopRtcParticles", function(playerCoords)
    table.insert(particleLocations, playerCoords)
    TriggerClientEvent("VICE:stopRtcParticles", -1, playerCoords)
end)

RegisterServerEvent("VICE:rtcOpenDoor")
AddEventHandler("VICE:rtcOpenDoor", function(vehicleId, doorIndex, playerCoords, breakDoor)
    local vehicleDoor = {vehicleId = vehicleId, doorIndex = doorIndex, playerCoords = playerCoords, breakDoor = breakDoor}
    table.insert(vehicleDoors, vehicleDoor)
    TriggerClientEvent("VICE:rtcOpenDoor", -1, vehicleId, doorIndex, playerCoords, breakDoor)
end)

RegisterServerEvent("VICE:updateCushionsTable")
AddEventHandler("VICE:updateCushionsTable", function(cushionId, cushionData, removeCushion)
    if removeCushion then
        cushions[cushionId] = nil
    else
        cushions[cushionId] = cushionData
    end

    TriggerClientEvent("VICE:updateCushionsTable", -1, cushionId, cushions[cushionId], removeCushion)
end)

RegisterServerEvent("VICE:updateFansTable")
AddEventHandler("VICE:updateFansTable", function(fanId, fanData, removeFan)
    if removeFan then
        fans[fanId] = nil
    else
        fans[fanId] = fanData
    end

    TriggerClientEvent("VICE:updateFansTable", -1, fanId, fans[fanId], removeFan)
end)

RegisterServerEvent("VICE:updateTentsTable")
AddEventHandler("VICE:updateTentsTable", function(tentId, tentData, removeTent)
    if removeTent then
        tents[tentId] = nil
    else
        tents[tentId] = tentData
    end

    TriggerClientEvent("VICE:updateTentsTable", -1, tentId, tents[tentId], removeTent)
end)

RegisterServerEvent("VICE:toggleWaterTents")
AddEventHandler("VICE:toggleWaterTents", function(tentId)
    if tents[tentId] then
        tents[tentId][8] = not tents[tentId][8]
    end

    TriggerClientEvent("VICE:toggleWaterTents", -1, tentId, tents[tentId][8])
end)

RegisterServerEvent("VICE:adjustPitchServer")
AddEventHandler("VICE:adjustPitchServer", function(monitorId, pitchChange)
    if monitors[monitorId] then
        monitors[monitorId].pitch = monitors[monitorId].pitch + pitchChange
    end

    TriggerClientEvent("VICE:adjustPitchClient", -1, monitorId, monitors[monitorId].pitch)
end)

RegisterServerEvent("VICE:toggleWaterServer")
AddEventHandler("VICE:toggleWaterServer", function(monitorId)
    if monitors[monitorId] then
        monitors[monitorId].waterOn = not monitors[monitorId].waterOn
    end

    TriggerClientEvent("VICE:toggleWaterClient", -1, monitorId, monitors[monitorId].waterOn)
end)

RegisterServerEvent("VICE:updateMonitorsTable")
AddEventHandler("VICE:updateMonitorsTable", function(monitorId, monitorData, removeMonitor)
    if removeMonitor then
        monitors[monitorId] = nil
    else
        monitors[monitorId] = monitorData
    end

    TriggerClientEvent("VICE:updateMonitorsTable", -1, monitorId, monitors[monitorId], removeMonitor)
end)

RegisterServerEvent("VICE:hoseUpdateServer")
AddEventHandler("VICE:hoseUpdateServer", function(hoseId, hoseData, removeHose)
    if removeHose then
        hoses[hoseId] = nil
    else
        hoses[hoseId] = hoseData
    end

    TriggerClientEvent("VICE:hoseUpdate", -1, hoseId, hoses[hoseId], removeHose)
end)

RegisterServerEvent("VICE:updateSupplyLineTable")
AddEventHandler("VICE:updateSupplyLineTable", function(supplyLineId, supplyLineData, removeSupplyLine)
    if removeSupplyLine then
        supplyLines[supplyLineId] = nil
    else
        supplyLines[supplyLineId] = supplyLineData
    end

    TriggerClientEvent("VICE:updateSupplyLines", -1, supplyLineId, supplyLines[supplyLineId], removeSupplyLine)
end)

RegisterServerEvent("VICE:lfbDeleteSupplyLine")
AddEventHandler("VICE:lfbDeleteSupplyLine", function(supplyLineId)
    if supplyLines[supplyLineId] then
        supplyLines[supplyLineId] = nil
        TriggerClientEvent("VICE:supplyLineRemoved", -1, supplyLineId)
    end
end)

local v, w, x, y, z, A, B, C, D = {}, {}, {}, {}, {}, {}, {}, {}, {} 

RegisterServerEvent("VICE:sendLFBTables")
AddEventHandler("VICE:sendLFBTables", function()
    v = nil
    w = nil
    x = nil
    y = nil
    z = nil
    A = nil
    B = nil
    C = nil
    D = nil

    TriggerClientEvent("VICE:receiveLFBTables", source, v, w, x, y, z, A, B, C, D)
end)

local v = v or {}

RegisterServerEvent("VICE:updateFireTableServer")
AddEventHandler("VICE:updateFireTableServer", function(R, S, T, U)
    if T then
        if v[R] and v[R].active then
            v[R] = nil
        end
    elseif U then
        if v[R] and S.size then
            v[R].size = S.size
        end
    else
        v[R] = S
    end
    TriggerClientEvent("VICE:updateFireTable", source, R, S, T, U)
end)

RegisterServerEvent("VICE:updateFireTable")
AddEventHandler("VICE:updateFireTable", function(fireId, fireData, removeFire, updateFire)
    if removeFire then
        fires[fireId] = nil
    elseif updateFire then
        if fires[fireId] then
            fires[fireId].size = fireData.size
        end
    else
        fires[fireId] = fireData
    end

    TriggerClientEvent("VICE:updateFires", -1, fireId, fires[fireId], removeFire, updateFire)
end)

RegisterServerEvent("VICE:updateFireOptions")
AddEventHandler("VICE:updateFireOptions", function(autoFires, fireSize, fireCooldown)
    print("Received fire options: autoFires=" .. tostring(autoFires) .. ", fireSize=" .. tostring(fireSize) .. ", fireCooldown=" .. tostring(fireCooldown))
    TriggerClientEvent("VICE:updateFireTable", -1, autoFires, fireSize, fireCooldown, true)
end)

RegisterServerEvent("VICE:stopAllFires")
AddEventHandler("VICE:stopAllFires", function()
    fires = {}
    TriggerClientEvent("VICE:allFiresStopped", -1)
end)

function supplyLineNearby(playerCoords)
    local supplyLineCoords = {x = 1206.6981201172, y = -1448.4521484375, z = 34.670917510986} -- Testing on the water supply on the yellow thing outside the LFB station
    local distance = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(supplyLineCoords.x, supplyLineCoords.y, supplyLineCoords.z))
    local maxDistance = 30.0 

    if distance <= maxDistance then
        return true
    else
        return false
    end
end