function table_values(t)
    local new_table = {}
    for k,v in pairs(t) do
        table.insert(new_table,v)
    end
    return new_table
end

function table_keys(tbl)
    local keys = {}
    for k,_ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function table.find(table, h)
    for i, j in pairs(table) do
        if j == h then
            return i
        end
    end
    return false
end
local cfg = module("cfg/cfg_wagers").settings
local wagerTeam,wagersOpen,timeout = {},true,false
local _, teamA_group_id = AddRelationshipGroup("WAGERS_TEAM_A")
local _, teamB_group_id = AddRelationshipGroup("WAGERS_TEAM_B")
local getCurrentWagerForLocalPlayer

local function isEmergencyServiceSafe()
    -- Emergency-service restriction disabled.
    -- if type(VICE) == "table" and type(VICE.isEmergencyService) == "function" then
    --     local ok, value = pcall(VICE.isEmergencyService)
    --     if ok then
    --         return value == true
    --     end
    -- end
    return false
end

local function setFriendlyFireSafe(state)
    if type(tVICE) == "table" and type(tVICE.setFriendlyFire) == "function" then
        tVICE.setFriendlyFire(state)
        return
    end
    if type(VICE) == "table" and type(VICE.setFriendlyFire) == "function" then
        VICE.setFriendlyFire(state)
        return
    end
    NetworkSetFriendlyFireOption(state == true)
    SetCanAttackFriendly(VICE.getPlayerPed(), state == true, true)
    local player = PlayerId()
SetRunSprintMultiplierForPlayer(player, 1.49) -- 1.49 is max safe value

end

local function getSafeWeaponName(weapon)
    if type(VICE) == "table" then
        if type(VICE.getWeaponName) == "function" then
            local ok, name = pcall(VICE.getWeaponName, weapon)
            if ok and name and name ~= "" then
                return name
            end
        end
        if type(VICE.getweaponnames) == "function" then
            local ok, name = pcall(VICE.getweaponnames, weapon)
            if ok and name and name ~= "" then
                return name
            end
        end
    end

    return tostring(weapon):gsub("^WEAPON_", ""):gsub("_", " ")
end

for k,v in pairs(cfg.weapons_in_category) do
    for a,b in pairs(v) do
        cfg.weapons_in_category[k][a] = getSafeWeaponName(a)
    end
end

local function getCategoryWeaponEntries(category)
    local entries = {}
    for weaponCode, weaponLabel in pairs(cfg.weapons_in_category[category] or {}) do
        table.insert(entries, {key = weaponCode, label = weaponLabel})
    end
    table.sort(entries, function(a, b)
        return tostring(a.key) < tostring(b.key)
    end)
    return entries
end

local wagerMapKeys, wagerMapLabels = {}, {}
for mapKey, mapLabel in pairs(cfg.locations) do
    if cfg.location_coords[mapKey] then
        table.insert(wagerMapKeys, mapKey)
        table.insert(wagerMapLabels, mapLabel)
    end
end


