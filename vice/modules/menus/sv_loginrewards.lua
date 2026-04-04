local cfg = module("cfg/cfg_loginrewards")

MySQL.createCommand("dailyrewards/set_reward_time","UPDATE vice_daily_rewards SET last_reward = @last_reward WHERE user_id = @user_id")
MySQL.createCommand("dailyrewards/set_reward_streak","UPDATE vice_daily_rewards SET streak = @streak WHERE user_id = @user_id")
MySQL.createCommand("dailyrewards/get_reward_time","SELECT last_reward FROM vice_daily_rewards WHERE user_id = @user_id")
MySQL.createCommand("dailyrewards/get_reward_streak","SELECT streak FROM vice_daily_rewards WHERE user_id = @user_id")
MySQL.createCommand("dailyrewards/add_id", "INSERT IGNORE INTO vice_daily_rewards SET user_id = @user_id")

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_daily_rewards(user_id) VALUES(@user_id)", {user_id = user_id})
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        MySQL.query("dailyrewards/get_reward_time", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then
                if rows[1].last_reward then
                    local x = rows[1].last_reward
                    local y = os.time()
                    local streak = 0
                    MySQL.query("dailyrewards/get_reward_streak", {user_id = user_id}, function(rows, affected)
                        if #rows > 0 then
                            if rows[1].streak > 0 and y - 86400*2 > x then
                                streak = 0
                            else
                                streak = rows[1].streak
                            end
                        end
                        MySQL.execute("dailyrewards/set_reward_streak", {user_id = user_id, streak = streak})
                        TriggerClientEvent('VICE:setDailyRewardInfo', source, streak, x,y)
                        return
                    end)
                end
            end
        end)
    end
end)
local cooldown = {}
RegisterNetEvent("VICE:he")
AddEventHandler("VICE:he", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local current_time = os.time()
    MySQL.query("dailyrewards/get_reward_streak", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            Streak = rows[1].streak
           local last_reward = rows[1].last_reward
           if last_reward and current_time - last_reward < 86400000 then
                print('[DEBUG Already claimed.]')
            end
            if cooldown[source] and not (os.time() > cooldown[source]) then
                VICE.ACBan(15,user_id,"VICE:he")
                
                return
            else
                cooldown[source] = nil
                Streak = Streak + 1
            end
           
            cooldown[source] = os.time() + 86400000
            end
            for k,v in pairs(cfg.rewards) do
                if v.day == Streak then
                    VICE.giveBankMoney(user_id,v.amount)
                    TriggerClientEvent('VICE:smallAnnouncement', source, 'login reward', "You have claimed £"..getMoneyStringFormatted(grindBoost*v.amount).." from the login reward!", 33, 10000)
                    MySQL.execute("dailyrewards/set_reward_streak", {user_id = user_id, streak = Streak})
                    MySQL.execute("dailyrewards/set_reward_time", {user_id = user_id, last_reward = os.time()})
                    return
                end
            end
            VICE.giveBankMoney(user_id, 150000)
            TriggerClientEvent('VICE:smallAnnouncement', source, 'login reward', "You have claimed £150,000 from the login reward!", 33, 10000)
            MySQL.execute("dailyrewards/set_reward_streak", {user_id = user_id, streak = Streak})
            MySQL.execute("dailyrewards/set_reward_time", {user_id = user_id, last_reward = os.time()})
       
        
    end)
end)