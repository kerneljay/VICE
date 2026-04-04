local a = module("VICEVeh", "cfg_vehiclemaxspeeds")
isInGreenzone = false
local cityCap = true
local b = false
local c = false
local gangZone = false
local d = false
local e = false
local f = 0
local g = false
local h = false
local i = false
local j = vector3(0.0, 0.0, 0.0)
local k = 0.0
local zz = {
    -- {
    --     colour = 7,
    --     id = 1,
    --     pos = vector3(892.02825927734,-2109.3544921875,30.761661529541),
    --     dist = 30,
    --     nonRP = true,
    --     setBit = false,
    --     gZone = true,
    --     maxHeight = 105.0
    -- },
    -- {
    --     colour = 7,
    --     id = 1,
    --     pos = vector3(-587.50897216797,-717.9052734375,36.279510498047),
    --     dist = 30,
    --     nonRP = true,
    --     setBit = false,
    --     gZone = true,
    --     maxHeight = 105.0
    -- },
    -- {
    --     colour = 7,
    --     id = 1,
    --     pos = vector3(389.19250488281, 1.8228433132172, 91.415802001953),
    --     dist = 61,
    --     nonRP = true,
    --     setBit = false,
    --     gZone = true,
    --     maxHeight = 105.0
    -- },
    -- {
    --     colour = 7,
    --     id = 1,
    --     pos = vector3(-1017.5219116211,-419.19961547852,33.260135650635),
    --     dist = 32,
    --     nonRP = true,
    --     setBit = false,
    --     gZone = true,
    --     maxHeight = 105.0
    -- },
}
local l = {
    {
        colour = 2,
        id = 1,
        pos = vector3(333.91488647461, -597.16156005859, 29.292747497559),
        dist = 40,
        nonRP = false,
        setBit = false,
        maxHeight = 105.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(141.11846923828,-1061.2664794922,29.19236946106),
        dist = 45,
        nonRP = false,
        setBit = false,
        maxHeight = 87.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-252.12911987305,6325.6162109375,32.427223205566),
        dist = 45,
        nonRP = false,
        setBit = false,
        maxHeight = 87.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-110.09871673584, 6464.6030273438, 31.62672996521),
        dist = 20,
        nonRP = false,
        setBit = false,
        maxHeight = 50.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-1079.5734863281, -843.14739990234, 4.8841333389282),
        dist = 45,
        nonRP = false,
        setBit = false,
        maxHeight = 59.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-2681.8854980469,-1494.7041015625,4.437831401825), --VICE Island -- 1464.9133300781,3562.5808105469,36.821094512939
        dist = 150, 
        nonRP = true,
        setBit = false,
        maxHeight = 77.0
    },
        {
        colour = 2,
        id = 1,
        pos = vector3(1474.7325439453,3567.0590820312,36.820770263672), -- wagers
        dist = 15, 
        nonRP = false,
        setBit = false,
        maxHeight = 77.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-540.54748535156, -216.42681884766, 37.64966583252),
        dist = 50,
        nonRP = false,
        setBit = false,
        maxHeight = 102.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(246.30143737793, -782.50170898438, 30.573167800903),
        dist = 40,
        nonRP = false,
        setBit = false,
        maxHeight = 100.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(3486.9533691406,2584.42578125,14.178074836731), -- admin island
        dist = 200,
        nonRP = true,
        setBit = false,
        maxHeight = 150.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(1133.0970458984, 250.78565979004, -51.035778045654),
        dist = 100,
        nonRP = false,
        setBit = false,
        interior = true,
        maxHeight = 0.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(13.929432868958, 6711.216796875, -105.85443878174),
        dist = 100,
        nonRP = false,
        setBit = false,
        interior = true,
        maxHeight = 0.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-335.19680786133, -699.10406494141, 33.036075592041),
        dist = 30,
        nonRP = false,
        setBit = false,
        maxHeight = 86.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-1671.5692138672, -912.63940429688, 8.2297477722168),
        dist = 50,
        nonRP = false,
        setBit = false,
        maxHeight = 60.0
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-1437.4920654297, -2961.6879882812, 14.313854217529),
        dist = 700,
        nonRP = true,
        setBit = false,
        maxHeight = 210.0,
        isPurge = true
    },
    {
        colour = 2,
        id = 1,
        pos = vector3(-732.95123291016, 5812.35546875, 17.42693901062),
        dist = 35,
        nonRP = false,
        setBit = false,
        maxHeight = 210.0
    },
        {
        colour = 2,
        id = 1,
        pos = vector3(-2181.7966308594, 5189.8286132813, 17.64377784729),
        dist = 150,
        nonRP = true,
        setBit = false,
        maxHeight = 210.0
    },
}
local m = {
    
    {vector3(333.91488647461, -597.16156005859, 29.292747497559), 40.0, 2, 180},
    {vector3(-252.12911987305,6325.6162109375,32.427223205566), 40.0, 2, 180},
    {vector3(141.11846923828,-1061.2664794922,29.19236946106), 45.0, 2, 180},
    {vector3(-110.09871673584, 6464.6030273438, 31.62672996521), 20.0, 2, 180},
    {vector3(-2681.8854980469,-1494.7041015625,4.437831401825), 45.0, 2, 180},
    {vector3(-2181.7966308594, 5189.8286132813, 17.64377784729), 150.0, 2, 180}, -- VICE Island
    {vector3(-540.54748535156, -216.42681884766, 37.64966583252), 50.0, 2, 180},
    {vector3(246.30143737793, -782.50170898438, 30.573167800903), 40.0, 2, 180},
    {vector3(-335.19680786133, -699.10406494141, 33.036075592041), 30.0, 2, 180},
    {vector3(-1671.5692138672, -912.63940429688, 8.2297477722168), 50.0, 2, 180},
    {vector3(1468.5318603516, 6328.529296875, 18.894895553589), 100.0, 1, 180},
    {vector3(4982.5634765625, -5175.1079101562, 2.4887988567352), 120.0, 1, 180},
   -- {vector3(-2332.9575195312, 266.10708618164, 169.60191345215), 40.0, 2, 180}, -- kortz center
    {vector3(5115.7465820312, -4623.2915039062, 2.642692565918), 85.0, 1, 180},
    {vector3(-1437.4920654297, -2961.6879882812, 14.31385421759), 700.0, 2, 255, true},
    {vector3(-732.95123291016, 5812.35546875, 17.42693901062), 35.0, 2, 180},
    {vector3(-1716.5004882812, 8886.94921875, 28.144144058228), 200.0, 1, 180},
    -- {vector3(892.02825927734,-2109.3544921875,30.761661529541), 30.0, 7, 200},
    -- {vector3(389.19250488281, 1.8228433132172, 91.415802001953), 61.0, 7, 200},
    -- {vector3(-587.50897216797,-717.9052734375,36.279510498047), 30.0, 7, 200},
    {vector3(-1017.5219116211,-419.19961547852,33.260135650635), 32.0, 7, 200},
}
local n = Citizen.CreateThread
local o = Citizen.Wait
local SetEntityInvincible = SetEntityInvincible
local SetPlayerInvincible = SetPlayerInvincible
local ClearPedBloodDamage = ClearPedBloodDamage
local ResetPedVisibleDamage = ResetPedVisibleDamage
local ClearPedLastWeaponDamage = ClearPedLastWeaponDamage
local SetEntityProofs = SetEntityProofs
local SetEntityCanBeDamaged = SetEntityCanBeDamaged
local NetworkSetFriendlyFireOption = NetworkSetFriendlyFireOption
local GetEntityCoords = GetEntityCoords
local SetEntityNoCollisionEntity = SetEntityNoCollisionEntity
local SetPedCanRagdoll = SetPedCanRagdoll
local SetPedCanRagdollFromPlayerImpact = SetPedCanRagdollFromPlayerImpact
local SetEntityMaxSpeed = SetEntityMaxSpeed
local GetEntityModel = GetEntityModel
local SetEntityCollision = SetEntityCollision
local DisableControlAction = DisableControlAction
local GetVehiclePedIsIn = GetVehiclePedIsIn
function VICE.areGreenzonesDisabled()
    return i
