local isPauseMenuOpen = false
local urlIsOpen = false
RegisterKeyMapping("viceTogglePauseMenu", "", "keyboard", "ESCAPE")
RegisterKeyMapping("viceTogglePauseMenuController", "", "controller", "START")

-- Add blur effect variables
local blurIntensity = 3.0

local function togglePauseMenu()
    if IsPauseMenuActive() then
        return
    end

    if isPauseMenuOpen then
        viceClosePauseMenu()
    elseif not tVICE.isInComa() then
        TriggerServerEvent('VICE:getPlayerListData')
        viceShowPauseMenu()
    end
end
RegisterCommand('viceTogglePauseMenu', togglePauseMenu)
RegisterCommand('viceTogglePauseMenuController', togglePauseMenu)

function tVICE.isPauseMenuOpen()
    return isPauseMenuOpen
end

function viceShowPauseMenu()
    if IsPauseMenuActive() and tVICE.isInComa() then
        return
    end
    SetPauseMenuActive(true)
    DisableIdleCamera(true)
    ExecuteCommand('hideui')
    SetNuiFocusKeepInput(false)
    
    -- Apply the same blur as dispute system
    TransitionToBlurred(1000)
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "viceTogglePauseMenu",
        toggle = true,
        viceDLastName = tostring(getMoneyStringFormatted(VICE.getPlayerHours(VICE.getUserId()))), -- PLAYTIME
        viceDBirthdate = VICE.getEmploymentStatus(), -- EMPLOYMENT
        totalPlayers = #GetPlayers() .. "/" .. GetConvar("sv_maxclients", "64"), -- TOTAL PLAYERS ONLINE
        viceDGender = getMoneyStringFormatted(VICE.getUserId()), -- ID
        deathmatchPlayers = "0/" .. GetConvar("sv_maxclients", "64"), -- TOTAL DEATHMATCH PLAYERS ONLINE
        vicePlrName = VICE.getPlayerName(GetPlayerServerId(PlayerId())), -- NAME
    })
    isPauseMenuOpen = true
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPauseMenuActive(false)
    end
end)

RegisterNUICallback('Close', function(data)
    viceClosePauseMenu()
end)

RegisterNUICallback('Settings', function(data)
    viceClosePauseMenu()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_LANDING_MENU'),0,-1) 
end)

RegisterNUICallback('Dispute', function(data)
    viceClosePauseMenu()
    ExecuteCommand('dispute')
end)

RegisterNUICallback('ReadRules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://vicestudios.ltd/rules/rules-redirect.html')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('DeathMatchDiscord', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://discord.gg/UTzM4kcCjG')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('DeathMatchF8', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        TriggerEvent("VICE:showNotification",
            {
                text = "F8 Connect Copied To Clipboard.",
                height = "200px",
                width = "auto",
                colour = "#FFF",
                background = "#32CD32",
                pos = "bottom-right",
                icon = "good"
            }, 5000
        )
        tVICE.CopyToClipBoard("deathmatch.vice.city")
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)


RegisterNUICallback('Rules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://vicestudios.ltd/rules/fivem-rules.html')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('ComRules', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://vicestudios.ltd/rules/community-rules.html')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('VICEDiscord', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://discord.gg/UTzM4kcCjG')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Guide', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://wiki.vicestudios.ltd/')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Twitter', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://x.com/VICEFiveM')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Website', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://vicestudios.ltd')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Store', function(data)
    if not urlIsOpen then
        urlIsOpen = true
        tVICE.OpenUrl('https://store.vicestudios.ltd')
    else
        VICE.notify('~r~You are being rate limited. Please wait a few seconds before trying again.')
    end
end)

RegisterNUICallback('Map', function(data)
    viceClosePauseMenu()
    ActivateFrontendMenu(GetHashKey('FE_MENU_VERSION_MP_PAUSE'),0,-1)
end)

RegisterNUICallback('Disconnect', function(data)
    viceClosePauseMenu()
	TriggerServerEvent('kick:PauseMenu')
end)

function viceClosePauseMenu()
    if IsPauseMenuActive() then
        return
    end
    ExecuteCommand('showui')
    DisableIdleCamera(false)
    
    -- Remove blur using same method as dispute system
    TransitionFromBlurred(1000)
    
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SetFrontendActive(false)
    SendNUIMessage({
        type = "viceTogglePauseMenu",
        toggle = false
    })
    isPauseMenuOpen = false
end

Citizen.CreateThread(function()
    while true do
        Wait(1500) -- 1.5 seconds
        if urlIsOpen then
           urlIsOpen = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) 
        if IsControlJustReleased(0, 199) then

            if isPauseMenuOpen then
                viceClosePauseMenu()
            elseif not tVICE.isInComa() then
                viceShowPauseMenu()
            end
        end
    end
end)

RegisterNetEvent('VICE:callOpenPReport')
AddEventHandler('VICE:callOpenPReport', function(data)
    tVICE.OpenUrl(data)
end)

RegisterNetEvent('viceHidePauseMenu')
AddEventHandler('viceHidePauseMenu', function()
	viceClosePauseMenu()
end)

RegisterNetEvent('viceShowPauseMenu')
AddEventHandler('viceShowPauseMenu', function()
	viceShowPauseMenu()
end)