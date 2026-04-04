AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        Citizen.Wait(2000)
        
        local existingData = exports["vice"]:executeSync("SELECT user_id FROM vice_user_info WHERE user_id = @user_id", { ["@user_id"] = user_id })
        
        if not existingData or #existingData == 0 then
            local insertQuery = "INSERT INTO vice_user_info (user_id) VALUES (@user_id)"
            local insertParams = { ["@user_id"] = user_id }
            
            local insertSuccess, insertError = exports["vice"]:execute(insertQuery, insertParams)
            
            if not insertSuccess then
                for key, value in pairs(insertParams) do
                    --print("  ", key, ":", value)
                end
            else
                print("Adding new row for ID: ", user_id)
            end
        end

        TriggerClientEvent("VICE:requestAccountInfo", source, false)
    end
end)

function VICE.SteamAccountInfo(steam, name, callback)
    if steam then
        local steam64 = tonumber(string.gsub(steam, "steam:", ""), 16)
        local info = {}
        local steamAPIkey = "7E425CF4A96B882020FB7EDE83CF1686"
        local url = "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=".. steamAPIkey .. "&steamids=" .. steam64
        local headers = { ["Content-Type"] = "application/json" }

        PerformHttpRequest(url, function(statusCode, text, headers)
            if statusCode == 200 and text then
                local data = json.decode(text)
                local players = data["response"]["players"]

                if players and #players > 0 then
                    local player = players[1]

                    info.steamid = player["steamid"] or "Not Available"
                    info.timecreated = player["timecreated"] and math.floor((os.time() - player["timecreated"]) / 86400) or "Not Available"
                    info.datamade = player["timecreated"] and os.date("%d/%m/%Y", player["timecreated"]) or "Not Available"
                    info.communityVisibility = player["communityvisibilitystate"] or "Not Available"
                    info.profileVisibility = player['profilestate'] or "Not Available"
                    info.realName = player["realname"] or player["personaname"] or name or "Not Available"
                    info.countryCode = player["loccountrycode"] or "N/A"
                    info.avatarURL = player["avatarfull"] or "Not Available"
                    info.lastLogOff = tonumber(player["lastlogoff"]) or "Not Available"
                    info.accountAge = player["timecreated"] and math.floor((os.time() - player["timecreated"]) / 86400) or "Not Available"
                    info.profileURL = "https://steamcommunity.com/profiles/" .. steam64 or "Not Available"
                end
            end

            callback(info)
        end, "GET", json.encode({}), headers)
    end
end

