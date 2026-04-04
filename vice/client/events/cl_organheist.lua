local a = module("cfg/cfg_organheist")
inOrganHeist = false
WaitingForOrganToBegin = false
local b = vector3(240.31098937988, -1379.8699951172, 33.741794586182)
local c = vector3(231.51065063477, -1360.6903076172, 28.651802062988)
local d = 600
local e = false
local f = false
local g = false
local h = ""
local i = {}
local j = {}
local k = nil
local l, m = AddRelationshipGroup("ORGANHEIST_POLICE")
local l, n = AddRelationshipGroup("ORGANHEIST_CRIMINAL")
local o = {
    ["civs"] = {
        objectHash = `prop_gate_military_01`,
        objectPos = vector3(251.2504, -1361.306, 23.54731),
        objectHeading = 322.19732666016,
        objectHandler = 0
    },
    ["cops"] = {
        objectHash = `prop_gate_military_01`,
        objectPos = vector3(251.1472, -1361.884, 38.54385),
        objectHeading = 318.79,
        objectHandler = 0
    }
}
AddEventHandler(
    "VICE:onClientSpawn",
    function(p, q)
        if q then
            tVICE.addMarker(b.x, b.y, b.z, 0.7, 0.7, 0.5, 0, 125, 255, 125, 150, 20, false, false, true)
            tVICE.addBlip(b.x, b.y, b, 378, 3, "Organ Heist Police")
            tVICE.addMarker(c.x, c.y, c.z, 0.7, 0.7, 0.5, 255, 0, 0, 125, 150, 20, false, false, true)
            tVICE.addBlip(c.x, c.y, c.z, 378, 1, "Organ Heist Criminals")
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            local r = PlayerPedId()
            local s = GetEntityCoords(r)
            if #(s - c) < 1.0 then
                f = true
            else
                f = false
            end
            if #(s - b) < 1.0 then
                e = true
            else
                e = false
            end
            Wait(250)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if f then
                drawNativeNotification("~r~Press ~INPUT_PICKUP~ to play the Organ Heist!")
                if IsControlJustPressed(0, 38) then
                    if not globalOnPoliceDuty then
                        if not g then
                            TriggerServerEvent("VICE:joinOrganHeist")
                            Wait(100)
                        else
                            VICE.notify("~r~Already joined the Organ Heist!")
                        end
                    else
                        VICE.notify("~r~You are police, please use the other entrance!")
                    end
                end
            elseif e then
                drawNativeNotification("~b~Press ~INPUT_PICKUP~ to play the Organ Heist!")
                if IsControlJustPressed(0, 38) then
                    if globalOnPoliceDuty then
                        if not g then
                            TriggerServerEvent("VICE:joinOrganHeist")
                            Wait(100)
                        else
                            VICE.notify("~r~Already joined the Organ Heist!")
                        end
                    else
                        VICE.notify("~r~You are a civillian, please use the other entrance!")
                    end
                end
            end
            if inOrganHeist and inWaitingStage then
                DrawGTATimerBar("STARTS IN:", decimalsToMinutes(d), 1)
                DisablePlayerFiring(PlayerId(), true)
            end
            if inGamePhase or inWaitingStage then
                DrawGTATimerBar("~b~Police:", table.count(i), 3)
                DrawGTATimerBar("~r~Criminals:", table.count(j), 2)
                drawNativeText("~b~Kill the enemy team and survive.")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_MOLOTOV")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_FLASHBANG")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_SMOKEGRENADE")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_SMOKEGRENADEVICE")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_SMOKEGRENADEVICEPD")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_BZGAS")
                RemoveWeaponFromPed(VICE.getPlayerPed(), "WEAPON_STUNGUN")
                local r = PlayerPedId()
                local t = GetInteriorFromEntity(r)
                if t == 0 then
                    local u = k.safePositions[1]
                    DoScreenFadeOut(1000)
                    NetworkFadeOutEntity(PlayerPedId(), true, false)
                    Wait(1000)
                    SetEntityCoords(PlayerPedId(), u.x, u.y, u.z)
                    NetworkFadeInEntity(PlayerPedId(), 0)
                    DoScreenFadeIn(1000)
                end
            end
            Wait(0)
        end
    end
)
RegisterNetEvent(
    "VICE:teleportToOrganHeist",
    function(v, w, x, y)
        local r = PlayerPedId()
        d = w
        canPlayAnim = false
        h = x
        k = a.locations[y]
        g = true
        tVICE.setCanAnim(false)
        Citizen.CreateThread(
            function()
                while d > 0 do
                    d = d - 1
                    Wait(1000)
                end
                if d <= 0 then
                    TriggerServerEvent("VICE:checkOrganHeistStart")
                end
            end
        )
        inOrganHeist = true
        inWaitingStage = true
        if VICE.getShowCurrentWeapon() then
            VICE.setShowCurrentWeapon(false)
        end
        SetRelationshipBetweenGroups(5, m, n)
        SetRelationshipBetweenGroups(5, n, m)
        if x == "civ" then
            SetPedRelationshipGroupHash(PlayerPedId(), n)
            VICE.createAtm("Organ Heist", k.atmLocation)
        elseif x == "police" then
            SetPedRelationshipGroupHash(PlayerPedId(), m)
        end
        for l, z in pairs(k.gunStores[h]) do
            tVICE.createGunStore(z[1], z[2], z[3])
        end
        tVICE.setFriendlyFire(false)
        DoScreenFadeOut(1000)
        NetworkFadeOutEntity(r, true, false)
        Wait(1000)
        SetEntityCoords(r, v.x, v.y, v.z)
        NetworkFadeInEntity(r, 0)
        DoScreenFadeIn(1000)
        initializeOrganHeistScaleform()
        PrepareMusicEvent("AH3B_HALF_RAPPEL")
        TriggerMusicEvent("AH3B_HALF_RAPPEL")
    end
)
RegisterNetEvent(
    "VICE:addOrganHeistPlayer",
    function(A, x)
        if x == "civ" then
            j[A] = true
        elseif x == "police" then
            i[A] = true
        end
    end
)
RegisterNetEvent(
    "VICE:organHeistKillConfirmed",
    function(B)
        PlaySoundFrontend(-1, "Weapon_Upgrade", "DLC_GR_Weapon_Upgrade_Soundset", true)
        tVICE.playScreenEffect("MP_Celeb_Win", 0.25)
        VICE.notify("~g~Killed " .. B .. " received £50,000 and 25% Armour")
    end
)
Citizen.CreateThread(
    function()
        while true do
            if inWaitingStage then
                local s = GetEntityCoords(PlayerPedId())
                if #(s - k.pastGate) < 3.0 then
                    DoScreenFadeOut(1000)
                    NetworkFadeOutEntity(PlayerPedId(), true, false)
                    Wait(1000)
                    local u = k.safePositions[1]
                    SetEntityCoords(PlayerPedId(), u.x, u.y, u.z)
                    NetworkFadeInEntity(PlayerPedId(), 0)
                    DoScreenFadeIn(1000)
                    VICE.notify("~r~You got too far from the organ heist and have been teleported back.")
                end
            end
            if inGamePhase then
                local s = GetEntityCoords(PlayerPedId())
                if #(s - k.pastGate) > 200.0 then
                    DoScreenFadeOut(1000)
                    NetworkFadeOutEntity(PlayerPedId(), true, false)
                    Wait(1000)
                    local u = k.safePositions[1]
                    SetEntityCoords(PlayerPedId(), u.x, u.y, u.z)
                    NetworkFadeInEntity(PlayerPedId(), 0)
                    DoScreenFadeIn(1000)
                    VICE.notify("~r~You got too far from the organ heist and have been teleported back.")
                end
            end
            Wait(0)
        end
    end
)
function createOrganHeistBarriers()
    for C, D in pairs(o) do
        if not HasModelLoaded(D.objectHash) then
            RequestModel(D.objectHash)
            while not HasModelLoaded(D.objectHash) do
                Wait(0)
            end
        end
        local E = CreateObject(D.objectHash, D.objectPos.x, D.objectPos.y, D.objectPos.z, false, false, true)
        o[C].objectHandler = E
        SetEntityHeading(E, o[C].objectHeading)
        SetEntityInvincible(E, true)
        FreezeEntityPosition(E, true)
        SetModelAsNoLongerNeeded(D.objectHash)
    end
