VICE = {}

local function TriggerErrorEvent(data)
    if IsDuplicityVersion() then
        TriggerEvent("VICE:serverIssue", data:gsub(":(.*)", ""), data)
    else
        TriggerServerEvent("VICE:clientIssue", data:gsub(":(.*)", ""), data)
    end
end

local function formatStackTrace(stack)
    local traces = {}
    for trace in string.gmatch(stack, "([^\n]+)\n%s*") do
        if not string.match(trace, "__newindex") and not string.match(trace, "errorHandler") and not string.match(trace, "handler") and not string.match(trace, "error.lua") then
            table.insert(traces, string.format("%s\n", trace))
        end
    end
    return table.concat(traces)
end

local function errorHandler(callback, ...)
    local success, data = xpcall(callback, function(message)
        local stack = Citizen.InvokeNative(0xD70C3BCA, nil, 0, Citizen.ResultAsString())
        if stack then
            return string.format("^1%s\n%s^7", message, formatStackTrace(stack))
        end
        return message
    end, ...)
    if not success and data then
        TriggerErrorEvent(data)
        print(data)
    end
end

local origCitizenTrace = Citizen.Trace

Citizen.Trace = function(data)
    if string.match(data, "ERROR") or string.match(data, "Error") or string.match(data, "error") then
        TriggerErrorEvent(data)
        print(data)
    end
    origCitizenTrace(data)
end

local origCitizenCreateThread = Citizen.CreateThread

Citizen.CreateThread = function(callback)
    origCitizenCreateThread(function()
        errorHandler(callback)
    end)
end

local origAddEventHandler = AddEventHandler

AddEventHandler = function(name, callback)
    return origAddEventHandler(name, function(...)
        errorHandler(callback, ...)
    end)
end

local origRegisterNetEvent = RegisterNetEvent

RegisterNetEvent = function(name, callback)
    if callback then
        return origRegisterNetEvent(name, function(...)
            errorHandler(callback, ...)
        end)
    else
        return origRegisterNetEvent(name)
    end
end
