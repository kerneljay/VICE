-- -- lamar drives into the wall but yeah working still made ofc from btf :)
-- local CUTSCENE_NAME = "mp_intro_concat"
-- local TUTORIAL_KVP = "vice_tutorial_intro_done"
-- local INTRO_STREAM_POS = vector3(-1035.95, -2734.62, 13.76)

-- local DRIVE_START = vector4(-1029.6437988281, -2720.0109863281, 13.802932739258, 326.0)
-- local SIMEONS_DROP = vector4(-29.35221862793, -1089.1497802734, 25.943387985229, 72.0)
-- local SIMEONS_DROP_RADIUS = 18.0
-- local CITY_HALL = vector3(-532.92028808594, -189.90745544434, 38.219657897949)
-- local TUTORIAL_CLOTHING = vector3(127.58757019043, -1038.0096435547, 29.432479858398)
-- local LAMAR_DRIVE_SPEED = 55.0
-- local LAMAR_DRIVE_STYLE = 1074528293

-- local TUTORIAL_CAR_MODEL = `emperor`
-- local LAMAR_MODEL = `ig_lamardavis`
-- local CUTSCENE_MAX_MS = 120000
-- local TUTORIAL_STAGE_KVP = "vice_tutorial_flow_stage"

-- local tutorialRunning = false
-- local tutorialSpawnResponse = nil
-- local tutorialDriveControllerActive = false
-- local tutorialStage = 0
-- local tutorialSpawnCheckSent = false

-- local function setTutorialStage(stage)
--     tutorialStage = stage
--     SetResourceKvpInt(TUTORIAL_STAGE_KVP, stage)

--     if stage == 1 then
--         SetNewWaypoint(SIMEONS_DROP.x, SIMEONS_DROP.y)
--         VICE.notify("~b~Tutorial: ~w~Buy your first car at Simeons.")
--     elseif stage == 2 then
--         SetNewWaypoint(CITY_HALL.x, CITY_HALL.y)
--         VICE.notify("~b~Tutorial: ~w~Go grab a license at City Hall.")
--     elseif stage == 3 then
--         SetNewWaypoint(TUTORIAL_CLOTHING.x, TUTORIAL_CLOTHING.y)
--         VICE.notify("~b~Tutorial: ~w~Go change your outfit at the clothing store.")
--     else
--         VICE.notify("~g~Tutorial complete.")
--     end
-- end

-- local function safeNative(fn, ...)
--     if type(fn) == "function" then
--         return pcall(fn, ...)
--     end
--     return false
-- end

-- local function showLamarRideScaleform(durationMs)
--     local sf = Scaleform("MIDSIZED_MESSAGE")
--     sf.RunFunction("SHOW_SHARD_MIDSIZED_MESSAGE", {
--         "LAMAR",
--         "I will drop you at Simeons so you can get your first car.",
--         21,
--         true,
--         true
--     })

--     local timeout = GetGameTimer() + (durationMs or 12000)
--     CreateThread(function()
--         while GetGameTimer() < timeout do
--             sf.Render2D()
--             Wait(0)
--         end
--     end)
-- end

-- local function ensureTutorialMalePreset(presetName)
--     local model = `mp_m_freemode_01`
--     RequestModel(model)
--     local timeout = GetGameTimer() + 10000
--     while not HasModelLoaded(model) and GetGameTimer() < timeout do
--         Wait(0)
--     end

--     if HasModelLoaded(model) then
--         SetPlayerModel(PlayerId(), model)
--         SetModelAsNoLongerNeeded(model)
--         Wait(50)
--         SetPedDefaultComponentVariation(PlayerPedId())
--     end
-- end

-- local function waitForDecorReady(timeoutMs)
--     local timeout = GetGameTimer() + (timeoutMs or 12000)
--     while GetGameTimer() < timeout do
--         if decor and DecorIsRegisteredAsType(decor, 3) then
--             return true
--         end
--         Wait(0)
--     end
--     return false
-- end

