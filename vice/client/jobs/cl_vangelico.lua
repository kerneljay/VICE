-- [[ Variables ]] --
if VangelicoHeist == nil then
    VangelicoHeist = {
        ['startPeds'] = {},
        ['painting'] = {},
        ['gasMask'] = false,
        ['globalObject'] = nil,
        ['globalItem'] = "Bottle Of Sperm",
    }
end
local n = {
    {["label"] = "Confirm Selections", ["button"] = "~INPUT_CELLPHONE_EXTRA_OPTION~"},
    {["label"] = "Select", ["button"] = "~INPUT_CELLPHONE_SELECT~"},
    {["label"] = "Next Cell", ["button"] = "~INPUT_CELLPHONE_RIGHT~"},
    {["label"] = "Previous Cell", ["button"] = "~INPUT_CELLPHONE_LEFT~"}
}
local o = {{["label"] = "Select", ["button"] = "~INPUT_ATTACK~"}}
local h = nil
local NativeNoti = nil
local TotalSum = 0
local incrementing = false
local targetSum = 0
local timeLeft = 60
local Door = 0
local hasVangelicoStarted = false
local heistInSetup = false
local inHeist = false
local isOwner = false
local SelectedDetails
local cost = 1500000
--local UserData = getHeistTeam(VICE.getUserId())
local heistTeam = {}
local cfgjew = module("cfg/cfg_jewelryHeist")
-- [[ Commands ]] --
RegisterCommand('vangelico', function(source, args)
    local src = source
    RageUI.Visible(RMenu:Get("Vangelico", "main"), not RageUI.Visible(RMenu:Get("Vangelico", "main")))
end)
RegisterCommand('heist', function(source, args)
    local src = source
    TriggerServerEvent("VICE:server:joinHeist")
end)
-- [[ Menu ]] --
RMenu.Add("Vangelico","manageplayer",RageUI.CreateMenu("Heist Setup","~b~Manage Player",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"shopui_title_sm_hangar","shopui_title_sm_hangar"))
RMenu.Add("Vangelico","main",RageUI.CreateMenu("Heist Setup","~b~Main Menu",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"shopui_title_sm_hangar","shopui_title_sm_hangar"))
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('Vangelico', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if heistInSetup then
                if next(heistTeam) then
                    RageUI.Separator("Joined Players (" .. #heistTeam .. "/10)")
                end
                for k,v in pairs(heistTeam) do
                    RageUI.Button(v.name, "Name: " .. v.name .." ID: " .. v.user_id .. " Temp ID: ".. v.src, {RightLabel = v.owner and "HOST" or "CREW"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            SelectedDetails = v
                        end
                    end, RMenu:Get("Vangelico", "manageplayer"))
                end
            end
            RageUI.Separator("Heist Options")
            if not isOwner and not heistInSetup and not viewingHeist then
                RageUI.Button("~b~Begin Setup", "", {RightLabel = "→→→"}, true, function(d, e, f)
                    if f then
                        TriggerServerEvent("VICE:server:beginVangelicoSetup")
                    end
                end)
            end
            if heistInSetup then
                RageUI.Button("~b~Buy Full Armour","",{},function(P, Q, R)
                    if R then
                        TriggerServerEvent("VICE:HeistsBuyFullArmour")
                    end
                end)
            end
            if isOwner then
                if not inHeist then
                    if #heistTeam < 10 then
                        RageUI.Button("~b~Invite Player", "Start the heist", {RightLabel = "→→→"}, true, function(d, e, f)
                            if f then
                                tVICE.clientPrompt("User's Perm Id","",function(s)
                                    if tonumber(s) then
                                        if s ~= "" then
                                            TriggerServerEvent("VICE:server:invitePlayerHeist", s)
                                        else
                                            VICE.notify("~r~Please provide a valid ID")
                                        end
                                    else
                                        VICE.notify("~r~Please provide a valid ID")
                                    end
                                end)
                            end
                        end)
                    end
                    RageUI.Button(string.format("~b~Start Heist (£%s)", getMoneyStringFormatted(cost)), "", {RightLabel = "→→→"}, true, function(d, e, f)
                        if f then
                            TriggerServerEvent("VICE:server:startHeist", cost)
                        end
                    end)
                    -- RageUI.Button("~b~Cancel Heist", "", {RightLabel = "→→→"}, true, function(d, e, f)
                    --     if f then
                    --         TriggerServerEvent("VICE:server:cancelHeist", cost)
                    --     end
                    -- end)
                end
            elseif not isOwner and heistInSetup and not viewingHeist then
                RageUI.Separator("Waiting for host...")
            end
        end)
    end
    if RageUI.Visible(RMenu:Get('Vangelico', 'manageplayer')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.Separator("~g~Managing: " .. SelectedDetails.name)
            RageUI.Button("Kick Player", "Remove " .. SelectedDetails.name .. " from the heist", {}, true, function(d, e, f)
                if f then
                    TriggerServerEvent("VICE:server:kickHeist", SelectedDetails)
                end
            end)
            RageUI.Button("Promote to leader", "Promote " .. SelectedDetails.name .. " to the heist leader", {}, true, function(d, e, f)
                if f then
                    TriggerServerEvent("VICE:server:promoteHeist", SelectedDetails)
                end
            end)
        end)
    end
end)

-- [[ Functions ]] --

local function getHeistTeam(playerid)
    for a, b in pairs(heistTeam) do
        if heistTeam[b.user_id] == playerid then
            return b
        end
    end
end

local function hackBegin(value)
    local r
    print(value)
    if value == "door" then
        r = n
    else
        r = o
    end
    local s = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(s) do
        Wait(0)
    end
    BeginScaleformMovieMethod(s, "CLEAR_ALL")
    BeginScaleformMovieMethod(s, "TOGGLE_MOUSE_BUTTONS")
    ScaleformMovieMethodAddParamBool(0)
    EndScaleformMovieMethod()
    for t, u in ipairs(r) do
        BeginScaleformMovieMethod(s, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(t - 1)
        ScaleformMovieMethodAddParamPlayerNameString(u["button"])
        ScaleformMovieMethodAddParamTextureNameString(u["label"])
        EndScaleformMovieMethod()
    end
    BeginScaleformMovieMethod(s, "DRAW_INSTRUCTIONAL_BUTTONS")
    ScaleformMovieMethodAddParamInt(-1)
    EndScaleformMovieMethod()
    while m do
        Wait(0)
        DrawScaleformMovieFullscreen(s, 255, 255, 255, 255, 0)
    end
    SetScaleformMovieAsNoLongerNeeded(s)
end
local c = false
RegisterNetEvent("VICE:jewelrySyncSetupReady",function(v)
    c = v
end)

Citizen.CreateThread(function()
    while true do
        if #(GetEntityCoords(PlayerPedId()) - vector3(707.28045654297, -966.78295898438, 30.412839889526)) <= 1.0 then
            ShowHelpNotification("Press ~INPUT_PICKUP~ to open the heist menu.")
            if IsControlJustPressed(1, 38) then
                TriggerServerEvent('VICE:server:getHeistData')
                RageUI.Visible(RMenu:Get("Vangelico", "main"), not RageUI.Visible(RMenu:Get("Vangelico", "main")))
            end
        elseif RageUI.Visible(RMenu:Get("Vangelico", "main"), false) then
            RageUI.Visible(RMenu:Get("Vangelico", "main"), true)
         end
        Citizen.Wait(1)
    end
end)
local H = false
RegisterNetEvent("VICE:client:invitePlayerHeist",function(m)
        if H then
            H = false
            Citizen.Wait(0)
            Citizen.Wait(0)
        end
        H = true
        local V = GetGameTimer()
        while GetGameTimer() - V < 10000 do
            if not H then
                return
            end
            VICE.notify(string.format("%s has invited you to a setup, press (~y~Y~w~) to accept (~r~L~w~) to refuse", m))
            if IsControlJustPressed(0, 246) then
                VICE.notify("~g~Request Accepted")
                TriggerServerEvent("VICE:server:joinHeist")
                H = false
            elseif IsControlJustPressed(0, 182) then
                VICE.notify("~g~Request Refused")
                H = false
            end
            Citizen.Wait(0)
        end
        H = false
    end
)

RegisterNetEvent("VICE:client:sendHeistData")
AddEventHandler("VICE:client:sendHeistData", function(team)
    heistTeam = team
    if team[VICE.getUserId()] then
        isOwner = team[VICE.getUserId()].owner
    end
end)

function VICE.hasHackedComputer()
    if heistTeam[VICE.getUserId()] then
        return heistTeam[VICE.getUserId()].hackedComputer
    end
    return false
end

function VICE.isInHeist()
    if heistTeam[VICE.getUserId()] then
        return heistTeam[VICE.getUserId()].inHeist
    end
    return false
end

RegisterNetEvent("VICE:client:toggleHeistMenu")
AddEventHandler("VICE:client:toggleHeistMenu", function(value)
    if value then
       RageUI.Visible(RMenu:Get("Vangelico", "main"), false)
    else
       RageUI.Visible(RMenu:Get("Vangelico", "main"), true)
    end
end)

local viewingHeist = false

Citizen.CreateThread(function()
    while true do
        if viewingHeist then
            if RageUI.Visible(RMenu:Get("Vangelico", "main"), true) then
                RageUI.Visible(RMenu:Get("Vangelico", "main"), false)
            end
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent("VICE:client:setInHeist")
AddEventHandler("VICE:client:setInHeist", function(value)
    if value then
        heistInSetup = true
        print("Heist in setup")
    end
end)

RegisterNetEvent("VICE:client:setHeist")
AddEventHandler("VICE:client:setHeist", function(value)
    print(value)
    if value then
        inHeist = true
        VICE.notify("~g~You are now participating in the Vangelico Heist.")
    else
        inHeist = false
        heistInSetup = false
        isOwner = false
        heistTeam = {}
        VICE.notify("~r~The host has canceled the Vangelico Heist.")
    end
end)

local Config = module("cfg/cfg_vangelico")

local function Checkpoint(s, t)
    local u = CreateCheckpoint(1, s.x, s.y, s.z, t.x, t.y, t.z, 2.0, 204, 204, 1, 100, 0)
    local v = AddBlipForCoord(s.x, s.y, s.z)
    while #(VICE.getPlayerCoords() - s) > 4.0 do
        Citizen.Wait(0)
    end
    RemoveBlip(v)
    DeleteCheckpoint(u)
end

local function Waypoint(Y, Z, _)
    local v = AddBlipForCoord(Y.x, Y.y, Y.z)
    SetBlipRoute(v, true)
    local u = CreateCheckpoint(1, Y.x, Y.y, Y.z, 0.0, 0.0, 0.0, 2.0, 204, 204, 1, 100, 0)
    local a0 = Z and 10.0 or 5.0
    while #(VICE.getPlayerCoords() - Y) > a0 do
        if _ then
            _()
        end
        Citizen.Wait(0)
    end
    RemoveBlip(v)
    DeleteCheckpoint(u)
end

local thrownGas = false

RegisterNetEvent("VICE:client:VangelicoSetup")
AddEventHandler("VICE:client:VangelicoSetup", function(value, issue)
    if value then
        h = "Head over to the ~g~Vangelico Jewelry Store."
        Waypoint(vector3(-574.37310791016,-281.93734741211,35.041473388672 -1.0), true)
        tVICE.FreezePlayerControls(true)
        h = "You will need to throw the BZ gas into the ~g~air vent."
        viewingHeist = true
        local cam1 = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam1, -621.98114013672,-225.19223022461,64.831901550293)
        SetCamRot(cam1, 0.0, 0.0, 0.0, 2)
        SetCamFov(cam1, 50.0)
        PointCamAtCoord(cam1, -622.4311, -233.6548, 58.41259)
        RenderScriptCams(true, false, 0, true, true)
        Wait(5500)
        h = "You will be stealing ~g~jewelry~s~ from the Vangelico jewelry store."
        SetCamCoord(cam1, -635.18524169922,-240.24458312988,38.096332550049)
        PointCamAtCoord(cam1, -631.68206787109,-237.7705078125,38.075538635254)
        Wait(3000)
        h = "Be quick, You only have 2 Minutes until the ~b~police ~s~are notified once inside."
        local cam2 = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam2, -629.4462890625,-235.99864196777,39.481147766113)
        PointCamAtCoord(cam2, -621.93212890625,-230.94522094727,38.056995391846)
        SetCamActiveWithInterp(cam2, cam1, 5000, true, true)
        Wait(9000)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam2, false)
        tVICE.FreezePlayerControls(false)
        viewingHeist = false
        TriggerEvent('VICE:client:toggleHeistMenu', true)
        gasBlip = addBlip(vector3(-622.4311, -233.6548, 58.41259), 310, 2, "Throw Gas")
        h = "Locate the ~g~air vent."
        Checkpoint(vector3(-625.87927246094,-216.50782775879,59.425590515137 - 1.0), vector3(-625.87927246094,-216.50782775879,59.425590515137 - 1.0))
        while true do
            local ped = PlayerPedId()
            local pedCo = GetEntityCoords(ped)
            local dist = #(pedCo - vector3(-622.4311, -233.6548, 58.41259))
            if dist <= 30.0 and not hasVangelicoStarted then
                h = "Throw the BZ gas into the ~g~air vent."
                DrawMarker(1, -622.4311, -233.6548, 58.41259, 0, 0, 0, 0, 0, 0, 0.8, 0.8, 1.0, 237, 197, 66, 255, false, false)
                if IsProjectileTypeWithinDistance(-622.4311, -233.6548, 58.41259, GetHashKey('WEAPON_BZGAS'), 1.0, true) then
                    h = nil
                    RemoveWeaponFromPed(VICE.getPlayerPed(), GetHashKey('WEAPON_BZGAS'))
                    TriggerServerEvent("VICE:server:syncGas")
                    break
                end
            end
            Wait(1)
        end
    else
        VICE.notify(issue)
    end
end)

