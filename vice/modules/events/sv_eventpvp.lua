-- local gunGamePlayers = {}

-- local weaponProgression = {
--     "WEAPON_MOSINCMG",
--     "WEAPON_MANORMOSIN",
--     "WEAPON_M4A1WHITENOISE",
--     "WEAPON_AK47TEMPERED",
--     "WEAPON_MK14",
--     "WEAPON_KITCHENKNIFE"
-- }

-- RegisterCommand("stopgungame", function(source)
--     local user_id = VICE.getUserId(source)
--     if user_id == 1 and gunGamePlayers[user_id] then
--         gunGamePlayers[user_id] = nil
--         VICEclient.removeAllWeapons(source,{})
--         VICE.notify(source, "~r~Gun Game ended.")
--         TriggerClientEvent("gungame:stop", source)
--         print("[GunGame] Player " .. user_id .. " left the game.")
--     end
-- end)

-- RegisterNetEvent("gungame:playerKilled")
-- AddEventHandler("gungame:playerKilled", function()
--     local src = source
--     local user_id = VICE.getUserId(src)
--     if not user_id or not gunGamePlayers[user_id] then return end
--     local currentLevel = gunGamePlayers[user_id]
--     local nextLevel = currentLevel + 1
--     if nextLevel <= #weaponProgression then
--         gunGamePlayers[user_id] = nextLevel
--         VICEclient.removeAllWeapons(src,{})
--         VICEclient.giveWeapons(src, { { [weaponProgression[nextLevel]] = { ammo = 250 } }, false, globalpasskey })
--         VICE.notify(src, "Weapon upgraded to: " .. weaponProgression[nextLevel])
--     else
--         gunGamePlayers[user_id] = nil
--         VICEclient.removeAllWeapons(src,{})
        
--         VICE.notify(src, "You won the gun game.")
--         TriggerClientEvent("gungame:stop", src)
--         print("[GunGame] Player " .. user_id .. " won!")
--     end
-- end)









-- local currentdata = {
--     eventactive = true,
--     teams = {
--         ["Red"] = {},
--         ["Blue"] = {},
--     }
-- }
-- local resetdata = currentdata

-- local function AlreadyInTeam(user_id)
--     for _, team in ipairs({ "Red", "Blue" }) do
--         for i = 1, 2 do
--             if currentdata.teams[team][i] == user_id then
--                 return true, team
--             end
--         end
--     end
--     return false, "None"
-- end

-- local function ActionTeam(actiontype, team, team2, user_id)
--     if actiontype == "join" then
--         if #currentdata.teams[team] < 2 then
--             for i = 1, 2 do
--                 if not currentdata.teams[team][i] then
--                     currentdata.teams[team][i] = user_id
--                     break
--                 end
--             end
--         end
--     elseif actiontype == "leave" then
--         for i = 1, 2 do
--             if currentdata.teams[team][i] == user_id then
--                 if i == 1 then
--                     currentdata.teams[team][i] = currentdata.teams[team][2]
--                     currentdata.teams[team][2] = nil
--                 else
--                     currentdata.teams[team][i] = nil
--                 end
--             end
--         end
--     elseif actiontype == "joinleave" then
--         ActionTeam("leave", team, nil, user_id)
--         ActionTeam("join", team2, nil, user_id)
--     end
-- end

-- RegisterServerEvent('VICE:StartEvent', function()
--     local source = source
--     local user_id = VICE.getUserId(source)
--     local slotsAvailable = 0
--     if VICE.hasPermission(user_id, "admin.managecommunitypot") then
--         currentdata.eventactive = true
--         for user_id, player_src in pairs(VICE.getUsers()) do
--             gunGamePlayers[user_id] = 1 -- ✅ Add everyone to the gunGamePlayers table
--             VICEclient.removeAllWeapons(player_src, {})
--             VICEclient.giveWeapons(player_src, {
--                 { [weaponProgression[1]] = { ammo = 250 } },
--                 false,
--                 globalpasskey
--             })
--         end
--         TriggerClientEvent("gungame:startFlag", -1)
--         VICE.notify(-1, "~o~Gun Game started. Weapon: " .. weaponProgression[1])
--         TriggerClientEvent("VICE:announceEventJoinable", -1, "Gun Game  Event", slotsAvailable)
--         TriggerClientEvent('chatMessage', -1, "^8[VICE] ", { 128, 128, 128 }, "Gun Game Started", "goodalert")
--         TriggerClientEvent("VICE:ClearEventData",-1)

--         VICE.sendDCLog('event-logs', "VICE Event Logs",
--             "> Event Started \n> Player Name: **" ..
--             VICE.getPlayerName(user_id) .. "**\n> Player PermID: **" .. user_id ..
--             "**\n> Player TempID: **" .. source .. "**")
--     end
-- end)

