local cfg = module("cfg/cfg_aastore")

RMenu.Add('VICEAAStores', 'main', RageUI.CreateMenu("", "~y~AA Store", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), 'menus', 'vice_marketui'))
RMenu.Add("VICEAAStores", "confirm", RageUI.CreateSubMenu(RMenu:Get('VICEAAStores', 'main',  VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), 'menus', 'vice_marketui')))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICEAAStores", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            for k, v in pairs(cfg.shopAAItems) do
                RageUI.Button(v.name, nil, {RightLabel = "£".. getMoneyStringFormatted(v.price)}, true, function(Hovered, Active, Selected)
                    if Selected then
                        cPrice = v.price
                        cHash = v.itemID
                        cName = v.name
                    end
                end, RMenu:Get("VICEAAStores", "confirm"))
            end
        end)
    end
end)

local ShopAAAMT = {
    '1','2','3','4','5','6','7','8','9','10'
}

local Index = 1
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICEAAStores", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("Item Name: " .. cName, function() end)
            RageUI.Separator("Item Price: £" .. getMoneyStringFormatted(cPrice * Index), function() end)
            RageUI.List(cName, ShopAAAMT, Index, nil, {}, true, function(Hovered, Active, Selected, AIndex)
                Index = AIndex
            end)
            RageUI.Button("Confirm Purchase" , nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("VICE:BuyAAStoreItem", cHash, tonumber(Index))
                end
            end, RMenu:Get("VICEAAStores", "main")) 
        end) 
    end
end)

local inAAMenu = false
local currentAAShop = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        for k, v in pairs(cfg.aashops) do
            if isInArea(v, 100.0) then
                DrawMarker(29, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 14, 212, 0, 250, true, true, false, false, nil, nil, false)
            end
            if isInArea(v, 1.0) and inAAMenu == false then
                alert('Press ~INPUT_VEH_HORN~ to open the store')
                if IsControlJustPressed(0, 51) then 
                    inAAMenu = true
                    currentAAShop = k
                    PlaySound(-1,"Hit","RESPAWN_SOUNDSET",0,0,1)
                    RageUI.Visible(RMenu:Get("VICEAAStores", "main"), true)
                    cLoaction = v
                end
            end
            if isInArea(v, 1.0) == false and inAAMenu and k == currentAAShop then
                inAAMenu = false
                currentAAShop = nil
                RageUI.ActuallyCloseAll()
            end
        end
    end
end)

tVICE.addBlip(489.73645019531,-1332.7416992188,29.332813262939, 446, 5, "AA Mechanic")