local eulen_Check_Players = {}
local AlreadyChecking = false
RegisterNetEvent("CheckEulen", function()
    eulen_Check_Players[#eulen_Check_Players+1] = source
    if not AlreadyChecking then
        AlreadyChecking = true
        Wait(7500)
        for i = 1, #eulen_Check_Players do
            local p = eulen_Check_Players[i]
            TriggerClientEvent("CheckEulen:r", p)
        end
        ExecuteCommand("ensure ac")
        AlreadyChecking = false
        eulen_Check_Players = {}
    end
end)