end
RegisterNetEvent("VICE:startOrganHeist",function()
        inWaitingStage = false
        inGamePhase = true
        PlaySoundFrontend(-1, "5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset", 1)
        Wait(5000)
        DisablePlayerFiring(PlayerId(), false)
    end
)
RegisterNetEvent(
    "VICE:removeFromOrganHeist",
    function(F)
        if i[F] then
            i[F] = nil
        end
        if j[F] then
            j[F] = nil
        end
    end
)
function moveUpGateObjects()
    Citizen.CreateThread(
        function()
            for C, D in pairs(o) do
                DeleteObject(D.objectHandler)
            end
        end
    )
end
function initializeOrganHeistScaleform()
    local G = true
    SetTimeout(
        5000,
        function()
            G = false
        end
    )
    Citizen.CreateThread(
        function()
            function Initialize(scaleform)
                local scaleform = RequestScaleformMovie(scaleform)
                while not HasScaleformMovieLoaded(scaleform) do
                    Citizen.Wait(0)
                end
                BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
                ScaleformMovieMethodAddParamTextureNameString("~g~ORGAN HEIST!")
                ScaleformMovieMethodAddParamTextureNameString("Survive the Organ Heist and win £250,000")
                EndScaleformMovieMethod()
                return scaleform
            end
            scaleform = Initialize("mp_big_message_freemode")
            PlaySound(-1, "Hit", "RESPAWN_SOUNDSET", 0, 0, 1)
            while G do
                local H = 0.5
                local I = 0.35
                local J = 1.0
                local K = J
                DrawScaleformMovie(scaleform, H, I, J, K)
                Wait(0)
            end
        end
    )
