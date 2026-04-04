local traderCoords = vector3(1439.1023, 6346.9937, 23.9780)
local traderHeading = 175.0
local traderPedModel = `g_m_m_armboss_01`
local traderWeapon = `WEAPON_MOSINCMG`

local traderPed = nil
local traderSpawning = false

RMenu.Add(
    "vice_blackmarket",
    "main",
    RageUI.CreateMenu(
        "",
        "Black Market Trader",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "shopui_title_gunclub",
        "shopui_title_gunclub"
    )
)

local function loadModel(model)
    if not IsModelInCdimage(model) or not IsModelValid(model) then
        return false
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) do
        Wait(0)
        if GetGameTimer() > timeout then
            return false
        end
    end
    return true
end

local function draw3DText(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    local cam = GetGameplayCamCoord()
    local dist = #(vector3(x, y, z) - cam)
    local scale = (1.0 / math.max(dist, 0.1)) * 1.4

    SetTextScale(0.0 * scale, 0.50 * scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 235)
    SetTextDropshadow(2, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(sx, sy)
end

local function cleanupTrader()
    if traderPed and DoesEntityExist(traderPed) then
        DeleteEntity(traderPed)
    end
    traderPed = nil
end

local function cleanupDuplicateTraders()
    local peds = GetGamePool("CPed")
    for _, ped in ipairs(peds) do
        if ped ~= traderPed and DoesEntityExist(ped) and GetEntityModel(ped) == traderPedModel then
            local pedCoords = GetEntityCoords(ped)
            if #(pedCoords - traderCoords) < 3.0 then
                DeleteEntity(ped)
            end
        end
    end
end

local function spawnTrader()
    if traderSpawning then
        return
    end
    traderSpawning = true

    cleanupTrader()
    cleanupDuplicateTraders()

    if not loadModel(traderPedModel) then
        traderSpawning = false
        return
    end

    local spawnZ = traderCoords.z
    local foundGround, groundZ = GetGroundZFor_3dCoord(traderCoords.x, traderCoords.y, traderCoords.z + 2.0, false)
    if foundGround then
        spawnZ = groundZ + 1.0
    end

    RequestCollisionAtCoord(traderCoords.x, traderCoords.y, spawnZ)
    traderPed = CreatePed(4, traderPedModel, traderCoords.x, traderCoords.y, spawnZ, traderHeading, false, false)
    SetEntityAsMissionEntity(traderPed, true, true)
    SetEntityInvincible(traderPed, true)
    SetBlockingOfNonTemporaryEvents(traderPed, true)
    SetPedCanRagdoll(traderPed, false)
    SetPedCanBeTargetted(traderPed, false)
    SetPedDiesWhenInjured(traderPed, false)
    SetPedFleeAttributes(traderPed, 0, false)
    SetPedCombatAttributes(traderPed, 17, true)
    SetEntityProofs(traderPed, true, true, true, true, true, true, true, true)
    FreezeEntityPosition(traderPed, true)
    SetEntityHeading(traderPed, traderHeading)
    SetEntityCoordsNoOffset(traderPed, traderCoords.x, traderCoords.y, spawnZ, false, false, false)
    GiveWeaponToPed(traderPed, traderWeapon, 250, false, true)
    SetCurrentPedWeapon(traderPed, traderWeapon, true)

    SetModelAsNoLongerNeeded(traderPedModel)
    traderSpawning = false
end

RageUI.CreateWhile(1.0, RMenu:Get("vice_blackmarket", "main"), function()
    RageUI.IsVisible(RMenu:Get("vice_blackmarket", "main"), true, true, true, function()
        RageUI.Separator("~o~Sell Weapons For Cash")
        RageUI.ButtonWithStyle("Sell Mosin", "Receive ~g~£500,000", {RightLabel = "→→→"}, true, function(_, _, selected)
            if selected then
                TriggerServerEvent("VICE:blackMarketSellWeapon", "mosin")
            end
        end)
        RageUI.ButtonWithStyle("Sell SVD", "Receive ~g~£750,000", {RightLabel = "→→→"}, true, function(_, _, selected)
            if selected then
                TriggerServerEvent("VICE:blackMarketSellWeapon", "svd")
            end
        end)
        RageUI.ButtonWithStyle("Sell MK14", "Receive ~g~£850,000", {RightLabel = "→→→"}, true, function(_, _, selected)
            if selected then
                TriggerServerEvent("VICE:blackMarketSellWeapon", "mk14")
            end
        end)
    end)
end)

AddEventHandler("playerSpawned", function()
    SetTimeout(2000, function()
        spawnTrader()
    end)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local dist = #(coords - traderCoords)

        if dist < 20.0 then
            sleep = 0
            DrawMarker(27, traderCoords.x, traderCoords.y, traderCoords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 20, 20, 20, 120, false, false, 2, false, nil, nil, false)

            if dist < 2.0 then
                if IsControlJustPressed(0, 38) then
                    RageUI.Visible(RMenu:Get("vice_blackmarket", "main"), true)
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    cleanupTrader()
end)