-- RegisterServerEvent('VICE:EndEvent', function()
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if VICE.hasPermission(user_id, "admin.managecommunitypot") then
--         currentdata = resetdata
--         TriggerClientEvent('VICE:EventInit', -1, false)
--         TriggerClientEvent('chatMessage', -1, "^8[VICE] ", { 128, 128, 128 }, "2v2 Event Ended", "goodalert")
--         VICE.sendDCLog('event-logs', "VICE Event Logs",
--             "> Event Ended \n> Player Name: **" ..
--             VICE.getPlayerName(user_id) .. "**\n> Player PermID: **" .. user_id ..
--             "**\n> Player TempID: **" .. source .. "**")
--     end
-- end)

-- RegisterCommand('eventspectate', function(source)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive and currentdata.teams[team] and VICE.hasPermission(user_id, "admin.managecommunitypot") then
--         local players = {}
--         for _, team in ipairs({ "Red", "Blue" }) do
--             for i = 1, 2 do
--                 if currentdata.teams[team][i] then
--                     table.insert(players, VICE.getUserSource(currentdata.teams[team][i]))
--                 end
--             end
--         end
--         VICE.setBucket(source, 50)
--         TriggerClientEvent('VICE:StartSpectating', source, players)
--     else
--         VICE.notify(source, '~r~The event is empty.')
--     end
-- end)

-- RegisterServerEvent("VICE:Request2v2", function()
--     local source = source
--     TriggerClientEvent("VICE:Update2v2Data", source, currentdata.teams)
-- end)

-- RegisterServerEvent("VICE:Join2v2", function(team)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive and currentdata.teams[team] then
--         local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--         if not alreadyInTeam then
--             ActionTeam("join", team, nil, user_id)
--             TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--         else
--             if currentteam ~= team then
--                 ActionTeam("joinleave", currentteam, team, user_id)
--                 TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--             end
--         end
--     end
-- end)

-- RegisterServerEvent("VICE:Leave2v2", function(team)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive and currentdata.teams[team] then
--         local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--         if alreadyInTeam then
--             ActionTeam("leave", team, nil, user_id)
--             TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--         end
--     end
-- end)

-- RegisterServerEvent("VICE:LeaveEvent", function()
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive then
--         local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--         if alreadyInTeam then
--             ActionTeam("leave", currentteam, nil, user_id)
--             TriggerClientEvent("VICE:Update2v2", source, false)
--             TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--         end
--     end
-- end)


-- RegisterServerEvent("VICE:Create2v2", function()
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive then
--         local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--         if alreadyInTeam then
--             if #currentdata.teams["Red"] == 2 and #currentdata.teams["Blue"] == 2 then
--                 for _, team in ipairs({ "Red", "Blue" }) do
--                     for i = 1, 2 do
--                         if currentdata.teams[team][i] then
--                             local source = VICE.getUserSource(currentdata.teams[team][i])
--                             if source then
--                                 TriggerClientEvent("VICE:Update2v2", source, true)
--                                 VICE.notify(source, '~g~Event Started!')
--                                 VICEclient.giveWeapons(source, { { ["WEAPON_ROOK"] = { ammo = 250 } }, false,
--                                     globalpasskey })
--                                 VICEclient.teleport(source,
--                                     team == "Red" and vector3(-356.64, -2655.59, 6.0) or vector3(-396.04, -2681.61, 6.0))
--                             end
--                         end
--                     end
--                 end
--                 VICE.sendDCLog('event-logs', "VICE Event Logs",
--                     "> Event Started \n> Player Name: **" ..
--                     VICE.getPlayerName(user_id) ..
--                     "**\n> Player PermID: **" .. user_id .. "**\n> Player TempID: **" .. source .. "**")
--             end
--         end
--     end
-- end)

