local h = {
  "Front Left",
  "Front Right",
  "Back Left",
  "Back Right",
  "Hood",
  "Trunk",
  "Second Trunk",
  "Windows",
  "Close All"
}
local j = {43, 427, 60, 786603, 1074528293, 262716, 537133628, 524860, 1076}
local k = {
  vehicle = nil,
  adSpeed = 1,
  autoDrive = false,
  limiterSpeed = 1,
  limiter = false,
  predictedMax = nil,
  door = 1,
  limitingVehicle = nil,
  currentLimit = nil,
  cruise = false,
  adMode = 1
}
local l = false
local m = false
local n = false
local o = false
local p = false
local q = 0
local r = true
local s = false
local t = 1
Citizen.CreateThread(function()
    while true do
        if m and VICE.getPlayerVehicle() ~= k.limitingVehicle then
            m = false
            SetVehicleMaxSpeed(VICE.getPlayerVehicle(), k.predictedMax)
            predictedMax = nil
            VICE.notify("Vehicle Changed, stopping limiter")
        end
        Wait(500)
    end
end)
function convert(speed)
  return speed * 10 * 0.44704 - 0.5
end

function limiter()
    Citizen.CreateThread(function()
        while k.limiter do
            local z = VICE.getPlayerVehicle()
            local speed = k.limiterSpeed
            if z ~= 0 then
                k.limitingVehicle = z
                m = true
                k.predictedMax = GetVehicleEstimatedMaxSpeed(z)
                if convert(speed) > k.predictedMax then
                    SetVehicleMaxSpeed(z, k.predictedMax)
                    k.currentLimit = k.predictedMax
                else
                    SetVehicleMaxSpeed(z, convert(speed))
                    k.currentLimit = convert(speed)
                end
            else
                VICE.notify("You are not in a vehicle!")
                k.limiter = false
            end
            Wait(100)
        end
        SetVehicleMaxSpeed(k.limitingVehicle, k.predictedMax)
        p = false
        m = false
    end)
end

