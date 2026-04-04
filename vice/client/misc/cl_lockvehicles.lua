local function a()
    local b = VICE.getPlayerPed()
    if GetEntityHealth(b) > 102 then
        local c, d = VICE.getNearestOwnedVehicle(8)
        if d then
            if c then
                VICE.vc_toggleLock(d)
                VICE.playSound("HUD_MINI_GAME_SOUNDSET", "5_SEC_WARNING")
                Citizen.Wait(1000)
            else
                Citizen.Wait(1000)
                VICE.notify("~r~You do not own this vehicle")
            end
        else
            VICE.notify("~r~No owned vehicle found nearby to lock/unlock")
        end
    else
        VICE.notify("~r~You may not lock/unlock your vehicle whilst dead.")
    end
end
RegisterCommand('lockVehicle', function(source, args, rawCommand)
    a()
end, false)
AddEventHandler("VICE:lockNearestVehicle",function()
    a()
end)

RegisterKeyMapping("lockVehicle", "Lock closest vehicle", "keyboard", "COMMA")