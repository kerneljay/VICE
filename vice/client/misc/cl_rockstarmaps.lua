eventMapHasLoaded = false
local loadedObjects = {}
local loadedPfx = {}
local loadedVehicles = {}
local loadedIPLs = {}
local blimpScaleform = nil
local stuntFireModels = {
    [-545580178] = {pfxDict="scr_stunts",pfxName="scr_stunts_fire_ring",offset=vector3(0.0,0.0,4.0),scale=0.2}, --stt_prop_hoop_small_01
    [-35121593] = {pfxDict="scr_stunts",pfxName="scr_stunts_fire_ring",offset=vector3(0.0,0.0,10.0),scale=0.4}, --ar_prop_ar_hoop_med_01
    [737590223] = {pfxDict="scr_stunts",pfxName="scr_stunts_fire_ring",offset=vector3(0.0,0.0,25.0),scale=1.0}, --stt_prop_hoop_constraction_01a
}

--?Update validIPLs table on both client & server _rockstarmaps.lua
local validIPLs = {
    ["vice_dust2"] = true,
    ["vice_lego"] = true,
    ["nuketown"] = true,
    ["shipment"] = true,
    ["map1"] = true, --Dragonball/Kame's House
    ["dragonball"] = true, --Dragonball/Kame's House
    ["NOT_IPL"] = true, --Temporary measure for loading the simpons map
}

local function checkModelPfx(model,x,y,z,rotX,rotY,rotZ)
    if stuntFireModels[model] then
        local stuntData = stuntFireModels[model]
        VICE.loadPtfx(stuntData.pfxDict)
        local particleHandle = StartParticleFxLoopedAtCoord(stuntData.pfxName,x+stuntData.offset.x,y+stuntData.offset.y,z+stuntData.offset.z,rotX,rotY,rotZ, stuntData.scale, false, false, false, false)
        SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,false)
        table.insert(loadedPfx,particleHandle)
    end
end

local speedUpObjects = {
    [-1006978322] = true,
    [-388593496] = true,
    [-66244843] = true,
    [-1170462683] = true,
    [993442923] = true,
    [737005456] = true,
    [-904856315] = true,
    [-279848256] = true,
    [588352126] = true,
}

local slowDownObjects = {
    [346059280] = true,
    [620582592] = true,
    [85342060] = true,
    [483832101] = true,
    [930976262] = true,
    [1677872320] = true,
    [708828172] = true,
    [950795200] = true,
    [-1260656854] = true,
    [-1875404158] = true,
    [-864804458] = true,
    [-1302470386] = true,
    [1518201148] = true,
    [384852939] = true,
    [117169896] = true,
    [-1479958115] = true,
    [-227275508] = true,
    [1431235846] = true,
    [1832852758] = true,
}

local function GetPropSpeedModificationParameters(model, prpsba)
    if prpsba == -1 then return false end

    local var1, var2 = -1, -1

    if speedUpObjects[model] then
        if prpsba == 1 then
            var1, var2 = 15, 0.3
        elseif prpsba == 2 then
            var1, var2 = 25, 0.3
        elseif prpsba == 3 then
            var1, var2 = 35, 0.5
        elseif prpsba == 4 then
            var1, var2 = 45, 0.5
        elseif prpsba == 5 then
            var1, var2 = 100, 0.5
        else
            var1, var2 = 25, 0.4
        end
    elseif slowDownObjects[model] then
        var2 = -1
        if prpsba == 1 then
            var1 = 44
        elseif prpsba == 2 then
            var1 = 30
        elseif prpsba == 3 then
            var1 = 16
        else
            var1 = 30
        end
    else
        return false
    end

    return true, var1, var2
end

local function checkModelSpeedBoost(objectId,model,speedBoostData)
    if speedBoostData then
        local speedAdjustment = speedBoostData
        local hasSpeedAdjust, speed, duration = GetPropSpeedModificationParameters(model, speedAdjustment)

        if hasSpeedAdjust then
            if speed and speed > -1 then
                SetObjectStuntPropSpeedup(objectId, speed)
            end

            if duration and duration > -1 then
                SetObjectStuntPropDuration(objectId, duration)
            end
        end
    end
end

function VICE.createBlimpText()
    if not IsNamedRendertargetRegistered("blimp_text") then
        RegisterNamedRendertarget("blimp_text", false)
    end

    if not IsNamedRendertargetLinked(`sr_mp_spec_races_blimp_sign`) then
        LinkNamedRendertarget(`sr_mp_spec_races_blimp_sign`)
    end

    local scaleform = RequestScaleformMovie("BLIMP_TEXT")
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(scaleform, "SET_MESSAGE")
    ScaleformMovieMethodAddParamTextureNameString_2("VICE MINIGAMES")
    BeginTextCommandScaleformString("SR_BLIMPTX")
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_COLOUR")
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_SCROLL_SPEED")
    ScaleformMovieMethodAddParamFloat(100.0)
    EndScaleformMovieMethod()

    N_0x32f34ff7f617643b(scaleform, 1)
    blimpScaleform = scaleform
end

-- RegisterCommand("cleanmaps", function()
--     VICE.cleanupRockstarMaps()
-- end)

