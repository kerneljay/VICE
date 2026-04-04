MySQL = module("modules/database/MySQL")

local Inventory = module("VICEVeh", "inventory")
local Housing = module("vice", "cfg/cfg_housing")
local Dumpster = {}
local InventorySpamTrack = {}
LootBagEntities = {}
local InventoryCoolDown = {}
local a = module("cfg/weapons")

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        if not InventorySpamTrack[source] then
            InventorySpamTrack[source] = true;
            local UserId = VICE.getUserId(source) 
            local data = VICE.getUserDataTable(UserId)
            if data and data.inventory then
                if type(data.inventory) == "string" then
                    data.inventory = json.decode(data.inventory)
                end
                local FormattedInventoryData = {}
                for i,v in pairs(data.inventory) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                end
                if data.invcap == nil then
                    data.invcap = 30
                end
                VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
                    if cb then
                        if plathours > 0 and data.invcap < 50 then
                            data.invcap = 50
                        elseif plushours > 0 and data.invcap < 40 then
                            data.invcap = 40
                        end
                    end
                    TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(UserId))
                    InventorySpamTrack[source] = false;
                end)  
            else 
                --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
            end
        end
    end
end)

RegisterServerEvent("VICE:closeChest")
AddEventHandler("VICE:closeChest", function()
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent("VICE:endRobbingPlayer", source)
end)

RegisterNetEvent('VICE:FetchPersonalInventory')
AddEventHandler('VICE:FetchPersonalInventory', function()
    local source = source
    if not InventorySpamTrack[source] then
        InventorySpamTrack[source] = true;
        local UserId = VICE.getUserId(source) 
        local data = VICE.getUserDataTable(UserId)
        if data and data.inventory then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
            end
            TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(UserId))
            InventorySpamTrack[source] = false;
        else 
            --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
        end
    end
end)

RegisterNetEvent('VICE:FetchPersonalWeapons')
AddEventHandler('VICE:FetchPersonalWeapons', function()
    local source = source
    if not InventorySpamTrack[source] then
        InventorySpamTrack[source] = true
        local UserId = VICE.getUserId(source) 
        VICEclient.getWeapons(source, {}, function(weapons)
            if weapons then
                local FormattedWeaponData = {}
                for i, v in pairs(weapons) do
                    FormattedWeaponData[i] = {amount = v.amount, ItemName = VICE.getItemName(i)}
                end
                TriggerClientEvent('VICE:FetchPersonalWeapons', source, FormattedWeaponData)
                InventorySpamTrack[source] = false
            else 
                --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
            end
        end)
    end
end)

AddEventHandler('VICE:RefreshInventory', function(source)
    local UserId = VICE.getUserId(source) 
    local data = VICE.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
        end
        TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)

RegisterNetEvent('VICE:GiveItem')
AddEventHandler('VICE:GiveItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  VICE.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        VICE.RunGiveTask(source, itemId)
        TriggerEvent('VICE:RefreshInventory', source)
    else
        VICE.notify(source, '~r~You need to have this item on you to give it.')
    end
end)

RegisterNetEvent('VICE:GiveItemAll')
AddEventHandler('VICE:GiveItemAll', function(itemId, itemLoc)
    local source = source
    if not itemId then  VICE.notify(source, '~r~You need to select an item, first!') 
        return 
    end
    if itemLoc == "Plr" then
        VICE.RunGiveAllTask(source, itemId)
        TriggerEvent('VICE:RefreshInventory', source)
    else
        VICE.notify(source, '~r~You need to have this item on you to give it.')
    end
end)

RegisterNetEvent('VICE:TrashItem')
AddEventHandler('VICE:TrashItem', function(itemId, itemLoc)
    local source = source
    if not itemId then  VICE.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        VICE.RunTrashTask(source, itemId)
        TriggerEvent('VICE:RefreshInventory', source)
    else
        VICE.notify(source, '~r~You need to have this item on you to drop it.')
    end
end)

RegisterNetEvent('VICE:FetchTrunkInventory')
AddEventHandler('VICE:FetchTrunkInventory', function(spawnCode, owner_id)
    local source = source
    local user_id = VICE.getUserId(source)
    if not owner_id then owner_id = UserId end
    if not owner_id then owner_id = user_id end
    if InventoryCoolDown[source] then VICE.notify(source, '~r~Please wait before moving more items.') return end
    local carformat = "chest:u1veh_" .. spawnCode .. '|' .. owner_id
    VICE.getSData(carformat, function(cdata)
        local processedChest = {};
        cdata = json.decode(cdata) or {}
        local FormattedInventoryData = {}
        for i, v in pairs(cdata) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
        end
        local maxVehKg = Inventory.vehicle_chest_weights[spawnCode] or Inventory.default_vehicle_chest_weight
        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
        TriggerEvent('VICE:RefreshInventory', source)
    end)
end)

local inHouse = {}
RegisterNetEvent('VICE:FetchHouseInventory')
AddEventHandler('VICE:FetchHouseInventory', function(nameHouse)
    local source = source
    local user_id = VICE.getUserId(source)
    getUserByAddress(nameHouse, 1, function(huser_id)
        if huser_id == user_id or VICE.RecentlyRobbed(nameHouse) then
            inHouse[user_id] = nameHouse
            local homeformat = "chest:u" ..huser_id.. "home" ..inHouse[user_id]
            VICE.getSData(homeformat, function(cdata)
                local processedChest = {};
                cdata = json.decode(cdata) or {}
                local FormattedInventoryData = {}
                for i, v in pairs(cdata) do
                    FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                end
                local maxVehKg = Housing.chestsize[inHouse[user_id]] or 500
                TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
            end)
        else
            VICE.notify(source, "~r~You do not own this house!")
        end
    end)
end)

