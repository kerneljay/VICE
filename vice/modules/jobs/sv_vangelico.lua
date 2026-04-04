local userRewards = {}
local heistTeam = {}
local pendingInvites = {}
local heistInProgress = false
local TotalSum = 0

--[[ 
    heistTeam = {
        [owner_id] = {
            players = {
                [player_id] = {
                    src = src,
                    user_id = player_id,
                    name = VICE.getPlayerName(player_id),
                    owner = true,
                    hackedComputer = false,
                    inHeist = false
                },
            },
            heistInProgress = false
        },
        [player_id] = {
            players = {},
            heistInProgress = false
        }
    }
 ]]

RegisterServerEvent('VICE:server:rewardItem')
AddEventHandler('VICE:server:rewardItem', function(item)
    local source = source
    local user_id = VICE.getUserId(source)
    local isInHeistTeam = false
    for _, teamPlayer in pairs(heistTeam) do
        if teamPlayer.user_id == user_id then
            isInHeistTeam = true
            break
        end
    end
    if isInHeistTeam then
        local reward = math.random(70000,500000)
        TotalSum = TotalSum + reward
        for _, teamPlayer in pairs(heistTeam) do
            TriggerClientEvent('VICE:client:TotalSum', teamPlayer.src, TotalSum)
        end
        if not userRewards[user_id] then
            userRewards[user_id] = {}
        end
        userRewards[user_id] = {src = source, user_id = user_id, item = item, reward = reward}
    else
        VICE.notify(source, "~r~Don't try that again....")
    end
end)

RegisterServerEvent('VICE:server:notifyPolice')
AddEventHandler('VICE:server:notifyPolice', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if heistInProgress then
       TriggerClientEvent('VICE:GenericAlarm', -1)
        for a, b in pairs(VICE.getUsers({})) do
            if VICE.hasPermission(a, "police.armoury") then
                TriggerClientEvent('chatMessage', b, "^7Robbery in progress at ^2Vangelico Jewelry Store", { 128, 128, 128 }, message, "alert")
                TriggerEvent('VICE:PDHeistRobberyCall', b, "Vangelico Jewelry Store", GetEntityCoords(GetPlayerPed(source)))
            end
        end
    end
end)

RegisterServerEvent("VICE:server:startHeist")
AddEventHandler("VICE:server:startHeist", function(amount)
    local src = source
    local player = VICE.getUserId(src)
    if #VICE.getUsersByPermission('police.armoury') <= 3 then
        VICE.notify(src, "~r~There are not enough police on duty to rob Vangelico.")
        return
    end
    if not VICE.tryBankPayment(player, amount) then
        VICE.notify(src, "~r~You do not have enough money to start the heist!")
            return
    end
    if not heistInProgress then
        heistTeam[player].inHeist = true
        TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam)
        TriggerClientEvent('VICE:client:setInHeist', src, true)
        VICE.notify(src, "~g~Paid £" .. getMoneyStringFormatted(amount))
    else
        VICE.notify(src, "~r~A heist is already in progress!")
    end
end)

RegisterServerEvent("VICE:server:startHeist")
AddEventHandler("VICE:server:startHeist", function()
    local src = source
    local player = VICE.getUserId(src)
    if heistTeam[player] then  
        if heistTeam[player].inHeist then
            if heistTeam[player].owner then
                for _, teamPlayer in pairs(heistTeam) do
                Wait(5000)
                --
                TriggerClientEvent('VICE:jewelryHeistReady', teamPlayer.src, true)
                TriggerClientEvent('VICE:jewelryComputerHackArea', teamPlayer.src, true)
                TriggerClientEvent('VICE:client:setHeist', teamPlayer.src, true)
                TriggerClientEvent('VICE:client:VangelicoSetup', teamPlayer.src, true)
                TriggerClientEvent('VICE:client:setInHeist', teamPlayer.src, true)
                --
                heistTeam[teamPlayer.user_id].inHeist = true
                heistInProgress = true
                VICEclient.giveWeapons(teamPlayer.src, {{["WEAPON_BZGAS"] = {ammo = 25}}, false, globalpasskey})
                print("[VICE] In Heist: " .. VICE.getPlayerName(teamPlayer.user_id))
            end
            TriggerClientEvent('VICE:jewelrySyncDoor', -1, true)
        else
            VICE.notify(src, "~r~Only the heist leader can start the heist!")
        end
    else
        VICE.notify(src, "~r~Unable to start the heist!")
    end
else
    VICE.notify(src, "~r~Player not found in heist team!")
end
end)

