local a = 0
local b = 0
local c = 0
local d = false
local e = 1
local f = 1
local g = 1
local h = false
local i = false
local j = 0.1
local k = 0
local l = false
local m
local n
local o
local p
local q = "None"
local r = 0
local s = false
local t = 0
local u = {
    [1] = "GOLF_SWING_GRASS_LIGHT_MASTER",
    [2] = "GOLF_SWING_GRASS_PERFECT_MASTER",
    [3] = "GOLF_SWING_GRASS_MASTER",
    [4] = "GOLF_SWING_TEE_LIGHT_MASTER",
    [5] = "GOLF_SWING_TEE_PERFECT_MASTER",
    [6] = "GOLF_SWING_TEE_MASTER",
    [7] = "GOLF_SWING_TEE_IRON_LIGHT_MASTER",
    [8] = "GOLF_SWING_TEE_IRON_PERFECT_MASTER",
    [9] = "GOLF_SWING_TEE_IRON_MASTER",
    [10] = "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER",
    [11] = "GOLF_SWING_FAIRWAY_IRON_PERFECT_MASTER",
    [12] = "GOLF_SWING_FAIRWAY_IRON_MASTER",
    [13] = "GOLF_SWING_ROUGH_IRON_LIGHT_MASTER",
    [14] = "GOLF_SWING_ROUGH_IRON_PERFECT_MASTER",
    [15] = "GOLF_SWING_ROUGH_IRON_MASTER",
    [16] = "GOLF_SWING_SAND_IRON_LIGHT_MASTER",
    [17] = "GOLF_SWING_SAND_IRON_PERFECT_MASTER",
    [18] = "GOLF_SWING_SAND_IRON_MASTER",
    [19] = "GOLF_SWING_CHIP_LIGHT_MASTER",
    [20] = "GOLF_SWING_CHIP_PERFECT_MASTER",
    [21] = "GOLF_SWING_CHIP_MASTER",
    [22] = "GOLF_SWING_CHIP_GRASS_LIGHT_MASTER",
    [23] = "GOLF_SWING_CHIP_GRASS_MASTER",
    [24] = "GOLF_SWING_CHIP_SAND_LIGHT_MASTER",
    [25] = "GOLF_SWING_CHIP_SAND_PERFECT_MASTER",
    [26] = "GOLF_SWING_CHIP_SAND_MASTER",
    [27] = "GOLF_SWING_PUTT_MASTER",
    [28] = "GOLF_FORWARD_SWING_HARD_MASTER",
    [29] = "GOLF_BACK_SWING_HARD_MASTER"
}
local v = {
    ["ironshufflehigh"] = "iron_shuffle_high",
    ["ironshufflelow"] = "iron_shuffle_low",
    ["ironshuffle"] = "iron_shuffle",
    ["ironswinghigh"] = "iron_swing_action_high",
    ["ironswinglow"] = "iron_swing_action_low",
    ["ironidlehigh"] = "iron_swing_idle_high",
    ["ironidlelow"] = "iron_swing_idle_low",
    ["ironidle"] = "iron_shuffle",
    ["ironswingintro"] = "iron_swing_intro_high"
}
local w = {
    ["puttshufflelow"] = "iron_shuffle_low",
    ["puttshuffle"] = "iron_shuffle",
    ["puttswinglow"] = "putt_action_low",
    ["puttidle"] = "putt_idle_low",
    ["puttintro"] = "putt_intro_low"
}
local x = {
    ["golfbag01"] = {
        ["model"] = "prop_golf_bag_01",
        ["bone"] = 24816,
        ["x"] = 0.12,
        ["y"] = -0.3,
        ["z"] = 0.0,
        ["xR"] = -75.0,
        ["yR"] = 190.0,
        ["zR"] = 92.0
    },
    ["golfputter01"] = {
        ["model"] = "prop_golf_putter_01",
        ["bone"] = 57005,
        ["x"] = 0.0,
        ["y"] = -0.05,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfiron01"] = {
        ["model"] = "prop_golf_iron_01",
        ["bone"] = 57005,
        ["x"] = 0.125,
        ["y"] = 0.04,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfiron03"] = {
        ["model"] = "prop_golf_iron_01",
        ["bone"] = 57005,
        ["x"] = 0.126,
        ["y"] = 0.041,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfiron05"] = {
        ["model"] = "prop_golf_iron_01",
        ["bone"] = 57005,
        ["x"] = 0.127,
        ["y"] = 0.042,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfiron07"] = {
        ["model"] = "prop_golf_iron_01",
        ["bone"] = 57005,
        ["x"] = 0.128,
        ["y"] = 0.043,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfwedge01"] = {
        ["model"] = "prop_golf_pitcher_01",
        ["bone"] = 57005,
        ["x"] = 0.17,
        ["y"] = 0.04,
        ["z"] = 0.0,
        ["xR"] = 90.0,
        ["yR"] = -118.0,
        ["zR"] = 44.0
    },
    ["golfdriver01"] = {
        ["model"] = "prop_golf_driver",
        ["bone"] = 57005,
        ["x"] = 0.14,
        ["y"] = 0.00,
        ["z"] = 0.0,
        ["xR"] = 160.0,
        ["yR"] = -60.0,
        ["zR"] = 10.0
    }
}
local y = {
    [1] = {
        ["par"] = 5,
        startHole = vector3(-1371.3370361328, 173.09497070313, 57.013027191162),
        endHole = vector3(-1114.2274169922, 220.8424987793, 63.8947830200)
    },
    [2] = {
        ["par"] = 4,
        startHole = vector3(-1107.1888427734, 156.581298828, 62.03958129882),
        endHole = vector3(-1322.0944824219, 158.8779296875, 56.80027008056)
    },
    [3] = {
        ["par"] = 3,
        startHole = vector3(-1312.1020507813, 125.8329391479, 56.4341888427),
        endHole = vector3(-1237.347412109, 112.9838562011, 56.20140075683)
    },
    [4] = {
        ["par"] = 4,
        startHole = vector3(-1216.913208007, 106.9870910644, 57.03926086425),
        endHole = vector3(-1096.6276855469, 7.780227184295, 49.73574447631)
    },
    [5] = {
        ["par"] = 4,
        startHole = vector3(-1097.859619140, 66.41466522216, 52.92545700073),
        endHole = vector3(-957.4982910156, -90.37551879882, 39.2753639221)
    },
    [6] = {
        ["par"] = 3,
        startHole = vector3(-987.7417602539, -105.0764007568, 39.585887908936),
        endHole = vector3(-1103.506958007, -115.2364349365, 40.55868911743)
    },
    [7] = {
        ["par"] = 4,
        startHole = vector3(-1117.0194091797, -103.8586044311, 40.8405838012),
        endHole = vector3(-1290.536499023, 2.7952194213867, 49.34057998657)
    },
    [8] = {
        ["par"] = 5,
        startHole = vector3(-1272.251831054, 38.04283142089, 48.72544860839),
        endHole = vector3(-1034.80187988, -83.16706085205, 43.0353431701)
    },
    [9] = {
        ["par"] = 4,
        startHole = vector3(-1138.319580078, -0.1342505216598, 47.98218917846),
        endHole = vector3(-1294.685913085, 83.5762557983, 53.92817306518)
    }
}
local function z(A, B, C)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(A)
    EndTextCommandDisplayHelp(0, false, B, C)