local inDumpster = {}
RegisterNetEvent('VICE:FetchDumpsterInventory')
AddEventHandler('VICE:FetchDumpsterInventory', function(nameDumpster)
    local source = source
    local user_id = VICE.getUserId(source)
    inDumpster[user_id] = nameDumpster
    local dumpsterformat = "chest:u" ..user_id.. "dumpster" ..inDumpster[user_id]
    VICE.getSData(dumpsterformat, function(cdata)
        local processedChest = {};
        cdata = json.decode(cdata) or {}

        cdata["wbody|WEAPON_MOSINCMG"] = {amount = 1}
        cdata["7.62mm Bullets"] = {amount = 255}

        local FormattedInventoryData = {}
        for i, v in pairs(cdata) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
        end
        local maxVehKg = 500
        TriggerClientEvent('VICE:callmemaybe', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
    end)
end)

local currentlySearching = {}

RegisterNetEvent('VICE:cancelPlayerSearch')
AddEventHandler('VICE:cancelPlayerSearch', function()
    local source = source
    local user_id = VICE.getUserId(source) 
    if currentlySearching[user_id] then
        TriggerClientEvent('VICE:cancelPlayerSearch', currentlySearching[user_id])
    end
end)

RegisterNetEvent('VICE:searchPlayer')
AddEventHandler('VICE:searchPlayer', function(playersrc)
    local source = source
    local user_id = VICE.getUserId(source) 
    local data = VICE.getUserDataTable(user_id)
    local their_id = VICE.getUserId(playersrc) 
    local their_data = VICE.getUserDataTable(their_id)
    if data and data.inventory and not currentlySearching[user_id] then
        currentlySearching[user_id] = playersrc
        TriggerClientEvent('VICE:startSearchingSuspect', source)
        TriggerClientEvent('VICE:startBeingSearching', playersrc, source)
        VICE.notify(playersrc, '~b~You are being searched.')
        Wait(10000)
        if currentlySearching[user_id] then
            local FormattedInventoryData = {}
            for i,v in pairs(data.inventory) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
            end
            exports['vice']:execute("SELECT * FROM vice_subscriptions WHERE user_id = @user_id", {user_id = user_id}, function(vipClubData)
                if #vipClubData > 0 then
                    if their_data and their_data.inventory then
                        local FormattedSecondaryInventoryData = {}
                        for i,v in pairs(their_data.inventory) do
                            FormattedSecondaryInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        if VICE.getMoney(their_id) > 0 then
                            FormattedSecondaryInventoryData['cash'] = {amount = VICE.getMoney(their_id), ItemName = 'Cash', Weight = 0.00}
                        end
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedSecondaryInventoryData, VICE.computeItemsWeight(their_data.inventory), 200)
                    end
                    if vipClubData[1].plathours > 0 then
                        TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id)+20)
                    elseif vipClubData[1].plushours > 0 then
                        TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id)+10)
                    else
                        TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id))
                    end
                    VICE.sendDCLog('search-player', 'VICE Search Player Logs', "> Searchers Name: **"..VICE.getPlayerName(user_id).."**\n> Searchers TempID: **"..source.."**\n> Searchers PermID: **"..user_id.."**\n> Players TempID: **"..playersrc.."**\n> Players PermID: **"..their_id.."**")
                    TriggerClientEvent('VICE:InventoryOpen', source, true)
                    currentlySearching[user_id] = nil
                end
            end)
        end
    end
end)


-- rob player where it gives you their inventory
RegisterNetEvent('VICE:robPlayer')
AddEventHandler('VICE:robPlayer', function(playersrc)
    local source = source
    VICEclient.globalSurrenderring(playersrc, {}, function(globalSurrenderring) 
        if globalSurrenderring then
            TriggerClientEvent('VICE:startRobbingPlayer', playersrc)
            if not InventorySpamTrack[source] then
                InventorySpamTrack[source] = true;
                local user_id = VICE.getUserId(source) 
                local data = VICE.getUserDataTable(user_id)
                local their_id = VICE.getUserId(playersrc) 
                local their_data = VICE.getUserDataTable(their_id)
                if data and data.inventory then
                    local FormattedInventoryData = {}
                    for i,v in pairs(data.inventory) do
                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                    end
                    TriggerClientEvent("VICE:endRobbingPlayer", playersrc)
                    TriggerClientEvent("VICE:endRobbingPlayer", source)
                    exports['vice']:execute("SELECT * FROM vice_subscriptions WHERE user_id = @user_id", {user_id = user_id}, function(vipClubData)
                        if #vipClubData > 0 then
                            if their_data and their_data.inventory then
                                local FormattedSecondaryInventoryData = {}
                                for i,v in pairs(their_data.inventory) do
                                    VICE.giveInventoryItem(user_id, i, v.amount)
                                    VICE.tryGetInventoryItem(their_id, i, v.amount)
                                end
                            end
                            if VICE.getMoney(their_id) > 0 then
                                VICE.AddStat(user_id,"amount_robbed",VICE.getMoney(their_id))
                                VICE.giveMoney(user_id, VICE.getMoney(their_id))
                                VICE.tryPayment(their_id, VICE.getMoney(their_id))
                            end
                            if vipClubData[1].plathours > 0 then
                                TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id)+20)
                            elseif vipClubData[1].plushours > 0 then
                                TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id)+10)
                            else
                                TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(user_id))
                            end
                            TriggerClientEvent('VICE:InventoryOpen', source, true)
                            InventorySpamTrack[source] = false;
                        end
                    end)
                else 
                    --print('An error has occured while trying to fetch inventory data from: ' .. user_id .. ' This may be a saving / loading data error you will need to investigate this.')
                end
            end
        else
            VICE.notify(source, '~r~This player is not on their knees.')
        end
    end)
