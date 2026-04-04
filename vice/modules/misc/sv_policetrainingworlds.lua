local trainingWorlds = {}
local trainingWorldsCount = 0
RegisterCommand('trainingworlds', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        TriggerClientEvent('VICE:trainingWorldSendAll', source, trainingWorlds)
        TriggerClientEvent('VICE:trainingWorldOpen', source, VICE.hasPermission(user_id, 'police.announce'))
    end
end)

RegisterNetEvent("VICE:trainingWorldCreate")
AddEventHandler("VICE:trainingWorldCreate", function()
    local source = source
    local user_id = VICE.getUserId(source)
    trainingWorldsCount = trainingWorldsCount + 1
    VICE.prompt(source,"World Name:","",function(player,worldname) 
        if string.gsub(worldname, "%s+", "") ~= '' then
            if next(trainingWorlds) then
                for k,v in pairs(trainingWorlds) do
                    if v.name == worldname then
                        VICE.notify(source, "This world name already exists.")
                        return
                    elseif v.ownerUserId == user_id then
                        VICE.notify(source, "You already have a world, please delete it first.")
                        return
                    end
                end
            end
            VICE.prompt(source,"World Password:","",function(player,password) 
                trainingWorlds[trainingWorldsCount] = {name = worldname, ownerName = VICE.getPlayerName(VICE.getUserId(source)), ownerUserId = user_id, bucket = trainingWorldsCount, members = {}, password = password}
                table.insert(trainingWorlds[trainingWorldsCount].members, user_id)
                VICE.setBucket(source, trainingWorldsCount)
                TriggerClientEvent('VICE:trainingWorldSend', -1, trainingWorldsCount, trainingWorlds[trainingWorldsCount])
                VICE.notify(source, '~g~Training World Created!')
            end)
        else
            VICE.notify(source, "Invalid World Name.")
        end
    end)
end)

RegisterNetEvent("VICE:trainingWorldRemove")
AddEventHandler("VICE:trainingWorldRemove", function(world)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.announce') then
        if trainingWorlds[world] then
            TriggerClientEvent('VICE:trainingWorldRemove', -1, world)
            for k,v in pairs(trainingWorlds[world].members) do
                local memberSource = VICE.getUserSource(v)
                if memberSource then
                    VICE.setBucket(memberSource, 0)
                    VICE.notify(memberSource, "~b~The training world you were in was deleted, you have been returned to the main dimension.")
                end
            end
            trainingWorlds[world] = nil
        end
    end
end)

RegisterNetEvent("VICE:trainingWorldJoin")
AddEventHandler("VICE:trainingWorldJoin", function(world)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.prompt(source,"Enter Password:","",function(player,password) 
        if password ~= trainingWorlds[world].password then
            VICE.notify(source, "Invalid Password.")
            return
        else
            VICE.setBucket(source, world)
            table.insert(trainingWorlds[world].members, user_id)
            VICE.notify(source, "~b~You have joined training world "..trainingWorlds[world].name..' owned by '..trainingWorlds[world].ownerName..'.')
        end
    end)
end)

RegisterNetEvent("VICE:trainingWorldLeave")
AddEventHandler("VICE:trainingWorldLeave", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.setBucket(source, 0)
    VICE.notify(source, "~b~You have left the training world.")
end)