-- local function loadModel(model)
--     if not IsModelInCdimage(model) then
--         return false
--     end

--     RequestModel(model)
--     local timeout = GetGameTimer() + 10000
--     while not HasModelLoaded(model) do
--         Wait(0)
--         if GetGameTimer() > timeout then
--             return false
--         end
--     end
--     return true
-- end

-- local function prewarmIntroScene()
--     RequestCollisionAtCoord(INTRO_STREAM_POS.x, INTRO_STREAM_POS.y, INTRO_STREAM_POS.z)
--     SetFocusPosAndVel(INTRO_STREAM_POS.x, INTRO_STREAM_POS.y, INTRO_STREAM_POS.z + 20.0, 0.0, 0.0, 0.0)
--     NewLoadSceneStartSphere(INTRO_STREAM_POS.x, INTRO_STREAM_POS.y, INTRO_STREAM_POS.z, 220.0, 2)

--     local timeout = GetGameTimer() + 10000
--     while GetGameTimer() < timeout do
--         Wait(0)
--         if IsNewLoadSceneLoaded() and GetNumberOfStreamingRequests() == 0 then
--             break
--         end
--     end

--     NewLoadSceneStop()
-- end

-- local function playIntroCutscene()
--     prewarmIntroScene()
--     ensureTutorialMalePreset()

--     local timeout = GetGameTimer() + 15000
--     while not HasCutsceneLoaded() do
--         RequestCutsceneWithPlaybackList(CUTSCENE_NAME, 31, 8)
--         Wait(0)
--         if GetGameTimer() > timeout then
--             return false
--         end
--     end

--     if IsScreenFadedOut() then
--         DoScreenFadeIn(800)
--         while not IsScreenFadedIn() do
--             Wait(0)
--         end
--     end

--     StartCutscene(4)
--     local started = false
--     local startTimeout = GetGameTimer() + 5000
--     while GetGameTimer() < startTimeout do
--         Wait(0)
--         if IsCutscenePlaying() then
--             started = true
--             break
--         end
--     end

--     if not started then
--         RemoveCutscene()
--         return false
--     end

--     local cutsceneTimeout = GetGameTimer() + CUTSCENE_MAX_MS
--     while IsCutscenePlaying() do
--         Wait(0)
--         if GetGameTimer() > cutsceneTimeout then
--             StopCutsceneImmediately()
--             break
--         end
--     end

--     RemoveCutscene()
--     ClearFocus()
--     SetPlayerControl(PlayerId(), true, 0)
--     return true
-- end

-- local function waitForCollisionAtCoord(x, y, z, timeoutMs)
--     local playerPed = PlayerPedId()
--     RequestCollisionAtCoord(x, y, z)
--     NewLoadSceneStartSphere(x, y, z, 80.0, 2)

--     local timeout = GetGameTimer() + timeoutMs
--     while GetGameTimer() < timeout do
--         Wait(0)
--         if HasCollisionLoadedAroundEntity(playerPed) then
--             break
--         end
--     end

--     NewLoadSceneStop()
-- end

-- local function waitForNetEntity(netId, timeoutMs)
--     if not netId or netId == 0 then
--         return 0
--     end

--     local timeout = GetGameTimer() + timeoutMs
--     while GetGameTimer() < timeout do
--         if NetworkDoesNetworkIdExist(netId) then
--             local entity = NetworkGetEntityFromNetworkId(netId)
--             if entity and entity ~= 0 and DoesEntityExist(entity) then
--                 return entity
--             end
--         end
--         Wait(0)
--     end

--     return 0
-- end

-- local function claimEntityControl(entity, timeoutMs)
--     if not entity or entity == 0 or not DoesEntityExist(entity) then
--         return false
--     end

--     local timeout = GetGameTimer() + (timeoutMs or 2500)
--     while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
--         NetworkRequestControlOfEntity(entity)
--         Wait(0)
--     end
--     return NetworkHasControlOfEntity(entity)
-- end

