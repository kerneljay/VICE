local cfg = module("cfg/cfg_lscustoms")
local lockedGarages = {}

function VICE.GetVehiclesNitro(user_id,spawncode)
    local nitro = 0
    local data = exports['vice']:executeSync('SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @spawncode', {user_id = user_id, spawncode = spawncode})
    if data[1] ~= nil then
        nitro = tonumber(data[1].nitro)
    end
    return nitro
end

function VICE.GetVehiclesFuel(user_id,spawncode)
    local fuel_level = exports['vice']:executeSync("SELECT fuel_level FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @spawncode", {user_id = user_id, spawncode = spawncode})[1].fuel_level
    return fuel_level or 100
end

function VICE.GetVehiclesPlate(user_id,spawncode)
    local plate = exports['vice']:executeSync("SELECT vehicle_plate FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @spawncode", {user_id = user_id, spawncode = spawncode})[1].vehicle_plate
    return plate or "Unknown"
end

RegisterServerEvent("VICE:setCustomsGarageStatus", function(garage,bool)
    local source = source
    local user_id = VICE.getUserId(source)
    if not bool then
        lockedGarages[garage] = nil
    else
        lockedGarages[garage] = {
            locked = true,
            player = source
        }
    end
    TriggerClientEvent('VICE:setCustomsGarageStatus', -1,garage,bool)
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        TriggerClientEvent('VICE:syncCustomsGarageStatus', source,lockedGarages)
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    for L,O in pairs(lockedGarages)do
        if O.player == source then
            TriggerClientEvent('VICE:setCustomsGarageStatus', -1,L,false)
            lockedGarages[L] = nil
            return
        end
    end
end)

MySQL.createCommand("VICE/GetUsersVehicleMods","SELECT * FROM vice_vehicle_mods WHERE user_id = @user_id AND spawncode = @spawncode")

MySQL.createCommand("VICE/GetUsersVehicleMod","SELECT * FROM vice_vehicle_mods WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey")
MySQL.createCommand("VICE/GetUsersSpecificVehicleMod","SELECT * FROM vice_vehicle_mods WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey AND `mod` = @mod")
MySQL.createCommand("VICE/InsertNewVehicleMod","INSERT INTO vice_vehicle_mods (user_id,spawncode,savekey,`mod`) VALUES (@user_id,@spawncode,@savekey,@mod)")
MySQL.createCommand("VICE/UpdateVehicleMod","UPDATE vice_vehicle_mods SET `mod` = @mod WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey")
MySQL.createCommand("VICE/DeleteVehicleMod","DELETE FROM vice_vehicle_mods WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey AND `mod` = @mod")

MySQL.createCommand("VICE/SetModEnabled","UPDATE vice_vehicle_mods SET enabled = @enabled WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey AND `mod` = @mod")

MySQL.createCommand("VICE/SetNewModValue","UPDATE vice_vehicle_mods SET `mod` = @mod WHERE user_id = @user_id AND spawncode = @spawncode AND savekey = @savekey AND `mod` = @oldmod")

MySQL.createCommand("VICE/GetVehicleStancerMods","SELECT * FROM vice_vehicle_stancer WHERE user_id = @user_id AND spawncode = @spawncode")
MySQL.createCommand("VICE/InsertNewVehicleStancerMod","INSERT INTO vice_vehicle_stancer (user_id,spawncode,`mod`) VALUES (@user_id,@spawncode,@mod)")
MySQL.createCommand("VICE/UpdateVehicleStancerMod","UPDATE vice_vehicle_stancer SET `value` = @value WHERE user_id = @user_id AND spawncode = @spawncode AND `mod` = @mod")

