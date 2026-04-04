local a = module("cfg/cfg_lscustoms")
RMenu.Add(
    "stancer",
    "mainmenu",
    RageUI.CreateMenu("", "Stancer", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "lscustoms")
)
local b = {}
local function c(d, e)
    if d % 2 == 0 then
        return -e
    else
        return e
    end
end
local function f(g)
    if g.frontWidth then
        for d = 0, g.frontWheelCount - 1 do
            SetVehicleWheelXOffset(g.vehicle, d, c(d, g.frontWidth))
        end
    end
    if g.rearWidth then
        for d = g.frontWheelCount, g.wheelCount - 1 do
            SetVehicleWheelXOffset(g.vehicle, d, c(d, g.rearWidth))
        end
    end
    if g.frontCamber then
        for d = 0, g.frontWheelCount - 1 do
            SetVehicleWheelYRotation(g.vehicle, d, c(d, g.frontCamber))
        end
    end
    if g.rearCamber then
        for d = g.frontWheelCount, g.wheelCount - 1 do
            SetVehicleWheelYRotation(g.vehicle, d, c(d, g.rearCamber))
        end
    end
end
local function h(i)
    local j = i / 2
    if j % 2 ~= 0 then
        j = j - 1
    end
    return math.floor(j)
end
AddStateBagChangeHandler(
    "stancer",
    nil,
    function(k, l, e)
        local m = tonumber(stringsplit(k, ":")[2])
        local n = 0
        while true do
            if n > 25 then
                return
            elseif NetworkDoesEntityExistWithNetworkId(m) then
                local o = NetworkGetEntityFromNetworkId(m)
                if o ~= 0 then
                    local i = GetVehicleNumberOfWheels(o)
                    if i < 32 then
                        e.vehicle = o
                        e.wheelCount = i
                        e.frontWheelCount = h(e.wheelCount)
                        b[o] = e
                        break
                    end
                end
            end
            n = n + 1
            Citizen.Wait(200)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            local p = false
            for o, g in pairs(b) do
                if DoesEntityExist(o) and not RageUI.IsAnyMenuOfTypeVisible("stancer") then
                    f(g)
                else
                    b[o] = nil
                end
                p = true
            end
            Citizen.Wait(p and 0 or 1000)
        end
    end
)
local q = {}
local r = 0.0
local s = 0
local t = {}
local u = 0.0
local v = 0
local w = {}
local x = 0.0
local y = 0
local z = {}
local A = 0.0
local B = 0
local C = nil
local D = 0
local E = 0
local F = 10
local function G(H, I)
    if H and H[I] then
        for J, K in pairs(H[I]) do
            if K then
                return tonumber(J)
            end
        end
    end
    return F
end
local function L(M, N)
    local O = {}
    for P = -M, M do
        table.insert(O, string.format("%.3f", N * P))
    end
    return O
end
local function Q(o)
    r = math.abs(GetVehicleWheelXOffset(o, 0))
    local N = a.stancerLimits.frontWidth / F
    q = L(F, N)
end
local function R(o, S)
    u = math.abs(GetVehicleWheelXOffset(o, S))
    local N = a.stancerLimits.rearWidth / F
    t = L(F, N)
end
local function T(o)
    x = math.abs(GetVehicleWheelYRotation(o, 0))
    local N = a.stancerLimits.frontCamber / F
    w = L(F, N)
end
local function U(o, S)
    A = math.abs(GetVehicleWheelYRotation(o, S))
    local N = a.stancerLimits.rearCamber / F
    z = L(F, N)
end
local function V()
    local W = GetEntityModel(D)
    VICE.loadModel(W)
    local o = CreateVehicle(W, 0.0, 0.0, 0.0, 0.0, false, false)
    FreezeEntityPosition(o, true)
    local i = GetVehicleNumberOfWheels(o)
    if i > 32 then
        print("[LS Customs] Undefined result from GetVehicleNumberOfWheels in generateStancerLists")
        return
    end
    Q(o)
    R(o, i - 1)
    T(o)
    U(o, i - 1)
    DeleteEntity(o)
    SetModelAsNoLongerNeeded(W)
end
local function X()
    local i = GetVehicleNumberOfWheels(D)
    if i > 32 then
        print("[LS Customs] Undefined result from GetVehicleNumberOfWheels in previewWheelCamber")
        return
    end
    f(
        {
            vehicle = D,
            wheelCount = i,
            frontWheelCount = h(i),
            frontWidth = r + tonumber(q[s]),
            rearWidth = u + tonumber(t[v]),
            frontCamber = x + tonumber(w[y]),
            rearCamber = A + tonumber(z[B])
        }
    )
