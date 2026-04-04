globalInRedzone = false
local a = false
local b = 0
local c = false
local d = {
    ["Rebel"] = {type = "radius", pos = vector3(1468.5318603516, 6328.529296875, 18.894895553589), radius = 100.0},
    ["Heroin"] = {type = "radius", pos = vector3(3545.048828125, 3724.0776367188, 36.64262008667), radius = 170.0},
    ["LargeArms"] = {type = "radius", pos = vector3(-1118.4926757813, 4926.1889648438, 218.35691833496), radius = 170.0},
    ["LargeArmsCayo"] = {type = "radius",pos = vector3(5115.7465820312, -4623.2915039062, 2.642692565918),radius = 85.0},
    ["RebelCayo"] = {type = "radius", pos = vector3(4982.5634765625, -5175.1079101562, 2.4887988567352), radius = 120.0},
    ["LSDNorth"] = {type = "radius", pos = vector3(1317.0300292969, 4309.8359375, 38.005485534668), radius = 90.0},
    ["LSDSouth"] = {type = "radius", pos = vector3(2539.0964355469, -376.51586914063, 92.986785888672), radius = 120.0},
    ["OilRig"] = {type = "radius", pos = vector3(-1716.5004882812, 8886.94921875, 28.144144058228), radius = 200.0}
}
function VICE.setRedzoneTimerDisabled(e)
    a = e
end
function VICE.isPlayerInRedZone()
    return globalInRedzone
end
local f = 0
local timers = {}
local nlrTimer = 0
local nlrDuration = 300
local nlrLastWarning = 0

local function getNlrEjectCoords(j, k)
    local edgeDistance = 0.0
    if k.type == "radius" then
        edgeDistance = k.radius + 20.0
    else
        edgeDistance = math.max((k.width or 0.0) / 2.0, (k.height or 0.0) / 2.0) + 20.0
    end

    local delta = j.xy - k.pos.xy
    local len = #delta
    if len < 0.01 then
        delta = vector2(1.0, 0.0)
        len = 1.0
    end

    local dir = delta / len
    return vector3(k.pos.x + dir.x * edgeDistance, k.pos.y + dir.y * edgeDistance, j.z)
end

local function handleNlrEntry(j, k)
    if nlrTimer <= 0 or tVICE.isStaffedOn() or noclipActive then
        return false
    end

    local ped = VICE.getPlayerPed()
    local ejectCoords = getNlrEjectCoords(j, k)
    local targetZ = ejectCoords.z
    local foundGround, groundZ = GetGroundZFor_3dCoord(ejectCoords.x, ejectCoords.y, ejectCoords.z + 100.0, false)
    if foundGround then
        targetZ = groundZ + 1.0
    end

    RequestCollisionAtCoord(ejectCoords.x, ejectCoords.y, targetZ)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 then
        SetPedCoordsKeepVehicle(ped, ejectCoords.x, ejectCoords.y, targetZ)
    else
        SetEntityCoordsNoOffset(ped, ejectCoords.x, ejectCoords.y, targetZ, false, false, false)
        ClearPedTasksImmediately(ped)
    end

    if GetGameTimer() - nlrLastWarning > 1500 then
        local minutes = math.floor(nlrTimer / 60)
        local seconds = nlrTimer % 60
        tVICE.announceMpBigMsg("~r~NLR ACTIVE", string.format("You cannot re-enter redzone for %02d:%02d.", minutes, seconds), 2500)
        nlrLastWarning = GetGameTimer()
    end

    return true
end

local function startNlrTimer()
    nlrTimer = nlrDuration
end

AddEventHandler("baseevents:onPlayerDied", function()
    if VICE.isPlayerInRedZone() then
        startNlrTimer()
    end
end)

AddEventHandler("baseevents:onPlayerKilled", function()
    if VICE.isPlayerInRedZone() then
        startNlrTimer()
    end
end)

function tVICE.setPlayerCombatTimer(g, h)
    if VICE.isInPurge() then
        return
    end
    b = g
    if h then
        c = true
    end
    timers[g] = h
    if GetGameTimer() - f > 2500 or tVICE.isStaffedOn() then
        TriggerServerEvent("VICE:setCombatTimer", g)
        f = GetGameTimer()
    end
end
function tVICE.getPlayerCombatTimer()
    return b, c
end
function VICE.getPlayerCombatTimer()
    return b, c
end
local function i(j, k, l)
    if k.type == "radius" then
        if l then
            return #(j.xy - k.pos.xy) <= k.radius
        else
            return #(j - k.pos) <= k.radius
        end
    elseif k.type == "area" then
        local m = k.width / 2.0
        local n = k.height / 2.0
        if #(j - k.pos) <= m + n then
            local o = vector3(m, n, 0.0)
            local p = k.pos + o
            local q = k.pos - o
            return j.x < p.x and j.y < p.y and j.x > q.x and j.y > q.y
        end
    end
    return false