-- RegisterServerEvent("VICE:DiedIn2v2", function(killersrc)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if currentdata.eventactive then
--         local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--         local alreadyInTeam2, currentteam2 = AlreadyInTeam(VICE.getUserId(killersrc))
--         if alreadyInTeam and alreadyInTeam2 then
--             if #currentdata.teams[currentteam] == 1 then
--                 for _, team in ipairs({ "Red", "Blue" }) do
--                     for i = 1, 2 do
--                         if currentdata.teams[team][i] then
--                             local source = VICE.getUserSource(currentdata.teams[team][i])
--                             if source then
--                                 TriggerClientEvent("VICE:EventInit", source, false)
--                                 TriggerClientEvent("VICE:Update2v2", source, false)
--                             end
--                         end
--                     end
--                 end
--                 currentdata = resetdata
--             else
--                 ActionTeam("leave", currentteam, nil, user_id)
--                 VICEclient.teleport(source, vector3(-345.68, -2649.14, 6.0))
--             end
--             VICE.giveBankMoney(VICE.getUserId(killersrc), 25000)
--             TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--         end
--     end
-- end)

-- AddEventHandler("VICE:playerLeave", function(user_id, source)
--     local alreadyInTeam, currentteam = AlreadyInTeam(user_id)
--     if alreadyInTeam then
--         ActionTeam("leave", currentteam, nil, user_id)
--         TriggerClientEvent("VICE:Update2v2Data", -1, currentdata.teams)
--     end
-- end)

-- AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
--     local source = source
--     if first_spawn and currentdata.eventactive and currentdata.teams[team] then
--         Citizen.Wait(5000)
--         VICE.notify(source, '~g~There is a 2v2 event active, Use /joinevent.')
--     end
-- end)

-- -- Battle Royale dosent work Event System
-- local BattleRoyale = {
--     isActive = false,
--     players = {},
--     alivePlayers = {},
--     lootBoxes = {},
--     weapons = {
--         "WEAPON_MOSINCMG",
--         "WEAPON_UMP45CMG"
--     }
-- }

-- -- Start Battle Royale dosent work Event
-- RegisterCommand("startevent", function(source, args, rawCommand)
--     if source == 0 then
--         local eventType = args[1]
--         if eventType == "battleroyale" then
--             BattleRoyale.isActive = true
--             BattleRoyale.players = {}
--             BattleRoyale.alivePlayers = {}
--             BattleRoyale.lootBoxes = {}

--             TriggerClientEvent("chatMessage", -1, "^7^*[VICE Events]", { 180, 0, 0 },
--                 "Battle Royale dosent work event has started! Type /joinevent to join!", "eventalert")
--             TriggerClientEvent("VICE:announceEventJoinable", -1, "Battle Royale dosent work", 15)
--         end
--     end
-- end, true)

