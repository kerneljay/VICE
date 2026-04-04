function getCallsign(guildType, source, user_id, type)
    local discord_id = exports['vice']:Get_Client_Discord_ID(source)
    if discord_id then
        local guilds_info = exports['vice']:Get_Guilds()
        for guild_name, guild_id in pairs(guilds_info) do
            if guild_name == guildType then
                local nick_name = exports['vice']:Get_Guild_Nickname(guild_id, discord_id)
                if nick_name then
                    local open_bracket = string.find(nick_name, '[', nil, true) -- Extra Params to toggle pattern matching
                    local closed_bracket = string.find(nick_name, ']', nil, true) -- Extra Params to toggle pattern matching
                    if open_bracket and closed_bracket then
                        local callsign_value = string.sub(nick_name, open_bracket + 1, closed_bracket - 1)
                        local group = getGroupInGroups(user_id, type)
                        if group then
                            group = string.gsub(group, ' Clocked', '')
                        else
                            group = 'N/A'
                        end
                        return callsign_value or 'N/A', group, VICE.getPlayerName(user_id)
                    end
                end
            end
        end
    end
end

RegisterServerEvent("VICE:getCallsign")
AddEventHandler("VICE:getCallsign", function(type)
    local source = source
    local user_id = VICE.getUserId(source)
    Wait(1000)
    if type == 'police' and VICE.hasPermission(user_id, 'police.armoury') then
        TriggerClientEvent("VICE:receivePoliceCallsign", source, getCallsign('Police', source, user_id, 'Police'))
        TriggerClientEvent("VICE:setPoliceOnDuty", source, true)
    elseif type == 'prison' and VICE.hasPermission(user_id, 'hmp.menu') then
        TriggerClientEvent("VICE:receiveHmpCallsign", source, getCallsign('HMP', source, user_id, 'HMP'))
        TriggerClientEvent("VICE:setPrisonGuardOnDuty", source, true)
    elseif type == 'lfb' and VICE.hasPermission(user_id, 'lfb.menu') then
        TriggerClientEvent("VICE:receiveLFBCallsign", source, getCallsign('LFB', source, user_id, 'LFB'))
        TriggerClientEvent("VICE:setLFBOnDuty", source, true)
    elseif type == 'ukbf' and VICE.hasPermission(user_id, 'ukbf.armoury') then
        TriggerClientEvent("VICE:receiveUKBFCallsign", source, getCallsign('UKBF', source, user_id, 'UKBF'))
        TriggerClientEvent("VICE:setUKBFOnDuty", source, true)
    end
end)