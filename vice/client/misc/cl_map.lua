globalBlips = {}
local k = {}

function VICE.addBlip(a, b, c, d, e, f, g, h)
    local i = AddBlipForCoord(a + 0.001, b + 0.001, c + 0.001)
    SetBlipSprite(i, d)
    SetBlipAsShortRange(i, false)
    SetBlipColour(i, e)
    if d == 403 or d == 431 or d == 365 or d == 85 or d == 140 or d == 60 or d == 44 or d == 110 or d == 315 then
        SetBlipScale(i, 1.1)
    elseif d == 50 then
        SetBlipScale(i, 0.7)
    else
        SetBlipScale(i, 0.8)
    end
    SetBlipScale(i, g or 0.8)
    SetBlipDisplay(i, 3)
    SetBlipCategory(i, 1)
    BeginTextCommandSetBlipName("STRING")
    if f ~= nil then
        AddTextComponentSubstringPlayerName(f)
    else
        AddTextComponentSubstringPlayerName("Location")
    end
    EndTextCommandSetBlipName(i)
    SetBlipHiddenOnLegend(i, false)
    SetBlipPriority(i, 1)
    table.insert(globalBlips, i)
    return i
end

function VICE.removeBlip(j)
    RemoveBlip(j)
end

function VICE.setNamedBlip(l, a, b, c, d, e, f, g)
    VICE.removeNamedBlip(l)
    k[l] = VICE.addBlip(a, b, c, d, e, f, g)
    return k[l]
end

function VICE.removeNamedBlip(l)
    if k[l] ~= nil then
        RemoveBlip(k[l])
        k[l] = nil
    end
end

local m = {}
local n = Tools.newIDGenerator()
local o = {}
local p = {}
local q = {}
function VICE.addMarker(a, b, c, r, s, t, u, v, w, x, y, z, A, B, C, D, E, F, G, H)
    local I = {
        position = vector3(a, b, c),
        sx = r,
        sy = s,
        sz = t,
        r = u,
        g = v,
        b = w,
        a = x,
        visible_distance = y,
        mtype = z,
        faceCamera = A,
        bopUpAndDown = B,
        rotate = C,
        textureDict = D,
        textureName = E,
        xRot = F,
        yRot = G,
        zRot = H
    }
    if I.sx == nil then
        I.sx = 2.0
    end
    if I.sy == nil then
        I.sy = 2.0
    end
    if I.sz == nil then
        I.sz = 0.7
    end
    if I.r == nil then
        I.r = 0
    end
    if I.g == nil then
        I.g = 155
    end
    if I.b == nil then
        I.b = 255
    end
    if I.a == nil then
        I.a = 200
    end
    I.sx = I.sx + 0.001
    I.sy = I.sy + 0.001
    I.sz = I.sz + 0.001
    if I.visible_distance == nil then
        I.visible_distance = 150
    end
    local j = n:gen()
    m[j] = I
    q[j] = I
    return j
end

function VICE.removeMarker(j)
    if m[j] ~= nil then
        m[j] = nil
        n:free(j)
    end
    if q[j] then
        q[j] = nil
    end
end

local J = {}
Citizen.CreateThread(function()
    while true do
        for K, L in pairs(p) do
            if J[K] then
                if J[K] <= L.visible_distance then
                    if L.mtype == nil then
                        L.mtype = 1
                    end
                    DrawMarker(L.mtype,L.position.x,L.position.y,L.position.z,0.0,0.0,0.0,L.xRot,L.yRot,L.zRot,L.sx,L.sy,L.sz,L.r,L.g,L.b,L.a,L.bopUpAndDown,L.faceCamera,2,L.rotate,L.textureDict,L.textureName,false)
                end
            end
        end
        Wait(1)
    end
end)
Citizen.CreateThread(function()
    while true do
        local coords = VICE.getPlayerCoords()
        J = {}
        for K, L in pairs(q) do
            J[K] = #(L.position - coords)
            if J[K] <= L.visible_distance and (not L.textureDict or HasStreamedTextureDictLoaded(L.textureDict)) then
                p[K] = L
            else
                p[K] = nil
            end
        end
        Citizen.Wait(250)
    end
end)
Citizen.CreateThread(function()
    while true do
        q = VICE.getNearbyMarkers()
        Citizen.Wait(10000)
    end
end)

function VICE.getNearbyMarkers()
    local N = {}
    local O = VICE.getPlayerCoords()
    local P = 0
    for K, L in pairs(m) do
        if #(L.position - O) <= 250.0 then
            N[K] = L
        end
        P = P + 1
        if P % 25 == 0 then
            Wait(0)
        end
    end
    return N
end
local Q = {}
local R = {}
local S = false
function VICE.getNearbyAreas()
    local T = {}
    local coords = VICE.getPlayerCoords()
    local P = 0
    for K, L in pairs(Q) do
        if #(L.position - coords) <= 250.0 or L.radius > 250 then
            T[K] = L
        end
        P = P + 1
        if not S then
            if P % 25 == 0 then
                Wait(0)
            end
        end
    end
    return T
end
function VICE.createArea(l, X, U, V, Y, Z, _, a0)
    local W = {position = X, radius = U, height = V, enterArea = Y, leaveArea = Z, onTickArea = _, metaData = a0}
    if W.height == nil then
        W.height = 6
    end
    Q[l] = W
    R[l] = W
end
function VICE.removeArea(l)
    if Q[l] then
        Q[l] = nil
    end
end

function VICE.useIncreasedAreaRefreshRate(a1)
    S = a1
end

Citizen.CreateThread(function()
    while true do
        local coords = VICE.getPlayerCoords()
        for _, a3 in pairs(R) do
            local a4 = #(a3.position - coords)
            local a5 = a4 <= a3.radius and math.abs(coords.z - a3.position.z) <= a3.height
            a3.distance = a4
            if a3.player_in and not a5 then
                if a3.leaveArea then
                    if a3.metaData == nil then
                        a3.metaData = {}
                    end
                    a3.leaveArea(a3.metaData)
                end
            elseif not a3.player_in and a5 then
                if a3.enterArea then
                    if a3.metaData == nil then
                        a3.metaData = {}
                    end
                    a3.enterArea(a3.metaData)
                end
            end
            a3.player_in = a5
        end
        Wait(0)
    end
end)
Citizen.CreateThread(function()
    while true do
        for _,A in pairs(R) do
            if A.player_in and A.onTickArea then
                if A.metaData == nil then
                    A.metaData = {}
                end
                A.metaData.distance = A.distance
                A.onTickArea(A.metaData)
            end
        end
        Wait(0)
    end
end)
Citizen.CreateThread(function()
    while true do
        R = VICE.getNearbyAreas()
        Citizen.Wait(S and 1000 or 5000)
    end
end)