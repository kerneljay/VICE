-- local kitMenuOpen = false

-- -- Create the menu
-- local menu = RageUI.CreateMenu("", "Select an option (Keep in mind Cooldown is 30 minutes)")
-- menu.X = 1350 -- Move to right
-- menu.Y = 50  -- Move to top
-- menu.Closed = function()
--     kitMenuOpen = false
-- end
-- menu.EnableMouse = false
-- menu.Glare = false
-- menu.Background = "" -- Remove background
-- menu.Sprite = { Dictionary = "menus", Texture = "kit", Y = 0, Width = 431 }
-- RMenu.Add('kitmenu', 'main', menu)

-- -- Define available kits
-- local kits = {
--     {name = "VICE Mosin Kit", description = "Mosin Nagant and 100% Armour", command = "vicekit"},
--     {name = "VICE Dragunov SVD Kit", description = "Dragunov SVD and 100% Armour", command = "sniperkit"},
--     --{name = "Mosin Kit", description = "Mosin and Armour", command = "mosinkit"},
--     --{name = "Sniper Kit", description = "SVD and Armour", command = "sniperkit"},
--     --{name = "SMG Kit", description = "SMG and Armour", command = "smgkit"}
-- }

-- -- Function to open kit menu
-- function OpenKitMenu()
--     if kitMenuOpen then return end
--     kitMenuOpen = true

--     RageUI.Visible(RMenu:Get('kitmenu', 'main'), true)
--     Citizen.CreateThread(function()
--         while kitMenuOpen do
--             Wait(1)
--             RageUI.IsVisible(RMenu:Get('kitmenu', 'main'), true, false, true, function()
--                 for _, kit in ipairs(kits) do
--                     RageUI.Button(kit.name, kit.description, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
--                         if Selected then
--                             TriggerServerEvent('VICE:redeemKit', kit.command)
--                         end
--                     end)
--                 end
--             end, function()
--             end)

--             if not RageUI.Visible(RMenu:Get('kitmenu', 'main')) then
--                 kitMenuOpen = false
--                 break
--             end
--         end
--     end)
-- end

-- -- Register command to open kit menu
-- RegisterCommand('kit', function()
--     OpenKitMenu()
-- end, false)

-- -- Event to handle server response
-- RegisterNetEvent('VICE:kitResponse')
-- AddEventHandler('VICE:kitResponse', function(message)
--     VICE.notify(message)
-- end) 