end
function VICE.setGreenzonesDisabled(p)
    i = p
end
n(
    function()
        for q, r in pairs(m) do
            if not r[5] and not VICE.isInPurge() or r[5] and VICE.isInPurge() then
                local s = AddBlipForRadius(r[1].x, r[1].y, r[1].z, r[2])
                SetBlipColour(s, r[3])
                SetBlipAlpha(s, r[4])
            end
        end
    end
)
n(
    function()
        local purgeActive = VICE.isInPurge()
        while true do
            local t = VICE.getPlayerPed()
            local u = VICE.getPlayerCoords()
            for v, w in pairs(l) do
                if not w.isPurge and not purgeActive or w.isPurge and purgeActive then
                    local x = #(u.xy - w.pos.xy)
                    while x < w.dist and u.z < w.maxHeight do
                        u = VICE.getPlayerCoords()
                        x = #(u.xy - w.pos.xy)
                        if w.gZone then
                            gangZone = true
                        end
                        if w.nonRP then
                            c = true
                        else
                            if not w.setBit then
                                b = true
                                d = true
                                e = false
                                f = 5
                                j = w.pos
                                k = w.dist
                                w.setBit = true
                            end
                            if w.interior then
                                setDrawGreenInterior = true
                            end
                        end
                        o(100)
                    end
                    if w.setBit then
                        d = false
                        e = true
                        f = 5
                        j = vector3(0.0, 0.0, 0.0)
                        k = 0.0
                        w.setBit = false
                    end
                    c = false
                    gangZone = false
                    b = false
                    d = false
                    setDrawGreenInterior = false
                    SetEntityInvincible(t, false)
                    SetPlayerInvincible(VICE.getPlayerId(), false)
                    ClearPedBloodDamage(t)
                    ResetPedVisibleDamage(t)
                    ClearPedLastWeaponDamage(t)
                    SetEntityProofs(t, false, false, false, false, false, false, false, false)
                    SetEntityCanBeDamaged(t, true)
                    SetLocalPlayerAsGhost(false)
                    SetNetworkVehicleAsGhost(VICE.getPlayerVehicle(), false)
                end
            end
            o(250)
        end
    end
)
Citizen.CreateThread(function()
    local purgeActive = VICE.isInPurge()
    while true do
        local playerPed = VICE.getPlayerPed()
        local playerCoords = VICE.getPlayerCoords()
        for _, w in pairs(zz) do
            if (not w.isPurge and not purgeActive) or (w.isPurge and purgeActive) then
                local distance = #(playerCoords - w.pos)
                while distance < w.dist and playerCoords.z < w.maxHeight do
                    playerCoords = VICE.getPlayerCoords()
                    distance = #(playerCoords - w.pos)
                    if w.gZone then
                        gangZone = true
                    end
                    Citizen.Wait(0) 
                end
            end
        end
        Citizen.Wait(1000) 
    end
end)
AddEventHandler("VICE:onClientSpawn",function(y, z)
    if z then
        local A = function(B)
            inCityZone = true
        end
        local C = function(B)
            inCityZone = false
        end
        local D = function(B)
        end
        VICE.createArea("cityzone",vector3(-225.30703735352, -916.74755859375, 31.216938018799),750.0,100,A,C,D,{})
    end
end)
local function E()
    local F = VICE.getPlayerCoords()
    local G = nil
    for H = 1, 25 do
        local I, J = GetNthClosestVehicleNode(F.x, F.y, F.z, H)
        if I and #(j - J) > k then
            G = J
            break
        end
    end
    if G then
        local K, L = VICE.getPlayerVehicle()
        if K ~= 0 then
            if L and GetScriptTaskStatus(PlayerPedId(), "SCRIPT_TASK_VEHICLE_DRIVE_TO_COORD") == 7 then
                TaskVehicleDriveToCoord(PlayerPedId(), K, G.x, G.y, G.z, 30.0, 1.0, GetEntityModel(K), 16777216, 1.0, 1)
            end
        else
            if GetScriptTaskStatus(PlayerPedId(), "SCRIPT_TASK_FOLLOW_NAVMESH_TO_COORD_ADVANCED") == 7 then
                TaskFollowNavMeshToCoordAdvanced(PlayerPedId(), G.x, G.y, G.z, 8.0, -1, 2.5, 0, 0, 0.0, 100.0, 4000.0)
            end
        end
    end
