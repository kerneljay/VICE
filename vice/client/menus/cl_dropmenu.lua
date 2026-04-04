local crateLocations = {
    {name = "Rebel", coords = vector3(2558.714, 6155.399, 161.8665)},
    {name = "Paleto", coords = vector3(375.0662, 6852.992, 4.083869)},
    {name = "Large Arms", coords = vector3(-880.6389, 4414.064, 20.36799)},
    {name = "Military Base", coords = vector3(-3032.489, 3402.802, 8.417397)},
    {name = "Diamond Mine River", coords = vector3(-119.2925, 3022.1, 32.18053)},
    {name = "Large Arms Bridge", coords = vector3(36.50002, 4344.443, 41.47789)},
    {name = "Mount Chilliad", coords = vector3(499.4316, 5536.806, 777.696)},
    {name = "Wine Mansion", coords = vector3(-1518.191, 2140.92, 55.53791)},
    {name = "Vinewood 1", coords = vector3(-191.0104, 1477.419, 288.4325)},
    {name = "Vinewood Sign", coords = vector3(828.4253, 1300.878, 363.6823)},
    {name = "Wind Turbines", coords = vector3(2348.622, 2138.061, 104.3607)},
    {name = "Vinewood Lake", coords = vector3(1877.604, 352.0831, 162.9319)},
    {name = "Island Near LSD", coords = vector3(2836.016, -1447.626, 10.45845)},
    {name = "Youtool Hill", coords = vector3(2543.626, 3615.884, 96.89672)},
    {name = "H Bunker", coords = vector3(2856.744, 4631.319, 48.39237)},
    {name = "Cayo Perico", coords = vector3(4784.917, -5530.945, 19.46264)},
    {name = "Biker City", coords = vector3(254.3428, 3583.882, 33.73079)},
    {name = "Racetrack", coords = vector3(-2556.779296875, 4279.4384765625, 101.58396148682)},
    {name = "Rebel 2", coords = vector3(1618.822265625, 6658.2407226562, 23.482976913452)},
    {name = "Coke Drop", coords = vector3(-557.46905517578, 5369.7192382812, 70.214332580566)},
}

RMenu.Add('VICECrateDrop', 'main', RageUI.CreateMenu("", "~y~Crate Drop Menu", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), 'menus', 'VICE_marketui'))
RMenu.Add("VICECrateDrop", "confirm", RageUI.CreateSubMenu(RMenu:Get('VICECrateDrop', 'main')), VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())

local selectedLocation = nil
local cooldownActive = false
local cooldownTime = 60

RegisterCommand("cratedrop", function()
    if VICE.getStaffLevel() >= 5 then
    if cooldownActive then
        VICE.notify("~r~Crate drop is on cooldown!")
        return
    end
    RageUI.Visible(RMenu:Get("VICECrateDrop", "main"), not RageUI.Visible(RMenu:Get("VICECrateDrop", "main")))
    else
        VICE.notify("~r~You do not have permission to use this command.")
    end
end)

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICECrateDrop", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(crateLocations) do
                RageUI.Button(v.name, "Drop crate at " .. v.name, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        selectedLocation = v
                    end
                end, RMenu:Get("VICECrateDrop", "confirm"))
            end
        end)
    end
end)

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICECrateDrop", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            if selectedLocation then
                RageUI.Separator("Location: " .. selectedLocation.name)                
                RageUI.Button("~g~Confirm Drop", "Drop the crate at " .. selectedLocation.name, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        TriggerEvent("VICE:crateDrop", selectedLocation.coords,  math.random(1, #crateLocations), false)
                        cooldownActive = true
                        VICE.notify("~g~Crate drop called! Cooldown: " .. cooldownTime .. " seconds")
                        
                        SetTimeout(cooldownTime * 1000, function()
                            cooldownActive = false
                            VICE.notify("~g~Crate drop is now available!")
                        end)
                        
                        RageUI.CloseAll()
                    end
                end)
                
                RageUI.Button("~r~Go Back", "Return to location selection", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    if Selected then
                    end
                end, RMenu:Get("VICECrateDrop", "main"))
            end
        end)
    end
end)