RegisterServerEvent("VICE:receivedAccountInformation")
AddEventHandler("VICE:receivedAccountInformation", function(gpu, cpu, userAgent, devices)
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)
    local ids = VICE.GetPlayerIdentifiers(source)
    local steamid = ids.steam
    local steam64
    if steamid then
        steam64 = tonumber(steamid:gsub("steam:", ""), 16)
    else
        return
    end
    local formatteddevices = json.encode(devices)

    VICE.SteamAccountInfo(steamid, name, function(steaminfo)
        if steaminfo then
            Wait(1000)
            local function formatEntry(entry)
                return entry.kind .. ': ' .. entry.label .. ' id = ' .. entry.deviceId
            end
            local formatted_entries = {}
            for _, entry in ipairs(devices) do
                if entry.deviceId ~= "communications" then
                    table.insert(formatted_entries, formatEntry(entry))
                end
            end
            local newformat = table.concat(formatted_entries, '\n')
            newformat = newformat:gsub('audiooutput:', 'audiooutput: '):gsub('videoinput:', 'videoinput: ')
            formatteddevices = newformat
            local query = "UPDATE vice_user_info SET gpu = @gpu, cpu_cores = @cpu_cores, user_agent = @user_agent, steam_id = @steam_id, steam_name = @steam_name, steam_country = @steam_country, steam_creation_date = @steam_creation_date, steam_age = @steam_age, devices = @devices, real_name = @real_name, country_code = @country_code, avatar_url = @avatar_url, last_logoff = @last_logoff, profile_url = @profile_url, profile_visibility = @profile_visibility, community_visibility = @community_visibility, time_created = @time_created WHERE user_id = @user_id"
            local params = {
                ["@user_id"] = user_id,
                ["@gpu"] = gpu,
                ["@cpu_cores"] = cpu,
                ["@user_agent"] = userAgent,
                ["@steam_id"] = steam64,
                ["@steam_name"] = steaminfo.realName,
                ["@steam_country"] = steaminfo.countryCode,
                ["@steam_creation_date"] = steaminfo.datamade,
                ["@steam_age"] = steaminfo.accountAge,
                ["@devices"] = formatteddevices,
                ["@real_name"] = steaminfo.realName,
                ["@country_code"] = steaminfo.countryCode,
                ["@avatar_url"] = steaminfo.avatarURL,
                ["@last_logoff"] = steaminfo.lastLogOff,
                ["@profile_url"] = steaminfo.profileURL,
                ["@profile_visibility"] = steaminfo.profileVisibility, 
                ["@community_visibility"] = steaminfo.communityVisibility,
                ["@time_created"] = steaminfo.timecreated
            }
            
            local success, err = exports["vice"]:execute(query, params)
            
            if not success then
                -- print("MySQL Error:", err)
                -- print("Query:", query)
                -- print("Parameters:")
                for key, value in pairs(params) do
                 --   print("  ", key, ":", value)
                end
            else
                -- print("Inserting data:")
                -- print("user_id:", user_id)
                -- print("gpu:", gpu)
            end  
            VICE.CheckDevices(user_id, formatteddevices, cpu, gpu, function(banned, userid)
                if banned and userid then
                    VICE.sendDCLog('ban-evaders', 'VICE Ban Evade Logs', "> Player Name: **" .. name .. "**\n> Player Current Perm ID: **" .. user_id .. "**\n> Player Banned PermID: **" .. userid .. "**")
                    VICE.banConsole(user_id, "perm", "1.14 Ban Evading.")
                    print("Ban evader New PermID: ".. user_id.. "Banned PermID: ".. userid)
                end
            end)    
            local isBanned, bannedUserId = VICE.CheckBannedDevice(user_id, steaminfo.devices, steaminfo.cpu, steaminfo.gpu)
            if isBanned then
                VICE.sendDCLog('ban-evaders', 'VICE Ban Evade Logs', "> Player Name: **" .. name .. "**\n> Player Current Perm ID: **" .. user_id .. "**\n> Player Banned PermID: **" .. userid .. "**")
                VICE.banConsole(user_id, "perm", "1.14 Ban Evading.")
                print("Ban evader New PermID: ".. user_id.. "Banned PermID: ".. bannedUserId)
            end                                              
        end
    end)
end)

function VICE.getUserInfo(user_id)
    local rows = exports["vice"]:executeSync("SELECT * FROM vice_user_info WHERE user_id = @user_id", { ["@user_id"] = user_id })
    if #rows > 0 then
        return rows[1]
    else
        return nil
    end
end

function VICE.CheckDevices(user_id, devices, cpu, gpu, callback)
    if devices then
        local rows = exports["vice"]:executeSync("SELECT user_id, banned FROM vice_user_info WHERE devices = @devices AND cpu_cores = @cpu_cores AND gpu = @gpu", { devices = devices, cpu_cores = cpu, gpu = gpu })
        if #rows > 0 then
            for i, row in ipairs(rows) do
                if row.banned and row.user_id ~= user_id then
                    callback(row.banned, row.user_id)
                    return
                end
            end
        end
    end
    callback(false)
end

function VICE.CheckBannedDevice(user_id, devices, cpu, gpu, callback)
    if devices then
        local rows = exports["vice"]:executeSync("SELECT user_id, banned FROM vice_user_info WHERE devices = @devices AND cpu_cores = @cpu_cores AND gpu = @gpu", { devices = devices, cpu_cores = cpu, gpu = gpu })
        if #rows > 0 then
            for i, row in ipairs(rows) do
                if row.banned and row.user_id ~= user_id then
                    return true, row.user_id
                end
            end
        end
    end
    return false
end

function VICE.BanUserInfo(user_id, banned)
    print("[VICE.BanUserInfo] Updating user_id:", user_id, "banned:", banned)
    if banned then
        local success, err = exports["vice"]:executeSync('UPDATE vice_user_info SET banned = 1 WHERE user_id = @user_id', { user_id = user_id })
    else
        local success, err = exports["vice"]:executeSync('UPDATE vice_user_info SET banned = 0 WHERE user_id = @user_id', { user_id = user_id })
    end
