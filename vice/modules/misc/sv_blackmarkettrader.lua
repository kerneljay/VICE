local weaponCfg = module("cfg/weapons").weapons
local saleCooldown = {}

local prices = {
    mosin = 500000,
    svd = 750000,
    mk14 = 850000
}

local function formatMoney(amount)
    local left, num, right = string.match(tostring(math.floor(amount or 0)), "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

local function findWeaponToSell(selection, weapons)
    if type(weapons) ~= "table" then
        return nil
    end

    if selection == "mosin" then
        for spawnCode, _ in pairs(weapons) do
            if weaponCfg[spawnCode] and weaponCfg[spawnCode].class == "Mosin" then
                return spawnCode
            end
        end
    elseif selection == "svd" then
        for spawnCode, _ in pairs(weapons) do
            if spawnCode == "WEAPON_SVDCMG" then
                return spawnCode
            end
            if weaponCfg[spawnCode] and weaponCfg[spawnCode].name and string.find(string.upper(weaponCfg[spawnCode].name), "SVD", 1, true) then
                return spawnCode
            end
        end
    elseif selection == "mk14" then
        for spawnCode, _ in pairs(weapons) do
            if spawnCode == "WEAPON_MK14" then
                return spawnCode
            end
            if weaponCfg[spawnCode] and weaponCfg[spawnCode].name and string.find(string.upper(weaponCfg[spawnCode].name), "MK14", 1, true) then
                return spawnCode
            end
        end
    end

    return nil
end

RegisterNetEvent("VICE:blackMarketSellWeapon")
AddEventHandler("VICE:blackMarketSellWeapon", function(selection)
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then return end

    if not prices[selection] then
        return
    end

    local now = GetGameTimer()
    if saleCooldown[source] and now - saleCooldown[source] < 1500 then
        return
    end
    saleCooldown[source] = now

    VICEclient.getWeapons(source, {}, function(weapons)
        local weaponToSell = findWeaponToSell(selection, weapons)
        if not weaponToSell then
            VICE.notify(source, "~r~You do not have that weapon to sell.")
            return
        end

        weapons[weaponToSell] = nil

        local data = VICE.getUserDataTable(user_id)
        if data then
            data.weapons = weapons
        end

        VICEclient.giveWeapons(source, {weapons, true, globalpasskey})
        VICE.giveMoney(user_id, prices[selection])

        local soldName = weaponCfg[weaponToSell] and weaponCfg[weaponToSell].name or weaponToSell
        VICE.notify(source, "~g~Sold " .. soldName .. " for £" .. formatMoney(prices[selection]))
    end)
end)

AddEventHandler("playerDropped", function()
    saleCooldown[source] = nil
end)
