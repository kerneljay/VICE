local usedwheel = {}
local alreadyspinning = false
RegisterNetEvent("VICE:requestSpinLuckyWheel")
AddEventHandler("VICE:requestSpinLuckyWheel", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local chips = nil
    if not usedwheel[user_id] then
        if not alreadyspinning then
            MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
                if #rows > 0 then
                    chips = rows[1].chips
                    if chips < 50000 then
                        VICE.notify(source, "~r~You don't have enough chips.")
                    else
                        local chance = math.random(1,20)
                        usedwheel[user_id] = true
                        alreadyspinning = true
                        MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = 50000})
                        TriggerClientEvent('VICE:chipsUpdated', source)
                        TriggerClientEvent('VICE:spinLuckyWheel', source)
                        TriggerClientEvent('VICE:syncLuckyWheel', -1, chance)
                        Wait(12500)
                        TriggerEvent("VICE:Reward",user_id,chance)
                    end
                end
            end)
        else
            VICE.notify(source, "~r~Someone is already spinning the wheel.")
        end
    else
        VICE.notify(source, "~r~You have already used the wheel this restart.")
    end
end)

AddEventHandler("VICE:Reward",function(user_id,number)
    if number == 1 or number == 9 or number == 13 or number == 17 then
        VICE.giveInventoryItem(user_id, "wbody|WEAPON_NBK", 1)
        VICE.giveInventoryItem(user_id, "9mm Bullets", 250)
        message = "a Rebel Revolver"
    -- elseif number == 2 or number == 6 or number == 10 or number == 14 or number == 18 then
    --     -- add fucking handcuffs :|
    --     message = "handcuffs"
    elseif number == 3 or number == 7 or number == 15 or number == 20 then
        VICE.giveBankMoney(user_id,100000)
        message = "£100,000"
    elseif number == 4 or number == 8 or number == 11 or number == 16 then
        giveChips(VICE.getUserSource(user_id), 100000)
        message = "100,000 Chips"
    elseif number == 5 then
        VICE.giveInventoryItem(user_id, "rock", 1)
        message = "A Rock"
    elseif number == 12 then
        VICE.giveInventoryItem(user_id,"handcuffkeys",1)
        message = "handcuff keys"
    elseif number == 19 then
        AddVehicle(user_id,"m4lb")
        message = "the casino car"
    end
    VICE.notify(VICE.getUserSource(user_id), "~g~You have won " ..message.. "!")
    TriggerClientEvent("VICE:spinLuckyWheelReaction", VICE.getUserSource(user_id), "_big")
    alreadyspinning = false
end)