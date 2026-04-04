MySQL.createCommand("subscription/set_plushours","UPDATE vice_subscriptions SET plushours = @plushours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_plathours","UPDATE vice_subscriptions SET plathours = @plathours WHERE user_id = @user_id")
MySQL.createCommand("subscription/set_lastused","UPDATE vice_subscriptions SET last_used = @last_used WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_subscription","SELECT * FROM vice_subscriptions WHERE user_id = @user_id")
MySQL.createCommand("subscription/get_all_subscriptions","SELECT * FROM vice_subscriptions")
MySQL.createCommand("subscription/add_id", "INSERT IGNORE INTO vice_subscriptions SET user_id = @user_id, plushours = 0, plathours = 0, last_used = ''")

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_subscriptions SET user_id = @user_id, plushours = 0, plathours = 0, last_used = ''", {user_id = user_id})
end)

function VICE.getSubscriptions(user_id,cb)
    MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
           cb(true, rows[1].plushours, rows[1].plathours, rows[1].last_used)
        else
            cb(false)
        end
    end)
end

RegisterNetEvent("VICE:setPlayerSubscription")
AddEventHandler("VICE:setPlayerSubscription", function(playerid, subtype)
    local source = source
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)
    if VICE.hasGroup(user_id, "Founder") or VICE.hasGroup(user_id, "Lead Developer") or VICE.hasGroup(user_id, "Developer") then
        VICE.prompt(player,"Number of days ","",function(player, hours)
            if tonumber(hours) and tonumber(hours) >= 0 then
                hours = hours * 24
                if subtype == "Plus" then
                    MySQL.asyncQuery("subscription/set_plushours", {user_id = playerid, plushours = hours})
                elseif subtype == "Platinum" then
                    MySQL.asyncQuery("subscription/set_plathours", {user_id = playerid, plathours = hours})
                end
                TriggerClientEvent('VICE:userSubscriptionUpdated', player)
                VICE.getSubscriptions(playerid, function(bool, plushours, plathours, last_used)
                    if not bool then
                        return
                    end
                    if plathours > 0 then
                        VICE.updateInvCap(playerid, 50)
                    elseif plushours > 0 then
                        VICE.updateInvCap(playerid, 40)
                    else
                        VICE.updateInvCap(playerid, 30)
                    end
                end)  
            else
                VICE.notify(player, "~r~Number of days must be a number.")
            end
        end)
    else
        VICE.ACBan(15,user_id,"VICE:setPlayerSubscription")
    end
end)

RegisterNetEvent("VICE:getPlayerSubscription")
AddEventHandler("VICE:getPlayerSubscription", function(playerid)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)
    if playerid then
        VICE.getSubscriptions(playerid, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('VICE:getUsersSubscription', player, playerid, plushours, plathours)
            else
                VICE.notify(player, "~r~Player not found.")
            end
        end)
    else
        VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
            if cb then
                TriggerClientEvent('VICE:setVIPClubData', player, plushours, plathours)
            end
        end)
    end
end)

