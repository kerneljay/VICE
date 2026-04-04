local rpZones = {}
local numRP = 0
RegisterServerEvent("VICE:createRPZone")
AddEventHandler("VICE:createRPZone", function(a)
	local source = source
	local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'group.remove') then
        numRP = numRP + 1
        a['uuid'] = numRP
        rpZones[numRP] = a
        TriggerClientEvent('VICE:createRPZone', -1, a)
    end
end)

RegisterServerEvent("VICE:removeRPZone")
AddEventHandler("VICE:removeRPZone", function(b)
	local source = source
	local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'group.remove') then
        if next(rpZones) then
            for k,v in pairs(rpZones) do
                if v.uuid == b then
                    rpZones[k] = nil
                    TriggerClientEvent('VICE:removeRPZone', -1, b)
                end
            end
        end
    end
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    if first_spawn then
        for k,v in pairs(rpZones) do
            TriggerClientEvent('VICE:createRPZone', source, rpZones)
        end
    end
end)
