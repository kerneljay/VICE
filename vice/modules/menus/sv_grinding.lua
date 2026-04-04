local grindingData = {
    ['Copper'] = {
        license = 'Copper', 
        processingScenario = 'WORLD_HUMAN_WELDING', 
        firstItem = 'Copper Ore', 
        secondItem = 'Copper', 
        pickaxe = true
    },
    ['Limestone'] = {
        license = 'Limestone', 
        processingScenario = 'WORLD_HUMAN_WELDING', 
        firstItem = 'Limestone Ore', 
        secondItem = 'Limestone', 
        pickaxe = true
    },
    ['Gold'] = {
        license = 'Gold', 
        processingScenario = 'WORLD_HUMAN_WELDING', 
        firstItem = 'Gold Ore', 
        secondItem = 'Gold', 
        pickaxe = true
    },
    ['Weed'] = {
        license = 'Weed', 
        miningScenario = 'WORLD_HUMAN_GARDENER_PLANT', 
        processingScenario = 'WORLD_HUMAN_CLIPBOARD', 
        firstItem = 'Weed leaf', 
        secondItem = 'Weed'
    },
    ['Cocaine'] = {
        license = 'Cocaine', 
        miningScenario = 'WORLD_HUMAN_GARDENER_PLANT', 
        processingScenario = 'WORLD_HUMAN_CLIPBOARD', 
        firstItem = 'Coca leaf', 
        secondItem = 'Cocaine'
    },
    ['Meth'] = {
        license = 'Meth', 
        miningScenario = 'WORLD_HUMAN_GARDENER_PLANT', 
        processingScenario = 'WORLD_HUMAN_CLIPBOARD', 
        firstItem = 'Ephedra', 
        secondItem = 'Meth'
    },
    ['Diamond'] = {
        license = 'Diamond', 
        processingScenario = 'WORLD_HUMAN_WELDING', 
        firstItem = 'Uncut Diamond', 
        secondItem = 'Diamond', 
        pickaxe = true
    },
    ['Nugget'] = {
        license = 'Trapping',
        cutting = true,
        processingAnimDict = 'anim@amb@business@coc@coc_unpack_cut_left@',
        processingAnim = 'coccutter_idle',
        firstItem = 'Nugget',
        secondItem = 'weedbag',
        pickaxe = false
    },
    ['Heroin'] = {
        license = 'Heroin', 
        miningScenario = 'WORLD_HUMAN_GARDENER_PLANT', 
        processingScenario = 'WORLD_HUMAN_CLIPBOARD', 
        firstItem = 'Opium Poppy', 
        secondItem = 'Heroin'
    },
    ['LSD'] = {
        license = 'LSD', 
        miningScenario = 'WORLD_HUMAN_GARDENER_PLANT', 
        processingScenario = 'WORLD_HUMAN_CLIPBOARD', 
        firstItem = 'Frogs legs', 
        secondItem = 'Lysergic Acid Amide', 
        thirdItem = 'LSD'
    },
}

local activeWeedDeals = {}
local weedDealerLocations = {
    {x = 1246.6611328125, y = -331.72686767578, z = 69.08283996582},
    {x = -1172.0634765625, y = -1571.4180908203, z = 4.663622379303},
    {x = -561.40893554688, y = 286.71569824219, z = 82.176391601563},
    {x = 89.232139587402, y = 374.93762207031, z = 112.14675140381},
    {x = -42.3098487854, y = -1750.0061035156, z = 29.421009063721}
}