function VICE.inHeist(player)
    if heistTeam[player] then
        return heistTeam[player].inHeist
    end
    return false
end

RegisterServerEvent("VICE:server:beginVangelicoSetup")
AddEventHandler("VICE:server:beginVangelicoSetup", function()
    local src = source
    local player = VICE.getUserId(src)

    if #VICE.getUsersByPermission('police.armoury') > 3 then
        if not heistInProgress then
            heistTeam = {}
            heistTeam[player] = {src = src, user_id = player, name = VICE.getPlayerName(player), owner = true, hackedComputer = false, inHeist = false}
            TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam)
            TriggerClientEvent('VICE:client:setInHeist', src, true)
        else
            VICE.notify(src, "~r~A heist is already in progress!")
        end
    else
        VICE.notify(src, "~r~There are not enough police on duty to rob Vangelico.")
    end
end)

RegisterServerEvent('VICE:server:joinHeist')
AddEventHandler('VICE:server:joinHeist', function()
    local src = source
    local player = VICE.getUserId(src)
    if not heistTeam[player] then
        if #heistTeam <=3 then
            if not heistInProgress then
                if pendingInvites[player].invited then
                    heistTeam[player] = {src = src, user_id = player, name = VICE.getPlayerName(player), owner = false, hackedComputer = false, inHeist = false}
                    TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
                    TriggerClientEvent('VICE:client:setInHeist', src, true)
                    TriggerClientEvent('VICE:client:toggleHeistMenu', src, true)
                    pendingInvites[player] = nil
                else
                    VICE.notify(src, "~r~You have no pending invites!")
                end
            else
                VICE.notify(src, "~r~There is currently no heist in progress!")
            end
        else
            VICE.notify(src, "~r~The heist is full!")
        end
    else
        VICE.notify(src, "~r~You are already in the heist!")
    end
end)

RegisterServerEvent('VICE:server:invitePlayerHeist')
AddEventHandler('VICE:server:invitePlayerHeist', function(player_id)
    local src = source
    local player = VICE.getUserId(src)
    if heistTeam[player].owner then
        if #heistTeam <=10 then
            if VICE.getUserSource(tonumber(player_id)) then
                if tonumber(player_id) ~= player then
                    pendingInvites[tonumber(player_id)] = {src = VICE.getUserSource(tonumber(player_id)), user_id = tonumber(player_id), name = VICE.getPlayerName(player_id), invited = true}
                    TriggerClientEvent('VICE:client:invitePlayerHeist', VICE.getUserSource(tonumber(player_id)), VICE.getPlayerName(player))
                else
                    VICE.notify(src, "~r~You cannot invite yourself!")
                end
            else
                VICE.notify(src, "~r~Player is not online!")
            end
        else
            VICE.notify(src, "~r~The heist is full!")
        end
    else
        VICE.notify(src, "~r~Only the heist leader can invite players!")
    end
end)

RegisterServerEvent('VICE:HeistsBuyFullArmour')
AddEventHandler('VICE:HeistsBuyFullArmour', function()
    local src = source
    local player = VICE.getUserId(src)
    if heistTeam[player] then
        if VICE.tryBankPayment(player, 50000) then
            VICEclient.setArmour(src, {100, true})
            VICE.notify(src,"~g~Paid £" .. getMoneyStringFormatted(50000))
        else
            VICE.notify(src, "~r~Not enough money")
        end
    else
        VICE.notify(src, "~r~Wait till the heist starts!")
    end
end)

local hacking = false
local computerHacking = false