-- [[ Hack things ]] --

RegisterNetEvent("VICE:jewelrySyncDoor",function(Value)
    while Door == 0 do
        Citizen.Wait(0)
    end
    FreezeEntityPosition(Door, Value)
end)

RegisterNetEvent("VICE:jewelryComputerHackArea",function(U)
    if U then
        i = tVICE.addMarker(cfgjew.hackComputerCoords.x,cfgjew.hackComputerCoords.y,cfgjew.hackComputerCoords.z,0.4,0.4,0.5,200,0,0,255,30,27,false,false,false)
        enter_hackJewelryComputer = function()
            if not globalOnPoliceDuty then
                drawNativeNotification("Press ~INPUT_CONTEXT~ to hack the computer")
            end
        end
        exit_hackJewelryComputer = function()
        end
        ontick_hackJewelryComputer = function()
            if not globalOnPoliceDuty then
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent("VICE:jewelryHackComputer")
                end
            end
        end
        VICE.createArea("jewelry_hack_computer",cfgjew.hackComputerCoords,1.25,10,enter_hackJewelryComputer,exit_hackJewelryComputer,ontick_hackJewelryComputer,{})
    else
        tVICE.removeArea("jewelry_hack_computer")
        tVICE.removeMarker(i)
    end
end)

RegisterNetEvent("VICE:jewelryHeistReady", function(T)
    if T then
        h = tVICE.addMarker(cfgjew.hackDoorCoords.x, cfgjew.hackDoorCoords.y, cfgjew.hackDoorCoords.z, 0.4, 0.4, 0.5, 200, 0, 0, 255, 30, 27, false, false, false)
        enter_hackJewelryDoor = function()
            if not globalOnPoliceDuty then
                drawNativeNotification("Press ~INPUT_CONTEXT~ to hack the keypad")
            end
        end
        exit_hackJewelryDoor = function() end
        ontick_hackJewelryDoor = function()
            if not globalOnPoliceDuty then
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent("VICE:jewelryHackDoor")
                end
            end
        end
        VICE.createArea("jewelry_hack_door", cfgjew.hackDoorCoords, 1.25, 10, enter_hackJewelryDoor, exit_hackJewelryDoor, ontick_hackJewelryDoor, {})
    else
        tVICE.removeArea("jewelry_hack_door")
        tVICE.removeMarker(h)
    end
end)

