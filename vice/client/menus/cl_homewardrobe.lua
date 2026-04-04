local a = nil
local b = {}
local c = ""
local function checkOutfits()
    if next(b) then
        return true
    end
    return false
end
RMenu.Add("vicewardrobe","mainmenu",RageUI.CreateMenu("", "", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "vice_wardrobeui"))
RMenu:Get("vicewardrobe", "mainmenu"):SetSubtitle("H~w~OME")
RMenu.Add("vicewardrobe","listoutfits",RageUI.CreateSubMenu(RMenu:Get("vicewardrobe", "mainmenu"),"","~s~W~w~ardrobe",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("vicewardrobe","equip",RageUI.CreateSubMenu(RMenu:Get("vicewardrobe", "listoutfits"),"","~s~W~w~ardrobe",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('vicewardrobe', 'mainmenu')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("List Outfits","",{RightLabel = "→→→"},checkOutfits(),function(d, e, f)
            end,RMenu:Get("vicewardrobe", "listoutfits"))
            RageUI.Button("Save Outfit", "", {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    tVICE.clientPrompt("Enter outfit name:", "", function(outfitName)
                        if outfitName and outfitName ~= '' then
                            if not VICE.isPlayerInAnimalForm() then
                                TriggerServerEvent("VICE:saveWardrobeOutfit", outfitName)
                            else
                                VICE.notify("~r~Cannot save animal in wardrobe.")
                            end
                        else
                            VICE.notify("~r~Invalid outfit name")
                        end
                    end)
                end
            end)
            RageUI.Button("Get Outfit Code","Gets a code for your current outfit which can be shared with other players.",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    if tVICE.isPlusClub() or tVICE.isPlatClub() then
                        TriggerServerEvent("VICE:getCurrentOutfitCode")
                    else
                        VICE.notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                        VICE.notify("~y~Available @ store.vicestudios.uk")
                    end
                end
            end,nil)
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('vicewardrobe', 'listoutfits')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            if b ~= {} then
                for g, h in pairs(b) do
                    RageUI.Button(g,"",{RightLabel = "→→→"},true,function(d, e, f)
                        if f then
                            c = g
                        end
                    end,RMenu:Get("vicewardrobe", "equip"))
                end
            else
                RageUI.Button("No outfits saved","",{RightLabel = "→→→"},true,function(d, e, f)
                end,RMenu:Get("vicewardrobe", "mainmenu"))
            end
        end, function()
        end)
    end
    if RageUI.Visible(RMenu:Get('vicewardrobe', 'equip')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Button("Equip Outfit","",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    TriggerServerEvent("VICE:equipWardrobeOutfit", c)
                end
            end,RMenu:Get("vicewardrobe", "listoutfits"))
            RageUI.Button("Delete Outfit","",{RightLabel = "→→→"},true,function(d, e, f)
                if f then
                    TriggerServerEvent("VICE:deleteWardrobeOutfit", c)
                end
            end,RMenu:Get("vicewardrobe", "listoutfits"))
        end, function()
        end)
    end
end)

local function i()
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get('vicewardrobe', 'mainmenu'), true)
end
local function j()
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get("vicewardrobe", "mainmenu"), false)
end
RegisterNetEvent("VICE:openOutfitMenu",function(k)
    if k then
        b = k
    else
        TriggerServerEvent("VICE:initWardrobe")
    end
    i()
end)
RegisterNetEvent("VICE:refreshOutfitMenu",function(k)
    b = k
end)
RegisterNetEvent("VICE:closeOutfitMenu",function()
    j()
end)