end)

RegisterNetEvent('VICE:UseItem')
AddEventHandler('VICE:UseItem', function(itemId, itemLoc)
    local source = source
    local user_id = VICE.getUserId(source) 
    local data = VICE.getUserDataTable(user_id)
    if not itemId then 
        VICE.notify(source, '~r~You need to select an item, first!') 
        return
     end
    if itemLoc ~= "Plr" then
        VICE.notify(source, '~r~You need to have this item on you to use it.')
        return
    end
    VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
            local invcap = 30
            if plathours > 0 then
                invcap = 50
            elseif plushours > 0 then
                invcap = 40
            end
            if VICE.getInventoryMaxWeight(user_id) then
                if VICE.getInventoryMaxWeight(user_id) > invcap then
                    return
                end
            end
            if itemId == "offwhitebag" then
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+15)
                TriggerClientEvent('VICE:boughtBackpack', source, 5, 92, 0,40000,15, 'Off White Bag (+15kg)')
            elseif itemId == "guccibag" then 
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+20)
                TriggerClientEvent('VICE:boughtBackpack', source, 5, 94, 0,60000,20, 'Gucci Bag (+20kg)')
            elseif itemId == "nikebag" then 
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+30)
            elseif itemId == "huntingbackpack" then 
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+35)
                TriggerClientEvent('VICE:boughtBackpack', source, 5, 91, 0,100000,35, 'Hunting Backpack (+35kg)')
            elseif itemId == "greenhikingbackpack" then 
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+40)
            elseif itemId == "rebelbackpack" then 
                VICE.tryGetInventoryItem(user_id, itemId, 1, true)
                VICE.updateInvCap(user_id, invcap+70)
                TriggerClientEvent('VICE:boughtBackpack', source, 5, 90, 0,250000,70, 'Rebel Backpack (+70kg)')
            elseif itemId == "Shaver" then 
                VICE.ShaveHead(source)
            -- elseif itemId == "rift2go" then 
            --     VICEclient.RiftIsAGo(source)
            --     VICE.tryGetInventoryItem(user_id, 'rift2go', 1)
            elseif itemId == "burnerphone" then 
                TriggerEvent("VICE:CreateDirtyCashDealer", user_id)
            elseif itemId == "handcuffkeys" then 
                VICE.handcuffKeys(source)
            elseif itemId == "armourplate" then 
                if VICE.hasGroup(user_id,"AdvancedRebel") then
                    VICE.ArmourPlate(source)
                else
                    VICE.notify(source,"~r~A advanced rebel license is required to apply armour!")
                end
            end
        end
    end) 
    VICE.RunInventoryTask(source, itemId)
    TriggerEvent('VICE:RefreshInventory', source)
end)

local alreadyEquiping = {}
RegisterNetEvent('VICE:EquipAll')
AddEventHandler('VICE:EquipAll', function()
    local source = source
    local user_id = VICE.getUserId(source) 
    if alreadyEquiping[user_id] then
        VICE.notify(source, '~r~You are already equiping all items')
        return
    end
    alreadyEquiping[user_id] = true
    local data = VICE.getUserDataTable(user_id)
    local sortedTable = {}
    for item,v in pairs(data.inventory) do
        if string.find(item, 'wbody|') or seizeBullets[item] then
            table.insert(sortedTable, item)
        end
    end
    table.sort(sortedTable, function(a,b) 
        if string.find(a, 'wbody|') and string.find(b, 'wbody|') then
            return a < b
        elseif string.find(a, 'wbody|') then
            return true
        elseif string.find(b, 'wbody|') then
            return false
        else
            return a < b
        end
    end)
    for _, item in ipairs(sortedTable) do
        if string.find(item:lower(), 'wbody|') then
            VICE.RunInventoryTask(source, item)
        elseif seizeBullets[item] then
            VICE.LoadAllTask(source, item)
        end
        Wait(500)
    end
    TriggerEvent('VICE:RefreshInventory', source)
    alreadyEquiping[user_id] = false
end)

