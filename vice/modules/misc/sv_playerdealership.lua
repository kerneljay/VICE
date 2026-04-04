local cfg = module("cfg/cfg_playerdealership")

-- Get player's vehicles
RegisterServerEvent("VICE:getPlayerVehicles")
AddEventHandler("VICE:getPlayerVehicles", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        exports.ghmattimysql:execute("SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND rented = 0 AND impounded = 0", {
            ['@user_id'] = user_id
        }, function(vehicles)
            TriggerClientEvent("VICE:receivePlayerVehicles", source, vehicles)
        end)
    end
end)

-- List vehicle for sale
RegisterServerEvent("VICE:listVehicleForSale")
AddEventHandler("VICE:listVehicleForSale", function(vehicle, price)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        -- Check if player can afford listing fee (from bank)
        if VICE.tryBankPayment(user_id, cfg.ListingFee) then
            -- Check if player owns the vehicle
            exports.ghmattimysql:execute("SELECT * FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle AND rented = 0 AND impounded = 0", {
                ['@user_id'] = user_id,
                ['@vehicle'] = vehicle
            }, function(result)
                if result and #result > 0 then
                    -- Check for duplicate listing
                    exports.ghmattimysql:execute("SELECT * FROM vice_playerdealership WHERE owner_user_id = @user_id AND vehicle_id = @vehicle AND status = 'for sale'", {
                        ['@user_id'] = user_id,
                        ['@vehicle'] = vehicle
                    }, function(dupe)
                        if dupe and #dupe > 0 then
                            VICE.giveBankMoney(user_id, cfg.ListingFee) -- Refund listing fee
                            TriggerClientEvent("VICE:vehicleListed", source, false, "This vehicle is already listed for sale!")
                        else
                            -- Add to dealership listings (store vehicle_id as spawn code)
                            exports.ghmattimysql:execute("INSERT INTO vice_playerdealership (vehicle_id, owner_user_id, price, list_time, status, dealership_location) VALUES (@vehicle_id, @owner_user_id, @price, @list_time, @status, @location)", {
                                ['@vehicle_id'] = result[1].vehicle, -- store spawn code
                                ['@owner_user_id'] = user_id,
                                ['@price'] = price,
                                ['@list_time'] = os.time(),
                                ['@status'] = 'for sale',
                                ['@location'] = 'main'
                            }, function(insertResult)
                                if insertResult ~= false then
                                    -- Copy mods from vice_vehicle_mods to vice_dealership_vehicle_mods
                                    local mods = exports['ghmattimysql']:executeSync("SELECT * FROM vice_vehicle_mods WHERE user_id = @user_id AND spawncode = @vehicle", {user_id = user_id, vehicle = result[1].vehicle})
                                    for _, mod in ipairs(mods) do
                                        exports['ghmattimysql']:execute("INSERT INTO vice_dealership_vehicle_mods (listing_id, savekey, mod, enabled) VALUES (@listing_id, @savekey, @mod, @enabled)", {
                                            ['@listing_id'] = insertResult.insertId,
                                            ['@savekey'] = mod.savekey,
                                            ['@mod'] = mod.mod,
                                            ['@enabled'] = mod.enabled
                                        })
                                    end
                                    -- Copy stancer mods if needed (similar logic)
                                    -- Remove from player's vehicles
                                    exports.ghmattimysql:execute("DELETE FROM vice_user_vehicles WHERE user_id = @user_id AND vehicle = @vehicle", {
                                        ['@user_id'] = user_id,
                                        ['@vehicle'] = vehicle
                                    })
                                    TriggerClientEvent("VICE:vehicleListed", source, true, "Vehicle listed for sale successfully!")
                                else
                                    VICE.giveBankMoney(user_id, cfg.ListingFee)
                                    TriggerClientEvent("VICE:vehicleListed", source, false, "This vehicle is already listed for sale!")
                                end
                            end)
                        end
                    end)
                else
                    VICE.giveBankMoney(user_id, cfg.ListingFee) -- Refund listing fee
                    TriggerClientEvent("VICE:vehicleListed", source, false, "You don't own this vehicle!")
                end
            end)
        else
            TriggerClientEvent("VICE:vehicleListed", source, false, "You can't afford the listing fee!")
        end
    end
end)

-- Get dealership listings
RegisterServerEvent("VICE:getDealershipListings")
AddEventHandler("VICE:getDealershipListings", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        exports.ghmattimysql:execute([[ 
            SELECT d.*, u.username as seller_name, d.vehicle_id as vehicle, NULL as vehicle_plate 
            FROM vice_playerdealership d 
            LEFT JOIN vice_users u ON d.owner_user_id = u.id 
            WHERE d.status = 'for sale' 
        ]], {}, function(listings)
            TriggerClientEvent("VICE:receiveDealershipListings", source, listings)
        end)
    end
end)

