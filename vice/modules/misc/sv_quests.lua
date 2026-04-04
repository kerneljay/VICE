MySQL.createCommand("quests/add_id", "INSERT IGNORE INTO vice_quests SET user_id = @user_id")

AddEventHandler("playerJoining", function()
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:executeSync("INSERT IGNORE INTO vice_quests SET user_id = @user_id", {user_id = user_id})
end)

RegisterServerEvent("VICE:setQuestCompleted")
AddEventHandler("VICE:setQuestCompleted", function()
	local source = source
	local user_id = VICE.getUserId(source)
    local a = exports['vice']:executeSync("SELECT * FROM vice_quests WHERE user_id = @user_id", {user_id = user_id})
    for k,v in pairs(a) do
        if v.user_id == user_id then
            if v.quests_completed < 51 and not v.reward_claimed then
                exports['vice']:execute("UPDATE vice_quests SET quests_completed = (quests_completed+1) WHERE user_id = @user_id", {user_id = user_id}, function() end)
            else
                VICE.ACBan(15,user_id,"VICE:setQuestCompleted")
            end
        end
    end
end)

RegisterServerEvent("VICE:claimQuestReward")
AddEventHandler("VICE:claimQuestReward", function()
	local source = source
	local user_id = VICE.getUserId(source)
    local a = exports['vice']:executeSync("SELECT * FROM vice_quests WHERE user_id = @user_id", {user_id = user_id})
    local plathours = 0
    for k,v in pairs(a) do
        if v.user_id == user_id then
            if not v.reward_claimed and v.quests_completed == 50 then
                -- code to give plat days
                MySQL.query("subscription/get_subscription", {user_id = user_id}, function(rows, affected)
                    plathours = rows[1].plathours
                    MySQL.execute("subscription/set_plathours", {user_id = user_id, plathours = plathours + 168*2})
                    exports['vice']:execute("UPDATE vice_quests SET reward_claimed = true WHERE user_id = @user_id", {user_id = user_id}, function() end)
                end)
            else
                VICE.ACBan(15,user_id,"VICE:claimQuestReward")
            end
        end
    end
end)
