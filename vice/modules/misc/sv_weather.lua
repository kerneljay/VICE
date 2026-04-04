voteCooldown = 1800
currentWeather = "CLEAR"
weatherVoterCooldown = voteCooldown
forcedWeather = nil -- Track if weather is forced

-- List of all valid weather types
local validWeathers = {
    "CLEAR",
    "EXTRASUNNY",
    "CLOUDS",
    "OVERCAST",
    "RAIN",
    "THUNDER",
    "HALLOWEEN",
    "SMOG",
    "FOGGY",
    "XMAS",
    "SNOWLIGHT",
    "BLIZZARD",
    "CLEARING",
    "HAZE"
}


RegisterServerEvent("VICE:vote") 
AddEventHandler("VICE:vote", function(weatherType)
    TriggerClientEvent("VICE:voteStateChange",-1,weatherType)
end)

RegisterServerEvent("VICE:tryStartWeatherVote") 
AddEventHandler("VICE:tryStartWeatherVote", function()
	local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.managecommunitypot') then
        if weatherVoterCooldown >= voteCooldown then
            TriggerClientEvent("VICE:startWeatherVote", -1)
            weatherVoterCooldown = 0
        else
            TriggerClientEvent("chatMessage", source, "Another vote can be started in " .. tostring(voteCooldown-weatherVoterCooldown) .. " seconds!", {255, 0, 0},"alert", "ooc")
        end
    else
        VICE.notify(source, 'You do not have permission for this.')
    end
end)

RegisterServerEvent("VICE:getCurrentWeather") 
AddEventHandler("VICE:getCurrentWeather", function()
    local source = source
    TriggerClientEvent("VICE:voteFinished",source,currentWeather)
end)

RegisterServerEvent("VICE:setCurrentWeather")
AddEventHandler("VICE:setCurrentWeather", function(newWeather)
	currentWeather = newWeather
end)

RegisterServerEvent("VICE:tryForceSnow")
AddEventHandler("VICE:tryForceSnow", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.managecommunitypot") then
        currentWeather = "XMAS"
        TriggerClientEvent("VICE:setWeather", -1, "XMAS")
        VICE.notify(source, "~g~Weather forced to snow")
    else
        VICE.notify(source, "~r~You don't have permission to use this command")
    end
end)

RegisterServerEvent("VICE:tryForceWeather")
AddEventHandler("VICE:tryForceWeather", function(weatherType)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.managecommunitypot") then
        -- Validate weather type
        if not table.contains(validWeathers, weatherType) then
            VICE.notify(source, "~r~Invalid weather type")
            return
        end
        
        currentWeather = weatherType
        -- Only set forced weather if it's not EXTRASUNNY (forceclear)
        if weatherType ~= "EXTRASUNNY" then
            forcedWeather = weatherType
            -- Store in database
            MySQL.execute("DELETE FROM vice_forced_weather", {}, function()
                MySQL.execute("INSERT INTO vice_forced_weather (weather_type) VALUES(@weather)", {weather = weatherType})
            end)
        else
            forcedWeather = nil
            -- Remove from database
            MySQL.execute("DELETE FROM vice_forced_weather", {})
        end
        TriggerClientEvent("VICE:setWeather", -1, weatherType)
        VICE.notify(source, "~g~Weather forced to All Online Players Type - " .. weatherType)
    else
        VICE.notify(source, "~r~You don't have permission to use this command")
    end
end)

RegisterServerEvent("VICE:tryUnlockWeather")
AddEventHandler("VICE:tryUnlockWeather", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.managecommunitypot") then
        weatherLocked = false
        TriggerClientEvent("VICE:unlockWeather", -1)
        VICE.notify(source, "~g~Weather settings unlocked")
    else
        VICE.notify(source, "~r~You don't have permission to use this command")
    end
end)

Citizen.CreateThread(function()
	while true do
		weatherVoterCooldown = weatherVoterCooldown + 1
		Citizen.Wait(1000)
	end
end)

RegisterNetEvent("VICE:requestPlayerName")
AddEventHandler("VICE:requestPlayerName", function()
    local playerName = VICE.getPlayerName(VICE.getUserId(source))
    TriggerClientEvent("VICE:receivePlayerName", source, playerName)
end)

RegisterNetEvent("VICE:sendPlayerName")
AddEventHandler("VICE:sendPlayerName", function()
    local playerName = VICE.getPlayerName(VICE.getUserId(source))
    TriggerEvent("VICE:receivePlayerName", playerName)
end)

-- Add event to sync forced weather to new players
RegisterServerEvent("VICE:playerJoined")
AddEventHandler("VICE:playerJoined", function()
    local source = source
    if forcedWeather then
        TriggerClientEvent("VICE:syncForcedWeather", source, forcedWeather)
    end
end)

-- Helper function to check if a value exists in a table
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

-- Load forced weather from database on server start
Citizen.CreateThread(function()
    MySQL.query("SELECT weather_type FROM vice_forced_weather LIMIT 1", {}, function(result)
        if result and result[1] then
            forcedWeather = result[1].weather_type
            TriggerClientEvent("VICE:syncForcedWeather", -1, forcedWeather)
        end
    end)
end)