local alreadyTransfering = {}
RegisterNetEvent("VICE:TransferAll")
AddEventHandler("VICE:TransferAll",function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    if not alreadyTransfering[user_id] then
        alreadyTransfering[user_id] = true
        local inventory = VICE.getUserDataTable(user_id).inventory
        local carformat = "chest:u1veh_" .. spawncode .. "|" .. user_id
        local maxVehKg = Inventory.vehicle_chest_weights[spawncode] or Inventory.default_vehicle_chest_weight
        VICE.getSData(carformat,function(cardata)
            cardata = json.decode(cardata) or {}
            local carweight = VICE.computeItemsWeight(cardata)
            for A,B in pairs(inventory) do
                local amount = B.amount
                local itemweight = VICE.getItemWeight(A)*amount
                if carweight+itemweight <= maxVehKg then
                    if VICE.tryGetInventoryItem(user_id,A,amount,true) then
                        if cardata[A] then
                            cardata[A].amount = cardata[A].amount + amount
                        else
                            cardata[A] = {}
                            cardata[A].amount = amount
                        end
                        local FormattedInventoryData = {}
                        for i, v in pairs(cardata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        TriggerClientEvent('VICE:SendSecondaryInventoryData',source,FormattedInventoryData,VICE.computeItemsWeight(cardata),maxVehKg)
                        carweight = carweight+itemweight
                        Wait(500)
                    end
                else
                    VICE.notify(source, '~r~You cannot move this item.')
                end
            end
            alreadyTransfering[user_id] = false
            VICE.setSData(carformat,json.encode(cardata))
        end)
    else
        VICE.notify(source, '~r~You are already transfering all items')
        return
    end
end)

RegisterNetEvent('VICE:MoveItem')
AddEventHandler('VICE:MoveItem', function(inventoryType, itemId, inventoryInfo, Lootbag, owner_id)
    local source = source
    local UserId = VICE.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = VICE.getUserDataTable(UserId)
    if InventoryCoolDown[source] then VICE.notify(source, '~r~Please wait before moving more items.') return end
    if not itemId then VICE.notify(source, '~r~You need to select an item, first!') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
            VICE.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+VICE.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        VICE.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = false;
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    InventoryCoolDown[source] = false;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end)
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then  
            if itemId then  
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = VICE.getInventoryWeight(UserId)+VICE.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > 1 then
                            LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - 1 
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        end
                        local FormattedInventoryData = {}
                        for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = 200
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                        TriggerEvent('VICE:RefreshInventory', source)
                        InventoryCoolDown[source] = false
                        if not next(LootBagEntities[inventoryInfo].Items) then
                            CloseInv(source)
                            ProcessCrateDrop(inventoryInfo)
                        end
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                end
            end
        elseif inventoryType == "Dumpster" then
            InventoryCoolDown[source] = true
            local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
            VICE.getSData(dumpsterformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+VICE.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = 500
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        VICE.setSData(dumpsterformat, json.encode(cdata))
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                end
            end)
        elseif inventoryType == "Housing" then
            InventoryCoolDown[source] = true
            local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
            VICE.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount >= 1 then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+VICE.getItemWeight(itemId)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if cdata[itemId].amount > 1 then
                            cdata[itemId].amount = cdata[itemId].amount - 1; 
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        else 
                            cdata[itemId] = nil;
                            VICE.giveInventoryItem(UserId, itemId, 1, true)
                        end 
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        InventoryCoolDown[source] = false;
                        VICE.setSData(homeformat, json.encode(cdata))
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "dumpster" then --start of housing intergration (moveitem)
                        local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                        VICE.getSData(dumpsterformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = VICE.computeItemsWeight(cdata)+VICE.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = 500
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = 500
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    VICE.setSData(dumpsterformat, json.encode(cdata))
                                else 
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end)
                    elseif inventoryInfo == "home" then --start of housing intergration (moveitem)
                        local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
                        local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                        VICE.getSData(homeformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = VICE.computeItemsWeight(cdata)+VICE.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    VICE.setSData(homeformat, json.encode(cdata))
                                else 
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end) --end of housing intergration (moveitem)
                    else
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                        VICE.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = VICE.computeItemsWeight(cdata)+VICE.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                        cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    VICE.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)

local alreadyLootingAll = {}
RegisterNetEvent('VICE:LootItemAll')
AddEventHandler('VICE:LootItemAll', function(inventoryInfo)
    local source = source
    local user_id = VICE.getUserId(source) 
    if alreadyLootingAll[user_id] then
        VICE.notify(source, '~r~You are already looting all items')
        return
    end
    local data = VICE.getUserDataTable(user_id)
    local totalBagWeight = 0
    local CarBoot = 0
    for itemId, _ in pairs(LootBagEntities[inventoryInfo].Items) do
        if LootBagEntities[inventoryInfo].Items[itemId] ~= nil then
            local weightCalculation = VICE.getInventoryWeight(user_id)+VICE.getItemWeight(itemId)
            if weightCalculation then 
                totalBagWeight = totalBagWeight + weightCalculation
            end
        end
    end
    if totalBagWeight > VICE.getInventoryMaxWeight(user_id) then
        VICE.notify(source, '~r~You do not have enough inventory space.')
        return
    end
    alreadyLootingAll[user_id] = true
    for itemId, _ in pairs(LootBagEntities[inventoryInfo].Items) do
        if LootBagEntities[inventoryInfo].Items[itemId] ~= nil then
            VICE.giveInventoryItem(user_id, itemId, LootBagEntities[inventoryInfo].Items[itemId].amount, true)
            LootBagEntities[inventoryInfo].Items[itemId] = nil;

            local FormattedInventoryData = {}
            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
            end
            local maxVehKg = 200
            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)    
            Wait(500)
        end
    end
    CloseInv(source)
    TriggerEvent('VICE:RefreshInventory', source)
    ProcessCrateDrop(inventoryInfo)
    alreadyLootingAll[user_id] = false
end)

RegisterNetEvent('VICE:UseAllItem')
AddEventHandler('VICE:UseAllItem', function(itemId, itemLoc)
    local source = source
    local user_id = VICE.getUserId(source) 
    if not itemId then VICE.notify(source, '~r~You need to select an item, first!') return end
    if itemLoc == "Plr" then
        VICE.LoadAllTask(source, itemId)
        TriggerEvent('VICE:RefreshInventory', source)
    else
        VICE.notify(source, '~r~You need to have this item on you to use it.')
    end
end)

