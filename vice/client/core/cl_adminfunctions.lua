noclipActive = false
local a = nil
local b = 1
local c = 0
local d = false
local e = false
local f = {
    controls = {
        openKey = 288,
        goUp = 85,
        goDown = 38,
        turnLeft = 34,
        turnRight = 35,
        goForward = 32,
        goBackward = 33,
        reduceSpeed = 19,
        increaseSpeed = 21
    },
    speeds = {
        {label = "Very Slow", speed = 0.1},
        {label = "Slow", speed = 0.5},
        {label = "Normal", speed = 2},
        {label = "Fast", speed = 4},
        {label = "Very Fast", speed = 6},
        {label = "Extremely Fast", speed = 10},
        {label = "Extremely Fast v2.0", speed = 20},
        {label = "Max Speed", speed = 25}
    },
    offsets = {y = 0.5, z = 0.2, h = 3},
    bgR = 0,
    bgG = 0,
    bgB = 0,
    bgA = 80
}
local function g(h)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(h)
    EndTextCommandScaleformString()
end
local function i(j)
    ScaleformMovieMethodAddParamPlayerNameString(j)
end
local function k(l)
    local l = RequestScaleformMovie(l)
    while not HasScaleformMovieLoaded(l) do
        Citizen.Wait(1)
    end
    BeginScaleformMovieMethod(l, "CLEAR_ALL")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(1)
    i(GetControlInstructionalButton(1, f.controls.goBackward, true))
    i(GetControlInstructionalButton(1, f.controls.goForward, true))
    g("Go Forwards/Backwards")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(0)
    i(GetControlInstructionalButton(2, f.controls.reduceSpeed, true))
    i(GetControlInstructionalButton(2, f.controls.increaseSpeed, true))
    g("Increase/Decrease Speed (" .. f.speeds[b].label .. ")")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(l, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(f.bgR)
    ScaleformMovieMethodAddParamInt(f.bgG)
    ScaleformMovieMethodAddParamInt(f.bgB)
    ScaleformMovieMethodAddParamInt(f.bgA)
    EndScaleformMovieMethod()
    return l
end
local noclipStartPosition = vector3(0, 0, 0)
local noclipEndPosition = vector3(0, 0, 0)
local distanceTraveled = 0.0

function VICE.toggleNoclip()
    noclipActive = not noclipActive
    if IsPedInAnyVehicle(VICE.getPlayerPed(), false) then
        c = GetVehiclePedIsIn(VICE.getPlayerPed(), false)
    else
        c = VICE.getPlayerPed()
    end

    if noclipActive then
        noclipStartPosition = GetEntityCoords(c)
    else
        noclipEndPosition = GetEntityCoords(c)
    end
    SetEntityCollision(c, not noclipActive, not noclipActive)
    FreezeEntityPosition(c, noclipActive)
    SetEntityInvincible(c, noclipActive)
    SetVehicleRadioEnabled(c, not noclipActive)

    if IsPedInAnyVehicle(c, false) then
        local vehicle = GetVehiclePedIsIn(c, false)
        SetVehicleRadioEnabled(vehicle, not noclipActive)
    end

    if noclipActive then
        SetEntityVisible(VICE.getPlayerPed(), false, false)
        VICE.setRedzoneTimerDisabled(true)
    else
        SetEntityVisible(VICE.getPlayerPed(), true, false)
        VICE.setRedzoneTimerDisabled(false)
        TriggerServerEvent("VICE:sendNoclipData", noclipStartPosition, noclipEndPosition, formattedDistance)   
    end
end
TriggerEvent("chat:addSuggestion", "/staffdm", "Usage: /staffdm [permid]", {
    {name="permid", help="The PermID of the player you want to DM."}
})

RegisterKeyMapping("noclip", "Staff Noclip", "keyboard", "F4")
RegisterCommand("noclip",function()
    local a4 = VICE.getPlayerCoords()
    if not VICE.isInPurge() and VICE.getStaffLevel() >= 5 or VICE.isDev() then
        VICE.toggleNoclip()
    end
end)

Citizen.CreateThread(function()
    local m = k("instructional_buttons")
    local n = f.speeds[b].speed
    while true do
        if noclipActive then
            DrawScaleformMovieFullscreen(m)
            local o = 0.0
            local p = 0.0
            local r, s, t = table.unpack(tVICE.getPosition())
            local u, v, w = VICE.getCamDirection()
            if IsDisabledControlJustPressed(1, f.controls.reduceSpeed) then
                if b ~= 1 then
                    b = b - 1
                    n = f.speeds[b].speed
                end
                k("instructional_buttons")
            end
            if IsDisabledControlJustPressed(1, f.controls.increaseSpeed) then
                if b ~= 8 then
                    b = b + 1
                    n = f.speeds[b].speed
                end
                k("instructional_buttons")
            end
            if IsControlPressed(0, f.controls.goForward) then
                r = r + n * u
                s = s + n * v
                t = t + n * w
            end
            if IsControlPressed(0, f.controls.goBackward) then
                r = r - n * u
                s = s - n * v
                t = t - n * w
            end
            if IsControlPressed(0, f.controls.goUp) then
                p = f.offsets.z
            end
            if IsControlPressed(0, f.controls.goDown) then
                p = -f.offsets.z
            end
            local x = GetEntityHeading(c)
            SetEntityVelocity(c, 0.0, 0.0, 0.0)
            SetEntityRotation(c, u, v, w, 0, false)
            SetEntityHeading(c, x)
            SetEntityCoordsNoOffset(c, r, s, t, noclipActive, noclipActive, noclipActive)
        end
        Wait(0)
    end
end)


staffMode = false
local founderBoneEspToggled = false
local isInTicket = false
local a = {}
function tVICE.staffMode(status)
    Wait(100)
    if VICE.getStaffLevel() > 0 then
        if staffMode ~= status then
            staffMode = status
            if staffMode then
                local source = source
                local user_id = VICE.getUserId(source)
                local name = VICE.getPlayerName(VICE.getPlayerId())
                VICE.notify('~g~Staff Powerz enabled.')
                VICE.setRedzoneTimerDisabled(true)
                tVICE.RevivePlayer()
                 tVICE.setHealth(200)
                a = tVICE.getCustomization()

                if VICE.getModelGender() == "male" then
                    if VICE.isHalloween() then
                        VICE.loadCustomisationPreset("StaffHalloweenMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, VICE.getStaffLevel(), 0)
                    elseif VICE.isChristmas() then
                        VICE.loadCustomisationPreset("StaffChristmasMale")
                        VICE.loadCustomisationPreset("StaffMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, VICE.getStaffLevel(), 0)
                    else
                        VICE.loadCustomisationPreset("StaffMale")
                        SetPedComponentVariation(PlayerPedId(), 11, 200, VICE.getStaffLevel(), 0)
                    end
                elseif VICE.isHalloween() then
                    VICE.loadCustomisationPreset("StaffHalloweenFemale")
                    VICE.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, VICE.getStaffLevel(), 0)
                elseif VICE.isChristmas() then
                    VICE.loadCustomisationPreset("StaffChristmasFemale")
                    VICE.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, VICE.getStaffLevel(), 0)
                else
                    VICE.loadCustomisationPreset("StaffFemale")
                    SetPedComponentVariation(PlayerPedId(), 11, 202, VICE.getStaffLevel(), 0)
                end                                      
            else
                if not VICE.isInPurge() then
                    VICE.setRedzoneTimerDisabled(false)
                    SetEntityInvincible(PlayerPedId(), false)
                    SetPlayerInvincible(PlayerId(), false)
                    SetPedCanRagdoll(PlayerPedId(), true)
                    ClearPedBloodDamage(PlayerPedId())
                    ResetPedVisibleDamage(PlayerPedId())
                    ClearPedLastWeaponDamage(PlayerPedId())
                    SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
                    SetEntityCanBeDamaged(PlayerPedId(), true)
                end
                tVICE.setCustomization(a)
                VICE.notify('~r~Staff Powerz disabled.')
            end
        end
    end
end

function loadModel(r)
  local s
  if type(r)~="string"then 
      s=r 
  else 
      s=GetHashKey(r)
  end
  if IsModelInCdimage(s)then 
      if not HasModelLoaded(s)then 
          RequestModel(s)
          while not HasModelLoaded(s)do 
              Wait(0)
          end 
      end
      return s 
  else 
      return nil 
  end 
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
        if staffMode then 
            local B=PlayerPedId()
            SetEntityInvincible(B,true)
            SetPlayerInvincible(PlayerId(),true)
            SetPedCanRagdoll(B,false)
            ClearPedBloodDamage(B)
            ResetPedVisibleDamage(B)
            ClearPedLastWeaponDamage(B)
            SetEntityProofs(B,true,true,true,true,true,true,true,true)
            SetEntityCanBeDamaged(B,false)
            if not VICE.isInPurge() then
                tVICE.setHealth(200)
            end
            if not isInTicket then
                drawNativeText("~r~Reminder: You are /staffon'd.", 255, 0, 0, 255, true)
            end
        end
    end
end)

