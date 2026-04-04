RMenu.Add(
    "nhs",
    "main",
    RageUI.CreateMenu("NHS", "Status: ~b~Available", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RMenu.Add(
    "nhs",
    "equipment",
    RageUI.CreateSubMenu(
        RMenu:Get("nhs", "main"),
        "Equipment",
        "Status: ~b~Available",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "nhs",
    "observations",
    RageUI.CreateSubMenu(
        RMenu:Get("nhs", "main"),
        "Observations",
        "Status: ~b~Available",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "nhs",
    "lifepak",
    RageUI.CreateSubMenu(
        RMenu:Get("nhs", "main"),
        "Observations",
        "Status: ~b~Available",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "nhs",
    "objects",
    RageUI.CreateSubMenu(
        RMenu:Get("nhs", "main"),
        "Objects",
        "Status: ~b~Available",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RegisterKeyMapping("nhs", "NHS Menu", "keyboard", "U")
TriggerEvent("chat:addSuggestion", "/nhs", "Toggle the NHS Menu")
RegisterNetEvent(
    "VICE:beginRevive",
    function(a, b, c, d)
        print("nuser_id", b)
        beginObs(a, c, b, true, d)
        TriggerEvent(
            "VICE:showNotification",
            {
                text = "Your LIFEPAK 15 is now connected to " .. d,
                height = "200px",
                width = "auto",
                colour = "#FFF",
                background = "#32CD32",
                pos = "bottom-right",
                icon = "success"
            },
            5000
        )
        TriggerEvent(
            "VICE:showNotification",
            {
                text = "Use your specialist medical equipment to treat this patient",
                height = "200px",
                width = "auto",
                colour = "#FFF",
                background = "#32CD32",
                pos = "bottom-right",
                icon = "success"
            },
            5000
        )
        RageUI.Visible(RMenu:Get("nhs", "main"), true)
    end
)
RegisterNetEvent(
    "VICE:attachLifepak",
    function(a, b, c, d)
        beginObs(a, c, b, false, d)
    end
)
local e = {
    active = false,
    user_id = 0,
    entity = 0,
    perm_id = 0,
    name = "",
    dead = false,
    readyToRevive = false,
    coma = false,
    heartRate = 80,
    bloodPressure1 = 120,
    bloodPressure2 = 60,
    temperature = 36.5,
    spo2 = 95
}
local f = {active = false, onGround = false, carrying = false, handle = 0, hash = 0, soundCount = 0}
RageUI.CreateWhile(
    1.0,
    true,
    function()
        if RageUI.Visible(RMenu:Get("nhs", "main")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Button(
                        "Observations",
                        "Carry out vital observations",
                        {RightLabel = "→→→"},
                        true,
                        function(g, h, i)
                        end,
                        RMenu:Get("nhs", "observations")
                    )
                    RageUI.Button(
                        "Medical Equipment",
                        "Carry your LIFEPAK 15",
                        {RightLabel = "→→→"},
                        true,
                        function(g, h, i)
                        end,
                        RMenu:Get("nhs", "equipment")
                    )
                    RageUI.Button(
                        "LIFEPAK Functions",
                        "Use your LIFEPAK 15",
                        {RightLabel = "→→→"},
                        true,
                        function(g, h, i)
                        end,
                        RMenu:Get("nhs", "lifepak")
                    )
                    RageUI.Button(
                        "Objects",
                        "Spawn NHS Objects",
                        {RightLabel = "→→→"},
                        true,
                        function(g, h, i)
                        end,
                        RMenu:Get("nhs", "objects")
                    )
                end
            )
        end
        if RageUI.Visible(RMenu:Get("nhs", "observations")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    if e.active then
                        RageUI.ButtonWithStyle(
                            "Heart Rate",
                            nil,
                            {RightLabel = tostring(e.heartRate .. " bpm")},
                            true,
                            function(g, h, i)
                            end
                        )
                        RageUI.ButtonWithStyle(
                            "Blood Pressure",
                            nil,
                            {RightLabel = e.bloodPressure1 .. " / " .. e.bloodPressure2 .. " mmHg"},
                            true,
                            function(g, h, i)
                            end
                        )
                        RageUI.ButtonWithStyle(
                            "Temperature",
                            nil,
                            {RightLabel = math.floor(e.temperature) .. " °C"},
                            true,
                            function(g, h, i)
                            end
                        )
                        RageUI.ButtonWithStyle(
                            "SpO2",
                            nil,
                            {RightLabel = e.spo2 .. "%"},
                            true,
                            function(g, h, i)
                            end
                        )
                        if not e.dead then
                            local j = math.random(1, 650)
                            if j < 2 then
                                changeUpObs()
                            end
                        end
                        if e.readyToRevive then
                            RageUI.Button(
                                "Shock Patient",
                                nil,
                                {RightLabel = ""},
                                true,
                                function(g, h, i)
                                    if i then
                                        TriggerServerEvent("VICE:finishRevive", e.perm_id)
                                        e.readyToRevive = false
                                        TriggerServerEvent("VICE:playNhsSound", "shockAdvisedCharging")
                                    end
                                end
                            )
                        else
                            RageUI.Button(
                                "Detach from patient",
                                nil,
                                {RightLabel = ""},
                                true,
                                function(g, h, i)
                                    if i then
                                        e.active = false
                                        RMenu:Get("nhs", "observations"):SetSubtitle("Status: ~b~Available")
                                        RMenu:Get("nhs", "lifepak"):SetSubtitle("Status: ~b~Available")
                                        TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
                                    end
                                end
                            )
                        end
                    else
                        RageUI.Button(
                            "Connect to patient",
                            nil,
                            {RightLabel = ""},
                            true,
                            function(g, h, i)
                                if i then
                                    connectObsToPatient()
                                end
                            end
                        )
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("nhs", "lifepak")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    if not e.active then
                        RageUI.Button(
                            "Connect to patient",
                            nil,
                            {RightLabel = ""},
                            true,
                            function(g, h, i)
                                if i then
                                    connectObsToPatient()
                                end
                            end
                        )
                    else
                        if e.readyToRevive then
                            RageUI.Button(
                                "Shock Patient",
                                nil,
                                {RightLabel = ""},
                                true,
                                function(g, h, i)
                                    if i then
                                        TriggerServerEvent("VICE:finishRevive", e.perm_id)
                                        e.readyToRevive = false
                                        TriggerServerEvent("VICE:playNhsSound", "carryOutShock")
                                    end
                                end
                            )
                        end
                    end
                    RageUI.Button(
                        "Enable Metronome",
                        nil,
                        {RightLabel = "100-120bpm"},
                        true,
                        function(g, h, i)
                            if i then
                                TriggerServerEvent("VICE:playNhsSound", "metronome")
                            end
                        end
                    )
                    if f.soundCount < 15 then
                        RageUI.Button(
                            "Press LIFEPAK Button",
                            nil,
                            {RightLabel = ""},
                            true,
                            function(g, h, i)
                                if i then
                                    TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
                                    f.soundCount = f.soundCount + 1
                                end
                            end
                        )
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("nhs", "equipment")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    if not f.active then
                        RageUI.Button(
                            "Carry",
                            nil,
                            {RightLabel = ""},
                            true,
                            function(g, h, i)
                                if i then
                                    carryLifePak()
                                end
                            end
                        )
                    else
                        if not f.onGround then
                            RageUI.Button(
                                "Place on ground",
                                nil,
                                {RightLabel = ""},
                                true,
                                function(g, h, i)
                                    if i then
                                        placeLifepakOnGround()
                                    end
                                end
                            )
                        else
                            RageUI.Button(
                                "Carry",
                                nil,
                                {RightLabel = ""},
                                true,
                                function(g, h, i)
                                    if i then
                                        reCarryLifepak()
                                    end
                                end
                            )
                        end
                        RageUI.Button(
                            "Place away",
                            nil,
                            {RightLabel = ""},
                            true,
                            function(g, h, i)
                                if i then
                                    placeLifepakAway()
                                end
                            end
                        )
                    end
                end
            )
        end
        if RageUI.Visible(RMenu:Get("nhs", "objects")) then
            RageUI.DrawContent(
                {header = true, glare = false, instructionalButton = false},
                function()
                    RageUI.Button(
                        "Spawn Stretcher",
                        nil,
                        {RightLabel = ""},
                        true,
                        function(g, h, i)
                            if i then
                                ExecuteCommand("stretcher")
                            end
                        end
                    )
                    RageUI.Button(
                        "Delete Stretcher",
                        nil,
                        {RightLabel = ""},
                        true,
                        function(g, h, i)
                            if i then
                                ExecuteCommand("removestretcher")
                            end
                        end
                    )
                    RageUI.Button(
                        "Spawn Wheelchair",
                        nil,
                        {RightLabel = ""},
                        true,
                        function(g, h, i)
                            if i then
                                ExecuteCommand("wheelchair")
                            end
                        end
                    )
                    RageUI.Button(
                        "Delete Wheelchair",
                        nil,
                        {RightLabel = ""},
                        true,
                        function(g, h, i)
                            if i then
                                ExecuteCommand("removewheelchair")
                            end
                        end
                    )
                end
            )
        end
    end
)
function carryLifePak()
    local k = VICE.getPlayerPed()
    f.active = true
    local l = VICE.loadModel("prop_lifepak")
    f.handle = CreateObject(l, 0, 0, 0, true, true, true)
    f.carrying = true
    f.onGround = false
    while not DoesEntityExist(f.handle) do
        Wait(0)
    end
    SetModelAsNoLongerNeeded(l)
    AttachEntityToEntity(
        f.handle,
        k,
        GetPedBoneIndex(k, 57005),
        0.15,
        0,
        0,
        -85.0,
        0,
        90.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
end
function placeLifepakOnGround()
    DetachEntity(f.handle, true, true)
    PlaceObjectOnGroundProperly(f.handle)
    f.carrying = false
    f.onGround = true
end
function reCarryLifepak()
    local k = VICE.getPlayerPed()
    AttachEntityToEntity(
        f.handle,
        k,
        GetPedBoneIndex(k, 57005),
        0.15,
        0,
        0,
        -85.0,
        0,
        90.0,
        true,
        true,
        false,
        true,
        1,
        true
    )
    f.onGround = false
    f.carrying = true
end
function placeLifepakAway()
    if f.carrying then
        DetachEntity(f.handle, true, true)
    end
    f.active = false
    f.onGround = false
    f.carrying = false
    DeleteEntity(f.handle)
    SetModelAsNoLongerNeeded()
end
function changeUpObs()
    Citizen.CreateThread(
        function()
            TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
            if not e.dead then
                local m = math.random(1, 2)
                local n = math.random(1, 5)
                if n == 3 then
                    Wait(3000)
                    TriggerServerEvent("VICE:playNhsSound", "checkPatientAlarm")
                end
                if m == 1 and not e.coma then
                    e.heartRate = e.heartRate + math.random(1, 4)
                    e.temperature = e.temperature + math.random(1, 2)
                    e.spo2 = e.spo2 + math.random(1, 5)
                    if e.spo2 <= 100 then
                        e.spo2 = math.random(90, 95)
                    end
                else
                    e.heartRate = e.heartRate - math.random(1, 4)
                    e.temperature = e.temperature - math.random(1, 2)
                    e.spo2 = e.spo2 - math.random(1, 5)
                    if e.spo2 <= 10 then
                        e.spo2 = math.random(12, 14)
                    end
                end
            else
                local o = math.random(1, 4)
                if o == 1 then
                    e.temperature = e.temperature - math.random(1, 2)
                    if e.temperature < 5 then
                        e.temperature = math.random(3, 6)
                    end
                end
            end
        end
    )
end
local function p(q, r, s)
    AddTextEntry("FMMC_KEY_TIP1", q)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", r, "", "", "", s)
    blockinput = true
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end
    if UpdateOnscreenKeyboard() ~= 2 then
        local t = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return t
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end
function beginObs(a, u, v, w, d)
    TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
    Wait(3000)
    TriggerServerEvent("VICE:playNhsSound", "analysingHeartRythm")
    e = {}
    RMenu:Get("nhs", "observations"):SetSubtitle("Patient: ~w~" .. d)
    RMenu:Get("nhs", "lifepak"):SetSubtitle("Patient: ~w~" .. d)
    e.active = true
    e.user_id = u
    e.perm_id = v
    e.name = d
    e.readyToRevive = w
    e.coma = a
    e.dead = false
    e.bloodPressure1 = math.random(20, 199)
    e.bloodPressure2 = math.floor(e.bloodPressure1 - e.bloodPressure1 / 2.9)
    if e.bloodPressure2 > e.bloodPressure1 then
        e.bloodPressure2 = e.bloodPressure2 / 2
    end
    e.heartRate = math.random(52, 95)
    e.temperature = 36.7 - 1 / math.random(2, 3)
    e.spo2 = math.random(95, 100)
    if e.coma then
        e.heartRate = math.random(1, 36)
        e.temperature = e.temperature - math.random(1, 3)
        e.spo2 = math.random(61, 94)
        TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
        if IsEntityDead(GetPlayerPed(u)) then
            e.heartRate = 0
            e.dead = true
            e.bloodPressure1 = 0
            e.bloodPressure2 = 0
            e.temperature = math.random(5, 25)
            e.spo2 = 0
            TriggerEvent(
                "VICE:showNotification",
                {
                    text = "LIFEPAK is unable to detect a pulse from this patient.",
                    height = "200px",
                    width = "auto",
                    colour = "#FFF",
                    background = "#32CD32",
                    pos = "bottom-right",
                    icon = "success"
                },
                5000
            )
        else
            Wait(3000)
            if e.readyToRevive then
                TriggerEvent(
                    "VICE:showNotification",
                    {
                        text = "You must press Shock Patient on the menu to deliver a shock.",
                        height = "200px",
                        width = "auto",
                        colour = "#FFF",
                        background = "#32CD32",
                        pos = "bottom-right",
                        icon = "success"
                    },
                    5000
                )
                TriggerServerEvent("VICE:playNhsSound", "pushToShock")
            end
        end
    end
end
function connectObsToPatient()
    TriggerServerEvent("VICE:attachLifepakServer")
end
RegisterNetEvent(
    "VICE:clientPlayNhsSound",
    function(x, y)
        local z = GetEntityCoords(VICE.getPlayerPed())
        local A = #(z - x)
        if A <= 15 then
            SendNUIMessage({transactionType = y})
        end
    end
)
RegisterCommand("nhs",function()
    if globalNHSOnDuty or globalLFBOnDuty then
        if not RageUI.Visible(RMenu:Get("nhs", "main")) then
            RageUI.Visible(RMenu:Get("nhs", "main"), not RageUI.Visible(RMenu:Get("nhs", "main")))
        end
    end
end)
RegisterNetEvent("VICE:returnRevive",function()
    TriggerServerEvent("VICE:playNhsSound", "checkPatientAlarm")
    e.bloodPressure1 = math.random(20, 199)
    e.bloodPressure2 = math.floor(e.bloodPressure1 - e.bloodPressure1 / 2.9)
    if e.bloodPressure2 > e.bloodPressure1 then
        e.bloodPressure2 = e.bloodPressure2 / 2
    end
    e.heartRate = math.random(52, 95)
    e.temperature = 36.7 - 1 / math.random(2, 3)
    e.spo2 = math.random(95, 100)
    e.dead = false
    e.coma = false
    Wait(3000)
    TriggerServerEvent("VICE:playNhsSound", "safeToTouch")
    Wait(12000)
    TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
end)
local B = {
    `WEAPON_SNOWBALL`,
    `WEAPON_HOSE`,
    `WEAPON_THROWBAG`,
    `WEAPON_PETROLCAN`,
    `WEAPON_FIREEXTINGUISHER`,
    `GADGET_PARACHUTE`,
    `WEAPON_PDGLOCK20VA5`,
    `WEAPON_STUNGUN`,
    `WEAPON_STAFFGUN`
}
local function C()
    if globalNHSOnDuty or globalLFBOnDuty and not VICE.getUserId() == 1 then
        local D = PlayerPedId()
        local E = GetSelectedPedWeapon(D)
        if E ~= `WEAPON_UNARMED` then
            if not table.has(B, E) then
                VICE.setWeapon(D, "WEAPON_UNARMED", true)
            end
        end
    end
end
VICE.createThreadOnTick(C)
Citizen.CreateThread(function()
    while true do
        if e.active and e.targetPed then
            local F = VICE.getPlayerCoords()
            local G = GetEntityCoords(e.targetPed, true)
            if #(F - G) > 10.0 then
                e.active = false
                TriggerServerEvent("VICE:playNhsSound", "threeBeeps")
                VICE.notify("~r~Lifepak disconnected.")
            end
        end
        Citizen.Wait(5000)
    end
end)
local H = false
RegisterNetEvent("VICE:attemptCPR",function()
    H = true
    VICE.loadAnimDict("missheistfbi3b_ig8_2")
    TaskPlayAnim(PlayerPedId(),"missheistfbi3b_ig8_2","cpr_loop_paramedic",8.0,1.0,-1,524801,0,false,false,false)
    RemoveAnimDict("missheistfbi3b_ig8_2")
    ForcePedAiAndAnimationUpdate(PlayerPedId(), false, false)
    Citizen.Wait(100)
    while H do
        if not IsEntityPlayingAnim(PlayerPedId(), "missheistfbi3b_ig8_2", "cpr_loop_paramedic", 3) or IsControlJustReleased(0, 73) then
            H = false
            TriggerServerEvent("VICE:cancelCPRAttempt")
            break
        end
        Citizen.Wait(0)
    end
end)
RegisterNetEvent("VICE:cancelCPRAttempt", function()
    H = false
    if VICE.canAnim() then
        ClearPedTasks(PlayerPedId())
    end
end)
RegisterNetEvent("VICE:cancelCPR", function()
    ReviveReady = true
    if ReviveReady then
        ClearPedTasks(PlayerPedId())
    end
end)