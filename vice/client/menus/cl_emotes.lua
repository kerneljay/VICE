local a = module("cfg/cfg_emotes")
RMenu.Add(
    "emotesmenu",
    "mainmenu",
    RageUI.CreateMenu(
        "",
        "Main Menu",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu.Add(
    "emotesmenu",
    "emotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "mainmenu"),
        "",
        "Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu:Get("emotesmenu", "emotes"):AddInstructionButton({"~INPUT_VEH_FLY_ATTACK_CAMERA~", "Favourite emote"})
RMenu.Add(
    "emotesmenu",
    "danceemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Dance Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu:Get("emotesmenu", "danceemotes"):AddInstructionButton({"~INPUT_VEH_FLY_ATTACK_CAMERA~", "Favourite emote"})
RMenu.Add(
    "emotesmenu",
    "customemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Custom Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu:Get("emotesmenu", "customemotes"):AddInstructionButton({"~INPUT_VEH_FLY_ATTACK_CAMERA~", "Favourite emote"})
RMenu.Add(
    "emotesmenu",
    "gunemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Gun Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu:Get("emotesmenu", "gunemotes"):AddInstructionButton({"~INPUT_VEH_FLY_ATTACK_CAMERA~", "Favourite emote"})
RMenu.Add(
    "emotesmenu",
    "favouriteemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Favourite Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu.Add(
    "emotesmenu",
    "propemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Prop Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu:Get("emotesmenu", "propemotes"):AddInstructionButton({"~INPUT_VEH_FLY_ATTACK_CAMERA~", "Favourite emote"})
RMenu.Add(
    "emotesmenu",
    "sharedemotes",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "emotes"),
        "",
        "Shared Emotes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu.Add(
    "emotesmenu",
    "walkingstyles",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "mainmenu"),
        "",
        "Walking Styles",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
RMenu.Add(
    "emotesmenu",
    "moods",
    RageUI.CreateSubMenu(
        RMenu:Get("emotesmenu", "mainmenu"),
        "",
        "Moods",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "menus",
        "emotes"
    )
)
local b = false
local c = ""
local d = {}
local e = 0
local f = nil
local g = nil
local h = nil
local i = nil
local j = {}
local k = nil
local l = 0
local m = nil
local n = 0
local o = 0

local function p()
    for q, prop in pairs(d) do
        DeleteEntity(prop)
    end
    d = {}
end
local function r(s)
    if not b then
        return
    end
    if not s and GetGameTimer() - e < 1500 and not VICE.isDev() then
        notify("~r~Emotes are being rate limited.")
        return
    end
    b = false
    f = nil
    g = nil
    h = nil
    if i then
        if i.handle then
            StopParticleFxLooped(i.handle, false)
        end
        i = nil
    end
    if c == "Scenario" or c == "MaleScenario" then
        ClearPedTasksImmediately(PlayerPedId())
    else
        ClearPedTasks(PlayerPedId())
        p()
    end
end
local function t(u, v, w, x, y, z, A, B)
    local C = PlayerPedId()
    local D = GetEntityCoords(C, true)
    local E = VICE.loadModel(u)
    prop = CreateObject(GetHashKey(u), D.x, D.y, D.z + 0.2, true, true, true)
    AttachEntityToEntity(prop, C, GetPedBoneIndex(C, v), w, x, y, z, A, B, true, true, false, true, 1, true)
    table.insert(d, prop)
    SetModelAsNoLongerNeeded(E)
end
local function F(G)
    SetFacialIdleAnimOverride(PlayerPedId(), G[2], nil)
    b = true
end
local function H(G)
    if VICE.getPlayerVehicle() ~= 0 then
        notify("~r~Can not use scenarios whilst in a vehicle.")
        return
    end
    local C = PlayerPedId()
    if G[1] == "Scenario" then
        ClearPedTasks(C)
        TaskStartScenarioInPlace(C, G[2], 0, true)
    elseif G[1] == "MaleScenario" then
        if VICE.getModelGender() == "male" then
            ClearPedTasks(C)
            TaskStartScenarioInPlace(C, G[2], 0, true)
        else
            notify("~r~This scenario is male only.")
        end
    elseif G[1] == "ScenarioObject" then
        local I = GetOffsetFromEntityInWorldCoords(C, 0.0, 0 - 0.5, -0.5)
        ClearPedTasks(C)
        TaskStartScenarioAtPosition(C, G[2], I.x, I.y, I.z, GetEntityHeading(C), 0, true, false)
    end
    b = true
end
local function J(G)
    local K = G.animationOptions
    if VICE.getPlayerVehicle() ~= 0 then
        return 51
    elseif not K then
        return 0
    elseif K.emoteLoop then
        if K.emoteMoving then
            return 51
        else
            return 1
        end
    elseif K.emoteMoving then
        return 51
    elseif not K.emoteMoving then
        return 0
    elseif K.emoteStuck then
        return 50
    end
    return 0
end
local function L(G)
    if G.animationOptions then
        return G.animationOptions.emoteDuration or -1
    else
        return -1
    end
end
local function M(G)
    local K = G.animationOptions
    if not K then
        return
    end
    local N = K.prop
    if not N then
        return
    end
    local O = K.propBone
    local P, Q, R, S, T, U = table.unpack(K.propPlacement)
    t(N, O, P, Q, R, S, T, U)
    local V = K.secondProp
    if not V then
        return
    end
    local W = K.secondPropBone
    local X, Y, Z, _, a0, a1 = table.unpack(K.secondPropPlacement)
    t(V, W, X, Y, Z, _, a0, a1)
end
local function a2(G)
    local a3, a4 = table.unpack(G)
    local a5 = J(G)
    local a6 = L(G)
    VICE.loadAnimDict(a3)
    TaskPlayAnim(PlayerPedId(), a3, a4, 2.0, 2.0, a6, a5, 0, false, false, false)
    RemoveAnimDict(a3)
    Citizen.Wait(0)
    b = true
    f = a3
    g = a4
    h = G
    local a7 = G.animationOptions
    if a7 and a7.ptfxAsset then
        i = {
            asset = a7.ptfxAsset,
            name = a7.ptfxName,
            placement = a7.ptfxPlacement,
            info = a7.ptfxInfo,
            wait = a7.ptfxWait
        }
        notify(i.info)
    end
    M(G)
end
local a8 = {2, 160, 161, 163, 167}
local function a9(G)
    if not VICE.canAnim() or tVICE.isHandcuffed() or VICE.inEvent() then
        return true
    end
    local C = PlayerPedId()
    if IsPedReloading(C) or IsPlayerFreeAiming(C) or GetEntityHealth(C) <= 102 then
        return true
    end
    if VICE.getPlayerCombatTimer() > 0 then
        return true
    end
    local aa = VICE.getPlayerVehicle()
    if aa ~= 0 and GetEntitySpeed(aa) > 1.0 then
        return true
    end
    for q, ab in pairs(a8) do
        if GetIsTaskActive(C, ab) then
            return true
        end
    end
    if isPlayerNearPrison() then
        if G and G.animationOptions and G.animationOptions.allowedPrison then
            return false
        else
            return true
        end
    end
    return false
end
local function ac(G)
    if a9(G) then
        notify("~r~Can not use this emote at this time.")
        return
    end
    if GetGameTimer() - e < 1500 and not (VICE.hasGroup(VICE.getUserId(), "Founder") or VICE.hasGroup(VICE.getUserId(), "Lead Developer") or VICE.hasGroup(VICE.getUserId(), "Developer")) then
        notify("~r~Emotes are being rate limited.")
        return
    end
    r(true)
    local type = G[1]
    c = type
    e = GetGameTimer()
    if type == "Expression" then
        F(G)
        return
    end
    if type == "Scenario" or type == "MaleScenario" or type == "ScenarioObject" then
        H(G)
        return
    end
    a2(G)
end
local function ad()
    local ae = PlayerId()
    local af = -1
    local ag = 2.0
    local ah = VICE.getPlayerCoords()
    for q, ai in pairs(GetActivePlayers()) do
        if ai ~= ae then
            local aj = GetPlayerPed(ai)
            local ak = #(GetEntityCoords(aj, true) - ah)
            if ak < ag then
                af = ai
                ag = ak
            end
        end
    end
    if af == -1 then
        return 0
    else
        return GetPlayerServerId(af)
    end
end
local function al(am)
    if a9() then
        notify("~r~Can not use shared emotes at this time.")
        return
    end
    local an = ad()
    if an ~= 0 then
        k = am
        l = an
        TriggerServerEvent("VICE:sendSharedEmoteRequest", an, am)
    else
        notify("~r~No player is near by.")
    end
end
local function ao(G)
    Citizen.CreateThreadNow(
        function()
            local ap = G[1]
            VICE.loadAnimDict(ap)
            SetPedMovementClipset(PlayerPedId(), ap, 0.2)
            RemoveAnimSet(ap)
            RemoveAnimDict(ap)
        end
    )
end
local function aq(ar, as)
    local at, au = type(ar), type(as)
    if at ~= au then
        return at < au
    else
        return ar < as
    end
end
local function av(aw, ax)
    local ay = {}
    local az = 1
    for aA in pairs(aw) do
        ay[az] = aA
        az = az + 1
    end
    ax = ax or aq
    table.sort(ay, ax)
    return ay
end
local function aB(aw, ax)
    local ay = av(aw, ax)
    local aC = 0
    return function()
        aC = aC + 1
        local aA = ay[aC]
        if aA ~= nil then
            return aA, aw[aA]
        else
            return nil, nil
        end
    end
end
local function aD(aE)
    if a.emotes[aE] then
        return a.emotes[aE]
    elseif a.dances[aE] then
        return a.dances[aE]
    elseif a.custom[aE] then
        return a.custom[aE]
    elseif a.props[aE] then
        return a.props[aE]
    elseif a.guns[aE] then
        return a.guns[aE]
    end
    return nil
end
local function aF(aE)
    if table.find(j, aE) then
        return {RightLabel = "⭐"}
    end
    return {}
end
local function aG(aH, aE)
    if aH and IsControlJustPressed(0, 121) then
        local az = table.find(j, aE)
        if az and az > 0 then
            table.remove(j, az)
        else
            table.insert(j, aE)
        end
        SetResourceKvp("vice_favourite_emotes", json.encode(j))
    end
end
RageUI.CreateWhile(
    1.0,
    RMenu:Get("emotesmenu", "mainmenu"),
    function()
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "mainmenu"),
            true,
            false,
            true,
            function()
                -- if VICE.isNewPlayer() then
                --     drawNativeNotification("Press ~INPUT_A6B0CFFB~ to toggle the Emote Menu.")
                -- end
                RageUI.Button(
                    "Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "emotes")
                )
                RageUI.Button(
                    "Cancel Emotes",
                    "",
                    {},
                    true,
                    function(aI, aJ, aK)
                        if aK then
                            r(false)
                            e = GetGameTimer()
                        end
                    end
                )
                RageUI.Button(
                    "Walking Styles",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "walkingstyles")
                )
                RageUI.Button(
                    "Moods",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "moods")
                )
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "emotes"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "🕺 Dance Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "danceemotes")
                )
                RageUI.Button(
                    "🛠️ Custom Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "customemotes")
                )
                RageUI.Button(
                    "📦 Prop Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "propemotes")
                )
                RageUI.Button(
                    "👫 Shared Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "sharedemotes")
                )
                RageUI.Button(
                    "🔫 Gun Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "gunemotes")
                )
                RageUI.Button(
                    "⭐ Favourite Emotes",
                    "",
                    {},
                    true,
                    function()
                    end,
                    RMenu:Get("emotesmenu", "favouriteemotes")
                )
                for aE, G in aB(a.emotes) do
                    RageUI.Button(
                        G[3],
                        "/e (" .. aE .. ")",
                        aF(aE),
                        not a9(G),
                        function(aI, aJ, aK)
                            aG(aJ, aE)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "danceemotes"),
            true,
            false,
            true,
            function()
                for aE, G in aB(a.dances) do
                    RageUI.ButtonWithStyle(
                        G[3],
                        "/e (" .. aE .. ")",
                        aF(aE),
                        not a9(G),
                        function(aI, aJ, aK)
                            aG(aJ, aE)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "customemotes"),
            true,
            false,
            true,
            function()
                for aE, G in aB(a.custom) do
                    RageUI.ButtonWithStyle(
                        G[3],
                        "/e (" .. aE .. ")",
                        aF(aE),
                        not a9(G),
                        function(aI, aJ, aK)
                            aG(aJ, aE)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "gunemotes"),
            true,
            false,
            true,
            function()
                for aE, G in aB(a.guns) do
                    RageUI.ButtonWithStyle(
                        G[3],
                        "/e (" .. aE .. ")",
                        aF(aE),
                        not a9(G),
                        function(aI, aJ, aK)
                            aG(aJ, aE)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "favouriteemotes"),
            true,
            false,
            true,
            function()
                if #j == 0 then
                    RageUI.Separator("~y~To favourite an emote press INSERT")
                    RageUI.Separator("~y~Whilst hovering over the button")
                end
                for q, aE in pairs(j) do
                    local G = aD(aE)
                    if G then
                        RageUI.Button(
                            G[3],
                            "/e (" .. aE .. ")",
                            aF(aE),
                            not a9(G),
                            function(aI, aJ, aK)
                                if aK then
                                    ac(G)
                                end
                            end
                        )
                    end
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "propemotes"),
            true,
            false,
            true,
            function()
                for aE, G in aB(a.props) do
                    RageUI.ButtonWithStyle(
                        G[3],
                        "/e (" .. aE .. ")",
                        aF(aE),
                        not a9(G),
                        function(aI, aJ, aK)
                            aG(aJ, aE)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "sharedemotes"),
            true,
            false,
            true,
            function()
                for am, G in aB(a.shared) do
                    if not G.animationOptions or not G.animationOptions.invisible then
                        RageUI.ButtonWithStyle(
                            G[3],
                            "/nearby (~g~" .. am .. "~w~)",
                            aF(aE),
                            not a9(G),
                            function(aI, aJ, aK)
                                if aK then
                                    al(am)
                                end
                            end
                        )
                    end
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "walkingstyles"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Normal (Reset)",
                    "",
                    {},
                    not a9(nil),
                    function(aI, aJ, aK)
                        if aK then
                            ResetPedMovementClipset(PlayerPedId(), 0.0)
                        end
                    end
                )
                for am, G in aB(a.walks) do
                    RageUI.Button(
                        am,
                        "",
                        {},
                        not a9(G),
                        function(aI, aJ, aK)
                            if aK then
                                ao(G)
                            end
                        end
                    )
                end
            end
        )
        RageUI.IsVisible(
            RMenu:Get("emotesmenu", "moods"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Normal (Reset)",
                    "",
                    {},
                    true,
                    function(aI, aJ, aK)
                        if aK then
                            ClearFacialIdleAnimOverride(PlayerPedId())
                        end
                    end
                )
                for am, G in aB(a.moods) do
                    RageUI.Button(
                        am,
                        "",
                        {},
                        true,
                        function(aI, aJ, aK)
                            if aK then
                                ac(G)
                            end
                        end
                    )
                end
            end
        )
    end
)
RegisterCommand(
    "emotemenu",
    function(aL, aM, aN)
        RageUI.Visible(RMenu:Get("emotesmenu", "mainmenu"), not RageUI.Visible(RMenu:Get("emotesmenu", "mainmenu")))
    end,
    false
)
RegisterKeyMapping("emotemenu", "Toggles the emote menu", "KEYBOARD", "F3")
local function aO(aL, aM, aN)
    if #aM < 1 then
        notify("~r~No emote name was specified.")
        return
    end
    local am = string.lower(aM[1])
    if not am then
        notify("~r~No emote name was specified.")
        return
    elseif am == "c" then
        r(false)
        return
    end
    if a.emotes[am] then
        ac(a.emotes[am])
    elseif a.dances[am] then
        ac(a.dances[am])
    elseif a.custom[am] then
        ac(a.custom[am])
    elseif a.props[am] then
        ac(a.props[am])
    elseif a.guns[am] then
        ac(a.guns[am])
    else
        notify("~r~Invalid emote name was specified.")
    end