RegisterServerEvent("VICE:jewelryHackDoor")
AddEventHandler("VICE:jewelryHackDoor", function()
    local src = source
    local player = VICE.getUserId(src)
    if not hacking then
        hacking = true
        TriggerClientEvent("VICE:jewelryStartDoorHackSf",src)
    else
        VICE.notify(src, "~r~Door is already being hacked!")
    end
end)

RegisterServerEvent("VICE:jewelryHackComputer")
AddEventHandler("VICE:jewelryHackComputer", function()
    local src = source
    local player = VICE.getUserId(src)
    if not computerHacking then
        computerHacking = true
        TriggerClientEvent("VICE:jewelryStartComputerHackSf",src)
    else
        VICE.notify(src, "~r~Computer is already being hacked!")
    end
end)

RegisterServerEvent("VICE:jewelryDoorHackSuccess")
AddEventHandler("VICE:jewelryDoorHackSuccess", function()
    local src = source
    local player = VICE.getUserId(src)
    if hacking then
        hacking = false
        -- for _, teamPlayer in pairs(heistTeam) do
        --     heistTeam[teamPlayer.user_id].hackedDoor = true
        -- end
        --TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
    end
end)

RegisterServerEvent("VICE:jewelryDoorHackFailed")
AddEventHandler("VICE:jewelryDoorHackFailed", function()
    local src = source
    local player = VICE.getUserId(src)
    if hacking then
        hacking = false
    end
end)


RegisterServerEvent("VICE:jewelryComputerHackSuccess")
AddEventHandler("VICE:jewelryComputerHackSuccess", function()
    local src = source
    local player = VICE.getUserId(src)
    if computerHacking then
        computerHacking = false
        for _, teamPlayer in pairs(heistTeam) do
            heistTeam[teamPlayer.user_id].hackedComputer = true
        end
        TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
    end
end)

RegisterServerEvent("VICE:jewelryComputerHackFailed")
AddEventHandler("VICE:jewelryComputerHackFailed", function()
    local src = source
    local player = VICE.getUserId(src)
    if computerHacking then
        computerHacking = false
        -- for _, teamPlayer in pairs(heistTeam) do
        --     --
        -- end
    end
end)

RegisterServerEvent("VICE:server:syncGas")
AddEventHandler("VICE:server:syncGas", function()
    local src = source
    local player = VICE.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('VICE:client:BeginVangelicoHeist', teamPlayer.src)
    end
end)

RegisterServerEvent("VICE:server:syncWinnerScreen")
AddEventHandler("VICE:server:syncWinnerScreen", function()
    local src = source
    local player = VICE.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('VICE:client:syncWinnerScreen', teamPlayer.src)
    end
end)

RegisterServerEvent("VICE:server:winnerSRV")
AddEventHandler("VICE:server:winnerSRV", function()
    local src = source
    local player = VICE.getUserId(src)

    for _, teamPlayer in pairs(heistTeam) do
        TriggerClientEvent('VICE:client:outside', teamPlayer.src)
    end
    TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
end)

RegisterServerEvent("VICE:server:cancelHeist")
AddEventHandler("VICE:server:cancelHeist", function()
    local src = source
    local player = VICE.getUserId(src)

    if heistTeam[player].owner then
        for i, teamPlayer in pairs(heistTeam) do
            TriggerClientEvent('VICE:client:setHeist', teamPlayer.src, false)
        end
        heistInProgress = false
        heistTeam = {}
        TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
    else
        VICE.notify(src, "~r~Only the heist leader can cancel the heist!")
    end
end)

RegisterServerEvent("VICE:server:getHeistData")
AddEventHandler("VICE:server:getHeistData", function()
    local src = source
    local player = VICE.getUserId(src)
    if heistTeam then
        TriggerClientEvent("VICE:client:sendHeistData", src, heistTeam)
    end
end)

RegisterServerEvent('VICE:server:leaveHeist')
AddEventHandler('VICE:server:leaveHeist', function()
    local src = source
    local player = VICE.getUserId(src)

    if VICE.inHeist(player) then
        heistTeam[player] = nil
        TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
        VICE.notify(src, "~r~Left the heist!")
    else
        VICE.notify(src, "~r~You are not in a heist?")
    end
end)