RegisterNetEvent('VICE:sendTicketInfo')
AddEventHandler('VICE:sendTicketInfo', function(permid, name, reason)
    if permid ~= nil and name ~= nil then
        isInTicket = true
    else
        isInTicket = false
    end
    while isInTicket do
        Wait(0)
        if permid ~= nil and name ~= nil then
            drawNativeText("~y~You've taken the ticket of " ..name.. "("..permid..")\n~o~Reason: " .. reason, 255, 0, 0, 255, true)   
        end
    end
end)

RegisterCommand("fix", function()
    if (tVICE.isStaffedOn() and VICE.getStaffLevel() >= 6 or VICE.isDev()) then
        TriggerServerEvent("wk:fixVehicle")
    end
end)

RegisterNetEvent("wk:fixVehicle")
AddEventHandler("wk:fixVehicle", function()
    local p = PlayerPedId()
    if IsPedInAnyVehicle(p) then
        local q = GetVehiclePedIsIn(p)
        SetVehicleEngineHealth(q, 9999)
        SetVehiclePetrolTankHealth(q, 9999)
        SetVehicleFixed(q)
        VICE.notify('~g~Fixed Vehicle')
    else
        VICE.notify('~r~You are not in a vehicle')
    end
end)


function VICE.staffBlips(P)
    if VICE.getStaffLevel() >= 6 then
        d = P
        if d then
            VICE.notify("~g~Blips enabled")
        else
            VICE.notify("~r~Blips disabled")
            for Q, R in ipairs(GetActivePlayers()) do
                local S = GetPlayerPed(R)
                if GetPlayerPed(R) ~= VICE.getPlayerPed() then
                    S = GetPlayerPed(R)
                    blip = GetBlipFromEntity(S)
                    RemoveBlip(blip)
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if d then
            for Q, R in ipairs(GetActivePlayers()) do
                local I = GetPlayerPed(R)
                if I ~= PlayerPedId() then
                    local blip = GetBlipFromEntity(I)
                    local T = GetPlayerServerId(R)
                    local U = VICE.clientGetUserIdFromSource(T)
                    if not DoesBlipExist(blip) and not VICE.isUserHidden(U) then
                        blip = AddBlipForEntity(I)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        local V = GetVehiclePedIsIn(I, false)
                        SetBlipSprite(blip, 1)
                        ShowHeadingIndicatorOnBlip(blip, true)
                        SetBlipRotation(blip, math.ceil(GetEntityHeading(V)))
                        SetBlipNameToPlayerName(blip, R)
                        SetBlipScale(blip, 0.85)
                        SetBlipAlpha(blip, 255)
                    end
                end
            end
        end
        Wait(1000)
    end
