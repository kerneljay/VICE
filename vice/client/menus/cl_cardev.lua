RMenu.Add(
    "cardev",
    "mainmenu",
    RageUI.CreateMenu("", "", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "cardeveloper")
)
RMenu:Get("cardev", "mainmenu"):SetSubtitle("Car Dev Menu")
RMenu.Add(
    "cardev",
    "vehiclemods",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "mainmenu"),
        "",
        "~b~Vehicle Mods",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "cardev",
    "vehiclemodindexes",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "vehiclemods"),
        "",
        "~b~Vehicle Mod Indexes",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "cardev",
    "extras",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "mainmenu"),
        "",
        "~b~Extras",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
RMenu.Add(
    "cardev",
    "car_dev",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "mainmenu"),
        "",
        "~b~To-do",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)

RMenu.Add(
    "cardev",
    "vehicle_details",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "car_dev"),
        "",
        "~b~Vehicle Details",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)

RMenu.Add(
    "cardev",
    "colours",
    RageUI.CreateSubMenu(
        RMenu:Get("cardev", "mainmenu"),
        "",
        "~b~Colours",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)
local a = false
local b = false
local c = {"speed", "drift", "handling", "city", "airport"}
local d = {
    vector3(2370.8, 2856.58, 40.46),
    vector3(974.58, -3006.6, 5.9),
    vector3(1894.57, 3823.71, 31.98),
    vector3(-482.63, -664.24, 32.74),
    vector3(-1728.25, -2894.99, 13.94)
}
local e = 1
function VICE.isCarDev()
    return a
end
local f = {
    [0] = "VMT_SPOILER",
    [1] = "VMT_BUMPER_F",
    [2] = "VMT_BUMPER_R",
    [3] = "VMT_SKIRT",
    [4] = "VMT_EXHAUST",
    [5] = "VMT_CHASSIS",
    [6] = "VMT_GRILL",
    [7] = "VMT_BONNET",
    [8] = "VMT_WING_L",
    [9] = "VMT_WING_R",
    [10] = "VMT_ROOF",
    [11] = "VMT_ENGINE",
    [12] = "VMT_BRAKES",
    [13] = "VMT_GEARBOX",
    [14] = "VMT_HORN",
    [15] = "VMT_SUSPENSION",
    [16] = "VMT_ARMOUR",
    [17] = "VMT_NITROUS",
    [18] = "VMT_TURBO",
    [19] = "VMT_SUBWOOFER",
    [20] = "VMT_TYRE_SMOKE",
    [21] = "VMT_HYDRAULICS",
    [22] = "VMT_XENON_LIGHTS",
    [23] = "VMT_WHEELS",
    [24] = "VMT_WHEELS_REAR_OR_HYDRAULICS",
    [25] = "VMT_PLTHOLDER",
    [26] = "VMT_PLTVANITY",
    [27] = "VMT_INTERIOR1",
    [28] = "VMT_INTERIOR2",
    [29] = "VMT_INTERIOR3",
    [30] = "VMT_INTERIOR4",
    [31] = "VMT_INTERIOR5",
    [32] = "VMT_SEATS",
    [33] = "VMT_STEERING",
    [34] = "VMT_KNOB",
    [35] = "VMT_PLAQUE",
    [36] = "VMT_ICE",
    [37] = "VMT_TRUNK",
    [38] = "VMT_HYDRO",
    [39] = "VMT_ENGINEBAY1",
    [40] = "VMT_ENGINEBAY2",
    [41] = "VMT_ENGINEBAY3",
    [42] = "VMT_CHASSIS2",
    [43] = "VMT_CHASSIS3",
    [44] = "VMT_CHASSIS4",
    [45] = "VMT_CHASSIS5",
    [46] = "VMT_DOOR_L",
    [47] = "VMT_DOOR_R",
    [48] = "VMT_LIVERY_MOD",
    [49] = "VMT_LIGHTBAR"
}
local g = {
    {name = "Black", colorindex = 0},
    {name = "White", colorindex = 112},
    {name = "Red", colorindex = 27},
    {name = "Orange", colorindex = 38},
    {name = "Yellow", colorindex = 88},
    {name = "Green", colorindex = 92},
    {name = "Blue", colorindex = 64},
    {name = "Pink", colorindex = 135},
    {name = "Purple", colorindex = 142}
}
local user_id = GetPlayerServerId(PlayerId())
local loading = true
local userVehicles = {}

RegisterNetEvent('vice:receiveUserVehicles')
AddEventHandler('vice:receiveUserVehicles', function(receivedVehicles)
   -- print("Received user vehicles:")
    for _, vehicleData in pairs(receivedVehicles) do
       -- print("Vehicle name:", vehicleData.spawncode)
    end

    userVehicles = receivedVehicles
    loading = false
end)

RegisterNetEvent('VICE:carDevTicket')
AddEventHandler('VICE:carDevTicket', function()
    if a then
        VICE.notify("~b~Car report received.")
    end
end)

RageUI.CreateWhile(
    1.0,
    RMenu:Get("cardev", "mainmenu"),
    function()
        RageUI.IsVisible(
            RMenu:Get("cardev", "mainmenu"),
            true,
            true,
            true,
            function()
                if b and VICE.getPlayerBucket() == 333 then
                    RageUI.ButtonWithStyle(
                        "Spawn Vehicle (No Mods)",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                tVICE.clientPrompt(
                                    "Spawncode:",
                                    "",
                                    function(k)
                                        if k ~= "" and VICE.getPlayerBucket() == 333 then
                                            local l = VICE.loadModel(k)
                                            TriggerServerEvent("VICE:logVehicleSpawn", k, "/cardev")
                                            local m = VICE.getPlayerCoords()
                                            VICEserver.CreateVehicle({l,m.x,m.y,m.z,GetEntityHeading(VICE.getPlayerPed()),true,true,}, function(nveh)
                                            local vehicle = NetToVeh(nveh)
                                            DecorSetInt(vehicle, decor, 955)
                                            SetVehicleOnGroundProperly(vehicle)
                                            SetEntityInvincible(vehicle, false)
                                            SetPedIntoVehicle(VICE.getPlayerPed(), vehicle, -1)
                                            SetModelAsNoLongerNeeded(l)
                                            SetVehRadioStation(vehicle, "OFF")
                                            Wait(500)
                                            SetVehRadioStation(vehicle, "OFF")
                                            end)
                                           
                                        end
                                    end
                                )
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Spawn Vehicle (Full Mods)",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                tVICE.clientPrompt(
                                    "Spawncode:",
                                    "",
                                    function(k)
                                        if k ~= "" and VICE.getPlayerBucket() == 333 then
                                            local l = VICE.loadModel(k)
                                            TriggerServerEvent("VICE:logVehicleSpawn", k, "/cardev")
                                            local m = VICE.getPlayerCoords()
                                            local n =
                                                VICE.spawnVehicle(
                                                l,
                                                m.x,
                                                m.y,
                                                m.z,
                                                GetEntityHeading(VICE.getPlayerPed()),
                                                true,
                                                true,
                                                true
                                            )
                                            DecorSetInt(n, decor, 955)
                                            SetVehicleOnGroundProperly(n)
                                            SetEntityInvincible(n, false)
                                            SetVehicleModKit(n, 0)
                                            SetVehicleMod(n, 11, 2, false)
                                            SetVehicleMod(n, 13, 2, false)
                                            SetVehicleMod(n, 12, 2, false)
                                            SetVehicleMod(n, 15, 3, false)
                                            ToggleVehicleMod(n, 18, true)
                                            SetPedIntoVehicle(VICE.getPlayerPed(), n, -1)
                                            SetModelAsNoLongerNeeded(l)
                                            SetVehRadioStation(n, "OFF")
                                            Wait(500)
                                            SetVehRadioStation(n, "OFF")
                                        end
                                    end
                                )
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Delete Vehicle",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                local o = GetVehiclePedIsIn(VICE.getPlayerPed(), false)
                                if NetworkHasControlOfEntity(o) then
                                    DeleteEntity(o)
                                end
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Fix Vehicle",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                local p = VICE.getPlayerPed()
                                if IsPedInAnyVehicle(p) then
                                    local q = GetVehiclePedIsIn(p)
                                    SetVehicleEngineHealth(q, 9999)
                                    SetVehiclePetrolTankHealth(q, 9999)
                                    SetVehicleFixed(q)
                                end
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Take Screenshot",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                local p = VICE.getPlayerPed()
                                if IsPedInAnyVehicle(p) then
                                    TakeVehScreenshot()
                                end
                            end
                        end
                    )
                    RageUI.List(
                        "Teleport",
                        c,
                        e,
                        "",
                        {},
                        true,
                        function(h, i, j, r)
                            e = r
                            if j then
                                tVICE.teleport2(d[e], true)
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Cycle through seats",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                local p = VICE.getPlayerPed()
                                if IsPedInAnyVehicle(p) then
                                    local s = GetVehiclePedIsIn(p)
                                    local t = GetVehicleModelNumberOfSeats(GetEntityModel(s))
                                    for u = -1, t - 2 do
                                        if IsVehicleSeatFree(s, u) then
                                            TaskWarpPedIntoVehicle(p, s, u)
                                            Wait(2000)
                                        end
                                    end
                                else
                                    VICE.notify("~r~Not in a vehicle.")
                                end
                            end
                        end
                    )
                    RageUI.ButtonWithStyle(
                        "Vehicle Mods",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(h, i, j)
                            if j then
                                local p = VICE.getPlayerPed()
                                if IsPedInAnyVehicle(p) then
                                    local s = GetVehiclePedIsIn(p)
                                else
                                    VICE.notify("~r~Not in a vehicle.")
                                end
                            end
                        end,
                        RMenu:Get("cardev", "vehiclemods")
                    )
                    RageUI.ButtonWithStyle(
                        "Vehicle Extras",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function()
                        end,
                        RMenu:Get("cardev", "extras")
                    )
                    RageUI.ButtonWithStyle(
                        "Vehicle To-Do",
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function()
                        end,
                        RMenu:Get("cardev", "car_dev")
                    )
                    -- RageUI.ButtonWithStyle(
                    --     "Vehicle Colours",
                    --     "",
                    --     {RightLabel = "→→→"},
                    --     true,
                    --     function()
                    --     end,
                    --     RMenu:Get("cardev", "colours")
                    -- )
                    RageUI.Checkbox(
                        "Return to normal Universe",
                        "",
                        b,
                        {},
                        function()
                        end,
                        function()
                            b = true
                            TriggerServerEvent("VICE:setCarDevMode", b)
                        end,
                        function()
                            b = false
                            TriggerServerEvent("VICE:setCarDevMode", b)
                        end
                    )
                else
                    RageUI.Checkbox(
                        "Teleport to Car Dev Universe",
                        "",
                        b,
                        {},
                        function()
                        end,
                        function()
                            b = true
                            TriggerServerEvent("VICE:setCarDevMode", b)
                        end,
                        function()
                            b = false
                            TriggerServerEvent("VICE:setCarDevMode", b)
                        end
                    )
                    RageUI.Separator("~g~Enter the Car Dev Universe to see more menu options.")
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("cardev", "vehiclemods"),
            true,
            true,
            true,
            function()
                for v, w in pairs(f) do
                    if GetNumVehicleMods(VICE.getPlayerVehicle(), v) > 0 then
                        RageUI.ButtonWithStyle(
                            w,
                            "",
                            {RightLabel = "→→→"},
                            true,
                            function(h, i, j)
                                if j then
                                    selectedModType = v
                                end
                            end,
                            RMenu:Get("cardev", "vehiclemodindexes")
                        )
                    end
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("cardev", "vehiclemodindexes"),
            true,
            true,
            true,
            function()
                if GetNumVehicleMods(VICE.getPlayerVehicle(), selectedModType) == 0 then
                    RageUI.Text({message = "~r~No available mod indexes for this mod type for this vehicle."})
                else
                    for v = 0, GetNumVehicleMods(VICE.getPlayerVehicle(), selectedModType) do
                        RageUI.ButtonWithStyle(
                            "Mod " .. v,
                            "",
                            {RightLabel = "→→→"},
                            true,
                            function(h, i, j)
                                if j then
                                    SetVehicleModKit(VICE.getPlayerVehicle(), 0)
                                    SetVehicleMod(VICE.getPlayerVehicle(), selectedModType, v)
                                end
                            end,
                            RMenu:Get("cardev", "vehiclemodindexes")
                        )
                    end
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("cardev", "car_dev"),
            true,
            true,
            true,
            function()
                if loading then
                    RageUI.Separator("Loading...")
                else
                    if not currentVehicleData then
                        RageUI.Separator("~y~Vehicle Developer To-do List")
                        RageUI.Separator("~y~Use Discord commands for a more in-depth usage")
                        RageUI.Separator("--------------------------------------")
                    end
        
                    local hasUncompletedVehicles = false
                    local name = "Unkown"
        
                    if userVehicles then
                        for _, vehicleData in pairs(userVehicles) do
                            if not vehicleData.completed and not hideOtherButtons then
                                hasUncompletedVehicles = true
                                RageUI.Button(
                                    vehicleData.spawncode,
                                    "",
                                    { RightLabel = "→→→" },
                                    true,  
                                    function(_, _, selected)
                                        if selected then
                                            currentVehicleData = vehicleData
                                            hideOtherButtons = true
                                        end
                                    end
                                )
                            end
                        end
                    else
                        RageUI.Separator("Loading...")
                        return
                    end
        
                    if not hasUncompletedVehicles and not currentVehicleData then
                        RageUI.Separator("No claimed vehicles.")
                    end
        
                    if currentVehicleData then
                        RageUI.Separator("~b~Vehicle Details")
                        RageUI.Separator("~b~Spawncode: " .. currentVehicleData.spawncode)
                        if currentVehicleData.notes ~= "" then
                            RageUI.Separator("~b~Notes: " .. currentVehicleData.notes)
                        end
                      --  RageUI.Separator("~b~Reporters Discord ID: " .. currentVehicleData.reporter)
                        RageUI.Separator("~b~Issue: " .. (currentVehicleData.issue or "No issues"))
                        RageUI.Button("Spawn Vehicle", nil, {}, true, function(_, _, selected)
                            if selected then
                                local l = VICE.loadModel(currentVehicleData.spawncode)
                                TriggerServerEvent("VICE:logVehicleSpawn", currentVehicleData.spawncode, "/cardev")
                                local m = VICE.getPlayerCoords()
                                local n = VICE.spawnVehicle(l, m.x, m.y, m.z, GetEntityHeading(VICE.getPlayerPed()), true, true, true)
                                DecorSetInt(n, decor, 955)
                                SetVehicleOnGroundProperly(n)
                                SetEntityInvincible(n, false)
                                SetPedIntoVehicle(VICE.getPlayerPed(), n, -1)
                                SetModelAsNoLongerNeeded(l)
                                SetVehRadioStation(n, "OFF")
                                Wait(500)
                                SetVehRadioStation(n, "OFF")
                            end
                        end)
                        RageUI.Button("Marked as complete", nil, {}, true, function(_, _, selected)
                            if selected then
                                tVICE.clientPrompt("Reason for marking as complete:", "", function(reason)
                                    if reason ~= "" then
                                        local user_id = GetPlayerServerId(PlayerId())
                                        TriggerServerEvent('vice:markVehicleComplete', currentVehicleData.reportid, reason)
                                        local user_id = GetPlayerServerId(PlayerId())
                                        TriggerServerEvent('vice:getUserVehicles', user_id)
                                        currentVehicleData = nil
                                        hideOtherButtons = false
                                        RageUI.CloseAll()
                                        Wait(1000)
                                        local user_id = GetPlayerServerId(PlayerId())
                                        TriggerServerEvent('vice:getUserVehicles', user_id)
                                        RageUI.Visible(RMenu:Get("cardev", "car_dev"), true)
                                    else
                                        VICE.notify("~r~You must provide a valid reason.")
                                    end
                                end)
                            end
                        end)
                        RageUI.Button("Copy Reporters Discord ID", nil, {}, true, function(_, _, selected)
                            if selected then
                                TriggerEvent("VICE:showNotification", {text = "Reporters Discord ID Copied To Clipboard.", height = "200px", width = "auto", colour = "#FFF", background = "#32CD32", pos = "bottom-right", icon = "good"}, 5000)
                                tVICE.CopyToClipBoard(currentVehicleData.reporter)
                            end
                        end)
                        RageUI.Button("Back to list", nil, {}, true, function(_, _, selected)
                            if selected then
                                currentVehicleData = nil
                                hideOtherButtons = false
                                local user_id = GetPlayerServerId(PlayerId())
                                TriggerServerEvent('vice:getUserVehicles', user_id)
                                RageUI.CloseAll()
                                RageUI.Visible(RMenu:Get("cardev", "car_dev"), true)
                            end
                        end)
                    end
                end
            end,function()
        end)  
        RageUI.IsVisible(
            RMenu:Get("cardev", "extras"),
            true,
            true,
            true,
            function()
                local q = VICE.getPlayerVehicle()
                local x = false
                if q ~= 0 then
                    for v = 1, 12 do
                        if DoesExtraExist(q, v) then
                            x = true
                            if IsVehicleExtraTurnedOn(q, v) then
                                RageUI.Button(
                                    "Disable Extra " .. v,
                                    nil,
                                    {RightLabel = tostring(v)},
                                    function(h, i, j)
                                        if j then
                                            SetVehicleExtra(q, v, true)
                                        end
                                    end
                                )
                            else
                                RageUI.Button(
                                    "Enable Extra " .. v,
                                    nil,
                                    {RightLabel = tostring(v)},
                                    function(h, i, j)
                                        if j then
                                            SetVehicleExtra(q, v, false)
                                            TriggerEvent("VICE:staffFixVehicle")
                                        end
                                    end
                                )
                            end
                        end
                    end
                end
                if not x then
                    RageUI.Text({message = "~r~No available extras for this vehicle."})
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("cardev", "colours"),
            true,
            true,
            true,
            function()
                for y, z in pairs(g) do
                    RageUI.Button(
                        z.name,
                        nil,
                        true,
                        function(h, i, j)
                            if j then
                                SetVehicleColours(VICE.getPlayerVehicle(), z.colorindex, z.colorindex)
                            end
                        end
                    )
                end
            end,
            function()
            end
        )
    end
)
local function A()
    RageUI.Visible(RMenu:Get("cardev", "mainmenu"), not RageUI.Visible(RMenu:Get("cardev", "mainmenu")))
