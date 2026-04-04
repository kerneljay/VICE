RegisterServerEvent("playRussianRouletteGlobally")
AddEventHandler('playRussianRouletteGlobally', function(coords)
    TriggerClientEvent('playRussianRoulette', -1, coords)
end)

RegisterServerEvent("playEmptyGunGlobally")
AddEventHandler('playEmptyGunGlobally', function(coords)
    TriggerClientEvent('playEmptyGun', -1, coords)
end)