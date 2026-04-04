RegisterCommand('cinematicmenu', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'Cinematic') then
        TriggerClientEvent('VICE:openCinematicMenu', source)
    end
end)