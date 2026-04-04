local EventTypes = {
    ["Battle Royale dosent work"] = {"Legion","Sandy Shores","Paleto","Cayo Perico"},
    ["Gun game"] = {"Legion","Sandy Shores","Paleto","Cayo Perico"} 
    -- Event Locations for Battle Royale dosent work
   -- ["Dropzone"] = {"Sandy Airfield","Grapeseed Airfield","LSD South","Kortz","Rebel Hill","H Bunker"}, -- Event Locations for Dropzone
    -- ["FFA"] = {"Heroin","LSD ATM"}, -- Event Locations for FFA
    -- ["Race"] = {"Forest Playground","Sanchez Parkour","Total Wipeout","District Afterglow","BMX Parkour","Blazer Shootin","Rally Racing","Heathrow Grand Prix","Devil's Breath","Batman Begins","DuneLoader Hell","TNT (Parkour)","Atomic Circuit","City Rooftop","Rainbowland","Sandy Run","Valley Valentine"}, -- Event Locations for Races
  --  ["Musket Wars"] = {"Map"},
}

CurrentEvent = {
    players = {}, -- Players in the event
    isActive = false, -- Is the event active
    eventName = "", -- Name of the event
    eventID = 0, -- Count Up 1 for each event
    eventData = {}, -- Event Data
}

local function CreateEvent(catagory,location,spawncode,user_id)
    if not CurrentEvent.isActive then
        CurrentEvent.isActive = true
        CurrentEvent.eventName = catagory
        CurrentEvent.eventLocation = location
        CurrentEvent.eventID = CurrentEvent.eventID + 1
        CurrentEvent.eventData.spawncode = spawncode or ""
        TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},catagory.." event has started, type /joinevent to join", "eventalert")
        TriggerClientEvent("VICE:announceEventJoinable", -1, catagory, 15)
        if user_id ~= "Console" then
            CurrentEvent.players[user_id] = {name = VICE.getPlayerName(user_id),source = source, user_id = user_id}
            TriggerClientEvent("VICE:EventSequence",source)
            TriggerClientEvent("VICE:addEventPlayer",-1,tbl)
            TriggerClientEvent("VICE:OpentHostEventMenu",source,true,CurrentEvent.eventID)
            TriggerClientEvent("VICE:syncPlayers",source,CurrentEvent.players,CurrentEvent.eventID)
            VICE.sendDCLog("event-create","Event Created","> Event Name: "..catagory.."\n> Event Location: "..location.."\n> Event Host: "..VICE.getPlayerName(user_id).."\n> Host Perm ID: "..user_id)
        end
    else
        VICE.notify(VICE.getuserSource(user_id),"~r~There is already an event active")
    end
end

local function StartEvent()
    if table.maxKeys(CurrentEvent.players) ~= 1 then
        if CurrentEvent.eventName == "Battle Royale dosent work" then
            TriggerEvent("VICE:Event:BattleRoyale",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "Dropzone" then
            TriggerEvent("VICE:Event:Drop",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "FFA" then
            TriggerEvent("VICE:Event:FFA",CurrentEvent.eventLocation)
        elseif CurrentEvent.eventName == "Race" then
            TriggerEvent("VICE:Event:Race",CurrentEvent.eventLocation,CurrentEvent.eventData.spawncode)
        elseif CurrentEvent.eventName == "Musket Wars" then
            TriggerEvent("VICE:Event:MusketWars",CurrentEvent.eventLocation)
             elseif CurrentEvent.eventName == "Gun game" then
            TriggerEvent("VICE:Event:GunGame",CurrentEvent.eventLocation)
        end
    else
        TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},CurrentEvent.eventName.." event has been cancelled due to not enough players", "eventalert")
        VICE.ResetEvent()
    end
end

local function CanJoinEvent(user_id)
    for k,v in pairs(CurrentEvent.players) do
        if v.user_id == user_id then
            return true
        end
    end
    return false
end

-- [[ Commands ]] --

RegisterCommand("eventMenu",function(source) -- Event Menu for Devs
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=4 or VICE.isDeveloper(user_id) or user_id == 1 then 
        TriggerClientEvent("VICE:OpenEventMenu",source,EventTypes)
        TriggerClientEvent("VICE:IsAnyEventActive",source,CurrentEvent.isActive)
    end
end)

RegisterCommand("joinevent",function(source) -- Join the event if there is one active
    local source = source
    local user_id = VICE.getUserId(source)
    if CurrentEvent.isActive then
        if not CurrentEvent.players[user_id] then
            local tbl = {name = VICE.getPlayerName(user_id),source = source, user_id = user_id}
            CurrentEvent.players[user_id] = tbl
            TriggerClientEvent("VICE:EventSequence",source)
            TriggerClientEvent("VICE:addEventPlayer",-1,tbl)
            TriggerClientEvent("VICE:OpentHostEventMenu",source,false,CurrentEvent.eventID)
            TriggerClientEvent("VICE:syncPlayers",source,CurrentEvent.players,CurrentEvent.eventID)
        else
            VICE.notify(source, (CurrentEvent.players[user_id] and "~r~You are already in the event") or "~r~You do not meet the requirements to join this event")
        end
    else
        VICE.notify(source, "~r~There is no event active")
    end
end)

