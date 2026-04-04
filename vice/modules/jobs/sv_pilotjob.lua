local pilotJobUsers = {}
local pilotLevels = {}  

RegisterServerEvent("VICE:startPilotJob")
AddEventHandler("VICE:startPilotJob", function(planeIndex)
    local src = source
    local user_id = VICE.getUserId(src)
    print("Starting pilot job for plane index:", planeIndex)
    pilotJobUsers[user_id] = true
    TriggerClientEvent("VICE:pilotJobStarted", src, planeIndex)
    TriggerClientEvent("VICE:updateClientPilotLevel", src, pilotLevels[user_id] or 0)  -- Trigger to update client's pilot level
end)

RegisterServerEvent("VICE:setOnPilotDuty")
AddEventHandler("VICE:setOnPilotDuty", function(onDuty)
    local src = source
    local user_id = VICE.getUserId(src)
    pilotJobUsers[user_id] = onDuty
end)

RegisterServerEvent('VICE:pilotJobCreatePlane')
AddEventHandler('VICE:pilotJobCreatePlane', function(planeType, planeLoc, tugLoc)
    local src = source
    local user_id = VICE.getUserId(src)
    if pilotJobUsers[user_id] then 
        TriggerClientEvent('VICE:spawnVehicle', src, planeType, planeLoc, tugLoc, true, true, true, 100)
    else
        print("User " .. user_id .. " tried to create a plane but is not on the pilot job.")
    end
end)

RegisterCommand('setpilotduty', function(source, args, rawCommand)
    local src = source
    local user_id = VICE.getUserId(src)
    TriggerClientEvent('VICE:setOnPilotDuty', src, true)
end)

RegisterNetEvent("VICE:getPilotLevel")
AddEventHandler("VICE:getPilotLevel", function()
    local src = source
    local user_id = VICE.getUserId(src)
    local level = pilotLevels[user_id] or 0  

    TriggerClientEvent("VICE:updateClientPilotLevel", src, level)
end)

RegisterServerEvent('VICE:pilotJobReset')
AddEventHandler('VICE:pilotJobReset', function()
    local src = source
    local user_id = VICE.getUserId(src)
    pilotJobUsers[user_id] = false
    print("User " .. user_id .. " has ended their shift.")
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local user_id = VICE.getUserId(src)
    if pilotJobUsers[user_id] then
        print("User " .. user_id .. " was on the pilot job but has disconnected.")
        pilotJobUsers[user_id] = nil
        pilotLevels[user_id] = nil  
    end
end)

RegisterServerEvent('VICE:increasePilotLevel')
AddEventHandler('VICE:increasePilotLevel', function(levelIncrease)
    local src = source
    local user_id = VICE.getUserId(src)
    if pilotJobUsers[user_id] then
        pilotLevels[user_id] = (pilotLevels[user_id] or 0) + levelIncrease
        print("User " .. user_id .. " has increased their pilot level to " .. pilotLevels[user_id])
        TriggerClientEvent("VICE:updateClientPilotLevel", src, pilotLevels[user_id])  -- Update client's pilot level
    end
end)