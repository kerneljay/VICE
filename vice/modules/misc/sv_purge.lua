local topFraggers = {} 
local leaderboard = {}
local purgeActive = {}
local playersInPurge = 0

RegisterServerEvent('VICE:getTopFraggers')
AddEventHandler('VICE:getTopFraggers', function()
    SendLeaderboard()
end)

RegisterServerEvent('VICE:purgeActive')
AddEventHandler('VICE:purgeActive', function(value)
    local source = source
    local user_id = VICE.getUserId(source)
    if value then
        purgeActive[user_id] = true
        playersInPurge = playersInPurge + 1
        SetPlayerRoutingBucket(source,666)
        TriggerClientEvent('VICE:purge:catchData', source, playersInPurge,true)
    elseif not value then
        purgeActive[user_id] = nil
        playersInPurge = playersInPurge - 1
        SetPlayerRoutingBucket(source,0)
        VICEclient.ClearWeapons(source,{})
        TriggerClientEvent('VICE:purge:catchData', source, playersInPurge, false)
    else
        VICE.ACBan(15,user_id,"VICE:purgeActive")
    end
end)

RegisterNetEvent('VICE:playerKilled')
AddEventHandler('VICE:playerKilled', function(targetId)
    local playerId = source
    local user_id = VICE.getUserId(playerId)
    if purgeActive[user_id] then
        for i, data in pairs(leaderboard) do
            if data.id == playerId then
                data.kills = data.kills + 1
                UpdatePlayerKills(playerId, data.kills)
                break
            end
        end
        TriggerClientEvent('VICE:updateKills', playerId, data.kills)
    end
end)

function UpdatePlayerKills(playerId, newKills)
    for i, data in pairs(leaderboard) do
        if data.id == playerId then
            data.kills = newKills
            break
        end
    end
    table.sort(leaderboard, function(a, b) return a.kills > b.kills end)
    SendLeaderboard() 
end

function SendLeaderboard()
    TriggerClientEvent('VICE:gotTopFraggers', -1, leaderboard)
end

RegisterCommand("testpurgekills", function(source, args)
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)
    if VICE.isDeveloper(user_id) then
        TriggerEvent('VICE:playerKilled', source, targetId)
    end
end)

RegisterServerEvent('VICE:triggerPurgeSpawn')
AddEventHandler('VICE:triggerPurgeSpawn', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if purgeActive[user_id] then
        TriggerClientEvent('VICE:purgeSpawnClient', source)
    else
        VICE.ACBan(15,user_id,"VICE:triggerPurgeSpawn")
    end
end)

local randomWeapons = {
    'WEAPON_ROOK',
    'WEAPON_MOSINCMG',
    'WEAPON_COLTM4A1',
    'WEAPON_OLYMPIA',
    'WEAPON_UZI',
    'WEAPON_AK74KASHNAR',
    'WEAPON_G36',
    'WEAPON_REMINGTON870',
    'WEAPON_SPAR17',
    'WEAPON_WINCHESTER12',
    'WEAPON_SPAZ',
    'WEAPON_BERETTA',
    'WEAPON_P90MD',
    'WEAPON_M1911',
    'WEAPON_TEC9',
}

RegisterNetEvent("VICE:purgeClientHasSpawned")
AddEventHandler("VICE:purgeClientHasSpawned", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local randomWeapon = randomWeapons[math.random(1, #randomWeapons)]
    if purgeActive[user_id] then
        VICEclient.giveWeapons(source, {{[randomWeapon] = {ammo = 250}}, false, globalpasskey})
        VICE.notify(source, "~o~Random weapon received!")
        VICEclient.FrontendSound(source, {"Weapon_Upgrade", "DLC_GR_Weapon_Upgrade_Soundset"})
    else
        VICE.ACBan(15,user_id,"VICE:purgeClientHasSpawned")
    end
end)

AddEventHandler("VICE:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        TriggerClientEvent("VICE:purgeAnnounce",source)
        TriggerClientEvent('VICE:purge:catchData', source, playersInPurge,false)
    end
end)

AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = VICE.getUserId(source)
    if purgeActive[user_id] then
        purgeActive[user_id] = nil
        playersInPurge = playersInPurge - 1
    end
end)