local function DisableOtherMods(spawncode,user_id,cat)
    local savekey = cat.saveKey
    local othersInCat = MySQL.asyncQuery("VICE/GetUsersVehicleMod",{user_id = user_id, spawncode = spawncode, savekey = savekey})
    local enabledTable = {}
    for k,v in pairs(othersInCat) do
        MySQL.execute("VICE/SetModEnabled",{user_id = user_id, spawncode = spawncode, savekey = savekey, mod = v.mod, enabled = 0})
        enabledTable[tostring(v.mod)] = false
    end
    local unapplyList = cat.unapply
    if unapplyList then
        unapplyList = string.gsub(unapplyList, " ", "")
        unapplyList = stringsplit(unapplyList, ",")
        local vehicleMods = MySQL.asyncQuery("VICE/GetUsersVehicleMods",{user_id = user_id, spawncode = spawncode})
        for k,v in pairs(vehicleMods) do
            if table.find(unapplyList,v.savekey)~=nil and table.find(unapplyList,v.savekey)~=false then
                MySQL.execute("VICE/SetModEnabled",{user_id = user_id, spawncode = spawncode, savekey = v.savekey, mod = v.mod, enabled = 0})
                enabledTable[tostring(v.mod)] = false
            end
        end
    end
    return enabledTable
end

local function SetModEnabled(spawncode,user_id,cat,mod)
    local savekey = cat.saveKey
    local enabledTable = DisableOtherMods(spawncode,user_id,cat)
    MySQL.asyncQuery("VICE/SetModEnabled",{user_id = user_id, spawncode = spawncode, savekey = savekey, mod = mod, enabled = 1})
    enabledTable[tostring(mod)] = true
    local source = VICE.getUserSource(user_id)
    if source then
        TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,enabledTable)
    end
end

local function UpdateVehicleMod(spawncode,user_id,cat,mod)
    local savekey = cat.saveKey
    local enabledTable = DisableOtherMods(spawncode,user_id,cat)
    enabledTable[tostring(mod)] = true
    local previousMod = MySQL.asyncQuery("VICE/GetUsersSpecificVehicleMod",{user_id = user_id, spawncode = spawncode, savekey = savekey, mod = mod})
    if previousMod and previousMod[1] then
        MySQL.asyncQuery("VICE/SetModEnabled",{user_id = user_id, spawncode = spawncode, savekey = savekey, mod = mod, enabled = 1})
    else
        MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = user_id, spawncode = spawncode, savekey = savekey, mod = mod})
    end
    local source = VICE.getUserSource(user_id)
    if source then
        TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,enabledTable)
    end
end

--Mods

function VICE.GetDefaultMods(array)
    if not array then
        array = cfg.category.categories
    end
    local returnArray = {}
    for k,v in pairs(array) do
        if v.categories then
            for i,d in pairs(VICE.GetDefaultMods(v.categories))do
                returnArray[i] = {}
            end
        end
        if v.saveKey then
            returnArray[v.saveKey] = {}
        end
    end
    returnArray.plate_colour = {}
    returnArray.vehicle_plate = "N/A"
    returnArray.nitro = 0
    returnArray.fuel = 100
    return returnArray
end

function VICE.GetMods(spawncode,user_id)
    local mods = VICE.GetDefaultMods()
    local data = MySQL.asyncQuery("VICE/GetUsersVehicleMods",{user_id = user_id, spawncode = spawncode})
    for k,v in pairs(data) do
        if not mods[v.savekey] then
            mods[v.savekey] = {}
        end
        mods[v.savekey][v.mod] = tobool(v.enabled)
    end
    local nitro = VICE.GetVehiclesNitro(user_id,spawncode)
    local fuel = VICE.GetVehiclesFuel(user_id,spawncode)
    local plate = VICE.GetVehiclesPlate(user_id,spawncode)
    mods.nitro = nitro
    mods.fuel = fuel
    mods.vehicle_plate = plate
    if mods.biometric_users then
        for k,v in pairs(mods.biometric_users) do
            mods.biometric_users[k] = VICE.getPlayerName(tonumber(k))
        end
    end
    TriggerEvent('VICE:callLockpickNotify', spawncode, nil, user_id)
    mods.stancer = VICE.GetVehiclesStancerMods(user_id,spawncode)
    return mods
end

function VICE.GetVehiclesStancerMods(user_id,spawncode)
    local data = MySQL.asyncQuery("VICE/GetVehicleStancerMods",{user_id = user_id, spawncode = spawncode})
    local returnArray = {}
    for k,v in pairs(data) do
        returnArray[v.mod] = {
            [v.value] = true
        }
    end
    return returnArray
end

