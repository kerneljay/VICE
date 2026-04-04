RegisterServerEvent("VICE:getCommunityPotAmount")
AddEventHandler("VICE:getCommunityPotAmount", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports['vice']:execute("SELECT value FROM vice_community_pot", function(potbalance)
        TriggerClientEvent('VICE:gotCommunityPotAmount', source, parseInt(potbalance[1].value))
    end)
end)

RegisterServerEvent("VICE:tryDepositCommunityPot")
AddEventHandler("VICE:tryDepositCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['vice']:execute("SELECT value FROM vice_community_pot", function(potbalance)
            if VICE.tryFullPayment(user_id,amount) then
                local newpotbalance = parseInt(potbalance[1].value) + amount
                exports['vice']:execute("UPDATE vice_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                TriggerClientEvent('VICE:gotCommunityPotAmount', source, newpotbalance)
                VICE.sendDCLog('com-pot', 'VICE Community Pot Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Deposit**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
            end
        end)
    end
end)

RegisterServerEvent("VICE:tryWithdrawCommunityPot")
AddEventHandler("VICE:tryWithdrawCommunityPot", function(amount)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['vice']:execute("SELECT value FROM vice_community_pot", function(potbalance)
            if parseInt(potbalance[1].value) >= amount then
                local newpotbalance = parseInt(potbalance[1].value) - amount
                exports['vice']:execute("UPDATE vice_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
                TriggerClientEvent('VICE:gotCommunityPotAmount', source, newpotbalance)
                VICE.giveMoney(user_id, amount)
                VICE.sendDCLog('com-pot', 'VICE Community Pot Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Withdraw**\n> Amount: £**"..getMoneyStringFormatted(amount).."**")
            end
        end)
    end
end)

RegisterServerEvent("VICE:distributeCommunityPot")
AddEventHandler("VICE:distributeCommunityPot", function(amountToDistribute)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.managecommunitypot') then
        exports['vice']:execute("SELECT value FROM vice_community_pot", function(potbalance)
            local totalAmount = tonumber(potbalance[1].value)
            amountToDistribute = tonumber(amountToDistribute)
            if totalAmount and amountToDistribute and totalAmount >= amountToDistribute then
                local players = GetPlayers()
                local amountPerPlayer = amountToDistribute / #players
                for i, player in ipairs(players) do
                    VICE.giveBankMoney(VICE.getUserId(player), amountPerPlayer)
                end
                local remainingAmount = totalAmount - amountToDistribute
                VICE.notify(-1, "~g~Received £"..getMoneyStringFormatted(amountPerPlayer).." distributed from the community pot.")
                VICE.notify(source, "~g~Distributed £"..getMoneyStringFormatted(amountPerPlayer).." to all online players.")
                exports['vice']:execute("UPDATE vice_community_pot SET value = @value", {['@value'] = remainingAmount})
                TriggerClientEvent('VICE:gotCommunityPotAmount', source, remainingAmount)
                VICE.sendDCLog('com-pot', 'VICE Community Pot Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Type: **Distribute**\n> Amount: £**"..getMoneyStringFormatted(amountToDistribute).."**")
            else
                VICE.notify(source, "~r~Not enough money in the community pot.")
            end
        end)
    end
end)

RegisterServerEvent("VICE:addToCommunityPot")
AddEventHandler("VICE:addToCommunityPot", function(amount)
    if source ~= '' then return end
    exports['vice']:execute("SELECT value FROM vice_community_pot", function(potbalance)
        local newpotbalance = parseInt(potbalance[1].value) + amount
        exports['vice']:execute("UPDATE vice_community_pot SET value = @newpotbalance", {newpotbalance = newpotbalance})
    end)
end)