local cfg = module("cfg/cfg_playerdealership")
local userVehicles = {}
local dealershipListings = {}
local viewingVehicle = nil
local testDriveVehicle = nil
local testDriveTimer = 0
local testDriveActive = false
local testDriveCar = nil
local testDriveSeconds = 0
local testDriveReturnCoords = nil
local PastCoords = nil

-- Load garages config
local cfg_garages = module("cfg/cfg_garages")

-- Build lookup table for friendly vehicle names
local vehicleNameLookup = {}
for garageName, garage in pairs(cfg_garages.garages) do
    if type(garage) == "table" then
        for spawnCode, data in pairs(garage) do
            if spawnCode ~= "_config" and type(data) == "table" and data[1] then
                vehicleNameLookup[spawnCode:lower()] = data[1]
            end
        end
    end
end

-- Safe friendly name lookup
function getFriendlyVehicleName(spawnCode)
    if not spawnCode or type(spawnCode) ~= "string" then
        return "Unknown Vehicle"
    end
    return vehicleNameLookup[spawnCode:lower()] or spawnCode
end

print("[Player Dealership] Script starting...")
if cfg and cfg.Location then
    print("[Player Dealership] Location: " .. cfg.Location.x .. ", " .. cfg.Location.y .. ", " .. cfg.Location.z)
else
    print("[Player Dealership] Error: Config not loaded properly!")
end

-- Create blip and marker
Citizen.CreateThread(function()
    print("[Player Dealership] Creating blip...")
    local blip = AddBlipForCoord(cfg.Location.x, cfg.Location.y, cfg.Location.z)
    SetBlipSprite(blip, 326) -- Car dealership sprite
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Player Dealership")
    EndTextCommandSetBlipName(blip)
    print("[Player Dealership] Blip created!")

    -- Create marker thread
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - cfg.Location)

        if distance < 10.0 then
            DrawMarker(1, cfg.Location.x, cfg.Location.y, cfg.Location.z - 1.0, 
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                1.5, 1.5, 1.0, 
                0, 255, 0, 100, 
                false, true, 2, false, nil, nil, false)
            
            if distance < 1.5 then
                if not RageUI.Visible(RMenu:Get('playerdealership', 'mainmenu')) then
                    DrawText3D(cfg.Location.x, cfg.Location.y, cfg.Location.z, "~g~Press ~w~[E] ~g~to access Player Dealership")
                    if IsControlJustPressed(0, 38) then -- E key
                        TriggerServerEvent("VICE:getPlayerVehicles")
                        RageUI.Visible(RMenu:Get('playerdealership', 'mainmenu'), true)
                    end
                end
            end
        end
    end
end)

-- RageUI Menus
RMenu.Add('playerdealership', 'mainmenu', RageUI.CreateMenu("", "Player Dealership", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "dealership"))
RMenu.Add('playerdealership', 'sellmenu', RageUI.CreateSubMenu(RMenu:Get('playerdealership', 'mainmenu'), "", "Sell Vehicle", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "dealership"))
RMenu.Add('playerdealership', 'viewmenu', RageUI.CreateSubMenu(RMenu:Get('playerdealership', 'mainmenu'), "", "View Listings", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "dealership"))
RMenu.Add('playerdealership', 'confirmmenu', RageUI.CreateSubMenu(RMenu:Get('playerdealership', 'sellmenu'), "", "Confirm Sale", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "dealership"))
RMenu.Add('playerdealership', 'purchasemenu', RageUI.CreateSubMenu(RMenu:Get('playerdealership', 'viewmenu'), "", "Purchase Vehicle", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "dealership"))