local function ConvertModTable(mod)
    if type(mod) == "table" then
        return json.encode(mod)
    else
        return mod
    end
end

RegisterServerEvent("VICE:getBoughtUpgrades", function(spawncode)
    local source = source
    local user_id = VICE.getUserId(source)
    local array = VICE.GetMods(spawncode,user_id)
    TriggerClientEvent('VICE:gotBoughtUpgrades', source,array)
end)

--Repair

RegisterServerEvent("VICE:lscustomsRepairVehicle", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not VICE.tryFullPayment(user_id, 1000) then
        VICE.notify(source, "~r~You don't have enough money to repair your vehicle")
        return
    end
    TriggerClientEvent('VICE:lscustomsRepairVehicle', source)
end)

RegisterServerEvent("VICE:setActiveStaticList",function(spawncode,cat,item)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local saveValue = cat.saveValue
    local mod = ConvertModTable(cat.items[item][saveValue])
    SetModEnabled(spawncode,user_id,cat,mod)
end)

RegisterServerEvent("VICE:purchaseStaticList",function(spawncode,cat,item)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local price = cat.items[item].price
    if not price then
        price = cat.price
    end
    if not VICE.tryFullPayment(user_id, price) then
        VICE.notify(source, "~r~You don't have enough money to purchase this upgrade")
        return
    end
    local upgradeName = cat.items[item].name
    VICE.notify(source, "~g~Purchased "..upgradeName.." for £"..getMoneyStringFormatted(price))
    local saveValue = cat.saveValue
    local mod = ConvertModTable(cat.items[item][saveValue])
    UpdateVehicleMod(spawncode,user_id,cat,mod)
end)

RegisterServerEvent("VICE:setActiveModList",function(spawncode,cat,mod)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    SetModEnabled(spawncode,user_id,cat,mod)
end)

RegisterServerEvent("VICE:purchaseModList",function(spawncode,cat,mod)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local price = cat.price
    if not price then
        price = 1000
    end
    if not VICE.tryFullPayment(user_id, price) then
        VICE.notify(source, "~r~You don't have enough money to purchase this upgrade")
        return
    end
    local upgradeName = cat.name
    VICE.notify(source, "~g~Purchased "..upgradeName.." for £"..getMoneyStringFormatted(price))
    local saveValue = cat.saveValue
    UpdateVehicleMod(spawncode,user_id,cat,mod)
end)

RegisterServerEvent("VICE:purchaseStaticValueList",function(spawncode,cat,item)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local price = cat.items[item].price
    if not price then
        price = cat.price
    end
    if not VICE.tryFullPayment(user_id, price) then
        VICE.notify(source, "~r~You don't have enough money to purchase this upgrade")
        return
    end
    local upgradeName = cat.items[item].name
    VICE.notify(source, "~g~Purchased "..upgradeName.." for £"..getMoneyStringFormatted(price))
    local savekey = cat.saveKey
    local saveValue = cat.saveValue
    local mod = ConvertModTable(cat.items[item][saveValue])
    if cat.name=="Nitro" then
        exports['vice']:execute("UPDATE vice_user_vehicles SET nitro = @nitro WHERE user_id = @user_id AND vehicle = @spawncode", {spawncode = spawncode,nitro = mod, user_id = user_id}, function() 
        end)
    end
    TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,mod)
end)

RegisterServerEvent("VICE:purchaseValueInputList",function(spawncode,cat)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local price = cat.price
    if not price then
        price = cat.price
    end
    if not VICE.tryFullPayment(user_id, price) then
        VICE.notify(source, "~r~You don't have enough money to purchase this upgrade")
        return
    end
    local upgradeName = cat.name
    local saveValue = cat.indexPrefix
    local savekey = cat.saveKey
    VICE.notify(source, "~g~Purchased "..upgradeName.." for £"..getMoneyStringFormatted(price))
    local oldmods = MySQL.asyncQuery("VICE/GetUsersVehicleMod", {user_id = user_id, spawncode = spawncode, savekey = savekey})
    local mod = "Unused #"..tostring(table.count(oldmods) + 1)
    local enabledTable = {}
    for k,data in pairs(oldmods) do
        enabledTable[tostring(data.mod)] = VICE.getPlayerName(data.mod)
    end
    MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = user_id, spawncode = spawncode, savekey = savekey, savevalue = savevalue, mod = mod})
    enabledTable[mod] = "Unknown"
    TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,enabledTable)
