RegisterServerEvent('__VICE_callback:server')
AddEventHandler('__VICE_callback:server', function(eventName, ticket, ...)
	local s = source
	local p = promise.new()

	TriggerEvent('s__VICE_callback:'..eventName, function(...)
		p:resolve({...})
	end, s, ...)

	local result = Citizen.Await(p)
	TriggerClientEvent(('__VICE_callback:client:%s:%s'):format(eventName, ticket), s, table.unpack(result))
end)

VICE.RegisterServerCallback = function(eventName, fn)
    assert(type(eventName) == 'string', 'Invalid Lua type at argument #1, expected string, got '..type(eventName))
    assert(type(fn) == 'function', 'Invalid Lua type at argument #2, expected function, got '..type(fn))

    AddEventHandler(('s__VICE_callback:%s'):format(eventName), function(cb, s, ...)
        local result = {fn(s, ...)}
        cb(table.unpack(result))
    end)
end

VICE.TriggerClientCallback = function(src, eventName, ...)
    assert(type(src) == 'number', 'Invalid Lua type at argument #1, expected number, got '..type(src))
    assert(type(eventName) == 'string', 'Invalid Lua type at argument #2, expected string, got '..type(eventName))

    local p = promise.new()

    RegisterServerEvent('__VICE_callback:server:'..eventName)
    local e = AddEventHandler('__VICE_callback:server:'..eventName, function(...)
        local s = source
        if src == s then
            p:resolve({...})
        end
    end)

    TriggerClientEvent('__VICE_callback:client', src, eventName, ...)
    local result = Citizen.Await(p)
    repeat Wait(0) until result ~= nil
    RemoveEventHandler(e)
    return table.unpack(result)
end