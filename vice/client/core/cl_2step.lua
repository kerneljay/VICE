local a = {twoStepControl = 137, TwoStepCars = {"mkay"}}
local b = {}
local c
local d = false
local e = false
Citizen.CreateThread(function()
    while true do
        local f = VICE.getPlayerPed()
        local g = GetVehiclePedIsIn(VICE.getPlayerPed(), false)
        if g ~= 0 and GetPedInVehicleSeat(g, -1) == f then
            local h, i = VICE.getVehicleInfos(g)
            if h == VICE.getUserId() then
                if b[i] and b[i] ~= 0 then
                    c = i
                    d = true
                    while GetVehiclePedIsIn(VICE.getPlayerPed(), false) ~= 0 and e == false do
                        Wait(100)
                    end
                    e = false
                    d = false
                end
            end
        end
        Wait(1000)
    end
end)
Citizen.CreateThread(function()
    while true do
        if d then
            if not IsControlPressed(1, 71) and not IsControlPressed(1, 72) then
                local j = VICE.getPlayerPed()
                if IsPedInAnyVehicle(j) then
                    local k = GetVehiclePedIsIn(j, false)
                    local l = GetEntityCoords(j)
                    local m = GetEntityCoords(k)
                    local n = GetVehicleCurrentRpm(GetVehiclePedIsIn(VICE.getPlayerPed(), false))
                    local o = math.random(25, 200)
                    if GetPedInVehicleSeat(k, -1) == j then
                        if n > 0.75 then
                            vehicleFlameExhaustEffect(k)
                            AddExplosion(m.x, m.y, m.z, 61, 0.0, true, true, 0.0)
                            SetVehicleTurboPressure(k, 25)
                            Wait(o)
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)
function getVehicleAntilag(i)
    return b[i] or false
end
function setVehicleAntiLag(i, p)
    e = true
    b[i] = p
end