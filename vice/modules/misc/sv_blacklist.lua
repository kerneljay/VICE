-- local allowedEntitySpawns = {}

-- local function grantSpawnAllowance(src, vehicles, peds, props, durationMs)
--     if not src then return end
--     allowedEntitySpawns[src] = {
--         vehicles = math.max(vehicles or 0, 0),
--         peds = math.max(peds or 0, 0),
--         props = math.max(props or 0, 0),
--         expires = GetGameTimer() + (durationMs or 4000)
--     }
-- end

-- local function consumeAllowance(src, key)
--     local data = allowedEntitySpawns[src]
--     if not data then return false end
--     if data.expires < GetGameTimer() then
--         allowedEntitySpawns[src] = nil
--         return false
--     end
--     if (data[key] or 0) <= 0 then
--         return false
--     end
--     data[key] = data[key] - 1
--     if data.vehicles <= 0 and data.peds <= 0 and data.props <= 0 then
--         allowedEntitySpawns[src] = nil
--     end
--     return true
-- end

-- AddEventHandler("VICE:allowSpawnForSource", function(src, vehicles, peds, props, durationMs)
--     grantSpawnAllowance(src, vehicles, peds, props, durationMs)
-- end)

-- RegisterNetEvent("VICE:allowTutorialSpawn")
-- AddEventHandler("VICE:allowTutorialSpawn", function()
--     local source = source
--     grantSpawnAllowance(source, 2, 2, 0, 10000)
-- end)

-- AddEventHandler('entityCreating', function(entity)
--     local entityType = GetEntityType(entity)
--     local owner = NetworkGetEntityOwner(entity)
--     if owner == 0 then
--         return -- allow server-owned entities
--     end
--     if entityType == 3 then
--         if not consumeAllowance(owner, "props") then
--             CancelEvent()
--             --("Prop spawning blocked: " .. entity)
--         end
--     end
-- end)

-- AddEventHandler('entityCreating', function(entity)
--     local entityType = GetEntityType(entity)
--     local owner = NetworkGetEntityOwner(entity)
--     if owner == 0 then
--         return -- allow server-owned entities
--     end
--     if entityType == 1 then
--         if not consumeAllowance(owner, "peds") then
--             CancelEvent()
--             --("Ped spawning blocked: " .. entity)
--         end
--     end
-- end)

--  RegisterServerEvent("VICE:spawnPersonalVehicle")
--  AddEventHandler('VICE:spawnPersonalVehicle', function(vehicle)
--      local source = source
--      grantSpawnAllowance(source, 1, 0, 0, 5000)
--      -- Your vehicle spawning logic here
--      --("Vehicle spawn allowed for player: " .. source)
--  end)

--  AddEventHandler('entityCreating', function(entity)
--      local entityType = GetEntityType(entity)
--      local source = NetworkGetEntityOwner(entity)
--      if source == 0 then
--          return -- allow server-owned entities
--      end

--      if entityType == 2 then -- 2 is the entity type for vehicles
--          if not consumeAllowance(source, "vehicles") then
--              CancelEvent()
--              --("Vehicle spawning blocked: " .. entity)
--          end
--      end
--  end)

--  AddEventHandler('ptfxEvent', function(sender, eventType, eventData)
--      if VICE.getStaffLevel(sender) <= 0 then
--          CancelEvent()
--          --("Particle effect blocked.")
--      end
--  end)

--  AddEventHandler('fireEvent', function(sender, fireData)
--      if VICE.getStaffLevel(sender) <= 0 then
--          CancelEvent()
--          --("Fire effect blocked.")
--      end
--  end)

--  AddEventHandler('explosionEvent', function(sender, event)
--      if VICE.getStaffLevel(sender) <= 0 then
--          CancelEvent()
--          --("Explosion blocked.")
--      end
--  end)
