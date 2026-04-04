carryingBackInProgress = false
local a = ""
local b = ""
local c = 0
local d = vector3(1117.671, 218.7382, -49.4)
local e = false
distanceToCasino = 1000
TriggerEvent("chat:addSuggestion", "/carry", "Carry the nearest player")
RegisterCommand(
    "carry",
    function(f, g)
        if IsPedInAnyVehicle(PlayerPedId(), true) then
            drawNativeNotification("You cannot carry someone whilst you are in a vehicle!")
        else
            if not globalPlayerInPrisonZone and not inOrganHeist or tVICE.isStaffedOn() then
                if GetEntityHealth(VICE.getPlayerPed()) > 102 then
                    local h = GetEntityCoords(VICE.getPlayerPed())
                    distanceToCasino = #(h - d)
                    if not carryingBackInProgress and (distanceToCasino > 200 or tVICE.isStaffedOn()) then
                        local i = VICE.getPlayerPed()
                        local j = GetClosestPlayer(3)
                        if j ~= -1 then
                            target = GetPlayerServerId(j)
                            if GetEntityHealth(GetPlayerPed(j)) ~= 0 then
                                if not tVICE.isStaffedOn() and not globalLFBOnDuty then
                                    TriggerServerEvent("CarryPeople:requestCarry", target)
                                else
                                    TriggerServerEvent(
                                        "CarryPeople:sync",
                                        GetPlayerServerId(VICE.getPlayerId()),
                                        target
                                    )
                                end
                            else
                                drawNativeNotification("Cannot carry dead people!")
                            end
                        else
                            drawNativeNotification("No one nearby to carry!")
                        end
                    else
                        local k = VICE.getPlayerPed()
                        carryingBackInProgress = false
                        ClearPedSecondaryTask(k)
                        DetachEntity(k, true, false)
                        local j = GetClosestPlayer(3)
                        target = GetPlayerServerId(j)
                        if target ~= 0 then
                            TriggerServerEvent("CarryPeople:stop", target)
                        end
                    end
                end
            else
                VICE.notify("~r~You cannot carry in the prison or the organ heist.")
            end
        end
    end,
    false
)
RegisterNetEvent(
    "CarryPeople:carryRequest",
    function()
        VICE.notify("Someone is trying to carry you, press (~y~Y~w~) to accept (~r~L~w~) to refuse")
        e = true
        Citizen.CreateThread(
            function()
                while e do
                    if IsControlJustPressed(0, 246) then
                        local playerPed = VICE.getPlayerPed()
                        local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
                        local playerCoords = GetEntityCoords(playerPed)
                        local targetCoords = GetEntityCoords(targetPed)
                        local distance = #(playerCoords - targetCoords)

                        if distance <= 3.0 then
                            VICE.notify("~g~Request Accepted")
                            ExecuteCommand("carryaccept")
                            e = false
                        else
                            VICE.notify("~r~Player is too far away to be carried")
                            e = false
                        end
                    elseif IsControlJustPressed(0, 182) then
                        VICE.notify("~r~Request Refused")
                        ExecuteCommand("carryrefuse")
                        e = false
                    end
                    Wait(0)
                end
            end
        )
        Citizen.Wait(15000)
        e = false
    end
)
Citizen.CreateThread(
    function()
        while true do
            Wait(5)
            if carryingBackInProgress then
                local l = VICE.getPlayerPed()
                local m, n = VICE.getPlayerVehicle()
                if m ~= 0 and n then
                    TriggerServerEvent("CarryPeople:stop", target)
                    carryingBackInProgress = false
                    ClearPedTasks(l)
                    StopAnimTask(l, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 0)
                    drawNativeNotification("You cannot carry someone whilst you are in a vehicle!")
                end
                if not tVICE.isStaffedOn() and IsPedFalling(l) then
                    TriggerServerEvent("CarryPeople:stop", target)
                    carryingBackInProgress = false
                    ClearPedTasks(l)
                    StopAnimTask(l, "missfinale_c2mcs_1", "fin_c2_mcs_1_camman", 0)
                    drawNativeNotification("You cannot carry someone whilst you are falling")
                end
            end
        end
    end
)
RegisterNetEvent(
    "CarryPeople:syncTarget",
    function(target, o, p, q, r, s, t, u, v)
        local l = VICE.getPlayerPed()
        local w = GetPlayerPed(GetPlayerFromServerId(target))
        carryingBackInProgress = true
        RequestAnimDict(o)
        while not HasAnimDictLoaded(o) do
            Citizen.Wait(10)
        end
        if u == nil then
            u = 180.0
        end
        AttachEntityToEntity(VICE.getPlayerPed(), w, 0, r, q, s, 0.5, 0.5, u, false, false, false, false, 2, false)
        if v == nil then
            v = 0
        end
        TaskPlayAnim(l, o, p, 8.0, -8.0, t, v, 0, false, false, false)
        RemoveAnimDict(o)
        a = p
        b = o
        c = v
    end
)
RegisterNetEvent(
    "CarryPeople:syncMe",
    function(o, x, t, v)
        local l = VICE.getPlayerPed()
        carryingBackInProgress = true
        RequestAnimDict(o)
        while not HasAnimDictLoaded(o) do
            Citizen.Wait(10)
        end
        Wait(500)
        if v == nil then
            v = 0
        end
        TaskPlayAnim(l, o, x, 8.0, -8.0, t, v, 0, false, false, false)
        RemoveAnimDict(o)
        a = x
        b = o
        c = v
    end
)
RegisterNetEvent(
    "CarryPeople:cl_stop",
    function()
        carryingBackInProgress = false
        ClearPedSecondaryTask(VICE.getPlayerPed())
        DetachEntity(VICE.getPlayerPed(), true, false)
    end
)
function func_carryAnimation()
    if carryingBackInProgress then
        DisablePlayerFiring(VICE.getPlayerId(), true)
        if not IsEntityPlayingAnim(VICE.getPlayerPed(), b, a, 3) then
            TaskPlayAnim(VICE.getPlayerPed(), b, a, 8.0, -8.0, 100000, c, 0, false, false, false)
        end
    end
end
VICE.createThreadOnTick(func_carryAnimation)
