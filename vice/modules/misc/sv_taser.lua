RegisterServerEvent('VICE:playTaserSound')
AddEventHandler('VICE:playTaserSound', function(coords, sound)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
        TriggerClientEvent('playTaserSoundClient', -1, coords, sound)
    end
end)

RegisterServerEvent('VICE:reactivatePed')
AddEventHandler('VICE:reactivatePed', function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
      TriggerClientEvent('VICE:receiveActivation', id)
      TriggerClientEvent('TriggerTazer', id)
    end
end)

RegisterServerEvent('VICE:arcTaser')
AddEventHandler('VICE:arcTaser', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
      VICEclient.getNearestPlayer(source, {3}, function(nplayer)
        local nuser_id = VICE.getUserId(nplayer)
        if nuser_id then
            TriggerClientEvent('VICE:receiveBarbs', nplayer, source)
            TriggerClientEvent('TriggerTazer', id)
        end
      end)
    end
end)

RegisterServerEvent('VICE:barbsNoLongerServer')
AddEventHandler('VICE:barbsNoLongerServer', function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
      TriggerClientEvent('VICE:barbsNoLonger', id)
    end
end)

RegisterServerEvent('VICE:barbsRippedOutServer')
AddEventHandler('VICE:barbsRippedOutServer', function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:barbsRippedOut', id)
end)

RegisterCommand('rt', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
      TriggerClientEvent('VICE:reloadTaser', source)
  end
end)