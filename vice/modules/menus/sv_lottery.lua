local ticketPrice = 50000
local potAmount = 0
local participantCount = 0
local personalAmountBought = {}
local participants = {}

RegisterServerEvent('VICE:getLotteryInfo')
AddEventHandler('VICE:getLotteryInfo', function()
    local source = source
    TriggerClientEvent('VICE:setLotteryInfo', source, ticketPrice, potAmount, participantCount)
end)

RegisterServerEvent('VICE:setPersonalAmountBought')
AddEventHandler('VICE:setPersonalAmountBought', function(user_id, amount)
    local amount = tonumber(amount)
    local ticketPrice = 50000
    if user_id then
        if not participants[user_id] then
            participantCount = participantCount + 1
        end
        participants[user_id] = true
        potAmount = potAmount + ticketPrice * amount
        personalAmountBought[user_id] = (personalAmountBought[user_id] or amount) + amount
        updateLotteryInfo(ticketPrice, potAmount, participantCount)
        TriggerClientEvent('VICE:setPersonalAmountBought', VICE.getUserSource(user_id), personalAmountBought[user_id])
    end
end)

function updateLotteryInfo(newTicketPrice, newPotAmount, newParticipantCount)
    ticketPrice = newTicketPrice
    potAmount = newPotAmount
    participantCount = newParticipantCount
    TriggerClientEvent('VICE:setLotteryInfo', -1, ticketPrice, potAmount, participantCount)
end

function updatePersonalAmountBought(playerId, amount)
    personalAmountBought[playerId] = amount
    TriggerClientEvent('VICE:setPersonalAmountBought', playerId, personalAmountBought[playerId])
end

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if not personalAmountBought[user_id] then
            personalAmountBought[user_id] = 0
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(6000)
        local hour = os.date("%H")

        if hour == "12" then
            if #participants > 0 then
                local winner
                repeat
                    winner = math.random(#participants)
                until VICE.getUserSource(winner)
            
                VICE.notify(VICE.getUserSource(winner), "~g~You have won the lottery! £" .. getMoneyStringFormatted(potAmount) .. "!")
                TriggerClientEvent('VICE:setPersonalAmountBought', VICE.getUserSource(winner), 0)
            end
            ticketPrice = 0
            potAmount = 0
            participantCount = 0
            personalAmountBought = {}
            participants = {}
            updateLotteryInfo(ticketPrice, potAmount, participantCount)
        end
    end
end)