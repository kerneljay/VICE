local stats = {monthly = {},total = {}}

local function RefreshStatMenu()
    stats = {monthly = {}, total = {}}
    exports["vice"]:execute("SELECT * FROM vice_statistics",function(result)
        if result then
            for k,v in pairs(result) do
                local monthly, total = #stats.monthly+1, #stats.total+1
                stats.monthly[monthly], stats.total[total] = json.decode(v.monthlystats), json.decode(v.totalstats)
                stats.monthly[monthly].name, stats.total[total].name = v.name, v.name
                stats.monthly[monthly].user_id, stats.total[total].user_id = v.user_id, v.user_id
            end
          --  print("[VICE] Statistic loaded")
        end
    end)
end

function VICE.SetStat(user_id, stat, value)
    if user_id and stat and value then
        exports["vice"]:execute("SELECT * FROM vice_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local monthly = json.decode(result[1].monthlystats)
                local total = json.decode(result[1].totalstats)
                if monthly[stat] == nil then
                    monthly[stat] = 0
                end
                if total[stat] == nil then
                    total[stat] = 0
                end
                monthly[stat], total[stat] = value, value
                exports["vice"]:execute("UPDATE vice_statistics SET name = @name, monthlystats = @monthly, totalstats = @total WHERE user_id = @user_id", {user_id = user_id, name = result[1].name, monthly = json.encode(monthly), total = json.encode(total)})
            end
        end)
    end
end

function VICE.AddStat(user_id, stat, value)
    if user_id and stat and value then
        exports["vice"]:execute("SELECT * FROM vice_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local monthly = json.decode(result[1].monthlystats)
                local total = json.decode(result[1].totalstats)
                if monthly[stat] == nil then
                    monthly[stat] = 0
                end
                if total[stat] == nil then
                    total[stat] = 0
                end
                monthly[stat], total[stat] = monthly[stat] + value, total[stat] + value
                exports["vice"]:execute("UPDATE vice_statistics SET name = @name, monthlystats = @monthly, totalstats = @total WHERE user_id = @user_id", {user_id = user_id, name = result[1].name, monthly = json.encode(monthly), total = json.encode(total)})
            end
        end)
    end
end

function VICE.GetStat(user_id, stat)
    if user_id and stat then
        local statValue = nil
        exports["vice"]:execute("SELECT * FROM vice_statistics WHERE user_id = @user_id", {user_id = user_id}, function(result)
            if result and result[1] then
                local total = json.decode(result[1].totalstats)
                statValue = total[stat]
            end
        end)
        return statValue
    end
end

MySQL.createCommand("vice_stats/adduser","INSERT INTO vice_statistics (user_id,name,monthlystats,totalstats) VALUES (@user_id,@name,@monthly,@total) ON DUPLICATE KEY UPDATE name = @name, monthlystats = @monthly, totalstats = @total")

RegisterServerEvent("VICE:requestStatistics")
AddEventHandler("VICE:requestStatistics", function()
    local source = source
    TriggerClientEvent("VICEDEATHUI:setStatistics", source, stats.monthly, stats.total,VICE.getUserId(source))
end)

AddEventHandler("VICE:onServerSpawn",function(user_id,source,first_spawn)
    if first_spawn then
        tVICE.GetPlayTime(user_id)
        local defaultdata = {name = VICE.getPlayerName(user_id),user_id = user_id,kills = 0,deaths = 0,amount_robbed = 0,jailed_time = 0,playtime = 0,weed_sales = 0,cocaine_sales = 0,meth_sales = 0,heroin_sales = 0,lsd_sales = 0,copper_sales = 0,limestone_sales = 0,gold_sales = 0,diamond_sales = 0,arrests = 0,searches = 0,money_seized = 0,revives = 0,bodybagged = 0,amount_fined = 0}
        MySQL.execute("vice_stats/adduser",{user_id = user_id,name = VICE.getPlayerName(user_id),monthly = json.encode(defaultdata),total = json.encode(defaultdata)})
    end
end)

RegisterCommand("refreshstats",function(source,args)
    local source = source
    if source == 0 or VICE.getUserId(source) == 1 then
        RefreshStatMenu()
    end
end)

RefreshStatMenu()