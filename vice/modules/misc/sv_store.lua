local cfg = module("cfg/cfg_store")
local Ranks = { 'Baller', 'Rainmaker', 'Kingpin', 'Supreme', 'Premium', 'Supporter' }
RegisterServerEvent('VICE:OpenStore')
AddEventHandler('VICE:OpenStore', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        ForceRefresh(source)
        TriggerClientEvent("VICE:OpenStoreMenu", source, true)
    end
end)

function RequestRank(user_id)
    for k, v in pairs(Ranks) do
        if VICE.hasGroup(user_id, v) then
            return v
        end
    end
    return 'None'
end

local UUIDs = {}

local uuidTypes = {
    ["alphabet"] = "abcdefghijklmnopqrstuvwxyz",
    ["numerical"] = "0123456789",
    ["alphanumeric"] = "abcdefghijklmnopqrstuvwxyz0123456789",
}

local function randIntKey(length, type)
    local index, pw, rnd = 0, "", 0
    local chars = {
        uuidTypes[type]
    }
    repeat
        index = index + 1
        rnd = math.random(chars[index]:len())
        if math.random(2) == 1 then
            pw = pw .. chars[index]:sub(rnd, rnd)
        else
            pw = chars[index]:sub(rnd, rnd) .. pw
        end
        index = index % #chars
    until pw:len() >= length
    return pw
end

function generateUUID(key, length, type)
    if UUIDs[key] == nil then
        UUIDs[key] = {}
    end

    if type == nil then type = "alphanumeric" end

    local uuid = randIntKey(length, type)
    if UUIDs[key][uuid] then
        while UUIDs[key][uuid] do
            uuid = randIntKey(length, type)
            Wait(0)
        end
    end
    UUIDs[key][uuid] = true
    return uuid
end

function ForceRefresh(source)
    local source = source
    local user_id = VICE.getUserId(source)
    exports['vice']:execute('SELECT * FROM vice_stores WHERE user_id = @user_id', { user_id = user_id },
        function(result)
            storeItemsOwned = {}
            if #result > 0 then
                for a, b in pairs(result) do
                    storeItemsOwned[b.code] = b.item
                end
                TriggerClientEvent('VICE:sendStoreItems', VICE.getUserSource(user_id), storeItemsOwned)
            end
        end)
end

function AddVehicle(user_id, vehicle)
    VICEclient.generateUUID(VICE.getUserSource(user_id), { "plate", 5, "alphanumeric" }, function(uuid)
        local uuid = string.upper(uuid)
        MySQL.execute("VICE/add_vehicle", { user_id = user_id, vehicle = vehicle, registration = 'P' .. uuid })
    end)
end

function CreateItem(user_id, itemname, source)
    local first, second = generateUUID("Items", 4, "alphanumeric"), generateUUID("Items", 4, "alphanumeric")
    local code = string.upper(first .. "-" .. second)
    local currentDate = os.date("%d/%m/%Y")

    exports['vice']:execute(
    "INSERT INTO vice_stores (code, item, user_id, date) VALUES (@code, @item, @user_id, @date)",
        { code = code, item = itemname, user_id = user_id, date = currentDate })

    Wait(100)

    if user_id then
        ForceRefresh(user_id)
    else
        ForceRefresh(VICE.getUserSource(source))
    end
end

local function processWeaponCodes(user_id, table, callback)
    local finished = false
    MySQL.query("VICE/get_weapon_codes", {}, function(weaponCodes)
        if #weaponCodes > 0 then
            for e, f in pairs(weaponCodes) do
                if f['user_id'] == user_id and f['weapon_code'] == tonumber(table.accessCode) then
                    MySQL.query("VICE/get_weapons", { user_id = user_id }, function(weaponWhitelists)
                        local ownedWhitelists = {}
                        if next(weaponWhitelists) then
                            ownedWhitelists = json.decode(weaponWhitelists[1]['weapon_info'])
                        end
                        for a, b in pairs(whitelistedGuns) do
                            for c, d in pairs(b) do
                                if c == f['spawncode'] then
                                    if not ownedWhitelists[a] then
                                        ownedWhitelists[a] = {}
                                    end
                                    ownedWhitelists[a][c] = d
                                end
                            end
                        end
                        MySQL.execute("VICE/set_weapons",
                            { user_id = user_id, weapon_info = json.encode(ownedWhitelists) })
                        MySQL.execute("VICE/remove_weapon_code", { weapon_code = table.accessCode })
                        finished = true
                        callback(finished)
                    end)
                end
            end
        end
        if not finished then
            callback(finished)
        end
    end)
