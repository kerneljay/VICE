usingDelgun = false
local a = false
local c = function(d)
    local e = {}
    local f = GetGameTimer() / 200
    e.r = math.floor(math.sin(f * d + 0) * 127 + 128)
    e.g = math.floor(math.sin(f * d + 2) * 127 + 128)
    e.b = math.floor(math.sin(f * d + 4) * 127 + 128)
    return e
end

local staffPlayers = {}
local discordNames = {}
local staffRanks = {
    ["Trial Staff"] = {text = "[Trial Staff]", color = {r = 173, g = 216, b = 230}}, -- Light Blue
    ["Support Team"] = {text = "[Support Team]", color = {r = 0, g = 100, b = 0}}, -- Dark Green
    ["Moderator"] = {text = "[Moderator]", color = {r = 0, g = 128, b = 0}}, -- Dark Green
    ["Senior Moderator"] = {text = "[Senior Moderator]", color = {r = 144, g = 238, b = 144}}, -- Light Green
    ["Administrator"] = {text = "[Administrator]", color = {r = 255, g = 165, b = 0}}, -- Orange
    ["Senior Administrator"] = {text = "[Senior Administrator]", color = {r = 255, g = 192, b = 203}}, -- Pink
    ["Head Administrator"] = {text = "[Head Administrator]", color = {r = 255, g = 165, b = 0}}, -- Orange
    ["Staff Manager"] = {text = "[Staff Manager]", color = {r = 128, g = 0, b = 128}}, -- Purple
    ["Community Manager"] = {text = "[Community Manager]", color = {r = 255, g = 145, b = 145}}, -- #ff9191
    ["Developer"] = {text = "[Developer]", color = {r = 255, g = 165, b = 0}}, -- Orange
    ["Lead Developer"] = {text = "[Lead Developer]", color = {r = 255, g = 165, b = 0}}, -- Orange
    ["Founder"] = {text = "[Founder]", color = {r = 255, g = 0, b = 0}} -- Red
}

local function getHighestStaffRank(permissions)
    local highestRank = nil
    local highestPriority = 0
    
    -- Check other permissions
    for perm, rankData in pairs(staffRanks) do
        if permissions[perm] then
            local priority = 0
            if perm == "Founder" then priority = 12
            elseif perm == "Lead Developer" then priority = 11
            elseif perm == "Developer" then priority = 10
            elseif perm == "Community Manager" then priority = 9
            elseif perm == "Staff Manager" then priority = 8
            elseif perm == "Head Administrator" then priority = 7
            elseif perm == "Senior Administrator" then priority = 6
            elseif perm == "Administrator" then priority = 5
            elseif perm == "Senior Moderator" then priority = 4
            elseif perm == "Moderator" then priority = 3
            elseif perm == "Support Team" then priority = 2
            elseif perm == "Trial Staff" then priority = 1
            end
            
            if priority > highestPriority then
                highestPriority = priority
                highestRank = rankData
            end
        end
    end
    
    return highestRank or staffRanks["Trial Staff"]
end

RegisterCommand("delgun",function()
    if VICE.getStaffLevel() > 0 then
        usingDelgun = not usingDelgun
        local g = VICE.getPlayerPed()
        local h = "WEAPON_STAFFGUN"
        if usingDelgun then
            a = HasPedGotWeapon(g, h, false)
            VICE.allowWeapon(h)
            GiveWeaponToPed(g, h, nil, false, true)
            GiveWeaponToPed(g, h, nil, false, true)
            Citizen.CreateThread(function()
                while usingDelgun do
                    Wait(0)
                    drawNativeText("Aim ~w~at an object and press ~b~Enter ~w~to delete it. ~r~Have fun!")
                    DisableControlAction(1, 18, true)
                    DisablePlayerFiring(PlayerId(), true)
                    if IsPlayerFreeAiming(PlayerId()) then
                        local l, m = GetEntityPlayerIsFreeAimingAt(PlayerId())
                        if l then
                            local n = GetEntityType(m)
                            local o = true
                            if o then
                                local p = GetEntityCoords(m)
                                local q = c(0.5)
                                DrawMarker(1,p.x,p.y,p.z - 1.02,0,0,0,0,0,0,0.7,0.7,1.5,q.r,q.g,q.b,200,0,0,2,0,0,0,0)
                                if IsDisabledControlJustPressed(1, 18) then
                                    local r = NetworkGetNetworkIdFromEntity(m)
                                    TriggerServerEvent("VICE:delGunDelete", r)
                                    if GetEntityType(m) == 2 then
                                        SetEntityAsMissionEntity(m, false, true)
                                        DeleteVehicle(m)
                                    end
                                end
                            end
                        end
                    end
                end
                RemoveWeaponFromPed(g, h)
            end)
            VICE.drawNativeNotification("Don't forget to use ~b~/delgun ~w~to disable the delete gun!")
        else
            if not a then
                RemoveWeaponFromPed(g, h)
            end
            a = false
        end
    end
end)

RegisterNetEvent("VICE:returnObjectDeleted",function(i)
    drawNativeNotification(i)
end)

RegisterNetEvent("VICE:deletePropClient",function(r)
    local s = VICE.getObjectId(r)
    if DoesEntityExist(s) then
        DeleteEntity(s)
    end
end)

local t = {}
function VICE.isLocalPlayerHidden()
    if t[VICE.getUserId()] then
        return true
    else
        return false
    end
end
function VICE.isUserHidden(u)
    if t[u] and VICE.getUserId() ~= u then
        return true
    else
        return false
    end
end

RegisterNetEvent('VICE:updateDiscordName')
AddEventHandler('VICE:updateDiscordName', function(playerId, name)
    discordNames[playerId] = name
end)

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
                    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z + 1.0)
                    if onScreen then
                        SetTextScale(0.45, 0.45)
                        SetTextFont(4)
                        SetTextProportional(1)
                        SetTextColour(staffPlayers[playerId].color.r, staffPlayers[playerId].color.g, staffPlayers[playerId].color.b, 255)
                        SetTextDropshadow(0, 0, 0, 0, 255)
                        SetTextEdge(2, 0, 0, 0, 255)
                        SetTextDropShadow()
                        SetTextOutline()
                        SetTextEntry("STRING")
                        SetTextCentre(1)
                        local displayName = VICE.getPlayerName(playerId)
                        AddTextComponentString(staffPlayers[playerId].text .. " " .. displayName)
                        DrawText(x, y - 0.02)
                    end
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.45, 0.45)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end