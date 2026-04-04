local a = module("cfg/cfg_identity")
local b = {
    onJob = false,
    spawnVehicleVector = vector3(-1172.4587402344, -876.53637695312, 14.131204605103),
    startVector = vector3(-1174.4127197266, -872.98626708984, 15.136045455933),
    tempMarker = 0,
    tempBlip = 0,
    tempVehicle = 0,
    tempObject = 0,
    cashEarned = 0,
    stopNumber = 0,
    customerName = "",
    previousCustomisation = nil
}
local c = 17
local d = {"bmx", "cruiser", "fixter", "scorcher", "tribike", "tribike2", "tribike3"}
RegisterNetEvent("VICE:beginDeliverooJob",function()
    local e = d[math.random(1, #d)]
    b.tempVehicle = VICE.spawnVehicle(e,b.spawnVehicleVector.x,b.spawnVehicleVector.y,b.spawnVehicleVector.z,343,true,true,true)
    b.onJob = true
    VICE.disableCustomizationSave(b.onJob)
    b.previousCustomisation = tVICE.getCustomization()
    local f = PlayerPedId()
    SetPedComponentVariation(f, 5, 126, 0, 0)
    SetPedComponentVariation(f, 6, 0, 0, 0)
    SetPedComponentVariation(f, 11, 449, 0, 0)
    VICE.notify("~g~Deliveroo Job started, exit the restaurant and head to the first drop off.")
    while b.onJob do
        DrawGTATimerBar("DELIVERIES:", b.stopNumber .. "/" .. c, 2)
        DrawGTATimerBar("~g~EARNED:", "£" .. getMoneyStringFormatted(b.cashEarned), 1)
        drawNativeText("Deliver to ~y~" .. b.customerName .. "~w~.")
        Wait(0)
    end
end)
RegisterNetEvent("VICE:deliverooJobEnd",function(g)
    if g then
        VICE.notify("~g~Shift complete.")
        DeleteVehicle(GetVehiclePedIsIn(VICE.getPlayerPed(), false))
        DeleteVehicle(b.tempVehicle)
    else
        RemoveBlip(b.tempBlip)
        tVICE.removeMarker(b.tempMarker)
    end
    tVICE.setCustomization(b.previousCustomisation)
    b.onJob = false
    VICE.disableCustomizationSave(b.onJob)
    b.tempMarker = 0
    b.tempBlip = 0
    b.tempVehicle = 0
    b.tempObject = 0
    b.cashEarned = 0
    b.stopNumber = 0
    b.customerName = ""
    b.previousCustomisation = nil
end)
RegisterNetEvent("VICE:deliverooJobReachedNextStop",function(i)
    local j = b.tempVehicle
    b.stopNumber = b.stopNumber + 1
    if i then
        b.cashEarned = b.cashEarned + i
    end
    Citizen.CreateThread(function()
        while j do
            SetVehicleEngineOn(j, false, true, false)
            Wait(0)
        end
    end)
    if b.tempMarker then
        tVICE.removeMarker(b.tempMarker)
    end
    RemoveBlip(b.tempBlip)
    SetTimeout(2500,function()
        j = nil
    end)
end)
RegisterNetEvent("VICE:deliverooJobSetNextBlip",function(k)
    b.tempBlip = AddBlipForCoord(k.x, k.y, k.z)
    SetBlipSprite(b.tempBlip, 1)
    SetBlipRoute(b.tempBlip, true)
    b.tempMarker = tVICE.addMarker(k.x, k.y, k.z - 1, 2.0, 2.0, 1.0, 200, 20, 0, 50, 50)
    local l = a.random_first_names
    b.customerName = l[math.random(1, #l)] .. " " .. l[math.random(1, #l)]
end)
AddEventHandler("VICE:onClientSpawn",function(m, n)
    if n then
        local o = function(p)
            drawNativeNotification("Press ~INPUT_PICKUP~ to start your deliveroo shift")
        end
        local q = function(p)
        end
        local r = function(p)
            if IsControlJustReleased(1, 38) and not b.onJob then
                TriggerServerEvent("VICE:attemptBeginDeliverooJob")
            end
        end
        tVICE.addBlip(b.startVector.x, b.startVector.y, b.startVector.z, 106, 1, "Deliveroo Job")
        tVICE.addMarker(b.startVector.x,b.startVector.y,b.startVector.z - 1,1.0,1.0,1.0,255,0,0,70,50,38,false,false,true)
        VICE.createArea("deliveroo", b.startVector, 1.5, 6, o, q, r, {})
    end
end)
