local WentParachuting = false -- Go Paracuting
local UsedItem = false -- Rift
local ParachutingLocations = {vector3(-753.74310302734, -1510.6815185547, 5.0141487121582),vector3(-2648.1313476562,-1499.6420898438,6.8074750900269),vector3(-2156.9946289062,5138.7290039062,2.8100011348724)} -- VIP

-- [[ Functions ]] --

function DisplayHelpText(b)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(b)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function goParachuting()
    if not WentParachuting then
        WentParachuting = true
        CreateThread(function()
            VICE.allowWeapon("GADGET_PARACHUTE")
            GiveWeaponToPed(PlayerPedId(), "GADGET_PARACHUTE")
            DoScreenFadeOut(3000)
            while not IsScreenFadedOut() do
                Wait(0)
            end
            local PlayerCoords = GetEntityCoords(VICE.getPlayerPed())
            SetEntityCoords(VICE.getPlayerPed(), PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1000.0)
            DoScreenFadeIn(2000)
            Wait(2000)
            SetPlayerInvincible(VICE.getPlayerPed(), true)
            SetEntityProofs(VICE.getPlayerPed(), true, true, true, true, true, false, 0, false)
            while true do
                if WentParachuting then
                    if IsPedInParachuteFreeFall(VICE.getPlayerPed()) and not HasEntityCollidedWithAnything(VICE.getPlayerPed()) then
                        ApplyForceToEntity(VICE.getPlayerPed(),true,0.0,200.0,2.5,0.0,0.0,0.0,false,true,false,false,false,true)
                    else
                        WentParachuting = false
                    end
                else
                    break
                end
                Wait(0)
            end
            Wait(3000)
            SetPlayerInvincible(VICE.getPlayerPed(), false)
            SetEntityProofs(VICE.getPlayerPed(), false, false, false, false, false, false, 0, false)
        end)
    end
end

-- function tVICE.RiftIsAGo()
--     if not UsedItem then
--         UsedItem = true
--         if VICE.getPlayerCombatTimer() == 0 then
--             if not VICE.isInVehicle() then
--                 CreateThread(function()
--                     VICE.allowWeapon("GADGET_PARACHUTE")
--                     GiveWeaponToPed(PlayerPedId(), "GADGET_PARACHUTE")
--                     local playerHealth = VICE.getHealth()
--                     RequestAnimDict("amb@world_human_car_park_attendant@male@base")
--                     while not HasAnimDictLoaded("amb@world_human_car_park_attendant@male@base") do
--                         Citizen.Wait(0)
--                     end
--                     TaskPlayAnim(PlayerPedId(), "amb@world_human_car_park_attendant@male@base", "base", 8.0, -8, -1, 50, 0, false, false, false)
--                     tVICE.startCircularProgressBar("", 5000, nil, function()
--                         if VICE.getHealth() < playerHealth then
--                             VICE.notify("~r~Rift cancelled due to taking damage.")
--                             return true
--                         end
--                     end)
--                     if VICE.getHealth() < playerHealth then
--                         return
--                     end
--                     DoScreenFadeOut(3000)
--                     while not IsScreenFadedOut() do
--                         Wait(0)
--                     end
--                     ClearPedTasks(PlayerPedId())
--                     local PlayerCoords = GetEntityCoords(VICE.getPlayerPed())
--                     SetEntityCoords(VICE.getPlayerPed(), PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 1000.0)
--                     DoScreenFadeIn(2000)
--                     Wait(2000)
--                     SetPlayerInvincible(VICE.getPlayerPed(), true)
--                     SetEntityProofs(VICE.getPlayerPed(), true, true, true, true, true, false, 0, false)
--                     while true do
--                         if UsedItem then
--                             if IsPedInParachuteFreeFall(VICE.getPlayerPed()) and not HasEntityCollidedWithAnything(VICE.getPlayerPed()) then
--                                 ApplyForceToEntity(VICE.getPlayerPed(),true,0.0,200.0,2.5,0.0,0.0,0.0,false,true,false,false,false,true)
--                             else
--                                 UsedItem = false
--                             end
--                         else
--                             break
--                         end
--                         Wait(0)
--                     end
--                     Wait(3000)
--                     SetPlayerInvincible(VICE.getPlayerPed(), false)
--                     SetEntityProofs(VICE.getPlayerPed(), false, false, false, false, false, false, 0, false)
--                 end)
--             else
--                 VICE.notify("~r~You cannot use this item whilst in a vehicle.")
--             end
--         else
--             VICE.notify("~r~You cannot use this item whilst in combat.")
--         end
--     end
-- end

AddEventHandler("VICE:onClientSpawn",function(D, E)
    if E then
		local g = function()
            drawNativeNotification("Press ~INPUT_PICKUP~ to go parachuting! (FREE)")
        end
        local h = function()
        end
        local i = function()
            if IsControlJustPressed(1, 51) then
                goParachuting()
            end
        end
        for j, k in pairs(ParachutingLocations) do
            VICE.createArea("parachute_" .. j, k, 1.5, 6, g, h, i, {})
            tVICE.addMarker(k.x, k.y, k.z, 1.0, 1.0, 1.0, 255, 0, 0, 170, 50, 40, false, false, true)
        end
	end
end)