RegisterCommand("doorhack", function()
    if VICE.getUserId() == 1 then
        TriggerEvent("VICE:jewelryStartDoorHackSf")
    end
end)

RegisterCommand("computerhack", function()
    if VICE.getUserId() == 1 then 
        TriggerEvent("VICE:jewelryStartComputerHackSf")
    end
end)

AddEventHandler("VICE:onClientSpawn",function(a3, a4)
    if a4 then
        AddRelationshipGroup("aiHeist")
        Citizen.Wait(10000)
        Door = GetClosestObjectOfType(cfgjew.hackDoorCoords.x,cfgjew.hackDoorCoords.y,cfgjew.hackDoorCoords.z,2.0,"v_ilev_j2_door",false,false,false)
        FreezeEntityPosition(Door, true)
    end
end)

AddEventHandler("VICE:onClientSpawn", function(a3, a4)
    if a4 then
        enter_jewelryTeleporterEnter = function()
            drawNativeNotification("Press ~INPUT_CONTEXT~ to exit via the roof")
        end

        exit_jewelryTeleporterEnter = function() end

        ontick_jewelryTeleporterEnter = function()
            if IsControlJustPressed(0, 38) then
                SetEntityHeading(VICE.getPlayerPed(), 217.38)
                tVICE.teleport(cfgjew.exitTeleporterCoords.x, cfgjew.exitTeleporterCoords.y, cfgjew.exitTeleporterCoords.z)
            end
        end

        tVICE.addBlip(cfgjew.enterTeleporterCoords.x, cfgjew.enterTeleporterCoords.y, cfgjew.enterTeleporterCoords.z, 617, 0, "Jewelry Store", 0.7)
        tVICE.addMarker(cfgjew.enterTeleporterCoords.x, cfgjew.enterTeleporterCoords.y, cfgjew.enterTeleporterCoords.z - 1, 0.4, 0.4, 0.5, 255, 255, 255, 255, 30, 27, false, false, false)
        VICE.createArea("jewelry_teleport", cfgjew.enterTeleporterCoords, 1.25, 10, enter_jewelryTeleporterEnter, exit_jewelryTeleporterEnter, ontick_jewelryTeleporterEnter)

        enter_jewelryTeleporterExit = function()
            drawNativeNotification("Press ~INPUT_CONTEXT~ to enter the jewelry store")
        end

        exit_jewelryTeleporterExit = function() end

        ontick_jewelryTeleporterExit = function()
            if IsControlJustPressed(0, 38) then
                SetEntityHeading(VICE.getPlayerPed(), 217.38)
                tVICE.teleport(cfgjew.enterTeleporterCoords.x, cfgjew.enterTeleporterCoords.y, cfgjew.enterTeleporterCoords.z)
            end
        end

        tVICE.addMarker(cfgjew.exitTeleporterCoords.x, cfgjew.exitTeleporterCoords.y, cfgjew.exitTeleporterCoords.z - 1, 0.4, 0.4, 0.5, 255, 255, 255, 255, 30, 27, false, false, false)
        VICE.createArea("jewelry_teleport2", cfgjew.exitTeleporterCoords, 1.25, 10, enter_jewelryTeleporterExit, exit_jewelryTeleporterExit, ontick_jewelryTeleporterExit)
    end
end)

RegisterNetEvent("VICE:jewelryStartDoorHackSf", function()
    if VICE.getUserId() == 1 then
        TriggerServerEvent("VICE:jewelryDoorHackSuccess")
        VICE.notify("~g~Succesfully hacked!")
        return
    end
    Citizen.CreateThread(function()
        Wait(2500)
        m = true
        hackBegin("door")
    end)
    TriggerServerEvent('VICE:server:notifyPolice')
    TriggerEvent("utk_fingerprint:Start", 4, 1, 2, function(K, L)
        if K then
            VICE.notify("~g~Succesfully hacked!")
            TriggerServerEvent("VICE:jewelryDoorHackSuccess")
        else
            VICE.notify("~r~Failed. Reason: " .. L)
            TriggerServerEvent("VICE:jewelryDoorHackFailed")
        end
        m = false
    end)
end)