RegisterServerEvent('VICE:server:kickHeist')
AddEventHandler('VICE:server:kickHeist', function(SelectedDetails)
    local src = source
    local player = VICE.getUserId(src)
    if SelectedDetails.user_id ~= player then
        if heistTeam[player].owner then
            for i, teamPlayer in pairs(heistTeam) do
                if teamPlayer.src == SelectedDetails.src then
                    heistTeam[i] = nil
                    break
                end
            end
            TriggerClientEvent('VICE:client:setHeist', SelectedDetails.src, false)
            TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam) 
        else
            VICE.notify(src, "~r~Only the heist leader can kick players!")
        end
    else
        VICE.notify(src, "~r~You cannot kick yourself!")
    end
end)

RegisterServerEvent('VICE:server:promoteHeist')
AddEventHandler('VICE:server:promoteHeist', function(SelectedDetails)
    local src = source
    local player = VICE.getUserId(src)
    if SelectedDetails.user_id ~= player then
        if heistTeam[player].owner then
            heistTeam[SelectedDetails.user_id].owner = true
            heistTeam[player].owner = false
            TriggerClientEvent('VICE:client:BeginSetupVangelico', SelectedDetails.src, true)
            TriggerClientEvent("VICE:client:sendHeistData", -1, heistTeam)
        else
            VICE.notify(src, "~r~Only the heist leader can promote players!")
        end
    else
        VICE.notify(src, "~r~You are already the heist leader!")
    end
end)

RegisterServerEvent('VICE:server:sellRewardItems')
AddEventHandler('VICE:server:sellRewardItems', function(TotalSumOfMoney)
    local src = source
    local player = VICE.getUserId(src)
    if player then
        local cut = TotalSumOfMoney / #heistTeam
        for _, teamPlayer in pairs(heistTeam) do
            VICE.giveDirtyCash(teamPlayer.user_id, cut)
            TriggerClientEvent("VICE:client:TotalSum", teamPlayer.src, 0)
            TriggerClientEvent("VICE:client:winVangelicoHeist", teamPlayer.src, math.floor(cut), teamPlayer.name)
        end
        VICE.sendDCLog("vangelico-heist", "VICE Vangelico Heist Logs", "Started talkin to dat guy, money thing: " .. math.floor(cut))
        VICE.notify(src,'~b~Received ~r~' .. math.floor(cut) .. ' ~b~dirty cash')
        userRewards[player] = {}
        if VICE.inHeist(player) then
            heistInProgress = false
            heistTeam = {}
        end
    end
end)

RegisterServerEvent('VICE:server:startGas')
AddEventHandler('VICE:server:startGas', function()
    TriggerClientEvent('VICE:client:startGas', -1)
end)

RegisterServerEvent("VICE:server:syncMarker")
AddEventHandler("VICE:server:syncMarker", function(index)
    TriggerClientEvent('VICE:client:markerSync', -1,index)
end)

RegisterServerEvent('VICE:server:insideLoop')
AddEventHandler('VICE:server:insideLoop', function()
    TriggerClientEvent('VICE:client:insideLoop', -1)
end)

RegisterServerEvent('VICE:server:lootSync')
AddEventHandler('VICE:server:lootSync', function(ggg, index)
    TriggerClientEvent('VICE:client:lootSync', -1, ggg, index)
end)

RegisterServerEvent('VICE:server:globalObject')
AddEventHandler('VICE:server:globalObject', function(obj, random)
    TriggerClientEvent('VICE:client:globalObject', -1, obj, random)
end)

RegisterServerEvent('VICE:server:smashSync')
AddEventHandler('VICE:server:smashSync', function(sceneConfig)
    TriggerClientEvent('VICE:client:smashSync', -1, sceneConfig)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local player = VICE.getUserId(src)
    if userRewards[player] then
        userRewards[player] = nil
    end
    if VICE.inHeist(player) then
        heistTeam[player] = nil
    end
end)