end

n(function()
    while true do
        local t = PlayerPedId()
        local M = GetVehiclePedIsIn(t, false)
      --  SetVehicleAutoRepairDisabled(M, true)
        if not VICE.areGreenzonesDisabled() then
            isInGreenzone = b or c or gangZone
            local N = GetActivePlayers()
            local O = VICE.getPlayerId()
            if b or c then
                SetEntityMaxSpeed(M, a.maxSpeeds["50"])
                SetLocalPlayerAsGhost(true)
                SetNetworkVehicleAsGhost(M, true)
                SetEntityAlpha(VICE.getPlayerVehicle(), 255)
                SetEntityAlpha(t, 255)
                for P, Q in pairs(N) do
                    local R = GetPlayerPed(Q)
                    local S = GetVehiclePedIsIn(R, true)
                    SetEntityAlpha(R, 255)
                    SetEntityAlpha(S, 255)
                end
                SetEntityInvincible(t, true)
                SetPlayerInvincible(O, true)
                ClearPedBloodDamage(t)
                if usingDelgun then
                    VICE.setWeapon(t, "WEAPON_STAFFGUN", true)
                else
                    VICE.setWeapon(t, "WEAPON_UNARMED", true)
                end
                ResetPedVisibleDamage(t)
                ClearPedLastWeaponDamage(t)
                SetEntityProofs(t, true, true, true, true, true, true, true, true)
                SetEntityCanBeDamaged(t, false)
                SetPedCanRagdoll(t, false)
                SetPedCanRagdollFromPlayerImpact(t, false)
            else
                SetPedCanRagdoll(t, true)
                SetPedCanRagdollFromPlayerImpact(t, true)
                if M ~= 0 then
                    SetEntityCollision(M, true, true)
                    local T = GetEntityModel(M)
                    if inCityZone then 
                        -- In city speed cap is always 150
                        if a.vehicleMaxSpeeds[T] then
                            -- If vehicle has a specific speed limit, use the lower of that or 150
                            local vehicleLimit = a.maxSpeeds[a.vehicleMaxSpeeds[T]]
                            if vehicleLimit > a.maxSpeeds["150"] then
                                SetEntityMaxSpeed(M, a.maxSpeeds["150"])
                            else
                                SetEntityMaxSpeed(M, vehicleLimit)
                            end
                        else
                            SetEntityMaxSpeed(M, a.maxSpeeds["150"])
                        end
                    else
                        -- Outside city
                        if a.vehicleMaxSpeeds[T] then
                            SetEntityMaxSpeed(M, a.maxSpeeds[a.vehicleMaxSpeeds[T]])
                        elseif globalOnTruckJob then
                            drawNativeText("~y~Vehicle Speed Limited By Trucking Job")
                            SetEntityMaxSpeed(M, a.maxSpeeds["150"])
                        elseif globalOnAADuty then
                            SetEntityMaxSpeed(M, a.maxSpeeds["150"])
                        else
                            SetEntityMaxSpeed(M, a.maxSpeeds["250"])
                        end
                    end
                end
            end
            if d and g == false then
                TriggerEvent(
                    "VICE:showNotification",
                    {
                        text = "You have entered the greenzone",
                        height = "200px",
                        width = "auto",
                        colour = "#FFF",
                        background = "#32CD32",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    5000
                )
                g = true
                h = false
            end
            if e and h == false then
                TriggerEvent(
                    "VICE:showNotification",
                    {
                        text = "You have left the greenzone",
                        height = "60px",
                        width = "auto",
                        colour = "#FFF",
                        background = "#ff0000",
                        pos = "bottom-right",
                        icon = "bad"
                    },
                    5000
                )
                h = true
                g = false
            end
            if b then
                DisableControlAction(2, 37, true)
                DisablePlayerFiring(O, true)
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 140, true)
                local U, V = VICE.getPlayerCombatTimer()
                if U > 0 and V then
                    E()
                end
            end
            if c then
                drawNativeText("You have entered a non-RP greenzone, you may talk OOC here")
                DisableControlAction(2, 37, true)
                DisablePlayerFiring(O, true)
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 140, true)
            end
            if gangZone and not insideDiamondCasino then
                drawNativeText("~p~ENTERED NOTABLE GANG ZONE")
            end
            if setDrawGreenInterior then
                DisableControlAction(0, 106, true)
                DisableControlAction(0, 45, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 22, true)
            end
        end
        o(0)
    end
end)

function VICE.getPlayerGreenZone()
    return isInGreenzone
end
            
RegisterCommand('togglecitycap', function()
    if VICE.getUserId() == 1 then
        cityCap = not cityCap
        VICE.notify('City Cap: '..(cityCap and "~g~Enabled" or "~r~Disabled"))
    end
end)