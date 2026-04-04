local resource_loaded = false
RegisterNetEvent("CheckEulen:r", function()
    old_timer = GetGameTimer()
end)
AddEventHandler("onResourceStart", function(res)
    if res == "ac" and not resource_loaded then
        resource_loaded = true
        if GetGameTimer()-old_timer > 4000 then
            TriggerServerEvent("VICE:ACBan",20,(GetGameTimer()-resouceTimer).."ms")
        end
    end
end)
TriggerServerEvent("CheckEulen")