end
RegisterCommand(
    "cardev",
    function(B)
        if a and not VICE.isInPurge() then
            A()
            local user_id = GetPlayerServerId(PlayerId())
            TriggerServerEvent('vice:getUserVehicles', user_id)
        end
    end
)
RegisterNetEvent(
    "VICE:setCarDev",
    function()
        a = true
    end
)
RegisterNetEvent(
    "VICE:setBucket",
    function(C)
        if b and C ~= 333 then
            RageUI.CloseAll()
            b = false
        end
    end
)
local TakingCarSS = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if TakingCarSS then
            SetEntityInvincible(GetVehiclePedIsIn(GetPlayerPed(-1),false),true)
            SetEntityProofs(GetVehiclePedIsIn(GetPlayerPed(-1),false),true,true,true,true,true,true,true,true)
            SetEntityCanBeDamaged(GetVehiclePedIsIn(GetPlayerPed(-1),false),false)
            SetEntityCanBeDamaged(GetPlayerPed(-1),false)
            SetVehicleFixed(GetVehiclePedIsIn(PlayerPedId(), true))
            SetVehicleDirtLevel(GetVehiclePedIsIn(PlayerPedId(), true),0.0)
            ClearPedBloodDamage(GetPlayerPed(-1))
            for i=0,360 do
                DisableControlAction(1,i,true)
            end
        end
    end
