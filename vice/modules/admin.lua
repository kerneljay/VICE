RegisterServerEvent('VICE:OpenSettings')
AddEventHandler('VICE:OpenSettings', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        if VICE.hasPermission(user_id, "admin.tickets") then
            TriggerClientEvent("VICE:OpenAdminMenu", source, true)
        else
            TriggerClientEvent("VICE:OpenSettingsMenu", source, false)
        end
    end
end)

RegisterNetEvent("VICE:sendNoclipData")
AddEventHandler("VICE:sendNoclipData", function(startCoords, endCoords)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        local formattedDistance = getMoneyStringFormatted(math.floor(#(startCoords-endCoords))).."m"
        VICE.sendDCLog("noclip","VICE Noclip","No Clip Distance\n\n> Admin Name: "..VICE.getPlayerName(user_id).."\n> Admin TempID: "..source.."\n> Admin PermID: "..user_id.."\n> Distance Traveled: "..formattedDistance.."\n> Start Coords: "..startCoords.."\n> End Coords: "..endCoords)
    -- else
    --     VICE.ACBan(15,user_id,"sendNoclipData") 
    end
end)

-- RegisterCommand("gethours", function(source, args)
--     local v = source
--     local D = math.ceil(VICE.getUserDataTable(v).PlayerTime/60) or 0
--     if VICE.hasGroup(user_id,"Founder") then
--         VICE.notify(v, "~g~You currently have ~b~"..D.." ~g~hours.")
--     end
-- end)





local warningCooldowns = {}
local currentTime = os.time()
local formattedTime = os.date("%Y-%m-%d %H:%M:%S", currentTime)
local warningCooldownSeconds = 15

RegisterCommand('staffdm', function(source, args)
    local source = source
    local user_id = VICE.getUserId(source)
    local their_id = tonumber(args[1])
    local their_source = VICE.getUserSource(their_id)
    local adminName = VICE.getPlayerName(user_id)
    if warningCooldowns[user_id] and warningCooldowns[user_id] > os.time() then
        VICE.notify(source, '~r~Staff DM is on cooldown.')
        return
    end
    if their_source == nil then return VICE.notify(source, '~r~User is not online.') end
    VICE.prompt(source, 'Please Enter Message:', '', function(source,msg)
        if msg == '' then return VICE.notify(source, '~r~Invalid Message') end
        if VICE.hasPermission(user_id, "admin.tickets") then
            TriggerClientEvent('VICE:StaffDMMessage', their_source, adminName, msg)
            VICE.notify(source, '~g~Message sent')
            VICE.sendDCLog('staff-dm', "VICE Staff DM Logs", "> Admin Name: **"..adminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Target ID: **"..their_id.."**\n> Target TempID: **"..their_source.."**\n> Message: **"..msg.."**")
            warningCooldowns[user_id] = os.time() + warningCooldownSeconds 
        else
            VICE.notify(source, '~r~You do not have the necessary permissions to send a dm.')
        end
    end)
end)

RegisterNetEvent("VICE:TriggerSendWarning")
AddEventHandler("VICE:TriggerSendWarning", function(target, warningMessage)
    local source = source
    local user_id = VICE.getUserId(source)
    local adminName = VICE.getPlayerName(user_id)
    local tuser_id = VICE.getUserId(target)

    if warningCooldowns[user_id] and warningCooldowns[user_id] > os.time() then
        VICE.notify(source, '~r~Warning is on cooldown.')
        return
    end

    if VICE.hasPermission(user_id, "admin.tickets") then
        TriggerClientEvent('VICE:SendWarning', target, warningMessage)

        local query = "INSERT INTO vice_staff_warnings (admin_id, admin_name, target_id, warning_message, timestamp) VALUES (@admin_id, @admin_name, @target_id, @warning_message, @timestamp)"
        local params = {
            ["@admin_id"] = user_id,
            ["@admin_name"] = adminName,
            ["@target_id"] = tuser_id,
            ["@warning_message"] = warningMessage,
            ["@timestamp"] = formattedTime
        }

        exports["vice"]:executeSync(query, params, function()
            VICE.sendDCLog('warning', "VICE Warning Logs", "> Admin Name: **"..adminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Target ID: **"..target.."**\n> Warning Message: **"..warningMessage.."**\n> Timestamp: **"..formattedTime.."**")
        end)
        warningCooldowns[user_id] = currentTime + warningCooldownSeconds 
    else
        VICE.notify(source, '~r~You do not have the necessary permissions to send a warning.')
    end
end)

RegisterCommand("sethours", function(source, args) 
    if source == 0 then 
        local data = VICE.getUserDataTable(tonumber(args[1]))
        data.PlayerTime = tonumber(args[2])*60
        print(VICE.getPlayerName(tonumber(args[1])).."'s hours have been set to: "..tonumber(args[2]))
    end  
end)

RegisterServerEvent("VICE:GetGroups")
AddEventHandler("VICE:GetGroups",function(perm)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("VICE:GotGroups", source, VICE.getUserGroups(perm))
    end
end)

RegisterServerEvent("VICE:CheckPov")
AddEventHandler("VICE:CheckPov",function(userperm)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        if VICE.hasPermission(userperm, 'pov.list') then
            TriggerClientEvent('VICE:ReturnPov', source, true)
        else
            TriggerClientEvent('VICE:ReturnPov', source, false)
        end
    end
end)
RegisterServerEvent("VICE:CheckShadowLobby")
AddEventHandler("VICE:CheckShadowLobby",function(targetTempId)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        local targetSrc = tonumber(targetTempId)
        if targetSrc and GetPlayerRoutingBucket(targetSrc) == 100 then
            TriggerClientEvent('VICE:ReturnShadowLobby', source, true)
        else
            TriggerClientEvent('VICE:ReturnShadowLobby', source, false)
        end
    end
end)
RegisterServerEvent("wk:fixVehicle")
AddEventHandler("wk:fixVehicle",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent('wk:fixVehicle', source)
        VICE.sendDCLog('staff', "VICE Fix Vehicle Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**")
    end
end)

local spectatingPositions = {}
RegisterServerEvent("VICE:spectatePlayer")
AddEventHandler("VICE:spectatePlayer", function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    local playerssource = VICE.getUserSource(id)
    if VICE.hasPermission(user_id, "admin.spectate") then
        if playerssource then
            spectatingPositions[user_id] = {coords = GetEntityCoords(GetPlayerPed(source)), bucket = GetPlayerRoutingBucket(source)}
            VICE.setBucket(source, GetPlayerRoutingBucket(playerssource))
            TriggerClientEvent("VICE:spectatePlayer", source, playerssource, GetEntityCoords(GetPlayerPed(playerssource)))
            VICE.sendDCLog('spectate', "VICE Spectate Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(id).."**\n> Player PermID: **"..id.."**\n> Player TempID: **"..playerssource.."**")
        else
            VICE.notify(source, "~r~You can't spectate an offline player.")
        end
    end
end)

RegisterServerEvent("VICE:stopSpectatePlayer")
AddEventHandler("VICE:stopSpectatePlayer", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.spectate") then
        TriggerClientEvent("VICE:stopSpectatePlayer",source)
        for k,v in pairs(spectatingPositions) do
            if k == user_id then
                TriggerClientEvent("VICE:stopSpectatePlayer",source,v.coords,v.bucket)
                SetEntityCoords(GetPlayerPed(source),v.coords)
                VICE.setBucket(source, v.bucket)
                spectatingPositions[k] = nil
            end
        end
    end
end)

RegisterServerEvent("VICE:Giveweapon")
AddEventHandler("VICE:Giveweapon",function()
    local source = source
    local user_id = VICE.getUserId(source)
    local weapon = 'WEAPON_'..string.upper(hash)
    if VICE.hasPermission(user_id, "dev.menu") then
        VICE.prompt(source,"Weapon Name:","",function(source,hash) 
            VICEclient.giveWeapons(source, {{[weapon] = {ammo = 250}}, false,globalpasskey})
            VICE.notify(source, "~g~Successfully spawned ~b~"..hash)
            VICE.sendDCLog('spawn-weapon',"VICE Weapon Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Weapon: **" .. weapon)
        end)
    end
end)

RegisterServerEvent("VICE:ForceClockOff")
AddEventHandler("VICE:ForceClockOff", function(player_temp)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_perm = VICE.getUserId(player_temp)
    if VICE.hasPermission(user_id,"admin.tp2waypoint") then
        VICE.removeAllJobs(player_perm)
        VICE.notify(source, '~g~User clocked off')
        VICE.notify(player_temp, '~b~You have been force clocked off.')
        VICE.sendDCLog('force-clock-off',"VICE Faction Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..VICE.getPlayerName(player_perm).."**\n> Players TempID: **"..player_temp.."**\n> Players PermID: **"..player_perm.."**")
        TriggerClientEvent("VICE:jobSelectorCooldown", player_temp, true)
    else
        VICE.ACBan(15,user_id,"Force Clock Off")
    end
end)

RegisterServerEvent("VICE:AddGroup")
AddEventHandler("VICE:AddGroup",function(perm, selgroup)
    local source = source
    local user_id = VICE.getUserId(source)
    local permsource = VICE.getUserSource(perm)
    if VICE.hasPermission(user_id, "group.add") then
        if selgroup == "pov" and not VICE.hasPermission(user_id, "group.add.pov") then
            VICE.notify(source, "You don't have permission to do that")
        else
            VICE.addUserGroup(perm, selgroup)
            local user_groups = VICE.getUserGroups(perm)
            TriggerClientEvent("VICE:GotGroups", source, user_groups)
            VICE.sendDCLog('group',"VICE Group Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..VICE.getPlayerName(perm).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Added**")
        end
    end
end)

RegisterServerEvent("VICE:RemoveGroup")
AddEventHandler("VICE:RemoveGroup",function(perm, selgroup)
    local source = source
    local user_id = VICE.getUserId(source)
    local permsource = VICE.getUserSource(perm)
    if VICE.hasPermission(user_id, "group.remove") then
        if selgroup == "Founder" and not VICE.hasPermission(user_id, "group.remove.founder") then
            VICE.notify(source, "You don't have permission to do that") 
            elseif selgroup == "Developer" and not VICE.hasPermission(user_id, "group.remove.developer") then
                VICE.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Staff Manager" and not VICE.hasPermission(user_id, "group.remove.staffmanager") then
            VICE.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Community Manager" and not VICE.hasPermission(user_id, "group.remove.commanager") then
            VICE.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Head Administrator" and not VICE.hasPermission(user_id, "group.remove.headadmin") then
            VICE.notify(source, "You don't have permission to do that") 
        elseif selgroup == "Senior Admin" and not VICE.hasPermission(user_id, "group.remove.senioradmin") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "Admin" and not VICE.hasPermission(user_id, "group.remove.administrator") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "Senior Moderator" and not VICE.hasPermission(user_id, "group.remove.srmoderator") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "Moderator" and not VICE.hasPermission(user_id, "group.remove.moderator") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "Support Team" and not VICE.hasPermission(user_id, "group.remove.supportteam") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "Trial Staff" and not VICE.hasPermission(user_id, "group.remove.trial") then
            VICE.notify(source, "You don't have permission to do that")
        elseif selgroup == "pov" and not VICE.hasPermission(user_id, "group.remove.pov") then
            VICE.notify(source, "You don't have permission to do that")
        else
            VICE.removeUserGroup(perm, selgroup)
            local user_groups = VICE.getUserGroups(perm)
            TriggerClientEvent("VICE:GotGroups", source, user_groups)
            VICE.sendDCLog('group',"VICE Group Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..VICE.getPlayerName(perm).."**\n> Players TempID: **"..permsource.."**\n> Players PermID: **"..perm.."**\n> Group: **"..selgroup.."**\n> Type: **Removed**")
        end
    end
end)

local bans = {
    {id = "trolling",name = "1.0 Trolling",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "trollingminor",name = "1.0 Trolling (Minor)",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "metagaming",name = "1.1 Metagaming",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "powergaming",name = "1.2 Power Gaming ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "failrp",name = "1.3 Fail RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rdm", name = "1.4 RDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massrdm",name = "1.4.1 Mass RDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "nrti",name = "1.5 No Reason to Initiate (NRTI) ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "vdm", name = "1.6 VDM",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "massvdm",name = "1.6.1 Mass VDM",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "offlanguageminor",name = "1.7 Offensive Language/Toxicity (Minor)",durations = {2,24,72},bandescription = "1st Offense: 2hr\n2nd Offense: 24hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "offlanguagestandard",name = "1.7 Offensive Language/Toxicity (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "offlanguagesevere",name = "1.7 Offensive Language/Toxicity (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "breakrp",name = "1.8 Breaking Character",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "combatlog",name = "1.9 Combat logging",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatstore",name = "1.10 Combat storing",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "exploitingstandard",name = "1.11 Exploiting (Standard)",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "exploitingsevere",name = "1.11 Exploiting (Severe)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "oogt",name = "1.12 Out of game transactions (OOGT)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "spitereport",name = "1.13 Spite Reporting",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "scamming",name = "1.14 Scamming",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "loans",name = "1.15 Loans",durations = {48,168,-1},bandescription = "1st Offense: 48hr\n2nd Offense: 168hr\n3rd Offense: Permanent",itemchecked = false},
    {id = "wastingadmintime",name = "1.16 Wasting Admin Time",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "ftvl",name = "2.1 Value of Life",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "sexualrp",name = "2.2 Sexual RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "terrorrp",name = "2.3 Terrorist RP",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "impwhitelisted",name = "2.4 Impersonation of Whitelisted Factions",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gtadriving",name = "2.5 GTA Online Driving",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "nlr", name = "2.6 NLR",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr", itemchecked = false},
    {id = "badrp",name = "2.7 Bad RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "kidnapping",name = "2.8 Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "stealingems",name = "3.0 Theft of Emergency Vehicles",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "whitelistabusestandard",name = "3.1 Whitelist Abuse",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "whitelistabusesevere",name = "3.1 Whitelist Abuse",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "copbaiting",name = "3.2 Cop Baiting",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "pdkidnapping",name = "3.3 PD Kidnapping",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "unrealisticrevival",name = "3.4 Unrealistic Revival",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "interjectingrp",name = "3.5 Interjection of RP",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "combatrev",name = "3.6 Combat Reviving",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gangcap",name = "3.7 Gang Cap",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "maxgang",name = "3.8 Max Gang Numbers",durations = {24,72,168},bandescription = "1st Offense: 24hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "gangalliance",name = "3.9 Gang Alliance",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "impgang",name = "3.10 Impersonation of Gangs",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzstealing",name = "4.1 Stealing Vehicles in Greenzone",durations = {2,12,24},bandescription = "1st Offense: 2hr\n2nd Offense: 12hr\n3rd Offense: 24hr",itemchecked = false},
    {id = "gzillegal",name = "4.2 Selling Illegal Items in Greenzone",durations = {12,24,48},bandescription = "1st Offense: 12hr\n2nd Offense: 24hr\n3rd Offense: 48hr",itemchecked = false},
    {id = "gzretretreating",name = "4.3 Greenzone Retreating ",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzhostage",name = "4.5 Taking Hostage into Redzone",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "rzretreating",name = "4.6 Redzone Retreating",durations = {24,48,72},bandescription = "1st Offense: 24hr\n2nd Offense: 48hr\n3rd Offense: 72hr",itemchecked = false},
    {id = "advert",name = "1.1 Advertising",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "bullying",name = "1.2 Bullying",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "impersonationrule",name = "1.3 Impersonation",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "language",name = "1.4 Language",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discrim",name = "1.5 Discrimination ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "attacks",name = "1.6 Malicious Attacks ",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "PIIstandard",name = "1.7 PII (Personally Identifiable Information)(Standard)",durations = {168,-1,-1},bandescription = "1st Offense: 168hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false},
    {id = "PIIsevere",name = "1.7 PII (Personally Identifiable Information)(Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "chargeback",name = "1.8 Chargeback",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "discretion",name = "1.9 Staff Discretion",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false    },
    {id = "cheating",name = "1.10 Cheating",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "banevading",name = "1.11 Ban Evading",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "fivemcheats",name = "1.12 Withholding/Storing FiveM Cheats",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "altaccount",name = "1.13 Multi-Accounting",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "association",name = "1.14 Association with External Modifications",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "pov",name = "1.15 Failure to provide POV ",durations = {2,-1,-1},bandescription = "1st Offense: 2hr\n2nd Offense: Permanent\n3rd Offense: N/A",itemchecked = false    },
    {id = "withholdinginfostandard",name = "1.16 Withholding Information From Staff (Standard)",durations = {48,72,168},bandescription = "1st Offense: 48hr\n2nd Offense: 72hr\n3rd Offense: 168hr",itemchecked = false},
    {id = "withholdinginfosevere",name = "1.16 Withholding Information From Staff (Severe)",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "blackmail",name = "1.17 Blackmailing",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
    {id = "breachterms",name = "1.18 Breach of Management Terms",durations = {-1,-1,-1},bandescription = "1st Offense: Permanent\n2nd Offense: N/A\n3rd Offense: N/A",itemchecked = false},
}
    
   

local PlayerOffenses = {}
local PlayerBanCachedDuration = {}
local defaultBans = {}

RegisterServerEvent("VICE:GenerateBan")
AddEventHandler("VICE:GenerateBan", function(PlayerID, RulesBroken)
    local source = source
    local PlayerCacheBanMessage = {}
    local PermOffense = false
    local separatormsg = {}
    local points = 0
    PlayerBanCachedDuration[PlayerID] = 0
    PlayerOffenses[PlayerID] = {}
    if VICE.hasPermission(VICE.getUserId(source), "admin.tickets") then
        exports['vice']:execute("SELECT * FROM vice_bans_offenses WHERE UserID = @UserID", {UserID = PlayerID}, function(result)
            if #result > 0 then
                points = result[1].points
                PlayerOffenses[PlayerID] = json.decode(result[1].Rules)
                for k,v in pairs(RulesBroken) do
                    for a,b in pairs(bans) do
                        if b.id == k then
                            PlayerOffenses[PlayerID][k] = PlayerOffenses[PlayerID][k] + 1
                            if PlayerOffenses[PlayerID][k] > 3 then
                                PlayerOffenses[PlayerID][k] = 3
                            end
                            PlayerBanCachedDuration[PlayerID] = PlayerBanCachedDuration[PlayerID] + bans[a].durations[PlayerOffenses[PlayerID][k]]
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] ~= -1 then
                                points = points + bans[a].durations[PlayerOffenses[PlayerID][k]]/24
                            end
                            table.insert(PlayerCacheBanMessage, bans[a].name)
                            if bans[a].durations[PlayerOffenses[PlayerID][k]] == -1 then
                                PlayerBanCachedDuration[PlayerID] = -1
                                PermOffense = true
                            end
                            if PlayerOffenses[PlayerID][k] == 1 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~1st Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] == 2 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~2nd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            elseif PlayerOffenses[PlayerID][k] >= 3 then
                                table.insert(separatormsg, bans[a].name ..' ~y~| ~w~3rd Offense ~y~| ~w~'..(PermOffense and "Permanent" or bans[a].durations[PlayerOffenses[PlayerID][k]] .." hrs"))
                            end
                        end
                    end
                end
                if PermOffense then 
                    PlayerBanCachedDuration[PlayerID] = -1
                end
                Wait(100)
                TriggerClientEvent("VICE:ReceiveBanPlayerData", source, PlayerBanCachedDuration[PlayerID], table.concat(PlayerCacheBanMessage, ", "), separatormsg, math.floor(points))
            end
        end)
    end
end)

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    for k,v in pairs(bans) do
        defaultBans[v.id] = 0
    end
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_bans_offenses(UserID,Rules) VALUES(@UserID, @Rules)", {UserID = user_id, Rules = json.encode(defaultBans)})
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_user_notes(user_id) VALUES(@user_id)", {user_id = user_id})
end)

RegisterCommand('refreshwarningpoints', function(source, args) -- for removing points each month
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id == 1 then
        for k,v in pairs(bans) do
            defaultBans[v.id] = 0
        end
        exports["vice"]:executeSync("INSERT IGNORE INTO vice_bans_offenses(UserID,Rules) VALUES(@UserID, @Rules)", {UserID = user_id, Rules = json.encode(defaultBans)})
        exports["vice"]:executeSync("INSERT IGNORE INTO vice_user_notes(user_id) VALUES(@user_id)", {user_id = user_id})
    end
end)

RegisterCommand('removepoints', function(source, args) -- for removing points each month
    local source = source
    if VICE.getUserId(source) == 1 then
        removePoints = tonumber(args[1])
        exports['vice']:execute("UPDATE vice_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE points > 0", {removepoints = removePoints}, function() end)
        VICE.notify(source, '~g~Removed '..removePoints..' points from all users.')
    end
end)

RegisterServerEvent("VICE:BanPlayer")
AddEventHandler("VICE:BanPlayer", function(PlayerID, Duration, BanMessage, BanPoints)
    local source = source
    local AdminPermID = VICE.getUserId(source)
    local AdminName = VICE.getPlayerName(AdminPermID)
    local CurrentTime = os.time()

    if VICE.hasPermission(AdminPermID, 'admin.ban') then
        local PlayerDiscordID = 0
        local PlayerSource = VICE.getUserSource(PlayerID)
        local PlayerName = VICE.getPlayerName(PlayerID) or VICE.GetNameOffline(PlayerID)
        VICE.prompt(source, "Extra Ban Information (Hidden)", "", function(player, Evidence)
            if VICE.hasPermission(AdminPermID, "admin.tickets") then
                if Evidence == "" then
                    VICE.notify(source, "~r~Evidence field was left empty, please fill this in via Discord.")
                    Evidence = "No Evidence Provided"
                end
                local banDuration
                local BanChatMessage
                if Duration == -1 then
                    banDuration = "perm"
                    BanPoints = 0
                    BanChatMessage = "has been permanently banned for "..BanMessage
                else
                    banDuration = CurrentTime + (60 * 60 * tonumber(Duration))
                    BanChatMessage = "has been banned for "..BanMessage.." ("..Duration.."hrs)"
                end
                 if PlayerID == 1  then --or PlayerID == 2
                          VICE.notify(source, "~r~You can not ban a Founder")
                return
                end
                VICE.sendDCLog('banned-player', "VICE Banned Players", "> Admin PermID: **"..AdminPermID.."**\n> Players PermID: **"..PlayerID.."**\n> Ban Duration: **"..Duration.."**\n> Reason: **"..BanMessage.."**\n> Evidence: "..Evidence)
                TriggerClientEvent("chatMessage", -1, "^8", {180, 0, 0}, "^1"..PlayerName .. " ^3"..BanChatMessage, "alert")
                VICE.sendDCLog('ban-player', "VICE Ban Logs", AdminName.. " banned "..PlayerID, "> Admin Name: **"..AdminName.."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..AdminPermID.."**\n> Players PermID: **"..PlayerID.."**\n> Ban Duration: **"..Duration.."**\n> Reason(s): **"..BanMessage.."**")
            -- if PlayerID == 1 then
                --    VICE.notify(PlayerSource, "[BAN]\nName: ".. PlayerName .. "\nPoints: " .. BanPoints)
            -- else
                VICE.notify(source, "~g~Banned User ID: ".. PlayerID .. "(" .. PlayerName .. ")")
                    VICE.ban(source, PlayerID, banDuration, BanMessage, Evidence)
            -- end
                VICE.AddWarnings(PlayerID, AdminName, BanMessage, Duration, BanPoints)
                exports['vice']:execute("UPDATE vice_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = BanPoints}, function() end)
                local a = exports['vice']:executeSync("SELECT * FROM vice_bans_offenses WHERE UserID = @uid", {uid = PlayerID})
                for k, v in pairs(a) do
                    if v.UserID == PlayerID then
                        if v.points > 10 then
                            exports['vice']:execute("UPDATE vice_bans_offenses SET Rules = @Rules, points = @points WHERE UserID = @UserID", {Rules = json.encode(PlayerOffenses[PlayerID]), UserID = PlayerID, points = 10}, function() end)
                            VICE.banConsole(PlayerID, 2160, "You have reached 10 points and have received a 3-month ban.")
                        end
                    end
                end
            end
        end)
    else
    end
end)


local screenshotdata = {}

RegisterServerEvent('VICE:RequestScreenshot')
AddEventHandler('VICE:RequestScreenshot', function(admin,target)
    local source = source
    local user_id = VICE.getUserId(source)
    local target_id = VICE.getUserId(target)
    if VICE.hasPermission(user_id, 'admin.screenshot') then
        local screenshotid = #screenshotdata + 1
        screenshotdata[screenshotid] = {target = target_id, admin = user_id}
        TriggerClientEvent("VICE:takeClientScreenshotAndUpload", target, VICE.getWebhook('media-cache'),screenshotid)
    else
        VICE.ACBan(15,user_id,"VICE:RequestScreenshot")
    end
end)

RegisterServerEvent('VICE:RequestVideo')
AddEventHandler('VICE:RequestVideo', function(admin,target)
    local source = source
    local user_id = VICE.getUserId(source)
    local target_id = VICE.getUserId(target)
    if VICE.hasPermission(user_id, 'admin.screenshot') then
        TriggerClientEvent("VICE:takeClientVideoAndUpload", target, VICE.getWebhook('media-cache'),"Admin")
    else
        VICE.ACBan(15,user_id,"VICE:RequestVideo")
    end
end)

RegisterServerEvent("VICE:ScreenshotProcessed",function(screenshotid,screenshot)
    local source = source
    local user_id = VICE.getUserId(source)
    if screenshotdata[screenshotid] and screenshotdata[screenshotid].target == user_id then
        --print("Screenshot | ID: " .. screenshotdata[screenshotid].target)
        VICE.sendDCLog('screenshot', 'VICE Screenshot Logs', "> Players Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**",screenshot)
    end
end)

RegisterServerEvent("VICE:VideoProcessed",function(videoType,video)
    local source = source
    local user_id = VICE.getUserId(source)
    if not video then
        print("fatal error video is nil src:"..source.." usrid:"..user_id)
        return
    end
    local videolink = "https://discord.com/channels/1345531320956358676/1345531321564397606"..video.channel_id.."/"..video.id
    if videoType == "Admin" then
        VICE.sendDCLog('video', 'VICE Video Logs', "> Players Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Video: "..videolink)
    elseif videoType == "Anticheat" then
        VICE.VideoProcessed(user_id,videolink)
    elseif videoType == "Lootbag" then
        VICE.sendDCLog('lootbag', 'VICE Lootbag Logs', "> Players Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Video: "..videolink)
    else
       VICE.ACBan(15, user_id, "VICE:VideoProccessed")
    end
end)

RegisterServerEvent('VICE:KickPlayer')
AddEventHandler('VICE:KickPlayer', function(admin, target, tempid)
    local source = source
    local user_id = VICE.getUserId(source)
    local target_id = VICE.getUserSource(target)
    if VICE.hasPermission(user_id, 'admin.kick') then
        VICE.prompt(source,"Reason:","",function(source,Reason) 
            if Reason == "" then return end
            VICE.sendDCLog('kick-player', 'VICE Kick Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(target).."**\n> Player TempID: **"..target_id.."**\n> Player PermID: **"..target.."**\n> Kick Reason: **"..Reason.."**")
            VICE.kick(target_id, "VICE You have been kicked | Your ID is: "..target.." | Reason: " ..Reason.." | Kicked by "..VICE.getPlayerName(user_id) or "No reason specified")
            VICE.notify(admin, '~g~Kicked Player.')
        end)
    else
        VICE.ACBan(15,user_id,"VICE:KickPlayer")
    end
end)


RegisterServerEvent('VICE:RemoveWarning')
AddEventHandler('VICE:RemoveWarning', function(warningid)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        if VICE.hasPermission(user_id, "admin.removewarn") then 
            exports['vice']:execute("SELECT * FROM vice_warnings WHERE warning_id = @warning_id", {warning_id = tonumber(warningid)}, function(result) 
                if result then
                    for k,v in pairs(result) do
                        if v.warning_id == tonumber(warningid) then
                            exports['vice']:execute("DELETE FROM vice_warnings WHERE warning_id = @warning_id", {warning_id = v.warning_id})
                            exports['vice']:execute("UPDATE vice_bans_offenses SET points = CASE WHEN ((points-@removepoints)>0) THEN (points-@removepoints) ELSE 0 END WHERE UserID = @UserID", {UserID = v.user_id, removepoints = (v.duration/24)}, function() end)
                            VICE.notify(source, '~g~Removed F10 Warning #'..warningid..' ('..(v.duration/24)..' points) from ID: '..v.user_id)
                            VICE.sendDCLog('remove-warning', 'VICE Remove Warning Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Warning ID: **"..warningid.."**")
                        end
                    end
                end
            end)
        else
            VICE.ACBan(15,user_id,"VICE:RemoveWarning")
        end
    end
end)

RegisterServerEvent("VICE:Unban")
AddEventHandler("VICE:Unban",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.unban') then
        VICE.prompt(source,"Perm ID:","",function(source,permid) 
            if permid == '' then return end
            permid = parseInt(permid)
            local permsource = VICE.getUserSource(permid)
            VICE.notify(source, '~g~Unbanned ID: ' .. permid)
            VICE.sendDCLog('unban-player', 'VICE Unban Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player PermID: **"..permid.."**")
            VICE.setBanned(permid,false)
        end)
    else
        VICE.ACBan(15,user_id,"VICE:Unban")
    end
end)


RegisterServerEvent("VICE:getNotes")
AddEventHandler("VICE:getNotes",function(player)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        exports['vice']:execute("SELECT * FROM vice_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result and #result > 0 then
                TriggerClientEvent('VICE:sendNotes', source, result[1].info)
            end
        end)
    end
end)

RegisterServerEvent("VICE:updatePlayerNotes")
AddEventHandler("VICE:updatePlayerNotes",function(player, notes)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        exports['vice']:execute("SELECT * FROM vice_user_notes WHERE user_id = @user_id", {user_id = player}, function(result) 
            if result then
                exports['vice']:execute("UPDATE vice_user_notes SET info = @info WHERE user_id = @user_id", {user_id = player, info = json.encode(notes)})
                VICE.notify(source, '~g~Notes updated.')
            end
        end)
    end
end)

local cooldowns = {}
local cooldownSeconds = 2 

RegisterServerEvent('VICE:SlapPlayer')
AddEventHandler('VICE:SlapPlayer', function(admin, target)
    local source = source
    local user_id = VICE.getUserId(source)
    if cooldowns[user_id] and cooldowns[user_id] > os.time() then
        VICE.notify(admin, '~r~Slap player is on cooldown.')
        --DropPlayer(admin,"Stop slapping players!")
        return
    end

    local player_id = VICE.getUserId(target)
    if VICE.hasPermission(user_id, "admin.slap") then
        if VICEclient.staffMode(source, {false}) then
            VICEclient.staffMode(source, {true}) 
            
        end
        VICE.sendDCLog('slap', 'VICE Slap Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")

        --  if player_id == 1 or player_id == 2 then 
        --                   return 
                 VICE.notify(source, "~r~You can not slap a Founder")
        --  end 
         TriggerClientEvent('VICE:SlapPlayer', target)
        VICE.notify(admin, '~g~Slapped '.. VICE.getPlayerName(player_id)..'.')
        cooldowns[user_id] = os.time() + cooldownSeconds 
    else
        VICE.ACBan(15,user_id,"VICE:SlapPlayer")
    end
end)

RegisterServerEvent('VICE:RevivePlayer')
AddEventHandler('VICE:RevivePlayer', function(admin, targetid, reviveall)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = targetid
    local target = VICE.getUserSource(player_id)
    if target then
        if VICE.hasPermission(user_id, "admin.revive") and not VICEclient.isStaffedOn(source) then
            VICEclient.RevivePlayer(target, {})
            VICEclient.setPlayerCombatTimer(target, {0})
            if not reviveall then
                VICE.sendDCLog('revive', 'VICE Revive Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
                VICE.notify(admin, '~g~Revived '..VICE.getPlayerName(player_id) .. '.')
                return
            end
            VICE.notify(admin, '~g~Revived all Nearby.')
        else
            VICE.ACBan(15,user_id,"VICE:RevivePlayer")
        end
    end
end)
RegisterServerEvent('VICE:GiveArmour')
AddEventHandler('VICE:GiveArmour', function(admin, targetid, giveall)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = targetid
    local target = VICE.getUserSource(player_id)
    if target then
        if VICE.hasPermission(user_id, "admin.revive") and not VICEclient.isStaffedOn(source) then
            VICEclient.setArmour(target, {100})
            if not giveall then
                VICE.sendDCLog('armour', 'VICE Armour Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..admin.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..target.."**\n> Player PermID: **"..player_id.."**")
                VICE.notify(admin, '~g~Gave armour to '..VICE.getPlayerName(player_id)..'.')
                return
            end
            VICE.notify(admin, '~g~Gave armour to all Nearby.')
        else
            VICE.ACBan(15, user_id, "VICE:GiveArmour")
        end
    end
end)
RegisterServerEvent('VICE:SpawnMosin')
AddEventHandler('VICE:SpawnMosin', function(admin, targetid, giveall)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = targetid
    local target = VICE.getUserSource(player_id)
    if target then
        if VICE.hasPermission(user_id, "admin.revive") and not VICEclient.isStaffedOn(source) then
           VICEclient.giveWeapons(source, {{["WEAPON_MOSINCMG"] = {ammo = 250}}, false,globalpasskey}) 
            if not giveall then
        
                VICE.notify(admin, '~g~Gave Mosin to '..VICE.getPlayerName(player_id)..'.')
                return
            end
            VICE.notify(admin, '~g~Gave Mosin to all Nearby.')
        else
            -- VICE.ACBan(15, user_id, "VICE:SpawnMosin")
        end
    end
end)

RegisterServerEvent('VICE:ArmourPlayer')
AddEventHandler('VICE:ArmourPlayer', function(admin, targetid)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = tonumber(targetid)
    local target = VICE.getUserSource(player_id)

   if target then
      if VICE.hasPermission(user_id, "admin.revive") and not VICEclient.isStaffedOn(source) then
            
            TriggerClientEvent("VICE:Client:GiveArmour", target, 100)

            VICE.notify(admin, '~g~Given player armour '..VICE.getPlayerName(player_id)..'.')
            return
        end
    end 
        VICE.notify(admin, '~g~Armoured all Nearby.')
end)


frozenplayers = {}

RegisterServerEvent('VICE:FreezeSV')
AddEventHandler('VICE:FreezeSV', function(admin, newtarget, isFrozen)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.freeze') then
        if isFrozen then
            VICE.sendDCLog('freeze', 'VICE Freeze Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Frozen**")
            VICE.notify(source, '~g~Froze: '..VICE.getPlayerName(player_id))
            frozenplayers[player_id] = true
            VICE.notify(newtarget, '~g~You have been frozen.')
        else
            VICE.sendDCLog('freeze', 'VICE Freeze Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**\n> Type: **Unfrozen**")
            VICE.notify(source, '~g~Unfrozen: '..VICE.getPlayerName(player_id))
            VICE.notify(newtarget, '~g~You have been unfrozen.')
            frozenplayers[player_id] = nil
        end
        TriggerClientEvent('VICE:Freeze', newtarget, isFrozen)
    else
        VICE.ACBan(15,user_id,"VICE:FreezeSV")
    end
end)

RegisterServerEvent("VICE:RequestIfFrozen",function(perm)
    local source = source
    local user_id = VICE.getUserId(source)
    perm = tonumber(perm)
    if VICE.hasPermission(user_id, 'admin.freeze') then
        if frozenplayers[perm] ~= nil then
            TriggerClientEvent("VICE:SendIfFrozen",source,perm,frozenplayers[perm])
        else
            TriggerClientEvent("VICE:SendIfFrozen",source,perm,false)
        end
    else
        VICE.ACBan(15,user_id,"VICE:RequestIfFrozen")
    end
end)

RegisterServerEvent('VICE:TeleportToPlayer')
AddEventHandler('VICE:TeleportToPlayer', function(source, newtarget)
    local source = source
    local coords = GetEntityCoords(GetPlayerPed(newtarget))
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        local adminbucket = GetPlayerRoutingBucket(source)
        local playerbucket = GetPlayerRoutingBucket(newtarget)
        if adminbucket ~= playerbucket then
            VICE.setBucket(source, playerbucket) 
            VICE.notify(source, '~g~Player was in another bucket, you have been set into their bucket.')
        end
        VICEclient.teleport(source, coords)
        VICE.notify(newtarget, '~g~An admin has teleported to you.')
        if player_id then
            VICE.sendDCLog('tp-to-player', 'VICE Teleport to Player Logs', "> Admin Name: **"..VICE.getPlayerName(player_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..newtarget.."**\n> Player PermID: **"..player_id.."**")
        end
    else
        VICE.ACBan(15,user_id,"VICE:TeleportToPlayer")
    end
end)

RegisterServerEvent('VICE:Teleport2Legion')
AddEventHandler('VICE:Teleport2Legion', function(newtarget)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        VICEclient.teleport(newtarget, vector3(152.66354370117,-1035.9771728516,29.337995529175))
        VICE.notify(newtarget, '~g~You\'ve been teleported to Legion by an admin.')
        VICEclient.setPlayerCombatTimer(newtarget, {0})
    else
        VICE.ACBan(15,user_id,"VICE:Teleport2Legion")
    end
end)
RegisterServerEvent('VICE:Teleport2Vip')
AddEventHandler('VICE:Teleport2Vip', function(newtarget)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        VICEclient.teleport(newtarget, vector3(-2171.8022460938,5141.736328125,2.808837890625))
        VICE.notify(newtarget, '~g~You\'ve been teleported to Vip Island by an admin.')
        VICEclient.setPlayerCombatTimer(newtarget, {0})
    else
        VICE.ACBan(15,user_id,"VICE:Teleport2Vip")
    end
end)

RegisterServerEvent('VICE:Teleport2Sandy')
AddEventHandler('VICE:Teleport2Sandy', function(newtarget)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        VICEclient.teleport(newtarget, vector3(1841.0941162109,3669.6140136719,33.679996490479))
        VICE.notify(newtarget, '~g~You\'ve been teleported to Sandy Shores by an admin.')
        VICEclient.setPlayerCombatTimer(newtarget, {0})
    else
        VICE.ACBan(15,user_id,"VICE:Teleport2Sandy")
    end
end)

RegisterServerEvent('VICE:Teleport2Paleto')
AddEventHandler('VICE:Teleport2Paleto', function(newtarget)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_id = VICE.getUserId(newtarget)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        VICEclient.teleport(newtarget, vector3(-233.5185546875,6317.2900390625,31.491870880127))
        VICE.notify(newtarget, '~g~You\'ve been teleported to Paleto by an admin.')
        VICEclient.setPlayerCombatTimer(newtarget, {0})
    else
        VICE.ACBan(15,user_id,"VICE:Teleport2Paleto")
    end
end)

RegisterNetEvent('VICE:BringPlayer')
AddEventHandler('VICE:BringPlayer', function(id)
    local source = source 
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        if id and VICE.getUserId(id) then
            VICE.sendDCLog('tp-player-to-me', 'VICE Bring Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(VICE.getUserId(id)).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..VICE.getUserId(id).."**")
            VICEclient.teleport(id, GetEntityCoords(GetPlayerPed(source)))
            local adminbucket = GetPlayerRoutingBucket(source)
            local playerbucket = GetPlayerRoutingBucket(id)
            if adminbucket ~= playerbucket then
                VICE.setBucket(id, adminbucket)
                VICE.notify(source, '~g~Player was in another bucket, they have been set into your bucket.')
            end
            VICEclient.setPlayerCombatTimer(id, {0})
        else 
            VICE.notify(source, "This player may have left the game.")
        end
    else
        VICE.ACBan(15,user_id,"VICE:BringPlayer")
    end
end)

RegisterNetEvent('VICE:TpALL')
AddEventHandler('VICE:TpALL', function()
    local source = source 
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tp2player') then
        local admin_coords = GetEntityCoords(GetPlayerPed(source))
        local players = GetPlayers()
        for _, id in ipairs(players) do
            VICEclient.teleport(id, admin_coords)
            local adminbucket = GetPlayerRoutingBucket(source)
            local playerbucket = GetPlayerRoutingBucket(id)
            if adminbucket ~= playerbucket then
                VICE.setBucket(id, adminbucket)
                VICE.notify(source, '~g~Player was in another bucket, they have been set into your bucket.')
            end
            VICEclient.setPlayerCombatTimer(id, {0})
        end
    else
        VICE.ACBan(15,user_id,"VICE:TpALL")
    end
end)

RegisterNetEvent('VICE:GetCoords')
AddEventHandler('VICE:GetCoords', function()
    local source = source 
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        VICEclient.getPosition(source,{},function(coords)
            local x,y,z = table.unpack(coords)
            VICE.prompt(source,"Copy the coordinates using Ctrl-A Ctrl-C",x..","..y..","..z,function(player,choice) 
            end)
        end)
    else
        VICE.ACBan(15,user_id,"VICE:GetCoords")
    end
end)

RegisterNetEvent('VICE:GetVec4Coords')
AddEventHandler('VICE:GetVec4Coords', function()
    local source = source 
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
        local heading = GetEntityHeading(playerPed)
        VICE.prompt(source,"Copy the coordinates using Ctrl-A Ctrl-C",coords.x..","..coords.y..","..coords.z .. "," ..heading,function(player,choice) 
        end)
    else
        VICE.ACBan(15,user_id,"VICE:GetVec4Coords")
    end
end)

RegisterServerEvent('VICE:Tp2Coords')
AddEventHandler('VICE:Tp2Coords', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tp2coords") then
        VICE.prompt(source,"Coords x,y,z:","",function(player,fcoords) 
            local coords = {}
            for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
            table.insert(coords,tonumber(coord))
            end
        
            local x,y,z = 0,0,0
            if coords[1] then x = coords[1] end
            if coords[2] then y = coords[2] end
            if coords[3] then z = coords[3] end

            if x and y and z == 0 then
                VICE.notify(source, "We couldn't find those coords, try again!")
            else
                VICEclient.teleport(player,{x,y,z})
            end 
        end)
    else
        VICE.ACBan(15,user_id,"VICE:Tp2Coords")
    end
end)

RegisterServerEvent("VICE:Teleport2AdminIsland")
AddEventHandler("VICE:Teleport2AdminIsland",function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if id then
        local player_id = VICE.getUserId(id)
        if VICE.hasPermission(user_id, 'admin.tp2player') then
            local ped = GetPlayerPed(source)
            local ped2 = GetPlayerPed(id)
            FreezeEntityPosition(ped, true)
            SetEntityCoords(ped2,3484.6481933594,2604.2587890625,11.995886802673)
            VICE.notify(VICE.getUserSource(player_id), '~g~You are now in an admin situation, do not leave the game.')
            VICEclient.setPlayerCombatTimer(id, {0})
            Wait(500)
            FreezeEntityPosition(ped, false)
            VICE.sendDCLog('tp-to-admin-zone', 'VICE Teleport Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(player_id).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..player_id.."**")
        else
            VICE.ACBan(15,user_id,"VICE:Teleport2AdminIsland")
        end
    end
end)

RegisterServerEvent("VICE:TeleportBackFromAdminZone")
AddEventHandler("VICE:TeleportBackFromAdminZone",function(id, savedCoordsBeforeAdminZone)
    local source = source
    local user_id = VICE.getUserId(source)
    if id then
        if VICE.hasPermission(user_id, 'admin.tp2player') then
            local ped = GetPlayerPed(id)
            SetEntityCoords(ped, savedCoordsBeforeAdminZone)
            VICE.setBucket(id, 0)
            VICE.sendDCLog('tp-back-from-admin-zone', 'VICE Teleport Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..VICE.getPlayerName(VICE.getUserId(id)).."**\n> Player TempID: **"..id.."**\n> Player PermID: **"..VICE.getUserId(id).."**")
        else
            VICE.ACBan(15,user_id,"VICE:TeleportBackFromAdminZone")
        end
    end
end)

RegisterNetEvent('VICE:AddCar')
AddEventHandler('VICE:AddCar', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.addcar') then
        VICE.prompt(source,"Add to Perm ID:","",function(source, permid)
            if permid == "" then 
                return 
            end
            permid = tonumber(permid)
            VICE.prompt(source,"Car Spawncode:","",function(source, car) 
                if car == "" then return end
                local car = car
                VICE.prompt(source,"Locked:","",function(source, locked) 
                    if locked == '0' or locked == '1' then
                        if permid and car ~= "" then  
                            VICEclient.generateUUID(source, {"plate", 5, "alphanumeric"}, function(uuid)
                                local uuid = string.upper(uuid)
                                exports['vice']:execute("SELECT * FROM `vice_user_vehicles` WHERE vehicle_plate = @plate", {plate = uuid}, function(result)
                                    if #result > 0 then
                                        VICE.notify(source, 'Error adding car, please try again.')
                                        return
                                    else
                                        MySQL.execute("VICE/add_vehicle", {user_id = permid, vehicle = car, registration = uuid, locked = locked})
                                        VICE.notify(source,  '~g~Successfully added car ' .. car .. ' to PermID (' .. permid .. ')' )
                                        VICE.sendDCLog('add-car', 'VICE Add Car To Player Logs', "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Player PermID: **"..permid.."**\n> Spawncode: **"..car.."**")
                                    end
                                end)
                            end)
                        else 
                            VICE.notify(source, '~r~Failed to add Player\'s car')
                        end
                    else
                        VICE.notify(source, '~g~Locked must be either 1 or 0') 
                    end
                end)
            end)
        end)
    else
        VICE.ACBan(15,user_id,"VICE:AddCar")
    end
end)

RegisterNetEvent('VICE:CleanAll')
AddEventHandler('VICE:CleanAll', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllPeds()) do 
            DeleteEntity(v)
        end
        for i,v in pairs(GetAllObjects()) do
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'VICE^7 │ ', {255, 255, 255}, "Cleanup Completed by ^3" .. VICE.getPlayerName(user_id) .. "^0!", "alert")
        VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Triggered** \n\n```Clean all Completed```\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('VICE:CleanVeh')
AddEventHandler('VICE:CleanVeh', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllVehicles()) do 
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'VICE^7 │ ', {255, 255, 255}, "Vehicle Cleanup Completed by ^3" .. VICE.getPlayerName(user_id) .. "^0!", "alert")
       VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Triggered** \n\n```Vehicle Cleanup Completed```\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('VICE:CleanPed')
AddEventHandler('VICE:CleanPed', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllPeds()) do 
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'VICE^7 │ ', {255, 255, 255}, "Ped Cleanup Completed by ^3" .. VICE.getPlayerName(user_id) .. "^0!", "alert")
       VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Triggered** \n\n```Ped Cleanup Completed```\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterNetEvent('VICE:CleanObj')
AddEventHandler('VICE:CleanObj', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        for i,v in pairs(GetAllObjects()) do
            DeleteEntity(v)
        end
        TriggerClientEvent('chatMessage', -1, 'VICE^7 │ ', {255, 255, 255}, "Object Cleanup Completed by ^3" .. VICE.getPlayerName(user_id) .. "^0!", "alert")
       VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Triggered** \n\n```Object Cleanup Completed```\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end
end)

RegisterServerEvent("VICE:GetPlayerData")
AddEventHandler("VICE:GetPlayerData",function()
    local source = source
    user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        players = GetPlayers()
        players_table = {}
        useridz = {}
        for i, p in pairs(VICE.getUsers()) do
            user_idz = i
            name = VICE.getPlayerName(user_idz)
            data = VICE.getUserDataTable(user_idz)
            stafflevel = VICE.GetStaffLevel(user_idz)
            playtime = data.PlayerTime or 0
            PlayerTimeInHours = playtime/60
            if PlayerTimeInHours < 1 then
                PlayerTimeInHours = 0
            end
            players_table[user_idz] = {name, p, user_idz, math.ceil(PlayerTimeInHours), stafflevel}
            table.insert(useridz, user_idz)
        end
        TriggerClientEvent("VICE:getPlayersInfo", source, players_table, bans)
    end
end)

function tVICE.GetPlayTime(user_id)
    if user_id then
        data = VICE.getUserDataTable(user_id)
        playtime = data.PlayerTime or 0
        PlayerTimeInHours = playtime / 60
        if PlayerTimeInHours < 1 then
            PlayerTimeInHours = 0
        end
        PlayerTimeInHours = math.ceil(PlayerTimeInHours)
        VICE.SetStat(user_id, 'playtime', PlayerTimeInHours)
        return PlayerTimeInHours
    else
        return 0
    end
end

RegisterServerEvent("VICE:StaffModeLogs")
AddEventHandler("VICE:StaffModeLogs", function(status)
    local source = source
    local user_id = VICE.getUserId(source)
    local action = status and "Activated" or "Deactivated"
    if VICE.hasPermission(user_id, "admin.tickets") then
        VICE.sendDCLog('staff', 'VICE Staff Mode Log', "**Staff Mode "..action.."**\n\n> Admin Name: ** "..VICE.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    else
        VICE.ACBan(15,user_id,"VICE:StaffModeLogs")
    end
end)

RegisterCommand("staffon", function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        if globalPreventStaff then
            VICE.notify("~r~You cannot staff on while in the pit.")
            return
        end
        VICEclient.staffMode(source, {true})
        -- Get all permissions for the user
        local permissions = {}
        for group, _ in pairs(VICE.getUserGroups(user_id)) do
            if VICE.hasGroup(user_id, group) then
                permissions[group] = true
            end
        end
        -- Broadcast staff status update
        TriggerClientEvent('VICE:updateStaffStatus', -1, source, true, permissions)
        VICE.sendDCLog('staff', 'VICE Staff Mode Log', "**Staff Mode Activated**\n\n> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    end
end)
RegisterCommand('staffmode', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
     local permissions = {}
        for group, _ in pairs(VICE.getUserGroups(user_id)) do
            if VICE.hasGroup(user_id, group) then
                permissions[group] = true
            end
        end     
    if VICE.hasPermission(user_id, "admin.tickets") then
        VICEclient.isStaffedOn(source, {}, function(staffedOn)
            if staffedOn then
                VICEclient.staffMode(source, { false })
                TriggerClientEvent('VICE:updateStaffStatus', -1, source, false, nil)
            else
                VICEclient.staffMode(source, { true })
                TriggerClientEvent('VICE:updateStaffStatus', -1, source, true, permissions)
            end
        end)
    end
end)

RegisterCommand("staffoff", function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "admin.tickets") then
        VICEclient.staffMode(source, {false})
        -- Broadcast staff status update
        TriggerClientEvent('VICE:updateStaffStatus', -1, source, false, nil)
        VICE.sendDCLog('staff', 'VICE Staff Mode Log', "**Staff Mode Deactivated**\n\n> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin PermID: **"..user_id.."**\n> Admin TempID: **" ..source.. "**")
    end
end)

RegisterServerEvent('VICE:getAdminLevel')
AddEventHandler('VICE:getAdminLevel', function()
    local source = source
    local user_id = VICE.getUserId(source)
    local adminlevel = VICE.GetStaffLevel(user_id)
    VICEclient.setStaffLevel(source, {adminlevel})
end)

RegisterServerEvent("VICE:VerifyStaffLevel",function(stafflvl)
    local source = source
    local user_id = VICE.getUserId(source)
    if stafflvl > 0 then
        for k, v in pairs(VICE.GetStaffTable()) do
            if v == stafflvl then
                if not VICE.hasGroup(user_id, k) then
                    VICE.ACBan(15,user_id,"VICE:VerifyStaffLevel")
                end
            end
        end
    end
end)

RegisterServerEvent("VICE:VerifyDev",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not VICE.isDeveloper(user_id) and not VICE.hasGroup(user_id,"Founder") and not VICE.hasGroup(user_id,"Lead Developer") and not VICE.hasGroup(user_id,"Developer") and not VICE.hasGroup(user_id,".") then
        VICE.ACBan(15,user_id,"VICE:VerifyDev")
    end
end)

RegisterServerEvent("VICE:VerifyUserID",function(id)
    local source = source
    local user_id = VICE.getUserId(source)
    if id ~= user_id then
        VICE.ACBan(15,user_id,"VICE:VerifyUserID")
    end
end)

RegisterNetEvent('VICE:zapPlayer')
AddEventHandler('VICE:zapPlayer', function(A)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'Founder') then
        TriggerClientEvent("VICE:useTheForceTarget", A)
        for k,v in pairs(VICE.getUsers()) do
            TriggerClientEvent("VICE:useTheForceSync", v, GetEntityCoords(GetPlayerPed(A)), GetEntityCoords(GetPlayerPed(v)))
        end
    end
end)

RegisterNetEvent('VICE:theForceSync')
AddEventHandler('VICE:theForceSync', function(A, q, r, s)
    local source = source
    if VICE.getUserId(source) == 1 then
        TriggerClientEvent("VICE:useTheForceSync", A, q, r, s)
        TriggerClientEvent("VICE:useTheForceTarget", A)
    end
end)

RegisterCommand("cleararea", function(source, args) -- these events are gonna be used for vehicle cleanup in future also
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.noclip') then
        TriggerClientEvent('VICE:clearVehicles', -1)
        TriggerClientEvent('VICE:clearBrokenVehicles', -1)
        VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Triggered** \n\n```Clear Area Command```\n> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player PermID: **"..user_id.."**\n> Player TempID: **"..source.."**")
    end 
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(590000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup in 10 seconds! All unoccupied vehicles will be deleted.", "alert")
        Citizen.Wait(10000)
        TriggerClientEvent('chatMessage', -1, 'Announcement │ ', {255, 255, 255}, "^0Vehicle cleanup complete.", "alert")
        TriggerClientEvent('VICE:clearVehicles', -1)
        TriggerClientEvent('VICE:clearBrokenVehicles', -1)
       -- VICE.sendDCLog('cleanup', "VICE Cleanup Logs", "**Automatic** \n\n```Vehicle cleanup Completed```")
	end
end)

RegisterCommand("getbucket", function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.notify(source, '~g~You are currently in Bucket: '..GetPlayerRoutingBucket(source)) 
end)

RegisterCommand("setbucket", function(source, args)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.managecommunitypot') then
        VICE.setBucket(source, tonumber(args[1]))
        VICE.notify(source, '~g~You are now in Bucket: '..GetPlayerRoutingBucket(source))
    end 
end)

RegisterCommand("clipboard", function(source, args)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'group.remove') then
        local permid = tonumber(args[1])
        table.remove(args, 1)
        local msg = table.concat(args, " ")
        VICEclient.CopyToClipBoard(VICE.getUserSource(permid), {msg})
    end
end)

local bucket100TrackedBySource = {}
local function bucketTrackKey(src)
    return tostring(src)
end

RegisterNetEvent('shadowlobby')
AddEventHandler('shadowlobby',function (permid,tempid)
    local targetSrc = tonumber(tempid)
    local targetPerm = tonumber(permid) or (targetSrc and VICE.getUserId(targetSrc))
    if targetSrc and targetPerm then
        bucket100TrackedBySource[bucketTrackKey(targetSrc)] = tonumber(targetPerm)
    end
    SetPlayerRoutingBucket(tempid,100)
    TriggerClientEvent('sl',tempid)
end)

RegisterNetEvent('returnlobby')
AddEventHandler('returnlobby',function (permid,tempid)
    local targetSrc = tonumber(tempid)
    if targetSrc then
        bucket100TrackedBySource[bucketTrackKey(targetSrc)] = nil
    end
    SetPlayerRoutingBucket(tempid,0)
    VICE.notify(tempid,'~g~An admin has sent you back to the normal lobby')
end)

-- AddEventHandler('playerDropped', function(reason)
--     local src = source
--     local trackedPerm = bucket100TrackedBySource[bucketTrackKey(src)]
--     local user_id = VICE.getUserId(src)
--     local permid = tonumber(trackedPerm) or tonumber(user_id)
--     local bucket = GetPlayerRoutingBucket(src)
--     local wasInCheatBucket = (bucket == 100) or (trackedPerm ~= nil)

--     if permid and wasInCheatBucket then
--         VICE.banConsole(permid, "perm", "Cheating: Left while in anti-cheat bucket (100).")
--         print(("Auto-banned user %s for leaving in bucket 100. Reason: %s"):format(permid, reason or "unknown"))
--     end

--     bucket100TrackedBySource[bucketTrackKey(src)] = nil
-- end)
