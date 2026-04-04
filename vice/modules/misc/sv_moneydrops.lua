local lang = VICE.lang
local MoneydropEntities = {}

function tVICE.MoneyDrop()
    local source = source
    Wait(100) -- wait delay for death.
    local user_id = VICE.getUserId(source)
    local money = VICE.getMoney(user_id)
    if money > 0 then
        local model = GetHashKey('prop_poly_bag_money')
        local name1 = VICE.getPlayerName(user_id)
        local moneydrop = CreateObjectNoOffset(model, GetEntityCoords(GetPlayerPed(source)) + 0.2, true, true, false)
        local moneydropnetid = NetworkGetNetworkIdFromEntity(moneydrop)
        SetEntityRoutingBucket(moneydrop, GetPlayerRoutingBucket(source))
        MoneydropEntities[moneydropnetid] = {moneydrop, moneydrop, false, source}
        MoneydropEntities[moneydropnetid].Money = {}
        local ndata = VICE.getUserDataTable(user_id)
        local stored_inventory = nil;
        if VICE.tryPayment(user_id,money) then
            MoneydropEntities[moneydropnetid].Money = money
        end
    end
end

RegisterNetEvent('VICE:Moneydrop')
AddEventHandler('VICE:Moneydrop', function(netid)
    local source = source
    if MoneydropEntities[netid] and not MoneydropEntities[netid][3] and #(GetEntityCoords(MoneydropEntities[netid][1]) - GetEntityCoords(GetPlayerPed(source))) < 10.0 then
        MoneydropEntities[netid][3] = true;
        local user_id = VICE.getUserId(source)
        if user_id then
            TriggerClientEvent("VICE:MoneyNotInBag",source)
            if MoneydropEntities[netid].Money ~= 0 then
                VICE.giveMoney(user_id,MoneydropEntities[netid].Money)
                VICE.notify(source, "~g~You have taken £"..getMoneyStringFormatted(math.floor(MoneydropEntities[netid].Money)))
                MoneydropEntities[netid].Money = 0
            end
        else
            VICE.notify(source, "~r~The money drop is already being taken")

        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(100)
        for i,v in pairs(MoneydropEntities) do 
            if v.Money == 0 then
                if DoesEntityExist(v[1]) then 
                    DeleteEntity(v[1])
                    MoneydropEntities[i] = nil;
                end
            end
        end
    end
end)