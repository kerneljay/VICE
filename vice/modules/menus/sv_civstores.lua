local cfg = module("cfg/cfg_civstores")

RegisterNetEvent("VICE:BuyCivStoreItem")
AddEventHandler("VICE:BuyCivStoreItem", function(item, amount)
    local source = source
    local user_id = VICE.getUserId(source)
    local ped = GetPlayerPed(source)
    for k,v in pairs(cfg.shopRadioItems) do
        if item == v.itemID then
            if VICE.getInventoryWeight(user_id) <= 25 then
                local totalPrice = v.price * amount
                local cash = VICE.getMoney(user_id)
                if cash >= totalPrice then
                    if VICE.tryPayment(user_id, totalPrice) then
                        VICE.giveInventoryItem(user_id, item, amount, false)
                        VICE.notify(source, "~g~Paid £".. getMoneyStringFormatted(totalPrice) ..".")
                        TriggerClientEvent("vice:PlaySound", source, "playMoney")
                    end
                elseif cash > 0 and cash + VICE.getBankMoney(user_id) >= totalPrice then
                    local remaining = totalPrice - cash
                    if VICE.tryPayment(user_id, cash) and VICE.tryBankPayment(user_id, remaining) then
                        VICE.giveInventoryItem(user_id, item, amount, false)
                        VICE.notify(source, "~g~Paid £".. getMoneyStringFormatted(totalPrice) ..".")
                        TriggerClientEvent("vice:PlaySound", source, "playMoney")
                    else
                        VICE.notify(source, "~r~Not enough money.")
                        TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
                    end
                else
                    VICE.notify(source, "~r~Not enough money.")
                    TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
                end
            else
                VICE.notify(source, '~r~Not enough inventory space.')
                TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
            end
        end
    end
end)