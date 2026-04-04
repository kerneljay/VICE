local a = "EXTRASUNNY"
local b = {h = 12, m = 0, s = 0}
local c = false
local forcedWeather = nil -- Track if weather is forced by admin
local function d(e)
    if forcedWeather then return end -- Only prevent changes if weather is forced
    a = e
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist(a)
    SetWeatherTypeNow(a)
    SetWeatherTypeNowPersist(a)
    if a == "XMAS" then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
    else
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    end
end
function VICE.setTime(f, g, h)
    b = {h = f, m = g, s = h}
end
function VICE.overrideTime(f, g, h)
    b.h = f
    b.m = g
    b.s = h
    c = true
end
function VICE.cancelOverrideTimeWeather()
    c = false
end
function VICE.setWeather(i)
    a = i
end
function func_manageTimeAndWeather()
    NetworkOverrideClockTime(b.h, b.m, b.s)
    d(a)
end
VICE.createThreadOnTick(func_manageTimeAndWeather)
RegisterNetEvent("VICE:setTime",function(f, g, h)
    VICE.setTime(f, g, h)
end)
RegisterNetEvent("VICE:setWeather",function(i)
    VICE.setWeather(i)
end)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        b.s = b.s + 10
        if b.s == 60 then
            b.s = 0
            b.m = b.m + 1
        end
        if b.m == 60 then
            b.m = 0
            b.h = b.h + 1
        end
        if b.h == 24 then
            b.h = 0
        end
        if not c then
            VICE.setTime(b.h, b.m, b.s)
        end
    end
end)
local j = false
local k = false
local l = 60
local m = {
    ["CLEAR"] = 0,
    ["EXTRASUNNY"] = 0,
    ["CLOUDS"] = 0,
    ["OVERCAST"] = 0,
    ["RAIN"] = 0,
    ["THUNDER"] = 0,
    ["HALLOWEEN"] = 0,
    ["SMOG"] = 0,
    ["FOGGY"] = 0,
    ["XMAS"] = 0,
    ["SNOWLIGHT"] = 0,
    ["BLIZZARD"] = 0
}
local function n(o, p, q, f, r, s, t, u, v, w, x, y)
    SetTextFont(x)
    SetTextScale(r, r)
    SetTextJustification(y)
    SetTextColour(t, u, v, w)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(s)
    EndTextCommandDisplayText(o - 0.1 + q, p - 0.02 + f)