RegisterNetEvent("VICE:jewelryStartComputerHackSf", function()
    if VICE.getUserId() == 1 then
        TriggerServerEvent("VICE:jewelryComputerHackSuccess")
        VICE.notify("~g~Succesfully hacked!")
        return
    end
    Citizen.CreateThread(function()
        Wait(2500)
        m = true
        hackBegin("computer")
    end)

    startDataCrack(5, function(K)
        if K then
            TriggerServerEvent("VICE:jewelryComputerHackSuccess")
        else
            TriggerServerEvent("VICE:jewelryComputerHackFailed")
        end
        m = false
    end)
end)

--[[ Events ]] --

startTimer = false
RegisterNetEvent("VICE:client:BeginVangelicoHeist")
AddEventHandler("VICE:client:BeginVangelicoHeist", function()
    hasVangelicoStarted = true
    Wait(2500)
    VICE.PlayCutscene('JH_2A_MCS_1')
    RemoveBlip(gasBlip)
    TriggerServerEvent('VICE:server:startGas')
    startTimer = true
    local random = math.random(1, 4)
    local glassConfig = Config.VangelicoInside['glassCutting']
    loadModel(glassConfig['rewards'][random]['object']['model'])
    loadModel(glassConfig['rewards'][random]['displayObj']['model'])
    loadModel('h4_prop_h4_glass_disp_01a')
    local glass = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01a'), -617.4622, -227.4347, 37.057, 1, 1, 0)
    SetEntityHeading(glass, -53.06)
    local reward = CreateObject(GetHashKey(glassConfig['rewards'][random]['object']['model']), glassConfig['rewardPos'].xy, glassConfig['rewardPos'].z + 0.195, 1, 1, 0)
    SetEntityHeading(reward, glassConfig['rewards'][random]['object']['rot'])
    local rewardDisp = CreateObject(GetHashKey(glassConfig['rewards'][random]['displayObj']['model']), glassConfig['rewardPos'], 1, 1, 0)
    SetEntityRotation(rewardDisp, glassConfig['rewards'][random]['displayObj']['rot'])
    TriggerServerEvent('VICE:server:globalObject', glassConfig['rewards'][random]['object']['model'], random)

    for k, v in pairs(Config.VangelicoInside['painting']) do
        loadModel(v['object'])
        VangelicoHeist['painting'][k] = CreateObjectNoOffset(GetHashKey(v['object']), v['objectPos'], 1, 0, 0)
        SetEntityRotation(VangelicoHeist['painting'][k], 0, 0, v['objHeading'], 2, true)
    end
    TriggerServerEvent('VICE:server:insideLoop')
end)

RegisterNetEvent('VICE:client:globalObject')
AddEventHandler('VICE:client:globalObject', function(obj, index)
    VangelicoHeist['globalObject'] = obj
    VangelicoHeist['globalItem'] = Config.VangelicoInside['glassCutting']['rewards'][index]['item']
end)

RegisterNetEvent('VICE:client:insideLoop')
AddEventHandler('VICE:client:insideLoop', function()
    h = "Head inside the ~g~Vangelico jewelry store."
    Checkpoint(vector3(-631.30395507812,-237.4510345459,38.075439453125 - 1.0), vector3(-631.30395507812,-237.4510345459,38.075439453125 - 1.0))
    insideLoop = true
    Citizen.CreateThread(function()
        while insideLoop do
            local ped = PlayerPedId()
            local pedCo = GetEntityCoords(ped)
            local sleep = 1000
            local dist = #(pedCo - vector3(-617.4622, -227.4347, 37.057))

            if not VangelicoHeist['gasMask'] then
                h="You will suffer casualties if you do not wear a ~g~gas mask."
            end
            if dist <= 1.5 and not Config.VangelicoInside['glassCutting']['loot'] and not busy then
                sleep = 1
                ShowHelpNotification("Press ~INPUT_PICKUP~ when next to the enclosure to steal the item.")
                if IsControlJustPressed(0, 38) then
                    Config.OverheatScene()
                end
            end
            if VangelicoHeist['gasMask'] then
                if dist >= 40.0 and robber and TotalSum >= 3000000 then
                    TriggerServerEvent("VICE:server:winnerSRV")
                    break
                elseif dist >= 40.0 and robber then
                    h="Get back inside, At least ~g~£3,000,000~s~ worth of items is required."
                end
            end

            for k, v in pairs(Config.VangelicoInside['painting']) do
                local dist = #(pedCo - v['objectPos'])

                if dist <= 1.5 and not v['loot'] and not busy then
                    sleep = 1
                    ShowHelpNotification("Press ~INPUT_PICKUP~ when next to a painting to steal it.")
                    if IsControlJustPressed(0, 38) then
                        PaintingScene(k)
                    end
                end
            end
            for k, v in pairs(Config.VangelicoInside['smashScenes']) do
                local dist = #(pedCo - v['objPos'])
            
                if not v['marker'] and not v['smashed'] and VICE.hasHackedComputer() then
                    v['marker'] = tVICE.addMarker(v['objPos'].x, v['objPos'].y, v['objPos'].z + 0.35, 0.2, 0.2, 0.2, 255, 255, 0, 200, 30, 0, false, true, false)
                end
            end
            
            for k, v in pairs(Config.VangelicoInside['smashScenes']) do
                local dist = #(pedCo - v['objPos'])
            
                if dist <= 1.3 and not v['loot'] and not busy then
                    sleep = 1
                    ShowHelpNotification("Press ~INPUT_PICKUP~ when next to a cabinet to steal jewelry.")
                    if IsControlJustPressed(0, 38) then
                        if VICE.hasHackedComputer() then
                            if GetSelectedPedWeapon(PlayerPedId()) ~= `WEAPON_UNARMED` then
                                TriggerEvent("VICE:client:smash", true, k)
                                v['smashed'] = true
                                if v['marker'] then
                                    TriggerServerEvent("VICE:server:syncMarker", v)
                                else
                                    print("No marker to remove for cabinet: ", k)
                                end
                            else
                                VICE.notify("~r~You need something to break this cabinet with.")
                            end
                        else
                            VICE.notify("~r~Unable to break the cabinet, hack the computer first.")
                        end
                    end
                end
            end
            if dist <= 40.0 and VangelicoHeist['gasMask'] then
                if not robber and VICE.hasHackedComputer() then
                    h = "Steal the ~g~jewerly."
                elseif not VICE.hasHackedComputer() then
                    h = "Hack the ~g~computer."
                elseif robber and TotalSum <= 3000000 then
                    h = "Target goal of ~g~£3,000,000."
                elseif robber and TotalSum >= 3000000 then
                    h = "You may leave, you can still ~g~steal~s~ more items."
                end
            end
            
            Citizen.Wait(1)
        end
    end)
end)

