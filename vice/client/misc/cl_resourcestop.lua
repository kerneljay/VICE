local display = false

RegisterNetEvent('showEndScreen')
AddEventHandler('showEndScreen', function()
    display = true
    SendNUIMessage({
        type = "showEndScreen"
    })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('hideEndScreen')
AddEventHandler('hideEndScreen', function()
    display = false
    SendNUIMessage({
        type = "hideEndScreen"
    })
    SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if display then
            -- Disable controls while the screen is displayed
            DisableControlAction(0, 1, true) -- LookLeftRight
            DisableControlAction(0, 2, true) -- LookUpDown
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
        end
    end
end)