RMenu.Add('wagers', 'main', RageUI.CreateMenu("", "~b~Wagers", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "wagers"))
RMenu.Add("wagers", "list", RageUI.CreateSubMenu(RMenu:Get("wagers", "main"), "", "~b~Wagers",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","wagers"))
RMenu.Add("wagers", "create", RageUI.CreateSubMenu(RMenu:Get("wagers", "main"), "", "~b~Wagers",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","wagers"))
RMenu.Add("wagers", "wagerteams", RageUI.CreateSubMenu(RMenu:Get("wagers", "list"), "", "~b~Wagers",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","wagers"))
RMenu.Add("wagers", "stats", RageUI.CreateSubMenu(RMenu:Get("wagers", "main"), "", "~b~Wagers",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","wagers"))

RageUI.CreateWhile(1.0,true,function() 
    RageUI.IsVisible(RMenu:Get("wagers", "main"),true,true,true,function()
        if wagersOpen then
            RageUI.ButtonWithStyle("List Wagers", nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                   TriggerServerEvent("VICE:getWagerData")
                end
            end, RMenu:Get("wagers", "list"))
            RageUI.ButtonWithStyle("Create Wager", nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get("wagers", "create"))
        else
            RageUI.Separator("Wagers are currently closed.")
        end
    end,
    function()
    end)
    RageUI.IsVisible(RMenu:Get("wagers", "list"),true,true,true,function()
        if table.count(wagerTeam) == 0 then
            RageUI.Separator("~r~No pending bets")
        else
            for owner_id,v in pairs(wagerTeam) do
                RageUI.ButtonWithStyle(v.name, string.format("%sWeapon Category: %s\nWeapon Name: %s\nBest of: %s", v.security_enabled and "~o~(Password protected)~s~\n" or "", v.WagerWeaponCategory, getSafeWeaponName(v.wagerWeapon), v.bestOf), {RightLabel = "£".. getMoneyStringFormatted(v.betAmount)}, true, function(Hovered, Active, Selected)
                    if Selected then
                        selectedWagerOwner = owner_id
                    end
                end, RMenu:Get("wagers", "wagerteams"))
            end
        end
    end,
    function()
    end)
    RageUI.IsVisible(RMenu:Get("wagers", "create"),true,true,true,function()
        RageUI.List("Map",wagerMapLabels,cfg.locationIndex,"",{},true,function(M, N, O, a0)
            if a0 ~= cfg.locationIndex then
                cfg.locationIndex = a0
            end
        end)
        RageUI.List("Weapon Category",cfg.categories,cfg.categoryIndex,"",{},true,function(M, N, O, a0)
            if a0 ~= cfg.categoryIndex then
                cfg.categoryIndex = a0
                cfg.weaponInCategoryIndex = 1
            end
        end)
        local weaponEntries = getCategoryWeaponEntries(cfg.categories[cfg.categoryIndex])
        local weaponLabels = {}
        for _, entry in ipairs(weaponEntries) do
            table.insert(weaponLabels, entry.label)
        end
        if cfg.weaponInCategoryIndex > #weaponLabels then
            cfg.weaponInCategoryIndex = 1
        end
        RageUI.List("Weapon",weaponLabels,cfg.weaponInCategoryIndex,"",{},true,function(M, N, O, a0)
            if a0 ~= cfg.weaponInCategoryIndex then
                cfg.weaponInCategoryIndex = a0
            end
        end)
        RageUI.List("Best of",cfg.best_of,cfg.best_ofIndex,"",{},true,function(M, N, O, a0)
            if a0 ~= cfg.best_ofIndex then
                cfg.best_ofIndex = a0
            end
        end)
        RageUI.ButtonWithStyle("Bet Amount", nil, {RightLabel = "£"..getMoneyStringFormatted(cfg.wagerBetAmount)}, true, function(Hovered, Active, Selected)
            if Selected then
                tVICE.clientPrompt("Enter Amount:", "", function(d)
                    if tonumber(d) then 
                        local amount = tonumber(d)
                        if amount <= cfg.wagerMaxBet and amount >= cfg.wagerMinBet then
                            cfg.wagerBetAmount = amount
                        else
                            VICE.notify("~r~You need to bet an amount between £" .. getMoneyStringFormatted(cfg.wagerMaxBet) .. " and £" .. getMoneyStringFormatted(cfg.wagerMinBet) .. ".")
                        end
                    else 
                        VICE.notify("~r~Invalid amount.")
                    end 
                end)
            end
        end)
        local function a4()
            cfg.use_armour = true
        end
        local function a5()
            cfg.use_armour = false
        end
        RageUI.Checkbox("Use Armour","Armour will be applied at the start of every round",cfg.use_armour,{Style = RageUI.CheckboxStyle.Car},function(a0, a2, a1, a6)
        end,a4,a5)
        local function p4()
            cfg.security.enabled = true
        end
        local function p5()
            cfg.security.enabled = false
        end
        RageUI.Checkbox("Password Protection","If enabled a password will be required to join this wager",cfg.security.enabled,{Style = RageUI.CheckboxStyle.Car},function(a0, a2, a1, a6)
        end,p4,p5)
        if cfg.security.enabled then
            RageUI.ButtonWithStyle(cfg.security.password == "" and "Set Password" or "Change Password", cfg.security.password == "" and "Enter a password for others to use to join this wager" or "Password set: ~g~"..cfg.security.password, {RightLabel = cfg.security.password}, true, function(Hovered, Active, Selected)
                if Selected then
                    tVICE.clientPrompt("Enter Password:", "", function(d)
                        if d ~= "" then
                            cfg.security.password = d
                        else
                            VICE.notify("~r~Invalid password.")
                        end
                    end)
                end
            end)
        end
        local tlock = true
        if cfg.security.enabled and cfg.security.password == "" then
            tlock = false
        end
        RageUI.ButtonWithStyle("Propose Wager", cfg.security.enabled and (cfg.security.password ~= "" and "~g~Password protected" or "~r~You must enter a password to create this wager."), {RightLabel = "→→→"}, tlock and not isEmergencyServiceSafe(), function(Hovered, Active, Selected)
            if Selected then
                local map = wagerMapKeys[cfg.locationIndex]
                local mapLoc = map and cfg.location_coords[map] or nil

                if not map or not mapLoc then
                    VICE.notify("~r~Invalid map selection. Please re-open the wagers menu.")
                    return
                end

                local selectedWeapon = weaponEntries[cfg.weaponInCategoryIndex]
                if not selectedWeapon or not selectedWeapon.key then
                    VICE.notify("~r~Invalid weapon selection. Please re-open the wagers menu.")
                    return
                end

              TriggerServerEvent("VICE:createWager", 
                cfg.best_of[cfg.best_ofIndex], 
                selectedWeapon.key,
                cfg.categories[cfg.categoryIndex], 
                cfg.wagerBetAmount, 
                cfg.use_armour,
                mapLoc,
                map,cfg.security.enabled,cfg.security.password)
                selectedWagerOwner = VICE.getUserId()
                
            end
        end, RMenu:Get("wagers", "wagerteams"))
    end,
    function()
    end)
    RageUI.IsVisible(RMenu:Get("wagers", "wagerteams"),true,true,true,function()
        RageUI.Separator("Team A")
        local teamACount = 0
        if wagerTeam[selectedWagerOwner] == nil then
            RageUI.CloseAll()
            RageUI.Visible(RMenu:Get("wagers", "list"), true)
        else
            for player_id, playerDetails in pairs(wagerTeam[selectedWagerOwner].teamA.players) do
                teamACount = teamACount + 1
                RageUI.ButtonWithStyle(playerDetails.name, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end)
            end
            for i = teamACount + 1, cfg.maxTeamPlayers do
                RageUI.ButtonWithStyle("Available Slot", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end)
            end
            if wagerTeam[selectedWagerOwner].teamA.players[VICE.getUserId()] then
                RageUI.ButtonWithStyle("~r~Leave Team A", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if not timeout then
                            timeout = true
                            SetTimeout(1000, function()
                                timeout = false
                            end)
                            TriggerServerEvent("VICE:leaveTeam")
                        else
                            VICE.notify("~r~Please wait before leaving another team.")
                        end
                    end
                end)
            else
                if teamACount < cfg.maxTeamPlayers then
                    RageUI.ButtonWithStyle("~g~Join Team A", nil, {RightLabel = ""}, not isEmergencyServiceSafe(), function(Hovered, Active, Selected)
                        if Selected then
                            if not timeout then
                                if not wagerTeam[selectedWagerOwner].teamB.players[VICE.getUserId()] and wagerTeam[selectedWagerOwner].security_enabled and wagerTeam[selectedWagerOwner].password ~= "" then
                                    tVICE.clientPrompt("Enter Password:", "", function(d)
                                        if string.lower(tostring(d)) == wagerTeam[selectedWagerOwner].password then
                                            timeout = true
                                            SetTimeout(1000, function()
                                                timeout = false
                                            end)
                                            TriggerServerEvent("VICE:joinWager", selectedWagerOwner, "teamA", string.lower(tostring(d)))
                                        else
                                            VICE.notify("~r~Incorrect password!")
                                        end
                                    end)
                                else
                                    timeout = true
                                    SetTimeout(1000, function()
                                        timeout = false
                                    end)
                                    TriggerServerEvent("VICE:joinWager", selectedWagerOwner, "teamA")
                                end
                            else
                                VICE.notify("~r~Please wait before joining another team.")
                            end
                        end
                    end)
                else
                    RageUI.Separator("~r~Team A is full.")
                end
            end
            RageUI.Separator("Team B")
            local teamBCount = 0
            for player_id, playerDetails in pairs(wagerTeam[selectedWagerOwner].teamB.players) do
                teamBCount = teamBCount + 1
                RageUI.ButtonWithStyle(playerDetails.name, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end)
            end
            for i = teamBCount + 1, cfg.maxTeamPlayers do
                RageUI.ButtonWithStyle("Available Slot", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end)
            end
            if wagerTeam[selectedWagerOwner].teamB.players[VICE.getUserId()] then
                RageUI.ButtonWithStyle("~r~Leave Team B", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if not timeout then
                            timeout = true
                            SetTimeout(1000, function()
                                timeout = false
                            end)
                           TriggerServerEvent("VICE:leaveTeam")
                        else
                            VICE.notify("~r~Please wait before leaving another team.")
                        end
                    end
                end)
            else
                if teamBCount < cfg.maxTeamPlayers then
                    RageUI.ButtonWithStyle("~g~Join Team B", nil, {RightLabel = ""}, not isEmergencyServiceSafe(), function(Hovered, Active, Selected)
                        if Selected then
                            if not timeout then
                                if not wagerTeam[selectedWagerOwner].teamA.players[VICE.getUserId()] and wagerTeam[selectedWagerOwner].security_enabled and wagerTeam[selectedWagerOwner].password ~= "" then
                                    tVICE.clientPrompt("Enter Password:", "", function(d)
                                        if string.lower(tostring(d)) == wagerTeam[selectedWagerOwner].password then
                                            timeout = true
                                            SetTimeout(1000, function()
                                                timeout = false
                                            end)
                                           TriggerServerEvent("VICE:joinWager", selectedWagerOwner, "teamB", string.lower(tostring(d)))
                                        else
                                            VICE.notify("~r~Incorrect password!")
                                        end
                                    end)
                                else
                                    timeout = true
                                    SetTimeout(1000, function()
                                        timeout = false
                                    end)
                                    TriggerServerEvent("VICE:joinWager", selectedWagerOwner, "teamB")
                                end
                            else
                                VICE.notify("~r~Please wait before joining another team.")
                            end
                        end
                    end)
                else
                    RageUI.Separator("~r~Team B is full.")
                end
            end
            if selectedWagerOwner == VICE.getUserId() then
                RageUI.Separator("")
                local teamsBalanced = (teamACount == 1 and teamBCount == 1) or (teamACount == 2 and teamBCount == 2) or (teamACount == 3 and teamBCount == 3) or (teamACount == 4 and teamBCount == 4) or (teamACount == 5 and teamBCount == 5)
                RageUI.ButtonWithStyle("~h~" .. (teamsBalanced and "~g~Start game with " .. (teamACount+teamBCount) .. " players" or "~r~Start game"), "The game must be at least a 1v1 or a 2v2 to start.", {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if VICE.isDev() or teamsBalanced then
                            TriggerServerEvent("VICE:startWager", selectedWagerOwner)
                        else
                            VICE.notify("~r~Teams must be balanced to start the wager!")
                        end
                    end
                end)
                RageUI.ButtonWithStyle("~r~Cancel Wager", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("VICE:cancelWager")
                    end
                end)
            end
        end
    end,
    function()
    end)
end)

AddEventHandler("VICE:onClientSpawn",function(D, E)
    if E then
        local B=function(B)
            VICE.drawNativeNotification("Press ~INPUT_PICKUP~ to wager.")
        end
        local T=function(T)
            RageUI.CloseAll()
            RageUI.Visible(RMenu:Get('wagers','main'),false)
        end
        local F=function(F)
            if IsControlJustPressed(1,51) then
                if VICE.inEvent() or VICE.isInPurge() and not isEmergencyServiceSafe() then
                    VICE.notify("~r~You cannot access this right now.")
                else
                    -- TriggerServerEvent("VICE:getWagerWhitelists")
                    TriggerServerEvent("VICE:isWagersOpen")
                    if cfg.locationIndex < 1 or cfg.locationIndex > #wagerMapLabels then
                        cfg.locationIndex = 1
                    end
                    cfg.categoryIndex = 1
                    cfg.weaponInCategoryIndex = 1
                    cfg.use_armour = false
                    cfg.security.enabled = false
                    cfg.security.password = ""
                    RageUI.Visible(RMenu:Get('wagers','main'),not RageUI.Visible(RMenu:Get('wagers','main')))
                end
            end
        end
        tVICE.addMarker(cfg.wagerStartLoc.x, cfg.wagerStartLoc.y, cfg.wagerStartLoc.z-1.0, 1.0, 1.0, 1.0, 0, 0, 255, 170, 50, 27)
        tVICE.addBlip(cfg.wagerStartLoc.x, cfg.wagerStartLoc.y, cfg.wagerStartLoc.z,437,0,"Wager Arena",0.9)
        VICE.createArea("wagers",cfg.wagerStartLoc,1.5,6,B,T,F,{})
    end
end)

-- RegisterNetEvent("VICE:gotWagerWhitelists", function(whitelists, if_wagers_open)
--     if table.count(whitelists) ~= 0 and not cfg.weapons_in_category["Owned Whitelists"] then
--         table.insert(cfg.categories,"Owned Whitelists")
--         cfg.weapons_in_category["Owned Whitelists"] = whitelists
--     end
--     wagersOpen = if_wagers_open
-- end)

RegisterNetEvent("VICE:sendWagerData", function(team)
    wagerTeam = team
end)

RegisterNetEvent("VICE:toggleInWager",function(v)
    inWager = tobool(v)
    VICE.setGreenzonesDisabled(inWager)
    if not inWager then
        RemoveAllPedWeapons(VICE.getPlayerPed())
        ClearRelationshipBetweenGroups(5, teamA_group_id, teamB_group_id)
        ClearRelationshipBetweenGroups(5, teamB_group_id, teamA_group_id)
        SetPedRelationshipGroupHash(VICE.getPlayerPed(), "PLAYER")
        setFriendlyFireSafe(true)
        RemoveAnimDict("mini@triathlon")
    else
        VICE.loadAnimDict("mini@triathlon")
    end
end)
RegisterNetEvent("VICE:loadWagerIPL",function(map,load)
    if load then
        if cfg.location_coords[map] and cfg.location_coords[map].load_IPL then
            DoScreenFadeOut(500)
            RequestIpl(map)
            local a = GetGameTimer()
            while not IsIplActive(map) do
                if GetGameTimer() - a > 10000 then
                    print("Failed to load IPL: "..map)
                    break
                end
                print("Attempting to load IPL: "..map)
                Wait(0)
            end
            DoScreenFadeIn(500)
        end
    else
        RemoveIpl(map)
    end
end)

RegisterNetEvent("VICE:startWager",function(team)
    ClearPedTasks(VICE.getPlayerPed())
    if team == "teamA" then
        SetPedRelationshipGroupHash(VICE.getPlayerPed(), teamA_group_id)
    elseif team == "teamB" then
        SetPedRelationshipGroupHash(VICE.getPlayerPed(), teamB_group_id)
    end
    SetRelationshipBetweenGroups(5, teamA_group_id, teamB_group_id)
    SetRelationshipBetweenGroups(5, teamB_group_id, teamA_group_id)
    setFriendlyFireSafe(false)
    local currentWager, ownerId = getCurrentWagerForLocalPlayer()
    if ownerId then
        selectedWagerOwner = ownerId
    end
    if currentWager and type(currentWager.wagerWeapon) == "string" and type(tVICE.holdWeapon) == "function" then
        SetTimeout(250, function()
            tVICE.holdWeapon({[currentWager.wagerWeapon] = {ammo = 250}}, true, decorpasskey)
        end)
    end
    -- createCinematicScene some sort of skippable cinematic scene
end)

RegisterNetEvent("VICE:wagerForceGiveWeapon", function(weapon, ammo, clearCurrent)
    local ped = VICE.getPlayerPed()
    if clearCurrent then
        RemoveAllPedWeapons(ped, true)
    end

    local hash = GetHashKey(tostring(weapon or ""))
    if hash and hash ~= 0 then
        GiveWeaponToPed(ped, hash, tonumber(ammo) or 250, false, true)
        SetCurrentPedWeapon(ped, hash, true)
    else
        VICE.notify("~r~Invalid wager weapon: " .. tostring(weapon))
    end
end)

local isCountingDown = false

function tVICE.showCountdownTimer(a9,freeze)
    isCountingDown = true
    local aa = 0
    local ab = a9
    local ac = a9 + 1

    Citizen.CreateThread(function()
        while isCountingDown do
            if ac ~= -1 then
                ac = ac - 1
                aa = aa + 1
            end
            if ac > 0 then
                PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", 1)
                FreezeEntityPosition(VICE.getPlayerPed(), freeze)
            end
            if ac == 0 then
                PlaySoundFrontend(-1, "GO", "HUD_MINI_GAME_SOUNDSET", 1)
                if freeze then
                    FreezeEntityPosition(VICE.getPlayerPed(), false)
                end
            end
            Citizen.Wait(1000)
        end
    end)

    local af = Scaleform("COUNTDOWN")

    Citizen.CreateThread(function()
        while isCountingDown do
            if ac ~= -1 then
                if ac == 0 then
                    af.RunFunction("SET_MESSAGE", {"CNTDWN_GO", 255, 255, 255, true, false})
                elseif ac > 0 then
                    if ac >= a9 / 2 then
                        ae = math.floor(510 * (1 - aa / ab))
                    elseif ac < a9 / 2 then
                        ad = math.floor(510 * aa / ab)
                    end
                    af.RunFunction("SET_MESSAGE", {tostring(ac), 255, 255, 255, true, false})
                end
                af.Render2D()
                DisablePlayerFiring(VICE.getPlayerId(), true)
            end
            Wait(0)
        end
    end)

    while ac ~= -1 do
        Citizen.Wait(1.0)
    end
    return true
end
local function createTimerBars()
    if type(tVICE) == "table" and type(tVICE.createTimerBars) == "function" then
        return tVICE.createTimerBars()
    end
    if type(VICE) == "table" and type(VICE.createTimerBars) == "function" then
        return VICE.createTimerBars()
    end

    local bars = {rows = {}}

    function bars:reset()
        self.rows = {}
    end

    function bars:push(label, value)
        table.insert(self.rows, {label = tostring(label or ""), value = tostring(value or "")})
    end

    function bars:draw()
        local count = #self.rows
        for i, row in ipairs(self.rows) do
            DrawGTATimerBar(row.label, row.value, count - i + 1)
        end
    end

    return bars
end

local T = createTimerBars()
Citizen.CreateThread(function()
    while true do
        if inWager and wagerTeam[selectedWagerOwner] then
            local currentWager = wagerTeam[selectedWagerOwner]
            T:reset()
            T:push("~b~Rounds won:", tonumber(currentWager.teamA.players[VICE.getUserId()] and currentWager.teamA.wins or currentWager.teamB.wins))
            T:push("~b~Current round:", (currentWager.currentRound + 1) .. "/" .. currentWager.bestOf)
            T:draw()
            for m, n in ipairs(GetActivePlayers()) do
                local o = GetPlayerPed(n)
                if o ~= VICE.getPlayerPed() then
                    local perm = VICE.clientGetUserIdFromSource(GetPlayerServerId(n))
                    if (currentWager.teamA.players[perm] or currentWager.teamB.players[perm]) and IsPedReloading(o) then
                        drawNativeText("~r~".. VICE.getPlayerName(n).." in Team "..(currentWager.teamA.players[perm] and "A" or "B").." is currently reloading...")
                    end
                end
            end
        end
        Citizen.Wait(0)
    end
end)

function VICE.playerInWager(player)
    local currentWager = wagerTeam[selectedWagerOwner]
    return not player and inWager or currentWager and (currentWager.teamA.players[player] or currentWager.teamB.players[player]) or false
end

getCurrentWagerForLocalPlayer = function()
    local userId = VICE.getUserId()
    if selectedWagerOwner and wagerTeam[selectedWagerOwner] then
        local wager = wagerTeam[selectedWagerOwner]
        if wager.teamA.players[userId] or wager.teamB.players[userId] then
            return wager, selectedWagerOwner
        end
    end
    for ownerId, wager in pairs(wagerTeam) do
        if wager.teamA.players[userId] or wager.teamB.players[userId] then
            return wager, ownerId
        end
    end
    return nil, nil
end

RegisterNetEvent("VICE:WagerStatus")
AddEventHandler("VICE:WagerStatus",function (wagerStatus)
    wagersOpen = wagerStatus
end)