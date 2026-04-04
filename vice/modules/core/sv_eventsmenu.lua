RegisterNetEvent('VICE:checkperm')
AddEventHandler('VICE:checkperm',function ()
    local src = source 
    local user_id = VICE.getUserId(src)
    if VICE.hasGroup(user_id,'Events Team') or VICE.isDeveloper then 
        TriggerClientEvent("VICE:gotPerm",src,true)
    else
        TriggerClientEvent("VICE:gotPerm",src,false)
    end
end)
