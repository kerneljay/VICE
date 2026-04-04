local searchedDumpsters = {}
local dumpsterCooldown = 15 * 60

local items = {
   -- [1] = {chance = 2, id = 'WEAPON_MOSINCMG', name = 'Mosin Nagant', quantity = math.random(1,2)}, -- dont want weapons in dumpsters
    [2] = {chance = 6, id = 'armourplate', name = 'Armour Plate', quantity = math.random(1,2)},
    --[4] = {chance = 6, id = 'WEAPON_ROOK', name = 'Rook', quantity = math.random(1,2)}, -- dont want weapons in dumpsters
   -- [5] = {chance = 3, id = 'repairkit', name = 'Repair Kit', quantity = 1},
    [6] = {chance = 2, id = 'Headbag', name = 'Head Bag', quantity = 1},
    -- [7] = {chance = 4, id = 'Wallet', name = 'Wallet', quantity = math.random(1,3)}, -- to be added
    [8] = {chance = 4, id = 'Shaver', name = 'Shaver', quantity = 1},
    [9] = {chance = 2, id = 'handcuffkeys', name = 'Handcuff Keys', quantity = 1},
    [10] = {chance = 2, id = 'WEAPON_CROWBAR', name = 'Crowbar', quantity = 1},
    [11] = {chance = 2, id = 'WEAPON_KITCHENKNIFE', name = 'Kitchen Knife', quantity = 1},
    [12] = {chance = 3, id = 'handcuff', name = 'Handcuff', quantity = 1},
    [13] = {chance = 4, id = 'boltcutters', name = 'Bolt Cutters', quantity = math.random(1,2)},
}

RegisterServerEvent('VICE:searchDumpster')
AddEventHandler('VICE:searchDumpster', function(dumpsterId)
    local source = source
    if searchedDumpsters[dumpsterId] and os.difftime(os.time(), searchedDumpsters[dumpsterId].lastSearched) < dumpsterCooldown then
       -- local timeLeft = dumpsterCooldown - os.difftime(os.time(), searchedDumpsters[dumpsterId].lastSearched)
       -- TriggerClientEvent('VICE:dumpsterSearchCooldown', source, timeLeft)
        VICE.notify(source, "~r~This dumpster has been searched recently.")
        return
    end
    local user_id = VICE.getUserId(source)
    if user_id ~= nil then
        local chance = math.random(1,100)
        if chance <= 60 then
            VICEclient.startCircularProgressBar(source, {"", 5000, nil})
            local anims = {{'amb@medic@standing@kneel@base', 'base', 1},{'anim@gangops@facility@servers@bodysearch@', 'player_search', 1},}
            VICEclient.playAnim(source,{true,anims,false})
            VICEclient.FreezePlayerControls(source, {true})
            TriggerClientEvent('VICE:DumpsterIsBeingSearched', source, true)
            SetTimeout(5000, function()
                if user_id then
                    local weightedItems = {}
                    for k, v in pairs(items) do
                        for i=1, v.quantity do
                            table.insert(weightedItems, v)
                        end
                    end
                    local item = weightedItems[math.random(#weightedItems)]
                    if string.sub(item.id, 1, 7) == "WEAPON_" then
                        VICE.giveInventoryItem(user_id, "wbody|"..item.id, item.quantity, true)
                    else
                        VICE.giveInventoryItem(user_id, item.id, item.quantity, false)
                    end
                    if item.quantity > 1 then
                        VICE.notify(source, "~g~Found " .. item.quantity .. " items in the dumpster!") 
                    else
                        VICE.notify(source, "~g~Found " .. item.quantity .. " item in the dumpster!") 
                    end
                end
                VICEclient.FreezePlayerControls(source, {false})
                TriggerClientEvent('VICE:DumpsterIsBeingSearched', source, false)
            end)
        else
            VICEclient.FreezePlayerControls(source, {false})
            TriggerClientEvent('VICE:DumpsterIsBeingSearched', source, false)
            VICE.notify(source, "~r~No items of interest found in the dumpster.")
        end
    end
    searchedDumpsters[dumpsterId] = { lastSearched = os.time() }
end)