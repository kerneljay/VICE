local lookup = {
    ["VICEELS:changeStage"] = "VICEELS:1",
    ["VICEELS:toggleSiren"] = "VICEELS:2",
    ["VICEELS:toggleBullhorn"] = "VICEELS:3",
    ["VICEELS:patternChange"] = "VICEELS:4",
    ["VICEELS:vehicleRemoved"] = "VICEELS:5",
    ["VICEELS:indicatorChange"] = "VICEELS:6"
}

local origRegisterNetEvent = RegisterNetEvent
RegisterNetEvent = function(name, callback)
    origRegisterNetEvent(lookup[name], callback)
end

if IsDuplicityVersion() then
    local origTriggerClientEvent = TriggerClientEvent
    TriggerClientEvent = function(name, target, ...)
        origTriggerClientEvent(lookup[name], target, ...)
    end

    TriggerClientScopeEvent = function(name, target, ...)
        exports["vice"]:TriggerClientScopeEvent(lookup[name], target, ...)
    end
else
    local origTriggerServerEvent = TriggerServerEvent
    TriggerServerEvent = function(name, ...)
        origTriggerServerEvent(lookup[name], ...)
    end
end