end)
function TakeVehScreenshot()
    if GetVehiclePedIsIn(PlayerPedId(),false)==0 then
        VICE.notify("~r~You must be in a vehicle.")
        return 
    end
    TakingCarSS = true
    ExecuteCommand('hideui')
    ped = GetVehiclePedIsIn(PlayerPedId(), true)
    SetEntityCoords(ped, vector3(-921.20440673828,-3082.5627441406,12.557805664062))
    SetEntityHeading(PlayerPedId(),100.0)
    SetGameplayCamRelativePitch(7.5,1.0)
    SetGameplayCamRelativeHeading(-180.0)
    Wait(3000)
    TriggerServerEvent('VICE:takeCarScreenshot')
    Wait(5000)
    SetGameplayCamRelativeHeading(0.8)
    TriggerServerEvent('VICE:takeCarScreenshot')
    Wait(5000)
    SetGameplayCamRelativeHeading(92.0)
    TriggerServerEvent('VICE:takeCarScreenshot')
    Wait(5000)
    TakingCarSS = false
    SetEntityInvincible(GetVehiclePedIsIn(GetPlayerPed(-1),false),false)
    SetEntityProofs(GetVehiclePedIsIn(GetPlayerPed(-1),false),false,false,false,false,false,false,false,false)
    SetEntityCanBeDamaged(GetVehiclePedIsIn(GetPlayerPed(-1),false),true)
    SetEntityCanBeDamaged(GetPlayerPed(-1),true)
    ExecuteCommand('showui')
