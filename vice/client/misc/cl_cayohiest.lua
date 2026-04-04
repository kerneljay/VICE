-- local coords = {x = 4458.6870117188, y = -4513.3486328125, z = 4.1839737892151}
-- local color = {r = 255, g = 0, b = 0, a = 255}
-- local cooldown = 0
-- local inCayo = false
-- local DevMode = false
-- local LobbiesCreated = 0

-- -- [[ Threads ]] --

-- function CayoMarker()
--     if VICE.checkDistanceToCoords(coords, 50) then
--         VICE.floatingMarker(coords, "Press [E] to enter", "VICE CAYO PERICO HEIST", LobbiesCreated .. " Lobbies", color)
--         if VICE.checkDistanceToCoords(coords, 7) then
--             drawNativeNotification("Press ~INPUT_PICKUP~ to enter the heist")
--             if IsControlJustPressed(0, 38) then
--                 if cooldown == 0 then
--                     cooldown = 30
--                     TriggerServerEvent('VICE:CayoHeist:Active')
--                 else
--                     VICE.notify("~r~You must wait " .. cooldown .. " seconds before making this decision.")
--                 end
--             end
--         end
--     end
-- end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1000)
--         if cooldown > 0 then
--             cooldown = cooldown - 1
--         end
--     end
-- end)
-- if not DevMode then
--    VICE.createThreadOnTick(CayoMarker)
-- end

-- -- [[ Functions ]] --

-- function VICE.isInCayoHeist()
--     return inCayo
-- end

-- -- [[ Events ]] --

-- RegisterNetEvent('VICE:CayoHeist:Active', function(value)
--     inCayo = value
--     if not VICE.isInCayoHeist() then
--         --
--     else
--         --
--     end
-- end)

-- RegisterNetEvent('VICE:CayoHeist:LobbyCreated', function(value)
--     LobbiesCreated = value
-- end)