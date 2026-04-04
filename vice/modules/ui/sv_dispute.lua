local disputes = {}
local blockedUsers = {}

local function RefreshDispute()
    disputes = {}
    exports["vice"]:execute("SELECT * FROM vice_disputedata",function(result)
        if result then
            for k,v in pairs(result) do
                disputes[v.user_id] = json.decode(v.disputeData)
            end
        end
    end)
end

local function updateDisputeData(user_id, other_user_id, from_id, message)
    local function updatePlayerData(user_id, other_user_id, from_id, message)
        local disputeData = disputes[user_id]
        if not disputeData then
            disputeData = {
                user_id = user_id,
                players = {
                    {
                        id = other_user_id,
                        name = VICE.getPlayerName(other_user_id),
                        messages = {{from = from_id, to = user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')}}
                    }
                }
            }
            exports["vice"]:execute("INSERT INTO vice_disputedata (user_id, name, disputeData) VALUES (@user_id, @name, @disputeData)", {user_id = user_id, name = VICE.getPlayerName(user_id), disputeData = json.encode(disputeData)})
        else
            if disputeData.players == nil then
                disputeData.players = {}
            end
            local playerFound = false
            for _, player in ipairs(disputeData.players) do
                if player.id == other_user_id then
                    playerFound = true
                    if player.messages == nil then
                        player.messages = {}
                    end
                    table.insert(player.messages, {from = from_id, to = other_user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')})
                    break
                end
            end
            if not playerFound then
                local player_name = VICE.getPlayerName(other_user_id) 
                table.insert(disputeData.players, {id = other_user_id, name = player_name, messages = {{from = from_id, to = other_user_id, message = message, timestamp = os.date('%Y-%m-%d %H:%M:%S')}}})
            end
            exports["vice"]:execute("UPDATE vice_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = user_id, disputeData = json.encode(disputeData)})
        end
    end

    updatePlayerData(user_id, other_user_id, from_id, message)
    updatePlayerData(other_user_id, user_id, from_id, message)

    RefreshDispute()
end

function VICE.AddDisputeMessage(src, user_id, other_user_id, message)
    print("Adding dispute message from " .. user_id .. " to " .. other_user_id .. ": " .. message)
    if user_id and other_user_id and message then
        exports["vice"]:execute("SELECT * FROM vice_disputedata WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
             --   print("Success! :" .. message)
                local disputeData = json.decode(result[1].disputeData)
                for _, player in ipairs(disputeData.players) do
                    if player.id == other_user_id and player.blocked == 1 then
                        print("Message not sent, sender is blocked by the receiver")
                        return
                    end
                end
                updateDisputeData(user_id, other_user_id, user_id, message) -- sender
                updateDisputeData(other_user_id, user_id, user_id, message) -- receiver
                if VICE.getUserSource(other_user_id) then
                    --print("Added message :" .. message)
                    TriggerClientEvent("VICE:MessageHasBeenSent", VICE.getUserSource(other_user_id), user_id, other_user_id, message) -- receiver
                    RefreshDispute()
                else
                    print("Error: No client with user_id " .. other_user_id)
                end
                RefreshDispute()
            end
        end)
    end
end

RegisterServerEvent('VICE:calladdDisputeMessage')
AddEventHandler('VICE:calladdDisputeMessage', function(message)
    local source = source
    local user_id = VICE.getUserId(source)
    local other_user_id = message.to
    VICE.AddDisputeMessage(source, user_id, other_user_id, message.message)
    RefreshDispute()
end)

function VICE.AddDisputePlayer(user_id, other_user_id, player_name)
    if user_id and other_user_id and player_name then
        exports["vice"]:execute("SELECT * FROM vice_disputedata WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                if not disputeData then
                    local defaultdata = {user_id = other_user_id}
                    MySQL.execute("vice_disputes/adduser",{user_id = other_user_id,name = VICE.getPlayerName(other_user_id),disputeData = json.encode(defaultdata)})
                end
                if disputeData.players == nil then
                    disputeData.players = {}
                end
                for _, player in ipairs(disputeData.players) do
                    if player.id == other_user_id then
                        return -- If other_user_id is found, stop the function
                    end
                end
                table.insert(disputeData.players, {id = other_user_id, name = player_name, messages = {}})
                exports["vice"]:execute("UPDATE vice_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = user_id, disputeData = json.encode(disputeData)}, function()
                    RefreshDispute()
                end)
            end
        end)
    end
end

function VICE.FetchDisputePlayers(user_id, other_user_id)
    if user_id and other_user_id then
        local disputeData = disputes[user_id]
        if disputeData and disputeData.players then
            for _, player in ipairs(disputeData.players) do
                if player.id == other_user_id then
                    return true 
                end
            end
        end
    end
    return false
end

function VICE.GetDisputeMessages(user_id, source)
    if user_id then
        local disputeData = disputes[user_id]
        local messages = disputeData and disputeData.messages or nil
        return messages
    end
end

RegisterServerEvent('VICE:getMessagesUpdated')
AddEventHandler('VICE:getMessagesUpdated', function(userId)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.GetDisputeMessages(userId, source)
end)

RegisterCommand("refreshMessages",function(source,args)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id == 1 then
        VICE.GetDisputeMessages(user_id, source)
    end
end)

MySQL.createCommand("vice_disputes/adduser","INSERT INTO vice_disputedata (user_id,name,disputeData) VALUES (@user_id,@name,@disputeData) ON DUPLICATE KEY UPDATE name = @name, disputeData = @disputeData")

RegisterServerEvent("VICE:requestdisputedatas")
AddEventHandler("VICE:requestdisputedatas", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local disputeData = disputes[user_id]
    local sentMessages = {}
    local receivedMessages = {}
    if disputeData then
        for _, player in ipairs(disputeData.players or {}) do
            if player.messages then
                for _, message in ipairs(player.messages) do
                    if message.from == user_id then
                        table.insert(sentMessages, message)
                    else
                        table.insert(receivedMessages, message)
                    end
                end
            end
        end
    end
    RefreshDispute()
    TriggerClientEvent("VICEDISPUTEUI:setdisputedatas", source, disputeData, user_id, sentMessages, receivedMessages)
end)

function VICE.MuteUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        print("User " .. selected_user_id .. " has been muted by " .. triggering_user_id)
    end
end

function VICE.BlockUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        exports["vice"]:execute("SELECT * FROM vice_disputedata WHERE user_id = @user_id", {user_id = triggering_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for _, player in ipairs(disputeData.players) do
                    if player.id == selected_user_id then
                        player.blocked = 1
                        break
                    end
                end
                exports["vice"]:execute("UPDATE vice_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = triggering_user_id, disputeData = json.encode(disputeData)})
                print("User " .. selected_user_id .. " has been blocked by " .. triggering_user_id)
                RefreshDispute()
            end
        end)
    end
end

function VICE.DelUser(triggering_user_id, selected_user_id)
    if triggering_user_id and selected_user_id then
        exports["vice"]:execute("SELECT * FROM vice_disputedata WHERE user_id = @user_id", {user_id = triggering_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for i, player in ipairs(disputeData.players) do
                    if player.id == selected_user_id then
                        table.remove(disputeData.players, i)
                        break
                    end
                end
                exports["vice"]:execute("UPDATE vice_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = triggering_user_id, disputeData = json.encode(disputeData)})
                print("User " .. selected_user_id .. " has been deleted by " .. triggering_user_id)
                RefreshDispute()
            end
        end)
        exports["vice"]:execute("SELECT * FROM vice_disputedata WHERE user_id = @user_id", {user_id = selected_user_id}, function(result)
            if result and result[1] then
                local disputeData = json.decode(result[1].disputeData)
                for i, player in ipairs(disputeData.players) do
                    if player.id == triggering_user_id then
                        table.remove(disputeData.players, i)
                        break
                    end
                end
                exports["vice"]:execute("UPDATE vice_disputedata SET disputeData = @disputeData WHERE user_id = @user_id", {user_id = selected_user_id, disputeData = json.encode(disputeData)})
                print("User " .. triggering_user_id .. " has been deleted from " .. selected_user_id .. "'s player list")
                RefreshDispute()
            end
        end)
    end
end

RegisterServerEvent('VICE:callMuteUser')
AddEventHandler('VICE:callMuteUser', function(user2bMuted)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.MuteUser(user_id, user2bMuted)
end)

RegisterServerEvent('VICE:callDelUser')
AddEventHandler('VICE:callDelUser', function(user2bMuted)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.DelUser(user_id, user2bMuted)
end)

RegisterServerEvent('VICE:callBlockUser')
AddEventHandler('VICE:callBlockUser', function(user2bMuted)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.BlockUser(user_id, user2bMuted)
end)

AddEventHandler("VICE:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        local defaultdata = {user_id = user_id}
        MySQL.execute("vice_disputes/adduser",{user_id = user_id,name = VICE.getPlayerName(user_id),disputeData = json.encode(defaultdata)})
    end
end)

RegisterCommand("adddispute",function(source,args)
    local source = source
    local other = tonumber(args[1])
    local othername = VICE.getPlayerName(other)
    local sourceUserId = VICE.getUserId(source)
    local sourcename = VICE.getPlayerName(source)
    if sourceUserId == 1 then
        VICE.AddDisputePlayer(sourceUserId, other, othername)
        VICE.AddDisputePlayer(other, sourceUserId, sourcename)
    end
end)

RefreshDispute()