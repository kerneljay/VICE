RegisterCommand('craftbmx', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, 'admin.tickets') then
        TriggerClientEvent("VICE:spawnNitroBMX", source)
    else
        if VICE.checkForRole(user_id, '1388197597180592210') then
            TriggerClientEvent("VICE:spawnNitroBMX", source)
        end
    end
end)

RegisterCommand('craftmoped', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    VICEclient.isPlatClub(source, {}, function(isPlatClub)
        if VICE.hasPermission(user_id, 'admin.tickets') or isPlatClub then 
            TriggerClientEvent("VICE:spawnMoped", source)
        end
    end)
end)