end
local D = {
    {name = "fMass", type = "float"},
    {name = "fInitialDragCoeff", type = "float"},
    {name = "fDownforceModifier", type = "float"},
    {name = "fPercentSubmerged", type = "float"},
    {name = "vecCentreOfMassOffset", type = "vector"},
    {name = "vecInertiaMultiplier", type = "vector"},
    {name = "fDriveBiasFront", type = "float"},
    {name = "nInitialDriveGears", type = "integer"},
    {name = "fInitialDriveForce", type = "float"},
    {name = "fDriveInertia", type = "float"},
    {name = "fClutchChangeRateScaleUpShift", type = "float"},
    {name = "fClutchChangeRateScaleDownShift", type = "float"},
    {name = "fInitialDriveMaxFlatVel", type = "float"},
    {name = "fBrakeForce", type = "float"},
    {name = "fBrakeBiasFront", type = "float"},
    {name = "fHandBrakeForce", type = "float"},
    {name = "fSteeringLock", type = "float"},
    {name = "fTractionCurveMax", type = "float"},
    {name = "fTractionCurveMin", type = "float"},
    {name = "fTractionCurveLateral", type = "float"},
    {name = "fTractionSpringDeltaMax", type = "float"},
    {name = "fLowSpeedTractionLossMult", type = "float"},
    {name = "fCamberStiffnesss", type = "float"},
    {name = "fTractionBiasFront", type = "float"},
    {name = "fTractionLossMult", type = "float"},
    {name = "fSuspensionForce", type = "float"},
    {name = "fSuspensionCompDamp", type = "float"},
    {name = "fSuspensionReboundDamp", type = "float"},
    {name = "fSuspensionUpperLimit", type = "float"},
    {name = "fSuspensionLowerLimit", type = "float"},
    {name = "fSuspensionRaise", type = "float"},
    {name = "fSuspensionBiasFront", type = "float"},
    {name = "fAntiRollBarForce", type = "float"},
    {name = "fAntiRollBarBiasFront", type = "float"},
    {name = "fRollCentreHeightFront", type = "float"},
    {name = "fRollCentreHeightRear", type = "float"},
    {name = "fCollisionDamageMult", type = "float"},
    {name = "fWeaponDamageMult", type = "float"},
    {name = "fDeformationDamageMult", type = "float"},
    {name = "fEngineDamageMult", type = "float"},
    {name = "fPetrolTankVolume", type = "float"},
    {name = "fOilVolume", type = "float"},
    {name = "fSeatOffsetDistX", type = "float"},
    {name = "fSeatOffsetDistY", type = "float"},
    {name = "fSeatOffsetDistZ", type = "float"},
    {name = "nMonetaryValue", type = "integer"}
}
local E = {
    ["CCarHandlingData"] = {
        {name = "fBackEndPopUpCarImpulseMult", type = "float"},
        {name = "fBackEndPopUpBuildingImpulseMult", type = "float"},
        {name = "fBackEndPopUpMaxDeltaSpeed", type = "float"},
        {name = "fToeFront", type = "float"},
        {name = "fToeRear", type = "float"},
        {name = "fCamberFront", type = "float"},
        {name = "fCamberRear", type = "float"},
        {name = "fCastor", type = "float"},
        {name = "fEngineResistance", type = "float"},
        {name = "fMaxDriveBiasTransfer", type = "float"},
        {name = "fJumpForceScale", type = "float"},
        {name = "fIncreasedRammingForceScale", type = "float"}
    },
    ["CTrailerHandlingData"] = {
        {name = "fAttachLimitPitch", type = "float"},
        {name = "fAttachLimitRoll", type = "float"},
        {name = "fAttachLimitYaw", type = "float"},
        {name = "fUprightSpringConstant", type = "float"},
        {name = "fUprightDampingConstant", type = "float"},
        {name = "fAttachedMaxDistance", type = "float"},
        {name = "fAttachedMaxPenetration", type = "float"},
        {name = "fAttachRaiseZ", type = "float"},
        {name = "fPosConstraintMassRatio", type = "float"}
    },
    ["CBoatHandlingData"] = {
        {name = "fBoxFrontMult", type = "float"},
        {name = "fBoxRearMult", type = "float"},
        {name = "fBoxSideMult", type = "float"},
        {name = "fSampleTop", type = "float"},
        {name = "fSampleBottom", type = "float"},
        {name = "fSampleBottomTestCorrection", type = "float"},
        {name = "fAquaplaneForce", type = "float"},
        {name = "fAquaplanePushWaterMult", type = "float"},
        {name = "fAquaplanePushWaterCap", type = "float"},
        {name = "fAquaplanePushWaterApply", type = "float"},
        {name = "fRudderForce", type = "float"},
        {name = "fRudderOffsetSubmerge", type = "float"},
        {name = "fRudderOffsetForce", type = "float"},
        {name = "fRudderOffsetForceZMult", type = "float"},
        {name = "fWaveAudioMult", type = "float"},
        {name = "vecMoveResistance", type = "vector"},
        {name = "vecTurnResistance", type = "vector"},
        {name = "fLook_L_R_CamHeight", type = "float"},
        {name = "fDragCoefficient", type = "float"},
        {name = "fKeelSphereSize", type = "float"},
        {name = "fPropRadius", type = "float"},
        {name = "fLowLodAngOffset", type = "float"},
        {name = "fLowLodDraughtOffset", type = "float"},
        {name = "fImpellerOffset", type = "float"},
        {name = "fImpellerForceMult", type = "float"},
        {name = "fDinghySphereBuoyConst", type = "float"},
        {name = "fProwRaiseMult", type = "float"},
        {name = "fDeepWaterSampleBuoyancyMult", type = "float"},
        {name = "fTransmissionMultiplier", type = "float"},
        {name = "fTractionMultiplier", type = "float"}
    },
    ["CBikeHandlingData"] = {
        {name = "fLeanFwdCOMMult", type = "float"},
        {name = "fLeanFwdForceMult", type = "float"},
        {name = "fLeanBakCOMMult", type = "float"},
        {name = "fLeanBakForceMult", type = "float"},
        {name = "fMaxBankAngle", type = "float"},
        {name = "fFullAnimAngle", type = "float"},
        {name = "fDesLeanReturnFrac", type = "float"},
        {name = "fStickLeanMult", type = "float"},
        {name = "fBrakingStabilityMult", type = "float"},
        {name = "fInAirSteerMult", type = "float"},
        {name = "fWheelieBalancePoint", type = "float"},
        {name = "fStoppieBalancePoint", type = "float"},
        {name = "fWheelieSteerMult", type = "float"},
        {name = "fRearBalanceMult", type = "float"},
        {name = "fFrontBalanceMult", type = "float"},
        {name = "fBikeGroundSideFrictionMult", type = "float"},
        {name = "fBikeWheelGroundSideFrictionMult", type = "float"},
        {name = "fBikeOnStandLeanAngle", type = "float"},
        {name = "fBikeOnStandSteerAngle", type = "float"},
        {name = "fJumpForce", type = "float"}
    },
    ["CSubmarineHandlingData"] = {
        {name = "vTurnRes", type = "vector"},
        {name = "fMoveResXY", type = "float"},
        {name = "fMoveResZ", type = "float"},
        {name = "fPitchMult", type = "float"},
        {name = "fPitchAngle", type = "float"},
        {name = "fYawMult", type = "float"},
        {name = "fDiveSpeed", type = "float"},
        {name = "fRollMult", type = "float"},
        {name = "fRollStab", type = "float"}
    },
    ["CSpecialFlightHandlingData"] = {
        {name = "vecAngularDamping", type = "vector"},
        {name = "vecAngularDampingMin", type = "vector"},
        {name = "vecLinearDamping", type = "vector"},
        {name = "vecLinearDampingMin", type = "vector"},
        {name = "fLiftCoefficient", type = "float"},
        {name = "fCriticalLiftAngle", type = "float"},
        {name = "fInitialLiftAngle", type = "float"},
        {name = "fMaxLiftAngle", type = "float"},
        {name = "fDragCoefficient", type = "float"},
        {name = "fBrakingDrag", type = "float"},
        {name = "fMaxLiftVelocity", type = "float"},
        {name = "fMinLiftVelocity", type = "float"},
        {name = "fRollTorqueScale", type = "float"},
        {name = "fMaxTorqueVelocity", type = "float"},
        {name = "fMinTorqueVelocity", type = "float"},
        {name = "fYawTorqueScale", type = "float"},
        {name = "fSelfLevelingPitchTorqueScale", type = "float"},
        {name = "fInitalOverheadAssist", type = "float"},
        {name = "fMaxPitchTorque", type = "float"},
        {name = "fMaxSteeringRollTorque", type = "float"},
        {name = "fPitchTorqueScale", type = "float"},
        {name = "fSteeringTorqueScale", type = "float"},
        {name = "fMaxThrust", type = "float"},
        {name = "fTransitionDuration", type = "float"},
        {name = "fHoverVelocityScale", type = "float"},
        {name = "fStabilityAssist", type = "float"},
        {name = "fMinSpeedForThrustFalloff", type = "float"},
        {name = "fBrakingThrustScale", type = "float"},
        {name = "mode", type = "integer"}
    },
    ["CFlyingHandlingData"] = {
        {name = "fThrust", type = "float"},
        {name = "fThrustFallOff", type = "float"},
        {name = "fThrustVectoring", type = "float"},
        {name = "fInitialThrust", type = "float"},
        {name = "fInitialThrustFallOff", type = "float"},
        {name = "fYawMult", type = "float"},
        {name = "fYawStabilise", type = "float"},
        {name = "fSideSlipMult", type = "float"},
        {name = "fInitialYawMult", type = "float"},
        {name = "fRollMult", type = "float"},
        {name = "fRollStabilise", type = "float"},
        {name = "fInitialRollMult", type = "float"},
        {name = "fPitchMult", type = "float"},
        {name = "fPitchStabilise", type = "float"},
        {name = "fFormLiftMult", type = "float"},
        {name = "fAttackLiftMult", type = "float"},
        {name = "fAttackDiveMult", type = "float"},
        {name = "fGearDownDragV", type = "float"},
        {name = "fGearDownLiftMult", type = "float"},
        {name = "fWindMult", type = "float"},
        {name = "fMoveRes", type = "float"},
        {name = "vecTurnRes", type = "vector"},
        {name = "vecSpeedRes", type = "vector"},
        {name = "fGearDoorFrontOpen", type = "float"},
        {name = "fGearDoorRearOpen", type = "float"},
        {name = "fGearDoorRearOpen2", type = "float"},
        {name = "fGearDoorRearMOpen", type = "float"},
        {name = "fTurublenceMagnitudeMax", type = "float"},
        {name = "fTurublenceForceMulti", type = "float"},
        {name = "fTurublenceRollTorqueMulti", type = "float"},
        {name = "fTurublencePitchTorqueMulti", type = "float"},
        {name = "fBodyDamageControlEffectMult", type = "float"},
        {name = "fInputSensitivityForDifficulty", type = "float"},
        {name = "fOnGroundYawBoostSpeedPeak", type = "float"},
        {name = "fOnGroundYawBoostSpeedCap", type = "float"},
        {name = "fEngineOffGlideMulti", type = "float"},
        {name = "fAfterburnerEffectRadius", type = "float"},
        {name = "fAfterburnerEffectDistance", type = "float"},
        {name = "fAfterburnerEffectForceMulti", type = "float"},
        {name = "fSubmergeLevelToPullHeliUnderwater", type = "float"},
        {name = "fExtraLiftWithRoll", type = "float"}
    },
    ["CSeaPlaneHandlingData"] = {
        {name = "fLeftPontoonComponentId", type = "integer"},
        {name = "fRightPontoonComponentId", type = "integer"},
        {name = "fPontoonBuoyConst", type = "float"},
        {name = "fPontoonSampleSizeFront", type = "float"},
        {name = "fPontoonSampleSizeMiddle", type = "float"},
        {name = "fPontoonSampleSizeRear", type = "float"},
        {name = "fPontoonLengthFractionForSamples", type = "float"},
        {name = "fPontoonDragCoefficient", type = "float"},
        {name = "fPontoonVerticalDampingCoefficientUp", type = "float"},
        {name = "fPontoonVerticalDampingCoefficientDown", type = "float"},
        {name = "fKeelSphereSize", type = "float"}
    }
}
local F = D
local G = "CHandlingData"
local function H()
    return {
        speedBuffer = {},
        speed = 0.0,
        speedDisplay = 0.0,
        accel = 0.0,
        accelDisplay = 0.0,
        decel = 0.0,
        decelDisplay = 0.0
    }
