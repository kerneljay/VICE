radiusBlip = nil
local a = {}
local b
local c = {"p_cargo_chute_s", "xs_prop_arena_crate_01a", "cuban800", "s_m_m_pilot_02"}
local d
local purgeLootingCrateID = nil
local purgeSoundCrateID = nil
RegisterNetEvent(
    "VICE:crateDrop",
    function(e, f, g, crateModel)
        local selectedCrateModel = crateModel or "xs_prop_arena_crate_01a"
        for h, i in pairs(c) do
            VICE.loadModel(i)
        end
        VICE.loadModel(selectedCrateModel)
        RequestWeaponAsset("weapon_flare")
        while not HasWeaponAssetLoaded("weapon_flare") do
            Wait(0)
        end
        local j
        if not g then
            local k = math.random(0, 360) + 0.0
            local l = 1500.0
            local m = k / 180.0 * 3.14
            local n = vector3(e.x, e.y, e.z) - vector3(math.cos(m) * l, math.sin(m) * l, -500.0)
            local o = e.x - n.x
            local p = e.y - n.y
            local q = GetHeadingFromVector_2d(o, p)
            j = CreateVehicle("cuban800", n.x, n.y, n.z, q, false, true)
            DecorSetInt(j, decor, 955)
            SetEntityHeading(j, q)
            SetVehicleDoorsLocked(j, 2)
            SetEntityDynamic(j, true)
            ActivatePhysics(j)
            SetVehicleForwardSpeed(j, 60.0)
            SetHeliBladesFullSpeed(j)
            SetVehicleEngineOn(j, true, true, false)
            ControlLandingGear(j, 3)
            OpenBombBayDoors(j)
            SetEntityProofs(j, true, false, true, false, false, false, false, false)
            local r = CreatePedInsideVehicle(j, 1, "s_m_m_pilot_02", -1, false, true)
            SetBlockingOfNonTemporaryEvents(r, true)
            SetPedRandomComponentVariation(r, false)
            SetPedKeepTask(r, true)
            SetTaskVehicleGotoPlaneMinHeightAboveTerrain(j, 50)
            TaskVehicleDriveToCoord(
                r,
                j,
                vector3(e.x, e.y, e.z) + vector3(0.0, 0.0, 500.0),
                60.0,
                0,
                "cuban800",
                262144,
                15.0,
                -1.0
            )
            local s = AddBlipForEntity(j)
            SetBlipSprite(s, 307)
            SetBlipColour(s, 3)
            local t = vector2(e.x, e.y)
            local u = vector2(GetEntityCoords(j).x, GetEntityCoords(j).y)
            while #(u - t) > 5.0 do
                Wait(100)
                u = vector2(GetEntityCoords(j).x, GetEntityCoords(j).y)
            end
            TaskVehicleDriveToCoord(r, j, 0.0, 0.0, 500.0, 60.0, 0, "cuban800", 262144, -1.0, -1.0)
            SetTimeout(
                30000,
                function()
                    SetEntityAsNoLongerNeeded(r)
                    SetEntityAsNoLongerNeeded(j)
                end
            )
        end
        local v = vector3(e.x, e.y, GetEntityCoords(j).z - 5.0)
        a[f] = {}
        a[f].crate = CreateObject(selectedCrateModel, v, false, true, true)
        DecorSetInt(a[f].crate, "lootid", tonumber(f))
        DecorSetInt(a[f].crate, decor, 955)
        SetEntityInvincible(a[f].crate, true)
        SetEntityCanBeDamaged(a[f].crate, false)
        SetEntityProofs(a[f].crate, true, true, true, true, true, true, true, true)
        SetEntityLodDist(a[f].crate, 10000)
        ActivatePhysics(a[f].crate)
        SetDamping(a[f].crate, 2, 0.1)
        SetEntityVelocity(a[f].crate, 0.0, 0.0, -0.1)
        FreezeEntityPosition(a[f].crate, true)
        Wait(500)
        FreezeEntityPosition(a[f].crate, false)
        local w = AddBlipForEntity(a[f].crate)
        if g then
            SetBlipSprite(w, 306)
        else
            SetBlipSprite(w, 501)
        end
        SetBlipColour(w, 2)
        a[f].parachute = CreateObject("p_cargo_chute_s", v, false, true, true)
        DecorSetInt(a[f].parachute, decor, 955)
        SetEntityLodDist(a[f].parachute, 10000)
        SetEntityVelocity(a[f].parachute, 0.0, 0.0, -0.1)
        ActivatePhysics(a[f].crate)
        AttachEntityToEntity(
            a[f].parachute,
            a[f].crate,
            0,
            0.0,
            0.0,
            0.1,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
        radiusBlip = AddBlipForRadius(e.x, e.y, e.z, g and 50.0 or 200.0)
        SetBlipColour(radiusBlip, 1)
        SetBlipAlpha(radiusBlip, 180)
        local x = GetGameTimer()
        while GetEntityHeightAboveGround(a[f].crate) > 2 and GetGameTimer() - x < 60000 do
            Wait(100)
        end
        SetEntityCoords(a[f].crate, e + vector3(0.0, 0.0, -1.0))
        d = GetSoundId()
        PlaySoundFromEntity(d, "Crate_Beeps", a[f].crate, "MP_CRATE_DROP_SOUNDS", true, 0)
        ShootSingleBulletBetweenCoords(
            GetEntityCoords(a[f].crate),
            GetEntityCoords(a[f].crate) - vector3(0.0001, 0.0001, 0.0001),
            0,
            false,
            "weapon_flare",
            0,
            true,
            false,
            -1.0
        )
        DetachEntity(a[f].parachute, true, true)
        DeleteEntity(a[f].parachute)
        if DoesBlipExist(b) then
            RemoveBlip(b)
        end
        local y = GetEntityCoords(a[f].crate)
        FreezeEntityPosition(a[f].crate, true)
        for h, i in pairs(c) do
            SetModelAsNoLongerNeeded(GetHashKey(i))
        end
        SetModelAsNoLongerNeeded(selectedCrateModel)
    end
)
RegisterNetEvent(
    "VICE:removeLootcrate",
    function(f)
        if a[f] then
            if DoesEntityExist(a[f].crate) then
                DeleteEntity(a[f].crate)
            end
            if DoesEntityExist(a[f].parachute) then
                DeleteEntity(a[f].parachute)
            end
            SetTimeout(
                300000,
                function()
                    RemoveBlip(radiusBlip)
                end
            )
            StopSound(d)
            ReleaseSoundId(d)
            if purgeLootingCrateID == f then
                purgeLootingCrateID = nil
            end
        end
    end
)
RegisterNetEvent(
    "VICE:addCrateDropRedzone",
    function(crateID, e, crateModel, skipRadiusBlip)
        local selectedCrateModel = crateModel or "xs_prop_arena_crate_01a"
        VICE.loadModel(selectedCrateModel)
        a[crateID] = {}
        a[crateID].crate = CreateObject(selectedCrateModel, e + vector3(0.0, 0.0, -1.0), false, true, true)
        DecorSetInt(a[crateID].crate, "lootid", tonumber(crateID))
        DecorSetInt(a[crateID].crate, decor, 955)
        SetEntityInvincible(a[crateID].crate, true)
        SetEntityCanBeDamaged(a[crateID].crate, false)
        SetEntityProofs(a[crateID].crate, true, true, true, true, true, true, true, true)
        FreezeEntityPosition(a[crateID].crate, true)
        SetModelAsNoLongerNeeded(selectedCrateModel)
        local w = AddBlipForEntity(a[crateID].crate)
        SetBlipSprite(w, 501)
        SetBlipColour(w, 2)
        d = GetSoundId()
        PlaySoundFromEntity(d, "Crate_Beeps", a[crateID].crate, "MP_CRATE_DROP_SOUNDS", true, 0)
        if not skipRadiusBlip then
            radiusBlip = AddBlipForRadius(e.x, e.y, e.z, 200.0)
            SetBlipColour(radiusBlip, 1)
            SetBlipAlpha(radiusBlip, 180)
        end
    end
)
RegisterNetEvent(
    "VICE:removeCrateRedzone",
    function()
        SetTimeout(
            300000,
            function()
                RemoveBlip(radiusBlip)
            end
        )
    end
)
RegisterNetEvent(
    "VICE:removeCrateDropRedzone",
    function(crateID)
        if a[crateID] then
            if DoesEntityExist(a[crateID].crate) then
                DeleteEntity(a[crateID].crate)
            end
            if DoesEntityExist(a[crateID].parachute) then
                DeleteEntity(a[crateID].parachute)
            end
            if DoesBlipExist(radiusBlip) then
                RemoveBlip(radiusBlip)
                radiusBlip = nil
            end
            StopSound(d)
            ReleaseSoundId(d)
            a[crateID] = nil
            if purgeLootingCrateID == crateID then
                purgeLootingCrateID = nil
            end
        end
    end
)

RegisterNetEvent("VICE:startPurgeCrateTimer", function(crateID, durationMs)
    if purgeLootingCrateID then
        return
    end
    if not a[crateID] or not DoesEntityExist(a[crateID].crate) then
        return
    end

    purgeLootingCrateID = crateID
    local playerPed = PlayerPedId()
    local startCoords = GetEntityCoords(playerPed)
    local startTime = GetGameTimer()
    local lootAnimDict = "amb@medic@standing@tendtodead@base"
    local lootAnimName = "base"

    RequestAnimDict(lootAnimDict)
    while not HasAnimDictLoaded(lootAnimDict) do
        Wait(0)
    end
    TaskPlayAnim(playerPed, lootAnimDict, lootAnimName, 8.0, -8.0, -1, 49, 0.0, false, false, false)

    CreateThread(function()
        tVICE.startCircularProgressBar("", durationMs, nil, function()
        end)
    end)

    while purgeLootingCrateID == crateID and GetGameTimer() - startTime < durationMs do
        Wait(250)
        if not a[crateID] or not DoesEntityExist(a[crateID].crate) then
            TriggerServerEvent("VICE:cancelPurgeCrateLoot", crateID)
            tVICE.stopCircularProgressBar()
            ClearPedTasksImmediately(PlayerPedId())
            RemoveAnimDict(lootAnimDict)
            purgeLootingCrateID = nil
            return
        end

        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local crateCoords = GetEntityCoords(a[crateID].crate)
        if IsEntityDead(ped) or #(pedCoords - crateCoords) > 5.0 or #(pedCoords - startCoords) > 8.0 then
            TriggerServerEvent("VICE:cancelPurgeCrateLoot", crateID)
            tVICE.stopCircularProgressBar()
            ClearPedTasksImmediately(ped)
            RemoveAnimDict(lootAnimDict)
            purgeLootingCrateID = nil
            return
        end

        -- Standing up / interrupting the loot pose cancels the capture.
        if IsEntityPlayingAnim(ped, lootAnimDict, lootAnimName, 3) ~= 1 then
            TriggerServerEvent("VICE:cancelPurgeCrateLoot", crateID)
            tVICE.stopCircularProgressBar()
            ClearPedTasksImmediately(ped)
            RemoveAnimDict(lootAnimDict)
            purgeLootingCrateID = nil
            return
        end
    end

    if purgeLootingCrateID == crateID then
        TriggerServerEvent("VICE:finishPurgeCrateLoot", crateID)
        tVICE.stopCircularProgressBar()
        ClearPedTasksImmediately(PlayerPedId())
        RemoveAnimDict(lootAnimDict)
        purgeLootingCrateID = nil
    end
end)

RegisterNetEvent("VICE:announcePurgeZoneStart", function(redzoneName)
    tVICE.announceMpBigMsg("~r~PURGE ZONE", "Purge Zone has started at "..tostring(redzoneName), 10000)
end)

RegisterNetEvent("VICE:startPurgeLootSound", function(crateID)
    purgeSoundCrateID = crateID
    CreateThread(function()
        while purgeSoundCrateID == crateID do
            TriggerEvent("vice:PlaySound", "purge")
            Wait(10000)
        end
    end)
end)

RegisterNetEvent("VICE:stopPurgeLootSound", function(crateID)
    if purgeSoundCrateID == crateID then
        purgeSoundCrateID = nil
    end
end)