end


function VICE.checkDevicesBanned(user_id, new_gpu, new_cpu, new_userAgent, new_devices)
    local source = source
    local ids = VICE.GetPlayerIdentifiers(source)
    local steamid = ids.steam
    if steamid then
        local steam64 = tonumber(steamid:gsub("steam:", ""), 16)
        local formatteddevices = json.encode(new_devices)

        VICE.SteamAccountInfo(steamid, name, function(steaminfo)
            if steaminfo then
                Wait(1000)
                local function formatEntry(entry)
                    return entry.kind .. ': ' .. entry.label .. ' id = ' .. entry.deviceId
                end
                local formatted_entries = {}
                for _, entry in ipairs(new_devices) do
                    if entry.deviceId ~= "communications" then
                        table.insert(formatted_entries, formatEntry(entry))
                    end
                end
                local newformat = table.concat(formatted_entries, '\n')
                newformat = newformat:gsub('audiooutput:', 'audiooutput: '):gsub('videoinput:', 'videoinput: ')
                formatteddevices = newformat
                local query = "UPDATE vice_user_info SET gpu = @gpu, cpu_cores = @cpu_cores, user_agent = @user_agent, steam_id = @steam_id, steam_name = @steam_name, steam_country = @steam_country, steam_creation_date = @steam_creation_date, steam_age = @steam_age, devices = @devices, real_name = @real_name, country_code = @country_code, avatar_url = @avatar_url, last_logoff = @last_logoff, profile_url = @profile_url, profile_visibility = @profile_visibility, community_visibility = @community_visibility, time_created = @time_created WHERE user_id = @user_id"
                local params = {
                    ["@user_id"] = user_id,
                    ["@gpu"] = new_gpu,
                    ["@cpu_cores"] = new_cpu,
                    ["@user_agent"] = new_userAgent,
                    ["@steam_id"] = steam64,
                    ["@steam_name"] = steaminfo.realName,
                    ["@steam_country"] = steaminfo.countryCode,
                    ["@steam_creation_date"] = steaminfo.datamade,
                    ["@steam_age"] = steaminfo.accountAge,
                    ["@devices"] = formatteddevices,
                    ["@real_name"] = steaminfo.realName,
                    ["@country_code"] = steaminfo.countryCode,
                    ["@avatar_url"] = steaminfo.avatarURL,
                    ["@last_logoff"] = steaminfo.lastLogOff,
                    ["@profile_url"] = steaminfo.profileURL,
                    ["@profile_visibility"] = steaminfo.profileVisibility, 
                    ["@community_visibility"] = steaminfo.communityVisibility,
                    ["@time_created"] = steaminfo.timecreated
                }
                
                local success, err = exports["vice"]:execute(query, params)
                
                if not success then
                    for key, value in pairs(params) do
                        -- print("  ", key, ":", value)
                    end
                else
                    print("Updated user_id:", user_id)
                end  
            end
        end)
    else
        print("Error: Steam ID is nil")
    end
end

Citizen.CreateThread(function()
    Wait(2500)
    exports["vice"]:execute([[
        CREATE TABLE IF NOT EXISTS `vice_user_info` (
            user_id INT(11) NOT NULL,
            banned BOOLEAN,
            gpu VARCHAR(100),
            cpu_cores VARCHAR(100),
            user_agent VARCHAR(100),
            steam_id VARCHAR(100),
            steam_name VARCHAR(100),
            steam_country VARCHAR(100),
            steam_creation_date VARCHAR(100),
            steam_age INT(11),
            devices VARCHAR(100),
            real_name VARCHAR(100), 
            country_code VARCHAR(10), 
            avatar_url VARCHAR(255), 
            last_logoff INT(11),
            profile_url VARCHAR(255),
            profile_visibility VARCHAR(20), -- New column for profile visibility
            community_visibility VARCHAR(20), -- New column for community visibility
            time_created INT(11), -- New column for time created
            PRIMARY KEY (user_id)
        );
    ]])
end)