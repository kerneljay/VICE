drawInventoryUI = false
CloseToRestart = false
local cfgweapon = module("cfg/weapons")
local a = false
local b = false
local c = false
local d = 0.00
local e = 0.00
local f = nil
local g = nil
local h = nil
local i = false
local j = nil
local k = 0
local l = 0
local m = false
local n = {
    ["9mm Bullets"] = true,
    ["12 Gauge Bullets"] = true,
    [".308 Sniper Rounds"] = true,
    ["7.62mm Bullets"] = true,
    ["5.56mm NATO"] = true,
    [".357 Bullets"] = true,
    ["Police Issued 5.56mm"] = true,
    ["Police Issued .308 Sniper Rounds"] = true,
    ["Police Issued 9mm"] = true,
    ["Police Issued 12 Gauge"] = true
}
local o = {r = 255, g = 0, b = 0}
local p = nil
local q = nil
local r = nil
local s = false
inventoryType = nil
local t = false
local function u()
    if IsUsingKeyboard(2) and not tVICE.isInComa() and not tVICE.isHandcuffed() then
        TriggerServerEvent("VICE:FetchPersonalInventory")
        TriggerServerEvent("VICE:FetchPersonalWeapons")
        if not i then
            drawInventoryUI = not drawInventoryUI
            if drawInventoryUI then
                setCursor(1)
            else
                setCursor(0)
                inGUIVICE = false
                StopAnimTask(PlayerPedId(), "amb@medic@standing@tendtodead@base", "base", 1.0)
                if p then
                    VICE.vc_closeDoor(q, 5)
                    p = nil
                    q = nil
                    r = nil
                    TriggerEvent("VICE:clCloseTrunk")
                end
                TriggerEvent("VICE:closeSecondInventory")
                inventoryType = nil
                VICESecondItemList = {}
            end
        else
            VICE.notify("~r~Cannot open inventory right before a restart!")
        end
    end
end
RegisterCommand("inventory", u, false)
RegisterKeyMapping("inventory", "Open Inventory", "KEYBOARD", "L")
Citizen.CreateThread(function()
    while true do
        if drawInventoryUI and IsDisabledControlJustReleased(0, 200) then
            u()
        end
        Wait(0)
    end
end)
local v = {}
local FormattedWeaponData = {}
local w = 0
local VICESecondItemList = {}
local x = 0
local y = 14
local currentInventoryMaxWeight = 30
function VICE.getSpaceInFirstChest()
    return currentInventoryMaxWeight - d
end
function VICE.isInventoryOpen()
    return drawInventoryUI
end
function VICE.getSpaceInSecondChest()
    local z = 0
    if next(VICESecondItemList) == nil then
        return e
    else
        for u, w in pairs(VICESecondItemList) do
            z = z + w.amount * w.Weight
        end
        return e - z
    end
end


RegisterNetEvent(
    "VICE:FetchPersonalInventory",
    function(A, B, C)
        v = A
        d = B
        if not C or not tonumber(C) then
            return
        end
        currentInventoryMaxWeight = C
    end
)
RegisterNetEvent("VICE:FetchPersonalWeapons",function(A, B, C)
    FormattedWeaponData = A
end)
RegisterNetEvent("VICE:callmemaybe",function(x, y, D, E)
    inventoryType = "Dumpster"
    VICESecondItemList = x
    e = D
    c = true
    drawInventoryUI = true
    setCursor(1)
    if D then
        g = D
        h = GetEntityCoords(VICE.getPlayerPed())
        if D == "notmytrunk" then
            j = GetEntityCoords(VICE.getPlayerPed())
        end
        if string.match(D, "player_") then
            l = string.gsub(D, "player_", "")
        else
            l = 0
        end
    end
end)
RegisterNetEvent("VICE:SendSecondaryInventoryData",function(x, y, D, E)
    if E then
        r = E
        inventoryType = "CarBoot"
    end
    VICESecondItemList = x
    e = D
    c = true
    drawInventoryUI = true
    setCursor(1)
    if D then
        g = D
        h = GetEntityCoords(VICE.getPlayerPed())
        if D == "notmytrunk" then
            j = GetEntityCoords(VICE.getPlayerPed())
        end
        if string.match(D, "player_") then
            l = string.gsub(D, "player_", "")
        else
            l = 0
        end
    end
end)
RegisterNetEvent("VICE:CloseToRestart", function(x)
    CloseToRestart = true 
    TriggerServerEvent('VICE:CloseToRestartServer', true)
    Citizen.CreateThread(function()
        while true do
            VICESecondItemList = {}
            c = false
            drawInventoryUI = false
            setCursor(0)
            Wait(50)
        end
    end)
end)
RegisterNetEvent(
    "VICE:closeSecondInventory",
    function()
        VICESecondItemList = {}
        c = false
        drawInventoryUI = false
        g = nil
        setCursor(0)
    end
)
AddEventHandler(
    "VICE:clCloseTrunk",
    function()
        c = false
        drawInventoryUI = false
        g = nil
        setCursor(0)
        f = nil
        inGUIVICE = false
        VICESecondItemList = {}
    end
)
local owner_id = 0
AddEventHandler(
    "VICE:clOpenTrunk",
    function()
        local F, G, H = VICE.getNearestOwnedVehicle(3.5)
        r = G
        q = F
        owner_id = H
        if F and IsPedInAnyVehicle(PlayerPedId(), false) == false then
            p = GetEntityCoords(PlayerPedId())
            VICE.vc_openDoor(G, 5)
            inventoryType = "CarBoot"
            print("Opening trunk",G,H)
            TriggerServerEvent("VICE:FetchTrunkInventory", G, H)
        else
            VICE.notify("~r~You don't have the keys to this vehicle")
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if f and c then
                local I = GetEntityCoords(VICE.getPlayerPed())
                local J = GetEntityCoords(f)
                local K = #(I - J)
                if K > 10.0 then
                    TriggerEvent("VICE:clCloseTrunk")
                    TriggerServerEvent("VICE:closeChest")
                end
            end
            if g == "house" and c then
                local I = GetEntityCoords(VICE.getPlayerPed())
                local J = h
                local K = #(I - J)
                if K > 5.0 then
                    TriggerEvent("VICE:clCloseTrunk")
                    TriggerServerEvent("VICE:closeChest")
                end
            end
            if g == "dumpster" and c then
                local I = GetEntityCoords(VICE.getPlayerPed())
                local J = h
                local K = #(I - J)
                if K > 5.0 then
                    TriggerServerEvent("VICE:closeChest")
                end
            end
            if g == "notmytrunk" and c then
                local I = GetEntityCoords(VICE.getPlayerPed())
                local J = j
                local K = #(I - J)
                if K > 5.0 then
                    TriggerEvent("VICE:clCloseTrunk")
                    TriggerServerEvent("VICE:closeChest")
                end
            end
            if l ~= 0 and c then
                local I = GetEntityCoords(VICE.getPlayerPed())
                local J = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(tonumber(l))))
                local K = #(I - J)
                if K > 5.0 then
                    TriggerEvent("VICE:clCloseTrunk")
                    TriggerServerEvent("VICE:closeChest")
                end
            end
            if f == nil and g == "trunk" then
                c = false
                drawInventoryUI = false
            end
            Wait(500)
        end
    end
)
local function L(M, N)
    local O = sortAlphabetically(M)
    local P = #O
    local Q = N * y
    local R = {}
    for S = Q + 1, math.min(Q + y, P) do
        table.insert(R, O[S])
    end
    return R
