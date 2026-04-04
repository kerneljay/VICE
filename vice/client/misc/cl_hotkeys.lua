function loadAnimDict(a)
    while not HasAnimDictLoaded(a) do
        RequestAnimDict(a)
        Citizen.Wait(5)
    end
end
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if IsControlPressed(1, 19) and IsControlJustPressed(1, 90) then
                local b = GetClosestPlayer(3)
                if b then
                    targetSrc = GetPlayerServerId(b)
                    if targetSrc > 0 then
                        TriggerServerEvent("VICE:dragPlayer", targetSrc)
                    end
                end
                Wait(1000)
            end
            if IsControlPressed(1, 19) and IsDisabledControlJustPressed(1, 185) then
                TriggerServerEvent("VICE:ejectFromVehicle")
                Wait(1000)
            end
            if
                IsControlPressed(1, 19) and IsControlJustPressed(1, 58) and IsPedArmed(VICE.getPlayerPed(), 7) and
                    not VICE.isInPurge()
             then
                local c = GetSelectedPedWeapon(VICE.getPlayerPed())
                if c ~= `WEAPON_UNARMED` then
                    local d = GetWeapontypeGroup(c)
                    if d ~= `GROUP_UNARMED` and d ~= `GROUP_MELEE` and d ~= `GROUP_THROWN` then
                        if not inOrganHeist then
                        end
                    end
                end
                Wait(1000)
            end
            if IsControlPressed(1, 19) and IsControlJustPressed(1, 74) and VICE.isDev() then
                Wait(1000)
                local e = "melee@unarmed@streamed_variations"
                local f = "plyr_takedown_front_headbutt"
                local g = VICE.getPlayerPed()
                if DoesEntityExist(g) and not IsEntityDead(g) then
                    loadAnimDict(e)
                    if IsEntityPlayingAnim(g, e, f, 3) then
                        TaskPlayAnim(g, e, "exit", 3.0, 1.0, -1, 0, 0, 0, 0, 0)
                        ClearPedSecondaryTask(g)
                    else
                        TaskPlayAnim(g, e, f, 3.0, 1.0, -1, 0, 0, 0, 0, 0)
                    end
                    RemoveAnimDict(e)
                end
                TriggerServerEvent("VICE:KnockoutNoAnim")
                Wait(1000)
            end
            if IsControlPressed(1, 19) and IsControlJustPressed(1, 32) then
                if
                    not IsPauseMenuActive() and not IsPedInAnyVehicle(VICE.getPlayerPed(), true) and
                        not IsPedSwimming(VICE.getPlayerPed()) and
                        not IsPedSwimmingUnderWater(VICE.getPlayerPed()) and
                        not IsPedShooting(VICE.getPlayerPed()) and
                        not IsPedDiving(VICE.getPlayerPed()) and
                        not IsPedFalling(VICE.getPlayerPed()) and
                        GetEntityHealth(VICE.getPlayerPed()) > 105 and
                        not tVICE.isHandcuffed() and
                        not VICE.isInRadioChannel()
                 then
                    tVICE.playAnim(true, {{"rcmnigel1c", "hailing_whistle_waive_a"}}, false)
                end
            end
            if IsControlPressed(1, 19) and IsControlJustPressed(1, 29) then
                if not IsPedInAnyVehicle(VICE.getPlayerPed(), false) then
                    local h = GetClosestPlayer(4)
                    local i = IsEntityPlayingAnim(GetPlayerPed(h), "missminuteman_1ig_2", "handsup_enter", 3)
                    if i then
                        TriggerServerEvent("VICE:requestPlaceBagOnHead")
                    else
                        drawNativeNotification("Player must have his hands up!")
                    end
                end
            end
        end
    end
)