RegisterNetEvent('VICE:client:lootSync')
AddEventHandler('VICE:client:lootSync', function(ggg, index)
    if index then
        Config.VangelicoInside[ggg][index]['loot'] = true
    else
        Config.VangelicoInside[ggg]['loot'] = true
    end
end)

RegisterNetEvent('VICE:client:markerSync')
AddEventHandler('VICE:client:markerSync', function(index)
    tVICE.removeMarker(index['marker'])
    index['marker'] = nil
end)

RegisterNetEvent("VICE:client:smash")
AddEventHandler("VICE:client:smash", function(value, index)
    if value then
        local ped = PlayerPedId()
        robber = true
        busy = true
        TriggerServerEvent('VICE:server:lootSync', 'smashScenes', index)
        local pedCo = GetEntityCoords(ped)
        local pedRotation = GetEntityRotation(ped)
        local animDict = 'missheist_jewel'
        local ptfxAsset = "scr_jewelheist"
        local particleFx = "scr_jewel_cab_smash"
        loadAnimDict(animDict)
        loadPtfxAsset(ptfxAsset)
        local sceneConfig = Config.VangelicoInside['smashScenes'][index]
        SetEntityCoords(ped, sceneConfig['scenePos'])
        local anims = {
            {'smash_case_necklace', 300},
            {'smash_case_d', 300},
            {'smash_case_e', 300},
            {'smash_case_f', 300}
        }
        local selected = ''
        repeat
            selected = anims[math.random(1, #anims)]
        until selected ~= prevAnim
        prevAnim = selected

        if index == 4 or index == 10 or index == 14 or index == 8 then
            selected = {'smash_case_necklace_skull', 300}
        end
        
        cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, 0, 0, 0, 0)
        tVICE.FreezePlayerControls(true)
        scene = NetworkCreateSynchronisedScene(sceneConfig['scenePos'], sceneConfig['sceneRot'], 2, true, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(ped, scene, animDict, selected[1], 1.0, 2.0, 1, 0, 1148846080, 0)
        NetworkStartSynchronisedScene(scene)
        PlayCamAnim(cam, 'cam_' .. selected[1], animDict, sceneConfig['scenePos'], sceneConfig['sceneRot'], 0, 2)

        Wait(300)

        TriggerServerEvent('VICE:server:smashSync', sceneConfig)
        for i = 1, 5 do
            PlaySoundFromCoord(-1, "Glass_Smash", sceneConfig['objPos'], 0, 0, 0)
        end
        SetPtfxAssetNextCall(ptfxAsset)
        StartNetworkedParticleFxNonLoopedAtCoord(particleFx, sceneConfig['objPos'], 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
        Wait(GetAnimDuration(animDict, selected[1]) * 1000 - 1000)
        tVICE.FreezePlayerControls(false)
        random = math.random(1, #Config.VangelicoHeist['smashRewards'])
        TriggerServerEvent('VICE:server:rewardItem', Config.VangelicoHeist['smashRewards'][random]['item'])
        ClearPedTasks(PlayerPedId())
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        busy = false
    else
        VICE.notify("~r~You need something to break this cabinet with.")
    end
end)

local eventTriggered = false

RegisterNetEvent("VICE:client:TotalSum")
AddEventHandler("VICE:client:TotalSum", function(value)
    if value == 0 then
        TotalSum = 0
        incrementing = false
        eventTriggered = false
    else
        targetSum = value
        incrementing = true
    end
end)

RegisterNetEvent("VICE:GenericAlarm", function()
    local L = vector3(-624.55065917969,-232.79370117188,38.05700302124) 
    while not RequestScriptAudioBank("Alarms", false) do
        Citizen.Wait(0)
    end
    local X = GetSoundId()
    PlaySoundFromCoord(X, "Burglar_Bell", L.x, L.y, L.z, "Generic_Alarms", false, 0.05, false)
    Citizen.Wait(60000)
    StopSound(X)
    ReleaseSoundId(X)
end)

RegisterNetEvent('VICE:client:smashSync')
AddEventHandler('VICE:client:smashSync', function(sceneConfig)
    CreateModelSwap(sceneConfig['objPos'], 0.3, GetHashKey(sceneConfig['oldModel']), GetHashKey(sceneConfig['newModel']), 1)
end)

RegisterNetEvent('VICE:client:startGas')
AddEventHandler('VICE:client:startGas', function()
    local ptfxAsset = "scr_jewelheist"
    local particleFx = "scr_jewel_fog_volume"
    loadPtfxAsset(ptfxAsset)
    SetPtfxAssetNextCall(ptfxAsset)
    ptfx = StartParticleFxLoopedAtCoord(particleFx, -622.0, -231.0, 38.0, 0.0, 0.0, 0.0, 0.5, false, false, false, false)
    gasLoop = true
    Citizen.CreateThread(function()
        while gasLoop do
            local ped = PlayerPedId()
            local pedCo = GetEntityCoords(ped)
            local cu = vector3(-622.30, -230.82, 38.0570)
            local dist = #(pedCo - cu)

            if dist <= 10.0 and not VangelicoHeist['gasMask'] then
                ApplyDamageToPed(ped, 3, false)
                Citizen.Wait(1000)
            end
            Citizen.Wait(1)
        end
    end)
end)

RegisterNetEvent('VICE:client:wearMask')
AddEventHandler('VICE:client:wearMask', function()
    VangelicoHeist['gasMask'] = not VangelicoHeist['gasMask']
    if VangelicoHeist['gasMask'] then
        loadAnimDict('mp_masks@standard_car@ds@')
        TaskPlayAnim(PlayerPedId(), 'mp_masks@standard_car@ds@', 'put_on_mask', 8.0, 8.0, 800, 16, 0, false, false, false)
        SetPedComponentVariation(PlayerPedId(), 1, Config.VangelicoHeist['gasMask']['clothNumber'], 0, 1)
    else
        loadAnimDict('mp_masks@standard_car@ds@')
        TaskPlayAnim(PlayerPedId(), 'mp_masks@standard_car@ds@', 'put_on_mask', 8.0, 8.0, 800, 16, 0, false, false, false)
        SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 1)
    end
end)

RegisterNetEvent('VICE:client:resetHeist')
AddEventHandler('VICE:client:resetHeist', function()
    insideLoop = false
    gasLoop = false
    for k, v in pairs(Config.VangelicoInside['smashScenes']) do
        v['loot'] = false
        CreateModelSwap(v['objPos'], 0.3, GetHashKey(v['newModel']), GetHashKey(v['oldModel']), 1)
    end
    for k, v in pairs(Config.VangelicoInside['painting']) do
        v['loot'] = false
        object = GetClosestObjectOfType(v['objectPos'], 1.0, GetHashKey(v['object']), 0, 0, 0)
        DeleteObject(object)
    end
    Config.VangelicoInside['glassCutting']['loot'] = false
    glassObjectDel = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01a'), 0, 0, 0)
    glassObjectDel2 = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01b'), 0, 0, 0)
    DeleteObject(glassObjectDel)
    DeleteObject(glassObjectDel2)
    StopParticleFxLooped(ptfx, 1)
end)
RegisterNetEvent("VICE:client:outside")
AddEventHandler("VICE:client:outside", function()
    h = "Meet at the ~g~drop off location ~s~ to sell the jewerly."
    Waypoint(vector3(Config.VangelicoHeist['finishHeist']['buyerPos'].x,Config.VangelicoHeist['finishHeist']['buyerPos'].y,Config.VangelicoHeist['finishHeist']['buyerPos'].z), true)
    while true do
        local players = GetPlayers()
        local playersInDist = 0
        for i=1, #players do
            if #(GetEntityCoords(GetPlayerPed(players[i])) - Config.VangelicoHeist['finishHeist']['buyerPos']) <= 15.0 then
                playersInDist = playersInDist + 1
            end
        end
        if #(GetEntityCoords(PlayerPedId()) - Config.VangelicoHeist['finishHeist']['buyerPos']) <= 15.0 then
            h = "Wait for the rest of the ~b~team~s~ to arrive."
            if playersInDist == #heistTeam then
                h = "You will receive ~g~£" .. getMoneyStringFormatted(TotalSum) .. " ~s~for the jewerly."
                TriggerServerEvent("VICE:server:syncWinnerScreen")
                break
            end
        end
        Wait(1)
    end
end)

RegisterNetEvent("VICE:client:syncWinnerScreen")
AddEventHandler("VICE:client:syncWinnerScreen", function()
    PlayCutscene('hs3f_all_drp3', Config.VangelicoHeist['finishHeist']['buyerPos'])
    TriggerServerEvent('VICE:server:sellRewardItems',TotalSum)
    h = nil
end)

-- [[ Winners Screen ]] --

local function HeistComplete(P, Q, R, S,playerNames)
    ClearTimecycleModifier()
    local T = {
        handle = Scaleform("MP_CELEBRATION"),
        handle2 = Scaleform("MP_CELEBRATION_BG"),
        handle3 = Scaleform("MP_CELEBRATION_FG")
    }
    for U, V in pairs(T) do
        V.RunFunction("CLEANUP", {"HEIST_COMPLETE"})
        V.RunFunction("CREATE_STAT_WALL", {"HEIST_COMPLETE", "HUD_COLOUR_BLACK", "70.0"})
        V.RunFunction(
            "SET_PAUSE_DURATION",
            {function()
                    ScaleformMovieMethodAddParamFloat(2.5)
                end}
        )
        if S ~= 0 then
            V.RunFunction("ADD_CASH_TO_WALL", {"HEIST_COMPLETE", S, true})
        end
        V.RunFunction("ADD_WINNER_TO_WALL", {"HEIST_COMPLETE", "CELEB_WINNER", P, playerNames, 0, false, "", false})
        V.RunFunction("ADD_BACKGROUND_TO_WALL", {"HEIST_COMPLETE", 75, 0})
        V.RunFunction("SHOW_STAT_WALL", {"HEIST_COMPLETE"})
    end
    return T.handle, T.handle2, T.handle3
end

RegisterNetEvent("VICE:client:winVangelicoHeist")
AddEventHandler("VICE:client:winVangelicoHeist", function(sum, playerNames)
    ExecuteCommand("hideui")
    Citizen.CreateThread(function()
        robber = false
        hasVangelicoStarted = false
        heistInSetup = false
        inHeist = false
        isOwner = false
        startTimer = false
        heistTeam = {}
        local W = false
        local X, Y, Z = HeistComplete("Vangelico Heist", 2, 100, sum, playerNames) 
        if not W then
            W = true
        end
        SetTimeout(10000,function()
            W = false
        end)
        while W do
            Wait(0)
            HideHudAndRadarThisFrame()
            DrawScaleformMovieFullscreenMasked(Y.Handle, Z.Handle, 255, 255, 255, 255)
            X.Render2D()
        end
    end)
    ExecuteCommand("showui")
end)

-- [[ Functions ]] --

function PaintingScene(sceneId)
    if GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey('WEAPON_SWITCHBLADE') then 
        VICE.notify("~r~Missing 1x Switchblade") 
        return 
    end
    local ped = PlayerPedId()
    if ped then
        TriggerServerEvent('VICE:server:lootSync', 'painting', sceneId)
        robber = true
        busy = true
        local pedCo, pedRotation = GetEntityCoords(ped), vector3(0.0, 0.0, 0.0)
        local scenes = {false, false, false, false}
        local animDict = "anim_heist@hs3f@ig11_steal_painting@male@"
        scene = Config.VangelicoInside['painting'][sceneId]
        sceneObject = GetClosestObjectOfType(scene['objectPos'], 1.0, GetHashKey(scene['object']), 0, 0, 0)
        scenePos = scene['scenePos']
        sceneRot = scene['sceneRot']
        loadAnimDict(animDict)
        for k, v in pairs(Config.ArtHeist['objects']) do
            loadModel(v)
            Config.ArtHeist['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 1, 0)
        end
        for i = 1, 10 do
            Config.ArtHeist['scenes'][i] = NetworkCreateSynchronisedScene(scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 2, true, false, 1065353216, 0, 1065353216)
            NetworkAddPedToSynchronisedScene(ped, Config.ArtHeist['scenes'][i], animDict, 'ver_01_' .. Config.ArtHeist['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
            NetworkAddEntityToSynchronisedScene(sceneObject, Config.ArtHeist['scenes'][i], animDict, 'ver_01_' .. Config.ArtHeist['animations'][i][3], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(Config.ArtHeist['sceneObjects'][1], Config.ArtHeist['scenes'][i], animDict, 'ver_01_' .. Config.ArtHeist['animations'][i][4], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(Config.ArtHeist['sceneObjects'][2], Config.ArtHeist['scenes'][i], animDict, 'ver_01_' .. Config.ArtHeist['animations'][i][5], 1.0, -1.0, 1148846080)
        end
        cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, 0, 3000, 1, 0)
        
        Config.ArtHeist['cuting'] = true
        local playerPed = VICE.getPlayerPed()
        FreezeEntityPosition(playerPed, true)
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][1])
        PlayCamAnim(cam, 'ver_01_top_left_enter_cam_ble', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        Wait(3000)
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][2])
        PlayCamAnim(cam, 'ver_01_cutting_top_left_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        repeat
            ShowHelpNotification("Press ~INPUT_MOVE_RIGHT_ONLY~ to cut right.")
            if IsControlJustPressed(0, 35) then
                scenes[1] = true
            end
            Wait(1)
        until scenes[1] == true
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][3])
        PlayCamAnim(cam, 'ver_01_cutting_top_left_to_right_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        Wait(3000)
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][4])
        PlayCamAnim(cam, 'ver_01_cutting_top_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        repeat
            ShowHelpNotification("Press ~INPUT_MOVE_DOWN_ONLY~ to cut down.")
            if IsControlJustPressed(0, 33) then
                scenes[2] = true
            end
            Wait(1)
        until scenes[2] == true
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][5])
        PlayCamAnim(cam, 'ver_01_cutting_right_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        Wait(3000)
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][6])
        PlayCamAnim(cam, 'ver_01_cutting_bottom_right_idle_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        repeat
            ShowHelpNotification("Press ~INPUT_MOVE_LEFT_ONLY~ to cut left.")
            if IsControlJustPressed(0, 34) then
                scenes[3] = true
            end
            Wait(1)
        until scenes[3] == true
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][7])
        PlayCamAnim(cam, 'ver_01_cutting_bottom_right_to_left_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        Wait(3000)
        repeat
            ShowHelpNotification("Press ~INPUT_MOVE_DOWN_ONLY~ to cut down.")
            if IsControlJustPressed(0, 33) then
                scenes[4] = true
            end
            Wait(1)
        until scenes[4] == true
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][9])
        PlayCamAnim(cam, 'ver_01_cutting_left_top_to_bottom_cam', animDict, scenePos['xy'], scenePos['z'] - 1.0, sceneRot, 0, 2)
        Wait(1500)
        NetworkStartSynchronisedScene(Config.ArtHeist['scenes'][10])
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        Wait(7500)
        TriggerServerEvent('VICE:server:rewardItem', "Painting")
        ClearPedTasks(ped)
        FreezeEntityPosition(playerPed, false)
        RemoveAnimDict(animDict)
        for k, v in pairs(Config.ArtHeist['sceneObjects']) do
            DeleteObject(v)
        end
        DeleteObject(sceneObject)
        DeleteEntity(sceneObject)
        Config.ArtHeist['sceneObjects'] = {}
        Config.ArtHeist['scenes'] = {}
        scenes = {false, false, false, false}
        busy = false
    end
