function func_recoilHandler()
    local playerPed = PlayerPedId()
    if IsPedArmed(playerPed, 6) then
        DisableControlAction(1, 140, true)
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)
    end
    DisplayAmmoThisFrame(false)
    HideHudComponentThisFrame(2)
end
VICE.createThreadOnTick(func_recoilHandler)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if IsPedShooting(VICE.getPlayerPed()) then
            if GetVehiclePedIsIn(VICE.getPlayerPed(), false) == 0 then
                local b, c = GetCurrentPedWeapon(VICE.getPlayerPed())
                b, cAmmo = GetAmmoInClip(VICE.getPlayerPed(), c)
                tv = 0
                repeat
                    Wait(0)
                    p = GetGameplayCamRelativePitch()
                    if GetFollowPedCamViewMode() ~= 4 then
                        SetGameplayCamRelativePitch(p + 0.1, 0.2)
                    end
                    tv = tv + 0.1
                until tv >= 0.15
            end
        end
    end
end)
