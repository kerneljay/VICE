local lang = VICE.lang
local cfg = module("cfg/atms")
RegisterServerEvent("VICE:depositAtm",function(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if user_id then
            if VICE.tryDeposit(user_id, amount) then
                VICE.notify(source, lang.atm.deposit.deposited({getMoneyStringFormatted(amount)}))
            else
                VICE.notify(source, lang.money.not_enough())
            end
        end
    else
        VICE.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("VICE:withdrawAtm",function(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if user_id then
            if VICE.tryWithdraw(user_id, amount) then
                VICE.notify(source, lang.atm.withdraw.withdrawn({getMoneyStringFormatted(amount)}))
            else
                VICE.notify(source, lang.atm.withdraw.not_enough())
            end
        end
    else
        VICE.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("VICE:depositAll",function()
    local source = source
    local user_id = VICE.getUserId(source)
    local amount = VICE.getMoney(user_id)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if VICE.tryDeposit(user_id, amount) then
            VICE.notify(source, lang.atm.deposit.deposited({getMoneyStringFormatted(amount)}))
        else
            VICE.notify(source, lang.money.not_enough())
        end
    else
        VICE.notify(source, lang.common.invalid_value())
    end
end)

RegisterServerEvent("VICE:withdrawAll",function()
    local source = source
    local user_id = VICE.getUserId(source)
    local amount = VICE.getBankMoney(user_id)
    amount = tonumber(amount)
    if amount and amount > 0 then
        if VICE.tryWithdraw(user_id, amount) then
            VICE.notify(source, lang.atm.withdraw.withdrawn({getMoneyStringFormatted(amount)}))
        else
            VICE.notify(source, lang.atm.withdraw.not_enough())
        end
    else
        VICE.notify(source, lang.common.invalid_value())
    end
end)

local robbedableatms = {}

for atmid,coords in pairs(cfg.robberyAtms) do
    robbedableatms[atmid] = {robbed = false, robberid = nil, lastrobbed = 0}
end

RegisterServerEvent("VICE:atmWireCutSparks",function(atmid)
    local source = source
    local user_id = VICE.getUserId(source)
    if robbedableatms[atmid].robbed then
        if user_id == robbedableatms[atmid].robberid then
            TriggerClientEvent("VICE:atmWireCutSparks",-1,atmid)
        else
            VICE.notify(source, "~r~You wasn't robbing this atm!")
        end
    end
end)

RegisterServerEvent("VICE:returnAtmWireCutting",function(storeid,success)
    local source = source
    local user_id = VICE.getUserId(source)
    if robbedableatms[storeid].robbed then
        if user_id == robbedableatms[storeid].robberid then
            if success then
                local chance = math.random(1,4)
                VICE.notify(source, "~g~You have successfully cut the wires!")
                if chance ~= 2 then
                    local amount = math.random(650000, 1000000)*grindBoost
                    TriggerClientEvent("VICE:atmRobberyFakeMoney",source,VICE.getDirtyCash(user_id),amount)
                    TriggerClientEvent("VICE:atmWireCuttingSuccessSync",-1,storeid)
                    TriggerClientEvent("VICE:atmWireCuttingSuccess",source)
                    Wait(10000)
                    VICE.giveDirtyCash(user_id, amount)
                else
                    VICE.notify(source, "~r~Failed to pick up money. A fail safe has covered it in ink.")
                    TriggerClientEvent("VICE:atmInkArea",source,storeid)
                    TriggerClientEvent("VICE:atmGenericAlarm",source,storeid)
                end
            else
                VICE.notify(source, "~r~You have failed to cut the wires.")
                TriggerClientEvent("VICE:atmInkArea",source,storeid)
                TriggerClientEvent("VICE:atmGenericAlarm",source,storeid)
            end
        else
            VICE.notify(source, "~r~You wasn't robbing this atm!")
        end
    end
end)

RegisterServerEvent("VICE:startAtmWireCutting",function(storeid)
    local source = source
    local user_id = VICE.getUserId(source)
    if not robbedableatms[storeid].robbed then
        robbedableatms[storeid].robbed = true
        robbedableatms[storeid].robberid = user_id
        robbedableatms[storeid].lastrobbed = GetGameTimer()+15*60*1000
        TriggerClientEvent("VICE:startAtmWireCutting",source,storeid)
    end
end)

RegisterServerEvent("VICE:atmStopWireCutting",function(storeid)
    local source = source
    local user_id = VICE.getUserId(source)
    if robbedableatms[storeid].robbed then
        if user_id == robbedableatms[storeid].robberid then
            robbedableatms[storeid].robbed = false
            robbedableatms[storeid].robberid = nil
            robbedableatms[storeid].lastrobbed = 0
            TriggerClientEvent("VICE:atmStopWireCutting",-1,storeid)
        end
    end
end)

RegisterServerEvent("VICE:getAtmHasBeenRobbed",function(storeid)
    local source = source
    TriggerClientEvent("VICE:setAtmHasBeenRobbed",source,robbedableatms[storeid].lastrobbed)
end)

RegisterServerEvent("VICE:requestMoneyUpdate")
AddEventHandler("VICE:requestMoneyUpdate", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        local wallet = VICE.getMoney(user_id)
        local bank = VICE.getBankMoney(user_id)
        local dirty = VICE.getDirtyCash(user_id)
        TriggerClientEvent("VICE:updateMoneyDisplay", source, wallet, bank, dirty)
    end
end)