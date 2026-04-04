globalOnTacoDuty = false
local a = false
local b
local c
local d = {}
local e = {}
local f = {}
RegisterNetEvent("VICE:removeTacoSeller",function(g)
    d[g] = nil
    refreshMarkersAndBlips()
end)
RegisterNetEvent("VICE:sendClientTacoData",function(h)
    d = h
    refreshMarkersAndBlips()
end)
RegisterNetEvent("VICE:toggleTacoJob",function(i)
    globalOnTacoDuty = i
end)
RegisterCommand("taco",function(j, k, l)
    local m = GetEntityCoords(VICE.getPlayerPed())
    local n = GetVehiclePedIsIn(VICE.getPlayerPed())
    local o = GetEntityModel(n)
    if not a then
        if globalOnTacoDuty then
            if o == `taco` then
                VICE.notify("~g~Now selling tacos!")
                SetVehicleDoorOpen(n, 5, true, true)
                tacoVehicle = n
                a = true
                FreezeEntityPosition(n, true)
                TriggerServerEvent("VICE:addTacoSeller", m, 15000)
                while GetVehiclePedIsIn(VICE.getPlayerPed(), false) == tacoVehicle do
                    Wait(100)
                end
                VICE.notify("~r~Stopped selling tacos!")
                SetVehicleDoorShut(n, 5, true)
                FreezeEntityPosition(n, false)
                tacoVehicle = nil
                a = false
                TriggerServerEvent("VICE:RemoveMeFromTacoPositions")
            else
                VICE.notify("~r~Stopped selling tacos!")
                SetVehicleDoorShut(n, 5, true)
                tacoVehicle = nil
                a = false
                TriggerServerEvent("VICE:RemoveMeFromTacoPositions")
            end
        else
            VICE.notify("~r~You do not have the taco seller job!")
        end
    end
end,false)
Citizen.CreateThread(function()
    while true do
        if tacoVehicle then
            SetVehicleEngineOn(tacoVehicle, false, true, false)
        end
        Wait(0)
    end
end)
function refreshMarkersAndBlips()
    for p, q in pairs(e) do
        tVICE.removeMarker(q)
    end
    for p, r in pairs(f) do
        tVICE.removeBlip(r)
    end
    e = {}
    f = {}
    for g, s in pairs(d) do
        table.insert(f, tVICE.addBlip(s.position.x, s.position.y, s.position.z, 52, 17, "Taco Seller"))
        s.position = s.position - GetEntityForwardVector(PlayerPedId()) * 1.2
        table.insert(e,tVICE.addMarker(s.position.x, s.position.y, s.position.z - 1, 5.0, 5.0, 2.0, 255, 100, 0, 70, 50))
    end
end
Citizen.CreateThread(function()
    while true do
        local m = GetEntityCoords(VICE.getPlayerPed())
        for g, s in pairs(d) do
            local t = #(m - s.position)
            if t < 7 then
                b = g
                c = s.amount
            end
            while #(GetEntityCoords(VICE.getPlayerPed()) - s.position) <= 8 do
                Wait(100)
            end
            b = nil
            c = nil
        end
        Wait(5000)
    end
end)
Citizen.CreateThread(function()
    while true do
        if not a and b then
            drawNativeNotification("Press ~INPUT_CONTEXT~ to buy a taco for ~g~£" .. c)
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent("VICE:payTacoSeller", b)
                Wait(50)
            end
        end
        Wait(0)
    end
end)