local cfg=module("cfg/cfg_peds")

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    local user_id = VICE.getUserId(source)
    if first_spawn then
        local pedAccess = {}
        local user_id = VICE.getUserId(source)
        for k,v in pairs(cfg.pedMenus) do
            for i,j in pairs(cfg.peds) do
                if v[1] == i then
                    if j['config'].permissions[1] then
                        if VICE.hasPermission(user_id, j['config'].permissions[1]) then
                            table.insert(pedAccess, {i, v[2]})
                        end
                    else
                        table.insert(pedAccess, {i, v[2]})
                    end
                end
            end
        end
        TriggerClientEvent("VICE:buildPedMenus",source,pedAccess)
    end
end)