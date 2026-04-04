local a = false
local b = true
RegisterCommand(
    "togglekillfeed",
    function()
        if not a then
            b = not b
            if b then
                VICE.notify("~g~Killfeed is now enabled")
                SendNUIMessage({type = "killFeedEnable"})
            else
                VICE.notify("~r~Killfeed is now disabled")
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterCommand(
    "showkillfeed",
    function()
        if not a then
            b = not b
            if b then
                VICE.notify("~g~Killfeed is now enabled")
                SendNUIMessage({type = "killFeedEnable"})
            end
        end
    end
)
RegisterCommand(
    "disablekillfeed",
    function()
        if not a then
            b = not b
            if b then
                VICE.notify("~g~Killfeed is now disabled")
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterNetEvent(
    "VICE:showHUD",
    function(c)
        a = not c
        if b then
            if c then
                SendNUIMessage({type = "killFeedEnable"})
            else
                SendNUIMessage({type = "killFeedDisable"})
            end
        end
    end
)
RegisterNetEvent(
    "VICE:newKillFeed",
    function(d, e, f, g, h, i, j, headShot, rollKill)
        if GetIsLoadingScreenActive() then
            return
        end
        local k = "other"
        local l = VICE.getPlayerName(GetPlayerServerId(PlayerId()))
        if e == l or d == l then
            k = "self"
        end
        local m = GetResourceKvpString("vice_oldkillfeed") or "false"
        if m == "false" then
            oldKillfeed = false
        else
            oldKillfeed = true
        end
        if oldKillfeed and (tVICE.isPlatClub() or tVICE.isPlusClub()) then
            if g then
                VICE.notify("~o~" .. e .. " ~w~died.")
            else
                VICE.notify("~o~" .. d .. " ~w~killed ~o~" .. e .. "~w~.")
            end
        else
            SendNUIMessage(
                {
                    type = "addKill",
                    victim = e,
                    killer = d,
                    weapon = f,
                    suicide = g,
                    victimGroup = i,
                    isHeadshot = headShot,
                    rollKill = rollKill == true,
                    killerGroup = j,
                    range = h,
                    uuid = tVICE.generateUUID("kill", 10, "alphabet"),
                    category = k
                }
            )
        end
    end
)

-- --RegisterCommand('testkillfeed', function()
--     local killer = VICE.getPlayerName(GetPlayerServerId(PlayerId())) or "Killer"
--     local victim = "Target"
--     local weapon = 'LMG'
--     local headShot = true
--     local suicide = false
--     local victimGroup = 'none'
--     local killerGroup = 'none'
--     local range = math.random(10,78)
--     TriggerEvent('VICE:newKillFeed', killer, victim, weapon, suicide, range, victimGroup, killerGroup, headShot, false)
-- end, false)

-- RegisterCommand('killfeed', function()
--     ExecuteCommand('testkillfeed')
-- end, false)

-- RegisterCommand('testroll', function()
--     local killer = VICE.getPlayerName(GetPlayerServerId(PlayerId())) or "Killer"
--     local victim = "Target"
--     local weapon = 'LMG'
--     local headShot = false
--     local suicide = false
--     local victimGroup = 'none'
--     local killerGroup = 'none'
--     local range = math.random(8,45)
--     TriggerEvent('VICE:newKillFeed', killer, victim, weapon, suicide, range, victimGroup, killerGroup, headShot, true)
-- end, false)

Citizen.CreateThread(function()
    local wasRolling = false
    while true do
        local ped = PlayerPedId()
        local isRolling = IsPedDiving(ped)
        if isRolling ~= wasRolling then
            wasRolling = isRolling
            TriggerServerEvent("VICE:updateCombatRollState", isRolling)
        end
        Wait(50)
    end
end)
