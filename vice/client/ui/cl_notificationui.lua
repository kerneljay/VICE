local a = {
    ["top-left"] = {top = 10, right = 1450},
    ["bottom-left"] = {top = 1000, right = 1450},
    ["top-right"] = {top = 10, right = 10},
    ["bottom-right"] = {top = 1000, right = 10}
}
local b = {["success"] = "fas fa-check", ["bad"] = "fas fa-times"}

-- Add notification cooldown system with longer cooldown
local lastNotificationTime = 0
local notificationCooldown = 5000 -- 5 second cooldown for wallet notifications

local function c(d, e)
    -- More aggressive filtering for wallet notifications
    if d and d.text and (string.find(string.lower(d.text), "wallet") or string.find(string.lower(d.text), "money")) then
        local currentTime = GetGameTimer()
        if currentTime - lastNotificationTime < notificationCooldown then
            return -- Skip notification if within cooldown
        end
        lastNotificationTime = currentTime
    end
    
    SendNUIMessage({show = true, options = d, pos = a[d.pos], icon = b[d.icon] or ""})
    Citizen.Wait(e or 15000)
    SendNUIMessage({show = false, options = d})
end

RegisterNetEvent("VICE:showNotification", function(d, e)
    c(d, e)
end)