function loadMap(map, fadeFlag, disableVehiclesFlag, bTeleport)
    eventMapHasLoaded = false
    if fadeFlag then
        DoScreenFadeOut(250)
    end
    VICE.setPlayerInvisible(true)

    if validIPLs[map] then
        if map ~= "NOT_IPL" then
            print("loading ipl")
            RequestIpl(map)
            while not IsIplActive(map) do print("loading ipl") Wait(0) end
            table.insert(loadedIPLs,map)
        end
    else
        for i=1, #map.models do
            VICE.loadModel(map.models[i])
            local obj = CreateObjectNoOffset(map.models[i], map.modelPos[i].x,map.modelPos[i].y,map.modelPos[i].z, false, false, false)
            if bTeleport then
                SetEntityCoords(PlayerPedId(), map.modelPos[i].x,map.modelPos[i].y,map.modelPos[i].z, false, false, false ,false)
            end
            if map.prpclr then
                SetObjectTextureVariant(obj, map.prpclr[i])
            end
            FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, map.modelHeading[i])
            SetEntityRotation(obj, map.modelRotation[i].x,map.modelRotation[i].y,map.modelRotation[i].z, 2, true)
            checkModelPfx(map.models[i],map.modelPos[i].x,map.modelPos[i].y,map.modelPos[i].z,map.modelRotation[i].x,map.modelRotation[i].y,map.modelRotation[i].z)
            if map.speedBoosts then
                checkModelSpeedBoost(obj,map.models[i],map.speedBoosts[i])
            end
            table.insert(loadedObjects,obj)
        end
        for i=1, #map.models2 do
            VICE.loadModel(map.models2[i])
            local obj = CreateObjectNoOffset(map.models2[i], map.modelPos2[i].x,map.modelPos2[i].y,map.modelPos2[i].z, false, false, map.modelDynamic2[i])
            if map.prpclr2 then
                SetObjectTextureVariant(obj, map.prpclr2[i])
            end
            --FreezeEntityPosition(obj, true)
            SetEntityHeading(obj, map.modelHeading2[i])
            SetEntityRotation(obj, map.modelRotation2[i].x,map.modelRotation2[i].y,map.modelRotation2[i].z, 2, true)
            checkModelPfx(map.models2[i],map.modelPos2[i].x,map.modelPos2[i].y,map.modelPos2[i].z,map.modelRotation2[i].x,map.modelRotation2[i].y,map.modelRotation2[i].z)
            table.insert(loadedObjects,obj)
        end
        if not disableVehiclesFlag then
            for i=1, #map.vehicles.models do
                local model = map.vehicles.models[i]
                local coords = map.vehicles.locations[i]
                local heading = map.vehicles.heading[i]
                VICE.loadModel(model)
                local vehicleId = VICE.spawnVehicle(model, coords.x, coords.y, coords.z, heading, false, false, true)
                SetVehicleDoorsLocked(vehicleId, 2)
                FreezeEntityPosition(vehicleId, true)
                table.insert(loadedVehicles, vehicleId)
            end
        end
    end
    if map.pickups then
        for i=1,#map.pickups do
            local pickup = map.pickups[i]
            VICE.createPickup(pickup.type, pickup.coords)
        end
    end
    VICE.createBlimpText()
    VICE.setPlayerInvisible(false)
    eventMapHasLoaded = true
    if fadeFlag then
        Wait(1000)
        DoScreenFadeIn(1000)
    end
end

function VICE.cleanupRockstarMaps()
    for _, objectId in pairs(loadedObjects) do
        if DoesEntityExist(objectId) then
            DeleteObject(objectId)
        end
    end
    for _, ptfxHandle in pairs(loadedPfx) do
        if DoesParticleFxLoopedExist(ptfxHandle) then
            StopParticleFxLooped(ptfxHandle, false)
        end
    end
    for _, vehicleId in pairs(loadedVehicles) do
        if DoesEntityExist(vehicleId) then
            DeleteEntity(vehicleId)
        end
    end
    for _, ipl in pairs(loadedIPLs) do
        RemoveIpl(ipl)
    end

    if blimpScaleform then
        if HasScaleformMovieLoaded(blimpScaleform) then
            SetScaleformMovieAsNoLongerNeeded(blimpScaleform)
        end
    end
    if IsNamedRendertargetRegistered("blimp_text") then
        ReleaseNamedRendertarget("blimp_text")
    end

    loadedObjects = {}
    loadedPfx = {}
    loadedVehicles = {}
    loadedIPLs = {}
    blimpScaleform = nil
end

RegisterNetEvent("VICE:loadRockstarMap", function(parsedMap)
    local bTeleport = true
    loadMap(parsedMap,true, false, bTeleport)
end)

Citizen.CreateThread(function()
    while true do
        if blimpScaleform then
            SetTextRenderId(GetNamedRendertargetRenderId("blimp_text"))
            SetScriptGfxDrawOrder(4)
            SetScriptGfxDrawBehindPausemenu(true)
            SetScaleformFitRendertarget(blimpScaleform, true)
            DrawScaleformMovie(blimpScaleform, 0.0, -0.08, 1.0, 1.7, 255, 255, 255, 255, 0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
        end
        Citizen.Wait(0)
    end
end)