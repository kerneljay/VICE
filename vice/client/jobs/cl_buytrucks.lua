RMenu.Add(
    "vicetruckmenu",
    "buy-rent",
    RageUI.CreateMenu("VICE Trucking", "~b~VICE Trucking", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RMenu.Add(
    "vicetruckmenu",
    "vehicle",
    RageUI.CreateSubMenu(
        RMenu:Get("vicetruckmenu", "buy-rent"),
        "VICE Trucking",
        "~b~VICE Trucking",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "vicetruckmenu",
    "vehicles",
    RageUI.CreateMenu("Your Trucks", "~b~VICE Trucking", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RMenu.Add(
    "vicetruckmenu",
    "rented_trucks",
    RageUI.CreateSubMenu(
        RMenu:Get("vicetruckmenu", "vehicles"),
        "Rented Vehicles",
        "~b~VICE Trucking",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "vicetruckmenu",
    "owned_trucks",
    RageUI.CreateSubMenu(
        RMenu:Get("vicetruckmenu", "vehicles"),
        "Owned Vehicles",
        "~b~VICE Trucking",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
local a = module("cfg/cfg_trucking")
local b = a.trucks
local c = {}
local d = {}
local e
local f = ""
local g
local h
local i = false
local j = false
local k = 10.0
local rentedTrucks = {}
globalOnTruckJob = false
RageUI.CreateWhile(1.0, true, function() -- Renting trucks tbd
    if RageUI.Visible(RMenu:Get('vicetruckmenu', 'buy-rent')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for l, m in pairs(b) do
                if not m.custom then
                    local n
                    if rentedTrucks[l] then
                        n = {RightBadge = RageUI.BadgeStyle.Tick}
                    else
                        n = {RightLabel = "£" .. getMoneyStringFormatted(m.price)}
                    end
                    RageUI.Button(m.name,"Press to spawn.",n,true,function(o, p, q)
                        if q then
                            if rentedTrucks[l] then
                                trySpawnVehicle(l)
                            else
                                tryRental(l, m.price)
                                rentedTrucks[l] = true
                            end
                        end
                    end)
                end
            end
        end)
    end
end)
RegisterNetEvent("VICE:updateOwnedTrucks")
AddEventHandler("VICE:updateOwnedTrucks", function(rentedTrucks)
    d["owned"] = b
    d["rented"] = rentedTrucks
end)
RegisterNetEvent("VICE:setTruckerOnDuty",function(s)
    globalOnTruckJob = s
end)
function tryRental(t, u)
    TriggerServerEvent("VICE:rentTruck", t, u)
    TriggerServerEvent('VICE:getRentedTrucks')
end
function getVehicleName(v)
    for l, m in pairs(b) do
        if GetHashKey(l) == v then
            return l
        end
    end
    return nil
end
Citizen.CreateThread(function()
    for w = 1, #a.buylocations do
        local x = a.buylocations[w]
        local y = x.main
        VICE.add3DTextForCoord("Truck Rental", y.x, y.y, y.z, 8.0)
        VICE.add3DTextForCoord("Truck Dealership", 895.98162841797,-3186.9907226562, y.z, 8.0)
        tVICE.addMarker(y.x, y.y, y.z, 0.7, 0.7, 0.5, 0, 255, 125, 125, 50, 29, true, true)
        tVICE.addBlip(y.x, y.y, y.z, 67, 5, "Truck Rental")
        tVICE.addBlip(895.98162841797,-3186.9907226562, y.z, 67, 5, "Truck Dealership")
    end
end)
AddEventHandler("VICE:onClientSpawn",function(z, A)
    if A then
        TriggerServerEvent('VICE:getRentedTrucks')
        local B = function(C)
            if not IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) ~= e then
                i = true
                RageUI.ActuallyCloseAll()
                RageUI.Visible(RMenu:Get('vicetruckmenu','buy-rent'),true)
            end
        end
        local D = function()
            i = false
            RageUI.ActuallyCloseAll()
        end
        local E = function()
        end
        for w = 1, #a.buylocations do
            local x = a.buylocations[w]
            local y = x.main
            VICE.createArea("trucking_buy_" .. w, x.main, 1.15, 6, B, D, E, {})
        end
    end
end)
function trySpawnVehicle(F)
    TriggerServerEvent("VICE:spawnTruck", F)
end
RegisterNetEvent("VICE:spawnTruckCl",function(F)
    local ped = PlayerPedId()
    local y = GetEntityCoords(ped)
    local G = VICE.spawnVehicle(F, y.x, y.y, y.z, GetEntityHeading(ped), true, true, true)
end)
function getAllTrucks()
    TriggerServerEvent("VICE:truckerJobBuyAllTrucks")
end
