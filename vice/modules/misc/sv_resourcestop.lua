AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == "vice" then
        TriggerClientEvent('showEndScreen', -1)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == "vice" then
        TriggerClientEvent('hideEndScreen', -1)
    end
end)
