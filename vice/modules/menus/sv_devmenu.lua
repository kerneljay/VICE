RegisterNetEvent('VICE:logWeaponSpawn')
AddEventHandler('VICE:logWeaponSpawn', function(logType, logTitle, weapon)
    local source = source
    local user_id = VICE.getUserId(source)
    local playerName = VICE.getPlayerName(user_id)

    if VICE.hasPermission(user_id, "dev.menu") or VICE.hasgroup (user_id, 'External Contributor' ) then

        VICE.sendDCLog(logType, logTitle, "> Player Name: **"..playerName.."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Weapon: **" .. weapon .. "**")
    else
       VICE.ACBan(15,user_id,"VICE:logWeaponSpawn")
    end
end)