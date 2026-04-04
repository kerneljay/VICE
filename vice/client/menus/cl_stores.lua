RMenu.Add('VICEStores', 'main', RageUI.CreateMenu("", "~s~I~w~tems", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), 'menus', 'vice_marketui'))
RMenu.Add("VICEStores", "confirm", RageUI.CreateSubMenu(RMenu:Get('VICEStores', 'main', VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), 'menus', 'vice_marketui')))

local cfg = module("cfg/cfg_stores")
local ShopAMT = {}
local Index = 1
for i = 1, 100 do
    table.insert(ShopAMT,tostring(i))
end

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICEStores", "main")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("~y~Items")
            for k, v in pairs(cfg.shopItems) do
                RageUI.Button(v.name, nil, {RightLabel = "£".. getMoneyStringFormatted(v.price)}, true, function(Hovered, Active, Selected)
                    if Selected then
                        cPrice = v.price
                        cHash = v.itemID
                        cName = v.name
                    end
                end, RMenu:Get("VICEStores", "confirm"))
            end
        end)
    end
    if RageUI.Visible(RMenu:Get("VICEStores", "confirm")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true}, function()
            RageUI.Separator("Item Name: " .. cName, function() end)
            RageUI.Separator("Item Price: £" .. getMoneyStringFormatted(cPrice * Index), function() end)
            RageUI.List(cName, ShopAMT, Index, nil, {}, true, function(Hovered, Active, Selected, AIndex)
                Index = AIndex
            end)
            RageUI.Button("Confirm Purchase" , nil, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent("VICE:BuyStoreItem", cHash, tonumber(Index))
                end
            end, RMenu:Get("VICEStores", "main")) 
        end) 
    end
end)

Citizen.CreateThread(function()
    local function EnterArea()
        RageUI.Visible(RMenu:Get("VICEStores", "main"), true)
    end
    local function LeaveArea()
        RageUI.Visible(RMenu:Get("VICEStores", "main"), false)
        RageUI.Visible(RMenu:Get("VICEStores", "confirm"), false)
    end
    for i,v in pairs(cfg.shops) do
        VICE.createArea("viceshop_"..i,v,1.5,6,EnterArea,LeaveArea)
        tVICE.addMarker(v.x,v.y,v.z, 0.7, 0.7, 0.5, 0, 255, 125, 125, 50, 29, true, true)
    end
end)