end
local function D()
    ExecuteCommand("hideui")
    local E = GetRenderingCam()
    local F = VICE.getPlayerPed()
    local G = VICE.getPlayerCoords()
    SetFocusPosAndVel(-1364.8052978516, 166.98794555664, 58.013092041016, 0.0, 0.0, 0.0)
    local H =
        CreateCameraWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        -1364.8052978516,
        166.98794555664,
        64.013092041016,
        0.0,
        0.0,
        0.0,
        65.0,
        false,
        2
    )
    PointCamAtCoord(H, -1371.0968017578, 173.33917236328, 58.013034820557)
    SetCamActive(H, true)
    RenderScriptCams(true, true, 0, true, false)
    local I =
        CreateCameraWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        -1367.5961914063,
        176.40940856934,
        64.013084411621,
        0.0,
        0.0,
        0.0,
        65.0,
        false,
        2
    )
    PointCamAtCoord(I, -1371.0968017578, 173.33917236328, 58.013034820557)
    SetCamActiveWithInterp(I, H, 14000, 5, 5)
    z("To play golf, you must first go to the location of where your ball is (white blip)", true, 8000)
    Wait(7000)
    z("Next, you must swing the ball towards the hole (red golf marker on your map)", false, 8000)
    Wait(7000)
    PointCamAtCoord(H, -1114.1766357422, 220.724609375, 64.893432617188)
    PointCamAtCoord(I, -1114.1766357422, 220.724609375, 64.893432617188)
    SetCamCoord(H, -1112.6385498047, 211.25141906738, 64.905075073242)
    SetCamCoord(I, -1108.9538574219, 223.51953125, 64.759399414063)
    SetCamActiveWithInterp(I, H, 14000, 5, 5)
    z("Your aim is to get the ball as close to the hole as possible to finish that hole.", false, 8000)
    Wait(7000)
    z(
        "Once complete, you will move on to the next hole where a ball is already placed for you. Good luck!",
        false,
        8000
    )
    Wait(7000)
    DestroyCam(H, false)
    DestroyCam(I, false)
    RenderScriptCams(false, true, 3000, true, false)
    ClearFocus()
    FreezeEntityPosition(F, false)
    SetEntityCoords(F, G)
    ExecuteCommand("showui")
