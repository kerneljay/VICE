local a = module("cfg/weapons")
Citizen.CreateThread(
    function()
        for b, c in pairs(a.weapons) do
            AddTextEntry(b, c.name)
        end
    end
)
allowedWeapons = {}
weapons = module("cfg/weapons")
function VICE.allowWeapon(d, e)
    if e == nil then
        e = 0
    end
    if allowedWeapons[d] then
        allowedWeapons[d].ammo = allowedWeapons[d].ammo or 0
        allowedWeapons[d] = {ammo = allowedWeapons[d].ammo + e, setFrame = GetFrameCount()}
    else
        allowedWeapons[d] = {ammo = e, setFrame = GetFrameCount()}
    end
end
function tVICE.removeWeapon(d)
    if allowedWeapons[d] then
        allowedWeapons[d] = nil
    end
end
function VICE.checkWeapon(d)
    if allowedWeapons[d] == nil and not weapon_additions then
        RemoveWeaponFromPed(PlayerPedId(), GetHashKey(d))
        TriggerServerEvent("VICE:ACBan",1,d)
        return
    end
end
function VICE.getAllowedWeapons()
    return allowedWeapons
end
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(1000)
            for f, g in pairs(weapons.weapons) do
                if GetHashKey(f) and HasPedGotWeapon(PlayerPedId(), GetHashKey(f), false) then
                    VICE.checkWeapon(f)
                end
            end
        end
    end
)
weapon_additions = false
function tVICE.giveWeapons(h, i,passkey)
    local j = PlayerPedId()
    if i then
        RemoveAllPedWeapons(j, true)
        allowedWeapons = {}
    end
    weapon_additions = true
    for k, l in pairs(h) do
        local m = GetHashKey(k)
        local n = l.ammo or 0
        VICE.allowWeapon(k, n)
        GiveWeaponToPed(j, m, n, false)
        local f = l.attachments or {}
        for o, p in pairs(f) do
            GiveWeaponComponentToPed(j, k, p)
        end
    end
    weapon_additions = false
end
function tVICE.holdWeapon(h, i, passkey)
    if decorpasskey and passkey == decorpasskey then
        local j = PlayerPedId()
        if i then
            RemoveAllPedWeapons(j, true)
            allowedWeapons = {}
        end
        weapon_additions = true
        for k, l in pairs(h) do
            local m = GetHashKey(k)
            local n = l.ammo or 0
            VICE.allowWeapon(k, n)
            GiveWeaponToPed(j, m, n, false)
            SetCurrentPedWeapon(j, m, true)
            local f = l.attachments or {}
            for o, p in pairs(f) do
                GiveWeaponComponentToPed(j, k, p)
            end
        end
        weapon_additions = false
    end
end
function VICE.isPlayerArmed()
    local j = PlayerPedId()
    for b, c in pairs(a.weapons) do
        if HasPedGotWeapon(j, c.hash) then
            return true
        end
    end
    return false
end
function tVICE.hasWeapon(q)
    if HasPedGotWeapon(PlayerPedId(), string.upper(q)) then
        return true
    end
    return false
end
function tVICE.isHoldingAnyWeapon()
    if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey('WEAPON_UNARMED') then
        return true
    end
    return false
end
function tVICE.getWeapons()
    local j = PlayerPedId()
    local r = {}
    local h = {}
    for b, c in pairs(a.weapons) do
        if HasPedGotWeapon(j, c.hash) then
            local l = {}
            local s = GetPedAmmoTypeFromWeapon(j, c.hash)
            if r[s] == nil then
                r[s] = true
                l.ammo = GetAmmoInPedWeapon(j, c.hash)
            else
                l.ammo = 0
            end
            h[b] = l
        end
    end
    return h
end
function VICE.removeAllWeapons()
    RemoveAllPedWeapons(VICE.getPlayerPed(),true)
end
function VICE.setWeaponAmmo(t, e)
    SetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), GetHashKey(t)), e)
