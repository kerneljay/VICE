local c = {}
RegisterCommand("djmenu", function(source, args, rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id,"DJ") then
        TriggerClientEvent('VICE:toggleDjMenu', source)
    end
end)
RegisterCommand("djadmin", function(source, args, rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id,"admin.noclip") then
        TriggerClientEvent('VICE:toggleDjAdminMenu', source, c)
    end
end)
RegisterCommand("play",function(source,args,rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local name = VICE.getPlayerName(user_id)
    if VICE.hasGroup(user_id,"DJ") then
        if #args > 0 then
            TriggerClientEvent('VICE:finaliseSong', source,args[1])
        end
    end
end)
RegisterServerEvent("VICE:DJMenuplay")
AddEventHandler("VICE:DJMenuplay",function(args)
    local source = source
    local user_id = VICE.getUserId(source)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local name = VICE.getPlayerName(user_id)
    if VICE.hasGroup(user_id,"DJ") then
        if args then
            TriggerClientEvent('VICE:finaliseSong', source,args)
        end
    end
end)
RegisterServerEvent("VICE:adminStopSong")
AddEventHandler("VICE:adminStopSong", function(PARAM)
    local source = source
    for k,v in pairs(c) do
        if v[1] == PARAM then
            TriggerClientEvent('VICE:stopSong', -1,v[2])
            c[tostring(k)] = nil
            TriggerClientEvent('VICE:toggleDjAdminMenu', source, c)
        end
    end
end)
RegisterServerEvent("VICE:playDjSongServer")
AddEventHandler("VICE:playDjSongServer", function(PARAM,coords)
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)
    c[tostring(source)] = {PARAM,coords,user_id,name,"true"}
    TriggerClientEvent('VICE:playDjSong', -1,PARAM,coords,user_id,name)
end)
RegisterServerEvent("VICE:skipServer")
AddEventHandler("VICE:skipServer", function(coords,param)
    local source = source
    TriggerClientEvent('VICE:skipDj', -1,coords,param)
end)
RegisterServerEvent("VICE:stopSongServer")
AddEventHandler("VICE:stopSongServer", function(coords)
    local source = source
    c[tostring(source)] = nil
    TriggerClientEvent('VICE:stopSong', -1,coords)
end)
RegisterServerEvent("VICE:updateVolumeServer")
AddEventHandler("VICE:updateVolumeServer", function(coords,volume)
    local source = source
    TriggerClientEvent('VICE:updateDjVolume', -1,coords,volume)
end)


RegisterServerEvent("VICE:requestCurrentProgressServer") -- doing this will fix the issue of the song not playing when you leave and re enter the area
AddEventHandler("VICE:requestCurrentProgressServer", function(a,b)
    TriggerClientEvent('VICE:requestCurrentProgress', -1, a, b)
end)

RegisterServerEvent("VICE:returnProgressServer") -- doing this will fix the issue of the song not playing when you leave and re enter the area
AddEventHandler("VICE:returnProgressServer", function(x,y,z)
    for k,v in pairs(c) do
        if tonumber(k) == VICE.getUserSource(x) then
            TriggerClientEvent('VICE:returnProgress', -1, x, y, z, v[1])
        end
    end
end)
