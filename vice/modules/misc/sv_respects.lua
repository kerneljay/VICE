local cayoPaymentCooldowns = {}

RegisterNetEvent("VICE:cayoPayment")
AddEventHandler("VICE:cayoPayment", function()
    local source = source
    local user_id = VICE.getUserId(source)

    if not cayoPaymentCooldowns[user_id] then
        VICE.giveMoney(user_id, 500000)
        cayoPaymentCooldowns[user_id] = true
    else
        VICE.notify(source, '~r~You have already paid your respects.')
    end
end)