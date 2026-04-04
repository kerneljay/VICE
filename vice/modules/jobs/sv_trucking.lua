local cfg = module("cfg/cfg_trucking")
local currentJob = {}
local currentVehicle = {}
local playerLevels = {}
local usersInTruckerJob = {}
local rentedTrucks = {}
local spawnedVehicles = {}
local playerXP = {}
local rentedTruck = {}
local amountOfXPGained = 400
RegisterServerEvent('VICE:startTruckerJob')
AddEventHandler('VICE:startTruckerJob', function(jobName, isNextJob)
    local source = source
    local user_id = VICE.getUserId(source)
    local jobConfig = cfg.jobs[jobName]

    if jobConfig == nil then
        print("Error: job name " .. jobName .. " does not exist in cfg.jobs")
        return
    end

    currentJob = jobConfig
    
    if VICE.hasGroup(user_id,"Lorry Driver") then
        if rentedTruck[user_id] then
            exports['vice']:execute("SELECT level, xp FROM vice_trucking WHERE user_id = @user_id", {['@user_id'] = user_id}, function(result)
                playerLevels[user_id] = result[1].level
                playerXP[user_id] = result[1].xp
                spawnedVehicles = {}

                if not isNextJob then
                    VICE.notify(source, "~y~Notice: Goverment regulations have limited trucking to 150 MPH")
                    TriggerClientEvent('VICE:VICESetInitialXPLevels', source, playerXP[user_id], false, false)
                    TriggerClientEvent('VICE:SetInitialXPLevels', source, playerLevels[user_id])
                    usersInTruckerJob[user_id] = true
                end
                TriggerClientEvent("VICE:startTruckerJobCl", source, jobConfig, isNextJob)
            end)
        else
            VICE.notify(source, "~r~You do not currently own or rent any trucks You can get one outside.")
        end
    else
        VICE.notify(source, "~r~You are not a trucker!")
    end
end)

RegisterServerEvent("VICE:TruckerLevelUp")
AddEventHandler("VICE:TruckerLevelUp", function(level)
    local source = source
    local user_id = VICE.getUserId(source)
    local CurLevel = level
    if VICE.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        if CurLevel == 0 then
            CurLevel = 1
        end
        exports['vice']:execute("UPDATE vice_trucking SET level = @level WHERE user_id = @user_id",{['@user_id'] = user_id,['@level'] = CurLevel})
        VICE.notify(source, "~h~~b~LEVEL UP~h~:\n~g~You have reached Trucking Level: " .. CurLevel)
       -- print("[TRUCKING]: Updating LEVEL for " .. VICE.getPlayerName(user_id) .. " to " .. CurLevel)
    else
        VICE.ACBan(15,user_id,"VICE:TruckerLevelUp")
    end
end)

RegisterServerEvent('VICE:jobCompleted')
AddEventHandler('VICE:jobCompleted', function(jobType)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        exports['vice']:execute("SELECT level, xp FROM vice_trucking WHERE user_id = @user_id", {['@user_id'] = user_id}, function(result)
            local currentLevel = result[1].level
            local currentXP = result[1].xp
            local payout = currentJob[1].payout
            if jobType == "Illegal" then
                if currentLevel % 2 == 0 then
                    payout = payout + 600000 -- Extra 600k every 2 levels
                end
                message = "~b~Received ~g~£" .. getMoneyStringFormatted(payout)
                VICE.notify(source, "Received ~g~Dirty Cash ~w~" .. payout)
                VICE.giveDirtyCash(user_id, payout)
                if math.random(1, 100) <= 20 then -- 20% chance
                    for a, b in pairs(VICE.getUsers({})) do
                        if VICE.hasPermission(a, "police.armoury") then
                            TriggerEvent('VICE:PDTruckingCall', b, "Illegal Trucking Activity", GetEntityCoords(GetPlayerPed(source)))
                        end
                    end
                    print("[TRUCKING]: " .. VICE.getPlayerName(user_id) .. " has been reported for illegal trucking activity")
                end
            else
                if currentLevel % 2 == 0 then
                    payout = payout + 300000 -- Extra 300k every 2 levels
                end
                message = "~b~Received ~g~£" .. getMoneyStringFormatted(payout)
                VICE.giveBankMoney(user_id, payout)
            end
            local newXP = currentXP + amountOfXPGained
            exports['vice']:execute("UPDATE vice_trucking SET xp = @xp WHERE user_id = @user_id",{['@user_id'] = user_id,['@xp'] = newXP})
            TriggerClientEvent('VICE:AddPlayerXP', source, amountOfXPGained)
            VICE.notify(source, message)
            TriggerClientEvent('VICE:startNextJob', source)
        end)
    else
      -- VICE.ACBan(15,user_id,"VICE:jobCompleted")
    end
end)

-- Trucking renting --

