-- this module describe the group/permission system
-- group functions are used on connected players only
-- multiple groups can be set to the same player, but the gtype config option can be used to set some groups as unique
-- api
local cfg = module("cfg/groups")
local groups = cfg.groups

-- get groups keys of a connected user
function VICE.getUserGroups(user_id)
    local data = VICE.getUserDataTable(user_id)
    if data then
        if data.groups == nil then
            data.groups = {} -- init groups
        end

        return data.groups
    else
        return {}
    end
end

-- add a group to a connected user
function VICE.addUserGroup(user_id, group)
    if not VICE.hasGroup(user_id, group) then  --
        local user_groups = VICE.getUserGroups(user_id)
        local ngroup = groups[group]
        if ngroup then
            if ngroup._config and ngroup._config.gtype then
                -- copy group list to prevent iteration while removing
                local _user_groups = {}
                for k, v in pairs(user_groups) do
                    _user_groups[k] = v
                end

                for k, v in pairs(_user_groups) do -- remove all groups with the same gtype
                    local kgroup = groups[k]
                    if kgroup and kgroup._config and ngroup._config and kgroup._config.gtype == ngroup._config.gtype then
                        VICE.removeUserGroup(user_id, k)
                    end
                end
            end

            -- add group
            user_groups[group] = true
            local player = VICE.getUserSource(user_id)
            if ngroup._config and ngroup._config.onjoin and player then
                ngroup._config.onjoin(player) -- call join callback
            end

            -- trigger join event
            local gtype = nil
            if ngroup._config then
                gtype = ngroup._config.gtype
            end
            TriggerEvent("VICE:playerJoinGroup", user_id, group, gtype)
        end
    end
end

-- get user group by type
-- return group name or an empty string
function VICE.getUserGroupByType(user_id, gtype)
    local user_groups = VICE.getUserGroups(user_id)
    for k, v in pairs(user_groups) do
        local kgroup = groups[k]
        if kgroup then
            if kgroup._config and kgroup._config.gtype and kgroup._config.gtype == gtype then
                return k
            end
        end
    end

    return ""
end

-- return list of connected users by group
function VICE.getUsersByGroup(group)
    local users = {}

    for k, v in pairs(VICE.rusers) do
        if VICE.hasGroup(tonumber(k), group) then
            table.insert(users, tonumber(k))
        end
    end

    return users
end

-- return list of connected users by permission
function VICE.getUsersByPermission(perm)
    local users = {}

    for k, v in pairs(VICE.rusers) do
        if VICE.hasPermission(tonumber(k), perm) then
            table.insert(users, tonumber(k))
        end
    end

    return users
end

-- remove a group from a connected user
function VICE.removeUserGroup(user_id, group)
    local user_groups = VICE.getUserGroups(user_id)
    local groupdef = groups[group]
    if groupdef and groupdef._config and groupdef._config.onleave then
        local source = VICE.getUserSource(user_id)
        if source then
            groupdef._config.onleave(source) -- call leave callback
        end
    end

    -- trigger leave event
    local gtype = nil
    if groupdef._config then
        gtype = groupdef._config.gtype
    end
    TriggerEvent("VICE:playerLeaveGroup", user_id, group, gtype)

    user_groups[group] = nil -- remove reference
end

-- check if the user has a specific group
function VICE.hasGroup(user_id, group)
    local user_groups = VICE.getUserGroups(user_id)
    return (user_groups[group] ~= nil)
end

-- check if the user has a specific permission
-- check if the user has a specific permission
function VICE.hasPermission(user_id, perm)
    local user_groups = VICE.getUserGroups(user_id)
    local fchar = string.sub(perm, 1, 1)

    if fchar == "@" then -- special aptitude permission
        local _perm = string.sub(perm, 2, string.len(perm))
        local parts = splitString(_perm, ".")
        if #parts == 3 then -- decompose group.aptitude.operator
            local group = parts[1]
            local aptitude = parts[2]
            local op = parts[3]

            local avice = math.floor(VICE.expToLevel(VICE.getExp(user_id, group, aptitude)))

            local fop = string.sub(op, 1, 1)
            if fop == "<" then -- less (group.aptitude.<x)
                local vice = parseInt(string.sub(op, 2, string.len(op)))
                if avice < vice then
                    return true
                end
            elseif fop == ">" then -- greater (group.aptitude.>x)
                local vice = parseInt(string.sub(op, 2, string.len(op)))
                if avice > vice then
                    return true
                end
            else -- equal (group.aptitude.x)
                local vice = parseInt(string.sub(op, 1, string.len(op)))
                if avice == vice then
                    return true
                end
            end
        end
    elseif fchar == "#" then -- special item permission
        local _perm = string.sub(perm, 2, string.len(perm))
        local parts = splitString(_perm, ".")
        if #parts == 2 then -- decompose item.operator
            local item = parts[1]
            local op = parts[2]

            local amount = VICE.getInventoryItemAmount(user_id, item)

            local fop = string.sub(op, 1, 1)
            if fop == "<" then -- less (item.<x)
                local n = parseInt(string.sub(op, 2, string.len(op)))
                if amount < n then
                    return true
                end
            elseif fop == ">" then -- greater (item.>x)
                local n = parseInt(string.sub(op, 2, string.len(op)))
                if amount > n then
                    return true
                end
            else -- equal (item.x)
                local n = parseInt(string.sub(op, 1, string.len(op)))
                if amount == n then
                    return true
                end
            end
        end
    else -- regular plain permission
        -- precheck negative permission
        local nperm = "-" .. perm
        for k, v in pairs(user_groups) do
            if v then -- prevent issues with deleted entry
                local group = groups[k]
                if group then
                    for l, w in pairs(group) do -- for each group permission
                        if l ~= "_config" and w == nperm then
                            return false
                        end
                    end
                end
            end
        end

        -- check if the permission exists
        for k, v in pairs(user_groups) do
            if v then -- prevent issues with deleted entry
                local group = groups[k]
                if group then
                    for l, w in pairs(group) do -- for each group permission
                        if l ~= "_config" and w == perm then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

-- check if the user has a specific list of permissions (all of them)
function VICE.hasPermissions(user_id, perms)
    for k, v in pairs(perms) do
        if not VICE.hasPermission(user_id, v) then
            return false
        end
    end

    return true
end

exports('hasPermission', function(source, perm)
    return VICE.hasPermission(VICE.getUserId(source), perm)
end)

RegisterServerEvent("VICE:CheckFounderGroup")
AddEventHandler("VICE:CheckFounderGroup", function(defaultWeight)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, "Founder") then
        TriggerClientEvent("VICE:SetInventoryWeight", source, 1000)
    else
        TriggerClientEvent("VICE:SetInventoryWeight", source, defaultWeight)
    end
end)