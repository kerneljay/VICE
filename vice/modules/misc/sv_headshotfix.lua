-- local maxDistance = 50.0

-- RegisterNetEvent('headshot:applyDamage')
-- AddEventHandler('headshot:applyDamage', function(playerId)
--     local src = source
--     local ped = GetPlayerPed(GetPlayerFromServerId(playerId))
--     local shooterPed = GetPlayerPed(GetPlayerFromServerId(src))

--     if ped and shooterPed and DoesEntityExist(ped) and DoesEntityExist(shooterPed) then
--         local health = GetEntityHealth(ped)

--         if health > 0 then
--             local shooterCoords = GetEntityCoords(shooterPed)
--             local targetCoords = GetEntityCoords(ped)
--             local distance = #(shooterCoords - targetCoords)

--             if distance <= maxDistance then
--                 local headshotDamage = 100
--                 local newHealth = math.max(health - headshotDamage, 0)

--                 if newHealth <= 0 then
--                     print("headshotted")
--                 end

--                 SetEntityHealth(ped, newHealth)

--                 if newHealth <= 0 then
--                     SetEntityHealth(ped, 0)
--                     local playerName = GetPlayerName(GetPlayerFromServerId(playerId))
--                     print('youve been headshotted')
--                 end
--             else
--                 print("too far")
--             end
--         end
--     end
-- end)


-- RegisterServerEvent("SyncEntityDamage")
-- AddEventHandler('SyncEntityDamage', function(nowhp, oldhp)
--     TriggerClientEvent('OnEntityHealthChange', -1, source, nowhp, oldhp)
-- end)
