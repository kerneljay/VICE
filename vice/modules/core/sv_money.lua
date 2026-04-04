local lang = VICE.lang

-- Money module, wallet/bank API
-- The money is managed with direct SQL requests to prevent most potential value corruptions
-- the wallet empty itself when respawning (after death)

MySQL.createCommand("VICE/money_init_user","INSERT IGNORE INTO vice_user_moneys(user_id,wallet,bank,dirtycash) VALUES(@user_id,@wallet,@bank,@dirtycash)")
MySQL.createCommand("VICE/get_money","SELECT wallet,bank,dirtycash FROM vice_user_moneys WHERE user_id = @user_id")
MySQL.createCommand("VICE/set_money","UPDATE vice_user_moneys SET wallet = @wallet, bank = @bank, dirtycash = @dirtycash WHERE user_id = @user_id")

-- get money
-- cbreturn nil if error
function VICE.getMoney(user_id)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp then
    return tmp.wallet or 0
  else
    return 0
  end
  task_save_datatables()
end

local lastUpdates = {}
local updateDelay = 1000 -- 1 second delay between updates

-- set money
function VICE.setMoney(user_id,value)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp then
    tmp.wallet = value
  end
  
  -- update client display
  local source = VICE.getUserSource(user_id)
  if source then
    TriggerClientEvent('VICE:setDisplayMoney', source, tmp.wallet)
  end
end


  -- get dirtycash
  function VICE.getDirtyCash(user_id)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp then
      return tmp.dirtycash or 0
    else
      return 0
    end
  end

  local function ProcessDirtyCashItem(user_id, amount)
    local data = VICE.getUserDataTable(user_id)
    if not data then return end
    if amount < 0 then amount = 0 end
    local entry = data.inventory.redmoney
    if amount == 0 then
      data.inventory.redmoney = nil
      return
    end
    data.inventory.redmoney = {amount = amount}
  end

  -- set dirty money
  function VICE.setDirtyCash(user_id,value,dontSet)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp then
      tmp.dirtycash = value
    end
  
    -- update client display
    local source = VICE.getUserSource(user_id)
    if source then
      TriggerClientEvent('VICE:setDisplayRedMoney', source, tmp.dirtycash)
    end
    if dontSet then return end
    ProcessDirtyCashItem(user_id, value)
  end

    -- give dirty money
    function VICE.giveDirtyCash(user_id,amount,dontSet)
      local money = VICE.getDirtyCash(user_id)
      VICE.setDirtyCash(user_id,money+amount,dontSet)
    end

-- try a payment
-- return true or false (debited if true)
function VICE.tryPayment(user_id,amount)
  local money = VICE.getMoney(user_id)
  if amount >= 0 and money >= amount then
    VICE.setMoney(user_id,money-amount)
    return true
  else
    return false
  end
end

function VICE.tryRedPayment(user_id,amount)
  local money = VICE.getDirtyCash(user_id)
  if amount >= 0 and money >= amount then
    VICE.setDirtyCash(user_id,money-amount)
    return true
  else
    return false
  end
end

function VICE.tryBankPayment(user_id,amount)
  local bank = VICE.getBankMoney(user_id)
  if amount >= 0 and bank >= amount then
    VICE.setBankMoney(user_id,bank-amount)
    return true
  else
    return false
  end
end

-- give money
function VICE.giveMoney(user_id, amount)
  if type(user_id) == "number" and type(amount) == "number" and amount > 0 then
      local money = VICE.getMoney(user_id)
      VICE.setMoney(user_id, money + amount)
  end
end

-- get bank money
function VICE.getBankMoney(user_id)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp then
    return tmp.bank or 0
  else
    return 0
  end
end

-- set bank money
function VICE.setBankMoney(user_id,value)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp then
    tmp.bank = value
  end
  
  local source = VICE.getUserSource(user_id)
  if source then
    VICEclient.setDivContent(source,{"bmoney",lang.money.bdisplay({Comma(VICE.getBankMoney(user_id))})})
    TriggerClientEvent('VICE:initMoney', source, VICE.getMoney(user_id), VICE.getBankMoney(user_id))
    TriggerClientEvent('VICE:setAccountMoney',source,VICE.getBankMoney(user_id))
  end
end

-- give bank money
function VICE.giveBankMoney(user_id,amount)
  if amount > 0 then
    local money = VICE.getBankMoney(user_id)
    VICE.setBankMoney(user_id,money+amount)
    task_save_datatables()
  end
end

-- try a withdraw
-- return true or false (withdrawn if true)
function VICE.tryWithdraw(user_id,amount)
  local money = VICE.getBankMoney(user_id)
  if amount > 0 and money >= amount then
    VICE.setBankMoney(user_id,money-amount)
    VICE.giveMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try a deposit
-- return true or false (deposited if true)
function VICE.tryDeposit(user_id,amount)
  if amount > 0 and VICE.tryPayment(user_id,amount) then
    VICE.giveBankMoney(user_id,amount)
    return true
  else
    return false
  end
end

-- try full payment (wallet + bank to complete payment)
-- return true or false (debited if true)
function VICE.tryFullPayment(user_id,amount)
  local money = VICE.getMoney(user_id)
  if money >= amount then -- enough, simple payment
    return VICE.tryPayment(user_id, amount)
  else  -- not enough, withdraw -> payment
    if VICE.tryWithdraw(user_id, amount-money) then -- withdraw to complete amount
      return VICE.tryPayment(user_id, amount)
    end
  end

  return false
end

local startingCash = 0 
local startingBank = 30000000 