-- Purchase vehicle
RegisterServerEvent("VICE:purchaseVehicle")
AddEventHandler("VICE:purchaseVehicle", function(listing_id)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        exports.ghmattimysql:execute("SELECT * FROM vice_playerdealership WHERE listing_id = @id AND status = 'for sale'", {
            ['@id'] = listing_id
        }, function(result)
            if result and #result > 0 then
                local listing = result[1]
                if not listing.vehicle_id or listing.vehicle_id == '' then
                    print("[DEALERSHIP ERROR] Listing vehicle_id is nil or empty for listing_id:", listing_id)
                    TriggerClientEvent("VICE:vehiclePurchased", source, false, "Vehicle data missing. Contact staff.")
                    return
                end
                if VICE.tryPayment(user_id, listing.price) then
                    -- Generate new plate
                    local plate = "PD" .. math.random(100000, 999999)
                    -- Add vehicle to buyer's garage
                    exports.ghmattimysql:execute("INSERT INTO vice_user_vehicles (user_id, vehicle, vehicle_plate, rented, locked, impounded) VALUES (@user_id, @vehicle, @plate, 0, 0, 0)", {
                        ['@user_id'] = user_id,
                        ['@vehicle'] = listing.vehicle_id,
                        ['@plate'] = plate
                    }, function(insertResult)
                        if insertResult and insertResult.affectedRows > 0 then
                            -- Copy mods from vice_dealership_vehicle_mods to buyer's vice_vehicle_mods
                            exports.ghmattimysql:execute("SELECT * FROM vice_dealership_vehicle_mods WHERE listing_id = @listing_id", {
                                ['@listing_id'] = listing_id
                            }, function(mods)
                                if mods and #mods > 0 then
                                    for _, mod in ipairs(mods) do
                                        exports.ghmattimysql:execute("INSERT INTO vice_vehicle_mods (user_id, spawncode, savekey, mod, enabled) VALUES (@user_id, @spawncode, @savekey, @mod, @enabled)", {
                                            ['@user_id'] = user_id,
                                            ['@spawncode'] = listing.vehicle_id,
                                            ['@savekey'] = mod.savekey,
                                            ['@mod'] = mod.mod,
                                            ['@enabled'] = mod.enabled
                                        })
                                    end
                                end
                            end)

                            -- Update listing status and give money to seller
                            exports.ghmattimysql:execute("UPDATE vice_playerdealership SET status = 'sold', buyer_user_id = @buyer_id, sale_time = @sale_time WHERE listing_id = @id", {
                                ['@id'] = listing_id,
                                ['@buyer_id'] = user_id,
                                ['@sale_time'] = os.time()
                            })

                            -- Give money to seller
                            VICE.giveMoney(listing.owner_user_id, listing.price)

                            -- Notify buyer
                            TriggerClientEvent("VICE:vehiclePurchased", source, true, "Vehicle purchased successfully! Pick up your vehicle from the nearest garage.")
                            
                            -- Notify seller if online
                            local seller_source = VICE.getUserSource(listing.owner_user_id)
                            if seller_source then
                                TriggerClientEvent("VICE:vehicleSold", seller_source, true, "Your vehicle has been sold for £" .. listing.price)
                                
                                -- Send Discord notification
                                local buyerMention = user_id and ("<@"..user_id..">") or ("PermID: "..tostring(user_id))
                                local friendlyName = getFriendlyVehicleName(listing.vehicle_id)
                                local msg = ("%s bought your vehicle: %s for £%s!"):format(buyerMention, friendlyName, listing.price)
                                PerformHttpRequest("http://127.0.0.1:3002/dealership-dm", function(err, text, headers) end, "POST", json.encode({
                                    discordId = VICE.getUserDiscordId(seller_source),
                                    message = msg
                                }), { ["Content-Type"] = "application/json" })
                            end
                        else
                            -- Refund the buyer if vehicle insertion failed
                            VICE.giveMoney(user_id, listing.price)
                            TriggerClientEvent("VICE:vehiclePurchased", source, false, "Failed to add vehicle to your garage. Money has been refunded.")
                        end
                    end)
                else
                    TriggerClientEvent("VICE:vehiclePurchased", source, false, "You can't afford this vehicle!")
                end
            else
                TriggerClientEvent("VICE:vehiclePurchased", source, false, "This vehicle is no longer available!")
            end
        end)
    end
end)

-- Helper to get friendly vehicle name from garages config
local function getFriendlyVehicleName(spawnCode)
    local garages = module("cfg/cfg_garages").garages
    for _, garage in pairs(garages) do
        if type(garage) == "table" then
            for code, data in pairs(garage) do
                if code ~= "_config" and code:lower() == tostring(spawnCode):lower() and type(data) == "table" and data[1] then
                    return data[1]
                end
            end
        end
    end
    return tostring(spawnCode)
end 