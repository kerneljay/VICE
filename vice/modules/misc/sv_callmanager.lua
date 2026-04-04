local tickets = {}
local callID = 0
local cooldown = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000)
        for k,v in pairs(cooldown) do
            if cooldown[k].time > 0 then
                cooldown[k].time = cooldown[k].time - 1
            end
        end
    end
end)

for _, command in ipairs({"calladmin", "help"}) do
    RegisterCommand(command, function(source)
        local user_id = VICE.getUserId(source)
        local user_source = VICE.getUserSource(user_id)
        local currentStaff = VICE.getUsersByPermission('admin.tickets')
        
        local bucket = GetPlayerRoutingBucket(user_source)
        if bucket == 100 then 
          VICE.notify(user_source, '~r~You can not call admin in a shadow lobby silly')
           return
        end 
        for k, v in pairs(cooldown) do
            if k == user_id and v.time > 0 then
                VICE.notify(user_source, "~r~You have already called an admin, please wait 5 minutes before calling again.")
                return
            end
        end
        if #currentStaff >= 0 then
            TriggerClientEvent("VICE:startPhoneAnim", user_source)
            VICE.prompt(user_source, "Please enter a call reason:", "", function(player, reason)
                if reason ~= "" then
                    if #reason >= 10 then
                        callID = callID + 1
                        tickets[callID] = {
                            permID = user_id,
                            name = VICE.getPlayerName(user_id),
                            tempID = user_source,
                            reason = reason,
                            type = 'admin',
                        }
                        cooldown[user_id] = { time = 5 } -- 5 Minutes
                        
                        for k, v in pairs(VICE.getUsers({})) do
                            TriggerClientEvent("VICE:addEmergencyCall", v, callID, VICE.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'admin')
                        end
                        
                        VICE.notify(user_source, "~b~Your request has been sent.")
                       -- VICE.notify(user_source, "~y~If you are reporting a player, you can also create a report @ https://discord.gg/UTzM4kcCjG")
                    else
                        VICE.notify(user_source, "~r~Please enter a minimum of 10 characters.")
                    end
                else
                    VICE.notify(user_source, "~r~Please enter a valid reason.")
                end
                TriggerClientEvent("VICE:clearPhoneAnim", user_source)
            end)
        else
            VICE.notify(user_source, "~r~There are no admins online currently to take your request.")
        end
    end)
end

RegisterCommand("999", function(source)
    local user_id = VICE.getUserId(source)
    local user_source = VICE.getUserSource(user_id)
    TriggerClientEvent("VICE:startPhoneAnim", user_source)
    VICE.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason == "" then
            reason = "Empty Message"
            VICE.notify(user_source, reason)
        end
        callID = callID + 1
        tickets[callID] = {
            name = VICE.getPlayerName(user_id),
            permID = user_id,
            tempID = user_source,
            reason = reason,
            type = 'met'
        }
        for k, v in pairs(VICE.getUsers({})) do
            TriggerClientEvent("VICE:addEmergencyCall", v, callID, VICE.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'met')
        end
        VICE.notify(user_source, "~g~Your message has been placed.")
        TriggerClientEvent("VICE:clearPhoneAnim", user_source)
    end)
end)

RegisterCommand("aa", function(source)
    local user_id = VICE.getUserId(source)
    local user_source = VICE.getUserSource(user_id)
    TriggerClientEvent("VICE:startPhoneAnim", user_source)
    VICE.prompt(user_source, "Enter your message: ", "", function(player, reason)
        if reason == "" then
            reason = "Empty Message"
            VICE.notify(user_source, reason)
        end
        callID = callID + 1
        tickets[callID] = {
            name = VICE.getPlayerName(user_id),
            permID = user_id,
            tempID = user_source,
            reason = reason,
            type = 'aa'
        }
        for k, v in pairs(VICE.getUsers({})) do
            TriggerClientEvent("VICE:addEmergencyCall", v, callID, VICE.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'aa')
        end
        VICE.notify(user_source, "~g~Your message has been placed.")
        TriggerClientEvent("VICE:clearPhoneAnim", user_source)
    end)
end)

RegisterCommand("08001111", function(source)
    local user_id = VICE.getUserId(source)
    local user_source = VICE.getUserSource(user_id)
    TriggerClientEvent("VICE:startPhoneAnim", user_source)
    VICE.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason ~= "" then
            VICE.notify(user_source, "~b~We are not here for you, Your call is going to get laughed at.")
        else
            VICE.notify(user_source, "~r~Please enter a valid reason.")
        end
        TriggerClientEvent("VICE:clearPhoneAnim", user_source)
    end)
end)