end


AddEventHandler('VICE:onServerSpawn', function(user_id, source, first_spawn)
    ForceRefresh(source)
    TriggerClientEvent('VICE:setStoreRankName', source, RequestRank(user_id))
end)



RegisterServerEvent('VICE:setInVehicleTestingBucket', function(status)
    local source = source
    if status then
        SetPlayerRoutingBucket(source, 20)
    else
        SetPlayerRoutingBucket(source, 0)
    end
end)

RegisterServerEvent("VICE:getStoreLockedVehicleCategories", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local permissiontable = {}
    for a, b in pairs(cfg.vehicleCategoryToPermissionLookup) do
        if VICE.hasPermission(user_id, b) then
            table.insert(permissiontable, a)
        end
    end
    TriggerClientEvent("VICE:setStoreLockedVehicleCategories", source, permissiontable)
end)
RegisterServerEvent("VICE:redeemStoreItem", function(code, table)
    local source = source
    local user_id = VICE.getUserId(source)
    local storeLengthName = false
    exports['vice']:execute('SELECT * FROM vice_stores WHERE code = @code', { code = code }, function(result)
        if #result > 0 then
            if result[1].user_id == user_id then
                if result[1].item == "2_money_bag" then
                    VICE.giveBankMoney(user_id, 2000000)
                elseif result[1].item == "5_money_bag" then
                    VICE.giveBankMoney(user_id, 5000000)
                elseif result[1].item == "10_money_bag" then
                    VICE.giveBankMoney(user_id, 10000000)
                elseif result[1].item == "20_money_bag" then
                    VICE.giveBankMoney(user_id, 20000000)
                elseif result[1].item == "30_money_bag" then
                    VICE.giveBankMoney(user_id, 30000000)
                elseif result[1].item == "100_money_bag" then
                    VICE.giveBankMoney(user_id, 100000000)
                elseif result[1].item == "250_money_bag" then
                    VICE.giveBankMoney(user_id, 250000000)
                elseif result[1].item == "500_money_bag" then
                    VICE.giveBankMoney(user_id, 500000000)
                elseif result[1].item == "vice_plus" then
                    VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
                        if cb then
                            MySQL.execute("subscription/set_plushours", { user_id = user_id, plushours = plushours + 720 })
                        end
                    end)
                elseif result[1].item == "vice_platinum" then
                    VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
                        if cb then
                            MySQL.execute("subscription/set_plathours", { user_id = user_id, plathours = plathours + 720 })
                        end
                    end)
                elseif result[1].item == "import_slot" then
                    AddVehicle(user_id, table.customCar)
                elseif result[1].item == "supporter" then
                    AddVehicle(user_id, table.vipCar1)
                    VICE.giveBankMoney(user_id, 500000)
                    VICE.addUserGroup(user_id, "Supporter")
                elseif result[1].item == "premium" then
                    AddVehicle(user_id, table.vipCar1)
                    VICE.giveBankMoney(user_id, 1500000)
                    VICE.addUserGroup(user_id, "Premium")
                elseif result[1].item == "supreme" then
                    AddVehicle(user_id, table.vipCar1)
                    AddVehicle(user_id, table.vipCar2)
                    VICE.giveBankMoney(user_id, 2500000)
                    VICE.addUserGroup(user_id, "Supreme")
                elseif result[1].item == "kingpin" then
                    AddVehicle(user_id, table.vipCar1)
                    AddVehicle(user_id, table.vipCar2)
                    VICE.giveBankMoney(user_id, 5000000)
                    VICE.addUserGroup(user_id, "Kingpin")
                    if table.customCar1 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar1)
                    end
                elseif result[1].item == "rainmaker" then
                    AddVehicle(user_id, table.vipCar1)
                    AddVehicle(user_id, table.vipCar2)
                    AddVehicle(user_id, table.vipCar3)
                    VICE.giveBankMoney(user_id, 10000000)
                    VICE.addUserGroup(user_id, "Rainmaker")
                    if table.customCar1 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar1)
                    end
                    if table.customCar2 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar2)
                    end
                    if table.customCar3 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar3)
                    end
                elseif result[1].item == "baller" then
                    VICE.giveBankMoney(user_id, 25000000)
                    VICE.addUserGroup(user_id, "Baller")
                    CreateItem(user_id, "lock_slot")
                    AddVehicle(user_id, table.vipCar1)
                    AddVehicle(user_id, table.vipCar2)
                    AddVehicle(user_id, table.vipCar3)
                    AddVehicle(user_id, table.vipCar4)
                    if table.customCar1 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar1)
                    end
                    if table.customCar2 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar2)
                    end
                    if table.customCar3 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar3)
                    end
                    if table.customCar4 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar4)
                    end
                    if table.customCar5 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar5)
                    end
                    if table.customCar6 == nil then
                        CreateItem(user_id, "import_slot")
                    else
                        AddVehicle(user_id, table.customCar6)
                    end
                    local function processWeaponCodes(user_id, table, callback)
                        local finished = false
                        MySQL.query("VICE/get_weapon_codes", {}, function(weaponCodes)
                            if #weaponCodes > 0 then
                                for e, f in pairs(weaponCodes) do
                                    if f['user_id'] == user_id and f['weapon_code'] == tonumber(table.accessCode) then
                                        MySQL.query("VICE/get_weapons", { user_id = user_id },
                                            function(weaponWhitelists)
                                                local ownedWhitelists = {}
                                                if next(weaponWhitelists) then
                                                    ownedWhitelists = json.decode(weaponWhitelists[1]['weapon_info'])
                                                end
                                                for a, b in pairs(whitelistedGuns) do
                                                    for c, d in pairs(b) do
                                                        if c == f['spawncode'] then
                                                            if not ownedWhitelists[a] then
                                                                ownedWhitelists[a] = {}
                                                            end
                                                            ownedWhitelists[a][c] = d
                                                        end
                                                    end
                                                end
                                                MySQL.execute("VICE/set_weapons",
                                                    { user_id = user_id, weapon_info = json.encode(ownedWhitelists) })
                                                MySQL.execute("VICE/remove_weapon_code",
                                                    { weapon_code = table.accessCode })
                                                finished = true
                                                callback(finished)
                                            end)
                                    end
                                end
                            end
                            if not finished then
                                callback(finished)
                            end
                        end)
                    end
                elseif string.find(result[1].item, "_whitelist") then
                    local validcode = exports["vice"]:executeSync(
                    "SELECT * FROM vice_weapon_codes WHERE weapon_code = @weapon_code AND user_id = @user_id",
                        { weapon_code = table.accessCode, user_id = user_id })
                    if validcode and #validcode > 0 then
                        MySQL.query("VICE/get_weapons", { user_id = user_id }, function(weaponWhitelists)
                            local ownedWhitelists = {}
                            if next(weaponWhitelists) then
                                ownedWhitelists = json.decode(weaponWhitelists[1]['weapon_info'])
                            end

                            -- Get weapon info from whitelistedGuns
                            local weaponInfo = nil
                            for a, b in pairs(whitelistedGuns) do
                                for c, d in pairs(b) do
                                    if c == validcode[1].spawncode then
                                        weaponInfo = d
                                        break
                                    end
                                end
                                if weaponInfo then break end
                            end

                            if weaponInfo then
                                -- Store weapon as top-level key with properties
                                ownedWhitelists[validcode[1].spawncode] = {
                                    name = weaponInfo[1],
                                    gunhash = validcode[1].spawncode,
                                    price = weaponInfo[2],
                                    category = a, -- category from whitelistedGuns
                                    owner = false
                                }

                                MySQL.execute("VICE/set_weapons",
                                    { user_id = user_id, weapon_info = json.encode(ownedWhitelists) })
                                MySQL.execute("VICE/remove_weapon_code", { weapon_code = table.accessCode })
                                Wait(1000)
                                VICE.RefreshGunstoreData(user_id)
                                TriggerClientEvent("VICE:refreshGunStorePermissions", source)
                                VICE.notify(source, "~g~Successfully redeemed weapon whitelist!")
                            else
                                VICE.notify(source, "~r~Invalid weapon code.")
                                return
                            end
                        end)
                    else
                        VICE.notify(source, "~r~Invalid Code.")
                        return
                    end
                end
                -- Delete the item from the store
                exports['vice']:execute("DELETE FROM vice_stores WHERE code = @code AND user_id = @user_id",
                    { code = code, user_id = user_id }, function()
                    if result[1].item == "vice_plus" or result[1].item == "vice_platinum" then
                        VICE.notify(source,
                            "~g~Redeemed " ..
                            cfg.items[result[1].item].length .. " of " .. cfg.items[result[1].item].name .. "!")
                        storeLengthName = true
                    else
                        VICE.notify(source, "~g~Redeemed " .. cfg.items[result[1].item].name .. "!")
                        storeLengthName = false
                    end
                    VICE.sendDCLog('store-redeem', "VICE Store Logs",
                        "> Player PermID: **" .. user_id .. "**\n> Item: **" .. cfg.items[result[1].item].name .. "**")
                    TriggerEvent("VICE:refreshGaragePermissions", source)
                    TriggerClientEvent("VICE:storeDrawEffects", source)
                    TriggerClientEvent('VICE:smallAnnouncement', source, cfg.items[result[1].item].name,
                        storeLengthName and
                        "You have redeemed " ..
                        cfg.items[result[1].item].length .. " of " .. cfg.items[result[1].item].name .. "!" or
                        "You have redeemed " .. cfg.items[result[1].item].name .. "!", 33, 10000)
                    Wait(250)
                    TriggerClientEvent("VICE:storeCloseMenu", source)
                    ForceRefresh(source)
                end)
            end
        end
    end)