end
local u = GetGameTimer()
RegisterCommand("storecurrentweapon",function()
    if u + 3000 < GetGameTimer() then
        u = GetGameTimer()
        if HasPedGotWeapon(PlayerPedId(), "WEAPON_PISTOL50") or HasPedGotWeapon(PlayerPedId(), "WEAPON_MACHINEPISTOL") then
            --
        else
            local o, m = GetCurrentPedWeapon(PlayerPedId())
            local k = a.weaponHashToModels[m]
            TriggerServerEvent("VICE:forceStoreSingleWeapon", k)
        end
    else
        VICE.notify("~r~Store weapons cooldown, please wait.")
    end
end)
local v = {`WEAPON_UNARMED`, `WEAPON_PETROLCAN`, `WEAPON_STAFFGUN`, `WEAPON_SNOWBALL`}
Citizen.CreateThread(function()
    while true do
        local w = allowedWeapons
        local x = GetFrameCount()
        local y = VICE.isPedScriptGuidChanging()
        local r = {}
        if weapon_additions then
            return
        end
        for b, c in pairs(w) do
            local s = GetPedAmmoTypeFromWeapon(PlayerPedId(), b)
            if s ~= 0 then
                if r[s] == nil then
                    r[s] = true
                    if w[b] and w[b].setFrame and x > w[b].setFrame and not y then
                        local B = GetAmmoInPedWeapon(PlayerPedId(), b)
                        w[b].ammo = w[b].ammo or 0
                        if B > w[b].ammo and not VICE.isInPurge() then
                        --    TriggerServerEvent("VICE:ACBan",17,b) -- This might false positive ban people
                        end
                        w[b].ammo = B
                    end
                else
                    w[b].ammo = w[b].ammo or 0
                    w[b].ammo = B
                end
            end
        end
        Wait(2000)
    end
end)
local lines = {}
local colorMap = {
    red = {255, 0, 0},
    blue = {0, 0, 255},
    green = {0, 255, 0},
    pink = {255, 105, 180},
    yellow = {255, 255, 0},
    orange = {255, 165, 0},
    purple = {128, 0, 128}
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        if IsPedShooting(playerPed) then
            local m = GetResourceKvpString("vice_bullettracers") or "false"
            if m == "false" then
                bulletTracersOn = false
            else
                bulletTracersOn = true
            end
            if bulletTracersOn and (tVICE.isPlatClub() or tVICE.isPlusClub()) then
                local handCoords = GetPedBoneCoords(playerPed, GetPedBoneIndex(playerPed, 57005), 0.0, 0.0, 0.0)
                local camRot = GetGameplayCamRot(2)
                local forwardVector = RotationToDirection(camRot)
                local muzzleCoords = vector3(handCoords.x - 0.2 + forwardVector.x * 0.2, handCoords.y + forwardVector.y * 0.2, handCoords.z + forwardVector.z + 0.5)
                local endCoords = vector3(muzzleCoords.x + forwardVector.x * 100, muzzleCoords.y + forwardVector.y * 100, muzzleCoords.z + forwardVector.z * 100)
                local colorName = (GetResourceKvpString("vice_bullettracercolour") or "red"):lower()
                local color = colorMap[colorName] or {255, 0, 0}
                table.insert(lines, {start = muzzleCoords, stop = endCoords, time = GetGameTimer(), color = color})
            end
        end
        for i = #lines, 1, -1 do
            local line = lines[i]
            if GetGameTimer() - line.time <= 1500 then
                DrawLine(line.start.x, line.start.y, line.start.z, line.stop.x, line.stop.y, line.stop.z, line.color[1], line.color[2], line.color[3], 255)
            else
                table.remove(lines, i)
            end
        end
    end
end)

function RotationToDirection(rotation)
    local z = math.rad(rotation.z)
    local x = math.rad(rotation.x)
    local num = math.abs(math.cos(x))

    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

AddEventHandler("onResourceStop",function(z)
    if z == GetCurrentResourceName() then
        RemoveAllPedWeapons(PlayerPedId(), true)
    end
end)


local WeaponCFG = module("cfg/weapons")
WeapNames = {}
HeadshotTable = {}
Citizen.CreateThread(function()
    for hash,table in pairs(WeaponCFG.weapons) do
        AddTextEntry(hash,table.name)
        WeapNames[GetHashKey(hash)] = table.name
        if table.headshot then
            HeadshotTable[GetHashKey(hash)] = true
        end
    end
end)

function VICE.getWeapons()
    local Ped = PlayerPedId()
    local Weapons = {}
    for SpawnCode,Table in pairs(WeaponCFG.weapons) do
        if HasPedGotWeapon(Ped,Table.hash,false) then
            Weapons[SpawnCode] = GetAmmoInPedWeapon(Ped,Table.hash) or 0
        end
    end
    return Weapons
end
function VICE.getMoreWeapons()
    local f = PlayerPedId()
    local n = {}
    local d = {}
    for b, c in pairs(a.weapons) do
        if HasPedGotWeapon(f, c.hash, false) and c.hash ~= "WEAPON_UNARMED" then
            local h = {}
            local o = GetPedAmmoTypeFromWeapon(f, c.hash)
            if n[o] == nil then
                n[o] = true
                h.ammo = GetAmmoInPedWeapon(f, c.hash)
            else
                h.ammo = 0
            end
            h.attachments = getAllWeaponAttachments(c.hash)
            d[b] = h
        end
    end
    return d
end

-- Add cleanup function for weapon props
local function cleanupWeaponProps()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local radius = 3.0 -- Increased search radius
    
    -- Get all objects in the area
    local objects = GetGamePool('CObject')
    for _, object in ipairs(objects) do
        if DoesEntityExist(object) then
            local objectCoords = GetEntityCoords(object)
            local model = GetEntityModel(object)
            -- Check if object is close to player
            if #(coords - objectCoords) <= radius then
                -- Check if the object is any weapon model
                for _, weapon in pairs(weapons.weapons) do
                    if model == GetHashKey(weapon.model) then
                        DeleteObject(object)
                        break
                    end
                end
            end
        end
    end
end

-- Add death event handler and also handle when player enters coma
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local isDead = args[4] == 1
        
        if victim == PlayerPedId() and isDead then
            Citizen.Wait(100) -- Small delay to ensure weapon prop is created
            cleanupWeaponProps()
        end
    end
end)

-- Also clean up on coma
RegisterNetEvent('VICE:coma')
AddEventHandler('VICE:coma', function()
    Citizen.Wait(100)
    cleanupWeaponProps()
end)

RegisterNetEvent("VICE:giveWeapons")
AddEventHandler("VICE:giveWeapons", function(weapons, clearCurrent, passkey)
    tVICE.giveWeapons(weapons, clearCurrent, passkey)
end)