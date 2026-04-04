h = {}
local cfg = module("cfg/cfg_housing")
local housedata = {
    homedata = {
        -- [housename] = {users = {user_id = {}}}
    },
    robberydata = {
        -- [housename] = {open = false,boltcuttingtime = startedanim,lastrobbed = openedtime,
        -- startedanim = When the player started the animation
        -- openedtime = When the house gets cracked open
        -- open = If the house is opened or not
    }
}

for k, v in pairs(cfg.homes) do
    housedata.homedata[k] = {users = {}}
    housedata.robberydata[k] = {open = false,houseowner = nil,boltcuttingtime = 0,lastrobbed = 0}
end

MySQL = module("modules/database/MySQL")

MySQL.createCommand("VICE/get_address","SELECT home, number FROM vice_user_homes WHERE user_id = @user_id")
MySQL.createCommand("VICE/get_home_owner","SELECT user_id FROM vice_user_homes WHERE home = @home AND number = @number")
MySQL.createCommand("VICE/rm_address","DELETE FROM vice_user_homes WHERE user_id = @user_id AND home = @home")
MySQL.createCommand("VICE/set_address","REPLACE INTO vice_user_homes(user_id,home,number) VALUES(@user_id,@home,@number)")
MySQL.createCommand("VICE/fetch_rented_houses", "SELECT * FROM vice_user_homes WHERE rented = 1")
MySQL.createCommand("VICE/rentedupdatehouse", "UPDATE vice_user_homes SET user_id = @id, rented = @rented, rentedid = @rentedid, rentedtime = @rentedunix WHERE user_id = @user_id AND home = @home")

Citizen.CreateThread(function()
    while true do
        Wait(300000)
        MySQL.query('VICE/fetch_rented_houses', {}, function(rentedhouses)
            for i,v in pairs(rentedhouses) do 
               if os.time() > tonumber(v.rentedtime) then
                  MySQL.execute('VICE/rentedupdatehouse', {id = v.rentedid, rented = 0, rentedid = "", rentedunix = "", user_id = v.user_id, home = v.home})
               end
            end
        end)
    end
end)

function getUserAddress(user_id, cbr)
    local task = Task(cbr)
  
    MySQL.query("VICE/get_address", {user_id = user_id}, function(rows, affected)
        task({rows[1]})
    end)
end
  
function setUserAddress(user_id, home, number)
    MySQL.execute("VICE/set_address", {user_id = user_id, home = home, number = number})
end
  
function removeUserAddress(user_id, home)
    MySQL.execute("VICE/rm_address", {user_id = user_id, home = home})
end

function getOwnedHouses(user_id, cb)
    local ownedHouses = {}

    for k, v in pairs(cfg.homes) do
        getUserByAddress(k, 1, function(owner)
            if owner == user_id then
                table.insert(ownedHouses, k)
            end
        end)
    end

    cb(ownedHouses)
end

function getUserByAddress(home, number, cbr)
    local task = Task(cbr)
  
    MySQL.query("VICE/get_home_owner", {home = home, number = number}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].user_id})
        else
            task()
        end
    end)
end

exports('getOwnedHouses', getOwnedHouses)

function leaveHome(user_id, home, number, cbr)
    local task = Task(cbr)
    local player = VICE.getUserSource(user_id)
    VICE.setBucket(player, 0)
    for k, v in pairs(cfg.homes) do
        if k == home then
            local x,y,z = table.unpack(v.entry_point)
            VICEclient.teleport(player, {x,y,z})
            VICEclient.setInHome(player, {false})
            housedata.homedata[home].users[user_id] = nil
            task({true})
        end
    end
end

function accessHome(user_id, home, number, cbr)
    local task = Task(cbr)
    local player = VICE.getUserSource(user_id)
    local count = 0
    for k, v in pairs(cfg.homes) do
        count = count+1
        if k == home then
            VICE.setBucket(player, count)
            local x,y,z = table.unpack(v.leave_point)
            VICEclient.teleport(player, {x,y,z})
            VICEclient.setInHome(player, {true})
            housedata.homedata[home].users[user_id] = true
            task({true})
        end
    end
end

