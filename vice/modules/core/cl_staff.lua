local staffPlayers = {}
local staffRanks = {
    ["admin.tickets"] = "[Trial Staff]",
    ["support.team"] = "[Support Team]",
    ["moderator"] = "[Moderator]",
    ["senior.moderator"] = "[Senior Moderator]",
    ["administrator"] = "[Administrator]",
    ["senior.administrator"] = "[Senior Administrator]",
    ["head.administrator"] = "[Head Administrator]",
    ["staff.manager"] = "[Staff Manager]",
    ["community.manager"] = "[Community Manager]",
    ["developer"] = "[Developer]",
    ["lead.developer"] = "[Lead Developer]",
    ["founder"] = "[Founder]"
}

-- Function to get highest staff rank
local function getHighestStaffRank(permissions)
    local highestRank = nil
    local highestPriority = 0
    
    for perm, rank in pairs(staffRanks) do
        if permissions[perm] then
            local priority = 0
            if perm == "founder" then priority = 12
            elseif perm == "lead.developer" then priority = 11
            elseif perm == "developer" then priority = 10
            elseif perm == "community.manager" then priority = 9
            elseif perm == "staff.manager" then priority = 8
            elseif perm == "head.administrator" then priority = 7
            elseif perm == "senior.administrator" then priority = 6
            elseif perm == "administrator" then priority = 5
            elseif perm == "senior.moderator" then priority = 4
            elseif perm == "moderator" then priority = 3
            elseif perm == "support.team" then priority = 2
            elseif perm == "admin.tickets" then priority = 1
            end
            
            if priority > highestPriority then
                highestPriority = priority
                highestRank = rank
            end
        end
    end
    
    return highestRank
end

-- Event to update staff status
RegisterNetEvent('VICE:updateStaffStatus')
AddEventHandler('VICE:updateStaffStatus', function(playerId, isStaff, permissions)
    if isStaff then
        local rank = getHighestStaffRank(permissions)
        if rank then
            staffPlayers[playerId] = rank
        end
    else
        staffPlayers[playerId] = nil
    end
end)

-- Thread to draw staff ranks
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local players = GetActivePlayers()
        
        for _, player in ipairs(players) do
            local ped = GetPlayerPed(player)
            local playerId = GetPlayerServerId(player)
            
            if staffPlayers[playerId] then
                local coords = GetEntityCoords(ped)
                local distance = #(GetGameplayCamCoords() - coords)
                
                if distance < 20.0 then
                    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.5)
                    if onScreen then
                        SetTextScale(0.35, 0.35)
                        SetTextFont(4)
                        SetTextProportional(1)
                        SetTextColour(255, 255, 255, 255)
                        SetTextEntry("STRING")
                        SetTextCentre(1)
                        AddTextComponentString(staffPlayers[playerId])
                        DrawText(x, y - 0.05)
                    end
                end
            end
        end
    end
end)

-- Event to handle staff mode toggle
RegisterNetEvent('VICE:toggleStaffMode')
AddEventHandler('VICE:toggleStaffMode', function(isStaff, permissions)
    local playerId = GetPlayerServerId(PlayerId())
    TriggerServerEvent('VICE:updateStaffStatus', playerId, isStaff, permissions)
end) 