RegisterServerEvent('VICE:getRentedTrucks')
AddEventHandler('VICE:getRentedTrucks', function()
    local src = source
    local user_id = VICE.getUserId(src)
    exports.ghmattimysql:execute("SELECT vehicle FROM vice_user_vehicles WHERE user_id = @user_id AND rentedtime IS NOT NULL", {
        ['@user_id'] = user_id
    }, function(result)
        if result then
            for k,v in pairs(result) do
                table.insert(rentedTrucks, v.vehicle)
            end
            TriggerClientEvent('VICE:updateOwnedTrucks', src, rentedTrucks)
        end
    end)
end)

RegisterServerEvent('VICE:spawnTruck')
AddEventHandler('VICE:spawnTruck', function(truckName)
    local src = source
    local user_id = VICE.getUserId(src)
    if VICE.hasGroup(user_id,"Lorry Driver") then
        exports.ghmattimysql:execute("SELECT vehicle FROM vice_user_vehicles WHERE user_id = @user_id AND rentedtime IS NOT NULL", {
            ['@user_id'] = user_id
        }, function(result)
            if result ~= nil then
                if spawnedVehicles[truckName] then
                    VICE.notify(src, "~r~That Truck is already out!")
                else
                    TriggerClientEvent('VICE:spawnTruckCl', src, truckName)
                    spawnedVehicles[truckName] = true
                end
            else
                VICE.notify(src, "~r~You have not rented this truck!")
            end
        end)
    else
        VICE.notify(src, "~r~You must be a trucker to spawn a truck!")
    end
end)

RegisterServerEvent('VICE:rentTruck')
AddEventHandler('VICE:rentTruck', function(truckName, truckPrice)
    local src = source
    local user_id = VICE.getUserId(src)
    if VICE.hasGroup(user_id,"Lorry Driver") then
        exports.ghmattimysql:execute("SELECT vehicle FROM vice_user_vehicles WHERE user_id = @user_id AND rentedtime IS NOT NULL", {
            ['@user_id'] = user_id
        }, function(result)
            local isRented = false
            for k,v in pairs(result) do
                if v.vehicle == truckName then
                    isRented = true
                    break
                end
            end
            if VICE.tryBankPayment(user_id, truckPrice) then
                TriggerEvent('VICE:getRentedTrucks')
                VICE.notify(src, "~r~Paid £" .. getMoneyStringFormatted(truckPrice) .. ".")
                rentedTruck[user_id] = true
                exports.ghmattimysql:execute("UPDATE vice_user_vehicles SET rentedtime = NOW() WHERE user_id = @user_id AND vehicle = @vehicle", {
                    ['@user_id'] = user_id,
                    ['@vehicle'] = truckName
                })
            else
                VICE.notify(src, "~r~You cannot afford this :(")
            end
        end)
    else
        VICE.notify(src, "~r~You must be a trucker to rent a truck!")
    end
end)

-- End Truck Renting --

RegisterNetEvent('VICE:setTruck')
AddEventHandler('VICE:setTruck', function(networkId)
    local source = source
    local user_id = VICE.getUserId(source)
    local vehicle = NetworkGetEntityFromNetworkId(networkId)
    if VICE.hasGroup(user_id,"Lorry Driver") and usersInTruckerJob[user_id] then
        spawnedVehicles[vehicle] = true
      --  print("[TRUCKING]: " .. VICE.getPlayerName(user_id) .. " truck set to " .. vehicle)
    else
        VICE.ACBan(15,user_id,"VICE:setTruck")
    end
end)

RegisterServerEvent('VICE:endTruckerJob')
AddEventHandler('VICE:endTruckerJob', function(message)
    local source = source
    local user_id = VICE.getUserId(source)

    if VICE.hasGroup(user_id,"Lorry Driver") then
        TriggerClientEvent('VICE:endTruckerJobCl', source, message)
        usersInTruckerJob[user_id] = nil
        spawnedVehicles = nil
    else
        VICE.ACBan(15,user_id,"VICE:endTruckerJob")
    end
end)

AddEventHandler("VICE:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        local defaultdata = {user_id = user_id, xp = 0, level = 1}
        exports.ghmattimysql:execute("INSERT INTO vice_trucking (user_id,xp,level) VALUES (@user_id,@xp,@level) ON DUPLICATE KEY UPDATE xp = @xp, level = @level", {
            ['@user_id'] = user_id,
            ['@xp'] = defaultdata.xp,
            ['@level'] = defaultdata.level
        })
        Wait(15000)
        exports.ghmattimysql:execute("SELECT level FROM vice_trucking WHERE user_id = @user_id", {
            ['@user_id'] = user_id
        }, function(result)
            playerLevels[user_id] = result[1].level
            TriggerClientEvent('VICE:SetInitialXPLevels', source, playerLevels[user_id], false, false)
        end)
    end
end)