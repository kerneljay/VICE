local tacoDrivers = {}

RegisterNetEvent('VICE:addTacoSeller')
AddEventHandler('VICE:addTacoSeller', function(coords, price)
    local source = source
    local user_id = VICE.getUserId(source)
    tacoDrivers[user_id] = {position = coords, amount = price}
    TriggerClientEvent('VICE:sendClientTacoData', -1, tacoDrivers)
end)

RegisterNetEvent('VICE:RemoveMeFromTacoPositions')
AddEventHandler('VICE:RemoveMeFromTacoPositions', function()
    local source = source
    local user_id = VICE.getUserId(source)
    tacoDrivers[user_id] = nil
    TriggerClientEvent('VICE:removeTacoSeller', -1, user_id)
end)

RegisterNetEvent('VICE:payTacoSeller')
AddEventHandler('VICE:payTacoSeller', function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if tacoDrivers[id] then
        if VICE.getInventoryWeight(user_id)+1 <= VICE.getInventoryMaxWeight(user_id) then
            if VICE.tryFullPayment(user_id,15000) then
                VICE.giveInventoryItem(user_id, 'Taco', 1)
                VICE.giveBankMoney(id, 15000)
                TriggerClientEvent("vice:PlaySound", source, "playMoney")
            else
                VICE.notify(source, 'You do not have enough money.')
            end
        else
            VICE.notify(source, 'Not enough inventory space.')
        end
    end
end)