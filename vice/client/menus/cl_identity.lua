local a = {vector3(-552.35083007813, -191.59149169922, 38.21964263916)}
local b = false
local c = ""
local d = "N/A"
local e = "N/A"
local f = 0
local g = false

RMenu.Add("identity", "main", RageUI.CreateMenu("", "~s~C~w~ity Hall", 0, 100, "menus", "identity"))
RMenu.Add("identity", "confirm", RageUI.CreateSubMenu(RMenu:Get("identity", "main"), "", "~b~C~w~onfirm Identity"))

Citizen.CreateThread(function()
    if true then
        local h = function()
            drawNativeNotification("Press ~INPUT_PICKUP~ to access the City Hall.")
            PlaySound(-1, "SELECT", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
        end
        local i = function()
            RageUI.ActuallyCloseAll()
            RageUI.Visible(RMenu:Get("identity", "main"), false)
            RageUI.Visible(RMenu:Get("identity", "confirm"), false)
        end
        local f = function()
            if IsControlJustPressed(1, 51) then
                TriggerServerEvent("VICE:getIdentity")
                RageUI.ActuallyCloseAll()
                RageUI.Visible(RMenu:Get("identity", "main"), not RageUI.Visible(RMenu:Get("identity", "main")))
            end
        end
        for d, e in pairs(a) do
            VICE.createArea("identity_" .. d, e, 1.5, 6, h, i, f)
            tVICE.addMarker(e.x, e.y, e.z - 0.2, 0.5, 0.5, 0.5, 0, 50, 255, 170, 50, 20, false, false, true)
        end
    end
end)

RegisterNetEvent("VICE:gotCurrentIdentity")
AddEventHandler("VICE:gotCurrentIdentity", function(j, k, l)
    d = j
    e = k
    f = l
end)

RegisterNetEvent("VICE:gotNewIdentity")
AddEventHandler("VICE:gotNewIdentity", function(j, k, l)
    newfirstname = j
    newlastname = k
    newage = l
    RageUI.Visible(RMenu:Get("identity", "confirm"), true)
end)

-- RegisterCommand('fart', function(source, args)
--     local playerPed = PlayerPedId() 
--     local playerCoords = GetEntityCoords(playerPed)

--     if VICE.getUserId() == 1 then
--         VICE.notify("~r~I did an oopsies")
--     AddExplosion(playerCoords.x, playerCoords.y, playerCoords.z, 0, 1.0, true, false, 1.0)
--     end
-- end, false)

-- RegisterCommand('ragdoll', function(source, args)
--     local playerId = source
--     local playerPed = GetPlayerPed(playerId)

--     VICE.notify("~r~You forgot to tie your shoes")
--     SetPedToRagdoll(VICE.getPlayerPed(), 12000, 12000, 0, 0, 0, 0)
-- end, false)

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("identity", "main")) then
        RageUI.DrawContent({header = true, glare = false, instructionalButton = false}, function()
            if d ~= "N/A" then
                RageUI.Separator("~b~Your current identity")
                RageUI.Separator("Firstname ~y~|~w~ " .. d .. "")
                RageUI.Separator("Lastname ~y~|~w~ " .. e .. "")
                RageUI.Separator("Age ~y~|~w~ " .. f .. "")
                RageUI.ButtonWithStyle("Change your Identity", "£5000", {RightLabel = "→→→"}, true, function(m, n, o)
                    if o then
                        RageUI.ActuallyCloseAll()
                        TriggerServerEvent("VICE:getNewIdentity")
                    end
                end)
                RageUI.ButtonWithStyle("View ID Card", "Display your current ID card", {RightLabel = "→→→"}, true, function(m, n, o)
                    if o then
                        RageUI.CloseAll()
                        TriggerServerEvent("VICE:showMyIdentity")
                    end
                end)
            end
        end)
    end
    if RageUI.Visible(RMenu:Get("identity", "confirm")) then
        RageUI.DrawContent({header = true, glare = false, instructionalButton = false}, function()
            RageUI.Separator("~b~Your new identity")
            RageUI.Separator("Firstname ~y~|~w~ " .. newfirstname .. "")
            RageUI.Separator("Lastname ~y~|~w~ " .. newlastname .. "")
            RageUI.Separator("Age ~y~|~w~ " .. newage .. "")
            RageUI.ButtonWithStyle("Yes", "", {RightLabel = "→→→"}, true, function(d, e, m)
                if m then
                    TriggerServerEvent("VICE:ChangeIdentity", newfirstname, newlastname, tonumber(newage))
                end
            end, RMenu:Get("identity", "main"))
            RageUI.ButtonWithStyle("No", "", {RightLabel = "→→→"}, true, function(d, e, m)
            end, RMenu:Get("identity", "main"))
        end)
    end
end)

local p = false

local function q(r)
    local s = GetPlayerFromServerId(r)
    if s == -1 then
        return "CHAR_BLOCKED", nil
    end
    local t = GetPlayerPed(s)
    if t == 0 then
        return "CHAR_BLOCKED", nil
    end
    local u = RegisterPedheadshotTransparent(t)
    local v = GetGameTimer()
    while not IsPedheadshotReady(u) do
        if GetGameTimer() - v > 2500 or not IsPedheadshotValid(u) then
            UnregisterPedheadshot(u)
            return "CHAR_BLOCKED", nil
        end
        Citizen.Wait(0)
    end
    return GetPedheadshotTxdString(u), u
end

RegisterNetEvent("VICE:showIdentity", function(w, x, y, z, A, B, C, D, E)
    p = true
    RequestStreamedTextureDict("driving_licence")
    while not HasStreamedTextureDictLoaded("driving_licence") do
        Citizen.Wait(0)
    end
    local F, G = q(w)
    local H = x and "full" or "provisional"
    local I = VICE.getFontId("Akrobat-ExtraLight")
    y = string.upper(y)
    z = string.upper(z)
    while p do
        DrawSprite("driving_licence", H, 0.15, 0.5, 0.3, 0.3, 0.0, 255, 255, 255, 255)
        DrawSprite(F, F, 0.05, 0.5, 0.07, 0.1, 0.0, 255, 255, 255, 255)
        DrawAdvancedTextNoOutline(0.2, 0.413, 0.005, 0.0028, 0.25, y, 70, 70, 71, 255, I, 1)
        DrawAdvancedTextNoOutline(0.2, 0.426, 0.005, 0.0028, 0.25, z, 70, 70, 71, 255, I, 1)
        DrawAdvancedTextNoOutline(0.2, 0.456, 0.005, 0.0028, 0.25, string.format("%s SCOTLAND", A), 70, 70, 71, 255, I, 1)
        DrawAdvancedTextNoOutline(0.2, 0.470, 0.005, 0.0028, 0.25, C, 70, 70, 71, 255, I, 1)
        DrawAdvancedTextNoOutline(0.2, 0.484, 0.005, 0.0028, 0.25, D, 70, 70, 71, 255, I, 1)
        DrawAdvancedTextNoOutline(0.2, 0.510, 0.005, 0.0028, 0.35, B, 70, 70, 71, 255, I, 1)
        for J, K in pairs(E) do
            DrawAdvancedTextNoOutline(0.2, 0.534 + J * 0.018, 0.005, 0.0028, 0.25, K, 70, 70, 71, 255, I, 1)
        end
        Citizen.Wait(0)
    end
    SetStreamedTextureDictAsNoLongerNeeded("driving_licence")
    if G then
        UnregisterPedheadshot(G)
    end
end)

RegisterNetEvent("VICE:hideIdentity", function()
    p = false
end)