end
local I = false
local J = H()
local function K()
    local q = VICE.getPlayerVehicle()
    local L = GetEntitySpeed(q)
    table.insert(J.speedBuffer, L)
    if #J.speedBuffer > 100 then
        table.remove(J.speedBuffer, 1)
    end
    local M = 0.0
    local N = 0.0
    local O = 0
    local P = 0
    for Q, R in ipairs(J.speedBuffer) do
        if Q > 1 then
            local S = R - J.speedBuffer[Q - 1]
            if S > 0.0 then
                M = M + S
                O = O + 1
            else
                N = M + S
                P = P + 1
            end
        end
    end
    M = M / O
    N = N / P
    J.speed = math.max(J.speed, L)
    J.speedDisplay = J.speed * 2.236936
    J.accel = math.max(J.accel, M)
    J.accelDisplay = J.accel * 60.0 * 2.236936
    J.decel = math.min(J.decel, N)
    J.decelDisplay = math.abs(J.decel) * 60.0 * 2.236936
end
local function T(U)
    local q = VICE.getPlayerVehicle()
    if q == 0 then
        return "0.0"
    end
    if U.type == "float" then
        local V = GetVehicleHandlingFloat(q, G, U.name)
        return string.format("%.5f", V)
    elseif U.type == "integer" then
        local W = GetVehicleHandlingInt(q, G, U.name)
        return tostring(W)
    elseif U.type == "vector" then
        local X = GetVehicleHandlingVector(q, G, U.name)
        return string.format("%.3f %.3f %.3f", X.x, X.y, X.z)
    end
    return "INVALID"
