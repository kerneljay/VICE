function VICE.loadClipSet(u)
    if not HasClipSetLoaded(u) then
        RequestClipSet(u)
        while not HasClipSetLoaded(u) do
            Wait(0)
        end
    end
end
function VICE.loadPtfx(u)
    if not HasNamedPtfxAssetLoaded(u) then
        RequestNamedPtfxAsset(u)
        while not HasNamedPtfxAssetLoaded(u) do
            Wait(0)
        end
    end
    UseParticleFxAsset(u)
end
function VICE.getStreetNameAtCoord(v, w, H)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(v, w, H))
end
Citizen.CreateThread(function()
    if not HasStreamedTextureDictLoaded("timerbars") then
        RequestStreamedTextureDict("timerbars")
        while not HasStreamedTextureDictLoaded("timerbars") do
            Wait(0)
        end
    end
end)
local a = module("cfg/cfg_attachments") or {attachments = {}}
function VICE.loadWeaponAsset(U)
    local U = GetHashKey(U)
    RequestWeaponAsset(U, 31, 0)
    while not HasWeaponAssetLoaded(U) do
        Wait(0)
    end
    return U
end
function VICE.spawnWeaponObject(E, B, C, D)
    local V = VICE.loadWeaponAsset(E)
    local W = CreateWeaponObject(V, 0, B, C, D, true, 0, 0)
    return W
end
function getAllWeaponAttachments(E, F)
    local G = PlayerPedId()
    local H = {}
    if F then
        for I, J in pairs(a.attachments) do
            if HasPedGotWeaponComponent(G, E, GetHashKey(J)) and not table.has(givenAttachmentsToRemove[E] or {}, J) then
                table.insert(H, J)
            end
        end
    else
        for I, J in pairs(a.attachments) do
            if HasPedGotWeaponComponent(G, E, GetHashKey(J)) then
                table.insert(H, J)
            end
        end
    end
    return H
end
function DrawGTAText(A, v, w, aa, ab, ac, r, g, b, a)
    SetTextFont(0)
    SetTextScale(aa, aa)
    SetTextColour(r or 254, g or 254, b or 254, a or 255)
    if ab then
        SetTextWrap(v - ac, v)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(A)
    EndTextCommandDisplayText(v, w)
end
function DrawGTATimerBar(ad, A, ae, r, g, b, a)
    local ac = 0.17
    local af = -0.01
    local ag = 0.038
    local ah = 0.008
    local ai = 0.005
    local aj = 0.32
    local ak = -0.04
    local al = 0.014
    local am = GetSafeZoneSize()
    local an = al + am - ac + ac / 2
    local ao = ak + am - ag + ag / 2 - (ae - 1) * (ag + ai)
    DrawSprite("timerbars", "all_black_bg", an, ao, ac, 0.038, 0, 0, 0, 0, 128)
    DrawGTAText(ad, am - ac + 0.06, ao - ah, aj)
    DrawGTAText(string.upper(A), am - af, ao - 0.0175, 0.5, true, ac / 2, r, g, b, a)
end
function GetPlayers()
    local a7 = {}
    for o, j in ipairs(GetActivePlayers()) do
        table.insert(a7, j)
    end
    return a7
end
function GetClosestPlayer(ap)
    local a7 = GetPlayers()
    local aq = -1
    local ar = -1
    local as = PlayerPedId()
    local at = GetEntityCoords(as, 0)
    for o, c in ipairs(a7) do
        local au = GetPlayerPed(c)
        if au ~= as then
            local av = GetEntityCoords(GetPlayerPed(c), 0)
            local aw = #(av - at)
            if aq == -1 or aq > aw then
                ar = c
                aq = aw
            end
        end
    end
    if aq <= ap then
        return ar
    else
        return nil
    end
end
function VICE.randomNum(d, e)
    math.randomseed(GetGameTimer() * math.random() * 2)
    return math.random(d, e)
end
soundEventCode = 0
TriggerServerEvent("VICE:soundCodeServer")
RegisterNetEvent("VICE:soundCode",function(aH)
    soundEventCode = aH
end)
RegisterNetEvent("VICE:playClientNuiSound",function(aI, aJ, ap) -- use for cuffing and other sounds in areas
    local ax = VICE.getPlayerCoords()
    if #(ax - aI) <= ap then
        SendNUIMessage({transactionType = aJ})
    end
end)
function VICE.getNetId(aW, aX)
    if aX == nil then
        aX = ""
    end
    local aY = 0
    local aZ = DoesEntityExist(aW)
    if not aZ then
        tVICE.debugLog(string.format("no such entity %s", aX))
    else
        aY = NetworkGetNetworkIdFromEntity(aW)
        if aY == aW then
            tVICE.debugLog(string.format("no such networked entity %s", aX))
        end
    end
    return aY
end
function VICE.getObjectId(a_, aX)
    if aX == nil then
        aX = ""
    end
    local aL = 0
    local b0 = NetworkDoesNetworkIdExist(a_)
    if not b0 then
        tVICE.debugLog(string.format("no object by ID %s\n%s", a_, aX))
    else
        local b1 = NetworkGetEntityFromNetworkId(a_)
        aL = b1
    end
    return aL
  end
  local aT = {}
  local aU = {}
  Citizen.CreateThread(function()
    local a = module("VICEVeh", "cfg_garages")
    for aV, J in pairs(a.garages) do
        for aW, aX in pairs(J) do
            if aV ~= "_config" then
                local aY = aX[1]
                local aZ = string.lower(aW)
                if not aT[aZ] then
                    aT[aZ] = {name = aY, garageType = aV}
                    aU[GetHashKey(aZ)] = aZ
                end
            end
        end
    end
end)
function VICE.getVehicleNameFromId(aZ)
    if aT[string.lower(aZ)] then
        return aT[string.lower(aZ)].name
    end
    return ""
end
function VICE.getGarageNameFromId(aZ)
    return aT[string.lower(aZ)].garageType
end
function VICE.getVehicleIdFromModel(s)
    return aU[s]
end
local a_ = math.rad
local b0 = math.cos
local b1 = math.sin
local b2 = math.abs
function VICE.rotationToDirection(b3)
    local B = a_(b3.x)
    local D = a_(b3.z)
    return vector3(-b1(D) * b2(b0(B)), b0(D) * b2(b0(B)), b1(B))
end
zz_z = Wait