end

local alreadyselecting = false
local playerIds = {}

function tVICE.NearbyDrawRect()
  if not alreadyselecting then
    local selected
    playerIds = {}
    for id in pairs(tVICE.getNearestPlayers(12.0)) do
        table.insert(playerIds, id)
    end
    -- for i = 1, 12 do -- for testing
    --     table.insert(playerIds, i)
    -- end
    alreadyselecting = true
    while not selected and drawInventoryUI do
        Wait(0)
        for i = 1, #playerIds do
            local isInGang = VICE.isPlayerInSelectedGang(playerIds[i])
            local left = 0.1521 - 0.115 / 2 - 0.05 + 0.05 
            local top = 0.253 + (i * 0.04) - 0.031 / 2
            local right = 0.251 + 0.1521 / 2 - 0.05 - 0.07  
            local bottom = 0.253 + (i * 0.04) + 0.031 / 2
        
            if CursorInZone(left, top, right, bottom) then
                local center_x = (left + right) / 2
                local center_y = (top + bottom) / 2
                local width = (right - left) / 2 
                local height = bottom - top
                DrawRect(0.1521, 0.253 + (i * 0.04), 0.115, 0.031, o.r, o.g, o.b, 150)
                local coords = VICE.isInSpectate() and GetFinalRenderedCamCoord() or GetEntityCoords(VICE.getPlayerPed())
                local pedcoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerIds[i])))
                if #(coords - pedcoords) < 250.0 then
                    DrawMarker(2,pedcoords.x,pedcoords.y,pedcoords.z + 1.1,0.0,0.0,0.0,0.0,-180.0,0.0,0.4,0.4,0.4,0,255,255,125,false,true,2, false)
                end
                if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                    PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                    selected = playerIds[i]
                end
            else
                DrawRect(0.1521, 0.253 + (i * 0.04), 0.115, 0.031, 0,0,0,200)
            end
            DrawAdvancedText(0.237, 0.260 + (i * 0.04), 0.005, 0.0028, 0.366,"["..playerIds[i].."] "..(isInGang and VICE.getPlayerName(playerIds[i]) or ""), 255, 255, 255, 255, 4, 0)
        end
        if IsControlJustPressed(1, 177) or IsControlJustPressed(1, 194) or IsControlJustPressed(1, 202) then
            break
        end
    end
    alreadyselecting = false
    return selected
  end
end

function tVICE.getAllWeapons()
    local playerPed = VICE.getPlayerPed()
    for weaponName, _ in pairs(cfgweapon.weapons) do
        if weaponName ~= "WEAPON_UNARMED" and weaponName ~= "GADGET_PARACHUTE" then
            local weaponHash = GetHashKey(weaponName)
            if HasPedGotWeapon(playerPed, weaponHash, false) then
                return true
            end
        end
    end
    return false
end

