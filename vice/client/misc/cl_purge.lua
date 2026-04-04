local a = module("cfg/cfg_purge")
local b = a.coords[a.location]
local purgeActive = false
local players = 0
local cooldown = 0
local blip = nil
local checkpointCoords = vector3(199.17549133301, -933.71490478516, 30.686817169189)
local f

-- [[ Threads ]] --

Citizen.CreateThread(function()
    if VICE.isPurge() then
        local y = tVICE.addBlip(checkpointCoords, 1, 1, 429, "Purge Event")
        SetBlipColour(y, 1)
        SetBlipScale(y, 2.0)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if VICE.isInPurge() then
           drawNativeNotification("You have entered VICE Purge! To leave return to Legion or Disconnect.")
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if cooldown > 0 then
            cooldown = cooldown - 1
        end
    end
end)

Citizen.CreateThread(function()
    local Q = RequestScaleformMovie("mp_mission_name_freemode")
    while not HasScaleformMovieLoaded(Q) do
        Citizen.Wait(0)
    end
    RequestStreamedTextureDict("mpleaderboard", true)
    while not HasStreamedTextureDictLoaded("mpleaderboard") do
        Wait(0)
    end
    while true do
        Citizen.Wait(0)
        if VICE.isPurge() then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - checkpointCoords)
            if distance <= 50.0 then
                local playerCoords = GetEntityCoords(PlayerPedId())
                local direction = vector3(playerCoords.x - checkpointCoords.x, playerCoords.y - checkpointCoords.y, 0)
                local rotation = vector3(0.0, 0.0, 270.0 - math.deg(math.atan2(direction.y, direction.x)))
                DrawMarker(1, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 12.0, 12.0, 4.0, 255, 0, 0, 255, false, false, 2, false, false, false, false)                BeginScaleformMovieMethod(Q, "SET_MISSION_INFO")
                ScaleformMovieMethodAddParamPlayerNameString(VICE.isInPurge() and "Press [E] to exit" or "Press [E] to enter")
                ScaleformMovieMethodAddParamPlayerNameString("~y~vice purge")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString("0")
                ScaleformMovieMethodAddParamPlayerNameString(players == 1 and players .. " Player" or players.." Players")
                EndScaleformMovieMethod()
                DrawScaleformMovie_3dSolid(Q, checkpointCoords.x, checkpointCoords.y, checkpointCoords.z - 0.5, rotation.x, rotation.y, rotation.z, 4.0, 4.0, 1.0, 14.0, 14.0, 2.0, 2)
                if distance < 7.0 then
                    drawNativeNotification(VICE.isInPurge() and "Press ~INPUT_PICKUP~ to exit the purge" or "Press ~INPUT_PICKUP~ to enter the purge")
                    if IsControlJustPressed(0, 38) then
                        if cooldown == 0 then
                            cooldown = 30
                            if VICE.isInPurge() then
                                TriggerServerEvent('VICE:purgeActive', false)
                            else
                                TriggerServerEvent('VICE:purgeActive', true)
                                TriggerServerEvent('VICE:triggerPurgeSpawn')
                            end
                        else
                            VICE.notify("~r~You must wait " .. cooldown .. " seconds before making this decision.")
                        end
                    end
                end
            end
        end
    end
end)

-- [[ Functions ]] --

function VICE.isPurge()
    return VICEConfig.Purge
end

function VICE.isInPurge()
    return purgeActive
end

function tVICE.FrontendSound(sound, soundSet)
    PlaySoundFrontend(-1, sound, soundSet, true)
end

local function c()
    math.random()
    math.random()
    math.random()
    return b[math.random(1, #b)]
end

local d = false
function VICE.hasSpawnProtection()
    return d
end

local function e()
    d = true
    SetTimeout(10000, function()
            d = false
        end)
    Citizen.CreateThread(function()
        SetLocalPlayerAsGhost(true)
        while d do
            SetEntityProofs(PlayerPedId(), true, true, true, true, true, true, true, true)
            SetEntityAlpha(PlayerPedId(), 100, false)
            Wait(0)
        end
        SetEntityAlpha(PlayerPedId(), 255, false)
        SetLocalPlayerAsGhost(false)
        ResetGhostedEntityAlpha()
        VICE.notify("~g~Spawn protection ended!")
        SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
    end)
end

-- [[ Events ]] --

RegisterNetEvent("VICE:purge:catchData", function(playersInPurge,value)
    if VICE.isPurge() then
        purgeActive = value
        if value then
            blip = AddBlipForRadius(0.0, 0.0, 0.0, 50000.0)
            SetBlipColour(blip, 1)
            SetBlipAlpha(blip, 180)
        elseif not value then
            if blip then
                RemoveBlip(blip) 
                blip = nil 
            end
        end
        players = playersInPurge
    end
end)

RegisterNetEvent("VICE:purgeSpawnClient")
AddEventHandler("VICE:purgeSpawnClient", function(g)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    e()
    DoScreenFadeOut(250)
    VICE.showUI()
    Wait(500)
    TriggerScreenblurFadeIn(100.0)
    f = c()
    RequestCollisionAtCoord(f.x, f.y, f.z)
    local h = GetGameTimer()
    while HaveAllStreamingRequestsCompleted(PlayerPedId()) ~= 1 and GetGameTimer() - h < 5000 do
        Wait(0)
       -- print("[VICE] Waiting for streaming requests to complete!")
    end
    VICE.checkCustomization()
    TriggerServerEvent("VICE:getPlayerHairstyle")
    TriggerServerEvent("VICE:getPlayerTattoos")
    DoScreenFadeIn(1000)
    VICE.showUI()
    local i = VICE.getPlayerCoords()
    SetEntityCoordsNoOffset(PlayerPedId(), i.x, i.y, 1200.0, false, false, false)
    SetEntityVisible(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), true, true)
    SetFocusPosAndVel(f.x, f.y, f.z + 1000, 0.0, 0.0, 0.0)
    spawnCam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", f.x, f.y, f.z + 1000, 0.0, 0.0, 0.0, 65.0, 0, 2)
    SetCamActive(spawnCam, true)
    RenderScriptCams(true, true, 0, true, false)
    spawnCam2 = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", f.x, f.y, f.z, 0.0, 0.0, 0.0, 65.0, 0, 2)
    SetCamActiveWithInterp(spawnCam2, spawnCam, 5000, 0, 0)
    Wait(2500)
    ClearFocus()
    if not g then
        SetEntityCoords(PlayerPedId(), f.x, f.y, f.z)
    end
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerScreenblurFadeOut(2000.0)
    Wait(2000)
    DestroyCam(spawnCam, false)
    DestroyCam(spawnCam2, false)
    RenderScriptCams(false, true, 2000, 0, 0)
    tVICE.setHealth(200)
    TriggerServerEvent("VICE:purgeClientHasSpawned")
end)

RegisterNetEvent("VICE:purgeAnnounce",function()
    if VICE.isPurge() then
        PlaySound(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", false, 0, true)
        tVICE.announceMpBigMsg("~r~purge event has started!","To join go to Legion and enter the marker",15000)
    end
end)

-- [[ Commands ]] --

RegisterCommand("airport", function()
    if VICE.isInPurge() then
        local k = VICE.getPlayerCoords()
        VICE.notify("~g~Teleporting to airport... please wait.")
        Wait(10000)
        if k == VICE.getPlayerCoords() then
            tVICE.teleport(-1113.495, -2917.377, 13.94363)
            VICE.notify("~g~Teleported to airport, use /suicide to return to the purge.")
        else
            VICE.notify("~r~Teleportation failed, please remain still when teleporting.")
        end
    end
end)