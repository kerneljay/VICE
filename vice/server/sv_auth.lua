local verifiedDiscordIds = {}
local permIdToDiscordId = {}
local lastAuthAttempts = {}
local MAX_AUTH_ATTEMPTS = 3
local AUTH_TIMEOUT = 300 -- 5 minutes

local function checkDuplicatePermId(source, permId, discordId)
    local identifiers = GetPlayerIdentifiers(source)
    local ip = GetPlayerEndpoint(source)
    
    MySQL.Async.fetchAll('SELECT * FROM users WHERE perm_id = @permId', {
        ['@permId'] = permId
    }, function(results)
        if #results > 0 then
            if results[1].discord_id ~= discordId then
                DropPlayer(source, "Unauthorized duplicate perm ID detected")
                print(string.format("^1[SECURITY ALERT] Unauthorized duplicate perm ID %s detected from IP %s^0", permId, ip))
            end
        end
    end)
end

local function validateDiscordIdentity(source, discordId)
    local ip = GetPlayerEndpoint(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    -- Check for Discord token validity
    local hasValidToken = false
    for _, id in ipairs(identifiers) do
        if string.match(id, "discord:") then
            local token = string.gsub(id, "discord:", "")
            if token == discordId then
                hasValidToken = true
                break
            end
        end
    end
    
    if not hasValidToken then
        return false, "Invalid Discord token"
    end
    
    -- Check for IP history
    MySQL.Async.fetchAll('SELECT ip FROM users WHERE discord_id = @discordId', {
        ['@discordId'] = discordId
    }, function(results)
        if #results > 0 then
            local knownIPs = {}
            for _, row in ipairs(results) do
                table.insert(knownIPs, row.ip)
            end
            
            if not table.contains(knownIPs, ip) then
                print(string.format("^1[SECURITY ALERT] New IP %s attempting to use Discord ID %s^0", ip, discordId))
                -- You might want to implement additional verification here
            end
        end
    end)
    
    return true
end

RegisterNetEvent('vice:auth')
AddEventHandler('vice:auth', function()
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local discordId = nil
    
    -- Rate limiting
    if not lastAuthAttempts[source] then
        lastAuthAttempts[source] = {
            count = 0,
            timestamp = os.time()
        }
    end
    
    local currentTime = os.time()
    if currentTime - lastAuthAttempts[source].timestamp > AUTH_TIMEOUT then
        lastAuthAttempts[source].count = 0
        lastAuthAttempts[source].timestamp = currentTime
    end
    
    lastAuthAttempts[source].count = lastAuthAttempts[source].count + 1
    if lastAuthAttempts[source].count > MAX_AUTH_ATTEMPTS then
        DropPlayer(source, "Too many authentication attempts")
        return
    end
    
    for _, id in ipairs(identifiers) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    
    if not discordId then
        DropPlayer(source, "Discord not found")
        return
    end
    
    -- Validate Discord identity
    local isValid, error = validateDiscordIdentity(source, discordId)
    if not isValid then
        DropPlayer(source, error)
        return
    end
    
    if verifiedDiscordIds[discordId] then
        local storedIP = GetPlayerEndpoint(verifiedDiscordIds[discordId])
        local currentIP = GetPlayerEndpoint(source)
        
        if storedIP ~= currentIP then
            DropPlayer(source, "IP mismatch detected")
            print(string.format("^1[SECURITY ALERT] IP mismatch for Discord ID %s^0", discordId))
            return
        end
    end
    
    MySQL.Async.fetchAll('SELECT perm_id FROM users WHERE discord_id = @discordId', {
        ['@discordId'] = discordId
    }, function(results)
        if #results > 0 then
            local permId = results[1].perm_id
            
            checkDuplicatePermId(source, permId, discordId)
            
            verifiedDiscordIds[discordId] = source
            permIdToDiscordId[permId] = discordId
            
            TriggerClientEvent('vice:setPlayerData', source, {
                permId = permId,
                discordId = discordId
            })
        else
            if not VICE.isDev() then
                DropPlayer(source, "Please verify your Discord ID first")
                return
            end
        end
    end)
end)

-- Helper function to check if a table contains a value
function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end 