local giveerrrors = true

AddEventHandler("VICE:serverIssue",function(errorfile,data)
    print("Server Issue: "..data.." at file: "..errorfile .. "^7")
    if giveerrrors then
        VICE.sendDCLog("server-bug","Server Issue","**Issue at file: **"..errorfile.."\n**Error: **"..data)
    end
end)

RegisterServerEvent("VICE:clientIssue",function(errorfile,data)
    local source = source
    print("Client Issue: "..data.." at file: "..errorfile .. "^7")
    if giveerrrors then
        VICE.sendDCLog("client-bug","Client Issue","Source: "..source.."\n**Issue at file: **"..errorfile.."\n**Error: **"..data)
    end
end)

RegisterCommand("toggleerrors",function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if source == 0 then
        giveerrrors = not giveerrrors
        print("Errors are now "..(giveerrrors and "enabled" or "disabled ^7"))
    end
end)