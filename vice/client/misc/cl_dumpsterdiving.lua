RegisterNetEvent('VICE:dumpsterSearchCooldown')
AddEventHandler('VICE:dumpsterSearchCooldown', function(timeLeft)
    local minutes = math.floor(timeLeft / 60)
    local seconds = timeLeft % 60
    local aa = string.format("%d minutes, %d seconds", minutes, seconds)

    if aa == "0 minutes, 0 seconds" then
        aa = "0 seconds"
    end
    drawNativeNotification("This dumpster has been searched recently. You can search it again in " .. aa, true)
end)