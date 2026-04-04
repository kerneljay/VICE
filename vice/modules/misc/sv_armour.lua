local cooldownActive = false

RegisterNetEvent("VICE:getArmour")
AddEventHandler("VICE:getArmour", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local existingArmor = GetPedArmour(GetPlayerPed(source)) -- armour check mkay
    local playerName = VICE.getPlayerName(user_id)

    if cooldownActive then
        VICE.notify(source, "~r~You are being rate limited, Please wait a moment.")
        return
    end

    if VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, "hmp.menu") then
        local armorValue = 0
        if VICE.hasPermission(user_id, "police.maxarmour") or VICE.hasPermission(user_id, "hmp.menu") then
            armorValue = 100
        elseif VICE.hasGroup(user_id, "Inspector Clocked") then
            armorValue = 75
        elseif VICE.hasGroup(user_id, "Senior Constable Clocked") or VICE.hasGroup(user_id, "Sergeant Clocked") then
            armorValue = 50
        elseif VICE.hasGroup(user_id, "PCSO Clocked") or VICE.hasGroup(user_id, "PC Clocked") then
            armorValue = 25
        elseif VICE.hasGroup(user_id, 'Founder') then 
            armorValue = 100
        end

        if existingArmor < 99 then
            VICEclient.setArmour(source, {armorValue, true})

            local notifications = {
                "~g~You slide in a plate of kevlar into your vest.",
                "~b~You equip a reinforced vest for protection.",
                "~y~Armor upgrade successful."
            }

            if existingArmor >= 50 then
                table.insert(notifications, "~o~Taking out the old plate and inserting a new one.")
            elseif existingArmor <= 10 then
                table.insert(notifications, "~r~Inserting a fresh armor plate.")
            end

            local randomNotification = notifications[math.random(1, #notifications)]

            TriggerClientEvent("vice:PlaySound", source, "playMoney")
            VICE.notify(source, randomNotification)

            cooldownActive = true
            SetTimeout(15000, function()
                cooldownActive = false
            end)
        else
            VICE.notify(source, "~r~You do not require any more armor.")
        end
    else
        VICE.notify(source, "~r~You shouldn't be here... Calling backup in 3..2..1...")

        local playerPed = PlayerPedId()
        local position = GetEntityCoords(playerPed)
        local locationName = "Police Department" 

        callID = callID + 1
        tickets[callID] = {
            name = 'Unauthed Armour',
            permID = 999,
            tempID = nil,
            reason = 'progress at '..locationName,
            type = 'met'
        }

        for k, v in pairs(VICE.getUsers({})) do
            TriggerClientEvent("VICE:addEmergencyCall", v, callID, 'Unauthed Armour attempt', 999, position, 'Person inside the pd '..locationName, 'met', playerName)
        end
    end
end)

local equipingplates = {}

function VICE.ArmourPlate(src)
    local user_id = VICE.getUserId(src)
    if GetPedArmour(GetPlayerPed(src)) < 100 then
        if not equipingplates[user_id] then
            if VICE.tryGetInventoryItem(user_id,"armourplate",1) then
                equipingplates[user_id] = true
                TriggerClientEvent("VICE:playArmourApplyAnim",src)
                Wait(5000)
                VICEclient.setArmour(src, {100})
                equipingplates[user_id] = false
                VICE.notify(src, "~g~You have equipped an armour plate.")
            else
                VICE.notify(src, "~r~You do not have any armour plates.")
            end
        else
            VICE.notify(src, "~r~You are already equipping armour plates.")
        end
    else
        VICE.notify(src, "~r~You already have 100% armour.")
    end
end