local function a(b)
    return b == 1 or b == true
end
local c = {[31086] = true}
local d = {
    [40269] = true,
    [28252] = true,
    [24818] = true,
    [45509] = true,
    [61163] = true,
    [10706] = true,
    [65245] = true,
    [63931] = true,
    [57597] = true,
    [58271] = true,
    [51826] = true,
    [36864] = true,
    [24816] = true,
    [24817] = true,
    [24819] = true,
    [14201] = true,
    [52301] = true,
    [18905] = true,
    [57005] = true,
    [39317] = true,
    [64729] = true
}
local e = false
AddEventHandler(
    "VICE:hsSoundsOn",
    function()
        e = true
    end
)
AddEventHandler(
    "VICE:hsSoundsOff",
    function()
        e = false
    end
)
local f = false
AddEventHandler(
    "VICE:codHMSoundsOn",
    function()
        f = true
    end
)
AddEventHandler(
    "VICE:codHMSoundsOff",
    function()
        f = false
    end
)
DecorRegister("lasthp", 3)
CreateThread(
    function()
        while true do
            Wait(0)
            if not DecorExistOn(PlayerPedId(), "lasthp") and GetEntityHealth(PlayerPedId()) > 102 then
                DecorSetInt(PlayerPedId(), "lasthp", GetEntityHealth(PlayerPedId()))
            end
        end
    end
)
AddEventHandler(
    "gameEventTriggered", 
    function(g, h)
        GameEventTriggered(g, h)
    end
)
function GameEventTriggered(i, j)
    if i == "CEventNetworkEntityDamage" then
        local k = tonumber(j[1])
        local l = tonumber(j[2])
        local m = tonumber(j[6]) == 1 and true or false
        local n = tonumber(j[5])
        local o = tonumber(j[10]) ~= 0 and true or false
        local p = tonumber(j[11])
        local q, r = GetPedLastDamageBone(k)
        local s = nil
        if q then
            s = tonumber(r)
        end
        if m and l == PlayerPedId() and IsEntityAPed(k) and k ~= PlayerPedId() then
            TriggerEvent("VICE:onPlayerKilledPed", k)
        end
        if k == PlayerPedId() then
            local t = VICE.getPedServerId(l)
            if n == 0 then
                n = GetSelectedPedWeapon(l)
            end
            CreateThread(
                function()
                    while not DecorExistOn(PlayerPedId(), "lasthp") do
                        Wait(0)
                    end
                    if DecorExistOn(PlayerPedId(), "lasthp") then
                        local u = m and 0 or GetEntityHealth(k)
                        local v = DecorGetInt(k, "lasthp")
                        if u < v then
                            if c[r] then
                                if t then
                                    TriggerServerEvent("VICE:syncEntityDamage", u, v, t, true, m, n)
                                end
                            elseif d[r] then
                                if t then
                                    TriggerServerEvent("VICE:syncEntityDamage", u, v, t, false, m, n)
                                end
                            end
                        end
                        if m then
                            DecorRemove(k, "lasthp")
                        else
                            DecorSetInt(k, "lasthp", u)
                        end
                    end
                end
            )
        end
        if
            VICE.getDmgIndcator() and (tVICE.isPlusClub() or tVICE.isPlatClub()) and IsEntityAPed(k) and
                k ~= PlayerPedId() and
                l == PlayerPedId()
         then
            local w = math.floor(string.unpack("f", string.pack("i4", tonumber(j[3]))))
            if w == 2 then
                return
            end
            local x, y = VICE.getDmgIndcator()
            local z = {
                {200, 0, 0, 255},
                {0, 0, 200, 255},
                {0, 200, 0, 255},
                {242, 172, 185, 255},
                {255, 255, 0, 255},
                {255, 165, 0, 255},
                {128, 0, 128, 255}
            }
            if x then
                local A = 3000
                local B = GetEntityCoords(k)
                Citizen.CreateThread(
                    function()
                        while true do
                            if A >= 0 then
                                VICE.DrawText3D(vector3(B.x, B.y, B.z + 0.5), w, 0.5, 4, nil, z[y], true, true)
                                A = A - 10
                            end
                            Wait(0)
                        end
                    end
                )
            end
        end
    end
end
AddEventHandler(
    "entityDamaged",
    function(C, D, n, E)
        local F = PlayerPedId()
        if D == F and C ~= F and IsEntityAPed(C) and GetEntityHealth(C) > 105 and not IsEntityDead(C) then
            Citizen.Wait(0)
            TriggerEvent("VICE:onPlayerDamagePed", C)
        end
    end
)
CreateThread(
    function()
        RequestScriptAudioBank("DLC_HITMARKERS\\HITMARKERS_ONE")
        while not RequestScriptAudioBank("DLC_HITMARKERS\\HITMARKERS_ONE") do
            Wait(0)
        end
        if not HasStreamedTextureDictLoaded("hitmarker") then
            RequestStreamedTextureDict("hitmarker")
            while not HasStreamedTextureDictLoaded("hitmarker") do
                Wait(0)
            end
        end
    end
)
local A = 0
RegisterNetEvent(
    "VICE:onEntityHealthChange",
    function(G, u, v, H)
        if f and (tVICE.isPlusClub() or tVICE.isPlatClub()) then
            PlaySoundFrontend(-1, "hitmarker", "hitmarkers", false)
            A = 500
        elseif e then
            if H then
                SendNUIMessage({transactionType = "headshot"})
            else
                SendNUIMessage({transactionType = "bodyshot"})
            end
        end
    end
)
CreateThread(
    function()
        while true do
            if A >= 0 then
                DrawSprite("hitmarker", "hitmarker", 0.5, 0.5, 0.0125, 0.02, 0.0, 255, 255, 255, 255)
                HideHudComponentThisFrame(14)
            end
            Wait(0)
        end
    end
)
CreateThread(
    function()
        while true do
            if A >= 0 then
                A = A - 100
            end
            Wait(100)
        end
    end
)

RegisterNetEvent("VICE:eatPill")
AddEventHandler("VICE:eatPill", function()
    local playerPed = PlayerPedId()
    local animDict = "mp_suicide"
    local animName = "pill"

    if DoesEntityExist(playerPed) and not IsEntityDead(playerPed) then
        RequestAnimDict(animDict)

            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(0)
            end

            if VICE.getPlayerCombatTimer() > 0 then
                VICE.notify("~r~You can't swallow this pill while in combat.")
            elseif not VICE.isInPurge() then
                VICE.notify("~r~You can only do this during the purge")
            else

            if IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
                TaskPlayAnim(playerPed, animDict, "exit", 3.0, 1.0, -1, 0, 0, false, false, false)
                ClearPedSecondaryTask(playerPed)
            else
                TaskPlayAnim(playerPed, animDict, animName, 3.0, 1.0, -1, 0, 0, false, false, false)
            end

            RemoveAnimDict(animDict)

            Citizen.Wait(3400) 

            local health = GetEntityHealth(playerPed)
            if health > 0 and health <= 200 then
                SetEntityHealth(playerPed, 0)
                VICE.notify("~r~You took the easy way out.")
            end
        end
    end
end)