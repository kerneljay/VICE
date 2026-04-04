grindBoost = 1.0 -- 1.0 -- 3.0 for beta

local defaultPrices = {
    ["Weed"] = math.floor(55000*grindBoost),
    ["Cocaine"] = math.floor(55000*grindBoost),
    ["Meth"] = math.floor(55000*grindBoost),
    ["Heroin"] = math.floor(55000*grindBoost),
    ["LSDNorth"] = math.floor(55000*grindBoost),
    ["LSDSouth"] = math.floor(55000*grindBoost),
    ["Copper"] = math.floor(55000*grindBoost),
    ["Limestone"] = math.floor(55000*grindBoost),
    ["Gold"] = math.floor(55000*grindBoost),
    ["Diamond"] = math.floor(250000*grindBoost),
}

function VICE.getCommissionPrice(drugtype)
    for k,v in pairs(turfData) do
        if v.name == drugtype then
            if v.commission == nil then
                v.commission = 0
            end
            if v.commission == 0 then
                return defaultPrices[drugtype]
            else
                return defaultPrices[drugtype]-defaultPrices[drugtype]*v.commission/100
            end
        end
    end
end

function VICE.getCommission(drugtype)
    if turfData then
        for k,v in pairs(turfData) do
            if v.name == drugtype then
                return v.commission
            end
        end
    else
        print("Warning: turfData is nil")
    end
end

function VICE.updateTraderInfo()
    TriggerClientEvent('VICE:updateTraderCommissions', -1, 
    VICE.getCommission('Weed'),
    VICE.getCommission('Cocaine'),
    VICE.getCommission('Meth'),
    VICE.getCommission('Heroin'),
    VICE.getCommission('LargeArms'),
    VICE.getCommission('LSDNorth'),
    VICE.getCommission('LSDSouth'))
    TriggerClientEvent('VICE:updateTraderPrices', -1, 
    VICE.getCommissionPrice('Weed'), 
    VICE.getCommissionPrice('Cocaine'),
    VICE.getCommissionPrice('Meth'),
    VICE.getCommissionPrice('Heroin'),
    VICE.getCommissionPrice('LSDNorth'),
    VICE.getCommissionPrice('LSDSouth'),
    defaultPrices['Copper'],
    defaultPrices['Limestone'],
    defaultPrices['Gold'],
    defaultPrices['Diamond'])
end

RegisterNetEvent('VICE:requestDrugPriceUpdate')
AddEventHandler('VICE:requestDrugPriceUpdate', function()
    local source = source
	local user_id = VICE.getUserId(source)
    VICE.updateTraderInfo()
end)

local function checkTraderBucket(source) 
    if GetPlayerRoutingBucket(source) ~= 0 then
        VICE.notify(source, 'You cannot sell drugs in this dimension.')
        return false
    end
    return true
end

RegisterNetEvent('VICE:sellCopper')
AddEventHandler('VICE:sellCopper', function()
    local source = source
	local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Copper') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Copper', 1, false)
            VICE.notify(source, '~g~Sold Copper for £'..getMoneyStringFormatted(defaultPrices['Copper']))
            VICE.giveMoney(user_id, defaultPrices['Copper'])
            VICE.AddStat(user_id, 'copper_sales', defaultPrices['Copper'])
        else
            VICE.notify(source, 'You do not have Copper.')
        end
    end
end)

RegisterNetEvent('VICE:sellLimestone')
AddEventHandler('VICE:sellLimestone', function()
    local source = source
	local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Limestone') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Limestone', 1, false)
            VICE.notify(source, '~g~Sold Limestone for £'..getMoneyStringFormatted(defaultPrices['Limestone']))
            VICE.giveMoney(user_id, defaultPrices['Limestone'])
            VICE.AddStat(user_id, 'limestone_sales', defaultPrices['Limestone'])
        else
            VICE.notify(source, 'You do not have Limestone.')
        end
    end
end)

RegisterNetEvent('VICE:sellGold')
AddEventHandler('VICE:sellGold', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Gold') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Gold', 1, false)
            VICE.notify(source, '~g~Sold Gold for £'..getMoneyStringFormatted(defaultPrices['Gold']))
            VICE.giveMoney(user_id, defaultPrices['Gold'])
            VICE.AddStat(user_id, 'gold_sales', defaultPrices['Gold'])
        else
            VICE.notify(source, 'You do not have Gold.')
        end
    end
end)

RegisterNetEvent('VICE:sellDiamond')
AddEventHandler('VICE:sellDiamond', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Diamond') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Diamond', 1, false)
            VICE.notify(source, '~g~Sold Diamond for £'..getMoneyStringFormatted(defaultPrices['Diamond']))
            VICE.giveMoney(user_id, defaultPrices['Diamond'])
            VICE.AddStat(user_id, 'diamond_sales', defaultPrices['Diamond'])
        else
            VICE.notify(source, 'You do not have Diamond.')
        end
    end
end)

