RegisterServerEvent("VICE:AChat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = VICE.getUserId(source)   
    local message = args
    local name = VICE.getPlayerName(user_id)

    if VICE.hasPermission(user_id, "admin.tickets") then
        VICE.sendDCLog('staff', "VICE Chat Logs", "```"..message.."```".."\n> Admin Name: **"..name.."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **"..source.."**")
        for k, v in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(k, 'admin.tickets') then
                TriggerClientEvent('chatMessage', v, "^3Admin Chat | " .. name..": " , { 128, 128, 128 }, message, "ooc", "Admin")
            end
        end
    end
end)
RegisterCommand("a", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:AChat", source, message)
end)
RegisterServerEvent("VICE:PoliceChat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = VICE.getUserId(source)   
    local message = args
    if VICE.hasPermission(user_id, "police.armoury") then
        local callsign = ""
        if getCallsign('Police', source, user_id, 'Police') then
            callsign = "["..getCallsign('Police', source, user_id, 'Police').."]"
        end
        local playerName =  "^4Police Chat | "..callsign.." "..VICE.getPlayerName(user_id)..": "
        for k, v in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(k, 'police.armoury') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "Police")
            end
        end
    end
end)

RegisterCommand("p", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:PoliceChat", source, message)
end)
RegisterCommand("n", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:Nchat", source, message)
end)

RegisterCommand("g", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:GangChat", source, message)
end)
RegisterCommand("h", function(source,args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = VICE.getUserId(source)   
    local message = table.concat(args, " ")
    if VICE.hasPermission(user_id, "hmp.menu") or VICE.hasPermission(k, 'police.armoury') then
        local callsign = ""
        if getCallsign('HMP', source, user_id, 'HMP') then
            callsign = "["..getCallsign('HMP', source, user_id, 'HMP').."]"
        end
        local playerName =  "^4HMP Chat | "..callsign.." "..VICE.getPlayerName(user_id)..": "
        for k, v in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(k, 'hmp.menu') or VICE.hasPermission(k, 'police.armoury') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "HMP")
            end
        end
    end
end)

RegisterServerEvent("VICE:Nchat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = VICE.getUserId(source)   
    local message = args
    if VICE.hasPermission(user_id, "nhs.menu") then
        local playerName =  "^2NHS Chat | "..VICE.getPlayerName(user_id)..": "
        for k, v in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(k, 'nhs.menu') then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "NHS")
            end
        end
    end
end)
RegisterCommand("n", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:Nchat", source, message)
end)

RegisterServerEvent("VICE:Fchat", function(source, args, rawCommand)
    if #args <= 0 then return end
    local source = source
    local user_id = VICE.getUserId(source)   
    local message = args
    if VICE.hasPermission(user_id, "nhs.menu") or VICE.hasPermission(user_id, "hmp.menu") or VICE.hasPermission(user_id, "lfb.menu") or VICE.hasPermission(user_id, "police.armoury") then
        local playerName =  "^2Faction's Chat | "..VICE.getPlayerName(user_id)..": "
        for k, v in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(user_id, "nhs.menu") or VICE.hasPermission(user_id, "hmp.menu") or VICE.hasPermission(user_id, "lfb.menu") or VICE.hasPermission(user_id, "police.armoury") then
                TriggerClientEvent('chatMessage', v, playerName , { 128, 128, 128 }, message, "ooc", "Faction")
            end
        end
    end
end)

RegisterCommand("f", function(source, args)
    local message = table.concat(args, " ")
    TriggerEvent("VICE:Fchat", source, message)
end)

