local players = {}

RegisterNetEvent("VICE:SendPlayers")
AddEventHandler("VICE:SendPlayers", function(list)
    players = list or {}
end)

TriggerServerEvent("VICE:RequestPlayers")

RMenu.Add('eventsmenu', 'main', RageUI.CreateMenu("", "Events Menu", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "adminmenu"))
RMenu.Add('eventsmenu', 'players', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'main'), "All Players", ""))
RMenu.Add('eventsmenu', 'searchoptions', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'main'), "Search Players", ""))
RMenu.Add('eventsmenu', 'search_permid', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'searchoptions'), "Search by Perm ID", ""))
RMenu.Add('eventsmenu', 'search_tempid', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'searchoptions'), "Search by Temp ID", ""))
RMenu.Add('eventsmenu', 'search_name', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'searchoptions'), "Search by Name", ""))
RMenu.Add('eventsmenu', 'player_actions', RageUI.CreateSubMenu(RMenu:Get('eventsmenu', 'searchoptions'), "Player Actions", ""))

local q = {"Minecraft","Ramps","Rooftop","Gulag","Heroin"}
local r = {
    vector3(-1964.6135,-1502.6834,321.0606),
    vector3(-935.6,-780.14,14.92),
    vector3(-56.62736,177.79515,140.17829),
    vector3(1457.8420,3555.2519,36.90834),
    vector3(3522.5588,3781.1757,29.92447),
}
local s = 1

local searchResults = {}
local selectedPlayer = nil
local searchPerm = ""
local searchTemp = ""
local searchName = ""

RegisterCommand('events', function()
    TriggerServerEvent('VICE:checkperm')
end)

