RegisterNetEvent("VICEELS:changeStage", function(stage)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('VICEELS:changeStage', -1, vehicleNetId, stage)
end)

RegisterNetEvent("VICEELS:toggleSiren", function(tone)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('VICEELS:toggleSiren', -1, vehicleNetId, tone)
end)

RegisterNetEvent("VICEELS:toggleBullhorn", function(enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('VICEELS:toggleBullhorn', -1, vehicleNetId, enabled)
end)

RegisterNetEvent("VICEELS:patternChange", function(patternIndex, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('VICEELS:patternChange', -1, vehicleNetId, patternIndex, enabled)
end)

RegisterNetEvent("VICEELS:vehicleRemoved", function(stage)
	TriggerClientEvent('VICEELS:vehicleRemoved', -1, stage)
end)

RegisterNetEvent("VICEELS:indicatorChange", function(indicator, enabled)
    local source = source
    local vehicleNetId = NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source)))
	TriggerClientEvent('VICEELS:indicatorChange', -1, vehicleNetId, indicator, enabled)
end)