RegisterCommand("leaveevent",function(source) -- Leave the event if there is one active
    local source = source
    local user_id = VICE.getUserId(source)
    if CurrentEvent.isActive then
        if CurrentEvent.players[user_id] then
            if CurrentEvent.eventName == "Battle Royale dosent work" then
                TriggerClientEvent("VICE:removePlayerFromBR",-1,source)
                TriggerClientEvent("VICE:BattleGrounds:Cleanup",source)
            elseif CurrentEvent.eventName == "Dropzone" then
                VICE.LeaveDropzone(source)
            elseif CurrentEvent.eventName == "FFA" then
                TriggerClientEvent("VICE:FFA:RemovePlayer",-1,source)
            elseif CurrentEvent.eventName == "Musket Wars" then
                TriggerClientEvent("VICE:MusketWars:Leave",-1,source)
                TriggerClientEvent("VICE:MusketWars:End",source)
            end
            SetPlayerRoutingBucket(source,0)
            TriggerClientEvent("VICE:ClearEventData",source)
            TriggerClientEvent("VICE:Teleport",source,vector3(-2265.09, 3224.25, 32.81))
            TriggerClientEvent("VICE:removeEventPlayer",-1, CurrentEvent.players[user_id])
            if #CurrentEvent.players <= 1 then
                TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},CurrentEvent.eventName.." event has ended", "eventalert")
                VICE.ResetEvent()
            end
            CurrentEvent.players[user_id] = nil
        else
            VICE.notify(source, "~r~You are not in the event")
        end
    else
        VICE.notify(source, "~r~There is no event active")
    end
end)

-- [[ Events ]] --

RegisterServerEvent("VICE:RequestActiveEvent",function() -- Request if there is an active event
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=4 or VICE.isDeveloper(user_id) then
        TriggerClientEvent("VICE:IsAnyEventActive",source,CurrentEvent.isActive)
    else
        VICE.notify(source, "~r~You do not have permission to do this")
    end
end)

RegisterServerEvent("VICE:CreateEvent",function(catagory,location,spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=4 or VICE.isDeveloper(user_id) then
        CreateEvent(catagory,location,spawncode,user_id)
        TriggerClientEvent("VICE:Closemenu",source)
    else
        VICE.notify(source, "~r~You do not have permission to do this")
    end
end)

RegisterServerEvent("VICE:StartEvent",function(eventID,leave)
    local source = source
    local user_id = VICE.getUserId(source)
    if (VICE.GetStaffLevel(user_id) >=4 or VICE.isDeveloper(user_id)) and CurrentEvent.isActive then
        if CurrentEvent.eventID == eventID then
            if leave then
                TriggerClientEvent("VICE:ClearEventData",source)
                TriggerClientEvent("VICE:Teleport",source,vector3(-2265.09, 3224.25, 32.81))
                TriggerClientEvent("VICE:removeEventPlayer",-1, CurrentEvent.players[user_id])
                CurrentEvent.players[user_id] = nil
            end
            StartEvent()
        else
            VICE.notify(source, "~r~This event is not active")
        end
    else
        -- VICE.ACBan(15,user_id,"VICE:StartEvent")
    end
end)

RegisterServerEvent("VICE:EndEvent",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.GetStaffLevel(user_id) >=4 or VICE.isDeveloper(user_id) then
        if CurrentEvent.isActive then
            VICE.sendDCLog("event-end","Event Ended","> Event Name: "..CurrentEvent.eventName.."\n> Event Location: "..CurrentEvent.eventLocation.."\n> Event Host: "..VICE.getPlayerName(user_id).."\n> Host Perm ID: "..user_id)
            TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},"Event has been ended by "..VICE.getPlayerName(user_id), "eventalert")
            VICE.ResetEvent()
        else
            VICE.notify(source, "~r~There is no event active") 
        end
    else
        VICE.ACBan(15,user_id,"VICE:EndEvent")
    end
end)

