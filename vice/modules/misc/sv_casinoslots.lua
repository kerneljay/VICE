local cfg = module("cfg/cfg_casinoslots")
local takenSlots = {}

local function AlreadyOnSlot(user_id)
    for k,v in pairs(takenSlots) do
        if v == user_id then
            return true
        end
    end
    return false
end

local function table_matches(table1, table2)
    local type1, type2 = type(table1), type(table2)
    if type1 ~= type2 then 
        return false 
    end
    if type1 ~= 'table' and type2 ~= 'table' then 
        return table1 == table2 
    end
    for key1,value1 in pairs(table1) do
        local value2 = table2[key1]
        if value2 == nil or not table_matches(value1,value2) then 
            return false 
        end
    end
    for key2,value2 in pairs(table2) do
        local value1 = table1[key2]
        if value1 == nil or not table_matches(value1,value2) then 
            return false 
        end
    end
    return true
end

RegisterServerEvent("VICE:requestSlotData",function(SlotID)
    local source = source
    local user_id = VICE.getUserId(source)
    if not takenSlots[SlotID] then
        if not AlreadyOnSlot(user_id) then
            takenSlots[SlotID] = user_id
            TriggerClientEvent("VICE:enterSlotMachine",source,SlotID)
        end
    else
        VICE.notify(source, {"~r~This slot machine is currently in use."})
    end
end)

RegisterServerEvent("VICE:ExitSlotMachine",function(SlotID)
    local source = source
    local user_id = VICE.getUserId(source)
    if takenSlots[SlotID] == user_id then
        takenSlots[SlotID] = nil
    end
end)





RegisterServerEvent("VICE:spinSlotMachine",function(SlotID,Amount)
    local source = source
    local user_id = VICE.getUserId(source)
    if closeToRestart then VICE.notify(source,{"~r~You cannot do this just before a server restart."}) return end
    if AlreadyOnSlot(user_id) then
        MySQL.query("casinochips/get_chips",{user_id = user_id}, function(rows,affected)
            chips = rows[1].chips
            if chips >= Amount then
                MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = Amount})
                TriggerClientEvent('VICE:chipsUpdated', source)
                VICE.notify(source, {"~y~Paid "..getMoneyStringFormatted(Amount).." chips."})
                
                local SlotMachineRewards = {math.random(0, 15), math.random(0, 15), math.random(0, 15)}
                local rewardMultiplier = 0
                for i = 1, #SlotMachineRewards do
                        -- 10-40
                    if cfg.slot_location[SlotID]["Info"].misschance > math.random(1, 70) then
                        SlotMachineRewards[i] = SlotMachineRewards[i] + math.random(4, 6) / 10
                    end
                end
                for k,v in pairs(cfg.slot_rewards) do
                    if table_matches(k, SlotMachineRewards) then
                        rewardMultiplier = v
                        break
                    end
                end
                if rewardMultiplier == 0 then
                    for i = 1, #SlotMachineRewards do
                        if SlotMachineRewards[i] == 4 or SlotMachineRewards[i] == 11 or SlotMachineRewards[i] == 15 then
                            rewardMultiplier = rewardMultiplier + 1
                        end
                    end
                    rewardMultiplier = cfg.slots_special_reward[rewardMultiplier] or 0
                end
                TriggerClientEvent("VICE:spinSlotMachine",source,SlotMachineRewards,rewardMultiplier)
                SetTimeout(5000,function()
                    local rewardAmount = Amount * rewardMultiplier
                    if rewardMultiplier == 0 then
                        VICE.notify(source, {"~r~You lost "..getMoneyStringFormatted(Amount).." chips."}) 
                        -- VICE.sendWebhook('slot-outcomes',"VICE Slots Logs", "> Player Name: **"..VICE.getPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Bet Amount: **"..getMoneyStringFormatted(Amount).."**\n> Outcome: **Loss**")
                    else
                        if rewardAmount >= 20000000 then
                            TriggerClientEvent('chatMessage', -1, "^7Diamond Casino |", { 128, 128, 128 }, ""..VICE.getPlayerName(source).." has WON "..getMoneyStringFormatted(rewardAmount).." chips with a "..rewardMultiplier.."x multiplier!", "green")
                        end
                        -- VICE.sendWebhook('slot-outcomes',"VICE Slots Logs", "> Player Name: **"..VICE.getPlayerName(source).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Bet Amount: **"..getMoneyStringFormatted(Amount).."**\n> Outcome: **Win**\n> Win Amount: **"..getMoneyStringFormatted(rewardAmount).."**\n> Win Multiplier: **"..rewardMultiplier.."x**")
                        VICE.notify(source, {"~g~You won "..getMoneyStringFormatted(rewardAmount).." chips."})
                        giveChips(source,rewardAmount)
                    end
                end)
            else
                VICE.notify(source, {"~r~You do not have "..getMoneyStringFormatted(Amount).." in chips for this bet."})
                return
            end
        end)
    else
        VICE.notify(source, {"~r~It doesnt seem like you are playing a slot machine, resit down."})
        return
    end
end)

AddEventHandler("VICE:playerLeave",function(user_id,source)
    for k,v in pairs(takenSlots) do
        if v == user_id then
            takenSlots[k] = nil
        end
    end
end)
