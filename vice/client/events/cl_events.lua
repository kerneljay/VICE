-- -- Your existing variables
-- local easterEggLocations = {
--     vector3(183.86701965332,-674.69989013672,44.622638702393),
--     vector3(476.62857055664,-248.1383972168,53.78125),
--     vector3(995.74890136719,-353.84271240234,47.072154998779),
--     vector3(254.27734375,-660.40325927734,42.019733428955),
--     vector3(80.121841430664,-430.1764831543,37.552898406982),
--     vector3(-737.27038574219,-1109.3311767578,11.063877105713),
--     vector3(-463.41979980469,-887.0810546875,47.978786468506),
-- }

-- local cam1 = nil
-- local cam2 = nil
-- local foundEasterEgg = false
-- local isEventRunning = false
-- local selectedLocation = nil

-- -- Check if the player is near the secret location
-- function CheckSecretLocation()
--     if not selectedLocation then
--         return 
--     end

--     local playerPed = PlayerPedId()
--     local playerCoords = GetEntityCoords(playerPed)

--     if not foundEasterEgg and Vdist(playerCoords, selectedLocation) < 10.0 then
--         foundEasterEgg = true
--         VICE.notify("~g~You found the secret location! Enjoy your prize!")
--         tVICE.announceMpSmallMsg("~y~YOU FOUND THE LOCATION!", "~b~Your prize has been given to you!", 5, 15000) 
--         PerformAnimation(playerPed)
--         Wait(5000)
--         ClearPedTasks(playerPed)
--         ResetEvent()
--     end
-- end

-- -- Play the air guitar animation
-- function PerformAnimation(playerPed)
--     VICE.loadAnimDict("anim@mp_player_intcelebrationfemale@air_guitar")
--     TaskPlayAnim(
--         playerPed,
--         "anim@mp_player_intcelebrationfemale@air_guitar",
--         "air_guitar",
--         8.0,
--         -8.0,
--         -1,
--         0,
--         0.0,
--         false,
--         false,
--         false
--     )
-- end

-- -- Check the secret location every second if the event is running
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1000)

--         if isEventRunning then
--             CheckSecretLocation()
--         end
--     end
-- end)

-- -- Load the collision data for the selected location
-- function LoadCollisionDataForLocation()
--     if not selectedLocation then
--         return
--     end

--     RequestCollisionAtCoord(selectedLocation.x, selectedLocation.y, selectedLocation.z)
-- end

-- -- Reset the event state
-- function ResetEvent()
--     isEventRunning = false
--     foundEasterEgg = false
--     selectedLocation = nil
--     cam1 = nil
--     cam2 = nil
-- end

-- -- Start the event
-- RegisterCommand('event', function(source, rawCommand)
--     if foundEasterEgg then
--         VICE.notify("~r~You already found the secret. Try again next restart!")
--     elseif isEventRunning then
--         VICE.notify("~r~You haven't found the current location yet!")
--     else
--         isEventRunning = true
--         foundEasterEgg = false
--         VICE.notify("~y~Find the secret location and earn a prize!")

--         local playerPed = PlayerPedId()

--         local randomIndex = math.random(1, #easterEggLocations)
--         selectedLocation = easterEggLocations[randomIndex]

--         LoadCollisionDataForLocation()


--         local cam1Pos = selectedLocation + vector3(-10.0, 0.0, 5.0) 
--         local cam1Rot = GetCamRot(playerPed, 2)

--         cam1 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam1Pos, cam1Rot, 60.0, true, 0)
--         PointCamAtCoord(cam1, selectedLocation) 

--         RenderScriptCams(true, true, 1000, true, true)

--         local startTime = GetGameTimer()
--         while GetGameTimer() - startTime < 5000 do
--             local newCam1Pos = cam1Pos + vector3(0.0, 0.0, 5.0)
--             local newCam1Rot = GetCamRot(playerPed, 2)
--             SetCamCoord(cam1, newCam1Pos)
--             SetCamRot(cam1, newCam1Rot, 2)

--             Citizen.Wait(0)
--         end

--         local cam2Pos = selectedLocation + vector3(0.0, 0.0, 100.0) 
--         local cam2Rot = vector3(-90.0, 0.0, 0.0)
--         cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam2Pos, cam2Rot, 60.0, true, 0)
--         PointCamAtCoord(cam2, selectedLocation) 

--         startTime = GetGameTimer()
--         while GetGameTimer() - startTime < 5000 do 
--             RenderScriptCams(true, false, 0, true, true)
--             Citizen.Wait(0)
--         end

--         ExecuteCommand("e c")
--         ExecuteCommand("showui")
--         RenderScriptCams(false, false, 0, true, true)
--         DestroyCam(cam1, false)
--         DestroyCam(cam2, false)
--     end
-- end)