RegisterCommand("111", function(source)
    local user_id = VICE.getUserId(source)
    local user_source = VICE.getUserSource(user_id)
    TriggerClientEvent("VICE:startPhoneAnim", user_source)
    VICE.prompt(user_source, "Please enter call reason: ", "", function(player, reason)
        if reason ~= "" then
            callID = callID + 1
            tickets[callID] = {
                name = VICE.getPlayerName(user_id),
                permID = user_id,
                tempID = user_source,
                reason = reason,
                type = 'nhs'
            }
            for k, v in pairs(VICE.getUsers({})) do
                TriggerClientEvent("VICE:addEmergencyCall", v, callID, VICE.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'nhs')
            end
            VICE.notify(user_source, "~g~Sent NHS Call.")
        else
            VICE.notify(user_source, "~r~Please enter a valid reason.")
        end
        TriggerClientEvent("VICE:clearPhoneAnim", user_source)
    end)
end)

local savedPositions = {}
RegisterCommand("return", function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    pendingFeedback = false
    
    if VICE.hasPermission(user_id, 'admin.tickets') then
        if savedPositions[user_id] then
            pendingFeedback = true
            VICE.setBucket(source, savedPositions[user_id].bucket)
            VICEclient.teleport(source, {table.unpack(savedPositions[user_id].coords)})
            VICE.notify(source, '~g~Returned to position.')
            savedPositions[user_id] = nil
            TriggerClientEvent('VICE:sendTicketInfo', source)
            VICEclient.staffMode(source, {false})
            SetTimeout(1000, function()
                VICEclient.setPlayerCombatTimer(source, {0})
            end)
        else
            VICE.notify(source, "~r~Unable to find the last location.")
        end
    end
end)

RegisterNetEvent("VICE:TakeTicket")
AddEventHandler("VICE:TakeTicket", function(ticketID)
    local user_id = VICE.getUserId(source)
    local admin_source = VICE.getUserSource(user_id)
    if tickets[ticketID] then
        for k, v in pairs(tickets) do
            if ticketID == k then
                if tickets[ticketID].type == 'admin' and VICE.hasPermission(user_id, "admin.tickets") then
                    if VICE.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            local adminbucket = GetPlayerRoutingBucket(admin_source)
                            local playerbucket = GetPlayerRoutingBucket(v.tempID)
                            savedPositions[user_id] = {bucket = adminbucket, coords = GetEntityCoords(GetPlayerPed(admin_source))}
                            if adminbucket ~= playerbucket then
                                VICE.setBucket(admin_source, playerbucket)
                                VICE.notify(admin_source, '~g~Player was in another bucket, you have been set into their bucket.')
                            end
                            VICEclient.getPosition(v.tempID, {}, function(coords)
                                VICEclient.staffMode(admin_source, {true})
                                TriggerClientEvent('VICE:sendTicketInfo', admin_source, v.permID, v.name, v.reason)
                                local ticketPay = 0
                                if VICE.hasGroup(user_id,"Founder") then
                                    ticketPay = 30000
                                elseif VICE.hasGroup(user_id,"Lead Developer") then
                                    ticketPay = 28000
                                elseif VICE.hasGroup(user_id,"Developer") then
                                    ticketPay = 26000
                                elseif VICE.hasGroup(user_id,"Community Manager") then
                                    ticketPay = 25000
                                elseif VICE.hasGroup(user_id,"Staff Manager") then    
                                    ticketPay = 23000
                                elseif VICE.hasGroup(user_id,"Head Administrator") then
                                    ticketPay = 22000
                                elseif VICE.hasGroup(user_id,"Senior Administrator") then
                                    ticketPay = 20000
                                elseif VICE.hasGroup(user_id,"Administrator") then
                                    ticketPay = 19000
                                elseif VICE.hasGroup(user_id,"Senior Moderator") then
                                    ticketPay = 18000
                                elseif VICE.hasGroup(user_id,"Moderator") then
                                    ticketPay = 17000
                                elseif VICE.hasGroup(user_id,"Support Team") then
                                    ticketPay = 15000
                                elseif VICE.hasGroup(user_id,"Trial Staff") then
                                    ticketPay = 10000
                                end
                                exports['vice']:execute("SELECT * FROM `vice_staff_tickets` WHERE user_id = @user_id", {user_id = user_id}, function(result)
                                    if result then 
                                        for k,v in pairs(result) do
                                            if v.user_id == user_id then
                                                exports['vice']:execute("UPDATE vice_staff_tickets SET ticket_count = @ticket_count, username = @username WHERE user_id = @user_id", {user_id = user_id, ticket_count = v.ticket_count + 1, username = VICE.getPlayerName(user_id)}, function() end)
                                                return
                                            end
                                        end
                                        exports['vice']:execute("INSERT INTO vice_staff_tickets (`user_id`, `ticket_count`, `username`) VALUES (@user_id, @ticket_count, @username);", {user_id = user_id, ticket_count = 1, username = VICE.getPlayerName(user_id)}, function() end) 
                                    end
                                end)
                                VICE.giveBankMoney(user_id, ticketPay)
                                VICE.notify(admin_source, "~g~You earned £"..getMoneyStringFormatted(ticketPay).." for being a cutie.")
                                VICE.notify(v.tempID, "~g~An admin has taken your ticket.")
                                TriggerClientEvent('VICE:smallAnnouncement', v.tempID, 'ticket accepted', "Your admin ticket has been accepted by "..VICE.getPlayerName(user_id), 33, 10000)
                                VICE.sendDCLog('adminticket-logs',"VICE Ticket Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..admin_source.."**\n> Admin PermID: **"..user_id.."**\n> Player Name: **"..v.name.."**\n> Player PermID: **"..v.permID.."**\n> Player TempID: **"..v.tempID.."**\n> Reason: **"..v.reason.."**")
                                VICEclient.teleport(admin_source, {table.unpack(coords)})
                                TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                                tickets[ticketID] = nil
                                while not pendingFeedback do
                                    Citizen.Wait(0) 
                                end
                                TriggerClientEvent('VICE:adminTicketFeedback', v.tempID, admin_source)
                                pendingFeedback = false
                            end)
                        else
                            VICE.notify(admin_source, "~r~You can't take your own ticket!")
                        end
                    else
                        VICE.notify(admin_source, "~r~You cannot take a ticket from an offline player.")
                        TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'met' and VICE.hasPermission(user_id, "police.armoury") then
                    if VICE.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            if v.tempID then
                                VICE.notify(v.tempID, "~b~Your MET Police call has been accepted!")
                            end
                            tickets[ticketID] = nil
                            TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                        else
                            VICE.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'aa' and VICE.hasPermission(user_id, "aa.menu") then
                    if VICE.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            if v.tempID then
                                VICE.notify(v.tempID, "~y~An AA Mechanic is enroute to your location.")
                            end
                            tickets[ticketID] = nil
                            TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                        else
                            VICE.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                    end
                elseif tickets[ticketID].type == 'nhs' and VICE.hasPermission(user_id, "nhs.menu") then
                    if VICE.getUserSource(v.permID) then
                        if user_id ~= v.permID then
                            VICE.notify(v.tempID, "~g~Your NHS call has been accepted!")
                            tickets[ticketID] = nil
                            TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                        else
                            VICE.notify(admin_source, "~r~You can't take your own call!")
                        end
                    else
                        TriggerClientEvent("VICE:removeEmergencyCall", -1, ticketID)
                    end
                end
            end
        end
    end         
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    local user_id = VICE.getUserId(source)
    local hasTicket = false
    for id, ticket in pairs(tickets) do
        if ticket.permID == user_id then
            tickets[id] = nil
            hasTicket = true
            break
        end
    end
end)

AddEventHandler("VICE:PDRobberyCall", function(source, store, position)
    local source = source
    local user_id = VICE.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Store Robbery',
        permID = 999,
        tempID = nil,
        reason = 'Robbery in progress at '..store,
        type = 'met'
    }
    for k, v in pairs(VICE.getUsers({})) do
        TriggerClientEvent("VICE:addEmergencyCall", v, callID, 'Store Robbery', 999, position, 'Robbery in progress at '..store, 'met')
    end
end)

