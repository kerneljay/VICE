function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

local config = {
    ["TITLE"] = "VICE British Roleplay",
    ["SUBTITLE"] = "https://discord.gg/UTzM4kcCjG",
    ["MAP"] = "City Map",
    ["STATUS"] = "Player Status",
    ["GAME"] = "Disconnect",
    ["INFO"] = "Information",
    ["SETTINGS"] = "Settings",
    ["R*EDITOR"] = "R* Editor"
}

Citizen.CreateThread(function()
	while true do
    Citizen.Wait(0)
        N_0xb9449845f73f5e9c("SHIFT_CORONA_DESC")
        PushScaleformMovieFunctionParameterBool(true)
        PopScaleformMovieFunction()
        N_0xb9449845f73f5e9c("SET_HEADER_TITLE")
        PushScaleformMovieFunctionParameterString(config["TITLE"])
        PushScaleformMovieFunctionParameterBool(true)
        PushScaleformMovieFunctionParameterString(config["SUBTITLE"])
        PushScaleformMovieFunctionParameterBool(true)
        PopScaleformMovieFunctionVoid()
	end
end)

Citizen.CreateThread(function()
    AddTextEntry('PM_SCR_MAP', config["MAP"])
    AddTextEntry('PM_SCR_STA', config["STATUS"])
    AddTextEntry('PM_SCR_GAM', config["GAME"])
    AddTextEntry('PM_SCR_INF', config["INFO"])
    AddTextEntry('PM_SCR_SET', config["SETTINGS"])
    AddTextEntry('PM_SCR_RPL', config["R*EDITOR"])
end)

RegisterCommand("discord",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0Discord: https://discord.gg/UTzM4kcCjG","ooc")
    VICE.notify("~g~discord Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "Discord Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("https://discord.gg/UTzM4kcCjG")
end)
RegisterCommand("ts",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0TS: ts.viceforums.net","ooc")
    VICE.notify("~g~ts Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "TS Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("ts.viceforums.net")
end)
RegisterCommand("website",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0Forums: www.vicestudios.ltd","ooc")
    VICE.notify("~g~Website Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "Website Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("www.vicestudios.ltd")
end)
RegisterCommand("register",function()
    TriggerEvent("chatMessage","^1There is no need to /register on this server, to change your appearance go to a clothes store!")
end,false)

RegisterCommand('getid', function(source, args)
    if args and args[1] then 
        if VICE.clientGetUserIdFromSource(tonumber(args[1])) then
            if VICE.clientGetUserIdFromSource(tonumber(args[1])) ~= VICE.getUserId() then
                TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. VICE.clientGetUserIdFromSource(tonumber(args[1])), "alert")
            else
                TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. VICE.getUserId(), "alert")
            end
        else
            TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "Invalid Temp ID", "alert")
        end
    else 
        TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "Please specify a user eg: /getid [tempid]", "alert")
	end
end)

-- RegisterCommand("linktwitter",function()
--     SendNUIMessage({act="openurl",url="https://www.youtube.com/watch?v=dQw4w9WgXcQ"}) mkay
-- end,false)
function AddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

local config = {
    ["TITLE"] = "VICE British Roleplay",
    ["SUBTITLE"] = "https://discord.gg/UTzM4kcCjG",
    ["MAP"] = "City Map",
    ["STATUS"] = "Player Status",
    ["GAME"] = "Disconnect",
    ["INFO"] = "Information",
    ["SETTINGS"] = "Settings",
    ["R*EDITOR"] = "R* Editor"
}

Citizen.CreateThread(function()
    while true do
    Citizen.Wait(0)
        N_0xb9449845f73f5e9c("SHIFT_CORONA_DESC")
        PushScaleformMovieFunctionParameterBool(true)
        PopScaleformMovieFunction()
        N_0xb9449845f73f5e9c("SET_HEADER_TITLE")
        PushScaleformMovieFunctionParameterString(config["TITLE"])
        PushScaleformMovieFunctionParameterBool(true)
        PushScaleformMovieFunctionParameterString(config["SUBTITLE"])
        PushScaleformMovieFunctionParameterBool(true)
        PopScaleformMovieFunctionVoid()
    end
end)

Citizen.CreateThread(function()
    AddTextEntry('PM_SCR_MAP', config["MAP"])
    AddTextEntry('PM_SCR_STA', config["STATUS"])
    AddTextEntry('PM_SCR_GAM', config["GAME"])
    AddTextEntry('PM_SCR_INF', config["INFO"])
    AddTextEntry('PM_SCR_SET', config["SETTINGS"])
    AddTextEntry('PM_SCR_RPL', config["R*EDITOR"])
end)

RegisterCommand("discord",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0Discord: https://discord.gg/UTzM4kcCjG","ooc")
    VICE.notify("~g~discord Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "Discord Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("https://discord.gg/UTzM4kcCjG")
end)
RegisterCommand("ts",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0TS: ts.viceforums.net","ooc")
    VICE.notify("~g~ts Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "TS Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("ts.viceforums.net")
end)
RegisterCommand("website",function()
    TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 },"^0Forums: www.vicestudios.ltd","ooc")
    VICE.notify("~g~Website Copied to Clipboard.")
    TriggerEvent("VICE:showNotification",
        {
            text = "Website Copied To Clipboard.",
            height = "200px",
            width = "auto",
            colour = "#FFF",
            background = "#32CD32",
            pos = "bottom-right",
            icon = "good"
        }, 5000
    )
    tVICE.CopyToClipBoard("www.vicestudios.ltd")
end)
RegisterCommand("register",function()
    TriggerEvent("chatMessage","^1There is no need to /register on this server, to change your appearance go to a clothes store!")
end,false)

RegisterCommand('getid', function(source, args)
    if args and args[1] then 
        if VICE.clientGetUserIdFromSource(tonumber(args[1])) then
            if VICE.clientGetUserIdFromSource(tonumber(args[1])) ~= VICE.getUserId() then
                TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. VICE.clientGetUserIdFromSource(tonumber(args[1])), "alert")
            else
                TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "This Users Perm ID is: " .. VICE.getUserId(), "alert")
            end
        else
            TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "Invalid Temp ID", "alert")
        end
    else 
        TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "Please specify a user eg: /getid [tempid]", "alert")
    end
end)

-- RegisterCommand("linktwitter",function()
--     SendNUIMessage({act="openurl",url="https://www.youtube.com/watch?v=dQw4w9WgXcQ"}) mkay
-- end,false)