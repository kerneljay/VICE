local chatCooldown = {}
local lastmsg = nil
local lastMessage = {}
local blockedWords = {
	"nigger",
	"nigga",
	"wog",
	"coon",
	"paki",
	"faggot",
	"anal",
	"kys",
	"homosexual",
	"lesbian",
	"suicide",
	"negro",
	"queef",
	"queer",
	"terrorist",
	"wanker",
	"n1gger",
	"f4ggot",
	"n0nce",
	"d1ck",
	"h0m0",
	"n1gg3r",
	"h0m0s3xual",
	"nazi",
	"hitler",
	"fag",
	"fa5",
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3000)
		for k, v in pairs(chatCooldown) do
			chatCooldown[k] = nil
		end
	end
end)

RegisterCommand("anon", function(source, args)
	local message = table.concat(args, " ")
	TriggerEvent("VICE:Anon", source, message)
end)

--Dispatch Message
RegisterServerEvent("VICE:Anon", function(source, args)
	local source = source
	local message = args
	local user_id = VICE.getUserId(source)
	local name = VICE.getPlayerName(user_id)
	if message == "" then
		return
	end
	if name then
		for word in pairs(blockedWords) do
			if (string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(message:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(blockedWords[word])) then
				TriggerClientEvent('VICE:chatFilterScaleform', source, 10, 'That word is not allowed.', name, user_id)
				VICE.sendDCLog('filtered-message', 'VICE Banned Words Logs',
					"Filtered Message!\n```" ..
					message .. "```\n> Player Name: **" .. name .. "**\n> Player PermID: **" .. user_id .. "**")
				CancelEvent()
				return
			end
		end
		VICE.sendDCLog('anon', "VICE Chat Logs",
			"```" ..
			message ..
			"```" ..
			"\n> Player Name: **" ..
			VICE.getPlayerName(user_id) .. "**\n> Player PermID: **" .. user_id ..
			"**\n> Player TempID: **" .. source .. "**")
		TriggerClientEvent('chatMessage', -1, "^4Global @^1Anonymous: ", { 128, 128, 128 }, message, "ooc", "Anonymous")
	end
end)

function VICE.ooc(source, args, raw)
	if #args <= 0 then
		return
	end
	local source = source
	local message = args
	local user_id = VICE.getUserId(source)
	local name = VICE.getPlayerName(user_id)
	if lastMessage[source] and lastMessage[source] == message then
		TriggerClientEvent('chatMessage', source, "", { 128, 128, 128 },
			"^1" .. VICE.getPlayerName(user_id) .. " ^3Sending duplicate messages is forbidden.^0", "alert", "OOC")
		return
	end
	if not chatCooldown[source] then
		for word in pairs(blockedWords) do
			if (string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(args:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(blockedWords[word])) then
				TriggerClientEvent('VICE:chatFilterScaleform', source, 10, 'That word is not allowed.', name, user_id)
				VICE.sendDCLog('filtered-message', 'VICE Banned Words Logs',
					"Filtered Message!\n```" ..
					message .. "```\n> Player Name: **" .. name .. "**\n> Player PermID: **" .. user_id .. "**")
				CancelEvent()
				return
			end
		end
		if VICE.hasGroup(user_id, "Founder") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^8 Founder ^7" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
		elseif VICE.hasGroup(user_id, "Lead Developer") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^3 Lead Developer ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
		elseif VICE.hasGroup(user_id, "Developer") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^4 Developer ^7" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
		elseif VICE.hasGroup(user_id, "Community Manager") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^1 Community Manager ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 },
				message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Staff Manager") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^6 Staff Manager ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Head Administrator") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^3 Head Administrator ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 },
				message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Senior Administrator") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^3 Senior Administrator ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 },
				message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Administrator") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^4 Administrator ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Senior Moderator") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^2 Senior Moderator ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Moderator") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7^r |^2 Moderator ^7" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Support Team") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^2 Support Team ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Trial Staff") then
			TriggerClientEvent('chatMessage', -1,
				"^7OOC ^7^r |^5 Trial Staff ^7" .. VICE.getPlayerName(user_id) .. " : ", { 128, 128, 128 }, message,
				"ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Baller") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^3" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Rainmaker") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^4" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Kingpin") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^1" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Supreme") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^5" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Premium") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^6" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "Supporter") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^2" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		elseif VICE.hasGroup(user_id, "B") then
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^2" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		else
			TriggerClientEvent('chatMessage', -1, "^7OOC ^7 | ^7" .. VICE.getPlayerName(user_id) .. " : ",
				{ 128, 128, 128 }, message, "ooc", "OOC")
			chatCooldown[source] = true
		end
		VICE.sendDCLog('chat-logs', "VICE Chat Logs",
			"```" ..
			message ..
			"```" ..
			"\n> Player Name: **" ..
			VICE.getPlayerName(user_id) .. "**\n> Player PermID: **" .. user_id ..
			"**\n> Player TempID: **" .. source .. "**")
	else
		TriggerClientEvent('chatMessage', source, "^1[VICE]", { 128, 128, 128 }, " Chat Spam | Retry in 3 Seconds",
			"alert", "OOC")
		chatCooldown[source] = true
		lastMessage[source] = message
	end
