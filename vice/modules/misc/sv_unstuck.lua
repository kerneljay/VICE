RegisterServerEvent('VICE:unstuckSuccessful')
AddEventHandler('VICE:unstuckSuccessful', function(d, e)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        VICE.sendDCLog('unstuck-logs', 'Temp ID: **'.. source .. '**\nPerm ID: **' .. VICE.getUserId(source) .. '**\n Coordinates: **' .. e.x .. ', ' .. e.y .. ', ' .. e.z .. '**\n Reason: **' .. e.reason .. '**\n', source)
    end
end)