function VICE.RecentlyRobbed(home)
    if housedata.robberydata[home].open then
        return true, housedata.robberydata[home].houseowner
    end
    return false, housedata.robberydata[home].houseowner
end

RegisterNetEvent("VICE:buyHome")
AddEventHandler("VICE:buyHome", function(house)
    local source = source
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)

    for k, v in pairs(cfg.homes) do
        if house == k then
            getUserByAddress(house,1,function(noowner) --check if house already has a owner
                if noowner == nil then
                    getUserAddress(user_id, function(address) -- check if user already has a home
                        if VICE.tryFullPayment(user_id,v.buy_price) then --try payment
                            local price = v.buy_price
                            setUserAddress(user_id,house,1) --set address
                            VICE.notify(player, "~g~You bought "..k.."!") --notify
                            for a,b in pairs(VICE.getUsers({})) do
                                local x,y,z = table.unpack(v.entry_point)
                                VICEclient.removeBlipAtCoords(b,{x,y,z})
                                if user_id == a then
                                    VICEclient.addBlip(b,{x,y,z,374,1,house})
                                    TriggerClientEvent('VICE:ownedStatus', source, k, true)
                                end
                            end
                            VICE.sendDCLog('housing-buy', 'VICE Housing Logs', "**User Name:** "..VICE.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Price: **".. price.. "\n **House Name: **" ..k)
                        else
                            VICE.notify(player, "~r~You do not have enough money to buy "..k) --not enough money
                        end
                    end)
                else
                    VICE.notify(player, "~r~Someone already owns "..k)
                end
                if noowner then
                    TriggerClientEvent('VICE:addHome', source)
                    clientOwnsHome = true
                end
            end)
        end
    end
end)

RegisterNetEvent("VICE:enterHome")
AddEventHandler("VICE:enterHome", function(house)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)
    local name = VICE.getPlayerName(user_id)

    getUserByAddress(house, 1, function(huser_id) --check if player owns home
        local hplayer = VICE.getUserSource(huser_id) --temp id of home owner

        if huser_id then
            if huser_id == user_id then
                accessHome(user_id, house, 1, function(ok) --enter home
                    if not ok then
                        VICE.notify(player, "Unable to enter home") --notify unable to enter home for whatever reason
                    end
                end)
            else
                if hplayer then --check if home owner is online
                    VICE.notify(player, "~r~You do not own this home, Knocked on door!")
                    VICE.request(hplayer,name.." knocked on your door!", 30, function(v,ok) --knock on door
                        if ok then
                            VICE.notify(player, "~g~Doorbell Accepted") --doorbell accepted
                            accessHome(user_id, house, 1, function(ok) --enter home
                                if not ok then
                                    VICE.notify(player, "~r~Unable to enter home!") --notify unable to enter home for whatever reason
                                end
                            end)
                        end
                        if not ok then
                            VICE.notify(player, "~r~Doorbell Refused ") -- doorbell refused
                        end
                    end)
                else
                    VICE.notify(player, "~r~Home owner not online!") -- home owner not online
                end
            end
        else
            VICE.notify(player, "~r~Nobody owns "..house.."") --no home owner & user_id already doesn't have a house
        end
    end)
end)

RegisterNetEvent("VICE:Leave")
AddEventHandler("VICE:Leave", function(house)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)

    leaveHome(user_id, house, 1, function(ok) --leave home
        if not ok then
            VICE.notify(player, "~r~Unable to leave home!") --notify if some error
        end
    end)
end)

