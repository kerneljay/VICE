local positions = {
    {   
        xyz = vector3(1732.7370605469,3328.900390625,41.22350692749),
        x = 1732.7370605469,
        y = 3328.900390625,
        z = 41.22350692749,
        w = 193.59,
    }, 
    {   
        xyz = vector3(281.64596557617,6787.8999023438,15.695206642151),
        x = 281.64596557617,
        y = 6787.8999023438,
        z = 15.695206642151,
        w = 193.59,
    },
    {   
        xyz = vector3(425.65841674805,6462.2622070312,28.777309417725),
        x = 425.65841674805,
        y = 6462.2622070312,
        z = 28.777309417725,
        w = 193.59,
    },
    {   
        xyz = vector3(2565.6779785156,4657.9780273438,34.076782226562),
        x = 2565.6779785156,
        y = 4657.9780273438,
        z = 34.076782226562,
        w = 193.59,
    },
    {   
        xyz = vector3(312.78762817383,-2894.7719726562,5.9999871253967),
        x = 312.78762817383,
        y = -2894.7719726562,
        z = 5.9999871253967,
        w = 193.59,
    },
    {   
        xyz = vector3(576.38952636719,-2725.3366699219,6.0560121536255),
        x = 576.38952636719,
        y = -2725.3366699219,
        z = 6.0560121536255,
        w = 193.59,
    },
    {   
        xyz = vector3(-198.15956115723,-7.0564312934875,52.374649047852),
        x = -198.15956115723,
        y = -7.0564312934875,
        z = 52.374649047852,
        w = 193.59,
    },
    {   
        xyz = vector3(187.74783325195,6377.8081054688,32.340599060059),
        x = 187.74783325195,
        y = 6377.8081054688,
        z = 32.340599060059,
        w = 193.59,
    },
    {   
        xyz = vector3(480.00091552734,-2995.2915039062,6.0444560050964),
        x = 480.00091552734,
        y = -2995.2915039062,
        z = 6.0444560050964,
        w = 193.59,
    },
}

local DirtyCashData = {
    --[user_id] = {dealerloc = vector3(x,y,z), amount = 0, time = 0}
}

AddEventHandler("VICE:CreateDirtyCashDealer",function(user_id)
    local source = VICE.getUserSource(user_id)
    if source then
        local randomPosition = positions[math.random(1,#positions)]
        DirtyCashData[user_id] = {dealerloc = randomPosition, amount = 0, time = 0}
        TriggerClientEvent("VICE:addDirtyCashDealer", -1, source, randomPosition, "a_m_m_business_01")
        TriggerClientEvent("VICE:routeDirtyCashDealer", source,randomPosition.xyz)
    end
end)

RegisterServerEvent("VICE:startHandingDirtyCash",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if GetPlayerRoutingBucket(source) == 0 then
        if VICE.getDirtyCash(user_id) > 0 then
            local time = VICE.getDirtyCash(user_id) / 1000000 * 7500
            DirtyCashData[user_id].time = os.time() + time/1000 -- 1000 because os.time is in seconds and time is in milliseconds
            DirtyCashData[user_id].amount = VICE.getDirtyCash(user_id)
            TriggerClientEvent("VICE:startHandingDirtyCash", source, time)
            TriggerClientEvent("VICE:startHandingDirtyCashAnim", source, DirtyCashData[user_id].dealerloc)
            while DirtyCashData[user_id] and os.time() < DirtyCashData[user_id].time do
                Wait(1000)
            end
            if DirtyCashData[user_id] then
                if VICE.getDirtyCash(user_id) == DirtyCashData[user_id].amount then
                    VICE.giveMoney(user_id, DirtyCashData[user_id].amount)
                    VICE.setDirtyCash(user_id, 0)
                    VICE.notify(source, "~g~Received £"..DirtyCashData[user_id].amount.." through legitimate businesses.")
                else
                    VICE.notify(source, "~r~You have tweaked with the dirty cash. Call me back when you are serious.")
                end
                TriggerClientEvent("VICE:stopHandingDirtyCash", source)
                TriggerClientEvent("VICE:stopHandingDirtyCashAnim", source, DirtyCashData[user_id].dealerloc)
            end
        else
            VICE.notify(source, "~r~You don't have any dirty cash. Call me back when you are serious.")
        end
        TriggerClientEvent("VICE:removeDirtyCashDealer", -1, source)
        DirtyCashData[user_id] = nil
    else
        VICE.notify(source, "~r~You are in the incorrect universe to do this!")
    end
end)

RegisterServerEvent("VICE:stopHandingDirtyCash",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if DirtyCashData[user_id] then
        TriggerClientEvent("VICE:stopHandingDirtyCash", source)
        TriggerClientEvent("VICE:removeDirtyCashDealer", -1, source)
        TriggerClientEvent("VICE:stopHandingDirtyCashAnim", source, DirtyCashData[user_id].dealerloc)
        DirtyCashData[user_id] = nil
    end
end)