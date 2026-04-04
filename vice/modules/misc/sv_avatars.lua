RegisterNetEvent('VICE:requestAvatar')
AddEventHandler('VICE:requestAvatar', function(user_id)
    local source = source
    local avatar = exports["vice"]:Get_Discord_Avatar(exports['vice']:Get_Client_Discord_ID(VICE.getUserSource(user_id)))
    TriggerClientEvent('VICE:receiveAvatar', source, avatar)
end)

function RequestPFP(user_id)
    local table,ids = {},{}
    for _,id in pairs(GetPlayerIdentifiers(VICE.getUserSource(user_id))) do
        local key,value = string.match(id, "([^:]+):(.+)")
        if key and value then
            ids[key] = ids[key] or key..":"..value
        end
    end
    if ids["steam"] then
        PerformHttpRequest("http://steamcommunity.com/profiles/"..tonumber(stringsplit(ids["steam"],":")[2],16).."/?xml=1", function(err, text, headers)
            if text then
                local SteamProfileSplitted = stringsplit(text, '\n')
                for i, Line in ipairs(SteamProfileSplitted) do
                    if Line:find('<avatarFull>') then
                        table["Steam"] = Line:gsub('<avatarFull><!%[CDATA%[', ''):gsub(']]></avatarFull>', '')
                        break
                    end
                end
            end
        end)
    end
    table["Steam"] = table["Steam"] or "https://imgur.com/a/xmYNJG7"
    -- table["Discord"] = "https://imgur.com/a/1ehlA01"
    local avatar = exports["vice"]:Get_Discord_Avatar(exports['vice']:Get_Client_Discord_ID(VICE.getUserSource(user_id)))
    table["Discord"] = avatar
    if user_id and VICE.getUserSource(user_id) then
        exports["vice"]:Get_Discord_Avatar(exports['vice']:Get_Client_Discord_ID(VICE.getUserSource(user_id)))
    end
    table["None"] = "https://i.imgur.com/UFGzlQw.png"
    
    return table
end 
AddEventHandler("VICE:onServerSpawn",function(user_id,source,first_spawn)
    Citizen.Wait(6000)
    TriggerClientEvent("VICE:setProfilePictures",source,RequestPFP(user_id))
end)

TriggerClientEvent("VICE:requestAvatar", source, VICE.getUserId())

-- Listen for the avatar from the server:
RegisterNetEvent('VICE:receiveAvatar')
AddEventHandler('VICE:receiveAvatar', function(url)
    SendNUIMessage({
        setPFP = url
    })
end)

RegisterNetEvent('VICE:setProfilePictures')
AddEventHandler('VICE:setProfilePictures', function(pfps)
    if pfps and pfps.Discord then
        SendNUIMessage({
            setPFP = pfps.Discord
        })
    end
end)

function VICE.getAvatar(discordId)
    if not discordId then return end
    
    local avatarUrl = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. avatars[discordId] .. ".png"
    TriggerClientEvent("VICE:setAvatar", -1, discordId, avatarUrl)
end
