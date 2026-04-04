local a = {}
local b = {}
local c = false
local d
local e = 25.0
local f = 219
local g = 105
local h = 97
local i = 255
local j = 4
local k = 0.5
local l = 0.9
local m = 0.92
Citizen.CreateThread(
    function()
        while true do
            local n = VICE.getPlayerPed()
            local o = GetVehiclePedIsIn(VICE.getPlayerPed(), false)
            if o ~= 0 and GetPedInVehicleSeat(o, -1) == n then
                local p, q = VICE.getVehicleInfos(o)
                local r = DecorGetInt(o, "VICE_owner")
                if p == VICE.getUserId() then
                    if a[q] then
                        local s = a[q]
                        d = q
                        c = true
                        while GetVehiclePedIsIn(VICE.getPlayerPed(), false) ~= 0 do
                            Wait(1000)
                        end
                        c = false
                        offset = s - a[q]
                        TriggerServerEvent("VICE:updateNitro", q, -offset)
                    end
                end
            end
            Wait(0)
        end
    end
)
local t = {"exhaust", "exhaust_2", "exhaust_3", "exhaust_4"}
local u = "veh_backfire"
local v = "core"
local w = 2.4
local x = {"overheat"}
local y = "ent_sht_steam"
local z = "core"
local A = 0.4
local function B(C, D)
    local E = GetEntityBoneIndexByName(C, D)
    VICE.loadPtfx("core")
    UseParticleFxAsset("core")
    local F =
        StartParticleFxLoopedOnEntityBone(
        "veh_light_red_trail",
        C,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        E,
        1.0,
        false,
        false,
        false
    )
    SetParticleFxLoopedEvolution(F, "speed", 1.0, false)
    RemoveNamedPtfxAsset("core")
    return F
end
local function G(C, H, I, J, K, L, M)
    VICE.loadPtfx("core")
    UseParticleFxAsset("core")
    local F = StartParticleFxLoopedOnEntity("ent_sht_steam", C, H, I, J, K, L, M, 0.5, false, false, false)
    RemoveNamedPtfxAsset("core")
    return F
end
local function N(C)
    if b[C] then
        return
    end
    local O = {}
    O.leftTrail = B(C, "taillight_l")
    O.rightTrail = B(C, "taillight_r")
    local P = GetEntityBoneIndexByName(C, "bonnet")
    local Q = GetWorldPositionOfEntityBone(C, P)
    local R = GetOffsetFromEntityGivenWorldCoords(C, Q.x, Q.y, Q.z)
    O.purge = {}
    for S = 0, 3 do
        local T = G(C, R.x - 0.5, R.y + 0.05, R.z, 40.0, -20.0, 0.0)
        table.insert(O.purge, T)
        local U = G(C, R.x + 0.5, R.y + 0.05, R.z, 40.0, 20.0, 0.0)
        table.insert(O.purge, U)
    end
    b[C] = O
end
local function V(F)
    Citizen.CreateThread(
        function()
            local W = GetGameTimer() + 500
            while GetGameTimer() < W do
                local X = GetGameTimer()
                local Y = (W - X) / 500
                SetParticleFxLoopedScale(F, Y)
                SetParticleFxLoopedAlpha(F, Y)
                Citizen.Wait(0)
            end
            StopParticleFxLooped(F, false)
        end
    )
end
local function Z(C)
    local O = b[C]
    if not O then
        return
    end
    V(O.leftTrail)
    V(O.rightTrail)
    for S, F in pairs(O.purge) do
        StopParticleFxLooped(F, false)
    end
end
local function _(C)
    if not IsVehicleStopped(C) then
        local a0 = GetEntityModel(C)
        local a1 = GetEntitySpeed(C)
        local a2 = GetVehicleModelEstimatedMaxSpeed(a0)
        local a3 = 7.0 * a2 / a1
        SetVehicleCheatPowerIncrease(C, a3)
    end
end
function func_drawNitroText()
    if c and a[d] > 0 then
        local a4 = a[d]
        if a4 < 0 then
            a4 = 0
        end
        VICE.DrawText(l, m, "Nitro: " .. math.floor(tonumber(a4)) .. "%", k, j, 1, {f, g, h, i}, true)
        local o = GetVehiclePedIsIn(VICE.getPlayerPed(), false)
        if IsControlPressed(0, 21) then
            if a[d] - 0.05 >= 0 then
                N(o)
                _(o)
                AnimpostfxPlay("RaceTurbo", 0, 0)
                a[d] = a[d] - 0.05
                if not nitroEventDelay then
                    nitroEventDelay = true
                    vehicleFlameExhaustEffect(o)
                    vehiclePurgeExhaustEffect(o)
                    exhaustSoundStart(o)
                    SetTimeout(
                        100,
                        function()
                            nitroEventDelay = false
                        end
                    )
                end
            else
                a[d] = 0
                StopGameplayCamShaking(true)
                SetVehicleCheatPowerIncrease(o, 1.0)
                SetVehicleBoostActive(o, false)
                AnimpostfxStop("RaceTurbo")
            end
        else
            SetVehicleCheatPowerIncrease(o, 1.0)
            exhaustSoundStop(o)
            Z(o)
        end
    end
end
VICE.createThreadOnTick(func_drawNitroText)
function vehicleFlameExhaustEffect(C)
    for S, a5 in pairs(t) do
        UseParticleFxAsset(v)
        createdPart =
            StartParticleFxLoopedOnEntityBone(
            u,
            C,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            GetEntityBoneIndexByName(C, a5),
            w,
            0.0,
            0.0,
            0.0
        )
        StopParticleFxLooped(createdPart, 1)
    end
end
function vehiclePurgeExhaustEffect(C)
    for S, a5 in pairs(x) do
        UseParticleFxAsset(z)
        createdPart =
            StartParticleFxLoopedOnEntityBone(
            y,
            C,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            GetEntityBoneIndexByName(C, a5),
            A,
            0.0,
            0.0,
            0.0
        )
        StopParticleFxLooped(createdPart, 1)
    end
end
function exhaustSoundStart(C)
    SetVehicleBoostActive(C, 1)
end
function exhaustSoundStop(C)
    SetVehicleBoostActive(C, 0)
end
function setVehicleIdNitro(q, a6)
    a[q] = a6
    if a[q] > 100 then
        a[q] = 100
    end
end
function addVehicleIdNitro(q, a6)
    a[q] = a[q] + a6
    if a[q] > 100 then
        a[q] = 100
    end
end
function getVehicleIdNitro(q)
    return a[q]
end