end
Citizen.CreateThread(
    function()
        while true do
            if not a then
                local r = GetEntityCoords(VICE.getPlayerPed())
                globalInRedzone = false
                for s, k in pairs(d) do
                    if i(r, k, false) then
                        if handleNlrEntry(r, k) then
                            globalInRedzone = false
                            break
                        end
                        globalInRedzone = true
                        local r = GetEntityCoords(VICE.getPlayerPed())
                        if not noclipActive or VICE.getStaffLevel() == 0 then
                            tVICE.setPlayerCombatTimer(30, false)
                        end
                        local t
                        local u = false
                        while not u do
                            r = GetEntityCoords(VICE.getPlayerPed())
                            while i(r, k, true) do
                                r = GetEntityCoords(VICE.getPlayerPed())
                                t = r
                                if
                                    IsPedShooting(VICE.getPlayerPed()) and
                                        GetSelectedPedWeapon(VICE.getPlayerPed()) ~= `WEAPON_UNARMED`
                                 then
                                    tVICE.setPlayerCombatTimer(60, true)
                                end
                                if b == 0 then -- b is the combat timer mkay
                                    -- Combat timer text is displayed in custom HUD box.
                        
                                end
                                Wait(0)
                            end
                            if b == 0 then
                                u = true
                            else
                                local v = k.pos - GetEntityCoords(VICE.getPlayerPed())
                                t = t + v * 0.01
                                if GetVehiclePedIsIn(VICE.getPlayerPed(), false) == 0 then
                                    TaskGoStraightToCoord(
                                        VICE.getPlayerPed(),
                                        t.x,
                                        t.y,
                                        t.z,
                                        8.0,
                                        1000,
                                        GetEntityHeading(VICE.getPlayerPed()),
                                        0.0
                                    )
                                    local w = GetSoundId()
                                    PlaySoundFrontend(w, "End_Zone_Flash", "DLC_BTL_RB_Remix_Sounds", true)
                                    ReleaseSoundId(w)
                                    tVICE.announceMpBigMsg("~r~WARNING", "Get back in the redzone!", 2000)
                                else
                                    SetEntityCoords(VICE.getPlayerPed(), t.x, t.y, t.z)
                                end
                                SetTimeout(
                                    1000,
                                    function()
                                        ClearPedTasks(VICE.getPlayerPed())
                                    end
                                )
                            end
                            Wait(0)
                        end
                    end
                end
            end
            Wait(500)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if b > 0 then
                if a then
                    tVICE.setPlayerCombatTimer(0, false)
                else
                    b = b - 1
                    if b == 0 then
                        c = false
                    end
                end
            end
            if nlrTimer > 0 then
                nlrTimer = nlrTimer - 1
            end
            Wait(1000)
        end
    end
)
local x = {["WEAPON_UNARMED"] = true, ["WEAPON_PETROLCAN"] = true, ["WEAPON_SNOWBALL"] = true}
local combatTimerUiLast = -1
local combatTimerUiPing = 0
AddEventHandler("VICE:startCombatTimer",function(h)
    if not VICE.isEmergencyService() then
        tVICE.setPlayerCombatTimer(60, h)
    end
end)
local function y()
    if not VICE.isEmergencyService() and not tVICE.isInComa() then
        local z = PlayerPedId()
        if HasEntityBeenDamagedByWeapon(z, 0, 2) then
            Citizen.CreateThread(
                function()
                    ClearEntityLastDamageEntity(z)
                    ClearEntityLastWeaponDamage(z)
                end
            )
            tVICE.setPlayerCombatTimer(60, true)
        end
        local A = GetSelectedPedWeapon(z)
        if IsPedShooting(z) and not x[A] then
            tVICE.setPlayerCombatTimer(60, true)
        elseif GetPlayerTargetEntity(VICE.getPlayerId()) and IsControlPressed(0, 24) then
            tVICE.setPlayerCombatTimer(60, true)
        end
    end
    if combatTimerUiLast ~= b or GetGameTimer() >= combatTimerUiPing then
        SendNUIMessage({combatTimer = b})
        combatTimerUiLast = b
        combatTimerUiPing = GetGameTimer() + 1000
    end
end
VICE.createThreadOnTick(y)
local function B()
    local z = PlayerPedId()
    SetCanPedEquipWeapon(z, "WEAPON_MOLOTOV", false)
    if GetSelectedPedWeapon(z) == `WEAPON_MOLOTOV` then
        VICE.setWeapon(z, "WEAPON_UNARMED", true)
    end
end
local function C()
    SetCanPedEquipWeapon(PlayerPedId(), "WEAPON_MOLOTOV", true)
end
VICE.createArea(
    "rig_disable_molotovs",
    vector3(-1703.7, 8886.5, 28.7),
    125.0,
    250.0,
    B,
    C,
    function()
    end
)