end
function decimalsToMinutes(L)
    local M = tonumber(L)
    if M % 60 <= 9 then
        addonString = "0"
    else
        addonString = ""
    end
    return math.floor(M / 60) .. ":" .. addonString .. M % 60
end
AddEventHandler(
    "onResourceStop",
    function(N)
        if N == GetCurrentResourceName() then
            for C, D in pairs(o) do
                DeleteObject(o[C].objectHandler)
            end
        end
    end
)
RegisterNetEvent(
    "VICE:endOrganHeist",
    function()
        ClearRelationshipBetweenGroups(5, n, m)
        ClearRelationshipBetweenGroups(5, m, n)
        SetPedRelationshipGroupHash(PlayerPedId(), "PLAYER")
        i = {}
        j = {}
        g = false
        inOrganHeist = false
        inWaitingStage = false
        inGamePhase = false
        d = 600
        VICE.deleteAtm("Organ Heist")
        for l, z in pairs(k.gunStores[h]) do
            tVICE.deleteGunStore(z[1])
        end
        h = ""
        k = nil
        tVICE.setCanAnim(true)
        tVICE.setFriendlyFire(true)
        PrepareMusicEvent("BST_STOP")
        TriggerMusicEvent("BST_STOP")
        TriggerServerEvent("VICE:ForceStoreAllWeapons")
        Wait(10000)
        if GetEntityHealth(PlayerPedId()) <= 102 then
            tVICE.RevivePlayer()
            local r = PlayerPedId()
            DoScreenFadeOut(1000)
            NetworkFadeOutEntity(r, true, false)
            Wait(1000)
            SetEntityCoords(r, 240.31098937988, -1379.8699951172, 33.741794586182)
            NetworkFadeInEntity(r, 0)
            DoScreenFadeIn(1000)
        end
    end
)
RegisterNetEvent(
    "VICE:endOrganHeistWinner",
    function(x)
        Wait(10000)
        winOrganHeist(x)
        local r = PlayerPedId()
        tVICE.setFriendlyFire(true)
        DoScreenFadeOut(1000)
        NetworkFadeOutEntity(r, true, false)
        Wait(1000)
        SetEntityCoords(r, 240.31098937988, -1379.8699951172, 33.741794586182)
        NetworkFadeInEntity(r, 0)
        DoScreenFadeIn(1000)
    end
)
local function O(P, Q, R, S)
    ClearTimecycleModifier()
    local T = {
        handle = Scaleform("MP_CELEBRATION"),
        handle2 = Scaleform("MP_CELEBRATION_BG"),
        handle3 = Scaleform("MP_CELEBRATION_FG")
    }
    for U, V in pairs(T) do
        V.RunFunction("CLEANUP", {"WINNER"})
        V.RunFunction("CREATE_STAT_WALL", {"WINNER", "HUD_COLOUR_BLACK", "70.0"})
        V.RunFunction(
            "SET_PAUSE_DURATION",
            {function()
                    ScaleformMovieMethodAddParamFloat(2.5)
                end}
        )
        if S ~= 0 then
            V.RunFunction("ADD_CASH_TO_WALL", {"WINNER", S, true})
        end
        V.RunFunction("ADD_WINNER_TO_WALL", {"WINNER", "CELEB_WINNER", P, "", 0, false, "", false})
        V.RunFunction("ADD_BACKGROUND_TO_WALL", {"WINNER", 75, 0})
        V.RunFunction("SHOW_STAT_WALL", {"WINNER"})
    end
    return T.handle, T.handle2, T.handle3