end
AddEventHandler(
    "VICE:lsCustomsOpenExternalMenu",
    function(Y, o, Z, _)
        if Y ~= "stancer" then
            return
        end
        D = o
        E = Z
        C = _
        local H = C["stancer"]
        s = G(H, "frontWidth")
        v = G(H, "rearWidth")
        y = G(H, "frontCamber")
        B = G(H, "rearCamber")
        V()
    end
)
RegisterNetEvent(
    "VICE:setSpecificOwnedUpgrade",
    function(J, e)
        if C then
            C[J] = e
        end
    end
)
local function a0(I, a1)
    local H = C["stancer"]
    if not H or not H[I] or table.count(H[I]) == 0 then
        local a2 = {RightLabel = "£" .. getMoneyStringFormatted(a.stancerPrices[I])}
        RageUI.ButtonWithStyle(
            a1,
            nil,
            a2,
            true,
            function(a3, a4, a5)
                if a5 then
                    TriggerServerEvent("VICE:stancerBuyMod", E, I)
                end
            end
        )
    else
        return true
    end
end
RageUI.CreateWhile(
    1.0,
    RMenu:Get("stancer", "mainmenu"),
    function()
        RageUI.IsVisible(
            RMenu:Get("stancer", "mainmenu"),
            true,
            true,
            true,
            function()
                X()
                if a0("frontWidth", "Front Track Width") then
                    RageUI.List(
                        "Front Track Width",
                        q,
                        s,
                        nil,
                        {},
                        true,
                        function(a3, a4, a5, a6)
                            if a6 ~= s then
                                s = a6
                                TriggerServerEvent("VICE:stancerSetModIndex", E, "frontWidth", a6)
                            end
                        end
                    )
                end
                if a0("rearWidth", "Rear Track Width") then
                    RageUI.List(
                        "Rear Track Width",
                        t,
                        v,
                        nil,
                        {},
                        true,
                        function(a3, a4, a5, a6)
                            if a6 ~= v then
                                v = a6
                                TriggerServerEvent("VICE:stancerSetModIndex", E, "rearWidth", a6)
                            end
                        end
                    )
                end
                if a0("frontCamber", "Front Camber") then
                    RageUI.List(
                        "Front Camber",
                        w,
                        y,
                        nil,
                        {},
                        true,
                        function(a3, a4, a5, a6)
                            if a6 ~= y then
                                y = a6
                                TriggerServerEvent("VICE:stancerSetModIndex", E, "frontCamber", a6)
                            end
                        end
                    )
                end
                if a0("rearCamber", "Rear Camber") then
                    RageUI.List(
                        "Rear Camber",
                        z,
                        B,
                        nil,
                        {},
                        true,
                        function(a3, a4, a5, a6)
                            if a6 ~= B then
                                B = a6
                                TriggerServerEvent("VICE:stancerSetModIndex", E, "rearCamber", a6)
                            end
                        end
                    )
                end
            end
        )
    end
)
local function a7(M, N)
    local O = {}
    for P = -M, M do
        table.insert(O, N * P)
    end
    return O
end
local function a8()
    local N = a.stancerLimits.frontWidth / F
    return a7(F, N)
end
local function a9()
    local N = a.stancerLimits.rearWidth / F
    return a7(F, N)
end
local function aa()
    local N = a.stancerLimits.frontCamber / F
    return a7(F, N)
end
local function ab()
    local N = a.stancerLimits.rearCamber / F
    return a7(F, N)
end
function setVehicleIdStancer(ac, H)
    local e = {}
    local i = GetVehicleNumberOfWheels(ac)
    if i > 32 then
        print("[LS Customs] Undefined result from GetVehicleNumberOfWheels in setVehicleIdStancer")
        return
    end
    local ad = GetVehicleWheelXOffset(ac, 0)
    local ae = GetVehicleWheelXOffset(ac, i - 1)
    local af = GetVehicleWheelYRotation(ac, 0)
    local ag = GetVehicleWheelYRotation(ac, i - 1)
    if Entity(ac).state.stancer then
        D = ac
        V()
        ad = r
        ae = u
        af = x
        ag = A
    end
    local ah = G(H, "frontWidth")
    if ah ~= F then
        e.frontWidth = math.abs(ad) + a8()[ah]
    end
    local ai = G(H, "rearWidth")
    if ai ~= F then
        e.rearWidth = math.abs(ae) + a9()[ai]
    end
    local aj = G(H, "frontCamber")
    if aj ~= F then
        e.frontCamber = math.abs(af) + aa()[aj]
    end
    local ak = G(H, "rearCamber")
    if ak ~= F then
        e.rearCamber = math.abs(ag) + ab()[ak]
    end
    local al = false
    if not NetworkGetEntityIsNetworked(ac) or NetworkGetNetworkIdFromEntity(ac) == 0 then
        al = true
    end
    Citizen.CreateThread(
        function()
            Citizen.Wait(al and 2500 or 0)
            local m = NetworkGetNetworkIdFromEntity(ac)
            TriggerServerEvent("VICE:stancerSetState", m, e)
        end
    )
end