RegisterNetEvent('VICE:MoveItemX')
AddEventHandler('VICE:MoveItemX', function(inventoryType, itemId, inventoryInfo, Lootbag, Quantity, owner_id)
    local source = source
    local UserId = VICE.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = VICE.getUserDataTable(UserId)
    if InventoryCoolDown[source] then VICE.notify(source, '~r~Please wait before moving more items.') return end
    if not itemId then  VICE.notify(source, '~r~You need to select an item, first!') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            if Quantity >= 1 then
                local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                VICE.getSData(carformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                            end
                            local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('VICE:RefreshInventory', source)
                            InventoryCoolDown[source] = nil;
                            VICE.setSData(carformat, json.encode(cdata))
                        else 
                            InventoryCoolDown[source] = nil;
                            VICE.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        InventoryCoolDown[source] = nil;
                        VICE.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else
                InventoryCoolDown[source] = nil;
                VICE.notify(source, '~r~Invalid Amount!')
            end
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then    
            if LootBagEntities[inventoryInfo].Items[itemId] then 
                Quantity = parseInt(Quantity)
                if Quantity then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * Quantity)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if Quantity <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            if LootBagEntities[inventoryInfo].Items[itemId] and LootBagEntities[inventoryInfo].Items[itemId].amount > Quantity then
                                LootBagEntities[inventoryInfo].Items[itemId].amount = LootBagEntities[inventoryInfo].Items[itemId].amount - Quantity
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                LootBagEntities[inventoryInfo].Items[itemId] = nil;
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            end
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('VICE:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                                ProcessCrateDrop(inventoryInfo)
                            end
                        else 
                            VICE.notify(source, '~r~You are trying to move more then there actually is!')
                        end 
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    VICE.notify(source, '~r~Invalid input!')
                end
            end
        elseif inventoryType == "Housing" then
            Quantity = parseInt(Quantity)
            if Quantity then
                local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
                local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                VICE.getSData(homeformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                            end
                            print(json.encode(FormattedInventoryData))
                            print(json.encode(cdata))
                            local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('VICE:RefreshInventory', source)
                            VICE.setSData(homeformat, json.encode(cdata))
                        else 
                            VICE.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        VICE.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else 
                VICE.notify(source, '~r~Invalid input!')
            end
        elseif inventoryType == "Dumpster" then
            Quantity = parseInt(Quantity)
            if Quantity then
                local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                VICE.getSData(dumpsterformat, function(cdata)
                    cdata = json.decode(cdata) or {}
                    if cdata[itemId] and Quantity <= cdata[itemId].amount  then
                        local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * Quantity)
                        if weightCalculation == nil then return end
                        if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                            if cdata[itemId].amount > Quantity then
                                cdata[itemId].amount = cdata[itemId].amount - Quantity; 
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            else 
                                cdata[itemId] = nil;
                                VICE.giveInventoryItem(UserId, itemId, Quantity, true)
                            end 
                            local FormattedInventoryData = {}
                            for i, v in pairs(cdata) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                            end
                            print(json.encode(FormattedInventoryData))
                            print(json.encode(cdata))
                            local maxVehKg = 500
                            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                            TriggerEvent('VICE:RefreshInventory', source)
                            VICE.setSData(dumpsterformat, json.encode(cdata))
                        else 
                            VICE.notify(source, '~r~You do not have enough inventory space.')
                        end
                    else 
                        VICE.notify(source, '~r~You are trying to move more then there actually is!')
                    end
                end)
            else 
                VICE.notify(source, '~r~Invalid input!')
            end
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "dumpster" then --start of housing intergration (moveitem)
                        local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
                        VICE.getSData(dumpsterformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount >= 1 then
                                local weightCalculation = VICE.computeItemsWeight(cdata)+VICE.getItemWeight(itemId)
                                if weightCalculation == nil then return end
                                local maxVehKg = 500
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, 1, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + 1
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = 1
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = 500
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    VICE.setSData(dumpsterformat, json.encode(cdata))
                                else 
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the home.')
                            end
                        end)
                    elseif inventoryInfo == "home" then --start of housing intergration (moveitemx)
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
                            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                            VICE.getSData(homeformat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = VICE.computeItemsWeight(cdata)+(VICE.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    if weightCalculation <= maxVehKg then
                                        if VICE.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                        end
                                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('VICE:RefreshInventory', source)
                                        VICE.setSData(homeformat, json.encode(cdata))
                                    else 
                                        VICE.notify(source, '~r~You do not have enough inventory space.')
                                    end
                                else 
                                    VICE.notify(source, '~r~You are trying to move more then there actually is!')
                                end
                            end)
                        else 
                            VICE.notify(source, '~r~Invalid input!')
                        end
                    else
                        InventoryCoolDown[source] = true;
                        Quantity = parseInt(Quantity)
                        if Quantity then
                            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                            VICE.getSData(carformat, function(cdata)
                                cdata = json.decode(cdata) or {}
                                if data.inventory[itemId] and Quantity <= data.inventory[itemId].amount  then
                                    local weightCalculation = VICE.computeItemsWeight(cdata)+(VICE.getItemWeight(itemId) * Quantity)
                                    if weightCalculation == nil then return end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    if weightCalculation <= maxVehKg then
                                        if VICE.tryGetInventoryItem(UserId, itemId, Quantity, true) then
                                            if cdata[itemId] then
                                                cdata[itemId].amount = cdata[itemId].amount + Quantity
                                            else 
                                                cdata[itemId] = {}
                                                cdata[itemId].amount = Quantity
                                            end
                                        end 
                                        local FormattedInventoryData = {}
                                        for i, v in pairs(cdata) do
                                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                        end
                                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                        TriggerEvent('VICE:RefreshInventory', source)
                                        InventoryCoolDown[source] = nil;
                                        VICE.setSData(carformat, json.encode(cdata))
                                    else 
                                        InventoryCoolDown[source] = nil;
                                        VICE.notify(source, '~r~You do not have enough inventory space.')
                                    end
                                else 
                                    InventoryCoolDown[source] = nil;
                                    VICE.notify(source, '~r~You are trying to move more then there actually is!')
                                end
                            end)
                        else 
                            VICE.notify(source, '~r~Invalid input!')
                        end
                    end
                else
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


RegisterNetEvent('VICE:MoveItemAll')
AddEventHandler('VICE:MoveItemAll', function(inventoryType, itemId, inventoryInfo, vehid, owner_id)
    local source = source
    local UserId = VICE.getUserId(source) 
    if not owner_id then owner_id = UserId end
    local data = VICE.getUserDataTable(UserId)
    if not itemId then VICE.notify(source, '~r~You need to select an item, first!') return end
    if InventoryCoolDown[source] then VICE.notify(source, '~r~Please wait before moving more items.') return end
    if data and data.inventory then
        if inventoryInfo == nil then return end
        if inventoryType == "CarBoot" then
            InventoryCoolDown[source] = true;
            local idz = NetworkGetEntityFromNetworkId(vehid)
            local user_id = VICE.getUserId(NetworkGetEntityOwner(idz))
            local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
            VICE.getSData(carformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = VICE.getInventoryWeight(user_id)+(VICE.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    local amount = cdata[itemId].amount
                    if weightCalculation > VICE.getInventoryMaxWeight(user_id) and VICE.getInventoryWeight(user_id) ~= VICE.getInventoryMaxWeight(user_id) then
                        amount = math.floor((VICE.getInventoryMaxWeight(user_id)-VICE.getInventoryWeight(user_id)) / VICE.getItemWeight(itemId))
                    end
                    if math.floor(amount) > 0 or (weightCalculation <= VICE.getInventoryMaxWeight(user_id)) then
                        VICE.giveInventoryItem(user_id, itemId, amount, true)
                        local FormattedInventoryData = {}
                        if (cdata[itemId].amount - amount) > 0 then
                            cdata[itemId].amount = cdata[itemId].amount - amount
                        else
                            cdata[itemId] = nil
                        end
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        InventoryCoolDown[source] = nil;
                        VICE.setSData(carformat, json.encode(cdata))
                    else 
                        InventoryCoolDown[source] = nil;
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    InventoryCoolDown[source] = nil;
                    VICE.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "LootBag" or inventoryType == "Crate" then  
            if itemId then    
                if LootBagEntities[inventoryInfo].Items[itemId] then 
                    local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) *  LootBagEntities[inventoryInfo].Items[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        if  LootBagEntities[inventoryInfo].Items[itemId].amount <= LootBagEntities[inventoryInfo].Items[itemId].amount then 
                            VICE.giveInventoryItem(UserId, itemId, LootBagEntities[inventoryInfo].Items[itemId].amount, true)
                            LootBagEntities[inventoryInfo].Items[itemId] = nil;
                            local FormattedInventoryData = {}
                            for i, v in pairs(LootBagEntities[inventoryInfo].Items) do
                                FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                            end
                            local maxVehKg = 200
                            TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(LootBagEntities[inventoryInfo].Items), maxVehKg)                
                            TriggerEvent('VICE:RefreshInventory', source)
                            if not next(LootBagEntities[inventoryInfo].Items) then
                                CloseInv(source)
                                ProcessCrateDrop(inventoryInfo)
                            end
                        else 
                            VICE.notify(source, '~r~You are trying to move more then there actually is!')
                        end 
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                end
            end
        elseif inventoryType == "Dumpster" then
            local dumpsterformat = "chest:u" ..(owner_id or UserId).. "dumpster" ..inDumpster[UserId]
            VICE.getSData(dumpsterformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        VICE.giveInventoryItem(UserId, itemId, cdata[itemId].amount, true)
                        cdata[itemId] = nil;
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = 500
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        VICE.setSData(dumpsterformat, json.encode(cdata))
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    VICE.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "Housing" then
            local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
            local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
            VICE.getSData(homeformat, function(cdata)
                cdata = json.decode(cdata) or {}
                if cdata[itemId] and cdata[itemId].amount <= cdata[itemId].amount  then
                    local weightCalculation = VICE.getInventoryWeight(UserId)+(VICE.getItemWeight(itemId) * cdata[itemId].amount)
                    if weightCalculation == nil then return end
                    if weightCalculation <= VICE.getInventoryMaxWeight(UserId) then
                        VICE.giveInventoryItem(UserId, itemId, cdata[itemId].amount, true)
                        cdata[itemId] = nil;
                        local FormattedInventoryData = {}
                        for i, v in pairs(cdata) do
                            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                        end
                        local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                        TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                        TriggerEvent('VICE:RefreshInventory', source)
                        VICE.setSData(homeformat, json.encode(cdata))
                    else 
                        VICE.notify(source, '~r~You do not have enough inventory space.')
                    end
                else 
                    VICE.notify(source, '~r~You are trying to move more then there actually is!')
                end
            end)
        elseif inventoryType == "Plr" then
            if not Lootbag then
                if data.inventory[itemId] then
                    if inventoryInfo == "home" then
                        local recentlyrobbed,owner_id = VICE.RecentlyRobbed(inHouse[UserId])
                        local homeformat = "chest:u" ..(recentlyrobbed and owner_id or UserId).. "home" ..inHouse[UserId]
                        VICE.getSData(homeformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = VICE.computeItemsWeight(cdata)+(VICE.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end 
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = Housing.chestsize[inHouse[UserId]] or 500
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    VICE.setSData(homeformat, json.encode(cdata))
                                else 
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                VICE.notify(source, '~r~You are trying to move more then there actually is!')
                            end
                        end) --end of housing intergration (moveitemall)
                    else 
                        InventoryCoolDown[source] = true;
                        local carformat = "chest:u1veh_" .. inventoryInfo .. '|' .. owner_id
                        VICE.getSData(carformat, function(cdata)
                            cdata = json.decode(cdata) or {}
                            if data.inventory[itemId] and data.inventory[itemId].amount <= data.inventory[itemId].amount  then
                                local itemAmount = data.inventory[itemId].amount
                                local weightCalculation = VICE.computeItemsWeight(cdata)+(VICE.getItemWeight(itemId) * itemAmount)
                                if weightCalculation == nil then return end
                                local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                if weightCalculation <= maxVehKg then
                                    if VICE.tryGetInventoryItem(UserId, itemId, itemAmount, true) then
                                        if cdata[itemId] then
                                            cdata[itemId].amount = cdata[itemId].amount + itemAmount
                                        else 
                                            cdata[itemId] = {}
                                            cdata[itemId].amount = itemAmount
                                        end
                                    end 
                                    local FormattedInventoryData = {}
                                    for i, v in pairs(cdata) do
                                        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
                                    end
                                    local maxVehKg = Inventory.vehicle_chest_weights[inventoryInfo] or Inventory.default_vehicle_chest_weight
                                    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(cdata), maxVehKg)
                                    TriggerEvent('VICE:RefreshInventory', source)
                                    InventoryCoolDown[source] = nil;
                                    VICE.setSData(carformat, json.encode(cdata))
                                else 
                                    InventoryCoolDown[source] = nil;
                                    VICE.notify(source, '~r~You do not have enough inventory space.')
                                end
                            else 
                                InventoryCoolDown[source] = nil;
                                VICE.notify(source, '~r~You are trying to move more then there actually is!')
                            end
                        end)
                    end
                else
                    InventoryCoolDown[source] = nil;
                    --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This is usually caused by cheating as the item does not exist in the car boot.')
                end
            end
        end
    else 
        InventoryCoolDown[source] = nil;
        --print('An error has occured while trying to move an item. Inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
end)


-- LOOTBAGS CODE BELOW HERE 



RegisterNetEvent('VICE:InComa')
AddEventHandler('VICE:InComa', function()
 local greenzone = vector3(1474.7325439453,3567.0590820312,36.820770263672) --
 local greenzoneDist = 15.0

    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id or not VICEclient then return end
    if not VICEclient.InMainEvent(user_id) then
        VICEclient.isInComa(source, {}, function(in_coma) 
            if in_coma then
                Wait(1500)
                local ndata = VICE.getUserDataTable(user_id)
                if not ndata then return end
                if not ndata.inventory then return end
                if table.count(ndata.inventory) == 0 then return end
                 local coords =GetEntityCoords(GetPlayerPed(source))
 local insidegreenzone = #(coords-greenzone) <= greenzoneDist 
  
                if insidegreenzone then 
                    VICE.notify(source,'~g~lootbags do not drop in the gulag ')
                    return 
                end 
                if CloseToRestart then 
                    VICE.notify(source, '~r~Lootbag not dropped due to server restart.')
                    return 
                end 
                VICE.setDirtyCash(user_id, 0, true)
                local model = GetHashKey('xs_prop_arena_bag_01')
                local name1 = VICE.getPlayerName(user_id)
                local lootbag = CreateObjectNoOffset(model, GetEntityCoords(GetPlayerPed(source)) + 0.2, true, true, false)
                local lootbagnetid = NetworkGetNetworkIdFromEntity(lootbag)
                SetEntityRoutingBucket(lootbag, GetPlayerRoutingBucket(source))
                local stored_inventory = nil;
                TriggerEvent('VICE:StoreWeaponsRequest', source)
                LootBagEntities[lootbagnetid] = {lootbag, lootbag, false, source}
                LootBagEntities[lootbagnetid].Items = {}
                LootBagEntities[lootbagnetid].name = name1 
                stored_inventory = ndata.inventory
                VICE.clearInventory(user_id)
                for k, v in pairs(stored_inventory) do
                    LootBagEntities[lootbagnetid].Items[k] = {}
                    LootBagEntities[lootbagnetid].Items[k].amount = v.amount
                end
            end
        end)
    end
end)
local videoQueue = {}
local isProcessingQueue = false

local function processQueue()
    if #videoQueue > 0 and not isProcessingQueue then
        isProcessingQueue = true
        local task = table.remove(videoQueue, 1)
        TriggerClientEvent("VICE:takeClientVideoAndUpload", task.source, VICE.getWebhook('media-cache'), "Lootbag")
        SetTimeout(15000, function()
            isProcessingQueue = false
            processQueue()
        end)
    end
end
RegisterNetEvent('VICE:LootBag')
AddEventHandler('VICE:LootBag', function(netid)
    local source = source
    VICEclient.isInComa(source, {}, function(in_coma) 
        if not in_coma then
            if LootBagEntities[netid] then
                LootBagEntities[netid][3] = true;
                local user_id = VICE.getUserId(source)
                if user_id then
                    TriggerClientEvent("VICE:playZipperSound", -1, GetEntityCoords(GetPlayerPed(source)))
                    table.insert(videoQueue, {source = source})
                    processQueue()
                    LootBagEntities[netid][5] = source
                    if VICE.hasPermission(user_id, "police.armoury") then
                        local bagData = LootBagEntities[netid].Items
                        if bagData == nil then return end
                        for a,b in pairs(bagData) do
                            if string.find(a, 'wbody|') then
                                c = a:gsub('wbody|', '')
                                bagData[c] = b
                                bagData[a] = nil
                            end
                        end
                        for k,v in pairs(a.weapons) do
                            if bagData[k] then
                                if not v.policeWeapon then
                                    VICE.notify(source, '~r~Seized '..v.name..' x'..bagData[k].amount..'.')
                                    bagData[k] = nil
                                end
                            end
                        end
                        for c,d in pairs(bagData) do
                            if seizeBullets[c] then
                                VICE.notify(source, '~r~Seized '..c..' x'..d.amount..'.')
                                bagData[c] = nil
                            end
                        end
                        LootBagEntities[netid].Items = bagData
                        VICE.notify(source, "~r~You have seized " .. LootBagEntities[netid].name .. "'s items")
                        if #LootBagEntities[netid].Items > 0 then
                            VICE.notify(source, "~g~You opened " .. LootBagEntities[netid].name .. "'s lootbag.")
                            OpenInv(source, netid, LootBagEntities[netid].Items)
                        end
                    else
                        VICE.notify(source, "~g~You opened " .. LootBagEntities[netid].name .. "'s lootbag.")
                        OpenInv(source, netid, LootBagEntities[netid].Items)
                    end  
                end
            else
                VICE.notify(source, '~r~This loot bag is unavailable.')
                local bag = NetworkGetEntityFromNetworkId(netid)
                if DoesEntityExist(bag) then
                    DeleteEntity(bag)
                end
                TriggerClientEvent("VICE:deletePropClient", -1, netid)
            end
        else 
            VICE.notify(source, '~r~You cannot open this while dead.')
        end
    end)
end)

Citizen.CreateThread(function()
    while true do 
        Wait(250)
        for i,v in pairs(LootBagEntities) do 
            if v[5] then 
                local coords = GetEntityCoords(GetPlayerPed(v[5]))
                local objectcoords = GetEntityCoords(v[1])
                if #(objectcoords - coords) > 5.0 then
                    CloseInv(v[5])
                    Wait(3000)
                    v[3] = false; 
                    v[5] = nil;
                end
            end
        end
    end
end)

RegisterNetEvent('VICE:CloseLootbag')
AddEventHandler('VICE:CloseLootbag', function()
    local source = source
    for i,v in pairs(LootBagEntities) do 
        if v[5] and v[5] == source then 
            CloseInv(v[5])
            Wait(3000)
            v[3] = false; 
            v[5] = nil;
        end
    end
end)

function CloseInv(source)
    TriggerClientEvent('VICE:InventoryOpen', source, false, false)
    TriggerClientEvent("VICE:closeSecondInventory", source)
end

function OpenInv(source, netid, LootBagItems)
    local UserId = VICE.getUserId(source)
    local data = VICE.getUserDataTable(UserId)
    if data and data.inventory then
        local FormattedInventoryData = {}
        for i,v in pairs(data.inventory) do
            FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
        end
        TriggerClientEvent('VICE:FetchPersonalInventory', source, FormattedInventoryData, VICE.computeItemsWeight(data.inventory), VICE.getInventoryMaxWeight(UserId))
        InventorySpamTrack[source] = false;
    else 
        --print('An error has occured while trying to fetch inventory data from: ' .. UserId .. ' This may be a saving / loading data error you will need to investigate this.')
    end
    TriggerClientEvent('VICE:InventoryOpen', source, true, true, netid)
    local FormattedInventoryData = {}
    for i, v in pairs(LootBagItems) do
        FormattedInventoryData[i] = {amount = v.amount, ItemName = VICE.getItemName(i), Weight = VICE.getItemWeight(i)}
    end
    local maxVehKg = 200
    TriggerClientEvent('VICE:SendSecondaryInventoryData', source, FormattedInventoryData, VICE.computeItemsWeight(LootBagItems), maxVehKg)
end


-- Garabge collector for empty lootbags.
Citizen.CreateThread(function()
    while true do 
        Wait(500)
        for i,v in pairs(LootBagEntities) do 
            local itemCount = 0;
            for i,v in pairs(v.Items) do
                itemCount = itemCount + 1
            end
            if itemCount == 0 then
                if DoesEntityExist(v[1]) then 
                    DeleteEntity(v[1])
                    LootBagEntities[i] = nil;
                end
            end
        end
    end
end)

function getMoneyStringFormatted(cashString)
	local i, j, minus, int, fraction = tostring(cashString):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction 
end

local usersLockpicking = {}
local userLockpicked = {}

RegisterNetEvent('VICE:attemptLockpick')
AddEventHandler('VICE:attemptLockpick', function(veh, netveh, ownerid, spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    local owner_source = VICE.getUserSource(ownerid)
    local mods = VICE.GetDefaultMods()
    if VICE.tryGetInventoryItem(user_id, 'Lockpick', 1, true) then
        local chance = math.random(1,8)
        TriggerClientEvent('VICE:playLockpickAlarm', -1, netveh)
        if chance == 1 then
            usersLockpicking[user_id] = true
            TriggerClientEvent('VICE:lockpickClient', source, veh, true, spawncode)
            if mods.security_alarm then
               TriggerClientEvent('VICE:vehicleBeingLockpicked', owner_source, spawncode)
            end
            VICE.sendDCLog('lock-pick', 'Vehicle Being Lockpicked', 'Vehicle: ' .. spawncode .. ' | Owner User ID: ' .. ownerid .. ' | Lockpicker User ID: ' .. user_id)
            userLockpicked[ownerid] = userLockpicked[ownerid] or {}
            userLockpicked[ownerid][spawncode] = true 
        else
            TriggerClientEvent('VICE:lockpickClient', source, veh, false)
        end
    end
end)

RegisterNetEvent('VICE:callLockpickNotify')
AddEventHandler('VICE:callLockpickNotify', function(veh, netveh, ownerid)
    local owner_source = VICE.getUserSource(ownerid)
    if userLockpicked[ownerid] and userLockpicked[ownerid][veh] then
        VICE.notify(owner_source, '~r~Your vehicle has been lockpicked since it was last out.')
        userLockpicked[ownerid][veh] = false 
    end
end)

RegisterNetEvent('VICE:lockpickVehicle')
AddEventHandler('VICE:lockpickVehicle', function(vehicle, ownerid, spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    if usersLockpicking[user_id] then
        VICEclient.setVehicleOwner(source,{vehicle,spawncode, ownerid}) 
    end
end)

RegisterNetEvent('VICE:setVehicleLock')
AddEventHandler('VICE:setVehicleLock', function(netid)
    local source = source
    local user_id = VICE.getUserId(source)
    if usersLockpicking[user_id] then
        SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(netid), false)
        usersLockpicking[user_id] = nil 
    end
end)