end

RegisterNetEvent("VICE:ooc")
AddEventHandler("VICE:ooc", function(args)
	local src = source
	VICE.ooc(src, args)
end)

RegisterCommand("ooc", function(source, args, raw)
	local message = table.concat(args, " ")
	VICE.ooc(source, message)
end)

RegisterCommand("/", function(source, args, raw)
	local message = table.concat(args, " ")
	message = message:sub(1)
	VICE.ooc(source, message)
end)

RegisterCommand('cc', function(source, args, rawCommand)
	local user_id = VICE.getUserId(source)
	if VICE.hasPermission(user_id, 'admin.ban') then
		TriggerClientEvent('chat:clear', -1)
	end
end, false)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}; i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end




RegisterCommand('resetbucket', function(source, args, rawCommand)
	local source = source
	local user_id = VICE.getUserId(source)
	if VICE.hasPermission(user_id,'group.remove.founder') then
		local players = VICE.getUsers()
		for k, v in pairs(players) do
			SetPlayerRoutingBucket(v,0)
			VICE.notify(v, { '~g~You are now in bucket: 0',})
		end
	end
end)

RegisterCommand('platforall', function(source, args, rawCommand)
	local source = source
	local user_id = VICE.getUserId(source)
	local plathours = args[1]
	if args and args[1] then 
	if VICE.hasPermission(user_id,'group.remove.founder') then
		local players = VICE.getUsers()
		for k, v in pairs(players) do
			MySQL.execute("subscription/set_plathours", {user_id = k, plathours = plathours})
			 VICE.notify(v, { string.format("~g~You received %d hours of plat!", plathours) })
		end
	end
else
	TriggerEvent("chatMessage","^1[VICE]^1  ",{ 128, 128, 128 }, "Please specify an arg eg: /platforall [amountofplatinhours]", "alert")
end
end)



RegisterCommand('beta', function(source)
	local source = source
    local user_id = VICE.getUserId(source)
    

    local hasSupporter = VICE.hasGroup(user_id, "Supporter")
    local hasHighroller = VICE.hasGroup(user_id, "Highroller")

    if hasSupporter and hasHighroller then
        VICE.notify(source, { "~r~You already claimed your beta rewards." })
        return
    end

    if not hasSupporter then
        VICE.addUserGroup(user_id, "Supporter")
        VICE.notify(source, { "~g~You have received the Supporter rank!" })
    end

    if not hasHighroller then
        VICE.addUserGroup(user_id, "Highroller")
        VICE.notify(source, { "~g~You have received the Highroller license!" })
    end
end)