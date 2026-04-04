RegisterNetEvent("playRussianRoulette",function(f)
    if f == nil then
        return
    end
    local g = GetEntityCoords(VICE.getPlayerPed())
    local h = Vdist(g.x, g.y, g.z, f.x, f.y, f.z)
    if h <= 15 then
        SendNUIMessage({transactionType = "playRussianRoulette"})
    end
end)

RegisterNetEvent("playEmptyGun",function(f)
    if f == nil then
        return
    end
    local g = GetEntityCoords(VICE.getPlayerPed())
    local h = Vdist(g.x, g.y, g.z, f.x, f.y, f.z)
    if h <= 15 then
        SendNUIMessage({transactionType = "emptygun"})
        VICE.notify("~g~Click...")
    end
end)

math.randomseed(GetGameTimer())
RegisterCommand("russianroulette",function()
    local a = VICE.getPlayerPed()
    if HasPedGotWeapon(a, "WEAPON_PYTHONVICE", false) then
        if GetAmmoInPedWeapon(a, "WEAPON_PYTHONVICE") > 0 then
            VICE.setWeapon(a, "WEAPON_PYTHONVICE", true)
            local b = GetEntityCoords(a)
            TriggerServerEvent("playRussianRouletteGlobally", b)
            num = math.random(1, 6)
            if not HasAnimDictLoaded("anim@weapons@first_person@aim_rng@general@pistol@revolver@str") then
                RequestAnimDict("anim@weapons@first_person@aim_rng@general@pistol@revolver@str")
                while not HasAnimDictLoaded("anim@weapons@first_person@aim_rng@general@pistol@revolver@str") do
                    Wait(1)
                end
            end
            TaskPlayAnim(a,"anim@weapons@first_person@aim_rng@general@pistol@revolver@str","reload_aim",8.0,8.0,-1,2)
            RemoveAnimDict("anim@weapons@first_person@aim_rng@general@pistol@revolver@str")
            Wait(4500)
            if not HasAnimDictLoaded("mp_suicide") then
                RequestAnimDict("mp_suicide")
                while not HasAnimDictLoaded("mp_suicide") do
                    Wait(1)
                end
            end
            if num == 1 then
                TaskPlayAnim(a, "mp_suicide", "pistol", 4.0, 0.0, -1, 0, 0.1, 0, 0, 0)
                Wait(800)
                SetPedShootsAtCoord(a, 0.0, 0.0, 0.0, 0)
                SetEntityHealth(a, 0)
                VICE.notify("~r~Bang...")
            else
                local c = GetEntityCoords(a)
                local d = GetEntityHeading(a)
                TaskPlayAnim(a, "mp_suicide", "pistol", 2.0, 100.0, 500, 0, 0.1, 0, 0, 0)
                Wait(500)
                TriggerServerEvent("playEmptyGunGlobally", b)
            end
            RemoveAnimDict("mp_suicide")
            ClearPedSecondaryTask(a)
        end
    end
end)