local function startWeedBagDeal(source, user_id)
    if not user_id then return end
    if VICE.getInventoryItemAmount(user_id, "weedbag") < 1 then return end
    local idx = math.random(1, #weedDealerLocations)
    local coords = weedDealerLocations[idx]
    activeWeedDeals[user_id] = coords
    TriggerClientEvent("VICE:startWeedBagDeal", source, coords)
end

RegisterNetEvent('VICE:requestGrinding')
AddEventHandler('VICE:requestGrinding', function(drug, grindingtype)
    local source = source
    local user_id = VICE.getUserId(source)
    if GetPlayerRoutingBucket(source) ~= 0 then
        VICEclient.notify(source, {"~r~You cannot grind in this bucket."})
        return
    end
    for k,v in pairs(grindingData) do
        if k == drug then
            if VICE.hasGroup(user_id, v.license) then
                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                    if #rows > 0 then
                        local delay = 10000
                        if rows[1].plathours > 0 then
                           delay = 7500
                        end
                        if grindingtype == 'mining' then
                            if v.pickaxe then
                                TriggerClientEvent('VICE:playGrindingPickaxe', source)  
                            elseif v.cutting then
                                TriggerClientEvent('VICE:playGrindingCutting', source)
                            else
                                TriggerClientEvent('VICE:playGrindingScenario', source, v.miningScenario, false) 
                            end
                            Citizen.Wait(delay)
                            if VICE.getInventoryWeight(user_id)+(1*4) > VICE.getInventoryMaxWeight(user_id) then
                                VICEclient.notify(source,{"~r~Not enough space in inventory."})
                            else    
                                VICE.giveInventoryItem(user_id, v.firstItem, 4, true)
                            end
                        elseif grindingtype == 'processing' then
                            if VICE.getInventoryItemAmount(user_id, v.firstItem) >= 4 then
                                VICE.tryGetInventoryItem(user_id, v.firstItem, 4, true)
                                if v.processingAnimDict and v.processingAnim then
                                    TriggerClientEvent('VICE:playGrindingAnim', source, v.processingAnimDict, v.processingAnim)
                                else
                                    TriggerClientEvent('VICE:playGrindingScenario', source, v.processingScenario, false)
                                end
                                Citizen.Wait(delay)
                                if VICE.getInventoryWeight(user_id)+(4*1) > VICE.getInventoryMaxWeight(user_id) then
                                    VICEclient.notify(source,{"~r~Not enough space in inventory."})
                                else   
                                    if drug == 'LSD' then 
                                        VICE.giveInventoryItem(user_id, v.secondItem, 4, true)
                                    else
                                        VICE.giveInventoryItem(user_id, v.secondItem, 1, true)
                                        if drug == 'Nugget' and v.secondItem == 'weedbag' then
                                            startWeedBagDeal(source, user_id)
                                        end
                                    end
                                end
                            else
                                VICEclient.notify(source, {"~r~You do not have enough "..v.firstItem.."."})
                            end
                        elseif grindingtype == 'refinery' then
                            if VICE.getInventoryItemAmount(user_id, v.secondItem) >= 4 then
                                VICE.tryGetInventoryItem(user_id, v.secondItem, 4, true)
                                TriggerClientEvent('VICE:playGrindingScenario', source, 'WORLD_HUMAN_CLIPBOARD', false)
                                Citizen.Wait(delay)
                                if VICE.getInventoryWeight(user_id)+(4*1) > VICE.getInventoryMaxWeight(user_id) then
                                    VICEclient.notify(source,{"~r~Not enough space in inventory."})
                                else    
                                    VICE.giveInventoryItem(user_id, v.thirdItem, 1, true)
                                end
                            else
                                VICEclient.notify(source, {"~r~You do not have enough "..v.secondItem.."."})
                            end
                        end
                        TriggerEvent('VICE:RefreshInventory', source)
                    end
                end)
            end
        end
    end
end)

RegisterNetEvent("VICE:requestWeedBagDealPing")
AddEventHandler("VICE:requestWeedBagDealPing", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then return end
    startWeedBagDeal(source, user_id)
end)

RegisterNetEvent("VICE:completeWeedBagDeal")
AddEventHandler("VICE:completeWeedBagDeal", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then return end

    local dealCoords = activeWeedDeals[user_id]
    if not dealCoords then
        VICEclient.notify(source, {"~r~No active dealer location."})
        return
    end

    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local playerCoords = GetEntityCoords(ped)
        local dist = #(playerCoords - vector3(dealCoords.x, dealCoords.y, dealCoords.z))
        if dist > 10.0 then
            VICEclient.notify(source, {"~r~You are too far from the dealer."})
            return
        end
    end

    if not VICE.tryGetInventoryItem(user_id, "weedbag", 1, true) then
        VICEclient.notify(source, {"~r~You do not have a weed bag."})
        return
    end

    local cashReward = math.random(150000, 500000)
    VICE.giveMoney(user_id, cashReward)

    VICE.giveInventoryItem(user_id, "Joint", 1, true)
    local gotJoint = true

    TriggerEvent("VICE:RefreshInventory", source)
    TriggerClientEvent("VICE:weedBagDealResult", source, cashReward, gotJoint)

    if VICE.getInventoryItemAmount(user_id, "weedbag") > 0 then
        startWeedBagDeal(source, user_id)
    else
        activeWeedDeals[user_id] = nil
        TriggerClientEvent("VICE:clearWeedBagDeal", source)
    end
end)

AddEventHandler("playerDropped", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        activeWeedDeals[user_id] = nil
    end
end)