end

function Config.OverheatScene()
    local hasItem = true
    if hasItem then
        TriggerServerEvent('VICE:server:lootSync', 'glassCutting')
        robber = true
        busy = true
        local ped = PlayerPedId()
        local pedCo, pedRotation = GetEntityCoords(ped), GetEntityRotation(ped)
        local animDict = 'anim@scripted@heist@ig16_glass_cut@male@'
        sceneObject = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 1.0, GetHashKey('h4_prop_h4_glass_disp_01a'), 0, 0, 0)
        scenePos = GetEntityCoords(sceneObject)
        sceneRot = GetEntityRotation(sceneObject)
        globalObj = GetClosestObjectOfType(-617.4622, -227.4347, 37.057, 5.0, GetHashKey(VangelicoHeist['globalObject']), 0, 0, 0)
        loadAnimDict(animDict)
        RequestScriptAudioBank('DLC_HEI4/DLCHEI4_GENERIC_01', -1)

        cam = CreateCam("DEFAULT_ANIMATED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, 0, 3000, 1, 0)

        tVICE.FreezePlayerControls(true)

        for k, v in pairs(Config.Overheat['objects']) do
            loadModel(v)
            Config.Overheat['sceneObjects'][k] = CreateObject(GetHashKey(v), pedCo, 1, 1, 0)
        end

        local newObj = CreateObject(GetHashKey('h4_prop_h4_glass_disp_01b'), GetEntityCoords(sceneObject), 1, 1, 0)
        SetEntityHeading(newObj, GetEntityHeading(sceneObject))

        for i = 1, #Config.Overheat['animations'] do
            Config.Overheat['scenes'][i] = NetworkCreateSynchronisedScene(scenePos, sceneRot, 2, true, false, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(ped, Config.Overheat['scenes'][i], animDict, Config.Overheat['animations'][i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
            NetworkAddEntityToSynchronisedScene(Config.Overheat['sceneObjects'][1], Config.Overheat['scenes'][i], animDict, Config.Overheat['animations'][i][2], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(Config.Overheat['sceneObjects'][2], Config.Overheat['scenes'][i], animDict, Config.Overheat['animations'][i][3], 1.0, -1.0, 1148846080)
            if i ~= 5 then
                NetworkAddEntityToSynchronisedScene(sceneObject, Config.Overheat['scenes'][i], animDict, Config.Overheat['animations'][i][4], 1.0, -1.0, 1148846080)
            else
                NetworkAddEntityToSynchronisedScene(newObj, Config.Overheat['scenes'][i], animDict, Config.Overheat['animations'][i][4], 1.0, -1.0, 1148846080)
            end
        end

        local sound1 = GetSoundId()
        local sound2 = GetSoundId()

        NetworkStartSynchronisedScene(Config.Overheat['scenes'][1])
        PlayCamAnim(cam, 'enter_cam', animDict, scenePos, sceneRot, 0, 2)
        Wait(GetAnimDuration(animDict, 'enter') * 1000)

        -- NetworkStartSynchronisedScene(Config.Overheat['scenes'][2])
        -- PlayCamAnim(cam, 'idle_cam', animDict, scenePos, sceneRot, 0, 2)
        -- Wait(GetAnimDuration(animDict, 'idle') * 1000)

        NetworkStartSynchronisedScene(Config.Overheat['scenes'][3])
        PlaySoundFromEntity(sound1, "StartCutting", Config.Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
        loadPtfxAsset('scr_ih_fin')
        UseParticleFxAssetNextCall('scr_ih_fin')
        fire1 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_cut', Config.Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0, 1065353216, 1065353216, 1065353216, 0)
        PlayCamAnim(cam, 'cutting_loop_cam', animDict, scenePos, sceneRot, 0, 2)
        Wait(GetAnimDuration(animDict, 'cutting_loop') * 1000)
        StopSound(sound1)
        StopParticleFxLooped(fire1)

        NetworkStartSynchronisedScene(Config.Overheat['scenes'][4])
        PlaySoundFromEntity(sound2, "Config.Overheated", Config.Overheat['sceneObjects'][2], 'DLC_H4_anims_glass_cutter_Sounds', true, 80)
        UseParticleFxAssetNextCall('scr_ih_fin')
        fire2 = StartParticleFxLoopedOnEntity('scr_ih_fin_glass_cutter_overheat', Config.Overheat['sceneObjects'][2], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1065353216, 0.0, 0.0, 0.0)
        PlayCamAnim(cam, 'overheat_react_01_cam', animDict, scenePos, sceneRot, 0, 2)
        Wait(GetAnimDuration(animDict, 'overheat_react_01') * 1000)
        StopSound(sound2)
        StopParticleFxLooped(fire2)

        DeleteObject(sceneObject)
        NetworkStartSynchronisedScene(Config.Overheat['scenes'][5])
        Wait(2000)
        DeleteObject(globalObj)
        TriggerServerEvent('VICE:server:rewardItem', "Internal Organ")
        PlayCamAnim(cam, 'success_cam', animDict, scenePos, sceneRot, 0, 2)
        Wait(GetAnimDuration(animDict, 'success') * 1000 - 2000)
        DeleteObject(Config.Overheat['sceneObjects'][1])
        DeleteObject(Config.Overheat['sceneObjects'][2])
        tVICE.FreezePlayerControls(false)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(cam, false)
        busy = false
    else
        VICE.notify("~r~Missing 1x Cutter.")
    end
end

-- [[ Threads ]] --

Citizen.CreateThread(function()
    while true do
        if not VangelicoHeist['gasMask'] and VICE.inVangelico() then
            ShowHelpNotification("Press ~INPUT_DETONATE~ to equip the gas mask.")
            if IsControlJustPressed(0, 47) then
                TriggerEvent('VICE:client:wearMask')
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if VICE.inVangelico() then
            if incrementing then
                if TotalSum < targetSum then
                    TotalSum = TotalSum + targetSum / 200
                    if TotalSum > targetSum then
                        TotalSum = targetSum
                        incrementing = false
                    end
                end
            end
            if TotalSum > 0 and TotalSum < 3000000 then
                DrawGTATimerBar("TAKE ", string.format("£%s", getMoneyStringFormatted(TotalSum)), 3, 220,45,47, 255) --red
            elseif TotalSum > 0 and TotalSum > 3000000 then
                DrawGTATimerBar("TAKE ", string.format("£%s", getMoneyStringFormatted(TotalSum)), 3, 45, 220, 122, 255) --green
            end
            if timeLeft > 0 then
                local minutes = math.floor(timeLeft / 60)
                local seconds = timeLeft % 60
                DrawGTATimerBar("TIME TO LOOT: ",string.format("%d:%02d", minutes, seconds), 2, 220,45,47, 255) --red
            else
                DrawGTATimerBar("~r~TIME UP", "", 2)
                if not eventTriggered then
                    TriggerEvent('VICE:GenericAlarm')
                    eventTriggered = true
                end
            end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if startTimer and timeLeft > 0 and VICE.inVangelico() then
            timeLeft = timeLeft - 1
        end
        Citizen.Wait(1000)
    end
end)

function VICE.PlayCutscene(scene)
    ExecuteCommand("hideui")
    PlayCutscene(scene)
    ExecuteCommand("showui")
end

function PlayCutscene(cut, coords)
    while not HasThisCutsceneLoaded(cut) do 
        RequestCutscene(cut, 8)
        Wait(0) 
    end
    CreateCutscene(false, coords)
    Finish(coords)
    RemoveCutscene()
    DoScreenFadeIn(500)
end

function CreateCutscene(change, coords)
    local ped = PlayerPedId()
        
    local clone = ClonePedEx(ped, 0.0, false, true, 1)
    local clone2 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone3 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone4 = ClonePedEx(ped, 0.0, false, true, 1)
    local clone5 = ClonePedEx(ped, 0.0, false, true, 1)

    SetBlockingOfNonTemporaryEvents(clone, true)
    SetEntityVisible(clone, false, false)
    SetEntityInvincible(clone, true)
    SetEntityCollision(clone, false, false)
    FreezeEntityPosition(clone, true)
    SetPedHelmet(clone, false)
    RemovePedHelmet(clone, true)
    
    if change then
        SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
        RegisterEntityForCutscene(ped, 'MP_2', 0, GetEntityModel(ped), 64)
        
        SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
        RegisterEntityForCutscene(clone2, 'MP_1', 0, GetEntityModel(clone2), 64)
    else
        SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
        RegisterEntityForCutscene(ped, 'MP_1', 0, GetEntityModel(ped), 64)

        SetCutsceneEntityStreamingFlags('MP_2', 0, 1)
        RegisterEntityForCutscene(clone2, 'MP_2', 0, GetEntityModel(clone2), 64)
    end

    SetCutsceneEntityStreamingFlags('MP_3', 0, 1)
    RegisterEntityForCutscene(clone3, 'MP_3', 0, GetEntityModel(clone3), 64)
    
    SetCutsceneEntityStreamingFlags('MP_4', 0, 1)
    RegisterEntityForCutscene(clone4, 'MP_4', 0, GetEntityModel(clone4), 64)
    
    SetCutsceneEntityStreamingFlags('MP_5', 0, 1)
    RegisterEntityForCutscene(clone5, 'MP_5', 0, GetEntityModel(clone5), 64)
    
    Wait(10)
    if coords then
        StartCutsceneAtCoords(coords, 0)
    else
        StartCutscene(0)
    end
    Wait(10)
    ClonePedToTarget(clone, ped)
    Wait(10)
    DeleteEntity(clone)
    DeleteEntity(clone2)
    DeleteEntity(clone3)
    DeleteEntity(clone4)
    DeleteEntity(clone5)
    Wait(50)
    DoScreenFadeIn(250)
end

function Finish(coords)
    if coords then
        local tripped = false
        repeat
            Wait(0)
            if (timer and (GetCutsceneTime() > timer))then
                DoScreenFadeOut(250)
                tripped = true
            end
            if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
            DoScreenFadeOut(250)
            tripped = true
            end
        until not IsCutscenePlaying()
        if (not tripped) then
            DoScreenFadeOut(100)
            Wait(150)
        end
        return
    else
        Wait(18500)
        StopCutsceneImmediately()
    end
end

function addBlip(coords, sprite, colour, text)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

function loadPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do
        RequestNamedPtfxAsset(dict)
        Citizen.Wait(50)
	end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function ShowHelpNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, 50)
end

local function ag()
    if VICE.inVangelico() then
        if h then
            drawNativeText(h)
        end
        if NativeNoti then
            drawNativeNotification(NativeNoti)
        end
    end
end

function VICE.inVangelico()
    return inHeist
end

VICE.createThreadOnTick(ag)
local c = vector3(707.01, -966.64, 30.41)
tVICE.addMarker(c.x, c.y, c.z, 0.5, 0.5, 0.5, 10, 255, 81, 170, 50, 2, false, false, true)
tVICE.addBlip(c.x, c.y, c.z, 363, 26, "Heist Setup Factory")