RageUI.CreateWhile(1.0, true, function()

    if RageUI.Visible(RMenu:Get('eventsmenu', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            if isEventsTeam then

                RageUI.List("Teleport", q, s, "", {}, true, function(_, _, Selected, Index)
                    s = Index
                    if Selected then
                        tVICE.teleport2(r[s], true)
                    end
                end)

                RageUI.ButtonWithStyle("Search Players", "", {RightLabel = "→→→"}, true, function() end, RMenu:Get('eventsmenu', 'searchoptions'))

                RageUI.ButtonWithStyle("Revive All Nearby Players", "", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        local D = VICE.getPlayerCoords()
                        for _, S in pairs(GetActivePlayers()) do
                            local T = GetPlayerServerId(S)
                            local M = GetPlayerPed(S)
                            if T ~= -1 and M ~= 0 then
                                local U = GetEntityCoords(M, true)
                                if #(D - U) < 50.0 then
                                    local V = VICE.clientGetUserIdFromSource(T)
                                    if V > 0 then
                                        TriggerServerEvent('VICE:RevivePlayer', GetPlayerServerId(PlayerId()), V, true)
                                    end
                                end
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Give All Nearby Players Armour", "", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        local D = VICE.getPlayerCoords()
                        for _, S in pairs(GetActivePlayers()) do
                            local T = GetPlayerServerId(S)
                            local M = GetPlayerPed(S)
                            if T ~= -1 and M ~= 0 then
                                local U = GetEntityCoords(M, true)
                                if #(D - U) < 50.0 then
                                    local V = VICE.clientGetUserIdFromSource(T)
                                    if V > 0 then
                                        TriggerServerEvent('VICE:GiveArmour', GetPlayerServerId(PlayerId()), V, true)
                                    end
                                end
                            end
                        end
                    end
                end)

                RageUI.ButtonWithStyle("Spawn Mosin", "", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        TriggerServerEvent('VICE:SpawnMosin', GetPlayerServerId(PlayerId()), VICE.getUserId(), false)
                    end
                end)

                RageUI.ButtonWithStyle("Noclip", "", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        VICE.toggleNoclip()
                    end
                end)

            end

        end)
    end

    if RageUI.Visible(RMenu:Get('eventsmenu', 'searchoptions')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.ButtonWithStyle("Search by Perm ID", "", {RightLabel = "→→→"}, true, function() end, RMenu:Get('eventsmenu', 'search_permid'))
            RageUI.ButtonWithStyle("Search by Temp ID", "", {RightLabel = "→→→"}, true, function() end, RMenu:Get('eventsmenu', 'search_tempid'))
            RageUI.ButtonWithStyle("Search by Name", "", {RightLabel = "→→→"}, true, function() end, RMenu:Get('eventsmenu', 'search_name'))
        end)
    end

    if RageUI.Visible(RMenu:Get('eventsmenu', 'search_permid')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            if searchPerm == "" then
                searchPerm = VICE.KeyboardInput("Enter Perm ID", "", 10) or ""
                searchResults = {}
                for _, v in pairs(players) do
                    if string.find(v[3], searchPerm) then
                        table.insert(searchResults, v)
                    end
                end
            end

            for _, v in pairs(searchResults) do
                RageUI.ButtonWithStyle(v[1].." ["..v[2].."]", "PermID: "..v[3].." | TempID: "..v[2], {RightLabel = "→→→"}, true, function(_,_,Selected)
                    if Selected then
                        selectedPlayer = v
                        SelectedPlayer = v
                        SelectedPerm = v[3]
                        TriggerServerEvent("VICE:CheckPov", v[3])
                        TriggerServerEvent("VICE:CheckShadowLobby", v[2])
                    end
                end, RMenu:Get('eventsmenu', 'player_actions'))
            end

        end)
    end

    if RageUI.Visible(RMenu:Get('eventsmenu', 'search_tempid')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            if searchTemp == "" then
                searchTemp = VICE.KeyboardInput("Enter Temp ID", "", 10) or ""
                searchResults = {}
                for _, v in pairs(players) do
                    if string.find(v[2], searchTemp) then
                        table.insert(searchResults, v)
                    end
                end
            end

            for _, v in pairs(searchResults) do
                RageUI.ButtonWithStyle(v[1].." ["..v[2].."]", "PermID: "..v[3].." | TempID: "..v[2], {RightLabel = "→→→"}, true, function(_,_,Selected)
                    if Selected then
                        selectedPlayer = v
                        SelectedPlayer = v
                        SelectedPerm = v[3]
                        TriggerServerEvent("VICE:CheckPov", v[3])
                        TriggerServerEvent("VICE:CheckShadowLobby", v[2])
                    end
                end, RMenu:Get('eventsmenu', 'player_actions'))
            end

        end)
    end

    if RageUI.Visible(RMenu:Get('eventsmenu', 'search_name')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            if searchName == "" then
                searchName = VICE.KeyboardInput("Enter Name", "", 20) or ""
                searchResults = {}
                for _, v in pairs(players) do
                    if string.find(string.lower(v[1]), string.lower(searchName)) then
                        table.insert(searchResults, v)
                    end
                end
            end

            for _, v in pairs(searchResults) do
                RageUI.ButtonWithStyle(v[1].." ["..v[2].."]", "PermID: "..v[3].." | TempID: "..v[2], {RightLabel = "→→→"}, true, function(_,_,Selected)
                    if Selected then
                        selectedPlayer = v
                        SelectedPlayer = v
                        SelectedPerm = v[3]
                        TriggerServerEvent("VICE:CheckPov", v[3])
                        TriggerServerEvent("VICE:CheckShadowLobby", v[2])
                    end
                end, RMenu:Get('eventsmenu', 'player_actions'))
            end

        end)
    end

    if RageUI.Visible(RMenu:Get('eventsmenu', 'player_actions')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()

            RageUI.Separator("Selected: "..selectedPlayer[1].." ["..selectedPlayer[2].."]")

            RageUI.ButtonWithStyle("Revive Player", "", {RightLabel = "→→→"}, true, function(_,_,Selected)
                if Selected then
                    TriggerServerEvent('VICE:RevivePlayer', GetPlayerServerId(PlayerId()), selectedPlayer[3], false)
                end
            end)

            RageUI.ButtonWithStyle("Give Armour", "", {RightLabel = "→→→"}, true, function(_,_,Selected)
                if Selected then
                    TriggerServerEvent('VICE:GiveArmour', GetPlayerServerId(PlayerId()), selectedPlayer[3], false)
                end
            end)

            RageUI.ButtonWithStyle("Spawn Mosin", "", {RightLabel = "→→→"}, true, function(_,_,Selected)
                if Selected then
                    TriggerServerEvent('VICE:SpawnMosin', GetPlayerServerId(PlayerId()), selectedPlayer[3], false)
                end
            end)

        end)
    end

end)


RegisterNetEvent("VICE:gotPerm")
AddEventHandler("VICE:gotPerm",function (hasGroup)
    isEventsTeam = hasGroup
    if isEventsTeam then
        RageUI.Visible(RMenu:Get('eventsmenu', 'main'),true)
    end
end)