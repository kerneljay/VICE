RegisterCommand('addgroup', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local group = args[2]
        VICE.addUserGroup(userid, group)
        print('Added Group: ' .. group .. ' to UserID: ' .. userid)
    else
        print('Incorrect usage: addgroup [permid] [group]')
    end
end)

RegisterCommand('removegroup', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local group = args[2]
        VICE.removeUserGroup(userid, group)
        print('Removed Group: ' .. group .. ' from UserID: ' .. userid)
    else
        print('Incorrect usage: addgroup [permid] [group]')
    end
end)

RegisterCommand("viewgroups", function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) then
        local userid = tonumber(args[1])
        local groups = VICE.getUserGroups(userid)
        print('Groups for UserID: ' .. userid .. ' are: ' .. json.encode(groups))
    else
        print('Incorrect usage: viewgroups [permid]')
    end
end)

RegisterCommand('ban', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) and args[2] then
        local userid = tonumber(args[1])
        local hours = args[2]
        local reason = table.concat(args, " ", 3)
        if reason then
            VICE.banConsole(userid, hours, reason)
        else
            print('Incorrect usage: ban [permid] [hours] [reason]')
        end
    else
        print('Incorrect usage: ban [permid] [hours] [reason]')
    end
end)

RegisterCommand('unban', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) then
        local userid = tonumber(args[1])
        VICE.setBanned(userid, false)
        print('Unbanned user: ' .. userid)
    else
        print('Incorrect usage: unban [permid]')
    end
end)
RegisterCommand('cashtoall', function(source, args)
    if source ~= 0 then return end;
    if tonumber(args[1]) then
        local amount = tonumber(args[1])
        print('Given £' .. amount .. ' to all users online')
        for k, v in pairs(VICE.getUsers()) do
            VICE.notify(v, '~g~You have received £' .. getMoneyStringFormatted(amount) .. ' from the server.')
            VICE.giveBankMoney(k, amount)
        end
    else
        print('Incorrect usage: cashtoall [amount]')
    end
end)
RegisterCommand('cartoall', function(source, args)
    if source ~= 0 then return end
    local car = args[1]
    local locked = 1
    local users = VICE.getUsers()
    for k, v in pairs(users) do
        VICEclient.generateUUID(v, { "plate", 5, "alphanumeric" }, function(uuid)
            local uuid = string.upper(uuid)
            exports['vice']:execute("SELECT * FROM `vice_user_vehicles` WHERE vehicle_plate = @plate", { plate = uuid },
                function(result)
                    if #result > 0 then
                        VICE.notify(k, 'Error adding car, please try again.')
                    else
                        MySQL.execute("VICE/add_vehicle",
                            { user_id = k, vehicle = car, registration = uuid, locked = locked })
                    end
                end)
        end)
        print(car .. "been given to everyone online.")
    end
end)


-- local hour = 3600

-- RegisterCommand("kit", function(source, args, rawCommand)
--     local user_id = VICE.getUserId(source)
--     if user_id then
--         local current_time = os.time()
--         local kit_name = "Mosin + Max Armour"
--         exports['ghmattimysql']:execute('SELECT last_kit_usage FROM vice_users WHERE id = @id', { id = user_id },
--             function(kitRows)
--                 if kitRows[1] then
--                     local last_kit_usage = kitRows[1].last_kit_usage or 0
--                     if current_time - last_kit_usage >= hour then
--                         exports['ghmattimysql']:execute(
--                         'UPDATE vice_users SET last_kit_usage = @current_time WHERE id = @id',
--                             { current_time = current_time, id = user_id })
--                         VICEclient.giveWeapons(source, { { ["WEAPON_MOSINCMG"] = { ammo = 250 } }, false })
--                         VICEclient.giveWeapons(source, { { ["WEAPON_UZICMG"] = { ammo = 250 } }, false })
--                         VICEclient.setArmour(source, { 100, true })
--                         VICEclient.notify(source, { "~g~Kit Redeemed, Received Mosin And Max Armour" })
--                     else
--                         local remaining_time = hour - (current_time - last_kit_usage)
--                         VICEclient.notify(source,
--                             { "~r~You can only redeem this kit hourly. Please wait " ..
--                             math.ceil(remaining_time / 60) .. " minutes." })
--                     end
--                 else
--                     VICEclient.notify(source, { "~r~Kit not found: " .. kit_name })
--                 end
--             end)
--     end
-- end, false)


RegisterCommand('moneywipe', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.

    print('Executing money wipe for all users')

    -- Update all users' money - set bank to 30mil, others to 0
    exports['vice']:execute("UPDATE vice_user_moneys SET wallet = 0, bank = 15000000, dirtycash = 0", {},
        function(result)
            print('Money wipe complete')

            -- Update all gang funds
            exports['vice']:execute("UPDATE vice_gangs SET funds = 0", {}, function(result)
                print('Gang funds wipe complete')
            end)

            -- Update casino chips
            exports['vice']:execute("UPDATE vice_casino_chips SET chips = 0", {}, function(result)
                print('Casino chips wipe complete')
            end)

            -- Update in-game display for all online players
            local users = VICE.getUsers()
            for k, v in pairs(users) do
                VICE.giveBankMoney(k, 15000000) -- Use giveBankMoney like cashtoall
                VICE.setMoney(k, 0)         -- wallet to 0
                VICE.setDirtyCash(k, 0)     -- dirty cash to 0
                VICE.setChips(k, 0)         -- chips to 0

                -- Notify each player
                VICE.notify(v, "~g~Your bank balance has been set to £15,000,000")
            end

            -- Log to console
            print('Money wipe executed by console - Bank set to 15mil')

            -- Notify all players
            TriggerClientEvent('chatMessage', -1, "^2SYSTEM", { 0, 255, 0 },
                "All bank balances have been set to £15,000,000")
        end)
end)


