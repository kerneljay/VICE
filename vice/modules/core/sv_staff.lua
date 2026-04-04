local staffPlayers = {}

-- Event to update staff status
RegisterServerEvent('VICE:updateStaffStatus')
AddEventHandler('VICE:updateStaffStatus', function(playerId, isStaff, permissions)
    if isStaff then
        staffPlayers[playerId] = permissions
    else
        staffPlayers[playerId] = nil
    end
    
    -- Broadcast the update to all players
    TriggerClientEvent('VICE:updateStaffStatus', -1, playerId, isStaff, permissions)
end)

-- When a player joins, send them the current staff list
AddEventHandler('playerJoining', function()
    local source = source
    for playerId, permissions in pairs(staffPlayers) do
        TriggerClientEvent('VICE:updateStaffStatus', source, playerId, true, permissions)
    end
end)

-- When a player leaves, remove them from the staff list
AddEventHandler('playerDropped', function()
    local source = source
    if staffPlayers[source] then
        staffPlayers[source] = nil
        TriggerClientEvent('VICE:updateStaffStatus', -1, source, false, nil)
    end
end)

RegisterNetEvent("VICE:checkStaffRoles")
AddEventHandler("VICE:checkStaffRoles", function(playerId)
    local source = source
    local roles = {}
    
    -- Check for each staff role
    if VICE.hasGroup(source, "Founder") then
        table.insert(roles, "Founder")
    end
    if VICE.hasGroup(source, "Lead Developer") then
        table.insert(roles, "Lead Developer")
    end
    if VICE.hasGroup(source, "Developer") then
        table.insert(roles, "Developer")
    end
    if VICE.hasGroup(source, "Community Manager") then
        table.insert(roles, "Community Manager")
    end
    if VICE.hasGroup(source, "Staff Manager") then
        table.insert(roles, "Staff Manager")
    end
    if VICE.hasGroup(source, "Head Administrator") then
        table.insert(roles, "Head Administrator")
    end
    if VICE.hasGroup(source, "Senior Administrator") then
        table.insert(roles, "Senior Administrator")
    end
    if VICE.hasGroup(source, "Administrator") then
        table.insert(roles, "Administrator")
    end
    if VICE.hasGroup(source, "Senior Moderator") then
        table.insert(roles, "Senior Moderator")
    end
    if VICE.hasGroup(source, "Moderator") then
        table.insert(roles, "Moderator")
    end
    if VICE.hasGroup(source, "Support Team") then
        table.insert(roles, "Support Team")
    end
    if VICE.hasGroup(source, "Trial Staff") then
        table.insert(roles, "Trial Staff")
    end
    
    TriggerClientEvent("VICE:receiveStaffRoles", source, roles)
end)

RegisterNetEvent("VICE:setOutfit")
AddEventHandler("VICE:setOutfit", function(outfit)
    local source = source
    VICE.setOutfit(source, outfit)
end)

RegisterNetEvent("VICE:resetOutfit")
AddEventHandler("VICE:resetOutfit", function()
    local source = source
    VICE.resetOutfit(source)
end)

RegisterNetEvent('VICE:requestDiscordName')
AddEventHandler('VICE:requestDiscordName', function(targetId)
    local source = source
    local discordName = VICE.getDiscordName(targetId)
    if discordName then
        TriggerClientEvent('VICE:updateDiscordName', -1, targetId, discordName)
    end
end) 