RMenu.Add("vehicle_menu", "main", RageUI.CreateMenu("", "", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","vehiclemenu"))
RMenu:Get("vehicle_menu", "main"):SetSubtitle("V~w~EHICLE OPTIONS")
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("vehicle_menu", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.Button("Toggle Door Lock", "Select to toggle between doors locked and unlocked",{RightLabel=""},true,function(o,p,q)
                if q then
                    local L = VICE.getPlayerVehicle()
                    if L ~= 0 then
                        if GetVehicleDoorLockStatus(L) ~= 2 then
                            SetVehicleDoorsLocked(L, 2)
                            VICE.notify("~w~Doors are now ~r~Locked")
                        else
                            SetVehicleDoorsLocked(L, 0)
                            VICE.notify("~w~Doors are now ~g~Unlocked")
                        end
                    end
                end
            end)
            RageUI.List("Toggle Door",h,k.door,"Select the door you want to toggle open/closed.",{}, true, function(I, J, K, M)
                if K then
                    local L = VICE.getPlayerVehicle()
                    if L ~= 0 then
                        local N = M - 1
                        if M == 9 then
                            SetVehicleDoorsShut(L, false)
                            VICE.notify("Closed ~w~all doors.")
                        elseif M == 8 then
                            if r then
                                r = false
                                RollDownWindow(L, 0)
                                RollDownWindow(L, 1)
                                VICE.notify("Rolled windows ~r~Down")
                            else
                                r = true
                                RollUpWindow(L, 0)
                                RollUpWindow(L, 1)
                                VICE.notify("Rolled windows ~g~Up")
                            end
                        elseif IsVehicleDoorDamaged(L, N) then
                            VICE.notify("Cannot shut this door when the door is damaged")
                        elseif GetVehicleDoorAngleRatio(L, N) == 0 then
                            SetVehicleDoorOpen(L, N, false, false)
                            VICE.notify(string.format("The ~b~%s ~w~door is now ~g~Open", h[M]))
                        else
                            SetVehicleDoorShut(L, N, false)
                            VICE.notify(string.format("The ~b~%s ~w~door is now ~r~Closed", h[M]))
                        end
                    end
                end
                k.door = M
            end)
            RageUI.Checkbox("Activate Speed Limiter","Select to turn on Speed Limiter",k.limiter,{Style = RageUI.CheckboxStyle.Tick},function(I, K, J, O)
                if K then
                    if k.limiter then
                        RageUI.Text({message = string.format("~w~Speed Limiter is currently ~g~~h~Active")})
                        k.autoDrive = false
                        k.cruise = false
                        if not p then
                            local speed = GetEntitySpeed(VICE.getPlayerVehicle())
                            if convert(speed) < 10.0 then
                                p = true
                                limiter()
                            else
                                p = false
                                VICE.notify("Alert~w~: Please slow down to enable the speed limiter.")
                            end
                        end
                    else
                        RageUI.Text({message = string.format("~w~Speed Limiter is currently ~r~~h~Inactive")})
                    end
                end
                k.limiter = O
            end)
            RageUI.SliderProgress("Speed Limiter",k.limiterSpeed,25,"Select the speed you wish to limit your vehicle to.",{ProgressBackgroundColor = {R = 0, G = 0, B = 0, A = 255},ProgressColor = {R = 0, G = 117, B = 194, A = 255}},true,function(I, K, J, M)
                if K then
                    if M ~= k.limiterSpeed then
                        k.limiterSpeed = M
                        RageUI.Text({message = string.format("Setting Limiter Speed to: ~r~%s ~w~mph",k.limiterSpeed * 10)})
                    end
                end
            end)
            RageUI.Button("Toggle Engine","Select to toggle current vehicle engine on/off",{Style = RageUI.BadgeStyle.Key},true,function(I, J, K)
                if K then
                    local L = VICE.getPlayerVehicle()
                    if GetIsVehicleEngineRunning(L) then
                        if L ~= 0 then
                            SetVehicleEngineOn(L, false, true, true)
                            VICE.notify("You've turned the ignition into the ~r~off ~w~position.")
                        end
                    else
                        if L then
                            SetVehicleEngineOn(L, true, false, true)
                            VICE.notify("You've turned the ignition to the ~g~on ~w~position.")
                        end
                    end
                end
            end)
        end)
    end
end)
function waypointNearest(A)
    local B = VICE.getPlayerPed()
    local C = GetEntityCoords(B)
    if A == "garage" then
        for D = 1, #b.garageInstances do
            local E = b.garageInstances[D]
            if E[1] == "Standard Garage" or E[1] == "VIP Cars" then
                if #(E[2] - C) <= 1000000 then
                    SetNewWaypoint(E[2].x, E[2].y)
                    return
                end
            end
        end
    elseif A == "atm" then
        array = d
    elseif A == "mechanic" then
        array = c
    elseif A == "lsc" then
        array = e
    elseif A == "heli" then
        for D = 1, #b.garageInstances do
            local E = b.garageInstances[D]
            if E[1] == "Helicopter Merchant" or E[1] == "VIP Helicopter Merchant" then
                if #(E[2] - C) <= 1000000 then
                    SetNewWaypoint(E[2].x, E[2].y)
                    return
                end
            end
        end
    elseif A == "clothes" then
        array = f
    end
    local F = GetEntityCoords(VICE.getPlayerPed())
    local G = 1000000
    for D = 1, #array, 1 do
        local H = #(F - array[D])
        if H < G then
            t = D
        end
    end
    SetNewWaypoint(array[t].x, array[t].y)
    Citizen.Wait(100)
end


RegisterCommand('vehiclemenu', function(source, args, rawCommand)
    if IsPedInAnyVehicle(VICE.getPlayerPed(), false) or RageUI.Visible(RMenu:Get("vehicle_menu", "main")) then
        RageUI.ActuallyCloseAll()
        RageUI.Visible(RMenu:Get("vehicle_menu", "main"), not RageUI.Visible(RMenu:Get("vehicle_menu", "main")))
    else
        VICE.notify("You are not in a vehicle!")
    end
end, false)

RegisterKeyMapping("vehiclemenu", "Open Vehicle Menu", "keyboard", "M")