end)

RegisterServerEvent("VICE:startSellStoreItem", function(code)
    local source = source
    local user_id = VICE.getUserId(source)

    exports['vice']:execute('SELECT * FROM vice_stores WHERE code = @code', { code = code }, function(result)
        if #result > 0 then
            local itemname = cfg.items[result[1].item].name

            VICEclient.getNearestPlayers(source, { 5 }, function(players)
                local usrList = ""
                for a, b in pairs(players) do
                    usrList = usrList .. "[" .. a .. "]" .. VICE.getPlayerName(VICE.getUserId(a)) .. " | "
                end

                VICE.prompt(source, "Sell to: " .. usrList, "",
                    function(source, player_id)                                              -- Change playersource to player_id
                        if player_id and player_id ~= "" then
                            player_id = tonumber(player_id)

                            if players[player_id] then
                                VICE.prompt(source, "Amount:", "", function(source, amount)
                                    if tonumber(amount) and tonumber(amount) >= 0 then
                                        local buyer_id = VICE.getUserId(player_id) -- Get the buyer's user_id

                                        VICE.notify(source,
                                            "~g~Offer sent for " ..
                                            VICE.getPlayerName(VICE.getUserId(player_id)) ..
                                            " to buy " ..
                                            itemname .. " for £" .. getMoneyStringFormatted(tonumber(amount)) .. "!")

                                        VICE.request(player_id,
                                            VICE.getPlayerName(VICE.getUserId(source)) ..
                                            " is selling you a " ..
                                            itemname .. " for £" .. getMoneyStringFormatted(tonumber(amount)), 30,
                                            function(player_id, ok)
                                                if ok then
                                                    if VICE.tryFullPayment(buyer_id, tonumber(amount)) then
                                                        exports['vice']:execute(
                                                        "UPDATE vice_stores SET user_id = @user_id WHERE code = @code",
                                                            { user_id = buyer_id, code = code })
                                                        exports['vice']:execute(
                                                        "UPDATE vice_stores SET date = @date WHERE code = @code",
                                                            { date = os.date("%d/%m/%Y"), code = code })
                                                        exports['vice']:execute(
                                                        "UPDATE vice_stores SET seller_id = @seller_id WHERE code = @code",
                                                            { seller_id = user_id, code = code })
                                                        Wait(250)
                                                        TriggerClientEvent("VICE:storeCloseMenu", source)
                                                        ForceRefresh(source)
                                                        TriggerClientEvent("VICE:storeCloseMenu", player_id)
                                                        ForceRefresh(player_id)
                                                        VICE.giveBankMoney(user_id, tonumber(amount))
                                                        VICE.notify(source,
                                                            "~g~Successfully sold " ..
                                                            itemname ..
                                                            " for £" .. getMoneyStringFormatted(tonumber(amount)) .. "!")
                                                        VICE.notify(player_id,
                                                            "~g~Successfully bought " ..
                                                            itemname ..
                                                            " for £" .. getMoneyStringFormatted(tonumber(amount)) .. "!")
                                                        VICE.sendDCLog('store-sell', "VICE Store Logs",
                                                            "> Seller PermID: **" ..
                                                            user_id ..
                                                            "**\n> Buyer PermID: **" ..
                                                            buyer_id ..
                                                            "**\n> Item: **" ..
                                                            itemname ..
                                                            "**\n> Amount: **£" ..
                                                            getMoneyStringFormatted(tonumber(amount)) .. "**")
                                                    else
                                                        VICE.notify(source,
                                                            "~r~" ..
                                                            VICE.getPlayerName(VICE.getUserId(player_id)) ..
                                                            " does not have enough money!")
                                                        VICE.notify(player_id, "~r~You do not have enough money!")
                                                    end
                                                else
                                                    VICE.notify(source,
                                                        "~r~" ..
                                                        VICE.getPlayerName(VICE.getUserId(player_id)) ..
                                                        " declined your offer!")
                                                    VICE.notify(player_id, "~r~You declined the offer!")
                                                end
                                            end)
                                    else
                                        VICE.notify(source, "~r~Invalid amount!")
                                    end
                                end)
                            else
                                VICE.notify(source, "~r~Invalid player!")
                            end
                        else
                            VICE.notify(source, "~r~Invalid player!")
                        end
                    end)
            end)
        else
            VICE.notify(source, "~r~Invalid code!")
        end
    end)
end)

