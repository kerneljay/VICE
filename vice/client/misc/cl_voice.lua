RegisterNetEvent("VICE:mutePlayers",function(a)
    for b, c in pairs(a) do
        exports["pma-voice"]:mutePlayer(b, true)
    end
end)
RegisterNetEvent("VICE:mutePlayer",function(b)
    exports["pma-voice"]:mutePlayer(b, true)
end)
RegisterNetEvent("VICE:unmutePlayer",function(b)
    exports["pma-voice"]:mutePlayer(b, false)
end)
