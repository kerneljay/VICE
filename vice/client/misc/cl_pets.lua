RMenu.Add(
    "vicepets",
    "main",
    RageUI.CreateMenu(
        "",
        "Select your ~b~Pet",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "vice_petsui"
    )
)
RMenu.Add(
    "vicepets",
    "store",
    RageUI.CreateMenu("", "~s~Store", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "vice_petsui")
)
TriggerEvent("chat:addSuggestion", "/pet", "Manage your owned pets!")
local a = "HANDLER"
local b = "K9"
local c = "K9TARGET"
local d = {}
local e = false
local f = {
    purchasing = false,
    purchasingId = 0,
    viewingPet = false,
    lastViewingId = 0,
    viewingId = 0,
    cameraEnabled = false,
    cameraHandle = 0
}
local g = {Follow = 1, Stay = 2, Attack = 3, Sit = 4, Trick = 5, Shoulder = 5, Floor = 6, Ride = 7}
local h = {active = false, id = 0, cooldown = false}
local i = {Success = 1, Error = 2, Alert = 3, Info = 4, Unknown = 5}
local j = {chooseActivePet = 1}
local k = false
local l = function(m)
    RageUI.Visible(RMenu:Get("vicepets", "store"), true)
    f.viewingPet = true
    if not f.cameraEnabled then
        DestroyCam(f.cameraHandle, false)
        f.cameraHandle = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        SetCamCoord(f.cameraHandle, 562.7604, 2752.879, 42.40)
        SetCamRot(f.cameraHandle, -1, -1, -84.73, 2)
        RenderScriptCams(1, 0, 0, 1, 1)
        f.cameraEnabled = true
    end
end
local n = function()
    RageUI.Visible(RMenu:Get("vicepets", "store"), false)
    f.viewingPet = false
    if f.viewingId ~= 0 then
        DeleteEntity(f.viewingEntity)
        f.viewingPet = false
        f.viewingId = 0
    end
    if f.cameraEnabled then
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(f.cameraHandle, false)
        f.cameraEnabled = false
    end
end
local o = function()
end
RegisterNetEvent(
    "VICE:attackToggledAdmin",
    function(p)
        for q, r in pairs(d.pets) do
            if not p then
                d.pets[q].abilities.attack = false
                showNotification(i.Alert, "Your ability to attack has been disabled by a ~b~VICE Staff Member~w~.")
            end
        end
    end
)
RegisterNetEvent(
    "VICE:updatePetHealth",
    function(b, s)
        if d.pets[b].info.owned then
            d.pets[b].health = s
            RMenu:Get("vicepets", "main"):SetSubtitle(
                "~b~Pet: ~w~" .. d.pets[h.id].name .. " ~b~Health: ~w~" .. d.pets[h.id].health .. "/100"
            )
        end
    end
)
function func_setPetShopWorkerPed(t)
    SetPedComponentVariation(t, 2, 0, 0, 0)
    SetPedComponentVariation(t, 2, 7, 2, 1) -- Hair
    SetPedComponentVariation(t, 3, 4, 0, 0) -- Arms
    SetPedComponentVariation(t, 4, 165, 0, 0) -- Legs
    SetPedComponentVariation(t, 5, 0, 0, 0) -- Bags
    SetPedComponentVariation(t, 6, 10, 0, 0) -- Shoes
    SetPedComponentVariation(t, 7, 0, 0, 0)
    SetPedComponentVariation(t, 8, 216, 0, 0) -- Undershirt
    SetPedComponentVariation(t, 9, 0, 0, 0) -- Vest
    SetPedComponentVariation(t, 10, 0, 0, 0)
    SetPedComponentVariation(t, 11, 440, 0, 0) -- Shirt
end
-- Ensure d.pets is initialized as an empty table
local d = { pets = {} }