RegisterNetEvent('VICE:sellWeed')
AddEventHandler('VICE:sellWeed', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Weed') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Weed', 1, false)
            VICE.notify(source, '~g~Sold Weed for £'..getMoneyStringFormatted(VICE.getCommissionPrice('Weed')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('Weed'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('Weed'), 'Weed')
            VICE.AddStat(user_id, 'weed_sales', VICE.getCommissionPrice('Weed'))
        else
            VICE.notify(source, 'You do not have Weed.')
        end
    end
end)

RegisterNetEvent('VICE:sellCocaine')
AddEventHandler('VICE:sellCocaine', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Cocaine') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Cocaine', 1, false)
            VICE.notify(source, '~g~Sold Cocaine for £'..getMoneyStringFormatted(VICE.getCommissionPrice('Cocaine')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('Cocaine'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('Cocaine'), 'Cocaine')
            VICE.AddStat(user_id, 'cocaine_sales', VICE.getCommissionPrice('Cocaine'))
        else
            VICE.notify(source, 'You do not have Cocaine.')
        end
    end
end)

RegisterNetEvent('VICE:sellMeth')
AddEventHandler('VICE:sellMeth', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Meth') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Meth', 1, false)
            VICE.notify(source, '~g~Sold Meth for £'..getMoneyStringFormatted(VICE.getCommissionPrice('Meth')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('Meth'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('Meth'), 'Meth')
            VICE.AddStat(user_id, 'meth_sales', VICE.getCommissionPrice('Meth'))
        else
            VICE.notify(source, 'You do not have Meth.')
        end
    end
end)

RegisterNetEvent('VICE:sellHeroin')
AddEventHandler('VICE:sellHeroin', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'Heroin') > 0 then
            VICE.tryGetInventoryItem(user_id, 'Heroin', 1, false)
            VICE.notify(source, '~g~Sold Heroin for £'..getMoneyStringFormatted(VICE.getCommissionPrice('Heroin')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('Heroin'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('Heroin'), 'Heroin')
            VICE.AddStat(user_id, 'heroin_sales', VICE.getCommissionPrice('Heroin'))
        else
            VICE.notify(source, 'You do not have Heroin.')
        end
    end
end)

RegisterNetEvent('VICE:sellLSDNorth')
AddEventHandler('VICE:sellLSDNorth', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'LSD') > 0 then
            VICE.tryGetInventoryItem(user_id, 'LSD', 1, false)
            VICE.notify(source, '~g~Sold LSD for £'..getMoneyStringFormatted(VICE.getCommissionPrice('LSDNorth')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('LSDNorth'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('LSDNorth'), 'LSDNorth')
            VICE.AddStat(user_id, 'lsd_sales', VICE.getCommissionPrice('LSDNorth'))
        else
            VICE.notify(source, 'You do not have LSD.')
        end
    end
end)

RegisterNetEvent('VICE:sellLSDSouth')
AddEventHandler('VICE:sellLSDSouth', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        if VICE.getInventoryItemAmount(user_id, 'LSD') > 0 then
            VICE.tryGetInventoryItem(user_id, 'LSD', 1, false)
            VICE.notify(source, '~g~Sold LSD for £'..getMoneyStringFormatted(VICE.getCommissionPrice('LSDSouth')))
            VICE.giveDirtyCash(user_id, VICE.getCommissionPrice('LSDSouth'))
            VICE.turfSaleToGangFunds(VICE.getCommissionPrice('LSDSouth'), 'LSDSouth')
            VICE.AddStat(user_id, 'lsd_sales', VICE.getCommissionPrice('LSDSouth'))
        else
            VICE.notify(source, 'You do not have LSD.')
        end
    end
end)

RegisterNetEvent('VICE:sellAll')
AddEventHandler('VICE:sellAll', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if checkTraderBucket(source) then
        for k,v in pairs(defaultPrices) do
            if k == 'Copper' or k == 'Limestone' or k == 'Gold' then
                if VICE.getInventoryItemAmount(user_id, k) > 0 then
                    local amount = VICE.getInventoryItemAmount(user_id, k)
                    VICE.tryGetInventoryItem(user_id, k, amount, false)
                    VICE.notify(source, '~g~Sold '..k..' for £'..getMoneyStringFormatted(defaultPrices[k]*amount))
                    VICE.giveMoney(user_id, defaultPrices[k]*amount)
                    VICE.AddStat(user_id, string.lower(k)..'_sales', defaultPrices[k]*amount)
                end
            elseif k == 'Diamond' then
                if VICE.getInventoryItemAmount(user_id, 'Diamond') > 0 then
                    local amount = VICE.getInventoryItemAmount(user_id, 'Diamond')
                    VICE.tryGetInventoryItem(user_id, 'Diamond', amount, false)
                    VICE.notify(source, '~g~Sold '..'Diamond'..' for £'..getMoneyStringFormatted(defaultPrices[k]*amount))
                    VICE.giveDirtyCash(user_id, defaultPrices[k]*amount)
                    VICE.AddStat(user_id, string.lower(k)..'_sales', defaultPrices[k]*amount)
                end
            end
        end
    end
end)