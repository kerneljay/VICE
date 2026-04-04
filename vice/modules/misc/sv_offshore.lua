-- [[ Offshore Banking ]] -- 

local lang = VICE.lang


MySQL.createCommand("VICE/offshore_init_user","INSERT IGNORE INTO vice_user_offshore(user_id,money) VALUES(@user_id,@money)")
MySQL.createCommand("VICE/get_offshore_money","SELECT money FROM vice_user_offshore WHERE user_id = @user_id")
MySQL.createCommand("VICE/set_offshore_money","UPDATE vice_user_offshore SET money = @money WHERE user_id = @user_id")

-- events, init user account if doesn't exist at connection
AddEventHandler("VICE:playerJoin",function(user_id,source,name,last_login)
  MySQL.query("VICE/offshore_init_user", {user_id = user_id,money=0}, function(affected)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("VICE/get_offshore_money", {user_id = user_id}, function(rows, affected)
        if rows and #rows > 0 then
          tmp.offshore = rows[1].money or 0
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("VICE:playerLeave",function(user_id,source)
-- (money)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp and tmp.offshore then
        MySQL.execute("VICE/set_offshore_money", {user_id = user_id, money = tmp.offshore})
    end
end)
  
-- save money (at same time that save datatables)
AddEventHandler("VICE:save", function()
    for k,v in pairs(VICE.user_tmp_tables) do
        if v.offshore then
            MySQL.execute("VICE/set_offshore_money", {user_id = k, money = v.offshore})
        end
    end
end)

RegisterServerEvent("VICE:depositOffshoreMoney")
AddEventHandler("VICE:depositOffshoreMoney", function(amount)
  local source = source
  local user_id = VICE.getUserId(source)
  if amount > 0 then
      local fee = math.floor(amount * 0.01) -- 1% fee
      local amountAfterFee = math.floor(amount - fee)
      if VICE.tryBankPayment(user_id, amount) then
          VICE.giveOffshoreMoney(user_id, amountAfterFee)
          VICE.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(amountAfterFee) .. " 1% deposit fee paid.")
          VICE.sendDCLog('deposit-offshore', "VICE Deposit Offshore Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Amount: **£"..amountAfterFee.."**\n> Fee: **£"..fee.."**")
      end
  end
end)

RegisterServerEvent("VICE:depositAllOffshoreMoney")
AddEventHandler("VICE:depositAllOffshoreMoney", function()
  local source = source
  local user_id = VICE.getUserId(source)
  local amount = VICE.getBankMoney(user_id)
  if amount > 0 then
      local fee = math.floor(amount * 0.01) -- 1% fee
      local amountAfterFee = math.floor(amount - fee)
      if VICE.tryBankPayment(user_id, amount) then
          VICE.giveOffshoreMoney(user_id, amountAfterFee)
          VICE.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(amountAfterFee) .. " 1% deposit fee paid.")
          VICE.sendDCLog('deposit-offshore', "VICE Deposit Offshore Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Amount: **£"..amountAfterFee.."**\n> Fee: **£"..fee.."**")
      end
  end
end)

RegisterServerEvent("VICE:withdrawAllOffshoreMoney")
AddEventHandler("VICE:withdrawAllOffshoreMoney", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local amount = VICE.getOffshore(user_id)
    if amount > 0 and VICE.tryOffshorePayment(user_id, amount) then
        VICE.giveBankMoney(user_id, amount)
        VICE.notify(source, "~g~Withdrawn £" .. getMoneyStringFormatted(math.floor(amount)))
    end
end)

RegisterServerEvent("VICE:withdrawOffshoreMoney")
AddEventHandler("VICE:withdrawOffshoreMoney", function(amount)
  local source = source
  local user_id = VICE.getUserId(source)
  local money = VICE.getOffshore(user_id)
  if amount > 0 and money >= amount and VICE.tryOffshorePayment(user_id, amount) then
     VICE.giveBankMoney(user_id, amount)
     VICE.notify(source, "~g~Withdrawn £" .. getMoneyStringFormatted(math.floor(amount)))
  end
end)

function VICE.giveOffshoreMoney(user_id,amount)
  if amount > 0 then
    local money = VICE.getOffshore(user_id)
    VICE.setOffshore(user_id,money+amount)
  end
end

function VICE.setOffshore(user_id,value)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp then
      tmp.offshore = value
      -- update client display
      local source = VICE.getUserSource(user_id)
      if source then
        TriggerClientEvent('VICE:setDisplayOffshore', source, tmp.offshore)
      end
    end
  end

Citizen.CreateThread(function()
  while true do
    Wait(5000)
    for k,v in pairs(VICE.user_tmp_tables) do
      if v.offshore then
        MySQL.execute("VICE/set_offshore_money", {user_id = k, money = v.offshore})
      end
    end
  end
end)

function VICE.tryOffshorePayment(user_id,amount)
  local money = VICE.getOffshore(user_id)
  if amount >= 0 and money >= amount then
    VICE.setOffshore(user_id,money-amount)
    return true
  else
    return false
  end
end

function VICE.getOffshore(user_id)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp then
    return tmp.offshore or 0
  else
    return 0
  end
end

--