RegisterServerEvent("VICE:getUserinformation")
AddEventHandler("VICE:getUserinformation",function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.moneymenu') then
        if not VICE.getUserSource(id) then
            VICE.notify(source, '~r~User is not online')
            return
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                VICE.notify(source, '~g~Managing money for ID: '..id..'.')
                TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:getUserinformation")
    end
end)

RegisterServerEvent("VICE:ManagePlayerBank")
AddEventHandler("VICE:ManagePlayerBank",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local userstemp = VICE.getUserSource(id)
    if VICE.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            VICE.giveBankMoney(id, amount)
            VICE.notify(source, "~g~Added £" .. getMoneyStringFormatted(amount) .. " to players Bank Balance.")
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            VICE.tryBankPayment(id, amount)
            VICE.notify(source, "~r~Removed £" .. getMoneyStringFormatted(amount) .. " to players Bank Balance.")
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Bank**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:ManagePlayerBank")
    end
end)

RegisterServerEvent("VICE:ManagePlayerCash")
AddEventHandler("VICE:ManagePlayerCash", function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local userstemp = VICE.getUserSource(id)

    if VICE.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            if type(amount) == "number" and amount > 0 then
                VICE.giveMoney(id, amount)
                VICE.notify(source, "~g~Added £" .. getMoneyStringFormatted(amount) .. " to players Cash Balance.")
                VICE.sendDCLog('manage-balance', "VICE Money Menu Logs", "> Admin Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Admin TempID: **" .. source .. "**\n> Admin PermID: **" .. user_id .. "**\n> Player Name: **" .. VICE.getPlayerName(id) .. "**\n> Player PermID: **" .. id .. "**\n> Player TempID: **" .. userstemp .. "**\n> Amount: **£" .. amount .. " Cash**\n> Type: **" .. cashtype .. "**")
            else
                VICE.notify(source,  '~r~Invalid amount.' )
            end
        elseif cashtype == 'Decrease' then
            if type(amount) == "number" and amount > 0 and VICE.tryPayment(id, amount) then
                VICE.notify(source, "~r~Removed £" .. getMoneyStringFormatted(amount) .. " to players Cash Balance.")
                VICE.sendDCLog('manage-balance', "VICE Money Menu Logs", "> Admin Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Admin TempID: **" .. source .. "**\n> Admin PermID: **" .. user_id .. "**\n> Player Name: **" .. VICE.getPlayerName(id) .. "**\n> Player PermID: **" .. id .. "**\n> Player TempID: **" .. userstemp .. "**\n> Amount: **£" .. amount .. " Cash**\n> Type: **" .. cashtype .. "**")
            else
                VICE.notify(source,  '~r~Invalid amount or insufficient funds.' )
            end
        end

        MySQL.query("casinochips/get_chips", { user_id = id }, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:ManagePlayerCash")
    end
end)

RegisterServerEvent("VICE:ManagePlayerDirtyCash")
AddEventHandler("VICE:ManagePlayerDirtyCash",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local userstemp = VICE.getUserSource(id)
    if VICE.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            VICE.giveDirtyCash(id, amount)
            VICE.notify(source, '~g~Added £'..getMoneyStringFormatted(amount)..' to players Dirty Cash Balance.')
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Dirty Cash**\n> Type: **"..cashtype.."**")
        elseif cashtype == 'Decrease' then
            VICE.tryRedPayment(id, amount)
            VICE.notify(source, '~r~Removed £'..getMoneyStringFormatted(amount)..' from players Dirty Cash Balance.')
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **£"..amount.." Dirty Cash**\n> Type: **"..cashtype.."**")
        end
        MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
            if #rows > 0 then
                local chips = rows[1].chips
                TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:ManagePlayerDirtyCash")
    end
end)


RegisterServerEvent("VICE:ManagePlayerChips")
AddEventHandler("VICE:ManagePlayerChips",function(id, amount, cashtype)
    local amount = tonumber(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local userstemp = VICE.getUserSource(id)
    if VICE.hasPermission(user_id, 'admin.moneymenu') then
        if cashtype == 'Increase' then
            MySQL.execute("casinochips/add_chips", {user_id = id, amount = amount})
            VICE.notify(source, '~g~Added '..getMoneyStringFormatted(amount)..' to players Casino Chips.')
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
                end
            end)
        elseif cashtype == 'Decrease' then
            MySQL.execute("casinochips/remove_chips", {user_id = id, amount = amount})
            VICE.notify(source, '~r~Removed '..getMoneyStringFormatted(amount)..' from players Casino Chips.')
            VICE.sendDCLog('manage-balance',"VICE Money Menu Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..userstemp.."**\n> Amount: **"..amount.." Chips**\n> Type: **"..cashtype.."**")
            MySQL.query("casinochips/get_chips", {user_id = id}, function(rows, affected)
                if #rows > 0 then
                    local chips = rows[1].chips
                    TriggerClientEvent('VICE:receivedUserInformation', source, VICE.getUserSource(id), VICE.getPlayerName(id), math.floor(VICE.getBankMoney(id)), math.floor(VICE.getMoney(id)), chips)
                end
            end)
        end
    else
        VICE.ACBan(15,user_id,"VICE:ManagePlayerChips")
    end
end)