RegisterServerEvent("VICE:GangChat", function(source, message)
    local source = source
    local user_id = VICE.getUserId(source)   
    local msg = message
    local senderName = VICE.getPlayerName(user_id)

    if VICE.hasGroup(user_id,"Gang") then
        local gang = exports['vice']:executeSync('SELECT gangname FROM vice_user_gangs WHERE user_id = @user_id', {user_id = user_id})[1].gangname
        if gang then
            exports["vice"]:execute("SELECT * FROM vice_user_gangs WHERE gangname = @gangname", {gangname = gang},function(ganginfo)
                for A,B in pairs(ganginfo) do
                    local playersource = VICE.getUserSource(B.user_id)
                    if playersource then
                        TriggerClientEvent('chatMessage',playersource,"^2[" .. B.gangname .. " Chat] " .. senderName ..": ",{ 128, 128, 128 },msg,"ooc", "Gang")
                    end
                end
                VICE.sendDCLog('gang', "VICE Chat Logs", "```"..msg.."```".."\n> Player Name: **"..senderName.."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
            end)
        end
    end
end)

-- local hour = 1800 -- Changed cooldown to 30 minutes (30 * 60 seconds)

-- RegisterNetEvent('VICE:redeemKit')
-- AddEventHandler('VICE:redeemKit', function(kitCommand)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if user_id then
--         local current_time = os.time()
--         exports['vice']:execute('SELECT last_kit_usage FROM vice_users WHERE id = @id', { id = user_id }, function(kitRows)
--             if kitRows[1] then
--                 local last_kit_usage = kitRows[1].last_kit_usage or 0
--                 if current_time - last_kit_usage >= hour or VICE.hasGroup(user_id, "Founder") then
--                     exports['vice']:execute('UPDATE vice_users SET last_kit_usage = @current_time WHERE id = @id', { current_time = current_time, id = user_id })
                    
--                     if kitCommand == "vicekit" then
--                         --VICEclient.giveWeapons(source, {{["WEAPON_VICETTTAXESMG"] = {ammo = 250}}, false, globalpasskey})
--                         VICEclient.giveWeapons(source, {{["WEAPON_MOSINCMG"] = {ammo = 250}}, false, globalpasskey})
--                         VICEclient.setArmour(source, {100, true})
--                         TriggerClientEvent('VICE:kitResponse', source, "~g~Redeem'd VICE Kit")
--                         VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit Redeemed: **VICE Kit**\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--                     elseif kitCommand == "mosinkit" then
--                         VICEclient.giveWeapons(source, {{["WEAPON_MOSINCMG"] = {ammo = 250}}, false, globalpasskey})
--                         VICEclient.setArmour(source, {100, true})
--                         TriggerClientEvent('VICE:kitResponse', source, "~g~Redeem'd Mosin Kit")
--                         VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit Redeemed: **Mosin Kit**\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--                     elseif kitCommand == "sniperkit" then
--                         VICEclient.giveWeapons(source, {{["WEAPON_SVDCMG"] = {ammo = 250}}, false, globalpasskey})
--                         VICEclient.setArmour(source, {100, true})
--                         TriggerClientEvent('VICE:kitResponse', source, "~g~Redeem'd Sniper Kit")
--                         VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit Redeemed: **Sniper Kit**\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--                     elseif kitCommand == "smgkit" then
--                         VICEclient.giveWeapons(source, {{["WEAPON_VICETTTAXESMG"] = {ammo = 250}}, false, globalpasskey})
--                         VICEclient.setArmour(source, {100, true})
--                         TriggerClientEvent('VICE:kitResponse', source, "~g~Redeem'd SMG Kit")
--                         VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit Redeemed: **SMG Kit**\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--                     end
--                 else
--                     local remaining_time = hour - (current_time - last_kit_usage)
--                     TriggerClientEvent('VICE:kitResponse', source, "~r~You can only redeem kits every 30 minutes. Please wait " .. math.ceil(remaining_time / 60) .. " minutes.")
--                     VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit cooldown: **" .. math.ceil(remaining_time / 60) .. " minutes** \n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--                 end
--             else
--                 TriggerClientEvent('VICE:kitResponse', source, "~r~Error retrieving kit data")
--                 VICE.sendDCLog('kit-redeem', "VICE Kit Logs", "> Kit Error\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
--             end
--         end)
--     end
-- end)