-- local function markEntityAntiCheatSafe(entity)
--     if not entity or entity == 0 or not DoesEntityExist(entity) then
--         return
--     end

--     local hasControl = claimEntityControl(entity, 3000)
--     if hasControl and entity ~= 0 and DoesEntityExist(entity) then
--         safeNative(SetEntityAsMissionEntity, entity, true, true)
--     end
--     if decor then
--         if entity ~= 0 and DoesEntityExist(entity) then
--             safeNative(DecorSetInt, entity, decor, 955)
--         end
--     end

--     if entity ~= 0 and DoesEntityExist(entity) and NetworkGetEntityIsNetworked(entity) then
--         local netId = NetworkGetNetworkIdFromEntity(entity)
--         if netId and netId ~= 0 then
--             safeNative(SetNetworkIdCanMigrate, netId, true)
--             safeNative(SetNetworkIdExistsOnAllMachines, netId, true)
--         end
--     end
-- end

-- local function forcePedIntoVehicleSeat(ped, vehicle, seat, timeoutMs)
--     if not ped or ped == 0 or not DoesEntityExist(ped) then
--         return false
--     end
--     if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
--         return false
--     end

--     local timeout = GetGameTimer() + (timeoutMs or 6000)
--     while GetGameTimer() < timeout do
--         if not DoesEntityExist(ped) or not DoesEntityExist(vehicle) then
--             return false
--         end
--         NetworkRequestControlOfEntity(vehicle)
--         NetworkRequestControlOfEntity(ped)
--         safeNative(SetVehicleDoorsLocked, vehicle, 1)
--         safeNative(SetVehicleDoorsLockedForAllPlayers, vehicle, false)
--         safeNative(SetPedIntoVehicle, ped, vehicle, seat)
--         safeNative(TaskWarpPedIntoVehicle, ped, vehicle, seat)
--         Wait(0)
--         if IsPedInVehicle(ped, vehicle, false) and GetPedInVehicleSeat(vehicle, seat) == ped then
--             return true
--         end
--     end
--     return false
-- end

-- local function playFallbackIntroCamera()
--     local playerPed = PlayerPedId()
--     FreezeEntityPosition(playerPed, true)
--     SetEntityVisible(playerPed, false, false)

--     local camA = CreateCameraWithParams(
--         "DEFAULT_SCRIPTED_CAMERA",
--         -1029.0, -2747.0, 55.0,
--         -12.0, 0.0, 38.0,
--         60.0, false, 2
--     )
--     local camB = CreateCameraWithParams(
--         "DEFAULT_SCRIPTED_CAMERA",
--         -1005.0, -2685.0, 42.0,
--         -8.0, 0.0, 145.0,
--         60.0, false, 2
--     )

--     SetCamActive(camA, true)
--     RenderScriptCams(true, true, 500, true, true)
--     DoScreenFadeIn(800)
--     Wait(3200)
--     SetCamActiveWithInterp(camB, camA, 3200, 0, 0)
--     Wait(3600)
--     DoScreenFadeOut(450)
--     while not IsScreenFadedOut() do
--         Wait(0)
--     end

--     RenderScriptCams(false, true, 500, true, true)
--     DestroyCam(camA, false)
--     DestroyCam(camB, false)
--     SetEntityVisible(playerPed, true, false)
--     FreezeEntityPosition(playerPed, false)
-- end

-- local function startLamarDrive()
--     local playerPed = PlayerPedId()
--     local spawnedByServer = false
--     local reachedDrop = false

--     SetEntityCoordsNoOffset(playerPed, DRIVE_START.x, DRIVE_START.y, DRIVE_START.z, false, false, false)
--     SetEntityHeading(playerPed, DRIVE_START.w)
--     waitForCollisionAtCoord(DRIVE_START.x, DRIVE_START.y, DRIVE_START.z, 8000)
--     waitForDecorReady(12000)