RegisterCommand('cheatunban', function(source, args)
    if source ~= 0 then return end; -- Stops anyone other than the console running it.
    if tonumber(args[1]) then
        local userid = tonumber(args[1])
        VICE.setBanned(userid, false)
        VICE.sendDCLog('store-unban', "VICE Store Unban Logs", "> Player PermID: **" .. userid .. "**")
        print('Unbanned user: ' .. userid)
    else
        print('Incorrect usage: unban [permid]')
    end
end)

RegisterCommand('storeunban', function(source, args)
    if source ~= 0 then return end -- Stops anyone other than the console running it.

    if tonumber(args[1]) then
        local userid = tonumber(args[1])

        exports['vice']:execute('SELECT banreason FROM vice_users WHERE id = ?', { userid }, function(result)
            if result[1] and result[1].banreason and string.find(result[1].banreason, "cheating") then
                print('User with PermID ' .. userid .. ' has a cheating ban reason. Not unbanning.')
            else
                exports['vice']:execute('UPDATE vice_users SET banned = 0 WHERE id = ?', { userid })
                VICE.sendDCLog('store-unban', "VICE Cheating Unban Logs", "> Player PermID: **" .. userid .. "**")
                print('Unbanned user: ' .. userid)
            end
        end)
    else
        print('Incorrect usage: unban [permid]')
    end
end)

