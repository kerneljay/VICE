local gates = {
    [1] = {open = false},
    [2] = {open = false},
    [3] = {open = false},
    [4] = {open = false}
}

RegisterServerEvent("VICE:setBorderState")
AddEventHandler("VICE:setBorderState", function(gateId, state)
    if gates[gateId] then
        gates[gateId].open = (state == "open")
        TriggerClientEvent("VICE:gotBorderState", -1, gateId, state)
    end
end)

RegisterServerEvent("VICE:getGateStates")
AddEventHandler("VICE:getGateStates", function()
    local src = source
    TriggerClientEvent("VICE:gotFullBorderStates", src, gates)
end)