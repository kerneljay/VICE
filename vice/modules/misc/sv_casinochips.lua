MySQL.createCommand("casinochips/add_id", "INSERT IGNORE INTO vice_casino_chips SET user_id = @user_id")
MySQL.createCommand("casinochips/get_chips","SELECT * FROM vice_casino_chips WHERE user_id = @user_id")
MySQL.createCommand("casinochips/add_chips", "UPDATE vice_casino_chips SET chips = (chips + @amount) WHERE user_id = @user_id")
MySQL.createCommand("casinochips/remove_chips", "UPDATE vice_casino_chips SET chips = CASE WHEN ((chips - @amount)>0) THEN (chips - @amount) ELSE 0 END WHERE user_id = @user_id")


AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_casino_chips SET user_id = @user_id", {user_id = user_id})
end)

RegisterNetEvent("VICE:enterDiamondCasino")
AddEventHandler("VICE:enterDiamondCasino", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.setBucket(source, 777)
    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            TriggerClientEvent('VICE:setDisplayChips', source, rows[1].chips)
            return
        end
    end)
end)

RegisterNetEvent("VICE:exitDiamondCasino")
AddEventHandler("VICE:exitDiamondCasino", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.setBucket(source, 0)
end)

RegisterNetEvent("VICE:getChips")
AddEventHandler("VICE:getChips", function()
    local source = source
    local user_id = VICE.getUserId(source)
    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            TriggerClientEvent('VICE:setDisplayChips', source, rows[1].chips)
            return
        end
    end)
end)

RegisterNetEvent("VICE:buyChips")
AddEventHandler("VICE:buyChips", function(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    if not amount then amount = VICE.getMoney(user_id) end
    if VICE.tryPayment(user_id, amount) then
        MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = amount})
        TriggerClientEvent('VICE:chipsUpdated', source)
        VICE.notifyPicture(source, "walletnotification", "notification", "Charged ~r~£" .. getMoneyStringFormatted(amount) .. " ~s~from your account.", "Wallet", "Casino purchase")
        VICE.sendDCLog('purchase-chips',"VICE Chip Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(amount).."**")
        return
    else
        VICE.notify(source, "You don't have enough money.")
        return
    end
end)

local sellingChips = {}
RegisterNetEvent("VICE:sellChips")
AddEventHandler("VICE:sellChips", function(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local chips = nil
    if not sellingChips[source] then
        sellingChips[source] = true
        MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                if not amount then amount = chips end
                if amount > 0 and chips > 0 and chips >= amount then
                    MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = amount})
                    TriggerClientEvent('VICE:chipsUpdated', source)
                    VICE.sendDCLog('sell-chips',"VICE Chip Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(amount).."**")
                    VICE.giveMoney(user_id, amount)
                else
                    VICE.notify(source, "You don't have enough chips.")
                end
                sellingChips[source] = nil
            end
        end)
    end
end)