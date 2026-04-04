local coinflipTables = {
    [1] = false,
    [2] = false,
    [5] = false,
    [6] = false,
}

local linkedTables = {
    [1] = 2,
    [2] = 1,
    [5] = 6,
    [6] = 5,
}

local coinflipGameInProgress = {}
local coinflipGameData = {}

local betId = 0

function giveChips(source,amount)
    local user_id = VICE.getUserId(source)
    MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = amount})
    TriggerClientEvent('VICE:chipsUpdated', source)
end

AddEventHandler('playerDropped', function (reason)
    local source = source
    for k,v in pairs(coinflipTables) do
        if v == source then
            coinflipTables[k] = false
            coinflipGameData[k] = nil
        end
    end
end)

RegisterNetEvent("VICE:requestCoinflipTableData")
AddEventHandler("VICE:requestCoinflipTableData", function()   
    local source = source
    TriggerClientEvent("VICE:sendCoinflipTableData",source,coinflipTables)
end)

RegisterNetEvent("VICE:requestSitAtCoinflipTable")
AddEventHandler("VICE:requestSitAtCoinflipTable", function(chairId)
    local source = source
    if source then
        for k,v in pairs(coinflipTables) do
            if v == source then
                coinflipTables[k] = false
                return
            end
        end
        coinflipTables[chairId] = source
        local currentBetForThatTable = coinflipGameData[chairId]
        TriggerClientEvent("VICE:sendCoinflipTableData",-1,coinflipTables)
        TriggerClientEvent("VICE:sitAtCoinflipTable",source,chairId,currentBetForThatTable)
    end
end)

RegisterNetEvent("VICE:leaveCoinflipTable")
AddEventHandler("VICE:leaveCoinflipTable", function(chairId)
    local source = source
    if source then 
        for k,v in pairs(coinflipTables) do 
            if v == source then 
                coinflipTables[k] = false
                coinflipGameData[k] = nil
            end
        end
        TriggerClientEvent("VICE:sendCoinflipTableData",-1,coinflipTables)
    end
end)

RegisterNetEvent("VICE:proposeCoinflip")
AddEventHandler("VICE:proposeCoinflip",function(betAmount)
    local source = source
    local user_id = VICE.getUserId(source)
    betId = betId+1
    if betAmount then 
        if coinflipGameData[betId] == nil then
            coinflipGameData[betId] = {}
        end
        if not coinflipGameInProgress[betId] then
            if tonumber(betAmount) then
                betAmount = tonumber(betAmount)
                if betAmount >= 100000 then
                    MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
                        chips = rows[1].chips
                        if chips >= betAmount then
                            TriggerClientEvent('VICE:chipsUpdated', source)
                            if coinflipGameData[betId][source] == nil then
                                coinflipGameData[betId][source] = {}
                            end
                            coinflipGameData[betId] = {betId = betId, betAmount = betAmount, user_id = user_id}
                            for k,v in pairs(coinflipTables) do
                                if v == source then
                                    TriggerClientEvent('VICE:addCoinflipProposal', source, betId, {betId = betId, betAmount = betAmount, user_id = user_id})
                                    if coinflipTables[linkedTables[k]] then
                                        TriggerClientEvent('VICE:addCoinflipProposal', coinflipTables[linkedTables[k]], betId, {betId = betId, betAmount = betAmount, user_id = user_id})
                                    end
                                end
                            end
                            VICE.notify(source, "~g~Bet placed: " .. getMoneyStringFormatted(betAmount) .. " chips.")
                        else 
                            VICE.notify(source, "Not enough chips!")
                        end
                    end)
                else
                    VICE.notify(source, 'Minimum bet at this table is £100,000.')
                    return
                end
            end
        end
    else
       VICE.notify(source, "Error betting!")
    end
end)

