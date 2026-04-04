local a = module("cfg/cfg_clothing")
local function b(c)
    if type(c) == "string" and string.sub(c, 1, 1) == "p" then
        return true, tonumber(string.sub(c, 2))
    else
        return false, tonumber(c)
    end
end
function VICE.getDrawables(d)
    local e, f = b(d)
    if e then
        return GetNumberOfPedPropDrawableVariations(PlayerPedId(), f)
    else
        return GetNumberOfPedDrawableVariations(PlayerPedId(), f)
    end
end
function VICE.getDrawableTextures(d, g)
    local e, f = b(d)
    if e then
        return GetNumberOfPedPropTextureVariations(PlayerPedId(), f, g)
    else
        return GetNumberOfPedTextureVariations(PlayerPedId(), f, g)
    end
end
function tVICE.getCustomization()
    local h = PlayerPedId()
    local i = {}
    i.modelhash = GetEntityModel(h)
    for j = 0, 20 do
        i[j] = {GetPedDrawableVariation(h, j), GetPedTextureVariation(h, j), GetPedPaletteVariation(h, j)}
    end
    for j = 0, 10 do
        i["p" .. j] = {GetPedPropIndex(h, j), math.max(GetPedPropTextureIndex(h, j), 0)}
    end
    return i
end
local k = false
local l = 0
function tVICE.setCustomization(i, m, n)
    if i and type(i) == "table" then
        local o = tVICE.getArmour()
        local h = PlayerPedId()
        local p = nil
        if i.modelhash then
            p = i.modelhash
        elseif i.model then
            p = GetHashKey(i.model)
        end
        local q = VICE.loadModel(p)
        local r = GetEntityModel(h)
        if q then
            if r ~= q or m then
                k = true
                local s = tVICE.getWeapons()
                local t = GetEntityHealth(h)
                SetPlayerModel(PlayerId(), p)
                Wait(0)
                tVICE.giveWeapons(s, true,decorpasskey)
                if n == nil or n == false then
                    print("[VICE] Customisation, setting health to ", t)
                    tVICE.setHealth(t)
                end
                TriggerServerEvent("VICE:getPlayerHairstyle")
                TriggerServerEvent("VICE:getPlayerTattoos")
                h = PlayerPedId()
            end
            SetModelAsNoLongerNeeded(p)
            for u, v in pairs(i) do
                if u ~= "model" and u ~= "modelhash" then
                    if tonumber(u) then
                        u = tonumber(u)
                    end
                    local e, f = b(u)
                    if e then
                        if v[1] < 0 then
                            ClearPedProp(h, f)
                        else
                            SetPedPropIndex(h, f, v[1], v[2], v[3] or 2)
                        end
                    else
                        SetPedComponentVariation(h, f, v[1], v[2], v[3] or 2)
                    end
                end
            end
            k = false
            l = GetGameTimer()
        else
            print("[VICE] Failed to load model", p)
        end
        tVICE.setArmour(o)
    else
        print("[VICE] Invalid customization data provided")
    end
end
function VICE.isPedScriptGuidChanging()
    return k or GetGameTimer() - l < 3000
end
function VICE.loadCustomisationPreset(w)
    local x = a.presets[w]
    assert(x, string.format("Preset %s does not exist.", w))
    if x.model then
        tVICE.setCustomization({modelhash = x.model})
        Citizen.Wait(100)
    end
    local y = PlayerPedId()
    if x.components then
        for z, A in pairs(x.components) do
            SetPedComponentVariation(y, z, A[1], A[2], A[3])
        end
    end
    if x.props then
        for B, C in pairs(x.props) do
            SetPedPropIndex(y, B, C[1], C[2], C[3])
        end
    end
end
SetVisualSettingFloat("ped.lod.distance.high", 200.0)
SetVisualSettingFloat("ped.lod.distance.medium", 400.0)
SetVisualSettingFloat("ped.lod.distance.low", 700.0)