--     if not loadModel(TUTORIAL_CAR_MODEL) then
--         return false
--     end
--     if not loadModel(LAMAR_MODEL) then
--         return false
--     end

--     local car, lamar = 0, 0

    
--     TriggerServerEvent("VICE:allowTutorialSpawn")
--     Wait(200)
--     for _ = 1, 3 do
--         car = CreateVehicle(TUTORIAL_CAR_MODEL, DRIVE_START.x, DRIVE_START.y, DRIVE_START.z, DRIVE_START.w, true, true)
--         if car and car ~= 0 then
--             lamar = CreatePed(4, LAMAR_MODEL, DRIVE_START.x, DRIVE_START.y, DRIVE_START.z, DRIVE_START.w, true, true)
--             if lamar and lamar ~= 0 then
--                 break
--             end
--             if DoesEntityExist(car) then safeNative(DeleteEntity, car) end
--             car = 0
--         end
--         Wait(150)
--     end


--     if car == 0 or lamar == 0 then
--         for _ = 1, 3 do
--             tutorialSpawnResponse = nil
--             TriggerServerEvent("VICE:spawnTutorialDriveEntities")
--             local responseTimeout = GetGameTimer() + 10000
--             while not tutorialSpawnResponse and GetGameTimer() < responseTimeout do
--                 Wait(0)
--             end

--             if tutorialSpawnResponse and tutorialSpawnResponse.vehicleNet ~= 0 and tutorialSpawnResponse.pedNet ~= 0 then
--                 car = waitForNetEntity(tutorialSpawnResponse.vehicleNet, 20000)
--                 lamar = waitForNetEntity(tutorialSpawnResponse.pedNet, 20000)
--                 if car ~= 0 then markEntityAntiCheatSafe(car) end
--                 if lamar ~= 0 then markEntityAntiCheatSafe(lamar) end
--                 spawnedByServer = car ~= 0 and lamar ~= 0
--                 if spawnedByServer then
--                     break
--                 end
--             end
--             TriggerServerEvent("VICE:cleanupTutorialDriveEntities")
--             Wait(300)
--         end
--     end

--     if car == 0 or lamar == 0 then
--         SetModelAsNoLongerNeeded(TUTORIAL_CAR_MODEL)
--         SetModelAsNoLongerNeeded(LAMAR_MODEL)
--         TriggerServerEvent("VICE:cleanupTutorialDriveEntities")
--         return false
--     end

--     SetModelAsNoLongerNeeded(TUTORIAL_CAR_MODEL)

--     markEntityAntiCheatSafe(car)
--     markEntityAntiCheatSafe(lamar)
--     forcePedIntoVehicleSeat(lamar, car, -1, 5000)
--     SetDriverAbility(lamar, 1.0)
--     SetDriverAggressiveness(lamar, 1.0)
--     SetPedCanBeDraggedOut(lamar, false)
--     SetBlockingOfNonTemporaryEvents(lamar, true)

--     local function getFreePassengerSeat(vehicle)
--         local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
--         for seat = 0, maxPassengers - 1 do
--             if IsVehicleSeatFree(vehicle, seat) then
--                 return seat
--             end
--         end
--         return nil
--     end

--     local function forceSeatPlayer(vehicle)
--         local seat = getFreePassengerSeat(vehicle)
--         if not seat then
--             return false
--         end

--         FreezeEntityPosition(playerPed, false)
--         ClearPedTasksImmediately(playerPed)
--         SetEntityCollision(playerPed, true, true)
--         TriggerServerEvent("VICE:forceTutorialSeat")

--         local seatTimeout = GetGameTimer() + 9000
--         while GetGameTimer() < seatTimeout do
--             if forcePedIntoVehicleSeat(playerPed, vehicle, seat, 900) then
--                 return true
--             end