end)

RegisterServerEvent("VICE:setValueInputList",function(spawncode,cat,oldmod,newvalue)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local saveValue = cat.indexPrefix
    local savekey = cat.saveKey
    local oldmods = MySQL.asyncQuery("VICE/GetUsersVehicleMod", {user_id = user_id, spawncode = spawncode, savekey = savekey})
    local enabledTable = {}
    for k,data in pairs(oldmods) do
        if data.mod == tostring(newvalue) then
            VICE.notify(source, "~r~You can't set the same value as a previous one")
            return
        end
        enabledTable[tostring(data.mod)] = VICE.getPlayerName(data.mod)
    end
    enabledTable[tostring(oldmod)] = nil
    enabledTable[tostring(newvalue)] = VICE.getPlayerName(newvalue)
    MySQL.execute("VICE/SetNewModValue", {user_id = user_id, spawncode = spawncode, savekey = savekey, mod = newvalue, oldmod = oldmod})
    TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,enabledTable)
end)

RegisterServerEvent("VICE:deleteValueInputList",function(spawncode,cat,oldmod)
    local source = source
    local user_id = VICE.getUserId(source)
    cat = cfg.identifierToCategory[cat]
    local refundPrice = math.floor(cat.price * 0.5)
    VICE.prompt(source, "Please replace text with YES or NO to confirm", "You are about to refund a biometric user on your vehicle.\n\nYou will receive £"..getMoneyStringFormatted(refundPrice).." if you decide to continue.\n\nThis will forfeit future use of this slot, please think carefully.",function(player,details)
        if string.upper(details) == 'YES' then
            local saveValue = cat.indexPrefix
            local savekey = cat.saveKey
            local oldmods = MySQL.asyncQuery("VICE/GetUsersVehicleMod", {user_id = user_id, spawncode = spawncode, savekey = savekey})
            local enabledTable = {}
            for k,data in pairs(oldmods) do
                enabledTable[tostring(data.mod)] = VICE.getPlayerName(data.mod)
            end
            enabledTable[tostring(oldmod)] = nil
            MySQL.execute("VICE/DeleteVehicleMod", {user_id = user_id, spawncode = spawncode, savekey = savekey, mod = oldmod})
            TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,savekey,enabledTable)
            VICE.giveBankMoney(user_id, refundPrice)
            VICE.notify(source, "You have been refunded ~g~£"..getMoneyStringFormatted(refundPrice).." ~w~for refunding a biometric user.")
        else
            VICE.notify(source, "~r~Biometric refund cancelled.")
        end
    end)
end)

RegisterServerEvent("VICE:stancerBuyMod", function(spawncode,mod)
    local source = source
    local user_id = VICE.getUserId(source)
    local price = cfg.stancerPrices[mod]
    if not price then
        price = 1000
    end
    if not VICE.tryFullPayment(user_id, price) then
        VICE.notify(source, "~r~You don't have enough money to purchase this upgrade")
        return
    end
    local upgradeName = mod
    VICE.notify(source, "~g~Purchased "..upgradeName.." for £"..getMoneyStringFormatted(price))
    MySQL.asyncQuery("VICE/InsertNewVehicleStancerMod",{user_id = user_id, spawncode = spawncode, mod = mod})
    local enabledTable = VICE.GetVehiclesStancerMods(user_id,spawncode)
    TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,"stancer",enabledTable)
end)

RegisterServerEvent("VICE:stancerSetModIndex", function(spawncode,cat,value)
    local source = source
    local user_id = VICE.getUserId(source)
    local oldmods = VICE.GetVehiclesStancerMods(user_id,spawncode)
    MySQL.asyncQuery("VICE/UpdateVehicleStancerMod",{user_id = user_id, spawncode = spawncode, mod = cat, value = value})
    local enabledTable = VICE.GetVehiclesStancerMods(user_id,spawncode)
    TriggerClientEvent('VICE:setSpecificOwnedUpgrade', source,"stancer",enabledTable)
end)

