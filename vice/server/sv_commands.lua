-- Kit cooldown table
local kitCooldowns = {}

-- Kit definitions
local kitConfigs = {
    starterkit = {
        cooldown = 3600, -- 1 hour in seconds
        items = {
            {weapon = "WEAPON_PISTOL", ammo = 100},
            {weapon = "WEAPON_BAT", ammo = 1},
            -- Add more items as needed
        }
    },
    combatkit = {
        cooldown = 7200, -- 2 hours in seconds
        items = {
            {weapon = "WEAPON_CARBINERIFLE", ammo = 200},
            {weapon = "WEAPON_PISTOL", ammo = 100},
            -- Add more items as needed
        }
    },
    medkit = {
        cooldown = 1800, -- 30 minutes in seconds
        items = {
            {weapon = "WEAPON_FIRSTAID", ammo = 5},
            -- Add more items as needed
        }
    }
}

-- Event handler for kit redemption
RegisterServerEvent('VICE:redeemKit')
AddEventHandler('VICE:redeemKit', function(kitType)
    local source = source
    local user_id = VICE.getUserId(source)
    
    if not user_id then return end
    
    -- Get kit configuration
    local kitConfig = kitConfigs[kitType]
    if not kitConfig then
        TriggerClientEvent('VICE:kitResponse', source, "~r~Invalid kit type.")
        return
    end
    
    -- Check cooldown
    local cooldownKey = string.format("%d:%s", user_id, kitType)
    local lastUsage = kitCooldowns[cooldownKey]
    local currentTime = os.time()
    
    if lastUsage and currentTime - lastUsage < kitConfig.cooldown then
        local remainingTime = math.ceil((kitConfig.cooldown - (currentTime - lastUsage)) / 60)
        TriggerClientEvent('VICE:kitResponse', source, string.format("~r~You must wait %d minutes before using this kit again.", remainingTime))
        return
    end
    
    -- Give items
    for _, item in ipairs(kitConfig.items) do
        VICE.giveWeapon(source, item.weapon, item.ammo)
    end
    
    -- Update cooldown
    kitCooldowns[cooldownKey] = currentTime
    
    -- Notify player
    TriggerClientEvent('VICE:kitResponse', source, string.format("~g~Successfully redeemed %s!", kitType))
end)