--             TriggerServerEvent("VICE:forceTutorialSeat")
--             TaskEnterVehicle(playerPed, vehicle, 1500, seat, 2.0, 1, 0)
--             Wait(150)
--             if IsPedInVehicle(playerPed, vehicle, false) then
--                 return true
--             end
--         end

        
--         local vehCoords = GetEntityCoords(vehicle)
--         SetEntityCoordsNoOffset(playerPed, vehCoords.x + 1.0, vehCoords.y, vehCoords.z + 0.2, false, false, false)
--         Wait(100)
--         local hardTimeout = GetGameTimer() + 3000
--         while GetGameTimer() < hardTimeout do
--             TriggerServerEvent("VICE:forceTutorialSeat")
--             SetPedIntoVehicle(playerPed, vehicle, seat)
--             TaskWarpPedIntoVehicle(playerPed, vehicle, seat)
--             Wait(0)
--             if IsPedInVehicle(playerPed, vehicle, false) then
--                 return true
--             end
--         end

--         return false
--     end

--     local inPassenger = forceSeatPlayer(car)
--     if not inPassenger then
--         TriggerServerEvent("VICE:cleanupTutorialDriveEntities")
--         return false
--     end

--     showLamarRideScaleform(15000)
--     if spawnedByServer then
--         TriggerServerEvent("VICE:startTutorialDrive")
--     else
        
--         safeNative(SetVehicleEngineOn, car, true, true, false)
--         safeNative(SetVehicleUndriveable, car, false)
--         safeNative(SetVehicleHandbrake, car, false)
--         safeNative(SetBlockingOfNonTemporaryEvents, lamar, true)
--         safeNative(SetPedKeepTask, lamar, true)
--         safeNative(TaskVehicleDriveToCoordLongrange,
--             lamar,
--             car,
--             SIMEONS_DROP.x,
--             SIMEONS_DROP.y,
--             SIMEONS_DROP.z,
--             LAMAR_DRIVE_SPEED,
--             LAMAR_DRIVE_STYLE,
--             12.0
--         )
--     end

--     if IsScreenFadedOut() then
--         DoScreenFadeIn(800)
--         while not IsScreenFadedIn() do
--             Wait(0)
--         end
--     end

--     local travelTimeout = GetGameTimer() + 180000
--     while DoesEntityExist(car) and DoesEntityExist(lamar) do
--         Wait(0)
--         if not DoesEntityExist(car) or not DoesEntityExist(lamar) then
--             break
--         end
--         DisableControlAction(0, 75, true)
--         DisableControlAction(27, 75, true)
--         if #(GetEntityCoords(car) - vector3(SIMEONS_DROP.x, SIMEONS_DROP.y, SIMEONS_DROP.z)) < SIMEONS_DROP_RADIUS then
--             reachedDrop = true
--             break
--         end
--         if GetGameTimer() > travelTimeout then
--             break
--         end
--     end

--     if not DoesEntityExist(car) or not DoesEntityExist(lamar) then
--         if spawnedByServer then
--             TriggerServerEvent("VICE:cleanupTutorialDriveEntities")
--         end
--         return false
--     end

--     ClearPedTasks(lamar)
--     TaskVehicleTempAction(lamar, car, 27, 1200)
--     Wait(300)
--     TaskLeaveVehicle(playerPed, car, 0)

--     local leaveTimeout = GetGameTimer() + 8000
--     while IsPedInVehicle(playerPed, car, false) and GetGameTimer() < leaveTimeout do
--         Wait(0)
--     end

--     SetEntityCoordsNoOffset(playerPed, SIMEONS_DROP.x, SIMEONS_DROP.y, SIMEONS_DROP.z, false, false, false)
--     SetEntityHeading(playerPed, SIMEONS_DROP.w)

--     if spawnedByServer then
--         TriggerServerEvent("VICE:cleanupTutorialDriveEntities")
--     else
--         safeNative(SetVehicleDoorsLocked, car, 2)
--         safeNative(SetEntityAsNoLongerNeeded, car)
--         safeNative(SetEntityAsNoLongerNeeded, lamar)
--         safeNative(DeleteEntity, lamar)
--         safeNative(DeleteEntity, car)
--     end