RegisterCommand("guntoall", function(source, args, rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id,"eventmanager") or VICE.hasGroup(user_id,"Developer") or VICE.hasGroup(user_id,"Lead Developer") or VICE.hasGroup(user_id,".") or VICE.hasGroup(user_id,"Founder") then
        VICE.prompt(source, "Weapon Name:", "", function(source, weapon)
            if weapon and weapon ~= "" then
                weapon = "WEAPON_" .. string.upper(weapon)
                -- Validate weapon spawncode
                local weapons = module("cfg/weapons")
                if not weapons.weapons[weapon] then
                    VICEclient.notify(source, {"~r~Invalid weapon spawncode!"})
                    return
                end
                
                -- Get all online players
                local players = VICE.getUsers()
                for k,v in pairs(players) do
                    -- Check if player is clocked on as police
                    local isPolice = false
                    if VICE.hasGroup(k, "Police") or 
                       VICE.hasGroup(k, "PC") or 
                       VICE.hasGroup(k, "PCSO") or 
                       VICE.hasGroup(k, "Special Constable") or 
                       VICE.hasGroup(k, "Sergeant") or 
                       VICE.hasGroup(k, "Inspector") or 
                       VICE.hasGroup(k, "Chief Inspector") or 
                       VICE.hasGroup(k, "Superintendent") or 
                       VICE.hasGroup(k, "Chief Superintendent") or 
                       VICE.hasGroup(k, "Commander") or 
                       VICE.hasGroup(k, "Dep. Asst. Commissioner") or 
                       VICE.hasGroup(k, "Assistant Commissioner") or 
                       VICE.hasGroup(k, "Deputy Commissioner") or 
                       VICE.hasGroup(k, "Commissioner") then
                        -- Check if they're actually clocked on
                        TriggerClientEvent("VICE:checkPoliceDuty", v, function(isOnDuty)
                            isPolice = isOnDuty
                        end)
                    end
                    
                    -- Give weapon if not on police duty
                    if not isPolice then
                        VICEclient.giveWeapons(v, {{[weapon] = {ammo = 250}}, false, globalpasskey})
                        VICEclient.setArmour(v, {200, true})
                        VICEclient.notify(v, {"~y~An admin has given you a weapon and armor."})
                    end
                end
                VICEclient.notify(source, {"~g~Weapon and full armour given to all non-police players."})
            else
                VICEclient.notify(source, {"~r~Please enter a valid weapon name!"})
            end
        end)
    else
        VICEclient.notify(source, {"~r~You don't have permission to do that!"})
    end
end)


RegisterCommand("guntoplayer", function(source, args, rawCommand)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, "eventmanager") or VICE.hasGroup(user_id, "Developer") or VICE.hasGroup(user_id, "Lead Developer") or VICE.hasGroup(user_id, ".") or VICE.hasGroup(user_id, "Founder") then
        VICE.prompt(source, "Player Perm ID:", "", function(source, target_id)
            if target_id and target_id ~= "" then
                target_id = tonumber(target_id)
                if not target_id then
                    VICEclient.notify(source, { "~r~Invalid player ID!" })
                    return
                end

                VICE.prompt(source, "Weapon Name:", "", function(source, weapon)
                    if weapon and weapon ~= "" then
                        weapon = "WEAPON_" .. string.upper(weapon)
                        -- Validate weapon spawncode
                        local weapons = module("cfg/weapons")
                        if not weapons.weapons[weapon] then
                            VICEclient.notify(source, { "~r~Invalid weapon spawncode!" })
                            return
                        end

                        -- Get target player source
                        local target_source = VICE.getUserSource(target_id)
                        if not target_source then
                            VICEclient.notify(source, { "~r~Player not found!" })
                            return
                        end

                        -- Give weapon and armor to target player
                        VICEclient.giveWeapons(target_source, { { [weapon] = { ammo = 250 } }, false, globalpasskey })
                        VICEclient.setArmour(target_source, { 200, true })

                        -- Notify both admin and target
                        VICEclient.notify(target_source, { "~y~An admin has given you a weapon and armor." })
                        VICEclient.notify(source, { "~g~Weapon and armor given to player ID: " .. target_id })
                    else
                        VICEclient.notify(source, { "~r~Please enter a valid weapon name!" })
                    end
                end)
            else
                VICEclient.notify(source, { "~r~Please enter a valid player ID!" })
            end
        end)
    else
        VICEclient.notify(source, { "~r~You don't have permission to do that!" })
    end
end)