-- -- Player joins event
-- RegisterServerEvent("VICE:JoinBattleRoyale")
-- AddEventHandler("VICE:JoinBattleRoyale", function()
--     local source = source
--     local user_id = VICE.getUserId(source)

--     if BattleRoyale.isActive and not BattleRoyale.players[user_id] then
--         -- Store player's original weapons
--         local ped = GetPlayerPed(source)
--         local weapons = {}
--         for i = 1, 9 do
--             local weapon = GetHashKey("WEAPON_" .. i)
--             if HasPedGotWeapon(ped, weapon, false) then
--                 local ammo = GetAmmoInPedWeapon(ped, weapon)
--                 weapons[weapon] = ammo
--             end
--         end

--         -- Add player to event
--         BattleRoyale.players[user_id] = {
--             source = source,
--             name = GetPlayerName(source),
--             originalWeapons = weapons
--         }
--         BattleRoyale.alivePlayers[user_id] = true

--         -- Remove original weapons
--         RemoveAllPedWeapons(ped, true)

--         -- Notify player
--         TriggerClientEvent("VICE:notify", source, "~g~You have joined the Battle Royale dosent work!")
--         TriggerClientEvent("VICE:UpdatePlayerCount", -1, #BattleRoyale.alivePlayers)
--     end
-- end)

-- -- Player opens loot box
-- RegisterServerEvent("VICE:OpenLootBox")
-- AddEventHandler("VICE:OpenLootBox", function(boxId)
--     local source = source
--     local user_id = VICE.getUserId(source)

--     if BattleRoyale.isActive and BattleRoyale.alivePlayers[user_id] and not BattleRoyale.lootBoxes[boxId] then
--         -- Mark box as used
--         BattleRoyale.lootBoxes[boxId] = true

--         -- Give random weapon
--         local randomWeapon = BattleRoyale.weapons[math.random(1, #BattleRoyale.weapons)]
--         GiveWeaponToPed(GetPlayerPed(source), GetHashKey(randomWeapon), 999, false, true)

--         -- Notify player
--         TriggerClientEvent("VICE:notify", source, "~g~You received a " .. randomWeapon)
--         TriggerClientEvent("VICE:RemoveLootBox", -1, boxId)
--     end
-- end)

-- -- Player dies
-- RegisterServerEvent("VICE:PlayerDied")
-- AddEventHandler("VICE:PlayerDied", function()
--     local source = source
--     local user_id = VICE.getUserId(source)

--     if BattleRoyale.isActive and BattleRoyale.alivePlayers[user_id] then
--         -- Remove player from alive players
--         BattleRoyale.alivePlayers[user_id] = nil

--         -- Count remaining players
--         local aliveCount = 0
--         local lastAlivePlayer = nil
--         for playerId, _ in pairs(BattleRoyale.alivePlayers) do
--             aliveCount = aliveCount + 1
--             lastAlivePlayer = playerId
--         end

--         -- Update player count for all players
--         TriggerClientEvent("VICE:UpdatePlayerCount", -1, aliveCount)

--         -- Check if event should end
--         if aliveCount <= 1 then
--             -- Announce winner
--             if lastAlivePlayer then
--                 local winnerName = GetPlayerName(BattleRoyale.players[lastAlivePlayer].source)
--                 TriggerClientEvent("chatMessage", -1, "^7^*[VICE Events]", { 180, 0, 0 },
--                     winnerName .. " has won the Battle Royale dosent work!", "eventalert")

--                 -- Give reward to winner
--                 VICE.giveBankMoney(lastAlivePlayer, math.random(250000, 450000))
--             end

--             -- End event and restore weapons
--             for playerId, playerData in pairs(BattleRoyale.players) do
--                 if playerData.originalWeapons then
--                     for weapon, ammo in pairs(playerData.originalWeapons) do
--                         GiveWeaponToPed(GetPlayerPed(playerData.source), weapon, ammo, false, true)
--                     end
--                 end
--                 TriggerClientEvent("VICE:ClearEventData", playerData.source)
--                 TriggerClientEvent("VICE:Teleport", playerData.source, vector3(-2265.09, 3224.25, 32.81))
--             end

--             -- Reset event
--             BattleRoyale.isActive = false
--             BattleRoyale.players = {}
--             BattleRoyale.alivePlayers = {}
--             BattleRoyale.lootBoxes = {}

--             TriggerClientEvent("VICE:EndEvent", -1)
--         end
--     end
-- end)

-- -- Store original weapons when player joins event
-- RegisterNetEvent("VICE:StoreOriginalWeapons")
-- AddEventHandler("VICE:StoreOriginalWeapons", function(weapons)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if CurrentEvent.players[user_id] then
--         CurrentEvent.players[user_id].originalWeapons = weapons
--     end
-- end)

-- -- Restore original weapons when event ends
-- RegisterNetEvent("VICE:RestoreOriginalWeaponsRequest")
-- AddEventHandler("VICE:RestoreOriginalWeaponsRequest", function()
--     local source = source
--     local user_id = VICE.getUserId(source)
--     if CurrentEvent.players[user_id] and CurrentEvent.players[user_id].originalWeapons then
--         -- Restore each weapon with its original ammo
--         for weapon, ammo in pairs(CurrentEvent.players[user_id].originalWeapons) do
--             GiveWeaponToPed(GetPlayerPed(source), weapon, ammo, false, true)
--         end
--         -- Clear stored weapons
--         CurrentEvent.players[user_id].originalWeapons = nil
--     end
-- end)