RegisterCommand("additem", function(source, args, raw)
    if source == 0 then
        local user_id, item = args[1], args[2]
        if user_id and item then
            local source = source
            VICE.AddItem(user_id,item)
        else
            print("Usage: additem [user_id] [item]")
        end
    end
end)
function VICE.AddItem(user_id, item)
    local code1, code2 = generateUUID("Items", 4, "alphanumeric"), generateUUID("Items", 4, "alphanumeric")
    local code = string.upper(code1 .. "-" .. code2)
    local vice = exports['vice']
    local currentDate = os.date("%d/%m/%Y")
    local insertQuery = "INSERT INTO vice_stores (code, item, user_id, date) VALUES (@code, @item, @user_id, @date)"
    local queryParams = { code = code, item = item, user_id = user_id, date = currentDate }
    print("Added item: " .. item .. " to user: " .. user_id)
    VICE.sendDCLog('donation', "VICE Donation Logs",
        "> Player PermID: **" .. user_id .. "**\n> Code: **" .. code .. "**\n> Item: **" .. item .. "**")
    vice:execute(insertQuery, queryParams)
end

RegisterCommand("removeitem", function(source, args, raw)
    if source == 0 then
        local user_id, item = args[1], args[2]
        if user_id and item then
            local vice = exports['vice']
            local selectQuery = "SELECT * FROM vice_stores WHERE user_id = @user_id AND item = @item"
            local queryParams = { user_id = user_id, item = item }

            vice:execute(selectQuery, queryParams, function(results)
                if results[1] then
                    local deleteQuery = "DELETE FROM vice_stores WHERE user_id = @user_id AND item = @item"
                    vice:execute(deleteQuery, queryParams)
                    print("Removed item: " .. item .. " from user: " .. user_id)
                    --      VICE.notify(user_id, "~r~The item" .. item .. "has been removed from your /store")
                    VICE.sendDCLog('donation', "VICE Donation Logs",
                        "> Player PermID: **" .. user_id .. "**\n> Removed Item: **" .. item .. "**")
                else
                    print("User: " .. user_id .. " doesn't have the item: " .. item)
                end
            end)
        else
            print("Usage: removeitem [user_id] [item]")
        end
    end
end)