RegisterNetEvent("VICE:beginSellSubscriptionToPlayer")
AddEventHandler("VICE:beginSellSubscriptionToPlayer", function(subtype)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)
    VICEclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
        usrList = ""
        for k, v in pairs(nplayers) do 
            usrList = usrList .. "[" .. VICE.getUserId(k) .. "]" .. VICE.getPlayerName(VICE.getUserId(k)) .. " | " --add ids to usrList
        end
        if usrList ~= "" then
            VICE.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                target_id = target_id
                if target_id and target_id ~= "" then --validation
                    local target = VICE.getUserSource(tonumber(target_id)) --get source of the new owner id
                    if target then
                        VICE.prompt(player,"Number of days ","",function(player, hours) -- ask for number of hours
                            if tonumber(hours) and tonumber(hours) > 0 then
                                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                                    sellerplushours = rows[1].plushours
                                    sellerplathours = rows[1].plathours
                                    if (subtype == 'Plus' and sellerplushours >= tonumber(hours)*24) or (subtype == 'Platinum' and sellerplathours >= tonumber(hours)*24) then
                                        VICE.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                            if tonumber(amount) and tonumber(amount) > 0 then
                                                VICE.request(target,VICE.getPlayerName(VICE.getUserId(player)).." wants to sell: " ..hours.. " days of "..subtype.." subscription for £"..getMoneyStringFormatted(amount), 30, function(target,ok) --request player if they want to buy sub
                                                    if ok then --bought
                                                        MySQL.query("subscription/get_subscription", {user_id = VICE.getUserId(target)}, function(rows, affected)
                                                            if subtype == "Plus" then
                                                                if VICE.tryFullPayment(VICE.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plushours", {user_id = VICE.getUserId(target), plushours = rows[1].plushours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = sellerplushours - tonumber(hours)*24})
                                                                    VICE.notify(player, '~g~You have sold '..hours..' days of VICE '..subtype..' subscription to '..VICE.getPlayerName(VICE.getUserId(target))..' for £'..amount)
                                                                    VICE.notify(target, '~g~ You\'ve purchased '..hours..' days of VICE '..subtype)
                                                                    VICE.notify(target, '~g~ Your VICE ' .. subtype .. ' has been activated!')
                                                                    VICE.giveBankMoney(user_id,tonumber(amount))
                                                                    VICE.updateInvCap(VICE.getUserId(target), 40)
                                                                else
                                                                    VICE.notify(player, "~r~".. VICE.getPlayerName(VICE.getUserId(target)).." doesn't have enough money!") --notify original owner
                                                                    VICE.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            elseif subtype == "Platinum" then
                                                                if VICE.tryFullPayment(VICE.getUserId(target),tonumber(amount)) then
                                                                    MySQL.execute("subscription/set_plathours", {user_id = VICE.getUserId(target), plathours = rows[1].plathours + tonumber(hours)*24})
                                                                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = sellerplathours - tonumber(hours)*24})
                                                                    VICE.notify(player, '~g~You have sold '..hours..' days of VICE '..subtype..' subscription to '..VICE.getPlayerName(VICE.getUserId(target))..' for £'..amount)
                                                                    VICE.notify(target, '~g~'..VICE.getPlayerName(VICE.getUserId(player))..' has sold '..hours..' days of '..subtype..' subscription to you for £'..amount)
                                                                    VICE.giveBankMoney(user_id,tonumber(amount))
                                                                    VICE.updateInvCap(VICE.getUserId(target), 50)
                                                                    TriggerClientEvent('VICE:refreshGunStorePermissions', target)
                                                                else
                                                                    VICE.notify(player, "~r~".. VICE.getPlayerName(VICE.getUserId(target)).." doesn't have enough money!") --notify original owner
                                                                    VICE.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            end
                                                        end)
                                                    else
                                                        VICE.notify(player, "~r~"..VICE.getPlayerName(VICE.getUserId(target)).." has refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount) --notify owner that refused
                                                        VICE.notify(target, "~r~You have refused to buy " ..hours.. " days of "..subtype.." subscription for £"..amount) --notify new owner that refused
                                                    end
                                                end)
                                            else
                                                VICE.notify(player, "~r~Price of subscription must be a number.")
                                            end
                                        end)
                                    else
                                        VICE.notify(player, "~r~You do not have "..hours.." days of "..subtype..".")
                                    end
                                end)
                            else
                                VICE.notify(player, "~r~Number of days must be a number.")
                            end
                        end)
                    else
                        VICE.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                    end
                else
                    VICE.notify(player, "~r~No Perm ID selected!") --no perm id selected
                end
            end)
        else
            VICE.notify(player, "~r~No players nearby!") --no players nearby
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        MySQL.query("subscription/get_all_subscriptions", {}, function(rows, affected)
            if rows and #rows > 0 then
                for k,v in pairs(rows) do
                    local plushours = v.plushours or 0
                    local plathours = v.plathours or 0
                    local user_id = v.user_id
                    local user = VICE.getUserSource(user_id)
                    if plushours >= 1/60 then
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = plushours-1/60})
                    else
                        MySQL.execute("subscription/set_plushours", {user_id = user_id, plushours = 0})
                    end
                    if plathours >= 1/60 then
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = plathours-1/60})
                    else
                        MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = 0})
                    end
                    if user then
                        TriggerClientEvent('VICE:setVIPClubData', user, plushours, plathours)
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent("VICE:claimWeeklyKit") -- need to add a thing for restricting the kit to actually being weekly
AddEventHandler("VICE:claimWeeklyKit", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getSubscriptions(user_id, function(cb, plushours, plathours, last_used)
        if cb then
            if plathours >= 168 or plushours >= 168 then
                if last_used == '' or (os.time() >= tonumber(last_used+24*60*60*7)) then
                    if plathours >= 168 then
                        VICE.giveInventoryItem(user_id, "wbody|WEAPON_M1911",1, true)
                        VICE.giveInventoryItem(user_id, "wbody|WEAPON_OLYMPIA", 1, true)
                        VICE.giveInventoryItem(user_id, "wbody|WEAPON_UMP45", 1, true)
                        VICE.giveInventoryItem(user_id, "12 Gauge Bullets",250)
                        VICE.giveInventoryItem(user_id, "9mm Bullets", 250)
                        VICE.giveInventoryItem(user_id, "Morphine", 5, true)
                        VICE.giveInventoryItem(user_id, "Taco", 5, true)
                        VICEclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    elseif plushours >= 168 then
                        VICE.giveInventoryItem(user_id, "wbody|WEAPON_M1911", 1, true)
                        VICE.giveInventoryItem(user_id, "wbody|WEAPON_UMP45", 1, true)
                        VICE.giveInventoryItem(user_id, "9mm Bullets",500,true)
                        VICE.giveInventoryItem(user_id, "Morphine", 5, true)
                        VICE.giveInventoryItem(user_id, "Taco", 5, true)
                        VICEclient.setArmour(source, {100, true})
                        MySQL.execute("subscription/set_lastused", {user_id = user_id, last_used = os.time()})
                    else
                        VICE.notify(source, "~r~You need at least 1 week of subscription to redeem the kit.")
                    end
                else
                    VICE.notify(source, "~r~You can only claim your weekly kit once a week.")
                end
            else
                VICE.notify(source, "~r~You require at least 1 week of a subscription to claim a kit.")
            end
        end
    end)
end)