Citizen.CreateThread(
    function()
        while true do
            if drawInventoryUI then
                DrawRect(0.5, 0.53, 0.572, 0.508, 0, 0, 0, 150)
                DrawAdvancedText(0.615, 0.232, 0.005, 0.0028, 0.68, "VICE INVENTORY", 255, 255, 255, 255, VICE.getFontId("Akrobat-ExtraBold"), 0)
                DrawRect(0.5, 0.24, 0.572, 0.058, 0, 0, 0, 225)
                if not c then
                    if alreadyselecting and #playerIds > 0 then
                       DrawAdvancedText(0.246, 0.243, 0.005, 0.0008, 0.38, "PLAYERS NEARBY", 255, 255, 255, 255, VICE.getFontId("Akrobat-ExtraBold"), 0)
                    end
                    if VICE.getShowNewInventoryUI() and tVICE.getAllWeapons() then
                        DrawAdvancedText(0.944, 0.243, 0.005, 0.0008, 0.38, "EQUIPPED WEAPONS", 255, 255, 255, 255, VICE.getFontId("Akrobat-ExtraBold"), 0)
                        DrawRect(0.848, 0.24, 0.115, 0.058, 0, 0, 0, 225) -- weapons
                        DrawRect(0.848, 0.53, 0.115, 0.508, 0, 0, 0, 150) -- weapons 
                    end
                    if alreadyselecting and #playerIds > 0 then
                        DrawRect(0.152, 0.53, 0.115, 0.508, 0, 0, 0, 150) -- nearby 
                        DrawRect(0.152, 0.24, 0.115, 0.058, 0, 0, 0, 225) -- nearby 
                    end
                end
                DrawRect(0.342, 0.536, 0.215, 0.436, 0, 0, 0, 150)
                DrawRect(0.652, 0.537, 0.215, 0.436, 0, 0, 0, 150)
                if s then
                    DrawAdvancedText(0.664, 0.305, 0.005, 0.0028, 0.325, "Loot All", 255, 255, 255, 255, 6, 0)
                end
                if c and r then
                    DrawAdvancedText(0.440, 0.305, 0.005, 0.0028, 0.325, "Transfer All", 255, 255, 255, 255, 6, 0)
                end
                if next(v) then
                    DrawAdvancedText(0.355, 0.305, 0.005, 0.0028, 0.325, "Equip All", 255, 255, 255, 255, 6, 0)
                end
                if m then
                    DrawAdvancedText(0.575, 0.364, 0.005, 0.0028, 0.325, "Use", 255, 255, 255, 255, 6, 0)
                    DrawAdvancedText(0.615, 0.364, 0.005, 0.0028, 0.325, "Use All", 255, 255, 255, 255, 6, 0)
                    DrawAdvancedText(0.575, 0.634, 0.005, 0.0028, 0.35, "Give X", 255, 255, 255, 255, 6, 0)
                    DrawAdvancedText(0.615, 0.634, 0.005, 0.0028, 0.35, "Give All", 255, 255, 255, 255, 6, 0)
                else
                    DrawAdvancedText(0.595,0.634,0.005,0.0028,0.35,"Give to Nearest Player",255,255,255,255,6,0)
                    DrawAdvancedText(0.594, 0.364, 0.005, 0.0028, 0.4, "Use", 255, 255, 255, 255, 6, 0)
                end
                DrawAdvancedText(0.594, 0.454, 0.005, 0.0028, 0.4, "Move", 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.575, 0.545, 0.005, 0.0028, 0.325, "Move X", 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.615, 0.545, 0.005, 0.0028, 0.325, "Move All", 255, 255, 255, 255, 6, 0)
                DrawAdvancedText(0.594, 0.722, 0.005, 0.0028, 0.4, "Drop", 255, 255, 255, 255, 6, 0)
                if VICE.getShowNewInventoryUI() and not c and tVICE.getAllWeapons() then
                   DrawAdvancedText(0.944, 0.722, 0.005, 0.0028, 0.4, "Store All", 255, 255, 255, 255, 6, 0)
                end
                DrawAdvancedText(0.488, 0.335, 0.005, 0.0028, 0.366, "Amount", 255, 255, 255, 255, 4, 0)
                DrawAdvancedText(0.404, 0.335, 0.005, 0.0028, 0.366, "Item Name", 255, 255, 255, 255, 4, 0)
                DrawAdvancedText(0.521, 0.335, 0.005, 0.0028, 0.366, "Weight", 255, 255, 255, 255, 4, 0)
                DrawAdvancedText(0.833, 0.776, 0.005, 0.0028, 0.288, "[Press L to close]", 255, 255, 255, 255, 4, 0)
                DrawRect(0.5, 0.273, 0.572, 0.0069999999999999, o.r, o.g, o.b, 150)
                if not c then
                    if alreadyselecting and #playerIds > 0 then
                       DrawRect(0.152, 0.273, 0.115, 0.0069999999999999, o.r, o.g, o.b, 150) -- nearby
                    end
                    if tVICE.getAllWeapons() and VICE.getShowNewInventoryUI() then
                       DrawRect(0.848, 0.273, 0.115, 0.0069999999999999, o.r, o.g, o.b, 150) -- weapons
                    end
                end
                DisableControlAction(0, 200, true)
                if table.count(v) > y then
                    DrawAdvancedText(0.528, 0.742, 0.005, 0.0008, 0.4, "Next", 255, 255, 255, 255, 6, 0)
                    if
                        CursorInArea(0.412, 0.432, 0.72, 0.76) and
                            (IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329))
                     then
                        local T = math.floor(table.count(v) / y)
                        w = math.min(w + 1, T)
                    end
                    DrawAdvancedText(0.349, 0.742, 0.005, 0.0008, 0.4, "Previous", 255, 255, 255, 255, 6, 0)
                    if
                        CursorInArea(0.239, 0.269, 0.72, 0.76) and
                            (IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329))
                     then
                        w = math.max(w - 1, 0)
                    end
                end
                inGUIVICE = true
                if not c then
                    DrawAdvancedText(
                        0.751,
                        0.525,
                        0.005,
                        0.0028,
                        0.49,
                        "2nd Inventory not available",
                        255,
                        255,
                        255,
                        118,
                        6,
                        0
                    )
                elseif g then
                    DrawAdvancedText(0.798, 0.335, 0.005, 0.0028, 0.366, "Amount", 255, 255, 255, 255, 4, 0)
                    DrawAdvancedText(0.714, 0.335, 0.005, 0.0028, 0.366, "Item Name", 255, 255, 255, 255, 4, 0)
                    DrawAdvancedText(0.831, 0.335, 0.005, 0.0028, 0.366, "Weight", 255, 255, 255, 255, 4, 0)
                    local U = 0.026
                    local V = 0.026
                    local W = 0
                    local X = 0
                    for Y, Z in pairs(sortAlphabetically(VICESecondItemList)) do
                        X = X + Z["value"].amount * Z["value"].Weight
                    end
                    local _ = L(VICESecondItemList, x)
                    if #_ == 0 then
                        x = 0
                    end
                    for Y, Z in pairs(_) do
                        local a0 = Z.title
                        local a1 = Z["value"]
                        local a2, a3, z = a1.ItemName, a1.amount, a1.Weight
                        DrawAdvancedText(0.714, 0.360 + W * V, 0.005, 0.0028, 0.366, a2, 255, 255, 255, 255, 4, 0)
                        DrawAdvancedText(0.831, 0.360 + W * V,0.005,0.0028,0.366,tostring(z * a3) .. "kg",255,255,255,255,4,0)
                        DrawAdvancedText(0.798, 0.360 + W * V, 0.005, 0.0028, 0.366, getMoneyStringFormatted(a3), 255, 255, 255, 255, 4, 0)
                        if CursorInArea(0.5443, 0.7584, 0.3435 + W * V, 0.3690 + W * V) then
                            DrawRect(0.652, 0.331 + U * (W + 1), 0.215, 0.026, o.r, o.g, o.b, 150)
                            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                if not lockInventorySoUserNoSpam then
                                    b = a0
                                    a = false
                                    k = a3
                                    selectedItemWeight = z
                                    lockInventorySoUserNoSpam = true
                                    Citizen.CreateThread(
                                        function()
                                            Wait(250)
                                            lockInventorySoUserNoSpam = false
                                        end
                                    )
                                end
                            end
                        elseif a0 == b then
                            DrawRect(0.652, 0.331 + U * (W + 1), 0.215, 0.026, o.r, o.g, o.b, 150)
                        end
                        W = W + 1
                    end
                    if X / e > 0.5 then
                        if X / e > 0.9 then
                            DrawAdvancedText(
                                0.826,
                                0.307,
                                0.005,
                                0.0028,
                                0.366,
                                "Weight: " .. X .. "/" .. e .. "kg",
                                255,
                                50,
                                0,
                                255,
                                4,
                                0
                            )
                        else
                            DrawAdvancedText(
                                0.826,
                                0.307,
                                0.005,
                                0.0028,
                                0.366,
                                "Weight: " .. X .. "/" .. e .. "kg",
                                255,
                                165,
                                0,
                                255,
                                4,
                                0
                            )
                        end
                    else
                        DrawAdvancedText(
                            0.826,
                            0.307,
                            0.005,
                            0.0028,
                            0.366,
                            "Weight: " .. X .. "/" .. e .. "kg",
                            255,
                            255,
                            153,
                            255,
                            4,
                            0
                        )
                    end
                    -- if s then
                    --     DrawAdvancedText(0.654,0.333,0.005,0.0028,0.366,"LootBag",255,255,255,255,4,0)
                    -- end
                    if table.count(VICESecondItemList) > y then
                        DrawAdvancedText(0.84, 0.742, 0.005, 0.0008, 0.4, "Next", 255, 255, 255, 255, 6, 0)
                        if
                            CursorInArea(0.735, 0.755, 0.72, 0.76) and
                                (IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329))
                         then
                            local T = math.floor(table.count(VICESecondItemList) / y)
                            x = math.min(x + 1, T)
                        end
                        DrawAdvancedText(0.661, 0.742, 0.005, 0.0008, 0.4, "Previous", 255, 255, 255, 255, 6, 0)
                        if
                            CursorInArea(0.55, 0.58, 0.72, 0.76) and
                                (IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329))
                         then
                            x = math.max(x - 1, 0)
                        end
                    end
                end
                if m then
                    if CursorInArea(0.46, 0.496, 0.33, 0.383) then
                        DrawRect(0.48, 0.359, 0.0375, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:UseItem", a, "Plr")
                                elseif b and g ~= nil and c then
                                    VICEserver.useInventoryItem({b})
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.48, 0.359, 0.0375, 0.056, 0, 0, 0, 150)
                    end
                    if CursorInArea(0.501, 0.536, 0.329, 0.381) then
                        DrawRect(0.52, 0.359, 0.0375, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:UseAllItem", a, "Plr")
                                elseif b and g ~= nil and c then
                                    VICEserver.useInventoryItem({b})
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.52, 0.359, 0.0375, 0.056, 0, 0, 0, 150)
                    end
                else
                    if CursorInArea(0.4598, 0.5333, 0.3283, 0.3848) then
                        DrawRect(0.5, 0.36, 0.075, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:UseItem", a, "Plr")
                                elseif b and g ~= nil and c then
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.5, 0.36, 0.075, 0.056, 0, 0, 0, 150)
                    end
                end
                if not m then
                    if CursorInArea(0.4598, 0.5333, 0.5931, 0.6477) then
                        DrawRect(0.5, 0.63, 0.075, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:GiveItem", a, "Plr")
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(
                                function()
                                    Wait(250)
                                    lockInventorySoUserNoSpam = false
                                end
                            )
                        end
                    else
                        DrawRect(0.5, 0.63, 0.075, 0.056, 0, 0, 0, 150)
                    end
                end
                if CursorInArea(0.4598, 0.5333, 0.418, 0.4709) then
                    DrawRect(0.5, 0.45, 0.075, 0.056, o.r, o.g, o.b, 150)
                    if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                        PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        if not lockInventorySoUserNoSpam then
                            if c then
                                if a and g and c then
                                    if VICE.getPlayerCombatTimer() > 0 then
                                        notify("~r~You can not store items whilst in combat.")
                                    else
                                        if inventoryType == "CarBoot" then
                                            TriggerServerEvent("VICE:MoveItem", "Plr", a, r, false, owner_id)
                                        elseif inventoryType == "Housing" then
                                            TriggerServerEvent("VICE:MoveItem", "Plr", a, "home", false)
                                        elseif inventoryType == "Dumpster" then
                                            TriggerServerEvent("VICE:MoveItem", "Plr", a, "dumpster", false)
                                        elseif inventoryType == "Crate" then
                                            TriggerServerEvent("VICE:MoveItem", "Plr", a, "crate", false)
                                        elseif s then
                                            TriggerServerEvent("VICE:MoveItem", "Plr", a, "LootBag", true)
                                        end
                                    end
                                elseif b and g and c then
                                    if inventoryType == "CarBoot" then
                                        TriggerServerEvent("VICE:MoveItem", inventoryType, b, r, false, owner_id)
                                    elseif inventoryType == "Housing" then
                                        TriggerServerEvent("VICE:MoveItem", inventoryType, b, "home", false)
                                    elseif inventoryType == "Dumpster" then
                                        TriggerServerEvent("VICE:MoveItem", inventoryType, b, "dumpster", false)
                                    elseif inventoryType == "Crate" then
                                        TriggerServerEvent("VICE:MoveItem", inventoryType, b, "crate", false)
                                    else
                                        TriggerServerEvent("VICE:MoveItem", "LootBag", b, LootBagIDNew, true)
                                    end
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            else
                                VICE.notify("~r~No second inventory available!")
                            end
                        end
                        lockInventorySoUserNoSpam = true
                        Citizen.CreateThread(
                            function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end
                        )
                    end
                else
                    DrawRect(0.5, 0.45, 0.075, 0.056, 0, 0, 0, 150)
                end
                if CursorInArea(0.4598, 0.498, 0.5042, 0.5666) then
                    DrawRect(0.48, 0.54, 0.0375, 0.056, o.r, o.g, o.b, 150)
                    if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                        PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        local a4 = tonumber(GetInvAmountText()) or 1
                        if not lockInventorySoUserNoSpam then
                            if c then
                                if a and g and c then
                                    if VICE.getPlayerCombatTimer() > 0 then
                                        notify("~r~You can not store items whilst in combat.")
                                    else
                                        if inventoryType == "CarBoot" then
                                            TriggerServerEvent("VICE:MoveItemX", "Plr", a, r, false, a4, owner_id)
                                        elseif inventoryType == "Housing" then
                                            TriggerServerEvent("VICE:MoveItemX", "Plr", a, "home", false, a4)
                                        elseif inventoryType == "Dumpster" then
                                            TriggerServerEvent("VICE:MoveItemX", "Plr", a, "dumpster", false, a4)
                                        elseif inventoryType == "Crate" then
                                            TriggerServerEvent("VICE:MoveItemX", "Plr", a, "crate", false, a4)
                                        elseif s then
                                            TriggerServerEvent("VICE:MoveItemX", "Plr", a, "LootBag", true, a4)
                                        end
                                    end
                                elseif b and g and c then
                                    if inventoryType == "CarBoot" then
                                        TriggerServerEvent("VICE:MoveItemX", inventoryType, b, r, false, a4, owner_id)
                                    elseif inventoryType == "Housing" then
                                        TriggerServerEvent("VICE:MoveItemX", inventoryType, b, "home", false, a4)
                                    elseif inventoryType == "Dumpster" then
                                        TriggerServerEvent("VICE:MoveItemX", inventoryType, b, "dumpster", false, a4)
                                    elseif inventoryType == "Crate" then
                                        TriggerServerEvent("VICE:MoveItemX", inventoryType, b, "crate", false, a4)
                                    else
                                        TriggerServerEvent("VICE:MoveItemX", "LootBag", b, LootBagIDNew, true, a4)
                                    end
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            else
                                VICE.notify("~r~No second inventory available!")
                            end
                        end
                        lockInventorySoUserNoSpam = true
                        Citizen.CreateThread(
                            function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end
                        )
                    end
                else
                    DrawRect(0.48, 0.54, 0.0375, 0.056, 0, 0, 0, 150)
                end
                if CursorInArea(0.5004, 0.5333, 0.5042, 0.5666) then
                    DrawRect(0.52, 0.54, 0.0375, 0.056, o.r, o.g, o.b, 150)
                    if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                        PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        if not lockInventorySoUserNoSpam then
                            if c then
                                if a and g and c then
                                    local L = VICE.getSpaceInSecondChest()
                                    local a4 = k
                                    if k * selectedItemWeight > L then
                                        a4 = math.floor(L / selectedItemWeight)
                                    end
                                    if a4 > 0 then
                                        if VICE.getPlayerCombatTimer() > 0 then
                                            notify("~r~You can not store items whilst in combat.")
                                        else
                                            if inventoryType == "CarBoot" then
                                                TriggerServerEvent(
                                                    "VICE:MoveItemAll",
                                                    "Plr",
                                                    a,
                                                    r,
                                                    NetworkGetNetworkIdFromEntity(VICE.getNearestVehicle(3),owner_id)
                                                )
                                            elseif inventoryType == "Housing" then
                                                TriggerServerEvent("VICE:MoveItemAll", "Plr", a, "home")
                                            elseif inventoryType == "Dumpster" then
                                                TriggerServerEvent("VICE:MoveItemAll", "Plr", a, "dumpster")
                                            elseif inventoryType == "Crate" then
                                                TriggerServerEvent("VICE:MoveItemAll", "Plr", a, "crate")
                                            elseif inventoryType == "LootBag" then
                                                TriggerServerEvent("VICE:MoveItemAll", "Plr", a, "LootBag")
                                            end
                                        end
                                    else
                                        VICE.notify("~r~Not enough space in secondary chest!")
                                    end
                                elseif b and g and c then
                                    local M = VICE.getSpaceInFirstChest()
                                    local a4 = k
                                    if k * selectedItemWeight > M then
                                        a4 = math.floor(M / selectedItemWeight)
                                    end
                                    if a4 > 0 then
                                        if inventoryType == "CarBoot" then
                                            TriggerServerEvent(
                                                "VICE:MoveItemAll",
                                                inventoryType,
                                                b,
                                                r,
                                                NetworkGetNetworkIdFromEntity(VICE.getNearestVehicle(3),owner_id)
                                            )
                                        elseif inventoryType == "Housing" then
                                            TriggerServerEvent("VICE:MoveItemAll", inventoryType, b, "home")
                                        elseif inventoryType == "Dumpster" then
                                            TriggerServerEvent("VICE:MoveItemAll", inventoryType, b, "dumpster")
                                        elseif inventoryType == "Crate" then
                                            TriggerServerEvent("VICE:MoveItemAll", inventoryType, b, "crate")
                                        else
                                            TriggerServerEvent("VICE:MoveItemAll", "LootBag", b, LootBagIDNew)
                                        end
                                    else
                                        VICE.notify("~r~Not enough space in secondary chest!")
                                    end
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            else
                                VICE.notify("~r~No second inventory available!")
                            end
                        end
                        lockInventorySoUserNoSpam = true
                        Citizen.CreateThread(
                            function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end
                        )
                    end
                else
                    DrawRect(0.52, 0.54, 0.0375, 0.056, 0, 0, 0, 150)
                end
                if m then
                    if CursorInArea(0.4598, 0.498, 0.5931, 0.6477) then
                        DrawRect(0.48, 0.63, 0.0375, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:GiveItem", a, "Plr")
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(
                                function()
                                    Wait(250)
                                    lockInventorySoUserNoSpam = false
                                end
                            )
                        end
                    else
                        DrawRect(0.48, 0.63, 0.0375, 0.056, 0, 0, 0, 150)
                    end
                end
                if m then
                    if CursorInArea(0.5004, 0.5333, 0.5931, 0.6477) then
                        DrawRect(0.52, 0.63, 0.0375, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                if a then
                                    TriggerServerEvent("VICE:GiveItemAll", a, "Plr")
                                elseif b then
                                    VICEserver.giveToNearestPlayer({b})
                                else
                                    VICE.notify("~r~No item selected!")
                                end
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(
                                function()
                                    Wait(250)
                                    lockInventorySoUserNoSpam = false
                                end
                            )
                        end
                    else
                        DrawRect(0.52, 0.63, 0.0375, 0.056, 0, 0, 0, 150)
                    end
                end
                if s then
                    if CursorInArea(0.5428, 0.5952, 0.2879, 0.3111) then
                        DrawRect(0.5695, 0.3, 0.05, 0.025, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                TriggerServerEvent("VICE:LootItemAll", LootBagIDNew, CarBoot)
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.5695, 0.3, 0.05, 0.025, 0, 0, 0, 150)
                    end
                end
                if next(v) then
                    if CursorInArea(0.233854, 0.282813, 0.287037, 0.308333) then
                        DrawRect(0.2600, 0.3, 0.05, 0.025, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                TriggerServerEvent("VICE:EquipAll")
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.2600, 0.3, 0.05, 0.025, 0, 0, 0, 150)
                    end
                end
                if c and r then
                    if CursorInArea(0.32000, 0.37000, 0.287037, 0.308333) then
                        DrawRect(0.3453, 0.3, 0.05, 0.025, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                TriggerServerEvent("VICE:TransferAll",r)
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.3453, 0.3, 0.05, 0.025, 0, 0, 0, 150)
                    end
                end
                if CursorInArea(0.4598, 0.5333, 0.6831, 0.7377) then
                    DrawRect(0.5, 0.72, 0.075, 0.056, o.r, o.g, o.b, 150)
                    if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                        PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                        if not lockInventorySoUserNoSpam then
                            if a and VICE.getPlayerCombatTimer() == 0 and (not VICE.getPlayerGreenZone or not VICE.getPlayerGreenZone()) then
                                TriggerServerEvent("VICE:TrashItem", a, "Plr")
                            elseif VICE.getPlayerCombatTimer() > 0 then
                                VICE.notify("~r~You cannot drop items whilst in combat.")
                            elseif not VICE.getPlayerGreenZone or VICE.getPlayerGreenZone() then
                                VICE.notify("~r~You cannot drop items whilst inside a greenzone.")
                            else
                                VICE.notify("~r~No item selected!")
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    end
                else
                    DrawRect(0.5, 0.72, 0.075, 0.056, 0, 0, 0, 150)
                end
                if VICE.getShowNewInventoryUI() and not c and tVICE.getAllWeapons() then
                    if CursorInArea(0.8119, 0.8828, 0.6831, 0.7377) then -- store all
                        DrawRect(0.85, 0.72, 0.075, 0.056, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            if not lockInventorySoUserNoSpam then
                                ExecuteCommand("storeallweapons")     
                            else
                                VICE.notify("~r~No item selected!")
                            end
                            lockInventorySoUserNoSpam = true
                            Citizen.CreateThread(function()
                                Wait(250)
                                lockInventorySoUserNoSpam = false
                            end)
                        end
                    else
                        DrawRect(0.85, 0.72, 0.075, 0.056, 0, 0, 0, 150)
                    end
                end
                if VICE.getShowNewInventoryUI() and not c then
                    local UWeapon = 0.026 
                    local VWeapon = 0.026
                    local WidthWeapon = 0
                    local weapons = {}
                    for weaponspawncode, weapondata in pairs(tVICE.getWeapons()) do
                        if weaponspawncode ~= "GADGET_PARACHUTE" then
                            for spawncode, data in pairs(cfgweapon.weapons) do
                                if spawncode == weaponspawncode then
                                    table.insert(weapons, {name = data.name, ammo = data.ammo, spawncode = weaponspawncode, weapondata = weapondata})
                                    break
                                end
                            end
                        end
                    end
                    local weapons = sortWeaponsAlphabetically(weapons)
                    for i, weapon in ipairs(weapons) do
                        local WeaponName = weapon.name
                        local WeaponAmmo = weapon.ammo
                        if weapon.weapondata.ammo > 0 then
                            DrawAdvancedText(0.944, 0.299 + WidthWeapon * VWeapon, 0.005, 0.0028, 0.366, WeaponName .. " | " ..WeaponAmmo, 255, 255, 255, 255, 4, 0)
                        else
                            DrawAdvancedText(0.944, 0.299 + WidthWeapon * VWeapon, 0.005, 0.0028, 0.366, WeaponName, 255, 255, 255, 255, 4, 0)
                        end
                        if CursorInArea(0.7900, 0.9041, 0.2795 + WidthWeapon * VWeapon, 0.3046 + WidthWeapon * VWeapon) then
                            DrawRect(0.848, 0.269 + UWeapon * (WidthWeapon + 1), 0.115, 0.026, o.r, o.g, o.b, 150)
                            if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                                PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                                TriggerServerEvent("VICE:forceStoreSingleWeapon", weapon.spawncode)
                            end
                        end
                        WidthWeapon = WidthWeapon + 1
                    end
                end
                local U = 0.026 
                local V = 0.026
                local W = 0
                local X = 0
                local a5 = sortAlphabetically(v)
                
                for Y2, Z in pairs(a5) do
                    local a0 = Z.title
                    local a1 = Z["value"]
                    local a2, a3, Z = a1.ItemName, a1.amount, a1.Weight
                    a3 = tonumber(a3) or 0
                    Z = tonumber(Z) or 0
                    X = X + a3 * Z
                    DrawAdvancedText(0.404, 0.360 + W * V, 0.005, 0.0028, 0.366, a2, 255, 255, 255, 255, 4, 0)
                    DrawAdvancedText(
                        0.521,
                        0.360 + W * V,
                        0.005,
                        0.0028,
                        0.366,
                        tostring(Z * a3) .. "kg",
                        255,
                        255,
                        255,
                        255,
                        4,
                        0
                    )
                    DrawAdvancedText(0.488, 0.360 + W * V, 0.005, 0.0028, 0.366, getMoneyStringFormatted(a3), 255, 255, 255, 255, 4, 0)
                    if CursorInArea(0.2343, 0.4484, 0.3435 + W * V, 0.3690 + W * V) then
                        DrawRect(0.342, 0.331 + U * (W + 1), 0.215, 0.026, o.r, o.g, o.b, 150)
                        if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                            PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                            a = a0
                            if n[a] then
                                m = true
                            else
                                m = false
                            end
                            k = a3
                            selectedItemWeight = Z
                            b = false
                        end
                    elseif a0 == a then
                        DrawRect(0.342, 0.331 + U * (W + 1), 0.215, 0.026, o.r, o.g, o.b, 150)
                    end
                    W = W + 1
                end
                -- if VICE.getShowNewInventoryUI() and not c then
                --     playerIds = {}
                --     -- for id in pairs(tVICE.getNearestPlayers(15.0)) do
                --     --     table.insert(playerIds, id) 
                --     -- end
                --     for i = 1, 5 do
                --         table.insert(playerIds, i)
                --     end
                --     alreadyselecting = true
                --     for i = 1, #playerIds do
                --         local left = 0.1521 - 0.115 / 2 - 0.05 + 0.05 
                --         local top = 0.253 + (i * 0.04) - 0.031 / 2
                --         local right = 0.251 + 0.1521 / 2 - 0.05 - 0.07  
                --         local bottom = 0.253 + (i * 0.04) + 0.031 / 2
                    
                --         if CursorInZone(left, top, right, bottom) then
                --             local center_x = (left + right) / 2
                --             local center_y = (top + bottom) / 2
                --             local width = (right - left) / 2 
                --             local height = bottom - top
                --             DrawRect(0.1521, 0.253 + (i * 0.04), 0.115, 0.031, o.r, o.g, o.b, 150)
                --             if IsControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 329) then
                --                 PlaySound(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
                --                 selected = playerIds[i]
                --             end
                --         else
                --             DrawRect(0.1521, 0.253 + (i * 0.04), 0.115, 0.031, 0,0,0,200)
                --         end
                --         DrawAdvancedText(0.237, 0.260 + (i * 0.04), 0.005, 0.0028, 0.366,"["..i.."] "..VICE.getPlayerName(playerIds[i]), 255, 255, 255, 255, 4, 0)
                --     end
                --     if IsControlJustPressed(1, 177) or IsControlJustPressed(1, 194) or IsControlJustPressed(1, 202) then
                --         break
                --     end
                --     alreadyselecting = false
                -- end
                if X / currentInventoryMaxWeight > 0.5 then
                    if X / currentInventoryMaxWeight > 0.9 then
                        DrawAdvancedText(
                            0.516,
                            0.307,
                            0.005,
                            0.0028,
                            0.366,
                            "Weight: " .. X .. "/" .. currentInventoryMaxWeight .. "kg",
                            255,
                            50,
                            0,
                            255,
                            4,
                            0
                        )
                    else
                        DrawAdvancedText(
                            0.516,
                            0.307,
                            0.005,
                            0.0028,
                            0.366,
                            "Weight: " .. X .. "/" .. currentInventoryMaxWeight .. "kg",
                            255,
                            165,
                            0,
                            255,
                            4,
                            0
                        )
                    end
                else
                    DrawAdvancedText(
                        0.516,
                        0.307,
                        0.005,
                        0.0028,
                        0.366,
                        "Weight: " .. X .. "/" .. currentInventoryMaxWeight .. "kg",
                        255,
                        255,
                        255,
                        255,
                        4,
                        0
                    )
                end
                DrawAdvancedText(0.345,0.333,0.005,0.0028,0.366,VICE.getPlayerName(GetPlayerServerId(PlayerId())),255,255,255,255,4,0)
            end
            Wait(0)
        end
    end
)
Citizen.CreateThread(
    function()
        while true do
            if GetEntityHealth(VICE.getPlayerPed()) <= 102 then
                VICESecondItemList = {}
                c = false
                drawInventoryUI = false
                inGUIVICE = false
                setCursor(0)
            end
            Wait(50)
        end
    end
)
function GetInvAmountText()
    AddTextEntry("FMMC_MPM_NA", "Enter amount: (Blank to cancel)")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Enter amount: (Blank to cancel)", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local N = GetOnscreenKeyboardResult()
        return N
    end
    return nil
end
Citizen.CreateThread(
    function()
        while true do
            Wait(250)
            if p then
                if #(p - GetEntityCoords(PlayerPedId())) > 8.0 then
                    drawInventoryUI = false
                    VICE.vc_closeDoor(q, 5)
                    p = nil
                    q = nil
                    r = nil
                    inventoryType = nil
                end
            end
            if drawInventoryUI then
                if
                    tVICE.isInComa() or
                        inventoryType == "Crate" and
                            GetClosestObjectOfType(
                                GetEntityCoords(PlayerPedId()),
                                5.0,
                                `xs_prop_arena_crate_01a`,
                                false,
                                false,
                                false
                            ) == 0
                 then
                    TriggerEvent("VICE:InventoryOpen", false)
                    if p then
                        VICE.vc_closeDoor(q, 5)
                        p = nil
                        q = nil
                        r = nil
                    end
                end
            end
        end
    end
)
function LoadAnimDict(a6)
    while not HasAnimDictLoaded(a6) do
        RequestAnimDict(a6)
        Citizen.Wait(5)
    end
end
RegisterNetEvent("VICE:InventoryOpen")
AddEventHandler(
    "VICE:InventoryOpen",
    function(a7, a8, a9)
        s = a8
        LootBagIDNew = a9
        if a7 and not i then
            drawInventoryUI = true
            setCursor(1)
            inGUIVICE = true
        else
            drawInventoryUI = false
            setCursor(0)
            VICESecondItemList = {}
            inGUIVICE = false
            inventoryType = nil
            local aa = PlayerPedId()
            local X = GetEntityCoords(aa)
            ClearPedTasks(aa)
            ForcePedAiAndAnimationUpdate(aa, false, false)
            if VICE.getPlayerVehicle() == 0 then
                SetEntityCoordsNoOffset(aa, X.x, X.y, X.z + 0.1, true, false, false)
            end
        end
    end
)
function VICE.createDropBag(source, item, amount)
    local ped = GetPlayerPed(source)
    if not ped or not DoesEntityExist(ped) then return end

    local playerCoords = GetEntityCoords(ped)
    local closestBag = nil
    local closestDistance = 4.0

    for netId, bag in pairs(LootBagEntities) do
        local bagEntity = bag[1]
        if DoesEntityExist(bagEntity) then
            local bagCoords = GetEntityCoords(bagEntity)
            local distance = #(playerCoords - bagCoords)
            if distance < closestDistance then
                closestBag = netId
                closestDistance = distance
            end
        end
    end

    if closestBag == nil then
        local model = `xm_prop_x17_bag_01a`
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local dropPos = vec3(playerCoords.x, playerCoords.y, playerCoords.z - 0.9)
        local lootbag = CreateObjectNoOffset(model, dropPos, true, true, false)
        local lootbagNetId = NetworkGetNetworkIdFromEntity(lootbag)

        SetEntityRoutingBucket(lootbag, GetPlayerRoutingBucket(source))

        LootBagEntities[lootbagNetId] = {
            [1] = lootbag,          -- entity reference
            [2] = lootbag,          -- maybe for tracking/duplication?
            [3] = false,            -- status (e.g., claimed)
            [4] = source,           -- owner
            Items = {
                [item] = { amount = amount }
            },
            name = VICE.getPlayerName(VICE.getUserId(source))
        }

        SetModelAsNoLongerNeeded(model)
    else
        local bag = LootBagEntities[closestBag]
        if bag.Items[item] then
            bag.Items[item].amount = bag.Items[item].amount + amount
        else
            bag.Items[item] = { amount = amount }
        end
    end
end