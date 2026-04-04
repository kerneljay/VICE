local a = {
    onJob = false,
    spawnVehicleVector = vector3(-17.703647613525, -696.84149169922, 32.344856262207),
    startVector = vector3(-19.447393417358, -705.32580566406, 32.338104248046),
    tempMarker = 0,
    tempBlip = 0,
    tempVehicle = 0,
    tempObject = 0,
    cashEarned = 0,
    stopNumber = 0
}
local b = 14
RegisterNetEvent(
    "VICE:beginRoyalMailJob",
    function()
        a.tempVehicle =
            VICE.spawnVehicle(
            "boxville2",
            a.spawnVehicleVector.x,
            a.spawnVehicleVector.y,
            a.spawnVehicleVector.z,
            343,
            true,
            true,
            true
        )
        a.onJob = true
        VICE.notify("~g~Royal Mail Job started, exit the car park on your left and head to your first drop off point.")
        while a.onJob do
            DrawGTATimerBar("PACKAGES:", a.stopNumber .. "/" .. b, 2)
            DrawGTATimerBar("~g~EARNED:", "£" .. getMoneyStringFormatted(a.cashEarned), 1)
            Wait(0)
        end
    end
)
RegisterNetEvent(
    "VICE:royalMailJobEnd",
    function()
        VICE.notify("~g~Shift complete.")
        DeleteVehicle(GetVehiclePedIsIn(VICE.getPlayerPed(), false))
        DeleteVehicle(a.tempVehicle)
        a.onJob = false
        a.tempMarker = 0
        a.tempBlip = 0
        a.tempVehicle = 0
        a.tempObject = 0
        a.cashEarned = 0
        a.stopNumber = 0
    end
)
RegisterNetEvent(
    "VICE:royalMailReachedNextStop",
    function(c, d)
        RemoveBlip(a.tempBlip)
        local e = a.tempVehicle
        a.stopNumber = a.stopNumber + 1
        if d then
            a.cashEarned = a.cashEarned + d
        end
        Citizen.CreateThread(
            function()
                while e do
                    SetVehicleEngineOn(e, false, true, false)
                    Wait(0)
                end
            end
        )
        if a.tempMarker then
            tVICE.removeMarker(a.tempMarker)
        end
        SetVehicleDoorOpen(e, 2, false, false)
        SetVehicleDoorOpen(e, 3, false, false)
        if DoesEntityExist(a.tempObject) then
            DeleteObject(a.tempObject)
        end
        local f = VICE.loadModel("prop_drug_package")
        a.tempObject = CreateObject(f, c.x, c.y, c.z, false, false, true)
        PlaceObjectOnGroundProperly(a.tempObject)
        SetModelAsNoLongerNeeded(f)
        SetTimeout(
            2500,
            function()
                SetVehicleDoorShut(e, 2, false)
                SetVehicleDoorShut(e, 3, false)
                e = nil
            end
        )
    end
)
RegisterNetEvent(
    "VICE:royalMailJobSetNextBlip",
    function(g)
        a.tempBlip = AddBlipForCoord(g.x, g.y, g.z)
        SetBlipSprite(a.tempBlip, 1)
        SetBlipRoute(a.tempBlip, true)
        a.tempMarker = tVICE.addMarker(g.x, g.y, g.z - 1, 2.0, 2.0, 1.0, 200, 20, 0, 50, 50)
    end
)
AddEventHandler(
    "VICE:onClientSpawn",
    function(h, i)
        if i then
            local j = function(k)
                drawNativeNotification("Press ~INPUT_PICKUP~ to start your Royal Mail job")
            end
            local l = function(k)
            end
            local m = function(k)
                if IsControlJustReleased(1, 38) and not a.onJob then
                    TriggerServerEvent("VICE:attemptBeginRoyalMailJob")
                end
            end
            tVICE.addBlip(a.startVector.x, a.startVector.y, a.startVector.z, 67, 1, "Royal Mail Job")
            tVICE.addMarker(
                a.startVector.x,
                a.startVector.y,
                a.startVector.z,
                1.0,
                1.0,
                1.0,
                255,
                0,
                0,
                70,
                50,
                39,
                false,
                false,
                true
            )
            VICE.createArea("royalmail", a.startVector, 1.5, 6, j, l, m, {})
        end
    end
)
