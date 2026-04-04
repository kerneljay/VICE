local function a()
    local b = VICE.getPlayerVehicle()
    if b ~= 0 then
        local c = VICE.getPlayerPed()
        local d = VICE.getPlayerId()
        if GetVehicleClass(b) == 8 then
            if GetPedInVehicleSeat(b, -1) == c or GetSelectedPedWeapon(c) == `WEAPON_UNARMED` then
                SetPlayerCanDoDriveBy(d, false)
            else
                SetPlayerCanDoDriveBy(d, true)
            end
        else
            SetPlayerCanDoDriveBy(d, false)
        end
        DisableControlAction(0, 69, true)
        DisableControlAction(0, 70, true)
        DisableControlAction(0, 114, true)
        DisableControlAction(0, 331, true)
    end
end
VICE.createThreadOnTick(a)