end
local z = 0.1
local A = 0.005
local B = 0.02
Citizen.CreateThread(function()
    while true do
        if j then
            n(z + 0.265, 0.96, 0.005, 0.0028, 0.30, "Time Left:", 0, 208, 104, 255, 4, 1)
            n(z + 0.295, 0.96, 0.005, 0.0028, 0.275, tostring(l), 255, 74, 53, 255, 0, 1)
            n(z + 0.29, 0.827, 0.005, 0.0028, 0.38, "Weather Voter", 0, 208, 104, 255, 4, 1)
            n(z + 0.2645, 0.848, 0.005, 0.0028, 0.30, "Clear", 255, 255, 255, 255, 4, 1)
            n(z + 0.2645, 0.866, 0.005, 0.0028, 0.30, "ExtraSunny", 255, 255, 255, 255, 4, 1)
            n(z + 0.2645, 0.884, 0.005, 0.0028, 0.30, "Cloudy", 255, 255, 255, 255, 4, 1)
            n(z + 0.2645, 0.902, 0.005, 0.0028, 0.30, "Overcast", 255, 255, 255, 255, 4, 1)
            n(z + 0.2645, 0.920, 0.005, 0.0028, 0.30, "Rain", 255, 255, 255, 255, 4, 1)
            n(z + 0.2645, 0.938, 0.005, 0.0028, 0.30, "Thunder", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.293, 0.848, 0.005, 0.0028, 0.25, tostring(m["CLEAR"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.293, 0.866, 0.005, 0.0028, 0.25, tostring(m["EXTRASUNNY"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.293, 0.884, 0.005, 0.0028, 0.25, tostring(m["CLOUDS"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.293, 0.902, 0.005, 0.0028, 0.25, tostring(m["OVERCAST"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.293, 0.920, 0.005, 0.0028, 0.25, tostring(m["RAIN"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.293, 0.938, 0.005, 0.0028, 0.25, tostring(m["THUNDER"]), 255, 74, 53, 255, 0, 1)
            n(z + A + 0.315, 0.848, 0.005, 0.0028, 0.30, "Halloween", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.315, 0.866, 0.005, 0.0028, 0.30, "Smog", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.315, 0.884, 0.005, 0.0028, 0.30, "Snow", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.315, 0.902, 0.005, 0.0028, 0.30, "Blizzard", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.315, 0.920, 0.005, 0.0028, 0.30, "Snowlight", 255, 255, 255, 255, 4, 1)
            n(z + A + 0.315, 0.938, 0.005, 0.0028, 0.30, "Foggy", 255, 255, 255, 255, 4, 1)
            n(z + B + 0.333, 0.848, 0.005, 0.0028, 0.25, tostring(m["HALLOWEEN"]), 255, 74, 53, 255, 0, 1)
            n(z + B + 0.333, 0.866, 0.005, 0.0028, 0.25, tostring(m["SMOG"]), 255, 74, 53, 255, 0, 1)
            n(z + B + 0.333, 0.884, 0.005, 0.0028, 0.25, tostring(m["XMAS"]), 255, 74, 53, 255, 0, 1)
            n(z + B + 0.333, 0.902, 0.005, 0.0028, 0.25, tostring(m["BLIZZARD"]), 255, 74, 53, 255, 0, 1)
            n(z + B + 0.333, 0.920, 0.005, 0.0028, 0.25, tostring(m["SNOWLIGHT"]), 255, 74, 53, 255, 0, 1)
            n(z + B + 0.333, 0.938, 0.005, 0.0028, 0.25, tostring(m["FOGGY"]), 255, 74, 53, 255, 0, 1)
        end
        Wait(0)
    end
end)
Citizen.CreateThread(function()
    while true do
        if j then
            l = l - 1
            if l == 0 then
                j = false
                l = 60
                k = false
                -- Find the weather with the most votes
                local highestVotes = 0
                local winningWeather = "CLEAR"
                for weather, votes in pairs(m) do
                    if votes > highestVotes then
                        highestVotes = votes
                        winningWeather = weather
                    end
                end
                -- Apply the winning weather
                TriggerServerEvent("VICE:setCurrentWeather", winningWeather)
                TriggerEvent("VICE:setWeather", winningWeather)
                VICE.notify("~g~Weather changed to " .. winningWeather)
                resetVotes()
            end
        end
        Wait(1000)
    end
end)
function voteWeather(C)
    if j then
        if not k then
            TriggerServerEvent("VICE:vote", C)
            k = true
            VICE.notify("~g~Vote sent!")
        else
            VICE.notify("~r~You have already voted!")
        end
    else
        VICE.notify("~r~Vote not in progress, start a vote with /voteweather!")
    end
end
function resetVotes()
    m = {
        ["CLEAR"] = 0,
        ["EXTRASUNNY"] = 0,
        ["CLOUDS"] = 0,
        ["OVERCAST"] = 0,
        ["RAIN"] = 0,
        ["THUNDER"] = 0,
        ["HALLOWEEN"] = 0,
        ["SMOG"] = 0,
        ["FOGGY"] = 0,
        ["XMAS"] = 0,
        ["SNOWLIGHT"] = 0,
        ["BLIZZARD"] = 0
    }
end
RegisterNetEvent("VICE:startWeatherVote",function()
    j = true
    TriggerEvent("chatMessage","Weather vote has started! Type /[weather] e.g /snow or /rain to vote.",{0, 250, 50}, "", "ooc")
    TriggerEvent("chatMessage", "Weather types are in bottom left & /voteweather to start a vote", {0, 250, 50}, "", "ooc")
end)
RegisterNetEvent("VICE:voteStateChange",function(D)
    m[D] = m[D] + 1
end)
RegisterCommand("voteweather",function()
    TriggerServerEvent("VICE:tryStartWeatherVote")
end,false)
RegisterCommand("clear",function()
    voteWeather("CLEAR")
end,false)
RegisterCommand("extrasunny",function()
    voteWeather("EXTRASUNNY")
end,false)
RegisterCommand("cloudy",function()
    voteWeather("CLOUDS")
end,false)
RegisterCommand("overcast",function()
    voteWeather("OVERCAST")
end,false)
RegisterCommand("rain",function()
    voteWeather("RAIN")
end,false)
RegisterCommand("thunder",function()
    voteWeather("THUNDER")
end,false)
RegisterCommand("halloween",function()
    voteWeather("HALLOWEEN")
end,false)
RegisterCommand("smog",function()
    voteWeather("SMOG")
end,false)
RegisterCommand("foggy",function()
    voteWeather("FOGGY")
end,false)
RegisterCommand("snow",function()
    voteWeather("XMAS")
end,false)
RegisterCommand("snowlight",function()
    voteWeather("SNOWLIGHT")
end,false)
RegisterCommand("blizzard",function()
    voteWeather("BLIZZARD")
end,false)

-- Modify force weather commands to set forced weather
RegisterCommand("forcesnow", function()
    TriggerServerEvent("VICE:tryForceWeather", "XMAS")
    forcedWeather = "XMAS"
    -- Force snow effects
    SetForceVehicleTrails(true)
    SetForcePedFootstepsTracks(true)
    SetWeatherTypePersist("XMAS")
    SetWeatherTypeNow("XMAS")
    SetWeatherTypeNowPersist("XMAS")
    SetRainLevel(0.0)
end)

RegisterCommand("forceclear", function()
    TriggerServerEvent("VICE:tryForceWeather", "EXTRASUNNY")
    forcedWeather = nil
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("EXTRASUNNY")
    SetWeatherTypeNow("EXTRASUNNY")
    SetWeatherTypeNowPersist("EXTRASUNNY")
    SetRainLevel(0.0)
end)

RegisterCommand("forceclouds", function()
    TriggerServerEvent("VICE:tryForceWeather", "CLOUDS")
    forcedWeather = "CLOUDS"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("CLOUDS")
    SetWeatherTypeNow("CLOUDS")
    SetWeatherTypeNowPersist("CLOUDS")
    SetRainLevel(0.0)
end)

RegisterCommand("forcefoggy", function()
    TriggerServerEvent("VICE:tryForceWeather", "FOGGY")
    forcedWeather = "FOGGY"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("FOGGY")
    SetWeatherTypeNow("FOGGY")
    SetWeatherTypeNowPersist("FOGGY")
    SetRainLevel(0.0)
end)

RegisterCommand("forceovercast", function()
    TriggerServerEvent("VICE:tryForceWeather", "OVERCAST")
    forcedWeather = "OVERCAST"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("OVERCAST")
    SetWeatherTypeNow("OVERCAST")
    SetWeatherTypeNowPersist("OVERCAST")
    SetRainLevel(0.0)
end)

RegisterCommand("forcerain", function()
    TriggerServerEvent("VICE:tryForceWeather", "RAIN")
    forcedWeather = "RAIN"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("RAIN")
    SetWeatherTypeNow("RAIN")
    SetWeatherTypeNowPersist("RAIN")
    SetRainLevel(0.8)
end)

RegisterCommand("forceclearing", function()
    TriggerServerEvent("VICE:tryForceWeather", "CLEARING")
    forcedWeather = "CLEARING"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("CLEARING")
    SetWeatherTypeNow("CLEARING")
    SetWeatherTypeNowPersist("CLEARING")
    SetRainLevel(0.3)
end)

RegisterCommand("forcethunder", function()
    TriggerServerEvent("VICE:tryForceWeather", "THUNDER")
    forcedWeather = "THUNDER"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("THUNDER")
    SetWeatherTypeNow("THUNDER")
    SetWeatherTypeNowPersist("THUNDER")
    SetRainLevel(1.0)
end)

RegisterCommand("forcesmog", function()
    TriggerServerEvent("VICE:tryForceWeather", "SMOG")
    forcedWeather = "SMOG"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("SMOG")
    SetWeatherTypeNow("SMOG")
    SetWeatherTypeNowPersist("SMOG")
    SetRainLevel(0.0)
end)

RegisterCommand("forcehaze", function()
    TriggerServerEvent("VICE:tryForceWeather", "HAZE")
    forcedWeather = "HAZE"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("HAZE")
    SetWeatherTypeNow("HAZE")
    SetWeatherTypeNowPersist("HAZE")
    SetRainLevel(0.0)
end)

RegisterCommand("forcesnowlight", function()
    TriggerServerEvent("VICE:tryForceWeather", "SNOWLIGHT")
    forcedWeather = "SNOWLIGHT"
    SetForceVehicleTrails(true)
    SetForcePedFootstepsTracks(true)
    SetWeatherTypePersist("SNOWLIGHT")
    SetWeatherTypeNow("SNOWLIGHT")
    SetWeatherTypeNowPersist("SNOWLIGHT")
    SetRainLevel(0.0)
end)

RegisterCommand("forceblizzard", function()
    TriggerServerEvent("VICE:tryForceWeather", "BLIZZARD")
    forcedWeather = "BLIZZARD"
    SetForceVehicleTrails(true)
    SetForcePedFootstepsTracks(true)
    SetWeatherTypePersist("BLIZZARD")
    SetWeatherTypeNow("BLIZZARD")
    SetWeatherTypeNowPersist("BLIZZARD")
    SetRainLevel(0.0)
end)

RegisterCommand("forcehalloween", function()
    TriggerServerEvent("VICE:tryForceWeather", "HALLOWEEN")
    forcedWeather = "HALLOWEEN"
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetWeatherTypePersist("HALLOWEEN")
    SetWeatherTypeNow("HALLOWEEN")
    SetWeatherTypeNowPersist("HALLOWEEN")
    SetRainLevel(0.0)
end)

-- Add event to sync forced weather when player joins
RegisterNetEvent("VICE:syncForcedWeather")
AddEventHandler("VICE:syncForcedWeather", function(weatherType)
    if weatherType then
        forcedWeather = weatherType
        a = weatherType
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weatherType)
        SetWeatherTypeNow(weatherType)
        SetWeatherTypeNowPersist(weatherType)
        
        -- Handle special weather effects
        if weatherType == "XMAS" then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
            SetRainLevel(0.0)
        elseif weatherType == "SNOWLIGHT" or weatherType == "BLIZZARD" then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end

        -- Additional weather type specific settings
        if weatherType == "THUNDER" then
            SetRainLevel(1.0)
        elseif weatherType == "RAIN" then
            SetRainLevel(0.8)
        elseif weatherType == "CLEARING" then
            SetRainLevel(0.3)
        else
            SetRainLevel(0.0)
        end
    end
end)