RegisterNetEvent("VICE:requestCoinflipTableData")
AddEventHandler("VICE:requestCoinflipTableData", function()   
    local source = source
    TriggerClientEvent("VICE:sendCoinflipTableData",source,coinflipTables)
end)

RegisterNetEvent("VICE:cancelCoinflip")
AddEventHandler("VICE:cancelCoinflip", function()   
    local source = source
    local user_id = VICE.getUserId(source)
    for k,v in pairs(coinflipGameData) do
        if v.user_id == user_id then
            coinflipGameData[k] = nil
            TriggerClientEvent("VICE:cancelCoinflipBet",-1,k)
        end
    end
end)

RegisterNetEvent("VICE:acceptCoinflip")
AddEventHandler("VICE:acceptCoinflip", function(gameid)   
    local source = source
    local user_id = VICE.getUserId(source)
    for k,v in pairs(coinflipGameData) do
        if v.betId == gameid then
            MySQL.query("casinochips/get_chips", {user_id = user_id}, function(rows, affected)
                chips = rows[1].chips
                if chips >= v.betAmount then
                    MySQL.execute("casinochips/remove_chips", {user_id = user_id, amount = v.betAmount})
                    TriggerClientEvent('VICE:chipsUpdated', source)
                    MySQL.execute("casinochips/remove_chips", {user_id = v.user_id, amount = v.betAmount})
                    TriggerClientEvent('VICE:chipsUpdated', VICE.getUserSource(v.user_id))
                    local coinFlipOutcome = math.random(0,1)
                    if coinFlipOutcome == 0 then
                        local game = {amount = v.betAmount, winner = VICE.getPlayerName(user_id), loser = VICE.getPlayerName(VICE.getUserSource(v.user_id))}
                        TriggerClientEvent('VICE:coinflipOutcome', source, true, game)
                        TriggerClientEvent('VICE:coinflipOutcome', VICE.getUserSource(v.user_id), false, game)
                        Wait(10000)
                        MySQL.execute("casinochips/add_chips", {user_id = user_id, amount = v.betAmount*2})
                        TriggerClientEvent('VICE:chipsUpdated', source)
                        VICE.sendDCLog('coinflip-bet',"VICE Coinflip Logs", "> Winner Name: **"..VICE.getPlayerName(user_id).."**\n> Winner TempID: **"..source.."**\n> Winner PermID: **"..user_id.."**\n> Loser Name: **"..VICE.getPlayerName(VICE.getUserSource(v.user_id)).."**\n> Loser TempID: **"..VICE.getUserSource(v.user_id).."**\n> Loser PermID: **"..v.user_id.."**\n> Amount: **"..getMoneyStringFormatted(v.betAmount).."**")
                    else
                        local game = {amount = v.betAmount, winner = VICE.getPlayerName(VICE.getUserSource(v.user_id)), loser = VICE.getPlayerName(user_id)}
                        TriggerClientEvent('VICE:coinflipOutcome', source, false, game)
                        TriggerClientEvent('VICE:coinflipOutcome', VICE.getUserSource(v.user_id), true, game)
                        Wait(10000)
                        MySQL.execute("casinochips/add_chips", {user_id = v.user_id, amount = v.betAmount*2})
                        TriggerClientEvent('VICE:chipsUpdated', VICE.getUserSource(v.user_id))
                        VICE.sendDCLog('coinflip-bet',"VICE Coinflip Logs", "> Winner Name: **"..VICE.getPlayerName(VICE.getUserSource(v.user_id)).."**\n> Winner TempID: **"..VICE.getUserSource(v.user_id).."**\n> Winner PermID: **"..v.user_id.."**\n> Loser Name: **"..VICE.getPlayerName(user_id).."**\n> Loser TempID: **"..source.."**\n> Loser PermID: **"..user_id.."**\n> Amount: **"..getMoneyStringFormatted(v.betAmount).."**")
                    end
                else 
                    VICE.notify(source, "Not enough chips!")
                end
            end)
        end
    end
end)

