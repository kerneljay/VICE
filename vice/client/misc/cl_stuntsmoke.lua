local a = {
    [`red`] = {mod = 1, rgb = {255, 25, 25}},
    [`orange`] = {mod = 2, rgb = {255, 179, 25}},
    [`yellow`] = {mod = 3, rgb = {255, 255, 25}},
    [`green`] = {mod = 4, rgb = {102, 255, 25}},
    [`blue`] = {mod = 5, rgb = {25, 25, 255}},
    [`purple`] = {mod = 6, rgb = {179, 25, 255}},
    [`pink`] = {mod = 7, rgb = {255, 25, 255}},
    [`white`] = {mod = 8, rgb = {255, 255, 255}}
}

local b = {}
local c = {}

local function d(e)
    local f = DecorGetBool(e, "smokeActive")
    if f then 
        local g = DecorGetInt(e, "smokeType")
        local h = a[g]
        local i = c[e]
        if not i then 
            VICE.loadPtfx("scr_ar_planes")
            UseParticleFxAsset("scr_ar_planes")
            i = StartParticleFxLoopedOnEntityBone("scr_ar_trail_smoke", e, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1, 1.0, false, false, false)
            RemoveNamedPtfxAsset("scr_ar_planes")
            SetParticleFxLoopedFarClipDist(i, 1000.0)
            c[e] = i 
        end
        SetParticleFxLoopedScale(i, 1.0)
        SetParticleFxLoopedColour(i, h.rgb[1]/255+0.0, h.rgb[2]/255+0.0, h.rgb[3]/255+0.0, false)
    else 
        if c[e] then 
            StopParticleFxLooped(c[e], false)
            c[e] = nil 
        end 
    end 
end

Citizen.CreateThread(function()
    DecorRegister("smokeType", 3)
    DecorRegister("smokeActive", 2)
    while true do 
        for j, k in pairs(GetActivePlayers()) do 
            local l = GetPlayerPed(k)
            if l ~= 0 then 
                local m = GetVehiclePedIsUsing(l)
                if m ~= 0 then 
                    d(m)
                end 
            end 
        end
        for e, i in pairs(c) do 
            if not DoesEntityExist(e) then 
                StopParticleFxLooped(i, false)
                c[e] = nil 
            end 
        end
        Citizen.Wait(1000)
    end 
end)

RegisterCommand("setsmoke", function(n, o, p)
    local m, q = VICE.getPlayerVehicle()
    if m == 0 or not q then 
        return 
    end
    local r = GetEntityModel(m)
    if not b[r] then 
        notify("~r~You can not set the smoke colour of this vehicle")
        return 
    end
    if #o ~= 1 then 
        notify("~r~No smoke colour was specified")
        return 
    end
    local g = GetHashKey(o[1])
    if not a[g] then 
        notify("~r~The specified smoke colour does not exist")
        return 
    end
    if not b[r][tostring(a[g].mod)] == nil then 
        notify("~r~You have not purchased this colour in LS Customs")
        return 
    end
    DecorSetInt(m, "smokeType", g)
    d(m)
end, false)

RegisterCommand("togglesmoke", function()
    local m, q = VICE.getPlayerVehicle()
    if m == 0 or not q then 
        return 
    end
    if not IsThisModelAPlane(GetEntityModel(m)) then 
        return 
    end
    if DecorGetInt(m, "smokeType") == 0 then 
        notify("No smoke colour has been set or purchased for this vehicle")
        return 
    end
    local f = not DecorGetBool(m, "smokeActive")
    DecorSetBool(m, "smokeActive", f)
    d(m)
end, false)

RegisterKeyMapping("togglesmoke", "Toggle Plane Stunt Smoke", "KEYBOARD", "G")

function setVehicleIdPlaneSmoke(m, s, t)
    b[GetHashKey(s)] = t
    for u, v in pairs(t) do 
        if v == true then 
            for g, h in pairs(a) do 
                if h.mod == tonumber(u) then 
                    DecorSetInt(m, "smokeType", g)
                    break 
                end 
            end 
        end 
    end 
end