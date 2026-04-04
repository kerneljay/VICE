noFeedbackGiven = false

RegisterServerEvent("VICE:adminTicketNoFeedback")
AddEventHandler("VICE:adminTicketNoFeedback", function(aL)
    local user_id = VICE.getUserId(source)
    local PlayerName = VICE.getPlayerName(user_id)

    noFeedbackGiven = true

    VICE.sendDCLog('feedback', 'VICE Feedback Logs', "> Player Name: **" .. PlayerName .. "**\n> Player PermID: **" .. user_id .. "**\n> Empty Feedback: **No Feedback Given**")
end)

RegisterServerEvent("VICE:adminTicketFeedback")
AddEventHandler("VICE:adminTicketFeedback", function(AdminID, FeedBackType, Message)
    if AdminID == nil then -- AdminID is Admin PermID
        return
    end
    local source = source
    local user_id = VICE.getUserId(source)
    local admintemp = VICE.getUserSource(AdminID)
    local amount = 0
    local colour = "~b~"
    if FeedBackType == "good" then
        colour = "~g~"
        amount = 25000
    elseif FeedBackType == "neutral" then
        colour = "~o~"
        amount = 10000
    elseif FeedBackType == "bad" then
        colour = "~r~"
        amount = 5000
    end
    VICE.giveBankMoney(admintemp, amount)
    if admintemp then
        VICE.notify(admintemp, colour.."You have received £"..getMoneyStringFormatted(amount).." for " ..FeedBackType.." feedback.")
    end
    VICE.notify(source, colour.."You have given "..VICE.getPlayerName(AdminID).." "..FeedBackType.." feedback.")
    if FeedBackType == "good" then
        VICE.sendDCLog('be-like-this', 'VICE Feedback Logs',  "> Admin Name: **" .. VICE.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    elseif FeedBackType == "bad" then
        VICE.sendDCLog('dont-be-like-this', 'VICE Feedback Logs',  "> Admin Name: **" .. VICE.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    else
        VICE.sendDCLog('be-like-this', 'VICE Feedback Logs', "> Admin Name: **" .. VICE.getPlayerName(AdminID) .. "**\n> Admin TempID **"..admintemp.. "**\n> Admin PermID **".. AdminID .. "**\n> Player Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Player TempID **"..source.. "**\n> Player PermID: **" .. user_id .. "**\n> Feedback Type: **" .. FeedBackType .. "**\n> Message: **" .. Message .."**")
    end
end)