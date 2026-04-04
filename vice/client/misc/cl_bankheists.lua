--[[local a = module("cfg/heists/cfg_heist")
RegisterHeistEvent = RegisterNetEvent
local function b()
    TriggerServerEvent("VICE:bankHeistsRequestState")
end
local c = vector3(707.01, -966.64, 30.41)
local d = vector3(707.95, -960.6, 30.4)
local e = vector3(718.31, -979.23, 24.12)
local function f(g, h, i)
    if VICE.isDev() then
        g(h)
    else
        local j, k = pcall(g, h)
        if not j then
            if i then
                TriggerServerEvent("VICE:bankHeistsLeaveSetup", true)
            end
            error(k)
        end
    end
end
local function l(m)
    local n = LoadResourceFile(GetCurrentResourceName(), string.format("cfg/heists/client/cfg_%s.lua", m))
    assert(n ~= nil, string.format("Failed to read bank heist setup file (name: %s)", m))
    local o = load(n)
    assert(o ~= nil, string.format("Failed to load chunks for bank heist setup (name: %s)", m))
    local j, k = pcall(o)
    assert(j, k)
    return k
end
local p = nil
local function q(h)
    for r, s in ipairs(GetGamePool("CPed")) do
        SetPedDropsWeaponsWhenDead(s, false)
    end
    for r, t in ipairs(GetGamePool("CPickup")) do
        RemovePickup(t)
        DeleteEntity(t)
    end
    if h.usedWeapons and type(h.usedWeapons) == "table" then
        local u = PlayerPedId()
        for r, v in ipairs(h.usedWeapons) do
            if HasPedGotWeapon(u, v, false) then
                RemoveWeaponFromPed(u, v)
            end
            SetCanPedEquipWeapon(u, v, false)
            ToggleUsePickupsForPlayer(PlayerId(), v, false)
        end
    end
end
local function w()
    while p do
        if p.stageIndex then
            local x = p.stages[p.stageIndex]
            if not p.stageSetup then
                print(string.format("Received stage change (stage: %s)", x.name))
                if p.prevStageIndex then
                    local y = p.stages[p.prevStageIndex]
                    if y.clean and p.inited[p.prevStageIndex] then
                        print(string.format("Required to clean previous stage (prevStage: %s)", y.name))
                        f(y.clean, p.info, true)
                    end
                end
                if x.init then
                    print(string.format("Required to initialise stage (stage: %s)", x.name))
                    f(x.init, p.info, true)
                    p.inited[p.stageIndex] = true
                end
                p.info.lastInit = GetGameTimer()
                p.stageSetup = true
            end
            q(p.info)
            if x.run then
                f(x.run, p.info, true)
            end
            if x.isFinishStage and not p.isLeaving then
                if #(VICE.getPlayerCoords() - c) < 15.0 then
                    TriggerServerEvent("VICE:bankHeistsLeaveSetup", false)
                    p.isLeaving = true
                end
            end
        end
        Citizen.Wait(0)
    end
end
RegisterNetEvent(
    "VICE:bankHeistNewSetup",
    function(h)
        print(string.format("Received new setup request (name: %s)", h.name))
        p = l(h.name)
        p.info = h
        p.isLeaving = false
        p.stageSetup = false
        p.inited = {}
        ExecuteCommand("hideids")
        if VICE.setRedzoneTimerDisabled then
            VICE.setRedzoneTimerDisabled(true)
        end
        VICE.setTime(h.time.hour, h.time.minute, 0)
        VICE.setWeather(h.weather)
        Citizen.CreateThreadNow(
            function()
                local z = GetGameTimer()
                while GetGameTimer() - z < 10000 do
                    drawNativeNotification("You can return to the factory office at any time to exit the setup")
                    Citizen.Wait(0)
                end
            end
        )
        w()
    end
)
RegisterNetEvent(
    "VICE:bankHeistSetSetupStage",
    function(A)
        for B, x in ipairs(p.stages) do
            if x.name == A then
                p.prevStageIndex = p.stageIndex
                p.stageIndex = B
                break
            end
        end
        p.stageSetup = false
    end
)
RegisterNetEvent(
    "VICE:bankHeistsSetupPlayerRemoved",
    function(C)
        print(string.format("Received player removed (server: %d)", C))
        table.remove(p.info.players, table.find(p.info.players, C))
    end
)
local function D(E, F)
    VICE.showUI()
    SetPlayerControl(PlayerId(), true, 0)
    local x = p.stages[p.stageIndex]
    if x.clean and p.inited[p.stageIndex] then
        f(x.clean, p.info, false)
    end
    if p.finish then
        f(p.finish, p.info, false)
    end
    p = nil
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Citizen.Wait(5000)
    SetEntityCoords(PlayerPedId(), d.x, d.y, d.z, false, false, false)
    SwitchInPlayer(PlayerPedId())
    while IsPlayerSwitchInProgress() do
        Citizen.Wait(0)
    end
    SetPlayerControl(PlayerId(), true, 0)
    VICE.showUI()
    ExecuteCommand("showids")
    if VICE.setRedzoneTimerDisabled then
        VICE.setRedzoneTimerDisabled(false)
    end
    tVICE.announceMpBigMsg(E, F, 10000)
    b()
end
RegisterNetEvent(
    "VICE:bankHeistsLeaveSetup",
    function(E, F)
        print(string.format("Receieved leave setup request (title: %s subtitle: %s)", E, F))
        D(E, F)
    end
)
local G = nil
local H = false
local function I(J)
    G.moving = true
    RageUI.Visible(RMenu:Get("bankheistssetup", "mainmenu"), false)
    if G.camera then
        SetCamActive(G.camera, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyCam(G.camera)
        G.camera = nil
    end
    G.setupNumber = J
    if G.isHost then
        TriggerServerEvent("VICE:bankHeistsSetSetupNumber", J)
    end
    local x = a.setups[J]
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Citizen.Wait(5000)
    SetEntityCoords(PlayerPedId(), x.position.x, x.position.y, x.position.z, false, false, false)
    SetEntityHeading(PlayerPedId(), x.heading)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)
    SwitchInPlayer(PlayerPedId())
    while IsPlayerSwitchInProgress() do
        Citizen.Wait(0)
    end
    BeginScaleformMovieMethod(G.scaleform, "SET_MENU_TITLE")
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(x.title)
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(G.scaleform, "SET_MENU_HELP_TEXT")
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay(x.description)
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()
    G.camera =
        CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        x.position.x,
        x.position.y,
        x.position.z,
        x.rotation.x,
        x.rotation.y,
        x.rotation.z,
        70.0,
        false,
        2
    )
    SetCamActive(G.camera, true)
    RenderScriptCams(true, false, 0, false, false)
    G.moving = false
end
local function K(L)
    while G.moving do
        Citizen.Wait(0)
    end
    RageUI.Visible(RMenu:Get("bankheistssetup", "mainmenu"), false)
    if G.camera then
        SetCamActive(G.camera, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyCam(G.camera)
        G.camera = nil
    end
    SetScaleformMovieAsNoLongerNeeded(G.scaleform)
    G.scaleform = nil
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Citizen.Wait(5000)
    if L then
        SetEntityCoords(PlayerPedId(), e.x, e.y, e.z, false, false, false)
    else
        SetEntityCoords(PlayerPedId(), c.x, c.y, c.z, false, false, false)
    end
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)
    SwitchInPlayer(PlayerPedId())
    while IsPlayerSwitchInProgress() do
        Citizen.Wait(0)
    end
    SetPlayerControl(PlayerId(), true, 0)
    AnimpostfxStop("MP_OrbitalCannon")
    VICE.showUI()
    G = nil
    if not L then
        b()
    end
end
local function M(N)
    if N then
        TriggerServerEvent("VICE:bankHeistsEnterTransition")
    end
    SetPlayerControl(PlayerId(), false, 0)
    AnimpostfxPlay("MP_OrbitalCannon", 0, true)
    VICE.showUI()
    G = {}
    G.isHost = N
    G.players = {}
    G.setupNumber = 1
    G.scaleform = RequestScaleformMovie("ORBITAL_CANNON_CAM")
    while not HasScaleformMovieLoaded(G.scaleform) do
        Citizen.Wait(0)
    end
    BeginScaleformMovieMethod(G.scaleform, "SET_STATE")
    ScaleformMovieMethodAddParamInt(1)
    EndScaleformMovieMethod()
    Citizen.Wait(0)
    I(G.setupNumber)
    while G do
        if G.camera then
            if G.isHost and not G.blockInteraction then
                if IsDisabledControlJustPressed(0, 174) then
                    if G.setupNumber - 1 > 0 then
                        I(G.setupNumber - 1)
                    end
                end
                if IsDisabledControlJustPressed(0, 175) then
                    if G.setupNumber + 1 <= #a.setups then
                        I(G.setupNumber + 1)
                    end
                end
            end
            if not G.blockInteraction and IsDisabledControlJustPressed(0, 200) then
                TriggerServerEvent("VICE:bankHeistsLeaveTransition")
                return
            end
            DrawScaleformMovieFullscreen(G.scaleform, 255, 255, 255, 255, 0)
            RageUI.Visible(RMenu:Get("bankheistssetup", "mainmenu"), true)
        end
        Citizen.Wait(0)
    end
end
RMenu.Add(
    "bankheistssetup",
    "mainmenu",
    RageUI.CreateMenu("Heist Setup", "Main Menu", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RageUI.CreateWhile(
    1.0,
    RMenu:Get("bankheistssetup", "mainmenu"),
    nil,
    function()
        RageUI.IsVisible(
            RMenu:Get("bankheistssetup", "mainmenu"),
            true,
            true,
            true,
            function()
                RageUI.Separator(string.format("Joined Players (%d/10)", #G.players))
                for r, O in ipairs(G.players) do
                    RageUI.ButtonWithStyle(
                        O.name,
                        "",
                        {RightLabel = O.isHost and "HOST" or "CREW"},
                        true,
                        function()
                        end
                    )
                end
                if G.blockInteraction then
                    RageUI.Separator("Waiting for heist preparation...")
                else
                    RageUI.Separator("Heist Options")
                    RageUI.Button(
                        "~b~Buy Full Armour",
                        "",
                        {},
                        function(P, Q, R)
                            if R then
                                TriggerServerEvent("VICE:bankHeistsBuyFullArmour")
                            end
                        end
                    )
                    if G.isHost then
                        if #G.players < 10 then
                            RageUI.Button(
                                "~b~Invite Player",
                                "",
                                {},
                                function(P, Q, R)
                                    if R then
                                        tVICE.clientPrompt(
                                            "User's Perm Id",
                                            "",
                                            function(S)
                                                local T = tonumber(S)
                                                if T then
                                                    TriggerServerEvent("VICE:bankHeistsTransitionInvitePlayer", T)
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                        end
                        local x = a.setups[G.setupNumber]
                        RageUI.Button(
                            string.format("~b~Start Heist (£%s)", getMoneyStringFormatted(x.cost)),
                            "",
                            {},
                            function(P, Q, R)
                                if R then
                                    TriggerServerEvent("VICE:bankHeistsTransitionSelect", G.setupNumber)
                                end
                            end
                        )
                    else
                        RageUI.Separator("Waiting for host...")
                    end
                end
            end,
            function()
            end
        )
    end
)
RMenu:Get("bankheistssetup", "mainmenu"):AddInstructionButton({"~INPUT_CELLPHONE_CANCEL~", "Exit Selection"})
RMenu:Get("bankheistssetup", "mainmenu"):AddInstructionButton({"~INPUT_CELLPHONE_RIGHT~", "Next Setup"})
RMenu:Get("bankheistssetup", "mainmenu"):AddInstructionButton({"~INPUT_CELLPHONE_LEFT~", "Previous Setup"})
RegisterNetEvent(
    "VICE:bankHeistsSetTransitionInfo",
    function(U, J)
        if not G then
            Citizen.CreateThreadNow(
                function()
                    M(false)
                end
            )
            G.players = U
            G.setupNumber = J
        else
            G.players = U
            if G.setupNumber ~= J then
                if not G.isHost then
                    I(J)
                end
            end
        end
    end
)
RegisterNetEvent(
    "VICE:bankHeistsLeaveTransition",
    function(L)
        K(L)
    end
)
RegisterNetEvent(
    "VICE:bankHeistsTransitionSelect",
    function()
        G.blockInteraction = true
        BeginTextCommandBusyspinnerOn("CELEB_WPLYRS")
        EndTextCommandBusyspinnerOn(4)
        Citizen.Wait(15000)
        BusyspinnerOff()
    end
)
RegisterNetEvent(
    "VICE:bankHeistsRequestInvite",
    function(m)
        if H then
            H = false
            Citizen.Wait(0)
            Citizen.Wait(0)
        end
        H = true
        local V = GetGameTimer()
        while GetGameTimer() - V < 10000 do
            if not H then
                return
            end
            VICE.notify(
                string.format("%s has invited you to a setup, press (~y~Y~w~) to accept (~r~L~w~) to refuse", m)
            )
            if IsControlJustPressed(0, 246) then
                VICE.notify("~g~Request Accepted")
                TriggerServerEvent("VICE:bankHeistsAcceptInvite")
                H = false
            elseif IsControlJustPressed(0, 182) then
                VICE.notify("~g~Request Refused")
                H = false
            end
            Citizen.Wait(0)
        end
        H = false
    end
)
local function W()
    if not G then
        if p then
            if not p.isLeaving then
                drawNativeNotification("Press ~INPUT_PICKUP~ to exit setup")
                DisableControlAction(0, 38, true)
                if IsDisabledControlJustPressed(0, 38) then
                    TriggerServerEvent("VICE:bankHeistsLeaveSetup", false)
                    p.isLeaving = true
                end
            end
        else
            drawNativeNotification("Press ~INPUT_PICKUP~ to enter setups")
            DisableControlAction(0, 38, true)
            if IsDisabledControlJustPressed(0, 38) then
                VICE.notify("~r~Heists are currently disabled.")
            end
        end
    end
end
tVICE.addMarker(c.x, c.y, c.z, 0.5, 0.5, 0.5, 10, 255, 81, 170, 50, 2, false, false, true)
tVICE.addBlip(c.x, c.y, c.z, 363, 26, "Heist Setup Factory")
VICE.createArea(
    "bankheists_select_setups",
    c,
    2.0,
    5.0,
    function()
    end,
    function()
    end,
    W,
    nil
)
local X = {
    state = "INACTIVE",
    lastStateChange = 0,
    hacking = {scaleform = nil, buttons = nil, lives = nil, text = nil, type = nil},
    trollies = {},
    lastHurt = 0,
    lootedAmount = 0,
    alarmDisabled = false
}
local Y = GetGameTimer()
local Z = "UNKNOWN"
local _ = false
local a0 = false
local a1 = false
function tVICE.isPlayerInBankHeistSetup()
    return G or p ~= nil
end
local function a2(a3)
    print(string.format("[BankHeist] %s", a3))
end
RegisterNetEvent(
    "VICE:bankHeistsBeingRobbed",
    function()
        tVICE.announceMpSmallMsg("ALERT", "An alarm has been triggered at the Bank of Scotland", 9, 10000)
    end
)
RegisterNetEvent(
    "VICE:bankHeistsAlarmDisable",
    function(a4)
        X.alarmDisabled = a4
    end
)
local function a5()
    if globalOnPoliceDuty and not X.alarmDisabled and X.state ~= "INACTIVE" then
        drawNativeNotification("Press ~INPUT_PICKUP~ to turn off the alarm")
    end
end
local function a6()
    if globalOnPoliceDuty and not X.alarmDisabled and X.state ~= "INACTIVE" then
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent("VICE:bankHeistsAlarmDisable")
        end
    end
end
VICE.createArea(
    "bankheists_alarm_disable",
    a.alarmDisablePos,
    2.0,
    2.0,
    a5,
    function()
    end,
    a6,
    nil
)
local function a7()
    local a8 = GetResourceKvpInt("vice_bankheists_lastdone")
    if a8 and type(a8) == "number" and a8 > 0 then
        local a9 = a.playerDelayBetweenHeists - (GetCloudTimeAsInt() - a8)
        local aa = math.floor(a9 / 60)
        local ab = math.floor(aa / 60)
        local ac = math.floor(ab / 24)
        if ac > 0 then
            aa = aa - ab * 60
            ab = ab - ac * 24
            return string.format("%dd %dh %dm", ac, ab, aa)
        elseif ab > 0 then
            aa = aa - ab * 60
            return string.format("%dh %dm", ab, aa)
        else
            return string.format("%dm", aa)
        end
    else
        return "no time"
    end
end
local function ad()
    local a8 = GetResourceKvpInt("vice_bankheists_lastdone")
    if a8 and type(a8) == "number" and a8 > 0 then
        local a9 = GetCloudTimeAsInt() - a8
        if a9 < 1800 or a9 > a.playerDelayBetweenHeists then
            return false
        else
            drawNativeNotification(string.format("You can not interact with a heist for another %s", a7()))
            return true
        end
    else
        return false
    end
end
local function ae()
    SetResourceKvpInt("vice_bankheists_lastdone", GetCloudTimeAsInt())
end
local function af(ag)
    SetScaleformMovieAsNoLongerNeeded(X.hacking.scaleform)
    SetScaleformMovieAsNoLongerNeeded(X.hacking.buttons)
    X.hacking.scaleform = nil
    X.hacking.buttons = nil
    X.hacking.lives = nil
    X.hacking.text = nil
    X.hacking.type = nil
    if ag then
        FreezeEntityPosition(PlayerPedId(), false)
        VICE.showUI()
        TriggerServerEvent("VICE:bankHeistsExitHacking")
    end
end
local function ah()
    Z = "MoveToSecondHacking"
    af(false)
    TriggerEvent(
        "ultra-voltlab",
        60,
        function(ai, a3)
            a2(string.format("Received voltlab callback (status: %sd message: %s)", ai, a3))
            if ai == 1 then
                ae()
                TriggerServerEvent("VICE:bankHeistsFinishHacking")
            else
                TriggerServerEvent("VICE:bankHeistsExitHacking")
            end
            FreezeEntityPosition(PlayerPedId(), false)
            VICE.showUI()
        end
    )
    X.hacking.type = 2
end
local function aj()
    VICE.showUI()
    local ak = RequestScaleformMovieInteractive("HACKING_PC")
    while not HasScaleformMovieLoaded(ak) do
        Citizen.Wait(0)
    end
    X.hacking.scaleform = ak
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LABELS")
    ScaleformMovieMethodAddParamTextureNameString("Local Disk (C:)")
    ScaleformMovieMethodAddParamTextureNameString("Network")
    ScaleformMovieMethodAddParamTextureNameString("External Device (F:)")
    ScaleformMovieMethodAddParamTextureNameString("sonic.exe")
    ScaleformMovieMethodAddParamTextureNameString("keyhack.exe")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_BACKGROUND")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "ADD_PROGRAM")
    ScaleformMovieMethodAddParamFloat(1.0)
    ScaleformMovieMethodAddParamFloat(4.0)
    ScaleformMovieMethodAddParamTextureNameString("My Computer")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "ADD_PROGRAM")
    ScaleformMovieMethodAddParamFloat(6.0)
    ScaleformMovieMethodAddParamFloat(6.0)
    ScaleformMovieMethodAddParamTextureNameString("Power Off")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(1)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(3)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(4)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(5)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(6)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_COLUMN_SPEED")
    ScaleformMovieMethodAddParamInt(7)
    ScaleformMovieMethodAddParamInt(255)
    EndScaleformMovieMethod()
    X.hacking.lives = 5
    X.hacking.text = a.terminalHack.words[math.random(1, #a.terminalHack.words)]
    X.hacking.type = 1
end
local function al()
    Z = "OnTickHackingScaleform"
    DrawScaleformMovieFullscreen(X.hacking.scaleform, 255, 255, 255, 255, 0)
    DrawScaleformMovieFullscreen(X.hacking.buttons, 255, 255, 255, 255, 0)
    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_CURSOR")
    ScaleformMovieMethodAddParamFloat(GetDisabledControlNormal(0, 239))
    ScaleformMovieMethodAddParamFloat(GetDisabledControlNormal(0, 240))
    EndScaleformMovieMethod()
    DisableControlAction(0, 24, true)
    if IsDisabledControlJustPressed(0, 24) then
        BeginScaleformMovieMethod(X.hacking.scaleform, "SET_INPUT_EVENT_SELECT")
        X.hacking.returnValue = EndScaleformMovieMethodReturnValue()
        PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
    end
    DisableControlAction(0, 25, true)
    if IsDisabledControlJustPressed(0, 25) then
        BeginScaleformMovieMethod(X.hacking.scaleform, "SET_INPUT_EVENT_BACK")
        EndScaleformMovieMethod()
        PlaySoundFrontend(-1, "HACKING_CLICK", "", true)
    end
    if X.hacking.lives <= 0 then
        af(true)
        return
    end
    if IsScaleformMovieMethodReturnValueReady(X.hacking.returnValue) then
        local am = GetScaleformMovieMethodReturnValueInt(X.hacking.returnValue)
        if am == 82 then
            PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
        elseif am == 83 then
            BeginScaleformMovieMethod(X.hacking.scaleform, "RUN_PROGRAM")
            ScaleformMovieMethodAddParamFloat(83.0)
            EndScaleformMovieMethod()
            BeginScaleformMovieMethod(X.hacking.scaleform, "SET_ROULETTE_WORD")
            ScaleformMovieMethodAddParamTextureNameString(X.hacking.text)
            EndScaleformMovieMethod()
        elseif am == 87 then
            X.hacking.lives = X.hacking.lives - 1
            BeginScaleformMovieMethod(X.hacking.scaleform, "SET_ROULETTE_WORD")
            ScaleformMovieMethodAddParamTextureNameString(X.hacking.text)
            EndScaleformMovieMethod()
            BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LIVES")
            ScaleformMovieMethodAddParamInt(X.hacking.lives)
            ScaleformMovieMethodAddParamInt(5)
            EndScaleformMovieMethod()
            PlaySoundFrontend(-1, "HACKING_CLICK_BAD", "", false)
        elseif am == 86 then
            PlaySoundFrontend(-1, "HACKING_SUCCESS", "", true)
            Citizen.CreateThread(
                function()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_ROULETTE_OUTCOME")
                    ScaleformMovieMethodAddParamBool(true)
                    ScaleformMovieMethodAddParamTextureNameString("BRUTEFORCE SUCCESSFUL!")
                    EndScaleformMovieMethod()
                    Citizen.Wait(2500)
                    BeginScaleformMovieMethod(X.hacking.scaleform, "CLOSE_APP")
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "OPEN_LOADING_PROGRESS")
                    ScaleformMovieMethodAddParamBool(true)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_PROGRESS")
                    ScaleformMovieMethodAddParamInt(35)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_TIME")
                    ScaleformMovieMethodAddParamInt(35)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_MESSAGE")
                    ScaleformMovieMethodAddParamTextureNameString("Writing data to buffer..")
                    ScaleformMovieMethodAddParamFloat(2.0)
                    EndScaleformMovieMethod()
                    Citizen.Wait(2500)
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_MESSAGE")
                    ScaleformMovieMethodAddParamTextureNameString("Executing malicious code..")
                    ScaleformMovieMethodAddParamFloat(2.0)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_TIME")
                    ScaleformMovieMethodAddParamInt(15)
                    EndScaleformMovieMethod()
                    BeginScaleformMovieMethod(X.hacking.scaleform, "SET_LOADING_PROGRESS")
                    ScaleformMovieMethodAddParamInt(75)
                    EndScaleformMovieMethod()
                    Citizen.Wait(1500)
                    ah()
                end
            )
        elseif am == 6 then
            Citizen.Wait(500)
            af(true)
        end
    end
end
local function an()
    X.hacking.buttons = RequestScaleformMovie("instructional_buttons")
    while not HasScaleformMovieLoaded(X.hacking.buttons) do
        Citizen.Wait(0)
    end
    BeginScaleformMovieMethod(X.hacking.buttons, "CLEAR_ALL")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.buttons, "SET_DATA_SLOT")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamPlayerNameString("~INPUT_ATTACK~")
    BeginTextCommandScaleformString("STRING")
    AddTextComponentSubstringKeyboardDisplay("Click / Select")
    EndTextCommandScaleformString()
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.buttons, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(X.hacking.buttons, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()
end
RegisterNetEvent(
    "VICE:bankHeistsStartHacking",
    function()
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        FreezeEntityPosition(PlayerPedId(), true)
        aj()
        an()
    end
)
local function ao()
    Z = "OnTickStaffDoor"
    if not ad() then
        drawNativeNotification("Press ~INPUT_PICKUP~ to plant thermite")
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent("VICE:bankHeistsPlantThermite")
        end
    end
end
local function ap()
    Z = "OnTickVaultDoorHackTerminal"
    if not ad() then
        drawNativeNotification("Press ~INPUT_PICKUP~ to begin hacking")
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent("VICE:bankHeistsStartHacking")
        end
    end
end
local function aq()
    Z = "OnTickSafeDoor"
    if not ad() then
        drawNativeNotification("Press ~INPUT_PICKUP~ to open the safe")
        if IsControlJustPressed(0, 38) then
            TriggerServerEvent("VICE:bankHeistsOpenSafe")
        end
    end
end
local function ar(as, at)
    Z = "EnsureTrollyCreation"
    local au = X.trollies[as]
    if au then
        if au.handle then
            if tonumber(au.state) then
                DeleteEntity(au.handle)
                au.handle = nil
            end
            return
        else
            if tonumber(au.state) then
                return
            end
        end
    end
    if not a1 then
        return
    end
    Z = "EnsureTrollyCreation:LoadModel"
    local v = au and au.state == "LOOTED" and 769923921 or at.model
    if not IsModelValid(v) or not HasModelLoaded(v) then
        RequestModel(v)
        return
    end
    Z = "EnsureTrollyCreation:ValidateInterior"
    local av = GetInteriorAtCoords(at.position.x, at.position.y, at.position.z)
    if not IsValidInterior(av) or not IsInteriorReady(av) then
        return
    end
    Z = "EnsureTrollyCreation:CreateObject"
    local aw = CreateObjectNoOffset(v, at.position.x, at.position.y, at.position.z, false, false, false)
    FreezeEntityPosition(aw, true)
    if at.heading ~= 0 then
        SetEntityHeading(aw, GetEntityHeading(aw) + at.heading)
    end
    SetModelAsNoLongerNeeded(v)
    a2(string.format("Created trolly %d with model %d", as, v))
    Z = "EnsureTrollyCreation:InsertTrolly"
    if au then
        au.handle = aw
        au.config = at
    else
        X.trollies[as] = {handle = aw, config = at, state = nil}
    end
end
local function ax()
    Z = "OnTickLootSafe"
    for as, ay in ipairs(a.trollies) do
        ar(as, ay)
    end
    Z = "OnTickLootSafe:GetClosest"
    local az = nil
    local aA = 10.0
    for r, au in pairs(X.trollies) do
        if au.config then
            local aB = #(VICE.getPlayerCoords() - au.config.position)
            if aB < aA and not au.state then
                az = au
                aA = aB
            end
        end
    end
    if az then
        Z = "OnTickLootSafe:FoundClosest"
        if aA < 2.0 and not ad() then
            drawNativeNotification(string.format("Press ~INPUT_PICKUP~ to steal the %s", az.config.name))
            if IsControlJustPressed(0, 38) then
                TriggerServerEvent("VICE:bankHeistsLootTrolly", table.find(a.trollies, az.config))
            end
        end
    end
    if a1 then
        DrawGTATimerBar("~g~TOTAL TAKE~w~", string.format("£%s", getMoneyStringFormatted(X.lootedAmount)), 0)
        if X.state == "DONE_SAFE" then
            DrawGTATimerBar(
                "~b~TIME TO GAS~w~",
                tostring(math.floor((a.timeToGas - (GetGameTimer() - X.lastStateChange)) / 1000)),
                1
            )
        end
    end
end
local function aC()
    Z = "RemoveTrollies"
    for r, au in pairs(X.trollies) do
        DeleteEntity(au.handle)
    end
    X.trollies = {}
end
RegisterNetEvent(
    "VICE:bankHeistsAddLootedAmount",
    function(aD)
        local aE = 0
        local aF = GetGameTimer()
        while GetGameTimer() - aF < 37000 do
            local aG = math.floor((GetGameTimer() - aF) / 37000 * aD)
            local a9 = aG - aE
            if a9 > 0 then
                aE = aG
                X.lootedAmount = X.lootedAmount + a9
            end
            Citizen.Wait(50)
        end
    end
)
RegisterNetEvent(
    "VICE:bankHeistsLootTrolly",
    function(aH)
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        ae()
        local au = X.trollies[aH]
        local aI = GetEntityModel(au.handle)
        local aJ = GetEntityCoords(au.handle, true)
        local aK = GetEntityRotation(au.handle, 2)
        DeleteEntity(au.handle)
        au.handle = nil
        local aw = CreateObjectNoOffset(aI, aJ.x, aJ.y, aJ.z, true, true, true)
        local u = VICE.getPlayerPed()
        local aL = VICE.getPlayerCoords()
        tVICE.setCanAnim(false)
        VICE.loadModel("hei_p_m_bag_var22_arm_s")
        VICE.loadAnimDict("anim@heists@ornate_bank@grab_cash")
        local aM = CreateObject("hei_p_m_bag_var22_arm_s", aL.x, aL.y, aL.z, true, true, false)
        local aN =
            NetworkCreateSynchronisedScene(aJ.x, aJ.y, aJ.z, aK.x, aK.y, aK.z, 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(
            u,
            aN,
            "anim@heists@ornate_bank@grab_cash",
            "intro",
            1.5,
            -4.0,
            1,
            16,
            1148846080,
            0
        )
        NetworkAddEntityToSynchronisedScene(aM, aN, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
        SetPedComponentVariation(u, 5, 0, 0, 0)
        NetworkStartSynchronisedScene(aN)
        VICE.loadModel(au.config.handModel)
        local aO = CreateObject(au.config.handModel, aL.x, aL.y, aL.z, true, true, false)
        FreezeEntityPosition(aO, true)
        SetEntityInvincible(aO, true)
        SetEntityNoCollisionEntity(aO, u)
        SetEntityVisible(aO, false, false)
        AttachEntityToEntity(
            aO,
            u,
            GetPedBoneIndex(u, 60309),
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            0,
            true
        )
        SetModelAsNoLongerNeeded(au.config.handModel)
        Citizen.CreateThread(
            function()
                local V = GetGameTimer()
                while GetGameTimer() - V < 37000 do
                    DisableControlAction(0, 73, true)
                    if HasAnimEventFired(u, "CASH_APPEAR") then
                        if not IsEntityVisible(aO) then
                            SetEntityVisible(aO, true, false)
                        end
                    end
                    if HasAnimEventFired(u, "RELEASE_CASH_DESTROY") then
                        if IsEntityVisible(aO) then
                            SetEntityVisible(aO, false, false)
                        end
                    end
                    Citizen.Wait(0)
                end
            end
        )
        local aP =
            NetworkCreateSynchronisedScene(aJ.x, aJ.y, aJ.z, aK.x, aK.y, aK.z, 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(
            u,
            aP,
            "anim@heists@ornate_bank@grab_cash",
            "grab",
            1.5,
            -4.0,
            1,
            16,
            1148846080,
            0
        )
        NetworkAddEntityToSynchronisedScene(aM, aP, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
        NetworkAddEntityToSynchronisedScene(
            aw,
            aP,
            "anim@heists@ornate_bank@grab_cash",
            "cart_cash_dissapear",
            4.0,
            -8.0,
            1
        )
        NetworkStartSynchronisedScene(aP)
        Citizen.Wait(37000)
        local aQ =
            NetworkCreateSynchronisedScene(aJ.x, aJ.y, aJ.z, aK.x, aK.y, aK.z, 2, false, false, 1065353216, 0, 1.3)
        NetworkAddPedToSynchronisedScene(
            u,
            aQ,
            "anim@heists@ornate_bank@grab_cash",
            "exit",
            1.5,
            -4.0,
            1,
            16,
            1148846080,
            0
        )
        NetworkAddEntityToSynchronisedScene(aM, aQ, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
        NetworkStartSynchronisedScene(aQ)
        DeleteEntity(aw)
        DeleteObject(aM)
        DeleteObject(aO)
        SetModelAsNoLongerNeeded("hei_p_m_bag_var22_arm_s")
        RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
        tVICE.setCanAnim(true)
    end
)
RegisterNetEvent(
    "VICE:bankHeistsSetTrolliesState",
    function(aR)
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        for as, aS in pairs(aR) do
            if X.trollies[as] then
                X.trollies[as].state = aS
            else
                X.trollies[as] = {state = aS}
            end
        end
    end
)
local function aT()
    if X.state == "INACTIVE" then
        Z = "OnTickInteration:Inactive"
        if #(VICE.getPlayerCoords() - a.staffDoor) < 2.0 then
            ao()
        end
        if table.count(X.trollies) > 0 then
            aC()
        end
    elseif X.state == "DONE_THERMITE" then
        Z = "OnTickInteraction:DoneThermite"
        if #(VICE.getPlayerCoords() - a.vaultDoorHack) < 1.0 then
            ap()
        end
    elseif X.state == "PENDING_HACKING" then
        Z = "OnTickInteraction:PendingHacking"
        if X.hacking.scaleform then
            al()
        end
    elseif X.state == "DONE_HACKING" then
        Z = "OnTickInteraction:DoneHacking"
        if #(VICE.getPlayerCoords() - a.safeDoorButton) < 1.0 then
            aq()
        end
    elseif X.state == "DONE_SAFE" then
        Z = "OnTickInteraction:DoneSafe"
        if #(VICE.getPlayerCoords() - a.staffDoor) < 50.0 then
            ax()
        end
    end
end
local function aU()
    Z = "OnTickDoors"
    local aV =
        GetClosestObjectOfType(a.staffDoor.x, a.staffDoor.y, a.staffDoor.z, 5.0, a.staffDoorModel, false, false, false)
    local aW = DoesEntityExist(aV)
    if not aW then
        aV =
            GetClosestObjectOfType(
            a.staffDoor.x,
            a.staffDoor.y,
            a.staffDoor.z,
            5.0,
            a.staffDoorThermiteModel,
            false,
            false,
            false
        )
        aW = DoesEntityExist(aV)
    end
    local aX =
        GetClosestObjectOfType(a.vaultDoor.x, a.vaultDoor.y, a.vaultDoor.z, 5.0, a.vaultDoorModel, false, false, false)
    local aY = DoesEntityExist(aX)
    local aZ =
        GetClosestObjectOfType(a.safeDoor.x, a.safeDoor.y, a.safeDoor.z, 5.0, a.safeDoorModel, false, false, false)
    local a_ = DoesEntityExist(aZ)
    local b0 =
        GetClosestObjectOfType(
        a.lockedDoor.x,
        a.lockedDoor.y,
        a.lockedDoor.z,
        5.0,
        a.lockedDoorModel,
        false,
        false,
        false
    )
    local b1 = DoesEntityExist(b0)
    if aW then
        Z = "OnTickDoors:Staff"
        if X.state == "INACTIVE" or X.state == "PENDING_THERMITE" then
            FreezeEntityPosition(aV, true)
            if GetEntityModel(aV) == a.staffDoorThermiteModel then
                RemoveModelSwap(
                    a.staffDoor.x,
                    a.staffDoor.y,
                    a.staffDoor.z,
                    5.0,
                    a.staffDoorModel,
                    a.staffDoorThermiteModel,
                    false
                )
                a2("Removing model swap for staff door")
            end
        else
            FreezeEntityPosition(aV, false)
            if GetEntityModel(aV) == a.staffDoorModel then
                CreateModelSwap(
                    a.staffDoor.x,
                    a.staffDoor.y,
                    a.staffDoor.z,
                    5.0,
                    a.staffDoorModel,
                    a.staffDoorThermiteModel,
                    true
                )
                a2("Creating model swap for staff door")
            end
        end
    end
    if aY then
        Z = "OnTickDoors:Vault"
        if
            X.state == "INACTIVE" or X.state == "PENDING_THERMITE" or X.state == "DONE_THERMITE" or
                X.state == "PENDING_HACKING"
         then
            FreezeEntityPosition(aX, true)
        else
            FreezeEntityPosition(aX, false)
        end
    end
    if a_ then
        Z = "OnTickDoors:Safe"
        FreezeEntityPosition(aZ, true)
        if X.state == "DONE_SAFE" then
            local b2 = GetEntityHeading(aZ)
            if b2 >= 10.0 then
                SetEntityHeading(aZ, b2 - 15.0 * GetFrameTime())
            end
        else
            local b2 = GetEntityHeading(aZ)
            if b2 <= 158.55 then
                SetEntityHeading(aZ, b2 + 10.0 * GetFrameTime())
            end
        end
    end
    if b1 then
        Z = "OnTickDoors:Locked"
        FreezeEntityPosition(b0, true)
    end
end
local function b3()
    Z = "RemoveAlarms"
    for r, b4 in ipairs(X.alarms) do
        StopSound(b4)
        ReleaseSoundId(b4)
    end
    X.alarms = nil
    X.alarmLastFlashed = nil
    ReleaseNamedScriptAudioBank("ALARM_BELL_02")
    a2("Removing alarm audio")
end
local function b5()
    Z = "OnTickAlarms"
    if X.alarms then
        Z = "OnTickAlarms:Flash"
        if GetGameTimer() - X.alarmLastFlashed > 500 then
            for r, b6 in ipairs(a.alarms) do
                DrawLightWithRange(b6.x - 0.5, b6.y - 0.5, b6.z, 255, 0, 0, 5.0, 5.0)
                DrawLightWithRange(b6.x + 0.5, b6.y + 0.5, b6.z, 255, 0, 0, 5.0, 5.0)
                DrawLightWithRange(b6.x, b6.y, b6.z, 255, 0, 0, 5.0, 5.0)
            end
            X.alarmLastFlashed = GetGameTimer()
        end
    else
        if RequestScriptAudioBank("ALARM_BELL_02") then
            Z = "OnTickAlarms:CreateAudio"
            X.alarms = {}
            X.alarmLastFlashed = GetGameTimer()
            for r, b6 in ipairs(a.alarms) do
                local b4 = GetSoundId()
                PlaySoundFromCoord(b4, "Bell_02", b6.x, b6.y, b6.z, "ALARMS_SOUNDSET", false, 0, false)
                table.insert(X.alarms, b4)
            end
            a2("Creating alarm audio")
        end
    end
end
local function b7()
    Z = "OnTickGas"
    if X.gases then
        Z = "OnTickGas:Damage"
        if GetGameTimer() - X.lastHurt > 150 then
            local s = PlayerPedId()
            SetEntityHealth(s, GetEntityHealth(s) - 1)
            X.lastHurt = GetGameTimer()
        end
    else
        VICE.loadPtfx("core")
        Z = "OnTickGas:CreateGas"
        X.gases = {}
        for r, b8 in ipairs(a.gases) do
            UseParticleFxAsset("core")
            local aw =
                StartParticleFxLoopedAtCoord(
                "exp_grd_grenade_smoke",
                b8.position.x,
                b8.position.y,
                b8.position.z,
                0.0,
                0.0,
                0.0,
                b8.scale,
                false,
                false,
                false,
                false
            )
            table.insert(X.gases, aw)
        end
        RemoveNamedPtfxAsset("core")
        a2("Creating gas particle")
    end
end
local function b9()
    Z = "RemoveGases"
    for r, aw in ipairs(X.gases) do
        StopParticleFxLooped(aw, false)
    end
    X.gases = nil
    X.lastHurt = 0
    RemoveNamedPtfxAsset("core")
    a2("Removing gas particle")
end
local function ba()
    Z = "OnTickBankHeist"
    local bb = GetRoomKeyFromEntity(PlayerPedId()) ~= 0
    _ = #(VICE.getPlayerCoords() - a.staffDoor) < 150.0
    a0 = #(VICE.getPlayerCoords() - a.staffDoor) < 60.0 and bb
    a1 = VICE.getPlayerCoords().z < 103.0 and a0
    if tVICE.isPlayerInBankHeistSetup() then
        if X.state ~= "INACTIVE" then
            X.state = "INACTIVE"
            a2("Setting state to INACTIVE as in setup")
        end
    else
        Z = "OnTickBankHeist:TickIteration"
        aT()
    end
    if a0 then
        Z = "OnTickBankHeist:TickDoors"
        aU()
    end
    Z = "OnTickBankHeist:CheckGases"
    if X.state ~= "GAS_VAULT" or not a1 then
        if X.gases then
            b9()
        end
    else
        b7()
    end
    Z = "OnTickBankHeist:CheckAlarms"
    if X.state == "INACTIVE" or not _ or X.alarmDisabled then
        if X.alarms then
            b3()
        end
    else
        b5()
    end
end
Citizen.CreateThread(
    function()
        while true do
            ba()
            Y = GetGameTimer()
            Citizen.Wait(0)
        end
        print("BANK HEIST THREAD EXITED. THIS IS VERY BAD.")
    end
)
Citizen.CreateThread(
    function()
        while true do
            local a9 = GetGameTimer() - Y
            if a9 > 10000 then
                print(string.format("Error running bank heist thread. Last ticked %dms ago at %s.", a9, Z))
            end
            Citizen.Wait(10000)
        end
    end
)
RegisterNetEvent(
    "VICE:bankHeistsSetHeistStates",
    function(aS)
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        X.state = aS
        X.lastStateChange = GetGameTimer()
        print(string.format("Received set heist state (state: %s)", aS))
    end
)
RegisterNetEvent(
    "VICE:bankHeistsPlantThermite",
    function()
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        tVICE.setCanAnim(false)
        VICE.loadAnimDict("anim@heists@ornate_bank@thermal_charge")
        VICE.loadModel("hei_p_m_bag_var22_arm_s")
        VICE.loadModel("hei_prop_heist_thermite")
        local s = VICE.getPlayerPed()
        SetEntityHeading(s, a.staffDoorHack.heading)
        local bc = GetEntityRotation(s, 2)
        local bd = a.staffDoorHack.position
        local aN =
            NetworkCreateSynchronisedScene(bd.x, bd.y, bd.z, bc.x, bc.y, bc.z, 2, false, false, 1065353216, 0, 1.3)
        local aM = CreateObject("hei_p_m_bag_var22_arm_s", bd.x, bd.y, bd.z, true, true, false)
        SetEntityCollision(aM, false, true)
        NetworkAddPedToSynchronisedScene(
            s,
            aN,
            "anim@heists@ornate_bank@thermal_charge",
            "thermal_charge",
            1.5,
            -4.0,
            1,
            16,
            1148846080,
            0
        )
        NetworkAddEntityToSynchronisedScene(
            aM,
            aN,
            "anim@heists@ornate_bank@thermal_charge",
            "bag_thermal_charge",
            4.0,
            -8.0,
            1
        )
        NetworkStartSynchronisedScene(aN)
        Citizen.Wait(1500)
        local be = VICE.getPlayerCoords()
        local bf = CreateObject("hei_prop_heist_thermite", be.x, be.y, be.z + 0.2, true, true, true)
        SetEntityCollision(bf, false, false)
        SetEntityCompletelyDisableCollision(bf, false, false)
        AttachEntityToEntity(bf, s, GetPedBoneIndex(s, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
        Citizen.Wait(4000)
        DeleteEntity(aM)
        SetPedComponentVariation(s, 5, 45, 0, 0)
        DetachEntity(bf, 1, 1)
        FreezeEntityPosition(bf, true)
        SetEntityCollision(bf, false, false)
        SetEntityCompletelyDisableCollision(bf, false, false)
        NetworkStopSynchronisedScene(aN)
        tVICE.setCanAnim(true)
        TaskPlayAnim(s, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
        TaskPlayAnim(s, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 10000, 49, 1, 0, 0, 0)
        Citizen.Wait(10000)
        ClearPedTasks(s)
        DeleteEntity(bf)
        SetModelAsNoLongerNeeded("hei_prop_heist_thermite")
        SetModelAsNoLongerNeeded("hei_p_m_bag_var22_arm_s")
        RemoveAnimDict("anim@heists@ornate_bank@thermal_charge")
    end
)
RegisterNetEvent(
    "VICE:bankHeistsThermiteParticle",
    function()
        if tVICE.isPlayerInBankHeistSetup() then
            return
        end
        VICE.loadPtfx("scr_ornate_heist")
        UseParticleFxAsset("scr_ornate_heist")
        local bg = a.staffDoorHack.particle
        local bh =
            StartParticleFxLoopedAtCoord(
            "scr_heist_ornate_thermal_burn",
            bg.x,
            bg.y,
            bg.z,
            0.0,
            0.0,
            0.0,
            1.0,
            false,
            false,
            false,
            false
        )
        Citizen.Wait(10000)
        StopParticleFxLooped(bh, 0)
        RemoveNamedPtfxAsset("scr_ornate_heist")
    end
)
AddEventHandler(
    "onResourceStop",
    function(bi)
        if GetCurrentResourceName() == bi and p then
            local x = p.stages[p.stageIndex]
            if x.clean then
                x.clean(p.info)
            end
            if p.finish then
                p.finish(p.info)
            end
        end
        aC()
        SetPlayerControl(PlayerId(), true, 0)
    end
)
RMenu.Add(
    "sellBankHeistItems",
    "main",
    RageUI.CreateMenu(
        "",
        "~b~Sell Stolen Bank Items",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight(),
        "vice_blackmarket",
        "vice_blackmarket"
    )
)
RageUI.CreateWhile(
    1.0,
    RMenu:Get("sellBankHeistItems", "main"),
    nil,
    function()
        RageUI.IsVisible(
            RMenu:Get("sellBankHeistItems", "main"),
            true,
            true,
            true,
            function()
                for m, bj in pairs(a.sellableItems) do
                    RageUI.ButtonWithStyle(
                        m,
                        "",
                        {RightLabel = "£" .. getMoneyStringFormatted(a.payouts[bj])},
                        true,
                        function(P, Q, R)
                            if R then
                                TriggerServerEvent("VICE:sellBankHeistItem", bj)
                            end
                        end,
                        nil
                    )
                end
            end,
            function()
            end
        )
    end
)
function onEnterSelling()
    RageUI.Visible(RMenu:Get("sellBankHeistItems", "main"), true)
end
function onExitSelling()
    RageUI.Visible(RMenu:Get("sellBankHeistItems", "main"), false)
end
Citizen.CreateThread(
    function()
        tVICE.addMarker(
            a.sellLocation.x,
            a.sellLocation.y,
            a.sellLocation.z - 0.9,
            0.8,
            0.8,
            0.8,
            200,
            0,
            0,
            255,
            30,
            27,
            false,
            false,
            false
        )
        tVICE.addBlip(a.sellLocation.x, a.sellLocation.y, a.sellLocation.z, 618, 46, "Sell Stolen Bank Items")
        VICE.createArea(
            "sellBankHeistItems",
            a.sellLocation,
            2.0,
            5.0,
            onEnterSelling,
            onExitSelling,
            function()
            end,
            {}
        )
    end
)
]]