end
local function Y()
    AddTextEntry("FMMC_MPM_NA", "Enter Value")
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "Enter Value", "", "", "", "", 30)
    while UpdateOnscreenKeyboard() == 0 do
        DisableAllControlActions(0)
        Wait(0)
    end
    if GetOnscreenKeyboardResult() then
        local Z = GetOnscreenKeyboardResult()
        if Z then
            return Z
        end
    end
    return false
end
local function _(U)
    local a0 = Y()
    if not a0 then
        notify("~r~Input cancelled.")
        return
    end
    local q = VICE.getPlayerVehicle()
    if U.type == "float" then
        local a1 = tonumber(a0)
        if a1 then
            SetVehicleHandlingFloat(q, G, U.name, a1 + 0.0)
        else
            notify("~r~Can not parse float.")
        end
    elseif U.type == "integer" then
        local a1 = tonumber(a0)
        if a1 then
            SetVehicleHandlingInt(q, G, U.name, math.floor(a1))
        else
            notify("~r~Can not parse integer.")
        end
    elseif U.type == "vector" then
        local a2 = stringsplit(a0, " ")
        if a2 and #a2 >= 3 then
            local a3 = tonumber(a2[1])
            local a4 = tonumber(a2[2])
            local a5 = tonumber(a2[3])
            if a3 and a4 and a5 then
                SetVehicleHandlingVector(q, G, U.name, vector3(a3 + 0.0, a4 + 0.0, a5 + 0.0))
            else
                notify("~r~Can not parse vector.")
            end
        else
            notify("~r~Expected 3 floats.")
        end
    end
    ModifyVehicleTopSpeed(q, 1.0)