RegisterNetEvent("VICE:fuelAllVehicles")
AddEventHandler("VICE:fuelAllVehicles", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            if plushours > 0 or plathours > 0 then
                if VICE.tryFullPayment(user_id,25000) then
                    exports["vice"]:execute("UPDATE vice_user_vehicles SET fuel_level = 100 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    TriggerClientEvent("vice:PlaySound", source, "playMoney")
                    VICE.notify(source, "~g~Vehicles Refueled.")
                end
            end
        end
    end)
end)


RegisterCommand('redeem', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.checkForRole(user_id, '1461435711977816165') then
        MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                local redeemed = rows[1].redeemed
               -- print('Redeemed:', redeemed)
                if redeemed == 0 then
                   -- print('Redeeming perks...')
                    exports["vice"]:execute("UPDATE vice_subscriptions SET redeemed = 1 WHERE user_id = @user_id", {user_id = user_id}, function() end)
                    VICE.giveBankMoney(user_id, 5000000)
                    VICE.notify(source, '~g~You have redeemed your perks of £500.0000 and 1 Week of Platinum Subscription.')
                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = rows[1].plathours + 168})
                else
                   -- print('Already redeemed.')
                    VICE.notify(source, '~r~You have already redeemed your subscription.')
                end
            else
              --  print('No subscription found for user:', user_id)
              VICE.notify(source, '~r~No subscription found.')
            end
        end)
    else
        VICE.notify(source, '~r~You are not boosting the discord, Unable to redeem your subscription.')
    end
end)

