local menuOpen = false
local menuEnabled = false

RegisterNetEvent("VICE:characterTutorial")
AddEventHandler("VICE:characterTutorial", function()
    if not menuEnabled then
        menuOpen = not menuOpen
        menuEnabled = true
        -- ShutdownLoadingScreen()
        -- ShutdownLoadingScreenNui()

        SendNUIMessage({
            type = "menuState",
            value = menuOpen
        })

        if menuOpen then
            ExecuteCommand("hideui")
            TriggerScreenblurFadeIn(500.0)
            SetNuiFocus(true, true) 
        else
            ExecuteCommand("showui")
            TriggerScreenblurFadeOut(500.0)
            SetNuiFocus(false, false) 
        end
    end
end)

RegisterNUICallback("VICE:pickMale", function()
    if menuEnabled then
        VICE.loadCustomisationPreset("Danny")
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, false)
        menuEnabled = false
        SendNUIMessage({
            type = "closeMenu"
        })
        ExecuteCommand("showui")
        TriggerScreenblurFadeOut(500.0)
        SetNuiFocus(false, false)
        CreateThread(function()
            Wait(250)
            TriggerEvent("VICE:sendTutorialThingy", {
                run = true,
                gender = "male",
                preset = "Danny"
            })
        end)
    end
end)

RegisterNUICallback("VICE:pickFemale", function()
    if menuEnabled then
        VICE.loadCustomisationPreset("TutFemale")
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, false)
        menuEnabled = false
        SendNUIMessage({
            type = "closeMenu"
        })
        ExecuteCommand("showui")
        TriggerScreenblurFadeOut(500.0)
        SetNuiFocus(false, false) 
    end
end)