AddEventHandler("VICE:PDHeistRobberyCall", function(source, store, position)
    local source = source
    local user_id = VICE.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Heist Robbery',
        permID = 999,
        tempID = nil,
        reason = 'Robbery in progress at '..store,
        type = 'met'
    }
    for k, v in pairs(VICE.getUsers({})) do
        TriggerClientEvent("VICE:addEmergencyCall", v, callID, 'Heist Robbery', 999, position, 'Robbery in progress at '..store, 'met')
    end
end)

AddEventHandler("VICE:PDTruckingCall", function(source, store, position)
    local source = source
    local user_id = VICE.getUserId(source)
    callID = callID + 1
    tickets[callID] = {
        name = 'Illegal Trucking Activity',
        permID = 999,
        tempID = nil,
        reason = 'Illegal Trucking in progress',
        type = 'met'
    }
    for k, v in pairs(VICE.getUsers({})) do
        TriggerClientEvent("VICE:addEmergencyCall", v, callID, 'Illegal Trucking', 999, position, 'Illegal Trucking in progress', 'met')
    end
end)

RegisterNetEvent("VICE:NHSComaCall")
AddEventHandler("VICE:NHSComaCall", function()
    local user_id = VICE.getUserId(source)
    local user_source = VICE.getUserSource(user_id)
    local reason = 'Immediate Attention'
    callID = callID + 1
    tickets[callID] = {
        name = VICE.getPlayerName(user_id),
        permID = user_id,
        tempID = user_source,
        reason = reason,
        type = 'nhs'
    }
    for k, v in pairs(VICE.getUsers({})) do
        TriggerClientEvent("VICE:addEmergencyCall", v, callID, VICE.getPlayerName(user_id), user_id, GetEntityCoords(GetPlayerPed(user_source)), reason, 'nhs')
    end
end)