end
RegisterCommand("e", aO, false)
RegisterCommand("emote", aO, false)
RegisterCommand(
    "nearby",
    function(aL, aM, aN)
        if #aM < 1 then
            notify("~r~No emote name was specified.")
            return
        end
        local am = string.lower(aM[1])
        if not am then
            notify("~r~No emote name was specified.")
            return
        end
        if a.shared[am] then
            al(am)
        else
            notify("~r~Invalid emote name was specified.")
        end
    end,
    false
)
RegisterCommand(
    "walk",
    function(aL, aM, aN)
        if #aM < 1 then
            notify("~r~No walk name was specified.")
            return
        end
        local am = aM[1]
        if not am then
            notify("~r~No walk name was specified.")
            return
        end
        if a.walks[am] then
            if not a9(a.walks[am]) then
                ao(a.walks[am])
            else
                notify("~r~You can not use emotes at this time.")
            end
        else
            notify("~r~Invalid walk name was specified.")
        end
    end,
    false
)
RegisterNetEvent(
    "VICE:sendSharedEmoteRequest",
    function(aP, am)
        if a.shared[am] and not a9() then
            m = am
            n = aP
            o = GetGameTimer()
            notify("~y~Y~w~ to accept, ~r~L~w~ to refuse (~g~" .. a.shared[am][3] .. "~w~)")
        end
    end
)
RegisterNetEvent(
    "VICE:receiveSharedEmoteRequest",
    function(am)
        r(false)
        Citizen.Wait(300)
        ac(a.shared[am])
    end
)
RegisterNetEvent(
    "VICE:receiveSharedEmoteRequestSource",
    function()
        local aQ = GetPlayerFromServerId(l)
        if aQ == -1 then
            return
        end
        local aR = GetPlayerPed(aQ)
        if aR == 0 then
            return
        end
        local aS = GetEntityHeading(aR)
        local D = GetOffsetFromEntityInWorldCoords(aR, 0.0, 1.0, 0.0)
        local G = a.shared[k]
        if G.animationOptions and G.animationOptions.syncOffsetFront then
            D = GetOffsetFromEntityInWorldCoords(aR, 0.0, G.animationOptions.syncOffsetFront, 0.0)
        end
        local C = PlayerPedId()
        SetEntityHeading(C, aS - 180.1)
        SetEntityCoordsNoOffset(C, D.x, D.y, D.z, 0)
        r(false)
        Citizen.Wait(300)
        ac(G)
    end
)
local function aT()
    m = nil
    n = 0
    o = 0