end
local function a6(a1)
    a1 = a1 * 10000.0
    return (a1 % 1.0 > 0.5 and math.ceil(a1) or math.floor(a1)) / 10000.0
end
local function a7()
    local a8 = ""
    local function a9(aa)
        if a8 ~= "" then
            a8 = a8 .. "\n\t\t\t"
        end
        a8 = a8 .. aa
    end
    local q = VICE.getPlayerVehicle()
    local dD = GetEntityModel(q)
    local car = GetDisplayNameFromVehicleModel(dD)
    for y, U in pairs(F) do
        if U.type == "float" then
            local a1 = GetVehicleHandlingFloat(q, G, U.name)
            a9(string.format('<%s value="%s" />', U.name, a6(a1)))
        elseif U.type == "integer" then
            local a1 = GetVehicleHandlingInt(q, G, U.name)
            a9(string.format('<%s value="%s" />', U.name, a1))
        elseif U.type == "vector" then
            local a1 = GetVehicleHandlingVector(q, G, U.name)
            a9(string.format('<%s x="%s" y="%s" z="%s" />', U.name, a1.x, a1.y, a1.z))
        end
    end
    tVICE.clientPrompt("Output (CTRL+A, CTRL+C)",a8,function()
    end)
    TriggerServerEvent("VICE:sendWebhookCarDev", a8, car)
