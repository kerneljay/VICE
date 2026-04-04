RegisterServerEvent('VICE:tryBuyAttachment')
AddEventHandler('VICE:tryBuyAttachment', function(weapon, attachment, price)
    local source = source
    local user_id = VICE.getUserId(source)

    if VICE.tryBankPayment(user_id, price) then
        TriggerClientEvent('VICE:updateBoughtAttachments', source, attachment, weapon)
    else
        VICE.notify(source,"~r~Not enough money.")
    end
end)