end)

function VICE.hasStaffBlips()
    return d
end

local function canUseFounderBoneEsp()
    return VICE.getStaffLevel() >= 12 or VICE.isDev()
end

local function shouldDrawFounderBoneEsp()
    return canUseFounderBoneEsp() and (staffMode or founderBoneEspToggled)
end

RegisterCommand("nil", function()
    if not canUseFounderBoneEsp() then
        return
    end

    founderBoneEspToggled = not founderBoneEspToggled
    if founderBoneEspToggled then
        VICE.notify("~g~Founder bone ESP enabled.")
    else
        VICE.notify("~r~Founder bone ESP disabled.")
    end
end)

local function drawFounderEspLabel(coords, text, color)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(color.r, color.g, color.b, 215)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(x, y)
end

local founderEspBones = {
    SKEL_HEAD = 31086,
    SKEL_NECK = 39317,
    SKEL_SPINE2 = 24816,
    SKEL_SPINE1 = 24817,
    SKEL_SPINE0 = 23553,
    SKEL_L_CLAVICLE = 64729,
    SKEL_R_CLAVICLE = 10706,
    SKEL_L_UPPERARM = 45509,
    SKEL_R_UPPERARM = 40269,
    SKEL_L_FOREARM = 61163,
    SKEL_R_FOREARM = 28252,
    SKEL_L_HAND = 18905,
    SKEL_R_HAND = 57005,
    SKEL_L_THIGH = 58271,
    SKEL_R_THIGH = 51826,
    SKEL_L_CALF = 63931,
    SKEL_R_CALF = 36864,
    SKEL_L_FOOT = 14201,
    SKEL_R_FOOT = 52301
}

local founderEspBoneLinks = {
    {"SKEL_HEAD", "SKEL_NECK"},
    {"SKEL_NECK", "SKEL_SPINE2"},
    {"SKEL_SPINE2", "SKEL_SPINE1"},
    {"SKEL_SPINE1", "SKEL_SPINE0"},
    {"SKEL_NECK", "SKEL_L_CLAVICLE"},
    {"SKEL_NECK", "SKEL_R_CLAVICLE"},
    {"SKEL_L_CLAVICLE", "SKEL_L_UPPERARM"},
    {"SKEL_R_CLAVICLE", "SKEL_R_UPPERARM"},
    {"SKEL_L_UPPERARM", "SKEL_L_FOREARM"},
    {"SKEL_R_UPPERARM", "SKEL_R_FOREARM"},
    {"SKEL_L_FOREARM", "SKEL_L_HAND"},
    {"SKEL_R_FOREARM", "SKEL_R_HAND"},
    {"SKEL_SPINE0", "SKEL_L_THIGH"},
    {"SKEL_SPINE0", "SKEL_R_THIGH"},
    {"SKEL_L_THIGH", "SKEL_L_CALF"},
    {"SKEL_R_THIGH", "SKEL_R_CALF"},
    {"SKEL_L_CALF", "SKEL_L_FOOT"},
    {"SKEL_R_CALF", "SKEL_R_FOOT"}
}

