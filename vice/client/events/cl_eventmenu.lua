CurrentEvent = {
    players = {},
    isHost = false,
    isActive = false,
    eventName = "",
    eventID = 0,
}

local EventTypes = {}
local selectedCategory,selectedLocation = nil,nil
local inEvent,ActiveEvent,EventProcessing = false,false,false
local cooldown = 0
-- local cfg = module("cfg/shared/cfg_dynamicraces")
-- [[ RageUI menus ]] -- 

RMenu.Add("VICE","EventMenu",RageUI.CreateMenu("","Event Menu",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_events", "vice_events"))
RMenu.Add("VICE","EventCatagory",RageUI.CreateSubMenu(RMenu:Get("VICE","EventMenu"),"","Event Menu",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_events", "vice_events"))
RMenu.Add("VICE","EventCreation",RageUI.CreateSubMenu(RMenu:Get("VICE","EventCatagory"),"","Event Menu",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_events", "vice_events"))

RMenu.Add("VICE","EventHostMenu",RageUI.CreateMenu("","Event Menu",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_events", "vice_events"))
RMenu.Add("VICE","EventHostClientMenu",RageUI.CreateMenu("","Event Menu",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_events", "vice_events"))
RageUI.CreateWhile(1.0,RMenu:Get("VICE","EventMenu"),function()
    RageUI.IsVisible(RMenu:Get("VICE","EventMenu"),true,false,false,function()
        if GetGameTimer() - cooldown > 3000 then
            TriggerServerEvent("VICE:RequestActiveEvent")
            cooldown = GetGameTimer()
        end
        RageUI.Separator(ActiveEvent and "~r~There is an event currently active" or "~g~There is no event currently active")
        if not ActiveEvent then
            for eventName,_ in pairs(EventTypes) do
                RageUI.ButtonWithStyle(eventName,"",{},true,function(Hovered, Active, Selected)
                    if Selected then
                        selectedCategory = eventName
                    end
                end,RMenu:Get("VICE","EventCatagory"))
            end
        else
            RageUI.ButtonWithStyle("~r~End Event","",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("VICE:EndEvent")
                end
            end)
        end
    end,function()
    end)
    RageUI.IsVisible(RMenu:Get("VICE","EventCatagory"),true,false,false,function()
        if selectedCategory ~= nil then
            for _,eventlocation in pairs(EventTypes[selectedCategory]) do
                RageUI.ButtonWithStyle(eventlocation,"",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                    if Selected then
                        selectedLocation = eventlocation
                    end
                end,RMenu:Get("VICE","EventCreation"))
            end
        end
    end,function()
    end)
    RageUI.IsVisible(RMenu:Get("VICE","EventCreation"),true,false,false,function()
        RageUI.Separator("You are about to create an event")
        RageUI.Separator("Event Type: "..selectedCategory)
        RageUI.Separator("Location: "..selectedLocation)
        RageUI.ButtonWithStyle("Create Event","",{},true,function(Hovered, Active, Selected)
            if Selected then
                if selectedCategory == "Race" then -- and cfg.dynamicRaces[selectedLocation].vehicleOptions then
                    VICE.prompt("Enter Spawn Code","",function(result)
                        if result ~= nil and result ~= "" then
                            TriggerServerEvent("VICE:CreateEvent",selectedCategory,selectedLocation,result)
                        end
                    end)
                else
                    TriggerServerEvent("VICE:CreateEvent",selectedCategory,selectedLocation)
                end
            end
        end)
        RageUI.ButtonWithStyle("Cancel","",{},true,function(Hovered, Active, Selected)
            if Selected then
                selectedCategory = nil
                selectedLocation = nil
            end
        end,RMenu:Get("VICE","EventMenu"))
    end,function()
    end)
    RageUI.IsVisible(RMenu:Get("VICE","EventHostMenu"),true,false,false,function()
        RageUI.Separator("~r~Min Players: 3")
        RageUI.Separator("~r~Admin Options")
        RageUI.ButtonWithStyle("~g~Start Event","",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            if Selected then
                TriggerServerEvent("VICE:StartEvent",CurrentEvent.eventID)
                print("startevent event triggered")
                
            end
        end)
        RageUI.ButtonWithStyle("~y~Start Event but leave","",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            if Selected then
                TriggerServerEvent("VICE:StartEvent",CurrentEvent.eventID,true)
            end
        end)
        RageUI.ButtonWithStyle("~r~End Event","",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            if Selected then
                TriggerServerEvent("VICE:EndEvent")
            end
        end)
        RageUI.Separator("~r~Players")
        for _,player in pairs(CurrentEvent.players) do
            RageUI.ButtonWithStyle(string.format("[%s] %s",player.source,player.name),string.format("Name: %s Temp ID: %s Perm ID: %s",player.name,player.source,player.user_id),{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            end)
        end
    end,function()
    end)
    RageUI.IsVisible(RMenu:Get("VICE","EventHostClientMenu"),true,false,false,function()
        RageUI.ButtonWithStyle("Leave Event","",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            if Selected then
               ExecuteCommand("leaveevent")
            end
        end)
        RageUI.Separator("~r~Players")
        for _,player in pairs(CurrentEvent.players) do
            RageUI.ButtonWithStyle(string.format("[%s] %s",player.source,player.name),string.format("Name: %s Temp ID: %s Perm ID: %s",player.name,player.source,player.user_id),{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
            end)
        end
    end,function()
    end)
end)


-- [[ Events ]] --

RegisterNetEvent("VICE:announceEventJoinable",function(P, U)
    if VICE.getPlayerCombatTimer() == 0 and not VICE.getHideEventAnnouncementFlag() then
        PlaySound(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", false, 0, true)
        tVICE.announceMpBigMsg("~b~" .. P .. " event has started!","/joinevent to enter, Win £10,000,000! - " .. tostring(U) .. " slots available.",15000)
    end
end)

RegisterNetEvent("VICE:OpenEventMenu",function(Types)
    RageUI.Visible(RMenu:Get("VICE","EventMenu"),not RageUI.Visible(RMenu:Get("VICE","EventMenu")))
    EventTypes = Types
end)

RegisterNetEvent("VICE:OpentHostEventMenu",function(ishost,eventID)
    if ishost then
        CurrentEvent.isHost = true
        RageUI.Visible(RMenu:Get("VICE","EventHostMenu"),not RageUI.Visible(RMenu:Get("VICE","EventHostMenu")))
    else
        RageUI.Visible(RMenu:Get("VICE","EventHostClientMenu"),not RageUI.Visible(RMenu:Get("VICE","EventHostClientMenu")))
    end
    CurrentEvent.eventID = eventID
end)

RegisterNetEvent("VICE:IsAnyEventActive",function(status)
    ActiveEvent = status
end)

RegisterNetEvent("VICE:EventSequence",function()
    EventProcessing = true
    StartSequenceCam()
end)

RegisterNetEvent("VICE:addEventPlayer",function(tbl)
    table.add(CurrentEvent.players,tbl)
end)

RegisterNetEvent("VICE:removeEventPlayer",function(tbl)
    for i = #CurrentEvent.players, 1, -1 do
        if CurrentEvent.players[i].user_id == tbl.user_id then
            table.remove(CurrentEvent.players, i)
        end
    end
end)

RegisterNetEvent("VICE:syncPlayers",function(tbl,eventID)
    CurrentEvent.players = tbl
    CurrentEvent.eventID = eventID
end)

RegisterNetEvent("VICE:EventStarting",function()
    CurrentEvent.isActive = true
    RageUI.Visible(RMenu:Get("VICE","EventHostClientMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventHostMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventCreation"),false)
    RageUI.Visible(RMenu:Get("VICE","EventMenu"),false)
end)

RegisterNetEvent("VICE:Closemenu",function()
    RageUI.Visible(RMenu:Get("VICE","EventHostClientMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventHostMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventCreation"),false)
    RageUI.Visible(RMenu:Get("VICE","EventMenu"),false)
end)

RegisterNetEvent("VICE:ClearEventData",function()
    VICE.stopEventSequence()
    RageUI.Visible(RMenu:Get("VICE","EventHostClientMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventHostMenu"),false)
    RageUI.Visible(RMenu:Get("VICE","EventCreation"),false)
    RageUI.Visible(RMenu:Get("VICE","EventMenu"),false)
    EventProcessing = false
    CurrentEvent.isActive,CurrentEvent.isHost,CurrentEvent.players,CurrentEvent.eventID = false,false,{},0
end)

-- [[ Functions ]] --

function tVICE.InMainEvent()
    return CurrentEvent.isActive or EventProcessing
end

function VICE.InAnyEvent()
    return CurrentEvent.isActive or EventProcessing or inDuel
end

function VICE.setPlayerInvisible(Status)
    local Ped = PlayerPedId()
    FreezeEntityPosition(Ped, Status)
    SetEntityInvincible(Ped, Status)
    SetEntityVisible(Ped, not Status, not Status)
end
local MainCamera = 0
local SecondaryCamera = 0
function StartSequenceCam()
    if EventProcessing then
        SetEntityVisible(VICE.getPlayerPed(), false, false)
        SetFocusPosAndVel(vector3(-77.84175, -1104.633, 33.12158))
        MainCamera =CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA",-77.84175,-1104.633,33.12158,0.0,0.0,0.0,65.0,false,2)
        PointCamAtCoord(MainCamera, -45.73187, -1097.881, 26.41541)
        SetCamActive(MainCamera, true)
        RenderScriptCams(true, true, 0, true, false)
        SecondaryCamera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA",-45.2044,-1128.317,33.12158,0.0,0.0,0.0,65.0,false,2)
        PointCamAtCoord(SecondaryCamera, -45.73187, -1097.881, 26.41541)
        SetCamActiveWithInterp(SecondaryCamera, MainCamera, 10000, 5, 5)
        Wait(10000)
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(177.9429, -901.3582, 46.75317))
            SetCamCoord(SecondaryCamera, vector3(178.9451, -991.0022, 47.74731))
            SetFocusPosAndVel(vector3(177.9429, -901.3582, 46.75317))
            PointCamAtCoord(MainCamera, 195.1253, -933.7582, 30.67834)
            PointCamAtCoord(SecondaryCamera, 195.1253, -933.7582, 30.67834)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 25000, 5, 5)
            Wait(25000)
        end
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(-3135.257, 1042.998, 30.15601))
            SetCamCoord(SecondaryCamera, vector3(-3123.837, 1133.525, 30.15601))
            SetFocusPosAndVel(vector3(-3147.073, 1088.374, 20.6864))
            PointCamAtCoord(MainCamera, -3147.073, 1088.374, 20.6864)
            PointCamAtCoord(SecondaryCamera, -3147.073, 1088.374, 20.6864)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 15000, 5, 5)
            Wait(15000)
        end
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(598.4967, 1122.923, 364.2878))
            SetCamCoord(SecondaryCamera, vector3(819.7582, 1057.543, 364.2878))
            SetFocusPosAndVel(vector3(732.5406, 1195.807, 326.359))
            PointCamAtCoord(MainCamera, 732.5406, 1195.807, 326.359)
            PointCamAtCoord(SecondaryCamera, 732.5406, 1195.807, 326.359)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 35000, 5, 5)
            Wait(35000)
        end
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(1658.914, 2526.369, 69.68567))
            SetCamCoord(SecondaryCamera, vector3(1751.934, 2507.947, 69.68567))
            SetFocusPosAndVel(vector3(1708.629, 2547.943, 45.55676))
            PointCamAtCoord(MainCamera, 1708.629, 2547.943, 45.55676)
            PointCamAtCoord(SecondaryCamera, 1708.629, 2547.943, 45.55676)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 35000, 5, 5)
            Wait(35000)
        end
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(1545.191, 6444.29, 35.64905))
            SetCamCoord(SecondaryCamera, vector3(1608.475, 6413.301, 35.64905))
            SetFocusPosAndVel(vector3(1588.536, 6456.923, 29.27991))
            PointCamAtCoord(MainCamera, 1588.536, 6456.923, 29.27991)
            PointCamAtCoord(SecondaryCamera, 1588.536, 6456.923, 29.27991)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 20000, 5, 5)
            Wait(20000)
        end
        if EventProcessing then
            ClearFocus()
            SetCamCoord(MainCamera, vector3(-134.1758, -834.0527, 321.186))
            SetCamCoord(SecondaryCamera, vector3(-37.60879, -882.6725, 321.186))
            SetFocusPosAndVel(vector3(-73.8989, -817.5824, 319.4843))
            PointCamAtCoord(MainCamera, -73.8989, -817.5824, 319.4843)
            PointCamAtCoord(SecondaryCamera, -73.8989, -817.5824, 319.4843)
            SetCamActiveWithInterp(SecondaryCamera, MainCamera, 25000, 5, 5)
            Wait(25000)
        end
        StartSequenceCam()
    end
end

function VICE.stopEventSequence(M)
    RageUI.ActuallyCloseAll()
    EventProcessing = false
    DestroyCam(MainCamera, false)
    DestroyCam(SecondaryCamera, false)
    if M == nil or M == true then
        RenderScriptCams(false, true, 0, true, false)
    else
        RenderScriptCams(false, false, 0, true, false)
    end
    ClearFocus()
    FreezeEntityPosition(VICE.getPlayerPed(), false)
    SetEntityVisible(VICE.getPlayerPed(), true, true)
end

-- [[ Threads ]] --

Citizen.CreateThread(function()
    while true do
        if EventProcessing then
            VICE.DrawNativeText("The command /leaveevent can be used at any time to return back to the main world.")
            if not RageUI.Visible(RMenu:Get("VICE","EventHostMenu")) and CurrentEvent.isHost then 
                RageUI.Visible(RMenu:Get("VICE","EventHostMenu"),true)
            end
            if not RageUI.Visible(RMenu:Get("VICE", "EventHostClientMenu")) and not CurrentEvent.isHost then
                RageUI.Visible(RMenu:Get("VICE", "EventHostClientMenu"), true)
            end
        end
        if CurrentEvent.isActive and CurrentEvent.eventName ~= "Race" then
            local PlayerCount = 0
            for _,A in pairs(CurrentEvent.players) do
                PlayerCount = PlayerCount + 1
            end
            VICE.DrawGTATimerBar("~y~Players:",PlayerCount,1)
            if CurrentEvent.eventName == "Dropzone" then
                VICE.DrawNativeText("The command /leaveevent can be used at any time to return back to the main world.")
            end
        end
        Wait((CurrentEvent.isActive or EventProcessing) and 0 or 1000)
    end
end)

function VICE.DrawNativeText(M)
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(M)
    EndTextCommandPrint(1000, 1)
end