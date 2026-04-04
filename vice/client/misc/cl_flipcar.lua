local a=false
RegisterCommand("flipcar",function()
    local b,c=VICE.getPlayerVehicle()
    if b==0 then 
        VICE.notify("You are not in a vehicle")
        return 
    end
    if not c then 
        VICE.notify("You are not the driver of this vehicle")
        return 
    end
    if GetIsVehicleEngineRunning(b)then 
        VICE.notify("You must have the engine off to flip the vehicle")
        return 
    end
    if IsVehicleOnAllWheels(b)then 
        VICE.notify("Your vehicle does not require flipping")
        return 
    end
    if a then 
        VICE.notify("Your vehicle is already waiting to be flipped")
        return 
    end
    a=true
    VICE.notify("Flipping your vehicle in 20 seconds. Please remain stationary")
    local d=VICE.getPlayerPed()
    local e=GetEntityHealth(d)
    local f=GetGameTimer()
    while GetGameTimer()-f<20000 do 
        if VICE.getPlayerVehicle()~=b then 
            VICE.notify("Cancelling flip as you left the vehicle")
            a=false
            return 
        end
        if GetEntityHealth(d)~=e then 
            VICE.notify("Cancelling flip as you received damage")
            a=false
            return 
        end
        if GetEntitySpeed(b)>=4.4704 then 
            VICE.notify("Cancelling flip as you are not stationary")
            a=false
            return 
        end
        if GetIsVehicleEngineRunning(b)then 
            VICE.notify("Cancelling flip as you turned the engine on")
            a=false
            return 
        end
        Citizen.Wait(0)
    end
    SetVehicleOnGroundProperly(b)
    VICE.notify("Your vehicle has been flipped")
    a=false 
end)