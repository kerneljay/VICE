RegisterServerEvent('VICE:checkForPolicewhitelist')
AddEventHandler('VICE:checkForPolicewhitelist', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        if VICE.hasPermission(user_id, 'police.announce') then
            TriggerClientEvent('VICE:openPNC', source, true, {}, {})
        else
            TriggerClientEvent('VICE:openPNC', source, false, {}, {})
        end
    end
end)

RegisterServerEvent('VICE:searchPerson')
AddEventHandler('VICE:searchPerson', function(firstname, lastname)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'police.armoury') then
        exports['vice']:execute("SELECT * FROM vice_user_identities WHERE firstname = @firstname AND name = @lastname", {firstname = firstname, lastname = lastname}, function(result) 
            if result then
                local returnedUsers = {}
                for k,v in pairs(result) do
                    local user_id = result[k].user_id
                    local firstname = result[k].firstname
                    local lastname = result[k].name
                    local data = exports['vice']:executeSync("SELECT * FROM vice_dvsa WHERE user_id = @user_id", {user_id = user_id})[1]
                    local licence = data.licence
                    local points = data.points
                    local age = result[k].age
                    local phone = result[k].phone
                    local ownedVehicles = exports['vice']:executeSync("SELECT * FROM vice_user_vehicles WHERE user_id = @user_id", {user_id = user_id})
                    local actualVehicles = {}
                    for a,b in pairs(ownedVehicles) do 
                        table.insert(actualVehicles, b.vehicle)
                    end
                    local ownedProperties = exports['vice']:executeSync("SELECT * FROM vice_user_homes WHERE user_id = @user_id", {user_id = user_id})
                    local actualHouses = {}
                    for a,b in pairs(ownedProperties) do 
                        table.insert(actualHouses, b.home)
                    end
                    table.insert(returnedUsers, {user_id = user_id, firstname = firstname, lastname = lastname, age = age, phone = phone, licence = licence, points = points, vehicles = actualVehicles, playerhome = actualHouses, warrants = {}, warning_markers = {}})
                end
                if next(returnedUsers) then
                    TriggerClientEvent('VICE:sendSearcheduser', source, returnedUsers)
                else
                    TriggerClientEvent('VICE:noPersonsFound', source)
                end
            end
        end)
    end
end)

RegisterServerEvent('VICE:finePlayer')
AddEventHandler('VICE:finePlayer', function(id, charges, amount, notes)
    local source = source
    local user_id = VICE.getUserId(source)
    local amount = tonumber(amount)
    if amount > 250000 then
        amount = 250000
    end
    if next(charges) then
        local chargesList = ""
        for k,v in pairs(charges) do
            chargesList = chargesList.."\n> - **"..v.fine.."**"
        end
        if VICE.hasPermission(user_id, 'police.armoury') then
            if id == user_id then
                TriggerClientEvent('VICE:verifyFineSent', source, false, "Can't fine yourself!")
                return
            end
            if VICE.tryBankPayment(id, amount) then
                VICE.giveBankMoney(user_id, amount*0.1)
                VICE.notifyPicture(VICE.getUserSource(id), "walletnotification", "notification", "You have been fined ~r~£" .. getMoneyStringFormatted(amount), "Wallet", "Fine received")
                VICE.notifyPicture(source, "walletnotification", "notification", "You have received ~g~£" .. getMoneyStringFormatted(amount) .. " ~s~for fining " ..VICE.getPlayerName(id).. ".", "Wallet", "Fine player")
                TriggerEvent('VICE:addToCommunityPot', tonumber(amount))
                TriggerClientEvent('VICE:verifyFineSent', source, true)
                VICE.sendDCLog('fine-player', 'VICE Fine Logs',"> Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Criminal Name: **"..VICE.getPlayerName(id).."**\n> Criminal PermID: **"..id.."**\n> Criminal TempID: **"..VICE.getUserSource(id).."**\n> Amount: **£"..amount.."**\n> Charges: "..chargesList)--.."\n> Notes: **"..notes.."**")
                -- do notes later
                VICE.AddStat(user_id,"amount_fined",amount)
            else
                TriggerClientEvent('VICE:verifyFineSent', source, false, 'The player does not have enough money.')
            end
        end
    end
end)


RegisterServerEvent('VICE:addPoints')
AddEventHandler('VICE:addPoints', function(charges, id)
    local source = source
    local user_id = VICE.getUserId(source)
    
    if VICE.hasPermission(user_id, 'police.armoury') then
        local totalPoints = 0 
        for i, v in pairs(charges) do
            local point = v.points 
            local reason = v.name
            totalPoints = totalPoints + point 
        end
        if totalPoints > 12 then
            totalPoints = 12
        end
        exports['vice']:execute("UPDATE vice_dvsa SET points = points + @newpoints WHERE user_id = @user_id", {user_id = id, newpoints = totalPoints})
        exports['vice']:execute('SELECT * FROM vice_dvsa WHERE user_id = @user_id', {user_id = user_id}, function(licenceInfo)
            local licenceType = licenceInfo[1].licence
            local userPoints = tonumber(licenceInfo[1].points)
            if (licenceType == "active" or licenceType == "full") and userPoints > 12 then
                VICE.notify(VICE.getUserSource(id), '~r~You have received '..totalPoints..' on your licence. You now have '..userPoints..'/12 points. Your licence has been suspended.')
                exports['vice']:execute("UPDATE vice_dvsa SET licence = 'banned' WHERE user_id = @user_id", {user_id = id})
                Wait(100)
                dvsaUpdate(user_id)
            else
                VICE.notify(VICE.getUserSource(id), '~r~You have received '..totalPoints..' on your licence. You now have '..userPoints..'/12 points.')
            end
            if userPoints > 12 then
                exports['vice']:execute("UPDATE vice_dvsa SET points = @points WHERE user_id = @user_id", {user_id = id, points = 12})
            end
        end)
    end
end)

RegisterServerEvent('VICE:searchPlate')
AddEventHandler('VICE:searchPlate', function(plate)
    TriggerClientEvent('VICE:displayPlate', source, plate)
end)

RegisterCommand('testad', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id == 1 then
        TriggerClientEvent('VICE:notifyAD', source, 'Phase 3 Firearms', 'Red Vauxhall Corsa')
    end
end)