--     return true
-- end

-- RegisterNetEvent("VICE:tutorialEntitiesSpawned")
-- AddEventHandler("VICE:tutorialEntitiesSpawned", function(vehicleNet, pedNet)
--     tutorialSpawnResponse = {
--         vehicleNet = vehicleNet or 0,
--         pedNet = pedNet or 0
--     }
--     if tutorialSpawnResponse.vehicleNet ~= 0 and NetworkDoesNetworkIdExist(tutorialSpawnResponse.vehicleNet) then
--         local veh = NetworkGetEntityFromNetworkId(tutorialSpawnResponse.vehicleNet)
--         markEntityAntiCheatSafe(veh)
--     end
--     if tutorialSpawnResponse.pedNet ~= 0 and NetworkDoesNetworkIdExist(tutorialSpawnResponse.pedNet) then
--         local ped = NetworkGetEntityFromNetworkId(tutorialSpawnResponse.pedNet)
--         markEntityAntiCheatSafe(ped)
--     end
-- end)

-- RegisterNetEvent("VICE:forceTutorialSeatClient")
-- AddEventHandler("VICE:forceTutorialSeatClient", function(vehicleNet)
--     if not vehicleNet or vehicleNet == 0 then
--         return
--     end

--     CreateThread(function()
--         local playerPed = PlayerPedId()
--         local vehicle = 0
--         local timeout = GetGameTimer() + 5000
--         while GetGameTimer() < timeout do
--             if NetworkDoesNetworkIdExist(vehicleNet) then
--                 vehicle = NetworkGetEntityFromNetworkId(vehicleNet)
--                 if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
--                     break
--                 end
--             end
--             Wait(0)
--         end

--         if vehicle == 0 or not DoesEntityExist(vehicle) then
--             return
--         end

--         if forcePedIntoVehicleSeat(playerPed, vehicle, 0, 7000) then return end
--         forcePedIntoVehicleSeat(playerPed, vehicle, 1, 2000)
--     end)
-- end)

-- RegisterNetEvent("VICE:startTutorialDriveClient")
-- AddEventHandler("VICE:startTutorialDriveClient", function(vehicleNet, pedNet, endX, endY, endZ)
--     if not vehicleNet or vehicleNet == 0 or not pedNet or pedNet == 0 then
--         return
--     end

--     if tutorialDriveControllerActive then
--         return
--     end
--     tutorialDriveControllerActive = true

--     CreateThread(function()
--         local car = waitForNetEntity(vehicleNet, 12000)
--         local lamar = waitForNetEntity(pedNet, 12000)
--         if car == 0 or lamar == 0 then
--             tutorialDriveControllerActive = false
--             return
--         end

--         markEntityAntiCheatSafe(car)
--         markEntityAntiCheatSafe(lamar)
--         SetVehicleEngineOn(car, true, true, false)
--         SetVehicleUndriveable(car, false)
--         SetVehicleHandbrake(car, false)
--         SetDriverAbility(lamar, 1.0)
--         SetDriverAggressiveness(lamar, 1.0)
--         SetBlockingOfNonTemporaryEvents(lamar, true)
--         SetPedKeepTask(lamar, true)

--         forcePedIntoVehicleSeat(lamar, car, -1, 3000)

--         if not IsPedInVehicle(PlayerPedId(), car, false) then
--             TriggerEvent("VICE:forceTutorialSeatClient", vehicleNet)
--         end

--         local stalledMs = 0
--         local runUntil = GetGameTimer() + 180000
--         safeNative(TaskVehicleDriveToCoordLongrange,
--             lamar,
--             car,
--             endX,
--             endY,
--             endZ,
--             LAMAR_DRIVE_SPEED,
--             LAMAR_DRIVE_STYLE,
--             12.0)

--         while GetGameTimer() < runUntil do
--             Wait(250)
--             if not DoesEntityExist(car) or not DoesEntityExist(lamar) then
--                 break
--             end

--             if #(GetEntityCoords(car) - vector3(endX, endY, endZ)) < 16.0 then
--                 break
--             end

--             if GetPedInVehicleSeat(car, -1) ~= lamar then
--                 forcePedIntoVehicleSeat(lamar, car, -1, 1000)
--             end

        
--             safeNative(SetVehicleEngineOn, car, true, true, false)
--             safeNative(SetVehicleUndriveable, car, false)
--             safeNative(SetVehicleHandbrake, car, false)
--             safeNative(SetDriveTaskDrivingStyle, lamar, LAMAR_DRIVE_STYLE)
--             safeNative(SetDriveTaskCruiseSpeed, lamar, LAMAR_DRIVE_SPEED)
--             safeNative(SetDriverAbility, lamar, 1.0)
--             safeNative(SetDriverAggressiveness, lamar, 1.0)
--             safeNative(SetBlockingOfNonTemporaryEvents, lamar, true)

--             local speed = GetEntitySpeed(car)
--             if speed < 1.2 then
--                 stalledMs = stalledMs + 250
--             else
--                 stalledMs = 0
--             end

        
--             if stalledMs >= 1500 then
--                 safeNative(TaskVehicleDriveToCoordLongrange,
--                     lamar,
--                     car,
--                     endX,
--                     endY,
--                     endZ,
--                     LAMAR_DRIVE_SPEED,
--                     LAMAR_DRIVE_STYLE,
--                     12.0)
--                 if #(GetEntityCoords(car) - vector3(endX, endY, endZ)) > 25.0 then
--                     safeNative(SetVehicleForwardSpeed, car, 8.0)
--                 end
--                 stalledMs = 0
--             end
--         end

--         tutorialDriveControllerActive = false
--     end)
-- end)