-- events, init user account if doesn't exist at connection
AddEventHandler("VICE:playerJoin",function(user_id,source,name,last_login)
  MySQL.query("VICE/money_init_user", {user_id = user_id, wallet = startingCash, bank = startingBank, dirtycash = 0}, function(affected)
    local tmp = VICE.getUserTmpTable(user_id)
    if tmp then
      MySQL.query("VICE/get_money", {user_id = user_id}, function(rows, affected)
        if rows and #rows > 0 then
          tmp.bank = rows[1].bank
          tmp.wallet = rows[1].wallet
          tmp.dirtycash = rows[1].dirtycash
        end
      end)
    end
  end)
end)

-- save money on leave
AddEventHandler("VICE:playerLeave",function(user_id,source)
  lastUpdates[user_id] = nil
  -- (wallet,bank)
  local tmp = VICE.getUserTmpTable(user_id)
  if tmp and tmp.wallet and tmp.bank and tmp.dirtycash then
    MySQL.execute("VICE/set_money", {user_id = user_id, wallet = tmp.wallet, bank = tmp.bank, dirtycash = tmp.dirtycash})
  end
end)

-- save money (at same time that save datatables)
AddEventHandler("VICE:save", function()
  for k,v in pairs(VICE.user_tmp_tables) do
    if v.wallet and v.bank then
      MySQL.execute("VICE/set_money", {user_id = k, wallet = v.wallet, bank = v.bank, dirtycash = v.dirtycash})
    end
  end
end)

RegisterNetEvent('VICE:giveCashToPlayer')
AddEventHandler('VICE:giveCashToPlayer', function(nplayer)
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id then
    if nplayer then
      local nuser_id = VICE.getUserId(nplayer)
      if nuser_id then
        VICE.prompt(source,lang.money.give.prompt(),"",function(source,amount)
          local amount = parseInt(amount)
          if amount > 0 and VICE.tryPayment(user_id,amount) then
            VICE.giveMoney(nuser_id,amount)
            VICE.notify(source, lang.money.given({getMoneyStringFormatted(math.floor(amount))}))
            VICE.notify(nplayer, lang.money.received({getMoneyStringFormatted(math.floor(amount))}))
            VICEclient.playAnim(source, {true, {{"mp_common", "givetake1_a", 1}}, false})
            VICEclient.playAnim(nplayer, {true, {{"mp_common", "givetake2_a", 1}}, false})
            VICE.sendDCLog('give-cash', "VICE Give Cash Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..VICE.getPlayerName(nuser_id).."**\n> Target PermID: **"..nuser_id.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**")
          else
            VICE.notify(source, lang.money.not_enough())
          end
        end)
      else
        VICE.notify(source, lang.common.no_player_near())
      end
    else
      VICE.notify(source, lang.common.no_player_near())
    end
  else
      VICE.ACBan(15,user_id,"VICE:giveCashToPlayer")
  end
end)


function Comma(amount)
  local formatted = amount
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

RegisterServerEvent("VICE:takeAmount")
AddEventHandler("VICE:takeAmount", function(amount, message)
    local source = source
    local user_id = VICE.getUserId(source)
    
    if not message then
        message = "Miscellaneous purchase"
    end
    
    if VICE.tryFullPayment(user_id, amount) then
        VICE.notify(source, "You paid ~g~£" .. getMoneyStringFormatted(amount) .. "~s~ for " .. message)
        return
    end
end)

RegisterServerEvent("VICE:bankTransfer")
AddEventHandler("VICE:bankTransfer", function(targetId, amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local targetId = tonumber(targetId)
    local amount = tonumber(amount)

    if targetId ~= user_id then 
        if VICE.getUserSource(targetId) then
            if VICE.tryBankPayment(user_id, amount) then
                VICE.notify(VICE.getUserSource(targetId), "You have received ~g~£" ..getMoneyStringFormatted(amount).. "~s~ from ~g~" .. VICE.getPlayerName(user_id))
                VICE.notify(source, "Transferred ~g~£" ..getMoneyStringFormatted(amount).. "~s~ to ~g~" .. VICE.getPlayerName(targetId))
                TriggerClientEvent("vice:PlaySound", source, "apple")
                TriggerClientEvent("vice:PlaySound", VICE.getUserSource(targetId), "iphone_dodoDO")
                VICE.giveBankMoney(targetId, amount)
                VICE.sendDCLog('bank-transfer', "VICE Bank Transfer Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Target Name: **"..VICE.getPlayerName(targetId).."**\n> Target PermID: **"..targetId.."**\n> Amount: **£"..amount.."**")
            else
                VICE.notify(source, "~r~You do not have ~g~£" ..getMoneyStringFormatted(amount))
            end
        else
            VICE.notify(source, "~r~Target user not online")
        end
    else
        VICE.notify(source, "~r~Cannot transfer money to yourself")
    end
end)

RegisterServerEvent('VICE:requestPlayerBankBalance')
AddEventHandler('VICE:requestPlayerBankBalance', function()
    local source = source
    local user_id = VICE.getUserId(source)
    local bank = VICE.getBankMoney(user_id)
    local wallet = VICE.getMoney(user_id)
    local dirtycash = VICE.getDirtyCash(user_id)
    local offshore = VICE.getOffshore(user_id)
    
    -- Send initial balance to client
    TriggerClientEvent('VICE:updatePlayerBalance', source, wallet, bank, dirtycash)
    
    -- Also trigger the individual updates for compatibility
    TriggerClientEvent('VICE:setDisplayMoney', source, wallet)
    TriggerClientEvent('VICE:setDisplayBankMoney', source, bank)
    TriggerClientEvent('VICE:setDisplayRedMoney', source, dirtycash)
end)