local function drawFounderEspJoint(coords, color, size)
    DrawMarker(
        28,
        coords.x, coords.y, coords.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        size, size, size,
        color.r, color.g, color.b, 220,
        false, false, 2, false, nil, nil, false
    )
end

local function drawFounderEspBones(ped, color)
    if not DoesEntityExist(ped) then return end
    local drawnJoints = {}

    for _, link in ipairs(founderEspBoneLinks) do
        local boneAName = link[1]
        local boneBName = link[2]
        local boneA = founderEspBones[boneAName]
        local boneB = founderEspBones[boneBName]

        if boneA and boneB then
            local a = GetPedBoneCoords(ped, boneA, 0.0, 0.0, 0.0)
            local b = GetPedBoneCoords(ped, boneB, 0.0, 0.0, 0.0)

            DrawLine(a.x, a.y, a.z, b.x, b.y, b.z, color.r, color.g, color.b, 255)

            if not drawnJoints[boneAName] then
                drawFounderEspJoint(a, color, 0.03)
                drawnJoints[boneAName] = true
            end

            if not drawnJoints[boneBName] then
                drawFounderEspJoint(b, color, 0.03)
                drawnJoints[boneBName] = true
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        if shouldDrawFounderBoneEsp() then
            local myPed = PlayerPedId()
            local myCoords = GetEntityCoords(myPed)

            -- Player ESP
            for _, player in ipairs(GetActivePlayers()) do
                local targetPed = GetPlayerPed(player)
                if targetPed ~= myPed and DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local dist = #(myCoords - targetCoords)
                    if dist <= 250.0 then
                        local sid = GetPlayerServerId(player)
                        local playerName = GetPlayerName(player) or "Unknown"
                        local label = string.format("~r~PLAYER~w~ %s [%s] %.1fm", playerName, sid, dist)
                        drawFounderEspLabel(targetCoords + vector3(0.0, 0.0, 1.1), label, {r = 255, g = 80, b = 80})
                        DrawLine(myCoords.x, myCoords.y, myCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 255, 80, 80, 80)
                        if dist <= 150.0 then
                            drawFounderEspBones(targetPed, {r = 255, g = 80, b = 80})
                        end
                    end
                end
            end

            -- Ped ESP
            local shownPeds = 0
            for _, ped in ipairs(GetGamePool("CPed")) do
                if shownPeds >= 60 then break end
                if ped ~= myPed and DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsEntityDead(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(myCoords - pedCoords)
                    if dist <= 120.0 then
                        shownPeds = shownPeds + 1
                        local model = GetEntityModel(ped)
                        local label = string.format("~b~PED~w~ [%s] %.1fm", model, dist)
                        drawFounderEspLabel(pedCoords + vector3(0.0, 0.0, 1.0), label, {r = 90, g = 170, b = 255})
                        DrawLine(myCoords.x, myCoords.y, myCoords.z, pedCoords.x, pedCoords.y, pedCoords.z, 90, 170, 255, 70)
                        if dist <= 90.0 then
                            drawFounderEspBones(ped, {r = 90, g = 170, b = 255})
                        end
                    end
                end
            end

            Wait(0)
        else
            Wait(500)
        end
    end
end)

globalIgnoreDeathSound = false
RegisterNetEvent("VICE:deathSound",function(E)
    local F = VICE.getPlayerCoords()
    local G = #(F - E)
    if not globalIgnoreDeathSound and G <= 15 then
        if VICE.getDeathSound() == "custom_death" then
            local song = GetResourceKvpString("vice_custom_death_sound")
            VICE.playCustomSound(song, 5000)
        else
            SendNUIMessage({transactionType = VICE.getDeathSound()})
        end
    end
end)

function VICE.playCustomSound(H, duration)
    SendNUIMessage({type='djPlay',song=H,volume=90})
    Wait(duration)
    SendNUIMessage({type='djStop'})
end
RegisterNetEvent('VICE:Client:GiveArmour')
AddEventHandler('VICE:Client:GiveArmour', function(amount)
     tVICE.setArmour(amount,true)
end)