RegisterServerEvent("VICE:setBiometricUsersState")
AddEventHandler("VICE:setBiometricUsersState", function(vehNetId,table)
	local source = source
	local user_id = VICE.getUserId(source)
    local playersCurrentVehicle = NetworkGetEntityFromNetworkId(vehNetId)
    Entity(playersCurrentVehicle).state:set("biometricUsers",table,true)
end)

RegisterServerEvent("VICE:stancerSetState")
AddEventHandler("VICE:stancerSetState", function(vehNetId,stancerTable)
    local source = source
    local user_id = VICE.getUserId(source)
    local playersCurrentVehicle = NetworkGetEntityFromNetworkId(vehNetId)
    Entity(playersCurrentVehicle).state:set("stancer",stancerTable,true)
end)

RegisterServerEvent("VICE:updateNitro", function(spawncode,amount)
    local source = source
    local user_id = VICE.getUserId(source)
    exports['vice']:execute("SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @spawncode", {user_id = user_id, spawncode = spawncode}, function(result)
        if result ~= nil then 
            if amount < 0 then
                amount = 0
            end
            local nitro = amount
            exports['vice']:execute("UPDATE vice_user_vehicles SET nitro = @nitro WHERE user_id = @user_id AND vehicle = @spawncode", {spawncode = spawncode,nitro = nitro, user_id = user_id}, function() 
            end)
        end
    end)
end)