RegisterNetEvent("VICE:Sell")
AddEventHandler("VICE:Sell", function(house)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)

    getUserByAddress(house, 1, function(huser_id)
        if huser_id == user_id then
            VICEclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
                usrList = ""
                for k, v in pairs(nplayers) do
                    usrList = usrList .. "[" .. VICE.getUserId(k) .. "]" .. VICE.getPlayerName(VICE.getUserId(k)) .. " | " --add ids to usrList
                end
                if usrList ~= "" then
                    VICE.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                        target_id = target_id
                        if target_id and target_id ~= "" then --validation
                            local target = VICE.getUserSource(tonumber(target_id)) --get source of the new owner id
                            if target then
                                VICE.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                    if tonumber(amount) and tonumber(amount) > 0 then
                                        VICE.request(target,VICE.getPlayerName(VICE.getUserId(player)).." wants to sell: " ..house.. " Price: £"..amount, 30, function(target,ok) --request new owner if they want to buy
                                            if ok then --bought
                                                local buyer_id = VICE.getUserId(target) --get perm id of new owner
                                                amount = tonumber(amount) --convert amount str to int
                                                if VICE.tryFullPayment(buyer_id,amount) then
                                                    setUserAddress(buyer_id, house, 1) --give house
                                                    removeUserAddress(user_id, house) -- remove house
                                                    VICE.giveBankMoney(user_id, amount) --give money to original owner
                                                    TriggerClientEvent('VICE:ownedStatus', source, house, false)
                                                    VICE.notify(player, "~g~You have successfully sold "..house.." to ".. VICE.getPlayerName(buyer_id).." for £"..amount.."!") --notify original owner
                                                    VICE.notify(target, "~g~"..VICE.getPlayerName(VICE.getUserId(player)).." has successfully sold you "..house.." for £"..amount.."!") --notify new owner
                                                    VICE.sendDCLog('housing-sell', 'VICE Housing Logs', "**User Name:** "..VICE.getPlayerName(user_id).."\n**User ID:** "..VICE.getUserId(source).."\n**Buyer Name: **"..VICE.getPlayerName(buyer_id).. "\n**Buyer ID: **" ..VICE.getUserId(source).. "\n**Price: **".. amount.. "\n**House Name: **" ..house)
                                               
                                                else
                                                    VICE.notify(player, "".. VICE.getPlayerName(buyer_id).." doesn't have enough money!") --notify original owner
                                                    VICE.notify(target, "~r~You don't have enough money!") --notify new owner
                                                end
                                            else
                                                VICE.notify(player, ""..VICE.getPlayerName(buyer_id).." has refused to buy "..house.."!") --notify owner that refused
                                                VICE.notify(target, "~r~You have refused to buy "..house.."!") --notify new owner that refused
                                            end
                                        end)
                                    else
                                        VICE.notify(player, "~r~Price of home needs to be a number!") -- if price of home is a string not a int
                                    end
                                end)
                            else
                                VICE.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                            end
                        else
                            VICE.notify(player, "~r~No Perm ID selected!") --no perm id selected
                        end
                    end)
                else
                    VICE.notify(player, "~r~No players nearby!") --no players nearby
                end
            end)
        else
            VICE.notify(player, "~r~You do not own "..house.."!")
        end
    end)
end)

