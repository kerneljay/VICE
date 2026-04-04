loadouts = {
    ['Basic'] = {
        permission = "police.armoury",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            "WEAPON_FLASHLIGHT",
            "WEAPON_BORA",
        },
    },
    -- ['SCO-19'] = {
    --     permission = "police.loadshop2",
    --     weapons = {
    --         "WEAPON_NIGHTSTICK",
    --         "WEAPON_STUNGUN",
    --         "WEAPON_FLASHLIGHT",
    --         "WEAPON_PDGLOCK20VA5",
    --         "WEAPON_G36VICE",
    --     },
    -- },
    -- ['CTSFO'] = {
    --     permission = "police.maxarmour",
    --     weapons = {
    --         "WEAPON_NIGHTSTICK",
    --         "WEAPON_STUNGUN",
    --         "WEAPON_FLASHLIGHT",
    --         "WEAPON_PDGLOCK20VA5",
    --         "WEAPON_SPAR17",
    --         "WEAPON_REMINGTON700",
    --         "WEAPON_FLASHBANG",
    --     },
    -- },
    ['VICE'] = {
        permission = "police.dev",
        weapons = {
            "WEAPON_NIGHTSTICK",
            "WEAPON_STUNGUN",
            -- "WEAPON_FLASHLIGHT",
            -- "WEAPON_PDGLOCK20VA5",
            -- "WEAPON_SPAR17",
            -- "WEAPON_REMINGTON700",
            "WEAPON_FLASHBANG",
            "WEAPON_BORA",
        },
    },
}


RegisterNetEvent('VICE:getPoliceLoadouts')
AddEventHandler('VICE:getPoliceLoadouts', function()
    local source = source
    local user_id = VICE.getUserId(source)
    local loadoutsTable = {}
    if VICE.hasPermission(user_id, 'police.armoury') then
        for k,v in pairs(loadouts) do
            v.hasPermission = VICE.hasPermission(user_id, v.permission) 
            loadoutsTable[k] = v
        end
        TriggerClientEvent('VICE:gotLoadouts', source, loadoutsTable)
    end
end)

RegisterNetEvent('VICE:selectLoadout')
AddEventHandler('VICE:selectLoadout', function(loadout)
    local source = source
    local user_id = VICE.getUserId(source)
    for k,v in pairs(loadouts) do
        if k == loadout then
            if VICE.hasPermission(user_id, 'police.armoury') and VICE.hasPermission(user_id, v.permission) then
                for a,b in pairs(v.weapons) do
                    VICEclient.giveWeapons(source, {{[b] = {ammo = 250}}, false, globalpasskey})
                end
                VICE.notify(source, "~g~Received "..loadout.." loadout.")
            else
                VICE.notify(source, "You do not have permission to select this loadout")
            end
        end 
    end
end)