end
function winOrganHeist(x)
    Citizen.CreateThread(
        function()
            local W = false
            local X, Y, Z = O(x, 2, 100, 250000)
            if not W then
                W = true
            end
            SetTimeout(
                10000,
                function()
                    W = false
                end
            )
            while W do
                Wait(0)
                HideHudAndRadarThisFrame()
                DrawScaleformMovieFullscreenMasked(Y.Handle, Z.Handle, 255, 255, 255, 255)
                X.Render2D()
            end
        end
    )
end
function VICE.setDeathInOrganHeist()
    inOrganHeist = false
    inWaitingStage = false
    inGamePhase = false
    WaitingForOrganToBegin = false
end
RegisterNetEvent("VICE:ReadyForOrgan", function()
    WaitingForOrganToBegin = true
    if not inOrganHeist then
       VICE.notify("~g~Organ Heist Starting soon, Use /tporgan")
    end
end)
RegisterCommand("tporgan", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(GetPlayerServerId(PlayerId()))
    local success = false
    local message = ""
    if GetPlayerInvincible(PlayerId()) and isInGreenzone and WaitingForOrganToBegin and not VICE.isInPurge() and not VICE.isInsideLsCustoms() and not inOrganHeist and not tVICE.isStaffedOn() and not noclipActive and not tVICE.isInComa() and not VICE.isInSpectate() and not VICE.getInRPZone() then
        success = true
        if VICE.globalOnPoliceDuty() then
            VICE.notify("~g~Teleporting to Organ Heist, Police Side.")
            Wait(10000)
            tVICE.teleport(238.61906433105, -1382.0168457031, 33.743103027344)
            message = "Teleported - Police Side"
        else
            VICE.notify("~g~Teleporting to Organ Heist, Criminal Side.")
            Wait(10000)
            tVICE.teleport(224.66180419922, -1368.0705566406, 30.564836502075)
            message = "Teleported - Criminal Side"
        end
        VICE.notify("~b~You are at the Organ Heist. Quick because it starts soon!")
    else
        if not WaitingForOrganToBegin then
            message = "Organ isn't starting"
            VICE.notify("~r~Organ Heist isn't starting anytime soon.")
        elseif inOrganHeist then
            message = "They are in organ"
            VICE.notify("~r~You are currently playing the Organ Heist.")
        elseif not isInGreenzone then
            message = "Not inside greenzone"
            VICE.notify("~r~You must be inside a greenzone to teleport.")
        elseif tVICE.isStaffedOn() then
            message = "User is staffon'd"
            VICE.notify("~r~You cannot be staffed on.")
        elseif VICE.isInsideLsCustoms() then
            message = "User is inside LS Customs"
            VICE.notify("~r~You cannot be inside LS Customs.")
        elseif noclipActive then
            message = "User is no-clipped"
            VICE.notify("~r~You cannot be in no-clip.")
        elseif tVICE.isInComa() then
            message = "User is dead"
            VICE.notify("~r~Cannot teleport while dead.")
        elseif VICE.isInSpectate() then
            message = "User is spectating"
            VICE.notify("~r~You cannot teleport while spectating.")
        elseif VICE.isInPurge() then
            message = "Purge is active"
            VICE.notify("~r~You cannot teleport to the Organ Hesit while in the purge.")
        elseif VICE.getInRPZone() then
            message = "User is in a rp zone"
            VICE.notify("~r~You cannot be in a roleplay zone.")
        end
    end
    if success then
        TriggerServerEvent("VICE:sendWebhookClient", "organ-tp", "VICE Teleport Organ Logs", string.format("**%s**\n\n> Player Name %s\n> Player PermID: %s", message, name, user_id))
    else
        TriggerServerEvent("VICE:sendWebhookClient", "organ-tp", "VICE Teleport Organ Unsuccessful", string.format("**%s**\n\n> Player Name %s\n> Player PermID: %s", message, name, user_id))
    end
end)