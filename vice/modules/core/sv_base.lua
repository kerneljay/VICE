RegisterServerEvent("VICE:CheckUserId",function(kvpid)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        if user_id ~= kvpid then
            VICE.isBanned(kvpid,function(banned)
                if banned then
                    VICE.banConsole(user_id,"perm","Ban Evading","ID Banned: "..kvpid)
                    VICE.sendDCLog("banevading",VICE.getPlayerName(user_id).." has been banned for ban evading","> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Temp ID: **"..source.."**\n> Perm ID: **"..user_id.."**\n> Ban Evading ID: **"..kvpid.."**")
                end
            end)
        end
    end
end)

RegisterServerEvent("VICE:VerifyUserId",function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        if user_id ~= id then
            VICE.ACBan(15,user_id,"Attempted to change their user id to "..id)
        end
    end
end)