end
local function aU()
    if i.handle then
        return
    end
    VICE.loadPtfx(i.asset)
    if not i then
        return
    end
    UseParticleFxAsset(i.asset)
    local aV, aW, aX, aY, aZ, a_, b0 = table.unpack(i.placement)
    i.handle =
        StartNetworkedParticleFxLoopedOnEntityBone(
        i.name,
        PlayerPedId(),
        aV,
        aW,
        aX,
        aY,
        aZ,
        a_,
        GetEntityBoneIndexByName(i.name, "VFX"),
        1065353216,
        0,
        0,
        0
    )
    Citizen.CreateThread(
        function()
            if i then
                SetParticleFxLoopedColour(i.handle, 1.0, 1.0, 1.0, false)
                Citizen.Wait(i.wait)
                if i then
                    StopParticleFxLooped(i.handle, false)
                    i.handle = nil
                end
            end
        end
    )
end
local function b1()
    if m then
        if GetGameTimer() - o > 5000 then
            aT()
        elseif IsControlJustPressed(1, 246) then
            if a9() then
                notify("~r~You can not use emotes at this time.")
            else
                TriggerServerEvent("VICE:receiveSharedEmoteRequest", n, a.shared[m][4])
            end
            aT()
        end
    end
    if b and f and g then
        if i and IsControlJustPressed(0, 47) then
            aU()
        end
        if not IsEntityPlayingAnim(PlayerPedId(), f, g, 3) or a9(h) then
            r(true)
        end
    end
end
function VICE.playEmote(am)
    if a.emotes[am] then
        ac(a.emotes[am])
    elseif a.dances[am] then
        ac(a.dances[am])
    elseif a.custom[am] then
        ac(a.custom[am])
    elseif a.props[am] then
        ac(a.props[am])
    elseif a.guns[am] then
        ac(a.guns[am])
    end
end
VICE.cancelEmote = r
Citizen.CreateThread(
    function()
        j = json.decode(GetResourceKvpString("vice_favourite_emotes") or "{}") or {}
        TriggerEvent(
            "chat:addSuggestion",
            "/e",
            "Play an emote",
            {{name = "emotename", help = "dance, camera, sit or any valid emote."}}
        )
        TriggerEvent(
            "chat:addSuggestion",
            "/emote",
            "Play an emote",
            {{name = "emotename", help = "dance, camera, sit or any valid emote."}}
        )
        TriggerEvent("chat:addSuggestion", "/emotemenu", "Open emotes menu (F3) by default.")
        TriggerEvent(
            "chat:addSuggestion",
            "/walk",
            "Set your walkingstyle.",
            {{name = "style", help = "/walks for a list of valid styles"}}
        )
        VICE.createThreadOnTick(b1)
    end
)
