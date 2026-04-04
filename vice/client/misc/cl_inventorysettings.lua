local b = false

RegisterNetEvent("VICE:InventoryText")
AddEventHandler("VICE:InventoryText", function()
    tVICE.setCustomInventoryText()
end)

RegisterNetEvent("VICE:InventoryFont")
AddEventHandler("VICE:InventoryFont", function()
    tVICE.setCustomFontID()
end)

RegisterNetEvent("VICE:InventoryName")
AddEventHandler("VICE:InventoryName", function()
    tVICE.togglePlayerName()
end)

RegisterNetEvent("VICE:ResetInventoryText")
AddEventHandler("VICE:ResetInventoryText", function()
    tVICE.resetCustomInventoryText()
end)

RegisterNetEvent("VICE:InventoryBG")
AddEventHandler("VICE:InventoryBG", function()
    tVICE.changeInventoryBackgroundColor()
end)

RMenu.Add('inventorycolour', 'main', RageUI.CreateMenu("","VICE Inventory Customiser", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "vice_settingsui", "vice_settingsui"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('inventorycolour', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            if not b then 
                b = true 
            end
            RageUI.Checkbox("Use In-Game name", "Swaps between player's name and custom text for inventory title.", g, {}, 
                function()
                end,
                function()
                    g = true
                    TriggerEvent("VICE:InventoryName")
                end,
                function()
                    g = false
                    TriggerEvent("VICE:InventoryName")
                end)

            RageUI.ButtonWithStyle("Change Inventory Text", "Changes the title inside your inventory.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("VICE:InventoryText")
                end
            end)

            RageUI.ButtonWithStyle("Change Inventory Font", "Changes the title font inside your inventory.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("VICE:InventoryFont")
                end
            end)

            RageUI.Separator("~y~Colour related options")

            RageUI.ButtonWithStyle("Change Small bar colour", "Set inventorys small bar colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    VICE.setInventoryColour()
                end
            end)

            RageUI.ButtonWithStyle("Change Header colour", "Set inventory header colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tVICE.changeHeaderBackgroundColorRGB()
                end
            end)

            RageUI.ButtonWithStyle("Change Background Colour", "Set the inventory background colour with RGB values.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tVICE.changeInventoryBackgroundColor()
                end
            end)
            
            RageUI.Separator("~y~Reset options")

            RageUI.ButtonWithStyle("Reset Inventory Text", "Resets back to the default text.", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerEvent("VICE:ResetInventoryText")
                end
            end)

            RageUI.ButtonWithStyle("Reset Small bar Colour", "Set the Small bar colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tVICE.setInventoryOriginalColour()
                end
            end)

            RageUI.ButtonWithStyle("Reset Header Colour", "Set the headers colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tVICE.ResetHeaderColour()
                end
            end)

            RageUI.ButtonWithStyle("Reset Background Colour", "Set the background colour back to its old value.", {RightLabel = "→→→"}, true, function(ad, ae, af)
                if af then
                    tVICE.setBGInventoryReset()
                end
            end)
        end)
    end
end, 1)