end
local function ab(ac)
    I = ac
    setCursor(ac and 1 or 0)
    inGUIVICE = ac
end
local function ad()
    if not b or VICE.getPlayerBucket() ~= 333 then
        if I then
            ab(false)
        end
        return
    end
    K()
    local ae = VICE.getFontId("Akrobat-ExtraBold")
    local af = I and 0.345 or 0.505
    DrawAdvancedTextNoOutline(
        af,
        0.055,
        0.005,
        0.02,
        0.35,
        string.format("Top Speed: %.5f", J.speedDisplay),
        255,
        255,
        255,
        255,
        ae,
        1
    )
    DrawAdvancedTextNoOutline(
        af,
        0.075,
        0.005,
        0.02,
        0.35,
        string.format("Top Acceleration: %.5f", J.accelDisplay),
        255,
        255,
        255,
        255,
        ae,
        1
    )
    DrawAdvancedTextNoOutline(
        af,
        0.095,
        0.005,
        0.02,
        0.35,
        string.format("Top Deacceleration: %.5f", J.decelDisplay),
        255,
        255,
        255,
        255,
        ae,
        1
    )
    local s = VICE.getPlayerVehicle()
    DisableControlAction(0, 19, true)
    if s ~= 0 and IsDisabledControlJustPressed(0, 19) then
        ab(not I)
    end
    if not I then
        return
    elseif s == 0 then
        ab(false)
    end
    for Q, U in pairs(F) do
        local ag = Q > 23 and 1 or 0
        local ah = 0.14 + (Q - ag * 23) * 0.0215
        local ai = CursorInArea(0.25 + ag * 0.27, 0.5 + ag * 0.27, ah, ah + 0.0215)
        local aj = ai and 100 or 255
        DrawAdvancedTextNoOutline(0.345 + ag * 0.27, ah, 0.005, 0.02, 0.35, U.name, aj, aj, 255, 255, ae, 1)
        DrawAdvancedTextNoOutline(0.516 + ag * 0.231, ah + 0.001, 0.005, 0.02, 0.35, T(U), aj, aj, 255, 255, ae, 1)
        if ai and IsDisabledControlJustPressed(0, 24) then
            Citizen.CreateThreadNow(
                function()
                    _(U)
                end
            )
        end
    end
    DrawRect(0.465, 0.415, 0.09, 0.495, 0, 0, 0, 100)
    DrawRect(0.695, 0.415, 0.09, 0.495, 0, 0, 0, 100)
    DrawRect(0.278, 0.14, 0.055, 0.02, 255, 255, 255, 230)
    DrawAdvancedTextNoOutline(0.346, 0.129, 0.005, 0.02, 0.24, "Copy Handling", 0, 0, 0, 255, 0, 1)
    if CursorInArea(0.25, 0.31, 0.12, 0.15) and IsDisabledControlJustPressed(0, 24) then
        a7()
    end
    DrawRect(0.338, 0.14, 0.055, 0.02, 255, 255, 255, 230)
    DrawAdvancedTextNoOutline(0.41, 0.129, 0.005, 0.02, 0.24, "Reset Stats", 0, 0, 0, 255, 0, 1)
    if CursorInArea(0.31, 0.37, 0.12, 0.15) and IsDisabledControlJustPressed(0, 24) then
        J = H()
        F = D
        G = "CHandlingData"
    end
    local Q = 0
    for ak, al in pairs(E) do
        local ag = Q >= 4 and 1 or 0
        local ah = (Q - ag * 4) * 0.125
        DrawRect(0.308 + ah, 0.685 + 0.05 * ag, 0.115, 0.02, 255, 255, 255, 230)
        DrawAdvancedTextNoOutline(0.403 + ah, 0.675 + 0.05 * ag, 0.005, 0.02, 0.24, ak, 0, 0, 0, 255, 0, 0)
        if
            CursorInArea(0.2505 + ah, 0.3655 + ah, 0.665 + ag * 0.05, 0.705 + ag * 0.05) and
                IsDisabledControlJustPressed(0, 24)
         then
            F = al
            G = ak
        end
        Q = Q + 1
    end
end
VICE.createThreadOnTick(ad)
