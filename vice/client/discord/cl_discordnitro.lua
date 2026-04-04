local a = GetGameTimer()
RegisterNetEvent("VICE:spawnNitroBMX",function()
    if not tVICE.isInComa() and not tVICE.isHandcuffed() and not insideDiamondCasino then --and not isPlayerNearPrison() then
        if GetTimeDifference(GetGameTimer(), a) > 10000 then
            a = GetGameTimer()
            VICE.notify("~g~Crafting a BMX")
            local b = VICE.getPlayerPed()
            TaskStartScenarioInPlace(b, "WORLD_HUMAN_HAMMERING", 0, true)
            Wait(5000)
            ClearPedTasksImmediately(b)
            local c = GetEntityCoords(b)
            VICE.spawnVehicle("bmx", c.x, c.y, c.z, GetEntityHeading(b), true, true, true)
        else
            VICE.notify("~r~Nitro BMX cooldown, please wait.")
        end
    else
        VICE.notify("~r~Cannot craft a BMX right now.")
    end
end)
RegisterNetEvent("VICE:spawnMoped",function()
    if not tVICE.isInComa() and not tVICE.isHandcuffed() and not insideDiamondCasino then --and not isPlayerNearPrison() then
        if GetTimeDifference(GetGameTimer(), a) > 10000 then
            a = GetGameTimer()
            VICE.notify("~g~Crafting a Moped")
            local b = VICE.getPlayerPed()
            TaskStartScenarioInPlace(b, "WORLD_HUMAN_HAMMERING", 0, true)
            Wait(5000)
            ClearPedTasksImmediately(b)
            local c = GetEntityCoords(b)
            VICE.spawnVehicle("faggio", c.x, c.y, c.z, GetEntityHeading(b), true, true, true)
        else
            VICE.notify("~r~Nitro BMX cooldown, please wait.")
        end
    else
        VICE.notify("~r~Cannot craft a Moped right now.")
    end
end)
