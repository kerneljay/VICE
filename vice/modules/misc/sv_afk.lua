function getPlayerFaction(user_id)
    if VICE.hasPermission(user_id, 'police.armoury') then
        return 'pd'
    elseif VICE.hasPermission(user_id, 'nhs.menu') then
        return 'nhs'
    elseif VICE.hasPermission(user_id, 'hmp.menu') then
        return 'hmp'
    elseif VICE.hasPermission(user_id, 'lfb.menu') then
        return 'lfb'
    elseif VICE.hasPermission(user_id, 'gang.whitelisted') then
        return 'gang'
    elseif VICE.hasPermission(user_id, 'ukbf.armoury') then
        return 'ukbf'
    elseif VICE.hasPermission(user_id, 'tutorial.user') then
        return 'user'
    end
    return nil
end

RegisterServerEvent('VICE:factionAfkAlert')
AddEventHandler('VICE:factionAfkAlert', function(text)
    local source = source
    local user_id = VICE.getUserId(source)
    if getPlayerFaction(user_id) then
        VICE.sendDCLog(getPlayerFaction(user_id)..'-afk', 'VICE AFK Logs', "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
    end
end)

RegisterServerEvent('VICE:setNoLongerAFK')
AddEventHandler('VICE:setNoLongerAFK', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if getPlayerFaction(user_id) then
        VICE.sendDCLog(getPlayerFaction(user_id)..'-afk', 'VICE AFK Logs', "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
    end
end)

RegisterServerEvent('kick:AFK')
AddEventHandler('kick:AFK', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not VICE.hasPermission(user_id, 'group.add') then
        DropPlayer(source, 'You have been kicked for being AFK for too long.')
    end
end)

RegisterServerEvent('kick:PauseMenu')
AddEventHandler('kick:PauseMenu', function()
    local source = source
    local user_id = VICE.getUserId(source)
    DropPlayer(source, 'You have disconnected from VICE.')
end)