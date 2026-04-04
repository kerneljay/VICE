local a = false
local radioProp = nil
function func_ptt()
    if VICE.getRadioAnim() and VICE.canAnim() and not noclipActive and VICE.isInRadioChannel() then
        local b = VICE.getPlayerPed()
        local c = VICE.getPlayerId()
        if a then
            if IsEntityPlayingAnim(b, "anim@male@holding_radio", "holding_radio_clip", 3) then
                DisableActions(b)
            end
            if not IsControlPressed(0, 19) and IsUsingKeyboard(2) and not IsPedReloading(b) then
                SendNUIMessage({transactionType = "radiooff"})
                StopAnimTask(b, "anim@male@holding_radio", "holding_radio_clip", 1.0)
                SetEnableHandcuffs(b, false)
                if radioProp then
                    DeleteObject(radioProp)
                    radioProp = nil
                end
                a = false
            end
        else
            if
                IsControlJustPressed(0, 19) and not IsPlayerFreeAiming(c) and IsUsingKeyboard(2) and
                    not IsPedReloading(b)
             then
                SendNUIMessage({transactionType = "radioon"})
                VICE.loadAnimDict("anim@male@holding_radio")
                TaskPlayAnim(b, "anim@male@holding_radio", "holding_radio_clip", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0)
                -- Attach radio prop
                local playerPed = b
                local x, y, z = table.unpack({0.0750, 0.0230, -0.0230})
                local rx, ry, rz = table.unpack({-90.0000, 0.0, -59.9999})
                local bone = 28422 -- Right Hand
                RequestModel(GetHashKey("prop_cs_hand_radio"))
                while not HasModelLoaded(GetHashKey("prop_cs_hand_radio")) do
                    Wait(0)
                end
                radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), GetEntityCoords(playerPed), true, true, true)
                AttachEntityToEntity(radioProp, playerPed, GetPedBoneIndex(playerPed, bone), x, y, z, rx, ry, rz, false, false, false, false, 2, true)
                SetModelAsNoLongerNeeded(GetHashKey("prop_cs_hand_radio"))
                if not IsPedSwimming(b) and not IsPedSwimmingUnderWater(b) then
                    SetEnableHandcuffs(b, true)
                end
                a = true
            elseif
                IsControlJustPressed(0, 19) and IsPlayerFreeAiming(c) and IsUsingKeyboard(2) and not IsPedReloading(b)
             then
                SendNUIMessage({transactionType = "radioon"})
                VICE.loadAnimDict("anim@male@holding_radio")
                TaskPlayAnim(b, "anim@male@holding_radio", "holding_radio_clip", 8.0, 2.0, -1, 50, 2.0, 0, 0, 0)
                -- Attach radio prop
                local playerPed = b
                local x, y, z = table.unpack({0.0750, 0.0230, -0.0230})
                local rx, ry, rz = table.unpack({-90.0000, 0.0, -59.9999})
                local bone = 28422 -- Right Hand
                RequestModel(GetHashKey("prop_cs_hand_radio"))
                while not HasModelLoaded(GetHashKey("prop_cs_hand_radio")) do
                    Wait(0)
                end
                radioProp = CreateObject(GetHashKey("prop_cs_hand_radio"), GetEntityCoords(playerPed), true, true, true)
                AttachEntityToEntity(radioProp, playerPed, GetPedBoneIndex(playerPed, bone), x, y, z, rx, ry, rz, false, false, false, false, 2, true)
                SetModelAsNoLongerNeeded(GetHashKey("prop_cs_hand_radio"))
                if not IsPedSwimming(b) and not IsPedSwimmingUnderWater(b) then
                    SetEnableHandcuffs(b, true)
                end
                a = true
            end
        end
    end
end
VICE.createThreadOnTick(func_ptt)
function DisableActions(b)
    DisableControlAction(1, 140, true)
    DisableControlAction(1, 141, true)
    DisableControlAction(1, 142, true)
    DisableControlAction(1, 37, true)
    DisablePlayerFiring(b, true)
end
local d = {[137473] = 2}
local e = false
local function f(g)
    local h = GetInteriorFromEntity(g.playerPed)
    local i = d[h]
    if i and not e then
        exports["pma-voice"]:setMaxProximityMode(i)
        e = true
    elseif not i and e then
        exports["pma-voice"]:clearMaxProximityMode()
        e = false
    end
end
VICE.createThreadOnTick(f)
