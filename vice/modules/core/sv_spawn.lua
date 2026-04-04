local cfg=module("cfg/cfg_spawn")


RegisterNetEvent("VICE:SendSpawnMenu")
AddEventHandler("VICE:SendSpawnMenu",function()
    local source = source
    local user_id = VICE.getUserId(source)
    local spawnTable={}
    for k,v in pairs(cfg.spawnLocations)do
        if v.permission[1] then
            if VICE.hasPermission(VICE.getUserId(source),v.permission[1])then
                table.insert(spawnTable, k)
            end
        else
            table.insert(spawnTable, k)
        end
    end
    exports['vice']:execute("SELECT * FROM `vice_user_homes` WHERE user_id = @user_id", {user_id = user_id}, function(result)
        if result then 
            for a,b in pairs(result) do
                table.insert(spawnTable, b.home)
            end
            TriggerClientEvent("VICE:OpenSpawnMenu",source,spawnTable)
            VICE.clearInventory(user_id) 
            VICEclient.setPlayerCombatTimer(source, {0})
        end
    end)
end)