-- Main menu loop
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('playerdealership', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.ButtonWithStyle("Sell Vehicle", "List your vehicle for sale", {RightLabel = "→→→"}, true, function(_, _, Selected)
                if Selected then
                    TriggerServerEvent("VICE:getPlayerVehicles")
                end
            end, RMenu:Get('playerdealership', 'sellmenu'))

            RageUI.ButtonWithStyle("View Listings", "Browse vehicles for sale", {RightLabel = "→→→"}, true, function()
                TriggerServerEvent("VICE:getDealershipListings")
            end, RMenu:Get('playerdealership', 'viewmenu'))
        end)
    end

    if RageUI.Visible(RMenu:Get('playerdealership', 'sellmenu')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            for k, v in pairs(userVehicles) do
                if v.vehicle and v.vehicle ~= "" then
                    RageUI.ButtonWithStyle(getFriendlyVehicleName(v.vehicle), "Plate: " .. v.vehicle_plate, {RightLabel = "→→→"}, true, function(_, _, Selected)
                        if Selected then
                            selectedVehicle = v
                        end
                    end, RMenu:Get('playerdealership', 'confirmmenu'))
                end
            end
        end)
    end

    if RageUI.Visible(RMenu:Get('playerdealership', 'confirmmenu')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            if selectedVehicle then
                RageUI.Separator("Listing Fee: £" .. (cfg.ListingFee or 0))
                RageUI.ButtonWithStyle("Set Price", "Set your asking price", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        local price = KeyboardInput("Enter price", "", 10)
                        if price and tonumber(price) then
                            TriggerServerEvent("VICE:listVehicleForSale", selectedVehicle.vehicle, tonumber(price))
                            RageUI.GoBack()
                        end
                    end
                end)
            end
        end)
    end

    if RageUI.Visible(RMenu:Get('playerdealership', 'viewmenu')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            RageUI.ButtonWithStyle("Refresh Listings", "Update available vehicles", {RightLabel = "→→→"}, true, function(_, _, Selected)
                if Selected then
                    TriggerServerEvent("VICE:getDealershipListings")
                end
            end)

            for k, v in pairs(dealershipListings) do
                if v.vehicle and v.vehicle ~= "" then
                    RageUI.ButtonWithStyle(getFriendlyVehicleName(v.vehicle), "Price: £" .. v.price .. " | Seller: " .. (v.seller_name or "Unknown"), {RightLabel = "→→→"}, true, function(_, _, Selected)
                        if Selected then
                            selectedListing = v
                            if viewingVehicle then
                                DeleteEntity(viewingVehicle)
                            end
                            viewingVehicle = SpawnViewingVehicle(v.vehicle, cfg.ViewingLocation.x, cfg.ViewingLocation.y, cfg.ViewingLocation.z)
                        end
                    end, RMenu:Get('playerdealership', 'purchasemenu'))
                end
            end
        end)
    end

    if RageUI.Visible(RMenu:Get('playerdealership', 'purchasemenu')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false }, function()
            if selectedListing then
                RageUI.ButtonWithStyle("Purchase Vehicle", "Price: £" .. selectedListing.price, {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected then
                        TriggerServerEvent("VICE:purchaseVehicle", selectedListing.listing_id)
                        RageUI.GoBack()
                    end
                end)

                RageUI.ButtonWithStyle("Test Drive", "Test drive the vehicle", {RightLabel = "→→→"}, true, function(_, _, Selected)
                    if Selected and not testDriveActive then
                        StartTestDrive(selectedListing.vehicle)
                    end
                end)
            end
        end)
    end
end)

-- Helper Functions
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        return result
    else
        Wait(500)
        return nil
    end
end

-- Function to spawn vehicle for viewing
function SpawnViewingVehicle(vehicle, x, y, z)
    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
    local hash = GetHashKey(vehicle)
    RequestModel(hash)
    local tries = 0
    while not HasModelLoaded(hash) and tries < 100 do
        Citizen.Wait(10)
        tries = tries + 1
    end
    if HasModelLoaded(hash) then
        local veh = CreateVehicle(hash, x, y, z, GetEntityHeading(PlayerPedId()), false, false)
        SetEntityAsMissionEntity(veh)
        FreezeEntityPosition(veh, true)
        SetEntityInvincible(veh, true)
        SetVehicleDoorsLocked(veh, 4)
        SetModelAsNoLongerNeeded(hash)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        Citizen.CreateThread(function()
            while DoesEntityExist(veh) do
                Citizen.Wait(25)
                SetEntityHeading(veh, GetEntityHeading(veh) + 1 % 360)
            end
        end)
        return veh
    else
        VICE.notify("~r~Could not load vehicle")
        return -1
    end
end

