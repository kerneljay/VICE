-- local checkInterval = 1000

-- function detectHeadshot()
--     local playerPed = PlayerPedId()

--     if IsPedShooting(playerPed) then
--         local _, hitEntity = GetEntityPlayerIsFreeAimingAt(PlayerId())

--         if hitEntity and IsPedAPlayer(hitEntity) then
--             local boneIndex = GetPedBoneIndex(hitEntity, 31086)
--             local headPosition = GetWorldPositionOfEntityBone(hitEntity, boneIndex)

--             if HasEntityBeenDamagedByWeapon(hitEntity, GetSelectedPedWeapon(playerPed), 0) then
--                 local playerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(hitEntity))
--                 TriggerServerEvent('headshot:applyDamage', playerId)
--             end
--         end
--     end
-- end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(checkInterval)
--         detectHeadshot()
--     end
-- end)


-- DecorRegister("lasthp", 3)
-- DecorRegisterLock()

-- CreateThread(function()
--     while true do
--         Wait(0)
--         if not DecorExistOn(PlayerPedId(), "lasthp") then
--             DecorSetInt(PlayerPedId(), "lasthp", GetEntityHealth(PlayerPedId(), false))
--         end
--     end
-- end)

-- AddEventHandler('gameEventTriggered', function(name, args)
--     GameEventTriggered(name, args)
-- end)

-- function GameEventTriggered(eventName, data)
--     if eventName == "CEventNetworkEntityDamage" then
--         victim = tonumber(data[1])
--         attacker = tonumber(data[2])
--         victimDied = tonumber(data[4]) == 1 and true or false
--         weaponHash = tonumber(data[5])
--         isMeleeDamage = tonumber(data[10]) ~= 0 and true or false
--         vehicleDamageTypeFlag = tonumber(data[11])
--         local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
--         local bonehash = nil
--         if FoundLastDamagedBone then
--             bonehash = tonumber(LastDamagedBone)
--         end

--         if victim == PlayerPedId() then
--             CreateThread(function()
--                 while not DecorExistOn(PlayerPedId(), "lasthp") do
--                     Wait(0)
--                 end
--                 if DecorExistOn(PlayerPedId(), "lasthp") then
--                     local nowhp = victimDied and 0 or GetEntityHealth(victim)
--                     local oldhp = DecorGetInt(victim, "lasthp")
--                     if nowhp < oldhp then
--                         TriggerServerEvent("SyncEntityDamage", nowhp, oldhp)
--                     end
--                     if victimDied then
--                         DecorRemove(victim, "lasthp")
--                     else
--                         DecorSetInt(victim, "lasthp", nowhp)
--                     end
--                 end

--                 return
--             end)
--         end
--     end
-- end
