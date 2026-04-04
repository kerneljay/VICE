local a = module("cfg/cfg_pilotjob")
globalOnPilotDuty = true
local b = a.fuelStations
local c = {}
local d = false
local e
local f
local g
local h = false
local i = false
local j = false
local k = false
local l = false
local m
local n = false
local o
local p
local q = 0
local r = 0
local s = 0
local t = { x = 0.932, y = 0.77, width = 0.03, height = 0.4 }
local u = { x = t.x, y = t.y, width = t.width, height = t.height }
local v = { x = t.x, y = t.y - t.height / 2, width = t.width, height = 0.002 }
local w = { x = t.x, y = t.y + t.height / 2, width = t.width, height = v.height }
local x = { x = t.x - t.width / 2, y = t.y, width = v.height / 2, height = t.height + v.height }
local y = { x = t.x + t.width / 2, y = t.y, width = v.height / 2, height = t.height + v.height }
local z = { x = 0.965, y = 0.77, width = 0.03, height = 0.4 }
local A = { x = z.x, y = 0, width = z.width, height = q / 150 * z.height }
A.y = z.y + z.height / 2 - A.height / 2
local B = { x = z.x, y = z.y - z.height / 2, width = z.width, height = 0.002 }
local C = { x = z.x, y = z.y + z.height / 2, width = z.width, height = B.height }
local D = { x = z.x - z.width / 2, y = z.y, width = B.height / 2, height = z.height + B.height }
local E = { x = z.x + z.width / 2, y = z.y, width = B.height / 2, height = z.height + B.height }

RMenu.Add('VICEpilotJob', 'atcMenu', RageUI.CreateMenu("", "Air Traffic Communications", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_pilotjob", "vice_pilotjob"))
AddEventHandler("VICE:onClientSpawn", function(F, G)
    local H = a.startJobLocs
    if G then
        for I = 1, #H, 1 do
            tVICE.addMarker(H[I].coords.x, H[I].coords.y, H[I].coords.z, 1.0, 1.0, 1.3, 10, 255, 81, 170, 50, 33, false, false, true, nil, nil, 0.0, 0.0, 0.0)
        end
    end
end)

local function J(...)
    print("[Pilot Job]", ...)
end

Citizen.CreateThread(function()
    RequestStreamedTextureDict("pilotjob", false)
    while not HasStreamedTextureDictLoaded("pilotjob") do
        Wait(0)
    end
end)

RegisterNetEvent("VICE:pilotJobCreatePlane", function(K, L, M)
    p = L
    o = M
    local N = a.planeSpawnLocs
    local O = a.tugSpawnLocs
    e = K
    globalOnPilotDuty = true
    tVICE.setCustomization({ modelhash = `s_m_m_pilot_01` })
    Citizen.Wait(500)
    g = VICE.spawnVehicle('airtug', O[M].coords.x, O[M].coords.y, O[M].coords.z, O[M].h, true, true, false)
    SetVehicleColours(g, 89, 0)
    SetNewWaypoint(N[L].coords.x, N[L].coords.y)
    drawPlaneScaleForm("~g~COLLECT PLANE", "Collect your plane from the waypoint on your map")
    while #(N[L].coords - VICE.getPlayerCoords()) > 250 do
        Citizen.Wait(500)
    end
    f = VICE.spawnVehicle(K.spawnName, N[L].coords.x, N[L].coords.y, N[L].coords.z, N[L].h, false, true, false)
    local P = GetOffsetFromEntityInWorldCoords(f, 0.0, 0.0, -2.0)
    local Q = a.pilotBlipColor
    local R = a.planeBlipColor
    SetVehicleColours(f, Q[1], Q[2])
    SetEntityAsMissionEntity(f, true, true)
    SetVehicleDoorsLockedForAllPlayers(f, true)
    SetVehicleEngineOn(f, true, false, false)
    SetVehicleFuelLevel(f, 100.0)
    TaskWarpPedIntoVehicle(PlayerPedId(), f, -1)
    FreezeEntityPosition(g, true)
    tVICE.deleteMarker()
    tVICE.addMarker(N[L].coords.x, N[L].coords.y, N[L].coords.z, 1.0, 1.0, 1.3, 10, R[1], R[2], R[3], 50, 33, false, false, true, nil, nil, 0.0, 0.0, 0.0)
    DrawSpecialText("Go to the waypoint on your map and enter your plane", 0.5, 0.08)
    t = u
    v.width = t.width
    w.width = t.width
    x.width = t.width / 2
    y.width = t.width / 2
    z.width = t.width
    z.x = 0.965
    A.x = z.x
    B.x = z.x
    C.x = z.x
    D.x = z.x - z.width / 2
    E.x = z.x + z.width / 2
    local S = a.fuelMultiplier
    SetVehicleFuelMultiplier(f, S)
    Citizen.CreateThread(function()
        while globalOnPilotDuty do
            Citizen.Wait(5)
            local T = GetVehicleFuelLevel(f)
            if T <= 10.0 then
                local U = a.refuelLocs
                local V = false
                for W = 1, #U, 1 do
                    if #(U[W].coords - VICE.getPlayerCoords()) < 10.0 then
                        V = true
                        if T < 100.0 then
                            local X = a.fuelStations[W].coords
                            tVICE.addMarker(X.x, X.y, X.z, 1.0, 1.0, 1.0, 10, 255, 81, 170, 50, 33, false, false, true, nil, nil, 0.0, 0.0, 0.0)
                            DrawSpecialText("Press ~INPUT_CONTEXT~ to refuel", 0.5, 0.08)
                            if IsControlJustPressed(0, 38) then
                                tVICE.deleteMarker()
                                local Y = GetEntityCoords(f)
                                local Z = GetEntityHeading(f)
                                SetEntityAsMissionEntity(f, false, true)
                                DeleteEntity(f)
                                f = VICE.spawnVehicle(K.spawnName, Y.x, Y.y, Y.z, Z, false, true, false)
                                SetVehicleColours(f, Q[1], Q[2])
                                SetVehicleDoorsLockedForAllPlayers(f, true)
                                SetVehicleEngineOn(f, true, false, false)
                                SetVehicleFuelLevel(f, 100.0)
                                TaskWarpPedIntoVehicle(PlayerPedId(), f, -1)
                            end
                            break
                        end
                    end
                end
                if not V then
                    tVICE.deleteMarker()
                end
            else
                tVICE.deleteMarker()
            end
        end
    end)
end)
