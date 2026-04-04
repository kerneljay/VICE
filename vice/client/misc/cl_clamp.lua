local a = {"wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr"}
local b = false
local function c(d, e)
    local f = GetGameTimer()
    while GetGameTimer() - f < e do
        if GetEntitySpeed(d) > 0.2 then
            return true
        end
        Citizen.Wait(0)
    end
    return false
end
RegisterNetEvent(
    "VICE:clampNearestVehicle",
    function()
        if b then
            return
        end
        local d = VICE.getClosestVehicle(7.0)
        if d == 0 or not NetworkGetEntityIsNetworked(d) then
            notify("~r~No vehicle found.")
            return
        end
        local g = NetworkGetNetworkIdFromEntity(d)
        if g == 0 then
            return
        end
        for h, i in pairs(GetGamePool("CObject")) do
            if GetEntityAttachedTo(i) == d and GetEntityModel(i) == `prop_clamp` then
                local j = NetworkGetNetworkIdFromEntity(i)
                TriggerServerEvent("VICE:removeClamp", g, j)
                FreezeEntityPosition(d, false)
                notify("~y~Vehicle unclamped.")
                return
            end
        end
        if VICE.getPlayerVehicle() ~= 0 then
            notify("~r~You can not clamp whilst in a vehicle.")
            return
        end
        local k = GetVehicleClass(d)
        if k == 14 or k == 15 or k == 18 or k == 21 then
            notify("~r~You can not clamp this vehicle.")
            return
        end
        if GetEntitySpeed(d) > 0.2 then
            notify("~r~You can not clamp a moving vehicle.")
            return
        end
        local l = -1
        local m = 1.5
        local n = vector3(0.0, 0.0, 0.0)
        local o = VICE.getPlayerCoords()
        for h, p in pairs(a) do
            local q = GetEntityBoneIndexByName(d, p)
            if q ~= -1 then
                local r = GetWorldPositionOfEntityBone(d, q)
                local s = #(o - r)
                if s < m then
                    l = q
                    m = s
                    n = r
                end
            end
        end
        if l == -1 then
            notify("~r~You are not nearby to any wheel.")
            return
        end
        b = true
        local t = PlayerPedId()
        TaskTurnPedToFaceCoord(t, n.x, n.y, n.z, 2000)
        while GetScriptTaskStatus(t, `SCRIPT_TASK_TURN_PED_TO_FACE_COORD`) ~= 7 do
            Citizen.Wait(0)
        end
        VICE.loadClipSet("move_ped_crouched")
        SetPedCanPlayAmbientAnims(t, false)
        SetPedCanPlayAmbientBaseAnims(t, false)
        SetPedMovementClipset(t, "move_ped_crouched", 0.35)
        SetPedStrafeClipset(t, "move_ped_crouched_strafing")
        RemoveClipSet("move_ped_crouched")
        tVICE.playAnim(true, {{"rcmextreme3", "idle", 1}}, true)
        VICE.loadModel("prop_clamp")
        local u = GetOffsetFromEntityInWorldCoords(t, 0.0, 0.2, 0.0)
        local i = CreateObject("prop_clamp", u.x, u.y, u.z, true, true, true)
        SetModelAsNoLongerNeeded("prop_clamp")
        PlaceObjectOnGroundProperly(i)
        FreezeEntityPosition(i, true)
        SetEntityRotation(i, -90.0, 0.0, 0.0, 2, true)
        SetEntityCollision(i, false, false)
        local v = c(d, 4000)
        if not v then
            SetEntityCollision(i, true, true)
            SetEntityHeading(i, 0.0)
            SetEntityRotation(i, 60.0, 20.0, 10.0, 1, true)
            AttachEntityToEntity(i, d, l, -0.10, 0.15, -0.30, 180.0, 200.0, 90.0, true, true, false, false, 2, true)
            v = c(d, 1000)
        end
        tVICE.stopAnim(true)
        ResetPedStrafeClipset(t)
        ResetPedMovementClipset(t, 0.0)
        SetPedCanPlayAmbientAnims(t, true)
        SetPedCanPlayAmbientBaseAnims(t, true)
        if v or #(VICE.getPlayerCoords() - n) > 5.0 then
            DeleteEntity(i)
            notify("~r~Failed to place clamp on vehicle.")
            b = false
            return
        end
        local f = GetGameTimer()
        while not NetworkGetEntityIsNetworked(i) or NetworkGetNetworkIdFromEntity(i) == 0 do
            if GetGameTimer() - f > 3000 then
                DeleteEntity(i)
                b = false
                return
            end
            Citizen.Wait(0)
        end
        local j = NetworkGetNetworkIdFromEntity(i)
        if j ~= 0 then
            TriggerServerEvent("VICE:addClamp", g, j)
            FreezeEntityPosition(d, true)
            notify("~y~Vehicle clamped.")
        end
        b = false
    end
)
TriggerEvent("chat:addSuggestion", "/clamp", "Clamp the nearest vehicle")