function VICE.ManagePlayerDeath(killedsource,killersource,WeaponName,distance)
    local user_id = VICE.getUserId(killedsource)
    local killer_id = VICE.getUserId(killersource)
    local killedname = VICE.getPlayerName(user_id)
    local killername = VICE.getPlayerName(killer_id)
    local killergroup = 'none'
    local killedgroup = 'none'
    if VICE.hasPermission(user_id, 'police.armoury') then
        killedgroup = 'police'
    elseif VICE.hasPermission(user_id, 'nhs.menu') then
        killedgroup = 'nhs'
    end
    if VICE.hasPermission(killerID, 'police.armoury') then
        killergroup = 'police'
    elseif VICE.hasPermission(killerID, 'nhs.menu') then
        killergroup = 'nhs'
    end
    if killedsource ~= killersource then
        for k,v in pairs(CurrentEvent.players) do
            TriggerClientEvent('VICE:newKillFeed', v.source, killername, killedname, GetWeaponClass(WeaponName), false, math.floor(distance), killedgroup, killergroup)
        end
    end
    if CurrentEvent.eventName == "Battle Royale dosent work" then
        TriggerClientEvent("VICE:removeEventPlayer",-1, CurrentEvent.players[user_id])
        TriggerClientEvent("VICE:addBRKill",-1,killersource,VICE.getPlayerName(killer_id))
        TriggerClientEvent("VICE:removePlayerFromBR",-1,killedsource)
        TriggerClientEvent("VICE:BattleGrounds:Cleanup",killedsource)--, false, {name=VICE.getPlayerName(user_id),source=killedsource})
        TriggerClientEvent("VICE:ClearEventData",killedsource)
        VICE.notify(killedsource, "~r~You have been eliminated from the event")
        SetPlayerRoutingBucket(killedsource,0)
        CurrentEvent.players[user_id] = nil
        if #CurrentEvent.players <= 1 then
            TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},killername.." has won the "..CurrentEvent.eventName.." event", "eventalert")
            if killedsource ~= killersource then
                local winners = {{name=VICE.getPlayerName(killer_id), source=killersource}}
                local losers = {{name=VICE.getPlayerName(user_id),source=killedsource}}
                for k,v in pairs(CurrentEvent.players) do
                    VICEclient.RevivePlayer(v.source, {})
                    TriggerClientEvent("VICE:Battlegrounds:Podium",v.source, winners, losers)
                end
            end
            VICE.giveBankMoney(killer_id, math.random(250000,450000))
            VICE.ResetEvent()
        end
    elseif CurrentEvent.eventName == "Dropzone" then
        VICE.RespawnDrop(killedsource)
    elseif CurrentEvent.eventName == "Musket Wars" then
        VICE.MusketKill(killedsource,killersource)
    end
end

RegisterCommand("testbrkills",function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.isDeveloper(user_id) then
        TriggerClientEvent("VICE:addBRKill",-1,source,VICE.getPlayerName(source))
    end
end)

AddEventHandler("playerDropped",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if CurrentEvent.isActive then
        if CurrentEvent.players[user_id] then
            if CurrentEvent.eventName == "Battle Royale dosent work" then
                TriggerClientEvent("VICE:removePlayerFromBR",-1,source)
            elseif CurrentEvent.eventName == "Dropzone" then
                TriggerClientEvent("VICE:removeLootcrate",source,1)
                TriggerClientEvent("VICE:removeCrateRedzone",source)
            elseif CurrentEvent.eventName == "FFA" then
                TriggerClientEvent("VICE:FFA:RemovePlayer",-1,source)
            end
            if #CurrentEvent.players <= 1 then
                TriggerClientEvent("chatMessage",-1,"^7^*[VICE Events]",{180,0,0},CurrentEvent.eventName.." event has ended", "eventalert")
                VICE.ResetEvent()
            end
            TriggerClientEvent("VICE:removeEventPlayer",-1, CurrentEvent.players[user_id])
        end
    end
end)

-- [[ Functions ]] --

function VICE.InEvent(user_id)
    if CurrentEvent.players[user_id] then
        return true
    else
        return false
    end
end

function VICE.ResetEvent()
    for k,v in pairs(CurrentEvent.players) do
        SetPlayerRoutingBucket(v.source,0)
        TriggerClientEvent("VICE:syncPlayers",v.source,{},CurrentEvent.eventID)
        TriggerClientEvent("VICE:ClearEventData",v.source)
        TriggerClientEvent("VICE:Teleport",v.source,vector3(-2265.09, 3224.25, 32.81))
        if CurrentEvent.eventName == "Battle Royale dosent work" then
            TriggerClientEvent("VICE:BattleGrounds:Cleanup",v.source)
            TriggerClientEvent("VICE:ClearEventData",v.source)
            TriggerClientEvent("VICE:RestoreOriginalWeapons", v.source)
        elseif CurrentEvent.eventName == "Dropzone" then
            VICE.LeaveDropzone(v.source)
        elseif CurrentEvent.eventName == "Musket Wars" then
            TriggerClientEvent("VICE:MusketWars:End",v.source)
        end
    end
    CurrentEvent.isActive = false
    CurrentEvent.eventName = ""
    CurrentEvent.eventLocation = ""
    CurrentEvent.players = {}
end


-- Citizen.CreateThread(function()
--     Wait(30*60*1000)
--     while true do
--         local players = GetPlayers()
--         if not CurrentEvent.isActive then -- and #players >= 3 then
--             local catagory,location = "",""
--             if #players >= 10 then
--                 catagory = "Battle Royale dosent work"
--                 location = EventTypes["Battle Royale dosent work"][math.random(1,#EventTypes["Battle Royale dosent work"])]
--             elseif #players >= 3 then
--                 catagory = "Dropzone"
--                 location = EventTypes["Dropzone"][math.random(1,#EventTypes["Dropzone"])]
--             end
--             CreateEvent(catagory,location,nil,"Console")
--             Wait(60000)
--             StartEvent()
--         end
--         Wait(30*60*1000)
--     end
-- end)


RegisterNetEvent("VICE:Event:GunGame")
AddEventHandler("VICE:Event:GunGame",function ()
    TriggerClientEvent("gungame:startFlag", -1)
end)