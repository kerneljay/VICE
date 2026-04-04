function discordbottoken()
    local key = GetConvar("bot_token", "default_")
    return key
end

local cfg = module("cfg/discordroles")
local FormattedToken = "Bot " .. discordbottoken()
local Discord_Sources = {} -- Discord ID: (User Source, User ID)
local roleCache = {} -- Table to store cached role information

local error_codes_defined = {
	[200] = 'OK - The request was completed successfully..!',
	[400] = "Error - The request was improperly formatted, or the server couldn't understand it..!",
	[401] = 'Error - The Authorization header was missing or invalid..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[403] = 'Error - The Authorization token you passed did not have permission to the resource..! Your Discord Token is probably wrong or does not have correct permissions attributed to it.',
	[404] = "Error - The resource at the location specified doesn't exist.",
	[429] = 'Error - Too many requests, you hit the Discord rate limit. https://discord.com/developers/docs/topics/rate-limits',
	[502] = 'Error - Discord API may be down?...'
}

local function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/" .. endpoint, function(errorCode, resultData, resultHeaders)
		data = {data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and jsondata or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while not data do
        Citizen.Wait(0)
    end
	
    return data
end

local function GetIdentifier(source, id_type)
    if type(id_type) ~= "string" then
		return print('Invalid usage')
	end

    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, id_type) then
            return identifier
        end
    end
    return nil
end

local function Get_Client_Discord_ID(source)
    local result = exports['vice']:executeSync("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", {user_id = VICE.getUserId(source)})

    if result and result[1] then
        return result[1].discord_id
	elseif source and VICE.getUserId(source) then
        print("No results found for user_id: " .. VICE.getUserId(source))
        return nil
    end
	return nil
end


local function Client_Has_Role(roles_table, role_id)
	for _, table_role_id in pairs(roles_table) do
		if tostring(table_role_id) == tostring(role_id) or tostring(_) == tostring(role_id) then
			return true
		end
	end
	return false
end

local function Get_Client_Has_Roles(guild_roles, client_roles)
	local has_roles = {}
	local does_not_have_roles = {}

	for role_name, guild_role_id in pairs(guild_roles) do
		local found_role = false
		for _, client_role_id in pairs(client_roles) do
			if tostring(guild_role_id) == tostring(client_role_id) then
				found_role = true
				table.insert(has_roles, guild_role_id)
				break
			end
		end
		
		if not found_role then
			table.insert(does_not_have_roles, guild_role_id)
		end
	end

	return has_roles, does_not_have_roles
end

local recent_role_cache = {}
local function GetDiscordRoles(guild_id, user_discord_id)
	if cfg.CacheDiscordRoles and recent_role_cache[user_discord_id] and recent_role_cache[user_discord_id][guild_id] then
		return recent_role_cache[user_discord_id][guild_id]
	end

	local endpoint = ("guilds/%s/members/%s"):format(guild_id, user_discord_id)
	local member = DiscordRequest("GET", endpoint, {})
	if member.code == 200 then
		local data = json.decode(member.data)
		local roles = data.roles
		local found = true
		if cfg.CacheDiscordRoles then
			recent_role_cache[user_discord_id] = recent_role_cache[user_discord_id] or {}
			recent_role_cache[user_discord_id][guild_id] = roles
			Citizen.SetTimeout(((cfg.CacheDiscordRolesTime or 60) * 1000), function()
				recent_role_cache[user_discord_id][guild_id] = nil 
			end)
		end
		return roles
	else
		return false
	end
	return false
end

local function Get_Discord_Name(guild_id, discord_id)
    local endpoint = ("guilds/%s/members/%s"):format(guild_id, discord_id)
    local member = DiscordRequest("GET", endpoint, {})
    if member.code == 200 then
        local data = json.decode(member.data)
        local username = data.user.username 
        return username
    else
        return nil
    end
end

dscnames = {}

-- Example Where it does VICEclient.spawnAnim do this below
-- VICEclient.setDiscordNames(source,{dscnames})

function VICE.GetDiscordName(user_id) -- Call this when player is connecting (example after it gets userid)
    local discord_id = exports["vice"]:executeSync("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", {user_id = user_id})[1].discord_id
	while discord_id == nil do
        Wait(100)
        discord_id = exports["vice"]:executeSync("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", {user_id = user_id})[1].discord_id
    end
	local nickname = Get_Guild_Nickname(1458466924974313527, discord_id)
    if nickname then
        dscnames[user_id] = nickname
        for k, v in pairs(VICE.getUsers()) do -- Guessing this is passing name to newer users
            VICEclient.addDiscordNames(v, {user_id, nickname})
        end
	else
		print("Error: Failed to get nickname for user_id: " .. user_id)
    end
end

function VICE.getPlayerName(user_id) -- if any is source then just do VICE.getUserId(source)
    if dscnames[user_id] then
        return dscnames[user_id]
    else
        local result = exports["vice"]:executeSync("SELECT username FROM `vice_users` WHERE id = @user_id", {user_id = user_id})
        if result and result[1] and result[1].username then
            return result[1].username
        else
            return "Unknown"
        end
    end
end

function getUserFromIdk(source)
	return exports['vice']:executeSync("SELECT user_id FROM `vice_verification` WHERE discord_id = @discord_id", {discord_id = Get_Client_Discord_ID(source)})[1].user_id
end

exports('GetDiscordName', function(source) -- dont know why its passing source but 
    return dscnames[VICE.getUserId(source)]
end)

-- exports('getUserId', function(source) -- dont know why its passing source but 
-- 	return exports['vice']:executeSync("SELECT user_id FROM `vice_verification` WHERE discord_id = @discord_id", {discord_id = Get_Client_Discord_ID(source)})[1].user_id
-- end)