RegisterNetEvent("VICE:buildPetCFG")
AddEventHandler("VICE:buildPetCFG", function(u, v, w)
    -- Update the existing 'd' table with data from 'w'
   -- print("id: bear      p: bear") -- only here cause i want prints to make it look like its done :(
    for key, value in pairs(w) do
        d[key] = value
    end

    local x = u
    for q, r in pairs(d.pets) do
        d.pets[q].abilities.teleport = false
        d.pets[q].awaitingHealthReduction = false
        d.pets[q].info = { currentAction = 1, owned = false, dead = false, inVehicle = false }
        if v.attack then
            d.pets[q].abilities.attack = false
        end
        local y = false
        for z in pairs(x) do
            print("id: " .. x[z].id, " p: " .. q)
            if x[z].id == q then
                y = true
                d.pets[q].name = x[z].name
                if not x[z].ownedSkills.teleport then
                    d.pets[q].abilities.teleport = false
                else
                    d.pets[q].abilities.teleport = true
                end
                if x[z].health then
                    d.pets[q].health = tonumber(x[z].health)
                else
                    d.pets[q].health = 100
                end
            end
        end
        if y then
            d.pets[q].info.owned = true
        end
    end

    -- Check if 'shop' field exists in 'd', and if not, set default coordinates
    if not d.shop or not d.shop.coords then
        d.shop = {
            coords = vector3(559.2889, 2749.858, 42.85172),
            changeNamePrice = 60000,
        }
    end

    tVICE.addMarker(
        d.shop.coords.x,
        d.shop.coords.y,
        d.shop.coords.z,
        1.0001,
        1.0001,
        0.5001,
        31,
        135,
        173,
        220,
        20.0,
        31,
        false,
        false,
        true,
        nil,
        nil,
        0.0,
        0.0,
        0.0
    )

    VICE.createArea("petStore", d.shop.coords, 1.5, 1.5, l, n, o, {})
    local A = tVICE.addBlip(d.shop.coords.x, d.shop.coords.y, d.shop.coords.z, 442, 26, "Pet Store")
    e = true
    local B =
        tVICE.createDynamicPed(
        "mp_m_freemode_01",
        vector3(558.74, 2752.71, 41.85),
        179.45,
        true,
        "mini@strip_club@idles@bouncer@base",
        "base",
        10,
        false,
        func_setPetShopWorkerPed
    )
end)

RegisterNetEvent(
    "VICE:togglePetMenu",
    function(x)
        if not e then
            showNotification("Please wait before opening the pet menu.")
        else
            local C = false
            for q, r in pairs(d.pets) do
                if r.info.owned and not r.info.dead then
                    C = true
                end
            end
            if h.cooldown then
                showNotification(i.Info, "Please wait before spawning in a new pet.")
            else
                if not C then
                    showNotification(i.Error, "You do not own any ~b~pets~w~. Visit a ~b~pet store ~w~to purchase one.")
                else
                    RageUI.Visible(RMenu:Get("vicepets", "main"), true)
                end
            end
        end
    end
)
RegisterNetEvent(
    "VICE:successfulPurchase",
    function(D)
        PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS")
        showNotification(
            i.Success,
            "You have now ~b~purchased ~w~a ~b~" .. d.pets[D].name .. "~w~. Use /pet to spawn it in."
        )
        d.pets[D].info.owned = true
        d.pets[D].health = 100
    end
)
RegisterNetEvent(
    "VICE:updatePetName",
    function(D, E)
        PlaySoundFrontend(-1, "PROPERTY_PURCHASE", "HUD_AWARDS")
        showNotification(i.Success, "You have now changed your pet name to ~b~" .. E .. "~w~!")
        d.pets[D].name = E
        RMenu:Get("vicepets", "main"):SetSubtitle(
            "~b~Pet: ~w~" .. d.pets[h.id].name .. " ~b~Health: ~w~" .. d.pets[h.id].health .. "/100"
        )
        RageUI.Visible(RMenu:Get("vicepets", "main"), true)
    end
)
RegisterNetEvent(
    "VICE:updateTeleportSkillPurchased",
    function(D)
        d.pets[D].abilities.teleport = true
    end
)
RegisterNetEvent(
    "VICE:sendClientRagdollPet",
    function(F, E)
        SetPedToRagdoll(VICE.getPlayerPed(), 12000, 12000, 0, 0, 0, 0)
        showNotification(i.Alert, "~y~~h~Alert~h~~s~: " .. "You have been attacked by a pet.")
        showNotification(i.Alert, "~b~Owner: ~w~" .. E .. "\nUser ID: ~b~" .. F)
        Citizen.Wait(1000)
        local G = VICE.getPlayerPed()
        if not IsPedRagdoll(G) then
            SetPedToRagdoll(G, -1, -1, 0, false, false, false)
        end
    end
)
RageUI.CreateWhile(
    1.0,
    RMenu:Get("vicepets", "store"),
    function()
        RageUI.IsVisible(
            RMenu:Get("vicepets", "store"),
            true,
            true,
            true,
            function()
                if f.purchasing then
                    RageUI.ButtonWithStyle(
                        "Purchase " .. d.pets[f.purchasingId].name,
                        "Purchase",
                        {RightLabel = "£" .. getMoneyStringFormatted(d.pets[f.purchasingId].price)},
                        true,
                        function(H, I, J)
                            if J then
                                TriggerServerEvent("VICE:purchasePet", f.purchasingId)
                                f.purchasing = false
                                f.purchasingId = 0
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Cancel Purchase",
                        "Cancel",
                        {},
                        true,
                        function(H, I, J)
                            if J then
                                f.purchasing = false
                                f.purchasingId = 0
                            end
                        end
                    )
                else
                    if e then
                        local C = false
                        for q, r in pairs(d.pets) do
                            if not r.info.owned then
                                C = true
                                RageUI.ButtonWithStyle(
                                    r.name,
                                    r.description,
                                    {RightLabel = "£" .. getMoneyStringFormatted(r.price)},
                                    true,
                                    function(H, I, J)
                                        if J then
                                            f.purchasing = true
                                            f.purchasingId = q
                                        end
                                        if I then
                                            f.viewingId = q
                                        end
                                    end
                                )
                            end
                        end
                        if not C then
                            RageUI.Visible(RMenu:Get("vicepets", "store"), false)
                           -- showNotification(i.Info, "There are no available pets for you to purchase.")
                           showNotification(i.Info, "The pets shop is currently under construction.")
                        end
                    end
                end
            end,
            function()
            end
        )
    end
)
function currentPet()
    if not h then
        return
    end
    return d.pets[h.id]
end
RageUI.CreateWhile(
    1.0,
    RMenu:Get("vicepets", "main"),
    function()
        RageUI.IsVisible(
            RMenu:Get("vicepets", "main"),
            true,
            true,
            true,
            function()
                if inOrganHeist then
                    RageUI.Visible(RMenu:Get("vicepets", "main"), false)
                    return
                end
                if not h.active then
                    for q, r in pairs(d.pets) do
                        if r.info.owned then
                            RageUI.Button(
                                "Spawn " .. r.name,
                                "Press to spawn",
                                {},
                                function(H, I, J)
                                    if J then
                                        if r.info.dead then
                                            showNotification(i.Info, "Please wait before spawning in " .. r.name .. ".")
                                        elseif h.cooldown then
                                            showNotification(i.Info, "Please wait before spawning in a pet.")
                                        else
                                            petCreate(q)
                                        end
                                    end
                                end
                            )
                        end
                    end
                else
                    if currentPet().info.inVehicle then
                        RageUI.Button(
                            "Remove from vehicle",
                            "Remove pet from vehicle",
                            {},
                            function(H, I, J)
                                if J then
                                    removePetFromVehicle()
                                end
                            end
                        )
                    else
                        if d.pets[h.id].health == nil or d.pets[h.id].health > 1 and not d.pets[h.id].onShoulder then
                            if not (currentPet().info.currentAction == g.Follow) then
                                RageUI.Button(
                                    "Follow",
                                    "Pet will follow you",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            petFollow()
                                        end
                                    end
                                )
                            end
                            if not (currentPet().info.currentAction == g.Stay) then
                                RageUI.Button(
                                    "Stay",
                                    "Pet will stay",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            showNotification(i.Info, currentPet().name .. " is now staying.")
                                            petStay()
                                        end
                                    end
                                )
                            end
                            if d.pets[h.id].abilities.sit and not (currentPet().info.currentAction == g.Sit) then
                                RageUI.Button(
                                    "Sit",
                                    "Pet will sit",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            showNotification(i.Info, currentPet().name .. " is now sitting.")
                                            petSit()
                                        end
                                    end
                                )
                            end
                            if d.pets[h.id].abilities.teleport then
                                RageUI.Button(
                                    "Teleport",
                                    "Teleport pet to you",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            tpPet()
                                            showNotification(i.Info, "Pet has now been teleported to you.")
                                        end
                                    end
                                )
                            end
                            if d.pets[h.id].abilities.attack and not (currentPet().info.currentAction == g.Attack) then
                                RageUI.Button(
                                    "Attack",
                                    "Pet will attack",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            selectAttackTargetPet()
                                        end
                                    end
                                )
                            end
                            if not (currentPet().info.currentAction == g.Attack) then
                                RageUI.Button(
                                    "Put in vehicle",
                                    "Put pet from vehicle",
                                    {},
                                    function(H, I, J)
                                        if J then
                                            putPetInVehicle()
                                        end
                                    end
                                )
                                if d.pets[h.id].abilities.paw then
                                    RageUI.Button(
                                        "Paw Trick",
                                        "Pet will lift paw",
                                        {},
                                        function(H, I, J)
                                            if J then
                                                petPerformTrick(d.pets[h.id].animations.paw)
                                            end
                                        end
                                    )
                                end
                                if d.pets[h.id].abilities.sleep then
                                    RageUI.Button(
                                        "Sleep Trick",
                                        "Pet will sleep",
                                        {},
                                        function(H, I, J)
                                            if J then
                                                petPerformTrick(d.pets[h.id].animations.sleep)
                                            end
                                        end
                                    )
                                end
                            end
                        end
                        if d.pets[h.id].onShoulder and d.pets[h.id].info.currentAction == g.Shoulder then
                            RageUI.Button(
                                "Place on ground",
                                "Place your pet on the ground",
                                {},
                                function(H, I, J)
                                    if J then
                                        petOnGround()
                                    end
                                end
                            )
                        end
                        if d.pets[h.id].onShoulder and d.pets[h.id].info.currentAction == g.Floor then
                            RageUI.Button(
                                "Place on right shoulder",
                                "Place your pet on your right shoulder",
                                {},
                                function(H, I, J)
                                    if J then
                                        petOnShoulder(true)
                                    end
                                end
                            )
                            RageUI.Button(
                                "Place on left shoulder",
                                "Place your pet on your left shoulder",
                                {},
                                function(H, I, J)
                                    if J then
                                        petOnShoulder(false)
                                    end
                                end
                            )
                        end
                        if d.pets[h.id].health and d.pets[h.id].health < 100 then
                            RageUI.Button(
                                "Feed Pet",
                                "Feed your current pet",
                                {},
                                function(H, I, J)
                                    if J then
                                        TriggerServerEvent("VICE:feedPet", h.id)
                                    end
                                end
                            )
                        end
                        RageUI.Button(
                            "Delete Pet",
                            "Deletes your current pet",
                            {},
                            function(H, I, J)
                                if J then
                                    RageUI.Visible(RMenu:Get("vicepets", "main"), false)
                                    petDelete()
                                end
                            end
                        )
                        if
                            d.pets[h.id] and d.pets[h.id].abilities and
                                not d.pets[h.id].abilities.teleport and
                                not d.pets[h.id].onShoulder
                         then
                            RageUI.ButtonWithStyle(
                                "Purchase Teleport Feature",
                                "Purchase",
                                {RightLabel = "£" .. getMoneyStringFormatted(d.pets[h.id].skillPrices.teleport)},
                                true,
                                function(H, I, J)
                                    if J then
                                        TriggerServerEvent("VICE:purchaseTeleportSkill", h.id)
                                    end
                                end
                            )
                        end
                        RageUI.ButtonWithStyle(
                            "Change Name",
                            "Purchase",
                            {RightLabel = "£" .. getMoneyStringFormatted(d.shop.changeNamePrice)},
                            true,
                            function(H, I, J)
                                if J then
                                    TriggerServerEvent("VICE:changePetName", h.id)
                                    RageUI.CloseAll()
                                end
                            end
                        )
                        if d.pets[h.id] and d.pets[h.id].abilities and d.pets[h.id].abilities.ride then
                            RageUI.ButtonWithStyle(
                                "Ride",
                                "",
                                {},
                                true,
                                function(I, J, K)
                                    if K then
                                        ridePet()
                                        RageUI.CloseAll()
                                    end
                                end
                            )
                        end
                    end
                end
            end,
            function()
            end
        )
    end
)
Citizen.CreateThread(
    function()
        while true do
            if f.viewingPet then
                f.lastViewingId = f.viewingId
                if f.viewingId ~= 0 then
                    VICE.loadModel(d.pets[f.viewingId].model)
                    drawNativeText("You are viewing the ~b~" .. d.pets[f.viewingId].name .. "~w~.")
                    if not d.pets[f.viewingId].abilities.attack then
                        if d.pets[f.viewingId].onShoulder then
                            drawNativeText("This pet can only go on your ~b~shoulder ~w~.")
                        else
                            drawNativeText("This pet ~b~cannot ~w~attack.")
                        end
                    end
                    local t = VICE.getPlayerPed()
                    local K = CreatePed(28, d.pets[f.viewingId].model, 564.83, 2753.28, 41.89, 81.06, false, false)
                    f.viewingEntity = K
                    SetEntityNoCollisionEntity(K, t, false)
                    TaskStandStill(K, 100000)
                    while f.viewingId == f.lastViewingId do
                        SetEntityHeading(K, GetEntityHeading(K) - 0.3)
                        Wait(0)
                    end
                    if d.pets[f.viewingId] and d.pets[f.viewingId].model then
                        SetModelAsNoLongerNeeded(d.pets[f.viewingId].model)
                    end
                    if DoesEntityExist(f.viewingEntity) then
                        DeleteEntity(f.viewingEntity)
                    end
                end
            end
            Wait(0)
        end
    end
)
local function L(M, ...)
    local N = NetworkGetNetworkIdFromEntity(h.handle)
    if N ~= 0 then
        TriggerServerEvent("VICE:receivePetCommand", h.id, N, M, ...)
    end
end
function petOnGround()
    if d.pets[h.id].onShoulder and d.pets[h.id].info.currentAction == g.Shoulder then
        d.pets[h.id].info.currentAction = g.Floor
        L("petOnGround", GetPlayerServerId(PlayerId()))
        showNotification(i.Success, currentPet().name .. " is now on the ground")
    end
end
function petOnShoulder(O)
    if d.pets[h.id].onShoulder then
        d.pets[h.id].info.currentAction = g.Shoulder
        L("petOnShoulder", GetPlayerServerId(PlayerId()), O)
        showNotification(i.Success, currentPet().name .. " is now on your shoulder.")
    end
end
function tpPet()
    L("tpPet", GetPlayerServerId(PlayerId()))
end
local P = function(Q)
    local R = {}
    local S = GetGameTimer() / 200
    R.r = math.floor(math.sin(S * Q + 0) * 127 + 128)
    R.g = math.floor(math.sin(S * Q + 2) * 127 + 128)
    R.b = math.floor(math.sin(S * Q + 4) * 127 + 128)
    return R
end
function selectAttackTargetPet()
    RageUI.Visible(RMenu:Get("vicepets", "main"), false)
    Citizen.CreateThread(
        function()
            d.pets[h.id].info.currentAction = g.Attack
            local T = setupDogScaleform("instructional_buttons")
            showNotification(i.Info, "Aim at the ~b~target ~s~and press ENTER to begin the attack.")
            local U = PlayerId()
            while true do
                if h.id == 0 then
                    break
                end
                if d.pets[h.id].info.currentAction == g.Attack then
                    local C, V = GetEntityPlayerIsFreeAimingAt(U)
                    if C then
                        if IsEntityAPed(V) and V ~= d.pets[h.id].info.handle then
                            DrawScaleformMovieFullscreen(T, 255, 255, 255, 255, 0)
                            local W = GetEntityCoords(V, true)
                            local X = P(0.5)
                            DrawMarker(
                                1,
                                W.x,
                                W.y,
                                W.z - 1.02,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0,
                                0.7,
                                0.7,
                                1.5,
                                X.r,
                                X.g,
                                X.b,
                                200,
                                0,
                                0,
                                2,
                                0,
                                0,
                                0,
                                0
                            )
                            if IsControlJustPressed(1, 18) then
                                local Y = d.pets[h.id].info.handle
                                local N = NetworkGetNetworkIdFromEntity(Y)
                                local Z = NetworkGetNetworkIdFromEntity(V)
                                if N ~= 0 and Z ~= 0 then
                                    TriggerServerEvent("VICE:startPetAttack", h.id, N, Z)
                                    d.pets[h.id].info.isAttacking = true
                                    T = setupDogScaleform("instructional_buttons")
                                    showNotification(i.Info, "Attack has started, press ~b~DEL ~s~to stop the attack.")
                                    while h.id ~= 0 and d.pets[h.id].info.isAttacking do
                                        Citizen.Wait(0)
                                    end
                                end
                            end
                        end
                    end
                else
                    break
                end
                Wait(0)
            end
        end
    )
end
RegisterNetEvent(
    "VICE:disablePetAttacking",
    function(_)
        d.pets[_].info.isAttacking = false
        showNotification(i.Alert, "The attack has finished.")
    end
)
function petPerformTrick(a0)
    d.pets[h.id].info.currentAction = g.Trick
    L("petPerformTrick", a0.dict, a0.base)
end
function ridePet()
    local E = h.id
    local a1 = d.pets[h.id].info.handle
    if not DoesEntityExist(a1) or IsEntityDead(a1) then
        return
    end
    if k then
        return
    end
    if #(VICE.getPlayerCoords() - GetEntityCoords(a1, true)) > 2.5 then
        notify("~r~You are too far away")
        return
    end
    DeleteEntity(a1)
    local a2 = ClonePed(PlayerPedId(), true, true, true)
    k = true
    local a3 = GetEntityHealth(PlayerPedId())
    local a4 = tVICE.getCustomization()
    tVICE.setCustomization({modelhash = "BrnBear"})
    SetModelAsNoLongerNeeded(horseModelHash)
    Citizen.CreateThread(
        function()
            Citizen.Wait(200)
            tVICE.setHealth(a3)
        end
    )
    d.pets[h.id].info.currentAction = g.Ride
    AttachEntityToEntity(
        a2,
        PlayerPedId(),
        GetPedBoneIndex(PlayerPedId(), 24816),
        -0.35,
        0.0,
        0.65,
        0.0,
        0.0,
        -90.0,
        false,
        false,
        false,
        true,
        2,
        true
    )
    VICE.loadAnimDict("amb@prop_human_seat_chair@male@generic@base")
    TaskPlayAnim(a2, "amb@prop_human_seat_chair@male@generic@base", "base", 8.0, 1, -1, 1, 1.0, 0, 0, 0)
    RemoveAnimDict("amb@prop_human_seat_chair@male@generic@base")
    FreezeEntityPosition(PlayerPedId(), false)
    FreezeEntityPosition(a2, false)
    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 0)
    SetBlockingOfNonTemporaryEvents(a2, true)
    SetPedCombatAttributes(a2, 292, true)
    SetPedFleeAttributes(a2, 0, 0)
    SetPedRelationshipGroupHash(a2, "CIVFEMALE")
    Citizen.CreateThread(
        function()
            while h and h.id and d.pets[h.id] and d.pets[h.id].info.currentAction == g.Ride and k do
                drawNativeNotification("~s~~INPUT_JUMP~ to stop riding")
                VICE.setWeapon(PlayerPedId(), "weapon_unarmed", true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 143, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                SetPedDropsWeaponsWhenDead(a2, false)
                if IsDisabledControlPressed(0, 22) then
                    break
                end
                Citizen.Wait(0)
            end
            DeleteEntity(a2)
            DetachEntity(PlayerPedId(), false, false)
            local a5 = GetEntityHealth(PlayerPedId())
            tVICE.setCustomization(a4)
            Citizen.CreateThread(
                function()
                    Citizen.Wait(200)
                    tVICE.setHealth(a5)
                    Citizen.Wait(1000)
                    inHorseModeDelayed = false
                end
            )
            k = false
            if h.id == E then
                petCreate(E)
            end
        end
    )
end
function petCreate(b)
    local t = VICE.getPlayerPed()
    VICE.loadModel(d.pets[b].model)
    local a6 = GetOffsetFromEntityInWorldCoords(t, 0.0, 1.0, 0.0)
    local a1 = GetEntityHeading(t)
    d.pets[b].info.handle = CreatePed(28, d.pets[b].model, a6.x, a6.y, a6.z, a1, true, true)
    while not DoesEntityExist(d.pets[b].info.handle) do
        Wait(0)
    end
    SetModelAsNoLongerNeeded(d.pets[b].model)
    if DoesEntityExist(d.pets[b].info.handle) then
        if d.pets[b].movementRate then
            SetPedMoveRateOverride(d.pets[b].info.handle, d.pets[b].movementRate)
        end
        SetBlockingOfNonTemporaryEvents(d.pets[b].info.handle, 1)
        d.pets[b].info.active = true
        h.active = true
        h.id = b
        h.handle = d.pets[b].info.handle
        petFollow()
        RMenu:Get("vicepets", "main"):SetSubtitle("Pet: ~w~" .. d.pets[h.id].name)
        if d.pets[h.id].health then
            RMenu:Get("vicepets", "main"):SetSubtitle(
                "~b~Pet: ~w~" .. d.pets[h.id].name .. " ~b~Health: ~w~" .. d.pets[h.id].health .. "/100"
            )
        end
        showNotification(i.Success, currentPet().name .. " has now been created.")
    end
end
function petDelete()
    L("petDelete")
    h.active = false
    h.id = 0
    h.cooldown = true
    RMenu:Get("vicepets", "main"):SetSubtitle("Select your ~b~Pet")
    if VICE.getUserId() ~= 1 then
        SetTimeout(
            20000,
            function()
                h.cooldown = false
                showNotification(i.Success, "You are now able to spawn in a pet again.")
            end
        )
    else
        h.cooldown = false
    end
end
function petFollow()
    if not d.pets[h.id].onShoulder then
        showNotification(i.Info, currentPet().name .. " is now following.")
        L("petFollow", GetPlayerServerId(PlayerId()))
        d.pets[h.id].info.currentAction = g.Follow
    else
        petOnShoulder()
    end
end
function petStay()
    L("petStay")
    d.pets[h.id].info.currentAction = g.Stay
end
function putPetInVehicle()
    local a2 = VICE.getNearestVehicle(7.0)
    if a2 ~= -1 and a2 and a2 ~= 0 then
        local a3 = NetworkGetNetworkIdFromEntity(a2)
        if a3 ~= 0 then
            L("putPetInVehicle", a3)
        end
        d.pets[h.id].info.inVehicle = true
        d.pets[h.id].info.insideVehicleHandle = a2
        showNotification(i.Info, "Pet is now inside the vehicle")
    else
        showNotification(i.Error, "No nearby vehicle found.")
    end
end
function removePetFromVehicle()
    if IsPedInAnyVehicle(VICE.getPlayerPed(), true) then
        showNotification(i.Error, "You must be outside the vehicle.")
    else
        L("removePetFromVehicle", GetPlayerServerId(PlayerId()))
        showNotification(i.Info, currentPet().name .. " is now removed from the vehicle.")
        d.pets[h.id].info.inVehicle = false
    end
end
function petSit()
    local a4 = d.pets[h.id].animations.sit.dict
    local a5 = d.pets[h.id].animations.sit.base
    L("petSit", a4, a5)
end
function petAttack()
    local a4 = d.pets[h.id].animations.sit.dict
    local a5 = d.pets[h.id].animations.sit.base
    L("petAttack", a4, a5)
end
local function a7(D, a8, E)
    ClearPedTasks(h.handle)
    VICE.loadAnimDict(a8)
    TaskPlayAnim(D, a8, E, 8.0, -8.0, -1, 2, 0.0, false, false, false)
    RemoveAnimDict(a8)
end
local function a9(D)
    DeleteEntity(D)
end
local function aa(D, ab)
    local ac = GetPlayerFromServerId(ab)
    if ac == -1 then
        return
    end
    local ad = GetPlayerPed(ac)
    if ad == 0 then
        return
    end
    ClearPedTasks(D)
    TaskFollowToOffsetOfEntity(D, ad, 0.0, 0.0, 0.0, 7.0, -1, 10.0, true)
end
local function ae(D)
    ClearPedTasks(D)
end
local function af(D, a3)
    if not NetworkDoesNetworkIdExist(a3) then
        return
    end
    local a2 = NetworkGetEntityFromNetworkId(a3)
    if a2 == 0 then
        return
    end
    ClearPedTasks(D)
    local ag = GetEntityBoneIndexByName(a2, "seat_dside_r")
    if ag == -1 then
        ag = GetEntityBoneIndexByName(a2, "seat_pside_f")
    end
    AttachEntityToEntity(D, a2, ag, 0.0, -0.1, 0.4, 0.0, 0.0, 0.0, 0, false, false, true, 0, true)
end
local function ah(D, ab)
    local ac = GetPlayerFromServerId(ab)
    if ac == -1 then
        return
    end
    local ad = GetPlayerPed(ac)
    if ad == 0 then
        return
    end
    ClearPedTasks(D)
    local a6 = GetEntityCoords(ad, true)
    DetachEntity(D, true, true)
    SetEntityCoords(D, a6.x, a6.y, a6.z - 1.0, 0.0, 0.0, 0.0, false)
    aa(D, ab)
end
local function ai(D, a8, E)
    ClearPedTasks(D)
    VICE.loadAnimDict(a8)
    TaskPlayAnim(D, a8, E, 8.0, -8.0, -1, 2, 0.0, false, false, false)
    RemoveAnimDict(a8)
end
local function aj(D, a8, E)
    ClearPedTasks(D)
    VICE.loadAnimDict(a8)
    TaskPlayAnim(D, a8, E, 8.0, -8.0, -1, 2, 0.0, false, false, false)
    RemoveAnimDict(a8)
end
local function ak(D, ab)
    local ac = GetPlayerFromServerId(ab)
    if ac == -1 then
        return
    end
    local ad = GetPlayerPed(ac)
    if ad == 0 then
        return
    end
    DetachEntity(D)
    TaskFollowToOffsetOfEntity(D, ad, 0.0, 0.0, 0.0, 1.0, -1, 10.0, true)
    ClearPedTasks(D)
end
local function al(D, ab, O)
    local ac = GetPlayerFromServerId(ab)
    if ac == -1 then
        return
    end
    local ad = GetPlayerPed(ac)
    if ad == 0 then
        return
    end
    if O then
        AttachEntityToEntity(
            D,
            ad,
            GetPedBoneIndex(ad, 24818),
            0.17,
            0.0,
            -0.18,
            0.0,
            90.0,
            0.0,
            false,
            false,
            false,
            true,
            1,
            true
        )
    else
        AttachEntityToEntity(
            D,
            ad,
            GetPedBoneIndex(ad, 24818),
            0.17,
            0.0,
            0.2,
            0.0,
            90.0,
            0.0,
            false,
            false,
            false,
            true,
            1,
            true
        )
    end
end
local function am(D, ab)
    local ac = GetPlayerFromServerId(ab)
    if ac == -1 then
        return
    end
    local ad = GetPlayerPed(ac)
    if ad == 0 then
        return
    end
    local a6 = GetEntityCoords(ad, true)
    SetEntityCoords(D, a6.x, a6.y, a6.z - 1.0, 0.0, 0.0, 0.0, false)
end
RegisterNetEvent(
    "VICE:receivePetCommand",
    function(N, M, ...)
        if not NetworkDoesNetworkIdExist(N) then
            return
        end
        local D = NetworkGetEntityFromNetworkId(N)
        if D == 0 then
            return
        end
        if M == "petPerformTrick" then
            a7(D, ...)
        elseif M == "petDelete" then
            a9(D, ...)
        elseif M == "petFollow" then
            aa(D, ...)
        elseif M == "petStay" then
            ae(D, ...)
        elseif M == "putPetInVehicle" then
            af(D, ...)
        elseif M == "removePetFromVehicle" then
            ah(D, ...)
        elseif M == "petSit" then
            ai(D, ...)
        elseif M == "petAttack" then
            aj(D, ...)
        elseif M == "petOnGround" then
            ak(D, ...)
        elseif M == "petOnShoulder" then
            al(D, ...)
        elseif M == "tpPet" then
            am(D, ...)
        end
    end
)
function showNotification(an, ao)
    BeginTextCommandThefeedPost("STRING")
    if an == i.Success then
        AddTextComponentSubstringPlayerName("~g~~h~Success~h~~s~: " .. ao)
    elseif an == i.Error then
        AddTextComponentSubstringPlayerName("~r~~h~Error~h~~s~: " .. ao)
    elseif an == i.Alert then
        AddTextComponentSubstringPlayerName("~y~~h~Alert~h~~s~: " .. ao)
    elseif an == i.Unknown then
        AddTextComponentSubstringPlayerName(ao)
    elseif an == i.Info then
        AddTextComponentSubstringPlayerName("~b~~h~Info~h~~s~: " .. ao)
    else
        AddTextComponentSubstringPlayerName(ao)
    end
    EndTextCommandThefeedPostTicker(false, false)
end
function func_petHandler(m)
    if h.active then
        if DoesEntityExist(h.handle) and IsEntityDead(h.handle) then
            drawNativeText("Your pet has ~b~died~w~, please wait before respawning.")
            showNotification(i.Alert, "Please wait 5 minutes before respawning the pet.")
            local D = h.id
            SetTimeout(
                300000,
                function()
                    d.pets[D].info.dead = false
                end
            )
            d.pets[h.id].info.dead = true
            h.active = false
            RMenu:Get("vicepets", "main"):SetSubtitle("Select your ~b~Pet")
        else
            if not d.pets[h.id].awaitingHealthReduction and d.pets[h.id].health < 1 then
                d.pets[h.id].awaitingHealthReduction = true
                SetTimeout(
                    300000,
                    function()
                        local ap = d.pets[h.id].health
                        local aq = ap - 10
                        if aq < 2 then
                            aq = 1
                            showNotification(
                                i.Alert,
                                "You must feed your pet to continue using it. Head to a pet store!"
                            )
                        end
                        d.pets[h.id].health = aq
                        d.pets[h.id].awaitingHealthReduction = false
                        TriggerServerEvent("VICE:updatePetHealthServer", h.id, aq)
                        RMenu:Get("vicepets", "main"):SetSubtitle(
                            "~b~Pet: ~w~" .. d.pets[h.id].name .. " ~b~Health: ~w~" .. d.pets[h.id].health .. "/100"
                        )
                    end
                )
            end
        end
    else
        if f.cameraEnabled then
            if not RageUI.Visible(RMenu:Get("vicepets", "store")) then
                RenderScriptCams(false, false, 0, 1, 0)
                if f.cameraHandle or f.cameraHandle ~= 0 then
                    DestroyCam(f.cameraHandle, false)
                end
                f.cameraEnabled = false
                f.viewingPet = false
            end
        end
    end
end
function VICE.hasPetSpawned()
    return h.active
end
VICE.createThreadOnTick(func_petHandler)