-- RegisterNetEvent("VICE:sendTutorialThingy")
-- AddEventHandler("VICE:sendTutorialThingy", function(shouldRun)
--     local runTutorial = false
--     local requestedGender = nil
--     local requestedPreset = nil

--     if type(shouldRun) == "table" then
--         runTutorial = shouldRun.run == true
--         requestedGender = shouldRun.gender
--         requestedPreset = shouldRun.preset
--     else
--         runTutorial = shouldRun == true
--     end

--     if not runTutorial or tutorialRunning then
--         return
--     end

--     if requestedGender and requestedGender ~= "male" then
--         return
--     end

--     if GetResourceKvpInt(TUTORIAL_KVP) == 1 then
--         return
--     end

--     tutorialRunning = true
--     CreateThread(function()
--         TriggerServerEvent("VICE:setTutorialRoutingBucket")
--         if IsCutscenePlaying() then
--             StopCutsceneImmediately()
--             RemoveCutscene()
--             Wait(300)
--         end
--         ensureTutorialMalePreset(requestedPreset)
--         ExecuteCommand("hideui")
--         DoScreenFadeOut(350)
--         while not IsScreenFadedOut() do
--             Wait(0)
--         end

--         local cutsceneOk = playIntroCutscene()
--         if not cutsceneOk then
--             playFallbackIntroCamera()
--         end
--         DoScreenFadeOut(350)
--         while not IsScreenFadedOut() do
--             Wait(0)
--         end

--         local driveOk = startLamarDrive()
--         if IsScreenFadedOut() then
--             DoScreenFadeIn(600)
--         end

--         SetResourceKvpInt(TUTORIAL_KVP, 1)
--         TriggerServerEvent("VICE:refreshSimeonsPermissions")
--         setTutorialStage(1)

--         if cutsceneOk and driveOk then
--             VICE.notify("~g~Lamar dropped you off. Buy your first vehicle at Simeons.")
--         else
--             VICE.notify("~y~Tutorial fallback used. Head to Simeons to get your first vehicle.")
--         end

--         ExecuteCommand("showui")
--         tutorialRunning = false
--     end)
-- end)

