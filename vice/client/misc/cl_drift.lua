local a = {
    [2] = {255, 25, 25},
    [3] = {255, 179, 25},
    [4] = {255, 255, 25},
    [5] = {102, 255, 25},
    [6] = {25, 25, 255},
    [7] = {179, 25, 255},
    [8] = {255, 25, 255}
}
local b = {}
local c = {}
local d = false
local e = false
function setVehicleIdDriftSuspension(f, g)
    if g["1"] then
        b[f] = true
    end
end
function setVehicleIdDriftSmoke(f, g)
    if g >= 2 then
        c[f] = g
    end
end
local function h(i, j)
    return math.floor(i / 2 ^ j) % 2 == 1
end
local function k(l)
    if not d then
        drawNativeNotification("Press ~INPUT_SPECIAL_ABILITY_SECONDARY~ to toggle drift mode.")
        d = true
        e = false
    end
    if IsControlJustPressed(0, 29) then
        local m = GetVehicleHandlingInt(l, "CCarHandlingData", "strAdvancedFlags")
        if m ~= 0 and h(m, 15) and h(m, 26) then
            e = not e
            drawNativeText(string.format("Drift mode ~y~%s~w~.", e and "enabled" or "disabled"))
            SetDriftTyresEnabled(l, e)
            SetReduceDriftVehicleSuspension(l, e)
        end
    end
end
local function n(l)
    local o = GetEntityVelocity(l)
    local p = math.sqrt(o.x * o.x + o.y * o.y)
    local q = GetEntityRotation(l, 0)
    local r, s = -math.sin(math.rad(q.z)), math.cos(math.rad(q.z))
    if GetEntitySpeed(l) * 3.6 < 5.0 or GetVehicleCurrentGear(l) == 0 then
        return 0, p
    end
    local t = (r * o.x + s * o.y) / p
    if t > 0.966 or t < 0.0 then
        return 0, p
    end
    return math.deg(math.acos(t)) * 0.5, p
end
local function u(v, w, l, x, y, z)
    local A = {}
    local B = a[z]
    VICE.loadPtfx(v)
    for C = 1, x do
        UseParticleFxAsset(v)
        local D =
            StartParticleFxLoopedOnEntityBone(
            w,
            l,
            0.05,
            0,
            0,
            0,
            0,
            0,
            GetEntityBoneIndexByName(l, "wheel_lr"),
            y,
            false,
            false,
            false
        )
        if B then
            SetParticleFxLoopedColour(D, B[1] / 255, B[2] / 255, B[3] / 255, false)
        end
        UseParticleFxAsset(v)
        local E =
            StartParticleFxLoopedOnEntityBone(
            w,
            l,
            0.05,
            0,
            0,
            0,
            0,
            0,
            GetEntityBoneIndexByName(l, "wheel_rr"),
            y,
            false,
            false,
            false
        )
        if B then
            SetParticleFxLoopedColour(E, B[1] / 255, B[2] / 255, B[3] / 255, false)
        end
        table.insert(A, D)
        table.insert(A, E)
    end
    RemoveNamedPtfxAsset(v)
    Citizen.Wait(3000)
    for C, F in pairs(A) do
        StopParticleFxLooped(F, true)
    end
end
local function G(l, z)
    local H, I = n(l)
    if I > 3.0 and H ~= 0 then
        u("scr_recartheft", "scr_wheel_burnout", l, 10, 0.2, z)
    elseif I < 1.0 and IsVehicleInBurnout(l) then
        u("core", "exp_grd_bzgas_smoke", l, 3, 1.5, 0)
    end
end
local function J(l)
    local K, f = VICE.getVehicleInfos(l)
    if VICE.getUserId() ~= K then
        return
    end
    if b[f] then
        k(l)
    end
    if c[f] then
        G(l, c[f])
    end
end
Citizen.CreateThread(
    function()
        while true do
            local l, L = VICE.getPlayerVehicle()
            if l ~= 0 and L then
                J(l)
            else
                d = false
            end
            Citizen.Wait(0)
        end
    end
)
