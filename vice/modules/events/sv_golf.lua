RegisterServerEvent('VICE:takeGolfMoney')
AddEventHandler('VICE:takeGolfMoney', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.tryBankPayment(user_id, 5000) then
        TriggerClientEvent('VICE:startGolf', source)
        VICE.notify(source, "~g~Paid £5,000")
    else
        VICE.notify(source, "~r~You do not have enough money.")
    end
end)