-- RegisterNetEvent("VICE:playTutorial")
-- AddEventHandler("VICE:playTutorial", function()
--     TriggerEvent("VICE:sendTutorialThingy", true)
-- end)

-- AddEventHandler("playerSpawned", function()
--     if tutorialSpawnCheckSent then
--         return
--     end
--     tutorialSpawnCheckSent = true

--     CreateThread(function()
--         while not NetworkIsSessionStarted() do
--             Wait(500)
--         end
--         Wait(1500)
--         TriggerServerEvent("VICE:checkTutorial")
--     end)
-- end)

-- RegisterCommand("retutorial", function()
--     SetResourceKvpInt(TUTORIAL_KVP, 0)
--     SetResourceKvpInt(TUTORIAL_STAGE_KVP, 0)
--     TriggerServerEvent("VICE:resetTutorialRoutingBucket")
--     TriggerEvent("VICE:sendTutorialThingy", true)
-- end)

-- RegisterCommand("testintrocs", function()
--     local ok = playIntroCutscene()
--     if ok then
--         VICE.notify("~g~mp_intro_concat played.")
--     else
--         VICE.notify("~r~mp_intro_concat failed to start on this client.")
--     end
-- end)

-- RegisterCommand("testtutorialcar", function()
--     local ok = startLamarDrive()
--     if ok then
--         VICE.notify("~g~Tutorial car drive started.")
--     else
--         VICE.notify("~r~Tutorial car/driver failed to spawn.")
--     end
-- end)

-- RegisterNetEvent("VICE:tutorialSimeonsVehiclePurchased")
-- AddEventHandler("VICE:tutorialSimeonsVehiclePurchased", function()
--     if tutorialStage == 1 then
--         setTutorialStage(2)
--     end
-- end)

-- RegisterNetEvent("VICE:tutorialLicenseBought")
-- AddEventHandler("VICE:tutorialLicenseBought", function()
--     if tutorialStage == 2 then
--         setTutorialStage(3)
--     end
-- end)

-- CreateThread(function()
--     tutorialStage = GetResourceKvpInt(TUTORIAL_STAGE_KVP) or 0
--     Wait(3000)
--     if tutorialStage == 1 or tutorialStage == 2 or tutorialStage == 3 then
--         setTutorialStage(tutorialStage)
--     end
--     while true do
--         Wait(1000)
--         if tutorialStage == 3 then
--             local ped = PlayerPedId()
--             local coords = GetEntityCoords(ped)
--             if #(coords - TUTORIAL_CLOTHING) <= 12.0 then
--                 TriggerServerEvent("VICE:setCompletedTutorial")
--                 TriggerServerEvent("VICE:resetTutorialRoutingBucket")
--                 setTutorialStage(0)
--                 VICE.notify("~g~Tutorial complete.")
--             end
--         end
--     end
-- end)
-- -- CreateThread(function()
-- --     tutorialStage = GetResourceKvpInt(TUTORIAL_STAGE_KVP) or 0
-- --     Wait(3000)
-- --     if tutorialStage == 1 or tutorialStage == 2 or tutorialStage == 3 then
-- --         setTutorialStage(tutorialStage)
-- --     end
-- --     while true do
-- --         Wait(1000)
-- --         if tutorialStage == 3 then
-- --             local ped = PlayerPedId()
-- --             local coords = GetEntityCoords(ped)
-- --             if #(coords - TUTORIAL_CLOTHING) <= 12.0 then
-- --                 TriggerServerEvent("VICE:setCompletedTutorial")
-- --                 TriggerServerEvent("VICE:resetTutorialRoutingBucket")
-- --                 setTutorialStage(0)
-- --                 VICE.notify("~g~Tutorial complete.")
-- --             end
-- --         end
-- --     end
-- -- end)


-- AddEventHandler('VICE:onClientSpawn', function (user_id, firstspawn)
--     if firstspawn then 
--         Wait(5000)
--         tVICE.teleport(-44.377208709717,-1112.5909423828,26.438020706177)
--     end 
    
-- end)
