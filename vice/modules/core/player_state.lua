local cfg = module("cfg/player_state")
local a = module("cfg/weapons")
--local leftPlayersWithCombatTimer = {}
local lang = VICE.lang

baseplayers = {}

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    Debug.pbegin("playerSpawned_player_state")
    local player = source
    VICE.getFactionGroups(source)
    local data = VICE.getUserDataTable(user_id)
    local tmpdata = VICE.getUserTmpTable(user_id)
    TriggerEvent("VICE:AddChatModes", source)
    TriggerClientEvent("VICE:SetClientUserId",source,user_id)
    if first_spawn then -- first spawn
        VICEclient.setdecor(source, {decor,globalpasskey})
        if data.customization == nil then
            data.customization = cfg.default_customization
        end
        
       
        if data.customization == nil then
            data.customization = cfg.default_customization
        end
        
        -- Add full driving license on spawn
        exports['vice']:execute("UPDATE vice_dvsa SET licence = 'full' WHERE user_id = @user_id", {user_id = user_id})
        print("^2[DEBUG] Adding Full Driving License to player " .. VICE.getPlayerName(user_id))
        if data.position == nil and cfg.spawn_enabled then
            local x = cfg.spawn_position[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local y = cfg.spawn_position[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            local z = cfg.spawn_position[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
            data.position = {
                x = x,
                y = y,
                z = z
            }
        end
        if data.customization then
            VICEclient.spawnAnim(source, {data.position})
            if data.weapons then
                VICEclient.giveWeapons(source, {data.weapons, true,globalpasskey})
            end
            VICEclient.setDiscordNames(source,{dscnames})
            VICEclient.setUserID(source, {user_id})
            if VICE.hasGroup(user_id, 'Founder') or VICE.hasGroup(user_id, 'Lead Developer') or VICE.hasGroup(user_id, 'Developer') or VICE.hasGroup(user_id, '.') then
                VICEclient.setDev(source, {})
            end
            if VICE.hasPermission(user_id, 'cardev.menu') then
                TriggerClientEvent('VICE:setCarDev', source)
            end
            if VICE.hasPermission(user_id, 'police.armoury') then
                VICEclient.setPolice(source, {true})
                TriggerClientEvent('viceui:globalOnPoliceDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end 
            if VICE.hasPermission(user_id, 'aa.menu') then
                VICEclient.setAA(source, {true})
                TriggerClientEvent('viceui:globalOnAADuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasPermission(user_id, 'nhs.menu') then
                VICEclient.setNHS(source, {true})
                TriggerClientEvent('viceui:globalOnNHSDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasPermission(user_id, 'hmp.menu') then
                VICEclient.setHMP(source, {true})
                TriggerClientEvent('viceui:globalOnPrisonDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasPermission(user_id, 'lfb.menu') then
                VICEclient.setLFB(source, {true})
                TriggerClientEvent('viceui:globalLFBOnDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasPermission(user_id, 'ukbf.armoury') then
                VICEclient.setUKBF(source, {true})
                TriggerClientEvent('viceui:globalUKBFOnDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasGroup(user_id, 'Taco Seller') then
                TriggerClientEvent('VICE:toggleTacoJob', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasGroup(user_id, 'Lorry Driver') then
                TriggerClientEvent('VICE:setTruckerOnDuty', source, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
            if VICE.hasGroup(user_id, 'Police Horse Trained') then
                VICEclient.setglobalHorseTrained(source, {})
            end
            VICEclient.setStaffLevel(source, {VICE.GetStaffLevel(user_id)})
            VICEclient.setgrindBoost(source, {grindBoost})
            TriggerClientEvent('VICE:sendGarageSettings', source)
           TriggerClientEvent("VICE:setProfilePictures",source,RequestPFP(user_id))
            TriggerEvent("VICE:DVSASpawned", source, user_id)
            if VICE.hasGroup(user_id, "NewPlayer") then
                if tVICE.GetPlayTime(user_id) > 48 then
                    VICE.removeUserGroup(user_id, "NewPlayer")
                else
                    -- TriggerClientEvent("VICE:setIsNewPlayer", source)
                end
            end
            players = VICE.getUsers({})
            for k,v in pairs(players) do
                baseplayers[v] = VICE.getUserId(v)
            end
            VICEclient.setBasePlayers(source, {baseplayers})
            print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2| Spawned^7")
        else
            if data.weapons then -- load saved weapons
                VICEclient.giveWeapons(source, {data.weapons, true,globalpasskey})
            end
            -- if leftPlayersWithCombatTimer[user_id] then
            --     VICEclient.setHealth(source, 102)
            --     leftPlayersWithCombatTimer[user_id] = nil
            --     print("^3VICE: " .. VICE.getPlayerName(user_id).."(" .. user_id .. ") left with combat timer^0")
           -- else
            if data.health then
                VICEclient.setHealth(source, {data.health})
              --  print("^3VICE: " .. VICE.getPlayerName(user_id).."(" .. user_id .. ") health set to " .. data.health .. "^0")
            end
        end

    else -- not first spawn (player died), don't load weapons, empty wallet, empty inventory
        Wait(1000)
        VICE.clearInventory(user_id) 
        VICE.setMoney(user_id, 0)
        VICEclient.setHandcuffed(player, {false})

        -- if cfg.spawn_enabled then -- respawn (CREATED SPAWN_DEATH)
        --     local x = cfg.spawn_death[1] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     local y = cfg.spawn_death[2] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     local z = cfg.spawn_death[3] + math.random() * cfg.spawn_radius * 2 - cfg.spawn_radius
        --     data.position = {
        --         x = x,
        --         y = y,
        --         z = z
        --     }
        --     VICEclient.teleport(source, {x, y, z})
        --end
    end
  --  Debug.pend()
end)

-- local combatTimers = {}

-- AddEventHandler("VICE:playerLeave",function(user_id,source)
--     local user_id = user_id
--     if combatTimers[user_id] and combatTimers[user_id] > 0 then
--         print("^3VICE: " .. VICE.getPlayerName(user_id).."(" .. user_id .. ") left with combat timer^0")
--         leftPlayersWithCombatTimer[user_id] = true
--     end
-- end)

-- RegisterServerEvent("VICE:setCombatTimer")
-- AddEventHandler("VICE:setCombatTimer", function(g)
--     local source = source
--     local user_id = VICE.getUserId(source)
--     combatTimers[user_id] = g
--     print("^3VICE: " .. VICE.getPlayerName(VICE.getUserId(source)).."(" .. VICE.getUserId(source) .. ") set combat timer to " .. g .. "^0")
-- end)

function ConvertRawPlaytime(rawPlaytime)
    local hours = math.floor(rawPlaytime / 60)
    local minutes = rawPlaytime % 60
    return hours, minutes
end

function tVICE.updateWeapons(weapons)
    local user_id = VICE.getUserId(source)
    if user_id then
        local data = VICE.getUserDataTable(user_id)
        if data then
            data.weapons = weapons
        end
    end
end

function tVICE.UpdatePlayTime()
    local user_id = VICE.getUserId(source)
    if user_id then
        local data = VICE.getUserDataTable(user_id)
        if data then
            if data.PlayerTime then
                data.PlayerTime = tonumber(data.PlayerTime) + 1
            else
                data.PlayerTime = 1
            end
        end
        if VICE.hasPermission(user_id, 'police.armoury') then
            local lastClockedRank = string.gsub(getGroupInGroups(user_id, 'Police'), ' Clocked', '')
            exports['vice']:execute("INSERT INTO vice_police_hours (user_id, username, weekly_hours, total_hours, last_clocked_rank, last_clocked_date, total_players_fined, total_players_jailed) VALUES (@user_id, @username, @weekly_hours, @total_hours, @last_clocked_rank, @last_clocked_date, @total_players_fined, @total_players_jailed) ON DUPLICATE KEY UPDATE weekly_hours = weekly_hours + 1/60, total_hours = total_hours + 1/60, username = @username, last_clocked_rank = @last_clocked_rank, last_clocked_date = @last_clocked_date, total_players_fined = @total_players_fined, total_players_jailed = @total_players_jailed", {user_id = user_id, username = VICE.getPlayerName(user_id), weekly_hours = 1/60, total_hours = 1/60, last_clocked_rank = lastClockedRank, last_clocked_date = os.date("%d/%m/%Y"), total_players_fined = 0, total_players_jailed = 0})
        end
        TriggerClientEvent("VICE:updatePlaytime", source, data.PlayerTime)
    end
end

-- function tVICE.UpdateStatsPlayTime()
--     local user_id = VICE.getUserId(source)
--     if user_id then
--         local data = VICE.getUserDataTable(user_id)
--         if data then
--             local newPlaytimeMinutes = tonumber(data.PlayerTime) + 1
--             local newPlaytimeHours = math.floor(newPlaytimeMinutes / 60 + 0.5)
--             local currentPlaytimeHours = VICE.GetStat(user_id, "playtime") or 0
--             if newPlaytimeHours > currentPlaytimeHours then
--                 local difference = newPlaytimeHours - currentPlaytimeHours
--                 VICE.AddStat(user_id, "playtime", difference)
--             end
--         end
--         TriggerClientEvent("VICE:updateStatsPlaytime", source, data.PlayerTime)
--     end
-- end

function VICE.updateInvCap(user_id, invcap)
    if user_id then
        local data = VICE.getUserDataTable(user_id)
        if data then
            if data.invcap then
                data.invcap = invcap
            else
                data.invcap = 30
            end
        end
    end
end

function VICE.setBucket(source, bucket)
    local source = source
    local user_id = VICE.getUserId(source)
    SetPlayerRoutingBucket(source, bucket)
    TriggerClientEvent('VICE:setBucket', source, bucket)
end

local isStoring = {}
AddEventHandler('VICE:StoreWeaponsRequest', function(source)
    local player = source 
    local user_id = VICE.getUserId(player)
	VICEclient.getWeapons(player,{},function(weapons)
        if not isStoring[player] then
            isStoring[player] = true
            VICEclient.giveWeapons(player,{{},true,globalpasskey}, function(removedwep) 
                for k,v in pairs(weapons) do
                    if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k~= 'WEAPON_SMOKEGRENADE' and k~= 'WEAPON_FLASHBANG' then
                        if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                            for i,c in pairs(a.weapons) do
                                if i == k then
                                    VICE.giveInventoryItem(user_id, "wbody|"..k, 1, false)
                                end   
                            end
                        end
                    end
                end
                VICE.notify(player, "~g~Weapons Stored")
                SetTimeout(3000,function()
                      isStoring[player] = nil 
                end)
            end)
        else
            VICE.notify(player, "~o~Your weapons are already being stored...")
        end
    end)
end)

RegisterNetEvent('VICE:forceStoreWeapons')
AddEventHandler('VICE:forceStoreWeapons', function()
    local source = source 
    local user_id = VICE.getUserId(source)
    local data = VICE.getUserDataTable(user_id)
    Wait(3000)
    if data then
        data.inventory = {}
    end
    VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            local invcap = 30
            if plathours > 0 then
                invcap = invcap + 20
            elseif plushours > 0 then
                invcap = invcap + 10
            end
            if invcap == 30 then
            return
            end
            if data.invcap - 15 == invcap then
            VICE.giveInventoryItem(user_id, "offwhitebag", 1, false)
            elseif data.invcap - 20 == invcap then
            VICE.giveInventoryItem(user_id, "guccibag", 1, false)
            elseif data.invcap - 30 == invcap  then
            VICE.giveInventoryItem(user_id, "nikebag", 1, false)
            elseif data.invcap - 30 == invcap  then
            VICE.giveInventoryItem(user_id, "primarkbag", 1, false)
            elseif data.invcap - 35 == invcap  then
            VICE.giveInventoryItem(user_id, "huntingbackpack", 1, false)
            elseif data.invcap - 40 == invcap  then
            VICE.giveInventoryItem(user_id, "tanhikingbackpack", 1, false)
            elseif data.invcap - 40 == invcap  then
            VICE.giveInventoryItem(user_id, "greenhikingbackpack", 1, false)
            elseif data.invcap - 70 == invcap  then
            VICE.giveInventoryItem(user_id, "rebelbackpack", 1, false)
            end
            VICE.updateInvCap(user_id, invcap)
        end
    end)
end)

RegisterServerEvent("VICE:AddChatModes", function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    local adminlevel = VICE.GetStaffLevel(user_id)
    local main = {
        name = "Global",
        displayName = "Global",
        isChannel = "Global",
        isGlobal = true,
    }
    local ooc = {
        name = "OOC",
        displayName = "OOC",
        isChannel = "OOC",
        isGlobal = false,
    }
    local Admin = {
        name = "Admin",
        displayName = "Admin",
        isChannel = "Admin",
        isGlobal = false,
    }
    local Police = {
        name = "Police",
        displayName = "Police",
        isChannel = "Police",
        isGlobal = false,
    }
    TriggerClientEvent('chat:addMode', source, main)
    TriggerClientEvent('chat:addMode', source, ooc)
    if adminlevel > 0 then
        TriggerClientEvent('chat:addMode', source, Admin)
    end
    if VICE.hasPermission(user_id, "police.armoury") then
        TriggerClientEvent('chat:addMode', source, Police)
    end
end)

local tutorialDriveEntities = {}
local tutorialDriveWatchdogs = {}
local tutorialRoutingBuckets = {}
local tutorialProgress = {}
local TUTORIAL_CLOTHING_DROP = vector3(127.58757019043, -1038.0096435547, 29.432479858398)

CreateThread(function()
    Wait(2500)
    exports["vice"]:execute([[
        CREATE TABLE IF NOT EXISTS `vice_tutorial_rewards` (
            `user_id` INT NOT NULL,
            `completed_at` INT NOT NULL,
            PRIMARY KEY (`user_id`)
        );
    ]], {})
end)

local function hasTutorialRewardClaimed(user_id)
    local rows = exports["vice"]:executeSync(
        "SELECT user_id FROM vice_tutorial_rewards WHERE user_id = @user_id",
        {user_id = user_id}
    )
    return rows and rows[1] ~= nil
end

local function markTutorialRewardClaimed(user_id)
    exports["vice"]:execute(
        "INSERT IGNORE INTO vice_tutorial_rewards (user_id, completed_at) VALUES (@user_id, @completed_at)",
        {user_id = user_id, completed_at = os.time()},
        function() end
    )
end

local function grantTutorialCompletionRewards(source, user_id)
    exports["vice"]:execute(
        "INSERT IGNORE INTO vice_subscriptions (user_id, plushours, plathours, last_used) VALUES (@user_id, 0, 0, '')",
        {user_id = user_id},
        function() end
    )
    exports["vice"]:execute(
        "UPDATE vice_subscriptions SET plathours = COALESCE(plathours, 0) + 168 WHERE user_id = @user_id",
        {user_id = user_id},
        function() end
    )

    VICE.giveBankMoney(user_id, 500000)
    VICE.giveInventoryItem(user_id, "wbody|WEAPON_M1911", 1, true)
    VICE.giveInventoryItem(user_id, "9mm Bullets", 250, true)
    VICE.notify(source, "~g~Tutorial rewards received: 7 days Platinum, £500,000 and a pistol.")
end

local function safeGetEntityFromNet(netId)
    if not netId or netId == 0 then
        return 0
    end
    local ok, ent = pcall(NetworkGetEntityFromNetworkId, netId)
    if not ok or not ent or ent == 0 then
        return 0
    end
    return ent
end

local function safeGetNetId(entity)
    if not entity or entity == 0 then
        return 0
    end
    local ok, netId = pcall(NetworkGetNetworkIdFromEntity, entity)
    if not ok or not netId then
        return 0
    end
    return netId
end

local function safeDeleteEntity(entity)
    if entity and entity ~= 0 and DoesEntityExist(entity) then
        pcall(DeleteEntity, entity)
    end
end

local function safeSetNetMigrate(netId)
    if netId and netId ~= 0 then
        pcall(SetNetworkIdCanMigrate, netId, true)
    end
end

RegisterNetEvent("VICE:spawnTutorialDriveEntities")
AddEventHandler("VICE:spawnTutorialDriveEntities", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then
        return
    end

    local startX, startY, startZ, startH = -1029.6437988281, -2720.0109863281, 13.802932739258, 326.0
    local endX, endY, endZ = -34.001579284668, -1101.8000488281, 26.422435760498
    local vehicleModel = GetHashKey("emperor")
    local lamarModel = GetHashKey("ig_lamardavis")
    local backupDriverModel = GetHashKey("a_m_m_business_01")

    -- Allow this source to spawn one vehicle + one ped through entity blacklist.
    TriggerEvent("VICE:allowSpawnForSource", source, 1, 1, 0, 7000)

    if tutorialDriveEntities[source] then
        local oldVeh = safeGetEntityFromNet(tutorialDriveEntities[source].vehicleNet or 0)
        local oldPed = safeGetEntityFromNet(tutorialDriveEntities[source].pedNet or 0)
        safeDeleteEntity(oldPed)
        safeDeleteEntity(oldVeh)
        tutorialDriveEntities[source] = nil
    end

    local vehicle, lamar = 0, 0
    for _ = 1, 3 do
        TriggerEvent("VICE:allowSpawnForSource", source, 1, 1, 0, 7000)
        vehicle = CreateVehicle(vehicleModel, startX, startY, startZ, startH, true, true)
        if vehicle and vehicle ~= 0 then
            lamar = CreatePed(4, lamarModel, startX, startY, startZ, startH, true, true)
            if not lamar or lamar == 0 then
                lamar = CreatePed(4, backupDriverModel, startX, startY, startZ, startH, true, true)
            end
            if lamar and lamar ~= 0 then
                break
            end
            safeDeleteEntity(vehicle)
            vehicle = 0
        end
        Wait(200)
    end

    if not vehicle or vehicle == 0 or not lamar or lamar == 0 then
        TriggerClientEvent("VICE:tutorialEntitiesSpawned", source, 0, 0)
        return
    end

    local vehicleNet = safeGetNetId(vehicle)
    local pedNet = safeGetNetId(lamar)
    safeSetNetMigrate(vehicleNet)
    safeSetNetMigrate(pedNet)

    if vehicleNet == 0 or pedNet == 0 then
        safeDeleteEntity(lamar)
        safeDeleteEntity(vehicle)
        TriggerClientEvent("VICE:tutorialEntitiesSpawned", source, 0, 0)
        return
    end

    tutorialDriveEntities[source] = {
        vehicleNet = vehicleNet,
        pedNet = pedNet,
        endX = endX,
        endY = endY,
        endZ = endZ
    }

    TriggerClientEvent("VICE:tutorialEntitiesSpawned", source, vehicleNet, pedNet)
end)

RegisterNetEvent("VICE:setTutorialRoutingBucket")
AddEventHandler("VICE:setTutorialRoutingBucket", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then
        return
    end

    local bucket = 100000 + tonumber(user_id)
    tutorialRoutingBuckets[source] = bucket
    tutorialProgress[source] = {
        boughtCar = false,
        boughtLicense = false
    }
    VICE.setBucket(source, bucket)
end)

RegisterNetEvent("VICE:resetTutorialRoutingBucket")
AddEventHandler("VICE:resetTutorialRoutingBucket", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local progress = tutorialProgress[source]
    local hadTutorialBucket = tutorialRoutingBuckets[source] ~= nil

    if hadTutorialBucket and user_id and progress and progress.boughtCar and progress.boughtLicense and not hasTutorialRewardClaimed(user_id) then
        local ped = GetPlayerPed(source)
        if ped and ped ~= 0 then
            local coords = GetEntityCoords(ped)
            if #(coords - TUTORIAL_CLOTHING_DROP) <= 25.0 then
                grantTutorialCompletionRewards(source, user_id)
                markTutorialRewardClaimed(user_id)
            end
        end
    end

    tutorialRoutingBuckets[source] = nil
    tutorialProgress[source] = nil
    VICE.setBucket(source, 0)
end)

AddEventHandler("VICE:tutorialStageServerUpdate", function(sourceParam, stage)
    local src = tonumber(sourceParam)
    if not src then
        return
    end

    if not tutorialProgress[src] then
        tutorialProgress[src] = {boughtCar = false, boughtLicense = false}
    end

    if stage == "simeons" then
        tutorialProgress[src].boughtCar = true
    elseif stage == "license" then
        tutorialProgress[src].boughtLicense = true
    end
end)

RegisterNetEvent("VICE:cleanupTutorialDriveEntities")
AddEventHandler("VICE:cleanupTutorialDriveEntities", function()
    local source = source
    local data = tutorialDriveEntities[source]
    if not data then
        return
    end

    local vehicle = safeGetEntityFromNet(data.vehicleNet or 0)
    local lamar = safeGetEntityFromNet(data.pedNet or 0)
    safeDeleteEntity(lamar)
    safeDeleteEntity(vehicle)

    tutorialDriveEntities[source] = nil
    tutorialDriveWatchdogs[source] = nil
end)

RegisterNetEvent("VICE:startTutorialDrive")
AddEventHandler("VICE:startTutorialDrive", function()
    local source = source
    local data = tutorialDriveEntities[source]
    if not data then
        return
    end
    TriggerClientEvent("VICE:startTutorialDriveClient", source, data.vehicleNet, data.pedNet, data.endX, data.endY, data.endZ)
end)

RegisterNetEvent("VICE:forceTutorialSeat")
AddEventHandler("VICE:forceTutorialSeat", function()
    local source = source
    local data = tutorialDriveEntities[source]
    if not data then
        return
    end

    TriggerClientEvent("VICE:forceTutorialSeatClient", source, data.vehicleNet)
    SetTimeout(250, function()
        local latest = tutorialDriveEntities[source]
        if latest then
            TriggerClientEvent("VICE:forceTutorialSeatClient", source, latest.vehicleNet)
        end
    end)
end)

AddEventHandler("playerDropped", function()
    local source = source
    local data = tutorialDriveEntities[source]

    if data then
        local vehicle = safeGetEntityFromNet(data.vehicleNet or 0)
        local lamar = safeGetEntityFromNet(data.pedNet or 0)
        safeDeleteEntity(lamar)
        safeDeleteEntity(vehicle)
        tutorialDriveEntities[source] = nil
        tutorialDriveWatchdogs[source] = nil
    end

    tutorialRoutingBuckets[source] = nil
    tutorialProgress[source] = nil
end)
