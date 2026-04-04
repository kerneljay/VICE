RMenu.Add("vicescenemenu","main",RageUI.CreateMenu("","VICE Traffic Scene Menu",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","scenemenu"))
RMenu.Add("vicescenemenu","objects",RageUI.CreateSubMenu(RMenu:Get("vicescenemenu", "main"),"","~s~S~w~pawn Objects",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","scenemenu"))
RMenu.Add("vicescenemenu","speedZone",RageUI.CreateSubMenu(RMenu:Get("vicescenemenu", "main"),"","~s~S~w~et a speed zone",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","scenemenu"))
RMenu.Add("vicescenemenu","spikes",RageUI.CreateSubMenu(RMenu:Get("vicescenemenu", "main"),"","~s~S~w~et a spike trap",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","scenemenu"))
local b = {}
local c = {}
local d = {object = 1, speedRad = 1, speed = 1, amount = 1, seperation = 1, degrees = 1, previewObjects = {}}
TriggerEvent("chat:addSuggestion", "/trafficmenu", "Open the traffic scene menu")
local e = {"0", "25", "50", "75", "100", "125", "150", "175", "200"}
local f = {"0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50"}
local g = {1, 2, 3, 4, 5}
local h = {3, 6, 9, 12, 15}
local i = {0, 45, 90, 135, 190, 235, 270, 315}
local j = {}
local k = {
    {"Police Slow", "prop_barrier_slow", true, 0.05},
    {"Police No Entry", "prop_barrier_noentry", true, 0.05},
    {"Police Incident Ahead", "prop_barrier_incident", true, 0.05},
    {"Police Checkpoint", "prop_barrier_checkpoint", true, 0.05},
    {"Police Collision", "prop_barrier_collision", true, 0.05},
    {"NHS Incident Ahead", "prop_barrier_nhsincident", true, 0.05},
    {"Diagonal Left", "prop_barrier_diagonalleft", true, 0.05},
    {"Diagonal Right", "prop_barrier_diagonalright", true, 0.05},
    {"Big Cone", "prop_roadcone01a", true},
    {"Gazebo", "prop_gazebo_02", true},
    {"Worklight", "prop_worklight_03b", true},
    {"Gate Barrier", "ba_prop_battle_barrier_02a", true},
    {"Fence Transparent", "prop_fncsec_03b", true, -0.45},
    {"Fence Hidden", "prop_fncsec_03d", true},
    {"Plastic Fence", "prop_barrier_work06a", true}
}
local l = {
    {bone = "wheel_lf", index = 0},
    {bone = "wheel_rf", index = 1},
    {bone = "wheel_lm", index = 2},
    {bone = "wheel_rm", index = 3},
    {bone = "wheel_lr", index = 4},
    {bone = "wheel_rr", index = 5}
}
local m = {}
for n, o in pairs(k) do
    m[n] = o[1]
end
local p
local q
local function r(s, t, u, v, w, x)
    local y = VICE.getPlayerPed()
    local z = GetEntityHeading(y)
    local A = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * (3.0 + h[d.seperation] * (x - 1))
    local B = VICE.loadModel(s)
    local C = CreateObject(B, A.x, A.y, A.z, w, false)
    if t then
        FreezeEntityPosition(C, true)
    end
    PlaceObjectOnGroundProperly(C)
    if u then
        local D = GetEntityCoords(C, true)
        SetEntityCoords(C, D.x, D.y, D.z + u, true, true, true, true)
    end
    SetEntityHeading(C, z + i[d.degrees])
    if v then
        SetEntityAlpha(C, v, false)
    end
    SetModelAsNoLongerNeeded(B)
    table.insert(b, C)
    return C
end
local function E()
    for F, s in pairs(d.previewObjects) do
        DeleteEntity(s)
    end
    d.previewObjects = {}
end
local function G()
    E()
    local H = k[d.object]
    local I = g[d.amount]
    for J = 1, I do
        local s = r(H[2], H[3], H[4], 155, false, J)
        table.insert(d.previewObjects, s)
    end
end

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('vicescenemenu', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            E()
            RageUI.ButtonWithStyle("Object Menu",nil,{RightLabel = "→→→"},true,function(K, L, M)
            end,RMenu:Get("vicescenemenu", "objects"))
            RageUI.ButtonWithStyle("Speed Zone",nil,{RightLabel = "→→→"},true,function(K, L, M)
            end,RMenu:Get("vicescenemenu", "speedZone"))
            if VICE.globalOnPoliceDuty() then
                RageUI.ButtonWithStyle("Spike Strip Menu",nil,{RightLabel = "→→→"},true,function(K, L, M)
                end,RMenu:Get("vicescenemenu", "spikes"))
            end
            RageUI.ButtonWithStyle("Close Menu",nil,{RightLabel = "→→→"},true,function(K, L, M)
                if M then
                    RageUI.Visible(RMenu:Get("vicescenemenu", "main"), false)
                end
            end)
        end)
    end
    if RageUI.Visible(RMenu:Get('vicescenemenu', 'objects')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.List("Spawn Object",m,d.object,nil,{},true,function(K, L, M, N)
                if M then
                    E()
                    local H = k[d.object]
                    local I = g[d.amount]
                    for J = 1, I do
                        r(H[2], H[3], H[4], nil, true, J)
                    end
                    G()
                end
                if L and d.object ~= N then
                    d.object = N
                    G()
                end
            end)
            RageUI.List("Number To Place",g,d.amount,"",{},true,function(K, L, M, N)
                if L and d.amount ~= N then
                    d.amount = N
                    G()
                end
            end)
            RageUI.List("Seperation (m)",h,d.seperation,"",{},true,function(K, L, M, N)
                if L and d.seperation ~= N then
                    d.seperation = N
                    G()
                end
            end)
            RageUI.List("Rotation (degrees)",i,d.degrees,"",{},true,function(K, L, M, N)
                if L and d.degrees ~= N then
                    d.degrees = N
                    G()
                end
            end)
            RageUI.ButtonWithStyle("Delete Object",nil,{RightLabel = "→→→"},true,function(K, L, M)
                if M then
                    deleteObject()
                end
            end)
            RageUI.ButtonWithStyle("Delete All Objects","Deletes all objects you have placed",{RightLabel = "→→→"},true,function(K, L, M)
                if M then
                    clearAllObjects()
                end
            end)
            local H = k[d.object]
            for J, s in pairs(d.previewObjects) do
                if DoesEntityExist(s) then
                    local O = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * (3.0 + h[d.seperation] * (J - 1))
                    if H[4] then
                        local P = H[4]
                        SetEntityCoordsNoOffset(s, O.x, O.y, O.z)
                        PlaceObjectOnGroundProperly(s)
                        local D = GetEntityCoords(s, true)
                        SetEntityCoordsNoOffset(s, D.x, D.y, D.z + P)
                    else
                        SetEntityCoordsNoOffset(s, O.x, O.y, O.z)
                        PlaceObjectOnGroundProperly(s)
                    end
                    SetEntityNoCollisionEntity(s, PlayerPedId(), true)
                    SetEntityNoCollisionEntity(PlayerPedId(), s, true)
                    SetEntityHeading(s, GetEntityHeading(PlayerPedId()) + i[d.degrees])
                end
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('vicescenemenu', 'speedZone')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.List("Radius",e,d.speedRad,nil,{},true,function(K, L, M, N)
                if L then
                    d.speedRad = N
                    p = tonumber(e[N])
                end
            end)
            RageUI.List("Speed",f,d.speed,nil,{},true,function(K, L, M, N)
                if L then
                    d.speed = N
                    q = tonumber(f[N])
                end
            end)
            RageUI.ButtonWithStyle("Create Speedzone",nil,{},true,function(K, L, M)
                if M then
                    if p == 0 then
                        VICE.notify("~r~Please set a radius")
                    elseif q == 0 then
                        VICE.notify("~r~Please set a speed")
                    else
                        TriggerServerEvent("VICE:createSpeedZone", VICE.getPlayerCoords(), q + 0.0, p + 0.0)
                        VICE.notify("~r~Speed zone created")
                    end
                end
            end,nil)
            RageUI.ButtonWithStyle("Delete Speedzone",nil,{},true,function(K, L, M)
                if M then
                    local Q = VICE.getPlayerCoords()
                    local R = nil
                    local S = 250.0
                    for T, U in pairs(j) do
                        local V = #(Q - U.position)
                        if V < S and V < U.radius then
                            R = T
                            S = V
                        end
                    end
                    if R then
                        TriggerServerEvent("VICE:deleteSpeedZone", R)
                        VICE.notify("~g~Speed zone removed")
                    end
                end
            end,nil)
        end)
    end
    if RageUI.Visible(RMenu:Get('vicescenemenu', 'spikes')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.ButtonWithStyle("Place Spike",nil,{},true,function(K, L, M)
                if M then
                    placeSpike()
                end
            end)
            RageUI.ButtonWithStyle("Delete Spike",nil,{},true,function(K, L, M)
                if M then
                    deleteSpike()
                end
            end)
        end)
    end
end)

RegisterNetEvent("VICE:toggleTrafficMenu",function()
    RageUI.Visible(RMenu:Get("vicescenemenu", "main"), not RageUI.Visible(RMenu:Get("vicescenemenu", "main")))
    if globalOnPoliceDuty and VICE.hasPoliceCallsign() then
        RMenu:Get("vicescenemenu", "main"):SetSubtitle("MPD~w~: " .. tVICE.getPoliceCallsign() .. " - " .. tVICE.getPoliceRank() .. " - " .. VICE.getPoliceName())
    elseif globalNHSOnDuty then 
        RMenu:Get("vicescenemenu", "main"):SetSubtitle("NHS Scene management")
    end
end)

function deleteObject()
    for n, o in pairs(k) do
        local W = o[2]
        local X = GetHashKey(W)
        local Y, Z, _ = table.unpack(GetEntityCoords(VICE.getPlayerPed(), true))
        if DoesObjectOfTypeExistAtCoords(Y, Z, _, 0.9, X, true) then
            local a0 = GetClosestObjectOfType(Y, Z, _, 0.9, X, false, false, false)
            if NetworkGetEntityIsNetworked(a0) and not NetworkHasControlOfEntity(a0) then
                local a1 = VICE.getNetId(a0, "deleteObject()")
                if a1 ~= 0 then
                    TriggerServerEvent("VICE:requestSceneObjectDelete", a1)
                end
            else
                DeleteObject(a0)
            end
        end
    end
end
function clearAllObjects()
    Citizen.CreateThread(function()
        for n, a2 in pairs(b) do
            if DoesEntityExist(a2) then
                if NetworkGetEntityIsNetworked(a2) then
                    local a3 = NetworkGetNetworkIdFromEntity(a2)
                    if a3 ~= 0 then
                        TriggerServerEvent("VICE:requestSceneObjectDelete", a3)
                    end
                else
                    DeleteEntity(a2)
                end
            end
        end
        b = {}
    end)
end
function placeSpike()
    local a4 = VICE.getPlayerVehicle()
    if a4 == 0 then
        local a5 = "P_ld_stinger_s"
        local a6 = VICE.getPlayerPed()
        local Q = GetEntityCoords(a6)
        local C = CreateObject(a5, Q.x, Q.y, Q.z, true, true, true)
        SetEntityHeading(C, GetEntityHeading(a6))
        DecorSetInt(C, decor, 955)
        PlaceObjectOnGroundProperly(C)
        local a7 = NetworkGetNetworkIdFromEntity(C)
        TriggerServerEvent("VICE:placeSpike", a7, Q)
    end
end
function getClosetSpike(Q)
    for n, o in pairs(c) do
        if #(o[1] - Q) <= 3.50 then
            return o
        end
    end
    return nil
end
function deleteSpike()
    local Q = GetEntityCoords(VICE.getPlayerPed())
    local a8 = getClosetSpike(Q)
    if a8 then
        TriggerServerEvent("VICE:removeSpike", a8[2])
    end
end
RegisterNetEvent("VICE:addSpike",function(Q, a7)
    c[a7] = {Q, a7}
end)
RegisterNetEvent("VICE:deleteSpike",function(a7)
    c[a7] = nil
end)
local a9 = 1
Citizen.CreateThread(function()
    while true do
        local a6 = VICE.getPlayerPed()
        local Q = GetEntityCoords(a6)
        for n, o in pairs(c) do
            local aa = o[1]
            if #(aa - Q) <= 5.00 then
                a9 = n
            end
        end
        Citizen.Wait(150)
    end
end)
Citizen.CreateThread(function()
    while true do
        local a6 = VICE.getPlayerPed()
        if IsPedInAnyVehicle(a6, true) then
            local ab = GetVehiclePedIsIn(a6, false)
            if c[a9] then
                for ac = 1, #l do
                    local ad = GetWorldPositionOfEntityBone(ab, GetEntityBoneIndexByName(ab, l[ac].bone))
                    local a8 = c[a9]
                    if #(ad - a8[1]) <= 3.6 then
                        if not IsVehicleTyreBurst(ab, l[ac].index, true) or IsVehicleTyreBurst(ab, l[ac].index, false) then
                            SetVehicleTyreBurst(ab, l[ac].index, false, 1000.0)
                            TriggerServerEvent("VICE:removeSpike", a8[2])
                        end
                    end
                end
            end
        end
        Citizen.Wait(150)
    end
end)

local af = false
local ag = 1000.0
function convertSpeed(q)
    return q * 10 * 0.44704 - 0.5
end
Citizen.CreateThread(function()
    while true do
        local a4, ah = VICE.getPlayerVehicle()
        if a4 ~= 0 and ah then
            local ai = false
            local aj = 1000.0
            local A = VICE.getPlayerCoords()
            for F, U in pairs(j) do
                if #(U.position - A) < U.radius then
                    ai = true
                    if U.speed < aj then
                        aj = U.speed
                    end
                end
            end
            if ai then
                if not af or ag ~= aj then
                    SetVehicleMaxSpeed(a4, aj / 2.236936)
                    af = true
                    ag = aj
                end
                drawNativeNotification("Hold up! There is a temporary ~r~speed restriction ~w~in this area.")
            else
                if af then
                    SetVehicleMaxSpeed(a4, -1.0)
                    af = false
                    ag = 1000.0
                end
            end
        end
        Wait(0)
    end
end)
RegisterNetEvent("VICE:createSpeedZone",function(T, ak, q, p)
    local al = AddBlipForRadius(ak.x, ak.y, ak.z, p)
    SetBlipColour(al, 26)
    SetBlipAlpha(al, 120)
    local am = AddSpeedZoneForCoord(ak.x, ak.y, ak.z, p, q, false)
    j[T] = {position = ak, speed = q, radius = p, blip = al, zone = am}
end)
RegisterNetEvent("VICE:deleteSpeedZone",function(T)
    local U = j[T]
    if U then
        RemoveBlip(U.blip)
        RemoveSpeedZone(U.zone)
        j[T] = nil
    end
end)