-- Function to start test drive
function StartTestDrive(vehicle)
    if testDriveActive then return end
    testDriveActive = true
    local hash = GetHashKey(vehicle)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end
    if HasModelLoaded(hash) then
        if viewingVehicle then
            DeleteEntity(viewingVehicle)
            viewingVehicle = nil
        end
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), false))
        testDriveCar = CreateVehicle(hash, -1255.6181640625, -366.23623657227, 37.169906616211, 60.962993621826, false, false)
        if not DoesEntityExist(testDriveCar) then
            VICE.notify("~r~Failed to spawn test drive vehicle")
            testDriveActive = false
            return
        end
        testDriveSeconds = 60
        testDriveReturnCoords = GetEntityCoords(PlayerPedId())
        SetEntityAsMissionEntity(testDriveCar, true, true)
        SetModelAsNoLongerNeeded(hash)
        TaskWarpPedIntoVehicle(PlayerPedId(), testDriveCar, -1)
        -- Wait until player is in the vehicle
        local tries = 0
        while GetVehiclePedIsIn(PlayerPedId(), false) ~= testDriveCar and tries < 50 do
            TaskWarpPedIntoVehicle(PlayerPedId(), testDriveCar, -1)
            Citizen.Wait(100)
            tries = tries + 1
        end
        if tries >= 50 then
            VICE.notify("~r~Failed to enter test drive vehicle")
            DeleteEntity(testDriveCar)
            testDriveActive = false
            return
        end
        setVehicleFuel(testDriveCar, 100)
        VICE.notify("~g~You have 1 minute to test drive this vehicle!")
        for i = 0, 24 do
            SetVehicleModKit(testDriveCar, 0)
            RemoveVehicleMod(testDriveCar, i)
        end
        SetTimeout(60000, function()
            if testDriveActive then
                EndTestDrive()
            end
        end)
        Citizen.CreateThread(function()
            while testDriveActive do
                testDriveSeconds = testDriveSeconds - 1
                Wait(1000)
            end
        end)
        Citizen.CreateThread(function()
            while testDriveActive do
                if testDriveSeconds < 60 then
                    DrawText2D(0.5, 0.95, "~y~" .. testDriveSeconds .. " seconds left", 0.5)
                end
                Wait(0)
            end
        end)
        Citizen.CreateThread(function()
            while testDriveActive do
                local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                if currentVehicle and currentVehicle ~= testDriveCar then
                    DeleteVehicle(currentVehicle)
                    DeleteVehicle(testDriveCar)
                    SetEntityCoords(PlayerPedId(), testDriveReturnCoords.x, testDriveReturnCoords.y, testDriveReturnCoords.z)
                    VICE.notify("~g~Test drive over!")
                    testDriveActive = false
                    RageUI.Visible(RMenu:Get('playerdealership', 'mainmenu'), true)
                end
                Wait(0)
            end
        end)
    else
        VICE.notify("~r~Failed to load vehicle model")
        testDriveActive = false
    end
end

function EndTestDrive()
    if testDriveCar then
        DeleteEntity(testDriveCar)
        testDriveCar = nil
    end
    if testDriveReturnCoords then
        SetEntityCoords(PlayerPedId(), testDriveReturnCoords.x, testDriveReturnCoords.y, testDriveReturnCoords.z)
    end
    testDriveActive = false
    testDriveSeconds = 0
    RageUI.Visible(RMenu:Get('playerdealership', 'mainmenu'), true)
end

function DrawText2D(x, y, text, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Add cleanup for viewing vehicle when menu closes
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if viewingVehicle and not RageUI.Visible(RMenu:Get('playerdealership', 'viewmenu')) then
            DeleteEntity(viewingVehicle)
            viewingVehicle = nil
        end
    end
end)

-- Events
RegisterNetEvent("VICE:receivePlayerVehicles")
AddEventHandler("VICE:receivePlayerVehicles", function(vehicles)
    userVehicles = vehicles
end)

RegisterNetEvent("VICE:receiveDealershipListings")
AddEventHandler("VICE:receiveDealershipListings", function(listings)
    dealershipListings = listings
end)

RegisterNetEvent("VICE:vehicleListed")
AddEventHandler("VICE:vehicleListed", function(success, message)
    if success then
        selectedVehicle = nil -- Clear selection
        RageUI.GoBack()      -- Go back to main menu
        VICE.notify("~g~" .. message)
    else
        VICE.notify("~r~" .. message)
    end
end)

RegisterNetEvent("VICE:vehiclePurchased")
AddEventHandler("VICE:vehiclePurchased", function(success, message)
    if success then
        VICE.notify("~g~" .. message)
    else
        VICE.notify("~r~" .. message)
    end
end)

RegisterNetEvent("VICE:vehicleSold")
AddEventHandler("VICE:vehicleSold", function(success, message)
    if success then
        VICE.notify("~g~" .. message)
    else
        VICE.notify("~r~" .. message)
    end
end) 