end
local function J()
    DeleteEntity(attachedProp)
    attachedProp = 0
end
local function K(L)
    if L then
        notify("You have successfully completed all holes in " .. tostring(c) .. " strokes!")
    end
    DeleteEntity(r)
    J()
    DeleteObject(k)
    tVICE.removeBlip(m)
    tVICE.removeBlip(n)
    tVICE.removeBlip(p)
    tVICE.removeMarker(o)
    Citizen.Wait(5000)
    a = 0
    b = 0
    d = false
    e = 1
    f = 1
    g = 1
    h = false
    i = false
    r = 0
end
Citizen.CreateThread(
    function()
        Citizen.Wait(5000)
        local M = vector3(-1350.1905517578, 134.2918548584, 55.256828308105)
        enter_golfMarker = function()
            s = true
        end
        exit_golfMarker = function()
            s = false
        end
        ontick_golfMarker = function()
            if d then
                z("Press ~INPUT_CONTEXT~ to end golf", false, -1)
            else
                z("Press ~INPUT_CONTEXT~ to start golf (£5,000)", false, -1)
            end
            DrawMarker(
                27,
                M.x,
                M.y,
                M.z,
                0,
                0,
                0,
                0,
                0,
                0,
                1.5,
                1.5,
                10.3,
                0,
                519,
                0,
                105,
                false,
                false,
                2,
                false,
                nil,
                nil,
                false
            )
            if IsControlJustPressed(1, 38) then
                if d then
                    K(false)
                else
                    TriggerServerEvent("VICE:takeGolfMoney")
                end
            end
        end
        VICE.createArea("golf_course", M, 15, 6, enter_golfMarker, exit_golfMarker, ontick_golfMarker, {})
    end
)
local function N(O, P, Q, R, S, T, U, V)
    J()
    attachModel = O
    boneNumber = P
    SetCurrentPedWeapon(VICE.getPlayerPed(), 0xA2719263, true)
    local W = GetPedBoneIndex(VICE.getPlayerPed(), P)
    VICE.loadModel(attachModel)
    attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, true, true, false)
    AttachEntityToEntity(attachedProp, VICE.getPlayerPed(), W, Q, R, S, T, U, V, true, true, false, false, 2, true)
