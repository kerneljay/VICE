AddEventHandler('gameEventTriggered', function(event, details)
    if GetGameBuildNumber() >= 2189 then
        if event == "CEventNetworkEntityDamage" then
            local target = tonumber(details[1])
            local attacker = tonumber(details[2])
            local lethal = tonumber(details[6])
            local weapon = tonumber(details[7])
            local headshot = false
            local attackerPosition = GetEntityCoords(attacker)
            local targetPosition = GetEntityCoords(target)
            local range = #(attackerPosition - targetPosition)
            local defaultRange = 20.0  
            local maxRange = AstraFIX.WeaponRanges[weapon] or 20.0 
            if range > maxRange then return end
            if IsEntityAPed(attacker) then
                if target == PlayerPedId() then
                    local valid, hitBone = GetPedLastDamageBone(PlayerPedId())
                    local helmetType = GetPedPropIndex(target, 0)
                    for _, restricted in pairs(AstraFIX.BlackListedHelmets) do
                        if tostring(helmetType) == restricted then
                            return
                        end
                    end
                    if hitBone == 31086 then  
                        SetEntityHealth(target, 4)
                        headshot = true
                    end
                else
                    if attacker == PlayerPedId() then
                        local valid, hitBone = GetPedLastDamageBone(target)
                        if hitBone == 31086 then  
                            SetEntityHealth(target, 4)
                        end
                    end
                end
            end
        end
    end
end)

