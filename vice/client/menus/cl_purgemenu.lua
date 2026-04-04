local leaderboard = {}
local kills = 0
local a = {12, 3, 43}

function DrawLeaderboard()
    for i, data in ipairs(leaderboard) do
        local text = ("#%d %s: %d Kills"):format(i, data.name, data.kills)
        local g = 0.17
        local h = -0.01
        local i = 0.038
        local j = 0.008
        local k = 0.005
        local l = 0.32
        local m = -0.04
        local n = 0.014
        local o = GetSafeZoneSize()
        local p = n + o - g + g / 2
        local q = m + o - i + i / 2 - (i - 1) * (i + k)
        if VICE.isInPurge() then
            DrawSprite("timerbars", "all_black_bg", p, q, g, 0.038, 0, 0, 0, 0, 128)
            DrawGTAText(text, o - g + 0.04, q - j, l)
        end
    end
end

local a = false
local c = 0.033
local d = 0.033
local e = 0
local f = 0.306
function func_PurgeMenuControl()
    if a then
        if VICE.isInPurge() then
            -- if VICE.isNewPlayer() then
            --     drawNativeNotification("Press ~INPUT_SELECT_CHARACTER_FRANKLIN~ to toggle the Purge Leaderboard Menu.")
            -- end
            DrawRect(0.50, 0.222, 0.223, 0.075,  142, 50, 0, 255)
            DrawAdvancedText(0.595, 0.210, 0.005, 0.0028, 0.7, "VICE PURGE LEADERBOARD", 255, 255, 255, 255, VICE.getFontId("Akrobat-ExtraBold"), 0)
           -- if next(leaderboard) ~= nil then
                DrawAdvancedText(0.55, 0.275, 0.005, 0.0028, 0.4, "Name", 0, 255, 50, 255, 6, 0)
                DrawAdvancedText(0.60, 0.275, 0.005, 0.0028, 0.4, "Top 10", 0, 255, 50, 255, 6, 0)
                DrawAdvancedText(0.65, 0.275, 0.005, 0.0028, 0.4, "Kills", 0, 255, 50, 255, 6, 0)
          --  else
          --      DrawAdvancedText(0.595, 0.275, 0.005, 0.0028, 0.4, "0 Players with kills", 255, 0, 50, 255, 6, 0)
         --   end
            DrawRect(0.50, 0.272, 0.223, 0.026, 0, 0, 0, 222)
            for i, player in ipairs(leaderboard) do
                if i <= 10 then
                    DrawAdvancedText(0.55, f + e * c, 0.005, 0.0028, 0.4, tostring(player.name), 255, 255, 255, 255, 6, 0)
                    DrawAdvancedText(0.60, f + e * c, 0.005, 0.0028, 0.4, "|", 255, 255, 255, 255, 6, 0)
                    DrawAdvancedText(0.65, f + e * c, 0.005, 0.0028, 0.4, tostring(player.kills or 0), 255, 255, 255, 255, 6, 0)
                    DrawRect(0.50, 0.301 + c * e, 0.223, 0.033, 0, 0, 0, 120)
                    e = e + 1
                end
            end
            DrawAdvancedText(0.55, f + e * c, 0.005, 0.0028, 0.4, VICE.getPlayerName(GetPlayerServerId(PlayerId())), 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.60, f + e * c, 0.005, 0.0028, 0.4, "|", 255, 255, 255, 255, 6, 0)
            DrawAdvancedText(0.65, f + e * c, 0.005, 0.0028, 0.4, tostring(kills or 0), 255, 255, 255, 255, 6, 0)
            DrawRect(0.50, 0.301 + c * e, 0.223, 0.033, 0, 0, 0, 120)
            e = 0
        end
    end
end
RegisterCommand('purgeleaderboard', function(source, args, rawCommand)
    a = not a
    if a then
        func_PurgeMenuControl()
    end
end, false)
RegisterKeyMapping("purgeleaderboard", "Open Purge Leaderboard Menu", "keyboard", "F6")
VICE.createThreadOnTick(func_PurgeMenuControl)

function func_purgeTimerBars()
    for f = 1, 3 do
        local r = leaderboard[f]
        local s = ("%d%s: %s(%s)"):format(
            f,
            f == 1 and "st" or f == 2 and "nd" or "rd",
            r and r.name or "None",
            r and r.user_id or "0"
        )
        DrawLeaderboard()
    end
    local text = "~r~KILLS: " .. kills
    local g = 0.17
    local h = -0.01
    local i = 0.038
    local j = 0.008
    local k = 0.005
    local l = 0.32
    local m = -0.04
    local n = 0.014
    local o = GetSafeZoneSize()
    local p = n + o - g + g / 2
    local q = m + o - i + i / 2 - 0 * (i + k)
    if VICE.isInPurge() then
        DrawSprite("timerbars", "all_black_bg", p, q, g, 0.038, 0, 0, 0, 0, 128)
        DrawGTAText(text, o - g + 0.04, q - j, l)
    end
end

if VICE.isPurge() then
    VICE.createThreadOnTick(func_purgeTimerBars)
end

function UpdateLeaderboard()
    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)
    DrawLeaderboard()
end

RegisterNetEvent("VICE:gotTopFraggers")
AddEventHandler("VICE:gotTopFraggers", function(data)
    leaderboard = data
    UpdateLeaderboard()
end)

RegisterNetEvent('VICE:updateKills')
AddEventHandler('VICE:updateKills', function(newKills)
    kills = newKills
end)

Citizen.CreateThread(function()
    Wait(5000)
    while true do
        if VICE.isInPurge() then
            TriggerServerEvent("VICE:getTopFraggers")
        end
        Wait(5000)
    end
end)