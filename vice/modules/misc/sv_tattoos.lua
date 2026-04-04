RegisterServerEvent('VICE:saveTattoos')
AddEventHandler('VICE:saveTattoos', function(tattooData, price)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.tryFullPayment(user_id, price) then
        VICE.setUData(user_id, "VICE:Tattoo:Data", json.encode(tattooData))
        VICE.notify(source, '~g~Purchased tattoo.')
    end
end)

RegisterServerEvent('VICE:getPlayerTattoos')
AddEventHandler('VICE:getPlayerTattoos', function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:Tattoo:Data", function(data)
        if data then
            TriggerClientEvent('VICE:setTattoos', source, json.decode(data))
        end
    end)
end)
