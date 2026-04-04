local stores = {
    ["paleto_twentyfourseven"] = {
        position = vector3(1728.7196044922, 6417.0654296875, 34.037220001221),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Paleto 24/7',
    },
    ["sandyshores_twentyfoursever"] = {
        position = vector3(1959.0535888672, 3741.7045898438, 31.3437995910641),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Sandy Shores 24/7',
    },
    ["bar_one"] = {
        position = vector3(1984.4356689453, 3054.7565917969, 47.215145111084),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Bar One',
    },
    ["littleseoul_twentyfourseven"] = {
        position = vector3(-706.16192626953, -913.20764160156, 18.215581893921),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Little Seoul 24/7',
    },
    ["asda"] = {
        position = vector3(24.493055343628, -1345.4788818359, 28.497024536133),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Asda',
    },
    ["southlossantos_twentyfourseven"] = {
        position = vector3(-46.450626373291, -1757.5461425781, 28.420984268188),
        beingrobbed = false,
        cooldown = 0,
        storename = 'South Los Santos 24/7',
    },
    ["vinewood_twentyfourseven"] = {
        position = vector3(372.95562744141, 328.26510620117, 102.56648254395),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Vinewood 24/7',
    },
    ["eastlossantos_robsliquor"] = {
        position = vector3(1134.2801513672, -982.96826171875, 45.415786743164),
        beingrobbed = false,
        cooldown = 0,
        storename = 'East Los Santos Rob\'s Liquor',
    },
    ["sandyshores_twentyfourseven"] = {
        position = vector3(2676.5114746094, 3280.2993164063, 54.241176605225),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Sandy Shores 24/7',
    },
    ["grapeseed_gasstop"] = {
        position = vector3(1698.5382080078, 4922.6352539063, 41.063629150391),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Grapeseed Gas Stop',
    },
    ["morningwood_robsliquor"] = {
        position = vector3(-1486.6450195313, -377.64117431641, 39.16344833374),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Morningwood Rob\'s Liquor',
    },
    ["chumash_robsliquor"] = {
        position = vector3(-2966.4086914063, 391.35339355469, 14.043314933777),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Chumash Rob\'s Liquor',
    },
    ["burgershot"] = {
        position = vector3(-1194.9146728516, -893.99810791016, 12.995297431946),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Burger Shot',
    },
    ["eastlossantos_gasstop"] = {
        position = vector3(1164.5863037109, -322.3291015625, 68.205024719238),
        beingrobbed = false,
        cooldown = 0,
        storename = 'East Los Santos Gas Stop',
    },
    ["tongva_gasstop"] = {
        position = vector3(-1820.384765625, 794.54663085938, 137.08973693848),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Tongva Gas Stop',
    },
    ["tataviam_twentyfourseven"] = {
        position = vector3(2555.5571289063, 380.84866333008, 107.62292480469),
        beingrobbed = false,
        cooldown = 0,
        storename = 'Tataviam 24/7',
    },
    ["new_store"] = {
        position = vector3(240.68464660645,-899.15118408203,29.623201370239),
        beingrobbed = false,
        cooldown = 0,
        storename = 'New Store',
    },
}

RegisterNetEvent('VICE:getStoreRobBlips')
AddEventHandler('VICE:getStoreRobBlips', function()
    TriggerClientEvent('VICE:updateStoreRobBlips', source, stores)
end)


RegisterNetEvent('VICE:initiateStoreRobbery')
AddEventHandler('VICE:initiateStoreRobbery', function(store)
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "police.armoury") then
        TriggerClientEvent('VICE:resetStorePed', source, store)
    else
        if #VICE.getUsersByPermission('police.armoury') > 0 then
            for k,v in pairs(stores) do
                if k == store then
                    if v.cooldown == 0 then
                        v.beingrobbed = true
                        v.cooldown = 300
                        TriggerClientEvent('VICE:updateStoreRobBlips', -1, stores)
                        TriggerClientEvent('VICE:beginStoreRobbingAnimations', -1, store)
                        TriggerClientEvent('VICE:storeRobberyInProgress', source, true, store)
                        for a, b in pairs(VICE.getUsers({})) do
                            if VICE.hasPermission(a, "police.armoury") then
                                TriggerClientEvent('chatMessage', b, "^7Robbery in progress at ^2"..v.storename, { 128, 128, 128 }, message, "alert")
                                TriggerEvent('VICE:PDRobberyCall', b, v.storename, v.position)
                            end
                        end
                    else
                        TriggerClientEvent('chatMessage', source, "^7OOC ^1Store Robbery ^7 - Store was robbed too recently, "..v.cooldown.." seconds remaining.", { 128, 128, 128 }, message, "alert")
                    end
                end
            end
        else
            VICE.notify(source, '~r~There are not enough police on duty to rob a store.')
            TriggerClientEvent('VICE:resetStorePed', source, store)
        end
    end
end)

RegisterNetEvent('VICE:completeSafeCracking')
AddEventHandler('VICE:completeSafeCracking', function(store)
    local source = source
    local user_id = VICE.getUserId(source)
    local amount = math.random(650000, 1000000)
    TriggerClientEvent('VICE:syncCloseSafeDoor', -1, store)
    TriggerClientEvent('VICE:resetStorePed', -1, store)
    for k,v in pairs(stores) do
        if k == store then
            if #(GetEntityCoords(GetPlayerPed(source)) - v.position) < 10 then
                TriggerClientEvent('VICE:giveStoreRobberyCash', source, amount)
                v.beingrobbed = false
                VICE.giveDirtyCash(user_id, amount)
                VICE.sendDCLog("store-rob","VICE Store Robbery","> Name: **"..VICE.getPlayerName(user_id).."**\n> PermID: **"..user_id.."**\n> TempID: **"..source.."**\n> Store: **"..v.storename.."**\n> Amount: **£"..getMoneyStringFormatted(amount).."**")
            else
                VICE.ACBan(15,user_id,#(GetEntityCoords(GetPlayerPed(source)) - v.position).."m, "..v.storename.." Store Robbery")
            end
       end
    end
    TriggerClientEvent('VICE:updateStoreRobBlips', -1, stores)
    TriggerClientEvent('VICE:storeRobberyInProgress', source, false, store)
end)

RegisterNetEvent('VICE:forceEndRobbery')
AddEventHandler('VICE:forceEndRobbery', function(store)
    local source = source
    local user_id = VICE.getUserId(source)
    TriggerClientEvent('VICE:resetStorePed', -1, store)
    for k,v in pairs(stores) do
        if k == store then
            v.beingrobbed = false
        end
    end
    TriggerClientEvent('VICE:updateStoreRobBlips', -1, stores)
    TriggerClientEvent('VICE:storeRobberyInProgress', source, false, store)
end)

RegisterNetEvent('VICE:syncOpenSafeDoor')
AddEventHandler('VICE:syncOpenSafeDoor', function(store)
    local source = source
    TriggerClientEvent('VICE:syncOpenSafeDoor', -1, store)
end)

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(stores) do
            if v.cooldown > 0 then
                v.cooldown = v.cooldown - 1
                if v.cooldown == 0 then
                    v.beingrobbed = false
                    TriggerClientEvent('VICE:updateStoreRobBlips', -1, stores)
                end
            end
        end
        Citizen.Wait(1000)
    end
end)