end
local function X(Y)
    Citizen.CreateThreadNow(
        function()
            N(x[Y]["model"], x[Y]["bone"], x[Y]["x"], x[Y]["y"], x[Y]["z"], x[Y]["xR"], x[Y]["yR"], x[Y]["zR"])
        end
    )
end
RegisterNetEvent(
    "VICE:startGolf",
    function()
        if d then
            return
        end
        r = VICE.spawnVehicle("caddy", -1332.7823486328, 128.18229675293, 56.032329559326, 180, true, true, false)
        local Z = AddBlipForEntity(r)
        SetBlipSprite(Z, 326)
        SetBlipColour(Z, 5)
        d = true
        SetCurrentPedWeapon(VICE.getPlayerPed(), 0xA2719263, false)
        X("golfbag01")
        if GetResourceKvpInt("vice_golf_done_cutscene") == 0 then
            D()
            SetResourceKvpInt("vice_golf_done_cutscene", 1)
        end
    end
)
local function _()
    if d and a ~= 0 and not i then
        DrawRect(0.5, 0.93, 0.15, 0.04, 0, 0, 0, 140)
        local A =
            "~s~" ..
            b ..
                "~r~ | ~s~" ..
                    c .. "~r~ | ~s~" .. q .. "~r~ | ~s~" .. math.ceil(#(VICE.getPlayerCoords() - y[a].endHole)) .. " m"
        VICE.DrawText(0.448, 0.91, A, 0.6, 4)
    end
end
VICE.createThreadOnTick(_)
local function a0(Q, R, S)
    DeleteObject(k)
    k = CreateObject("prop_golf_ball", Q, R, S, true, true, false)
    SetEntityRecordsCollisions(k, true)
    tVICE.removeBlip(m)
    m = tVICE.addBlip(Q, R, S, 161, 0, "Golf Ball", 0.6)
    SetBlipAsShortRange(m, false)
    SetBlipDisplay(m, 2)
    SetBlipAsFriendly(m, true)
    SetEntityCollision(k, true, true)
    SetEntityHasGravity(k, true)
    FreezeEntityPosition(k, true)
    local a1 = GetEntityHeading(VICE.getPlayerPed())
    SetEntityHeading(k, a1)
end
local function a2(a3)
    local a1 = GetEntityHeading(k)
    if a1 >= 360.0 then
        a1 = 0.0
    end
    if a3 then
        SetEntityHeading(k, a1 - 0.7)
    else
        SetEntityHeading(k, a1 + 0.7)
    end
end
local function a4()
    local a5 = 20000
    while a5 > 0 do
        Citizen.Wait(5)
        local a6 = GetEntityCoords(k)
        SetCamCoord(ballCamera, a6.x, a6.y - 10, a6.z + 9)
        PointCamAtEntity(ballCamera, k, 0.0, 0.0, 0.0, true)
        a5 = a5 - 1
    end
end
local function a7()
    ballCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamFov(ballCamera, 90.0)
    RenderScriptCams(true, true, 3, 1, 0)
    Citizen.CreateThreadNow(a4)
end
local function a8()
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(ballCamera, false)
end
local function a9()
    i = false
    b = b + 1
    local aa = GetEntityCoords(k)
    local ab = #(aa - y[a].endHole)
    if ab < 1.5 then
        c = b + c
        b = 0
        e = 1
        t = GetGameTimer()
        local ac = true
        Citizen.CreateThread(
            function()
                Wait(3000)
                ac = false
            end
        )
        while ac do
            drawNativeText("You got the ball within range!")
            Citizen.Wait(0)
        end
    end
    if b > 12 then
        c = b + c
        b = 0
        e = 1
        local ac = true
        Citizen.CreateThread(
            function()
                Wait(3000)
                ac = false
            end
        )
        while ac do
            drawNativeText("You took too many shots..")
            Citizen.Wait(0)
        end
    end
    X("golfbag01")
end
local function ad()
    if g == 3 then
        X("golfdriver01")
        q = "Wood"
    elseif g == 2 then
        X("golfwedge01")
        q = "Wedge"
    elseif g == 1 then
        X("golfiron01")
        q = "1 Iron"
    elseif g == 4 then
        X("golfiron03")
        q = "3 Iron"
    elseif g == 5 then
        X("golfiron05")
        q = "5 Iron"
    elseif g == 6 then
        X("golfiron07")
        q = "7 Iron"
    else
        X("golfputter01")
        q = "Putter"
    end
end
local function ae(af)
    VICE.loadAnimDict("mini@golf")
    if not IsEntityPlayingAnim(PlayerPedId(), "mini@golf", af, 3) then
        length = GetAnimDuration("mini@golf", af)
        TaskPlayAnim(VICE.getPlayerPed(), "mini@golf", af, 1.0, -1.0, length, 0, 1, false, false, false)
        Citizen.Wait(length)
    end
end
local function ag()
    if g == 0 then
        playAnim = w["puttidle"]
    else
        if IsControlPressed(1, 38) then
            playAnim = v["ironidlehigh"]
        else
            playAnim = v["ironidle"]
        end
    end
    ae(playAnim)
    Citizen.Wait(1200)
end
local function ah()
    h = true
    while h do
        Citizen.Wait(0)
        ag()
    end
end
local function ai(dir)
    local Q = 0.0
    local R = 0.0
    local dir = dir
    if dir >= 0.0 and dir <= 90.0 then
        local aj = dir / 9.2 / 10
        Q = -1.0 + aj
        R = 0.0 - aj
    end
    if dir > 90.0 and dir <= 180.0 then
        dirp = dir - 90.0
        local aj = dirp / 9.2 / 10
        Q = 0.0 + aj
        R = -1.0 + aj
    end
    if dir > 180.0 and dir <= 270.0 then
        dirp = dir - 180.0
        local aj = dirp / 9.2 / 10
        Q = 1.0 - aj
        R = 0.0 + aj
    end
    if dir > 270.0 and dir <= 360.0 then
        dirp = dir - 270.0
        local aj = dirp / 9.2 / 10
        Q = 0.0 - aj
        R = 1.0 - aj
    end
    return Q, R
end
local function ak()
    if g ~= 0 then
        a7()
    end
    VICE.loadPtfx("scr_minigamegolf")
    UseParticleFxAsset("scr_minigamegolf")
    StartParticleFxLoopedOnEntity("scr_golf_ball_trail", k, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
    local al = false
    dir = GetEntityHeading(k)
    local Q, R = ai(dir)
    FreezeEntityPosition(k, false)
    local am = j / 3
    if g == 0 then
        j = j / 3
        local an = 5.0
        while an < j do
            SetEntityVelocity(k, Q * an, R * an, -0.1)
            Citizen.Wait(20)
            an = an + 0.3
        end
        j = j
        while j > 0 do
            SetEntityVelocity(k, Q * j, R * j, -0.1)
            Citizen.Wait(20)
            j = j - 0.3
        end
    elseif g == 1 then
        j = j * 1.85
        airpower = j / 2.6
        al = true
        am = am / 4
    elseif g == 3 then
        j = j * 2.0
        airpower = j / 2.6
        al = true
        am = am / 2
    elseif g == 2 then
        j = j * 1.5
        airpower = j / 2.1
        al = true
        am = am / 4.5
    elseif g == 4 then
        j = j * 1.8
        airpower = j / 2.55
        al = true
        am = am / 5
    elseif g == 5 then
        j = j * 1.75
        airpower = j / 2.5
        al = true
        am = am / 5.5
    elseif g == 6 then
        j = j * 1.7
        airpower = j / 2.45
        al = true
        am = am / 6.0
    end
    while j > 0 do
        SetEntityVelocity(k, Q * j, R * j, airpower)
        Citizen.Wait(0)
        j = j - 1
        airpower = airpower - 1
    end
    if al then
        while am > 0 do
            SetEntityVelocity(k, Q * am, R * am, 0.0)
            Citizen.Wait(5)
            am = am - 1
        end
    end
    Citizen.Wait(2000)
    SetEntityVelocity(k, 0.0, 0.0, 0.0)
    if g ~= 0 then
        a8()
    end
    local a6 = GetEntityCoords(k)
    a0(a6.x, a6.y, a6.z)
    FreezeEntityPosition(k, true)
end
local function ao()
    j = 0.1
    local ab = #(GetEntityCoords(k) - y[a].endHole)
    if ab >= 200.0 then
        g = 3
    elseif ab >= 150.0 and ab < 200.0 then
        g = 1
    elseif ab >= 120.0 and ab < 250.0 then
        g = 4
    elseif ab >= 90.0 and ab < 120.0 then
        g = 5
    elseif ab >= 50.0 and ab < 90.0 then
        g = 6
    elseif ab >= 20.0 and ab < 50.0 then
        g = 2
    else
        g = 0
    end
    ad()
    RequestScriptAudioBank("GOLF_I", false)
    while f == 2 do
        Citizen.Wait(0)
        if IsControlPressed(1, 38) then
            addition = 0.5
            if j > 25 then
                addition = addition + 0.1
            end
            if j > 50 then
                addition = addition + 0.2
            end
            if j > 75 then
                addition = addition + 0.3
            end
            j = j + addition
            if j > 100.0 then
                j = 1.0
            end
        end
        local ap = j * 2 / 1000
        if j > 55 then
            local aq = j / 100
            DrawRect(0.5, 0.93, ap, 0.02, math.floor(aq * 255), math.floor((1.0 - aq) * 255), 0, 210)
        else
            DrawRect(0.5, 0.93, ap, 0.02, 22, 235, 22, 210)
        end
        local ar = GetOffsetFromEntityInWorldCoords(k, j - j * 2, 0.0, 0.0)
        drawNativeText("Press E to swing, A-D to rotate, Y to swap club.")
        local as = GetEntityCoords(k)
        DrawLine(as.x, as.y, as.z, y[a].endHole.x, y[a].endHole.y, y[a].endHole.z, 222, 111, 111, 0.2)
        if IsControlJustPressed(1, 246) then
            local at = g + 1
            if at > 6 then
                at = 0
            end
            g = at
            ad()
        end
        if IsControlPressed(1, 34) then
            a2(true)
        end
        if IsControlPressed(1, 9) then
            a2(false)
        end
        if g == 0 then
            AttachEntityToEntity(
                VICE.getPlayerPed(),
                k,
                20,
                0.14,
                -0.62,
                0.99,
                0.0,
                0.0,
                0.0,
                false,
                false,
                false,
                false,
                1,
                true
            )
        elseif g == 3 then
            AttachEntityToEntity(
                VICE.getPlayerPed(),
                k,
                20,
                0.3,
                -0.92,
                0.99,
                0.0,
                0.0,
                0.0,
                false,
                false,
                false,
                false,
                1,
                true
            )
        elseif g == 2 then
            AttachEntityToEntity(
                VICE.getPlayerPed(),
                k,
                20,
                0.38,
                -0.79,
                0.94,
                0.0,
                0.0,
                0.0,
                false,
                false,
                false,
                false,
                1,
                true
            )
        else
            AttachEntityToEntity(
                VICE.getPlayerPed(),
                k,
                20,
                0.4,
                -0.83,
                0.94,
                0.0,
                0.0,
                0.0,
                false,
                false,
                false,
                false,
                1,
                true
            )
        end
        if IsControlJustReleased(1, 38) then
            if g == 0 then
                playAnim = w["puttswinglow"]
            else
                playAnim = v["ironswinghigh"]
                ae(playAnim)
                playAnim = v["ironswinglow"]
                ae(playAnim)
                playAnim = v["ironswinglow"]
            end
            f = 1
            h = false
            DetachEntity(VICE.getPlayerPed(), true, false)
        else
            if not h then
                Citizen.CreateThreadNow(ah)
            end
        end
    end
    PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER", VICE.getPlayerPed(), 0, nil, 0)
    ae(playAnim)
    ak()
    Citizen.Wait(1000)
    a9()
end
Citizen.CreateThread(
    function()
        while true do
            if d then
                if e == 1 then
                    a = a + 1
                    if a == 10 then
                        K(true)
                    else
                        tVICE.removeBlip(p)
                        tVICE.removeBlip(n)
                        tVICE.removeMarker(o)
                        p =
                            tVICE.addBlip(
                            y[a].startHole.x,
                            y[a].startHole.y,
                            y[a].startHole.z,
                            161,
                            1,
                            "Swing Ball",
                            1.0
                        )
                        SetBlipAsShortRange(p, false)
                        SetBlipDisplay(p, 2)
                        n = tVICE.addBlip(y[a].endHole.x, y[a].endHole.y, y[a].endHole.z, 109, 1, "Hole", 1.0)
                        SetBlipAsShortRange(n, false)
                        SetBlipDisplay(n, 2)
                        o =
                            tVICE.addMarker(
                            y[a].endHole.x,
                            y[a].endHole.y,
                            y[a].endHole.z + 1,
                            0.5,
                            0.5,
                            0.5,
                            10,
                            255,
                            81,
                            255,
                            250,
                            0,
                            false,
                            true,
                            false,
                            nil,
                            nil,
                            0.0,
                            0.0,
                            0.0
                        )
                        e = 0
                        f = 1
                        a0(y[a].startHole.x, y[a].startHole.y, y[a].startHole.z)
                    end
                else
                    if f == 2 and not i and not l then
                        i = true
                        Citizen.CreateThread(
                            function()
                                ao()
                            end
                        )
                    elseif f == 1 and not i and not l then
                        if VICE.getPlayerVehicle() == 0 then
                            local aa = GetEntityCoords(k)
                            if #(VICE.getPlayerCoords() - aa) > 50 and not s then
                                if GetGameTimer() - t < 15000 then
                                    z("Move to the next start area.", false, -1)
                                else
                                    z(
                                        "Move to your ball or press ~g~~INPUT_CONTEXT~~s~ to ball drop if you are stuck.",
                                        false,
                                        -1
                                    )
                                    if IsControlJustReleased(1, 38) then
                                        l = true
                                        while l do
                                            if
                                                (#(VICE.getPlayerCoords() - aa) < 100.0 or
                                                    VICE.getPlayerCoords().z - aa.z > 100.0) and
                                                    #(VICE.getPlayerCoords() - y[a].endHole) > 50.0
                                             then
                                                z("Press ~g~E~s~ to drop here.", false, -1)
                                                if IsControlJustReleased(1, 38) then
                                                    l = false
                                                    local a6 = VICE.getPlayerCoords()
                                                    a0(a6.x, a6.y, a6.z - 1)
                                                    b = b + 1
                                                end
                                            else
                                                z(
                                                    "Press ~g~E~s~ to drop - ~r~ too far from ball or too close to hole.",
                                                    false,
                                                    -1
                                                )
                                                SetTimeout(
                                                    5000,
                                                    function()
                                                        l = false
                                                    end
                                                )
                                            end
                                            Wait(0)
                                        end
                                    end
                                end
                            elseif #(VICE.getPlayerCoords() - aa) < 2 and not l then
                                f = 2
                                e = 0
                            end
                        end
                    end
                end
            end
            Wait(0)
        end
    end
)
AddEventHandler(
    "VICE:onClientSpawn",
    function(au, av)
        if av then
            tVICE.addBlip(-1350.1905517578, 134.2918548584, 55.556828308105, 109, 68, "Golf Course", 1.0)
        end
    end
)