RegisterNetEvent('VICE:Rent')
AddEventHandler('VICE:Rent', function(house)
    local user_id = VICE.getUserId(source)
    local player = VICE.getUserSource(user_id)

    getUserByAddress(house, 1, function(huser_id)
        if huser_id == user_id then
            VICEclient.getNearestPlayers(player,{15},function(nplayers) --get nearest players
                usrList = ""
                for k, v in pairs(nplayers) do
                    usrList = usrList .. "[" .. VICE.getUserId(k) .. "]" .. VICE.getPlayerName(VICE.getUserId(k)) .. " | " --add ids to usrList
                end
                if usrList ~= "" then
                    VICE.prompt(player,"Players Nearby: " .. usrList .. "","",function(player, target_id) --ask for id
                        target_id = target_id
                        if target_id and target_id ~= "" then --validation
                            local target = VICE.getUserSource(tonumber(target_id)) --get source of the new owner id
                            if target then
                                VICE.prompt(player,"Price £: ","",function(player, amount) --ask for price
                                    if tonumber(amount) and tonumber(amount) > 0 then
                                        VICE.prompt(player,"Duration: ","",function(player, duration) --ask for price
                                            if tonumber(duration) and tonumber(duration) > 0 then
                                                VICE.prompt(player, "Please replace text with YES or NO to confirm", "Rent Details:\nHouse: "..house.."\nRent Cost: "..amount.."\nDuration: "..duration.." hours\nRenting to player: "..VICE.getPlayerName(buyer_id).."("..target_id..")",function(player,details)
                                                    if string.upper(details) == 'YES' then
                                                        VICE.notify(player, '~g~Rent offer sent!')
                                                        VICE.request(target,VICE.getPlayerName(VICE.getUserId(player)).." wants to rent: " ..house.. " for "..duration.." hours, for £"..amount, 30, function(target,ok) --request new owner if they want to buy
                                                            if ok then 
                                                                local buyer_id = VICE.getUserId(target) --get perm id of new owner
                                                                amount = tonumber(amount) --convert amount str to int
                                                                if VICE.tryFullPayment(buyer_id,amount) then
                                                                    local rentedTime = os.time()
                                                                    rentedTime = rentedTime  + (60 * 60 * tonumber(duration)) 
                                                                    MySQL.execute("VICE/rentedupdatehouse", {user_id = user_id, home = house, id = target_id, rented = 1, rentedid = user_id, rentedunix =  rentedTime }) 
                                                                    VICE.giveBankMoney(user_id, amount)
                                                                    TriggerClientEvent('VICE:ownedStatus', source, house, false)
                                                                    VICE.notify(player, "~g~You have successfully rented "..house.." to ".. VICE.getPlayerName(buyer_id).." for £"..amount.."!") --notify original owner
                                                                    VICE.notify(target, "~g~"..VICE.getPlayerName(VICE.getUserId(player)).." has successfully rented you "..house.." for £"..amount.."!") --notify new owner
                                                                    VICE.sendDCLog('housing-rent', 'VICE Housing Logs', "**User Name:** "..VICE.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Buyer Name: **"..VICE.getPlayerName(buyer_id).. "\n**Buyer ID: **" ..buyer_id.. "\n**Price: **".. amount.. "\n**House Name: **" ..house)
                                                                else
                                                                    VICE.notify(player, "".. VICE.getPlayerName(buyer_id).." doesn't have enough money!") --notify original owner
                                                                    VICE.notify(target, "~r~You don't have enough money!") --notify new owner
                                                                end
                                                            else
                                                                VICE.notify(player, ""..VICE.getPlayerName(buyer_id).." has refused to rent "..house.."!") --notify owner that refused
                                                                VICE.notify(target, "~r~You have refused to rent "..house.."!") --notify new owner that refused
                                                            end
                                                        end)
                                                    end
                                                end)
                                            end
                                        end)
                                    else
                                        VICE.notify(player, "~r~Price of home needs to be a number!") -- if price of home is a string not a int
                                    end
                                end)
                            else
                                VICE.notify(player, "~r~That Perm ID seems to be invalid!") --couldnt find perm id
                            end
                        else
                            VICE.notify(player, "~r~No Perm ID selected!") --no perm id selected
                        end
                    end)
                else
                    VICE.notify(player, "~r~No players nearby!") --no players nearby
                end
            end)
        else
            VICE.notify(player, "~r~You do not own "..house.."!")
        end
    end)
end)

RegisterServerEvent("VICE:raidHome")
AddEventHandler("VICE:raidHome", function(house)
    local source = source
    local user_id = VICE.getUserId(source)
    if GetPlayerRoutingBucket(source) == 0 then
        getUserByAddress(house, 1, function(owner_id)
            if VICE.getUserSource(owner_id) then
                if user_id ~= owner_id then
                    VICEclient.startCircularProgressBar(source, {"", 15000, nil})
                    TriggerClientEvent("VICE:houseGettingRobbed",VICE.getUserSource(owner_id),house, true)
                    SetTimeout(15000, function() 
                        accessHome(user_id, house, 1, function(ok) --enter home
                            if not ok then
                                VICE.notify(source, "Unable to enter home") --notify unable to enter home for whatever reason
                            else
                                VICE.notify(source, "~g~You have successfully raided "..house..", You have 10 minutes")
                                VICE.notify(VICE.getUserSource(owner_id), "~g~Your house "..house.." is being raided by the MET Police!")
                                SetTimeout(120000, function()
                                    for k, v in pairs(housedata.homedata[house].users) do
                                        local player = VICE.getUserSource(k)
                                        if player then
                                            leaveHome(k, house, 1, function(ok) --leave home
                                                if not ok then
                                                    VICE.notify(player, "~r~Unable to leave home!") --notify if some error
                                                else
                                                    VICE.notify(player, "~r~House raid is over!")
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end
                        end)
                    end)
                else
                    VICE.notify(source, "~r~You cannot raid your own house!")
                end
            else
                VICE.notify(source, "~r~House owner is not online!")
            end
        end)
    else
        VICE.notify(source, "~r~You are in the incorrect universe to do this!")
    end
end)

RegisterServerEvent("VICE:HouseRobbery",function(house)
    local source = source
    local user_id = VICE.getUserId(source)
    if GetPlayerRoutingBucket(source) == 0 then
        if not housedata.robberydata[house].open then
            getUserByAddress(house,1,function(owner_id)
                if VICE.getUserSource(owner_id) then
                    if user_id ~= owner_id then
                        if VICE.tryGetInventoryItem(user_id,"boltcutters",1,false) then
                            housedata.robberydata[house].boltcuttingtime = os.time()
                            TriggerClientEvent("VICE:forceBoltCutting",source)
                            TriggerClientEvent("VICE:houseGettingRobbed",VICE.getUserSource(owner_id),house)
                            while os.time() - housedata.robberydata[house].boltcuttingtime < 60 do
                                Wait(1000)
                                if #(GetEntityCoords(GetPlayerPed(source)) - cfg.homes[house].entry_point) < 3.0 then
                                    VICEclient.isPlayingAnim(source,{"WORLD_HUMAN_WELDING"},function(anim)
                                        if not anim then
                                            VICE.notify(source, "~r~Failed to break into house!")
                                            return
                                        end
                                    end)
                                else
                                    VICE.notify(source, "~r~You moved too far away from the door!")
                                    return
                                end
                            end
                            VICEclient.stopAnim(source)
                            housedata.robberydata[house].open = true
                            housedata.robberydata[house].houseowner = owner_id
                            accessHome(user_id, house, 1, function(ok) --enter home
                                if not ok then
                                    VICE.notify(source, "Unable to enter home") --notify unable to enter home for whatever reason
                                else
                                    VICE.notify(source, "~g~You have successfully broken into "..house..", You have 10 minutes")
                                    VICE.notify(VICE.getUserSource(owner_id), "~g~Your house "..house..", has been broken into!")
                                    VICE.sendDCLog('housing-rob', 'VICE Housing Logs', "**User Name:** "..VICE.getPlayerName(user_id).."\n**User ID:** "..user_id.."\n**Type: **Robbery\n **House Name: **" ..house)
                                end
                                SetTimeout(120000,function()
                                    housedata.robberydata[house].open = false
                                    housedata.robberydata[house].houseowner = nil
                                    for k, v in pairs(housedata.homedata[house].users) do
                                        local player = VICE.getUserSource(k)
                                        if player then
                                            leaveHome(k, house, 1, function(ok) --leave home
                                                if not ok then
                                                    VICE.notify(player, "~r~Unable to leave home!") --notify if some error
                                                else
                                                    VICE.notify(player, "~r~House robberey ended!")
                                                end
                                            end)
                                        end
                                    end
                                end)
                            end)
                        else
                            VICE.notify(source, "~r~You do not have boltcutters!")
                        end
                    else
                        VICE.notify(source, "~r~You cannot rob your own house!")
                    end
                else
                    VICE.notify(source, "~r~House owner is not online!")
                end
            end)
        else
            accessHome(user_id, house, 1, function(ok) --enter home
                if not ok then
                    VICE.notify(player, "Unable to enter home") --notify unable to enter home for whatever reason
                end
            end)
        end
    else
        VICE.notify(source, "~r~You are in the incorrect universe to do this!")
    end
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    for k, v in pairs(cfg.homes) do
        local x, y, z = table.unpack(v.entry_point)
        getUserByAddress(k, 1, function(owner)
            local owned = owner == user_id
            if owner == nil then
                VICEclient.addBlip(source, {x, y, z, 374, 2, k, 0.8, true}) -- remove the 0.8 and true to display on full map instead of minimap
            end
            if owned then
                VICEclient.addBlip(source, {x, y, z, 374, 1, k})
                TriggerClientEvent('VICE:ownedStatus', source, k, owned)
            end
        end)
    end
end)