local function Modify_Client_Roles(guild_name, discord_id, user_id)
	local discord_roles = GetDiscordRoles(cfg.Guilds[guild_name], discord_id)
	if discord_roles then
		local has_roles, does_not_have_roles = Get_Client_Has_Roles(cfg.Guild_Roles[guild_name], discord_roles)
		for _, role_id in pairs(does_not_have_roles) do
			for k,v in pairs(cfg.Guild_Roles[guild_name]) do
                if v == role_id and VICE.hasGroup(user_id, k) then
                    VICE.removeUserGroup(user_id, k)
                end
			end
		end

		for _, role_id in pairs(has_roles) do
            for k,v in pairs(cfg.Guild_Roles[guild_name]) do
                if v == role_id and not VICE.hasGroup(user_id, k) then
                    VICE.addUserGroup(user_id, k)
                end
            end
		end
	end
	VICE.getJobSelectors(VICE.getUserSource(user_id))
end

local tracked = {}
RegisterNetEvent('VICE:getFactionWhitelistedGroups')
AddEventHandler('VICE:getFactionWhitelistedGroups', function()
	local source = source
	VICE.getFactionGroups(source)
end)

function VICE.getFactionGroups(source)
    local source = source
	local fivem_license = GetIdentifier(source, 'license')
	if not tracked[fivem_license] then 
		tracked[fivem_license] = true
	end

	local user_id = VICE.getUserId(source)
	if user_id then
		local discord_id = Get_Client_Discord_ID(source)
		if discord_id then
			Discord_Sources[discord_id] = {user_source = source, user_id = user_id}
			Modify_Client_Roles('Main', discord_id, user_id)
			Modify_Client_Roles('Police', discord_id, user_id)
			Modify_Client_Roles('NHS', discord_id, user_id)
			Modify_Client_Roles('HMP', discord_id, user_id)
            Modify_Client_Roles('LFB', discord_id, user_id)
		end
	end
end

function Get_Guild_Nickname(guild_id, discord_id)
    if not guild_id or not discord_id then return nil end
    
    local endpoint = ("guilds/%s/members/%s"):format(guild_id, discord_id)
    local member = DiscordRequest("GET", endpoint, {})
    if member.code == 200 then
        local data = json.decode(member.data)
        if data and data.user then
            return data.nick or data.user.global_name or data.user.username
        end
    end
    return nil
end

local function Get_Discord_Avatar(discord_id)
    local endpoint = "users/" .. discord_id
    local user = DiscordRequest("GET", endpoint, {})
    if user.code == 200 then
        local data = json.decode(user.data)
        if data.avatar then
            local avatarURL = "https://cdn.discordapp.com/avatars/" .. discord_id .. "/" .. data.avatar .. ".png"
            return avatarURL
        end
    end
    return nil
end

exports('Get_Discord_Avatar', function(source)
	return Get_Discord_Avatar(source)
end)

exports('Get_Client_Discord_ID', function(source)
	return Get_Client_Discord_ID(source)
end)

exports('Get_Discord_Name', function(source)
	return Get_Discord_Name(source)
end)

exports('Get_Guild_Nickname', function(guild_id, discord_id)
	return Get_Guild_Nickname(guild_id, discord_id)
end)

exports('Get_Guilds', function()
	return cfg.Guilds
end)

exports('Get_User_Source', function(user_discord_id)
	return Discord_Sources[user_discord_id]
end)

local function Get_Guild_Status(guild)
	if guild.code == 200 then
		local data = json.decode(guild.data)
		--print(("[VICE] Connection to Guild: %s (^2%s^0)"):format(data.name, data.id))
  	else
		print(("An error occured, please check your config and ensure everything is correct. Error: %s"):format(guild.data and json.decode(guild.data) or guild.code))
  	end
end

Citizen.CreateThread(function()
	if cfg.Multiguild then 
		for _, guildID in pairs(cfg.Guilds) do
			local guild = DiscordRequest("GET", "guilds/" .. guildID, {})
			Get_Guild_Status(guild)
		end
	else
		local guild = DiscordRequest("GET", "guilds/" .. cfg.Guild_ID, {})
		Get_Guild_Status(guild)
	end
	print("^3VICE: Guilds Connected ^7")
end)

function VICE.checkForRole(user_id, role_id)
    local result = false
    local discord_id = exports['vice']:executeSync("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", {user_id = user_id})[1].discord_id
    if discord_id then
        local endpoint = ("guilds/%s/members/%s"):format(cfg.Guild_ID, discord_id)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data then
                result = Client_Has_Role(data.roles, role_id)
            else
                print("[VICE] Error: Failed to decode member data.")
            end
        else
            print("[VICE] Error: Discord request failed with code " .. member.code)
        end
    else
        print("[VICE] Error: Discord ID not found for user ID " .. user_id)
    end

    return result
end

AddEventHandler('playerConnecting', function(_, _, deferrals)
    local source = source
    local user_id = VICE.getUserId(source)
    while user_id == nil do
        Wait(100)
        user_id = VICE.getUserId(source)
    end
    local discordname = VICE.getPlayerName(user_id)
	local discord_id = Get_Client_Discord_ID(source)
    local discordpfp =  Get_Discord_Avatar(discord_id)
    local numplayers = #GetPlayers() + 1
    local maxplayers = GetConvar("sv_maxclients", "32")
    local online = numplayers.."/"..maxplayers
    local discordtable = {
        response = {
            players = {
                {
                    discordname = discordname,
                    discordpfp = discordpfp,
                    online = online,
                    user_id = "ID:"..user_id
                }
            }
        }
    }
    discordtable = json.encode(discordtable)
    deferrals.handover({
        json = discordtable,
        viceloading = "discord"
    })
end)