RegisterCommand('convertlsc', function(source, args)
    if source == 0 then
        exports['vice']:execute("SELECT * FROM vice_user_vehicles", {}, function(result)
            if #result > 0 then
                print("^5Converting LSC Vehicles")
                local startTime = os.time()
                print("^1Current Time - "..os.date("%H:%M:%S"))
                local coloursTable = {
                    ["chrome"] = {
                        {name = "Chrome", index = 120}
                    },
                    ["classic"] = {
                        {name = "Black", index = 0},
                        {name = "Carbon Black", index = 147},
                        {name = "Graphite", index = 1},
                        {name = "Anthracite Black", index = 11},
                        {name = "Black Steel", index = 2},
                        {name = "Dark Steel", index = 3},
                        {name = "Silver", index = 4},
                        {name = "Bluish Silver", index = 5},
                        {name = "Rolled Steel", index = 6},
                        {name = "Shadow Silver", index = 7},
                        {name = "Stone Silver", index = 8},
                        {name = "Midnight Silver", index = 9},
                        {name = "Cast Iron Silver", index = 10},
                        {name = "Red", index = 27},
                        {name = "Torino Red", index = 28},
                        {name = "Formula Red", index = 29},
                        {name = "Lava Red", index = 150},
                        {name = "Blaze Red", index = 30},
                        {name = "Grace Red", index = 31},
                        {name = "Garnet Red", index = 32},
                        {name = "Sunset Red", index = 33},
                        {name = "Cabernet Red", index = 34},
                        {name = "Wine Red", index = 143},
                        {name = "Candy Red", index = 35},
                        {name = "Hot Pink", index = 135},
                        {name = "Pfsiter Pink", index = 137},
                        {name = "Salmon Pink", index = 136},
                        {name = "Sunrise Orange", index = 36},
                        {name = "Orange", index = 38},
                        {name = "Bright Orange", index = 138},
                        {name = "Gold", index = 99},
                        {name = "Bronze", index = 90},
                        {name = "Yellow", index = 88},
                        {name = "Race Yellow", index = 89},
                        {name = "Dew Yellow", index = 91},
                        {name = "Dark Green", index = 49},
                        {name = "Racing Green", index = 50},
                        {name = "Sea Green", index = 51},
                        {name = "Olive Green", index = 52},
                        {name = "Bright Green", index = 53},
                        {name = "Gasoline Green", index = 54},
                        {name = "Lime Green", index = 92},
                        {name = "Midnight Blue", index = 141},
                        {name = "Galaxy Blue", index = 61},
                        {name = "Dark Blue", index = 62},
                        {name = "Saxon Blue", index = 63},
                        {name = "Blue", index = 64},
                        {name = "Mariner Blue", index = 65},
                        {name = "Harbor Blue", index = 66},
                        {name = "Diamond Blue", index = 67},
                        {name = "Surf Blue", index = 68},
                        {name = "Nautical Blue", index = 69},
                        {name = "Racing Blue", index = 73},
                        {name = "Ultra Blue", index = 70},
                        {name = "Light Blue", index = 74},
                        {name = "Chocolate Brown", index = 96},
                        {name = "Bison Brown", index = 101},
                        {name = "Creeen Brown", index = 95},
                        {name = "Feltzer Brown", index = 94},
                        {name = "Maple Brown", index = 97},
                        {name = "Beechwood Brown", index = 103},
                        {name = "Sienna Brown", index = 104},
                        {name = "Saddle Brown", index = 98},
                        {name = "Moss Brown", index = 100},
                        {name = "Woodbeech Brown", index = 102},
                        {name = "Straw Brown", index = 99},
                        {name = "Sandy Brown", index = 105},
                        {name = "Bleached Brown", index = 106},
                        {name = "Schafter Purple", index = 71},
                        {name = "Spinnaker Purple", index = 72},
                        {name = "Midnight Purple", index = 142},
                        {name = "Bright Purple", index = 145},
                        {name = "Cream", index = 107},
                        {name = "Ice White", index = 111},
                        {name = "Frost White", index = 112}
                    },
                    ["matte"] = {
                        {name = "Black", index = 12},
                        {name = "Gray", index = 13},
                        {name = "Light Gray", index = 14},
                        {name = "Ice White", index = 131},
                        {name = "Blue", index = 83},
                        {name = "Dark Blue", index = 82},
                        {name = "Midnight Blue", index = 84},
                        {name = "Midnight Purple", index = 149},
                        {name = "Schafter Purple", index = 148},
                        {name = "Red", index = 39},
                        {name = "Dark Red", index = 40},
                        {name = "Orange", index = 41},
                        {name = "Yellow", index = 42},
                        {name = "Lime Green", index = 55},
                        {name = "Green", index = 128},
                        {name = "Frost Green", index = 151},
                        {name = "Foliage Green", index = 155},
                        {name = "Olive Darb", index = 152},
                        {name = "Dark Earth", index = 153},
                        {name = "Desert Tan", index = 154}
                    },
                    ["metals"] = {
                        {name = "Black", index = 12},
                        {name = "Gray", index = 13},
                        {name = "Light Gray", index = 14},
                        {name = "Ice White", index = 131},
                        {name = "Blue", index = 83},
                        {name = "Dark Blue", index = 82},
                        {name = "Midnight Blue", index = 84},
                        {name = "Midnight Purple", index = 149},
                        {name = "Schafter Purple", index = 148},
                        {name = "Red", index = 39},
                        {name = "Dark Red", index = 40},
                        {name = "Orange", index = 41},
                        {name = "Yellow", index = 42},
                        {name = "Lime Green", index = 55},
                        {name = "Green", index = 128},
                        {name = "Frost Green", index = 151},
                        {name = "Foliage Green", index = 155},
                        {name = "Olive Darb", index = 152},
                        {name = "Dark Earth", index = 153},
                        {name = "Desert Tan", index = 154}
                    },
                    ["util"] = {
                        {name = "Black", index = 15},
                        {name = "Black Poly", index = 16},
                        {name = "Dark Steel", index = 17},
                        {name = "Silver", index = 18},
                        {name = "Black Steel", index = 19},
                        {name = "Shadow Silver", index = 20},
                        {name = "Dark Red", index = 43},
                        {name = "Red", index = 44},
                        {name = "Garnet Red", index = 45},
                        {name = "Dark Green", index = 56},
                        {name = "Green", index = 57},
                        {name = "Dark Blue", index = 75},
                        {name = "Midnight Blue", index = 76},
                        {name = "Saxon Blue", index = 77},
                        {name = "Nautical Blue", index = 78},
                        {name = "Blue", index = 79},
                        {name = "Blue Poly", index = 80},
                        {name = "Bright Purple", index = 81},
                        {name = "Straw Brown", index = 93},
                        {name = "Feltzer Brown", index = 108},
                        {name = "Moss Brown", index = 109},
                        {name = "Sandy Brown", index = 110},
                        {name = "Off White", index = 122},
                        {name = "Bright Green", index = 125},
                        {name = "Harbor Blue", index = 127},
                        {name = "Frost White", index = 134},
                        {name = "Lime Green", index = 139},
                        {name = "Ultra Blue", index = 140},
                        {name = "Gray", index = 144},
                        {name = "Light Blue", index = 157},
                        {name = "Yellow", index = 160},
                    },
                    ["chameleon"] = {
                        {name = "Monochrome", index = 161},
                        {name = "Night & Day", index = 162},
                        {name = "The Verlierer", index = 163},
                        {name = "Sprunk Extreme", index = 164},
                        {name = "Vice City", index = 165},
                        {name = "Synthwave Nights", index = 166},
                        {name = "Four Seasons", index = 167},
                        {name = "Maisonette 9 Throwback", index = 168},
                        {name = "Bubblegum", index = 169},
                        {name = "Full Rainbow", index = 170},
                        {name = "Sunset", index = 171},
                        {name = "The Seven", index = 172},
                        {name = "Kamen Rider", index = 173},
                        {name = "Chromatic Aberration", index = 174},
                        {name = "It's Christmas!", index = 175},
                        {name = "Temperature", index = 176},
                    },
                }
                for a,b in pairs(result) do
                    local modsTable = json.decode(b.modifications)
                    if modsTable ~= nil then
                        local modsColour = modsTable.color
                        local modsExtraColour = modsTable.extraColor
                        local modsWindowTint = modsTable.windowTint
                        local modsPlateIndex = modsTable.plateIndex
                        -- Converts all LS Customs mods to new format
                        for k,v in pairs(modsTable.mods) do
                            if v.mod ~= -1 then
                                MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "mod_"..k, mod = v.mod})
                            end
                        end
                        print("^5Converted mods of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        -- Converts the security mods to new format
                        if modsTable.biometric == 1 then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "security", mod = "21"})
                            print("^5Converted biometric of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        if modsTable.remoteblips == 1 then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "security_blips", mod = "11"})
                            print("^5Converted remote blips of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        if modsTable.dashcam == 1 then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "security_dashcam", mod = "1"})
                            print("^5Converted dashcam of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        -- Converts bulletproof tyres to new format
                        if modsTable.bulletProofTyres == 1 then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "bulletproof_tires", mod = "1"})
                            print("^5Converted bulletproof tyres of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        -- Converts primary colours to new format
                        if modsColour ~= nil then
                            for k,v in pairs(coloursTable) do
                                for k2, v2 in pairs(v) do
                                    if v2.index == modsColour[1] then
                                        MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = k, mod = modsColour[1]})
                                    end
                                    if v2.index == modsColour[2] then
                                        MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = k.."2", mod = modsColour[2]})
                                    end
                                end
                            end
                            print("^5Converted primary and secondary colours of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        -- Converts secondary colours to new format
                        if modsExtraColour ~= nil then
                            for k,v in pairs(coloursTable.classic) do
                                if v.index == modsExtraColour[2] then
                                    MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "wheelcolor", mod = modsExtraColour[2]})
                                end
                            end
                            print("^5Converted wheel colour of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        -- Converts window tint to new format
                        if modsWindowTint ~= nil then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "windowtint", mod = modsWindowTint})
                            print("^5Converted window tint of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        -- Converts plate index to new format
                        if modsPlateIndex ~= nil then
                            MySQL.asyncQuery("VICE/InsertNewVehicleMod",{user_id = b.user_id, spawncode = b.vehicle, savekey = "plate_colour", mod = modsPlateIndex})
                            print("^5Converted plate index of vehicle: "..b.vehicle.." for ID: "..b.user_id.."^0")
                        end
                        print("^5Current Conversion Status: Position: "..a.." (^2"..math.floor(a/#result*100).." %^5)^0")
                    end
                end
                print("^3-------------------------------------^0")
                print("^3Finished Converting LSC Vehicles^0")
                print("^1Finished Time - "..os.date("%H:%M:%S").."^0")
                print("^1Conversion took - "..os.time()-startTime.." seconds^0")
                print("^3-------------------------------------^0")
            end
        end)
    end
end)
