
RegisterCommand("lfb_key",function()
    TriggerEvent("VICE:toggleLFBMenu")
end)
RegisterKeyMapping("lfb_key","LFB Menu","keyboard","U")
TriggerEvent('chat:addSuggestion','/lfb','Access your LFB menu')

local a = false

RMenu.Add("lfb","main",RageUI.CreateMenu("","Status: ~g~Available",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus", "lfb"))
RMenu.Add("lfb","tools",RageUI.CreateSubMenu(RMenu:Get("lfb", "main"),"","LFB: ~b~Tools",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("lfb","water",RageUI.CreateSubMenu(RMenu:Get("lfb", "main"),"","LFB: ~b~Water",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("lfb","ba",RageUI.CreateSubMenu(RMenu:Get("lfb", "main"),"","LFB: ~b~BA",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("lfb","firemain",RageUI.CreateMenu("", "Manage Fires", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "lfb"))
RMenu.Add("lfb","fire",RageUI.CreateSubMenu(RMenu:Get("lfb", "firemain"),"","LFB: ~b~Start Fires",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("lfb","management",RageUI.CreateSubMenu(RMenu:Get("lfb", "firemain"),"","LFB: ~b~Manage Fires",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))
RMenu.Add("lfb","settings",RageUI.CreateSubMenu(RMenu:Get("lfb", "firemain"),"","LFB: ~b~Settings",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight()))

local b = {}
local c = {}
local d = {object = 1, speedRad = 1, speed = 1, amount = 1, seperation = 1, degrees = 1, previewObjects = {}}
local e = {"0", "25", "50", "75", "100", "125", "150", "175", "200"}
local f = {"0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50"}
local g = {1, 2, 3, 4, 5}
local h = {3, 6, 9, 12, 15}
local i = {0, 45, 90, 135, 190, 235, 270, 315}
local j = {}
local k = {
    {"Police Slow", "prop_barrier_slow", true, 0.05},
    {"Police No Entry", "prop_barrier_noentry", true, 0.05},
    {"Police Incident Ahead", "prop_barrier_incident", true, 0.05},
    {"Police Checkpoint", "prop_barrier_checkpoint", true, 0.05},
    {"Police Collision", "prop_barrier_collision", true, 0.05},
    {"NHS Incident Ahead", "prop_barrier_nhsincident", true, 0.05},
    {"Diagonal Left", "prop_barrier_diagonalleft", true, 0.05},
    {"Diagonal Right", "prop_barrier_diagonalright", true, 0.05},
    {"Big Cone", "prop_roadcone01a", true},
    {"Gazebo", "prop_gazebo_02", true},
    {"Worklight", "prop_worklight_03b", true},
    {"Gate Barrier", "ba_prop_battle_barrier_02a", true},
    {"Fence Transparent", "prop_fncsec_03b", true, -0.45},
    {"Fence Hidden", "prop_fncsec_03d", true},
    {"Plastic Fence", "prop_barrier_work06a", true}
}
local l = {
    {bone = "wheel_lf", index = 0},
    {bone = "wheel_rf", index = 1},
    {bone = "wheel_lm", index = 2},
    {bone = "wheel_rm", index = 3},
    {bone = "wheel_lr", index = 4},
    {bone = "wheel_rr", index = 5}
}
local m = {}
for n, o in pairs(k) do
    m[n] = o[1]
end
local p
local q
local function r(s, t, u, v, w, x)
    local y = VICE.getPlayerPed()
    local z = GetEntityHeading(y)
    local A = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * (3.0 + h[d.seperation] * (x - 1))
    local B = VICE.loadModel(s)
    local C = CreateObject(B, A.x, A.y, A.z, w, false)
    if t then
        FreezeEntityPosition(C, true)
    end
    PlaceObjectOnGroundProperly(C)
    if u then
        local D = GetEntityCoords(C, true)
        SetEntityCoords(C, D.x, D.y, D.z + u, true, true, true, true)
    end
    SetEntityHeading(C, z + i[d.degrees])
    if v then
        SetEntityAlpha(C, v, false)
    end
    SetModelAsNoLongerNeeded(B)
    table.insert(b, C)
    return C
end
local function E()
    for F, s in pairs(d.previewObjects) do
        DeleteEntity(s)
    end
    d.previewObjects = {}
end
local function G()
    E()
    local H = k[d.object]
    local I = g[d.amount]
    for J = 1, I do
        local s = r(H[2], H[3], H[4], 155, false, J)
        table.insert(d.previewObjects, s)
    end
end

RageUI.CreateWhile(
    1.0,
    RMenu:Get("lfb", "main"),
    function()
        RageUI.IsVisible(
            RMenu:Get("lfb", "main"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Tools",
                    "View and use your LFB tools",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "tools")
                )
                RageUI.Button(
                    "Water",
                    "Manage your hose and water supply",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "water")
                )
                RageUI.Button(
                    "BA",
                    "Manage your BA",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "ba")
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "tools"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Setup Decontamination Tent",
                    "Setup a decontamination tent",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleDecontaminationTent(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove Decontamination Tent",
                    "Remove a decontamination tent",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleDecontaminationTent(false)
                        end
                    end
                )
                RageUI.Button(
                    "Setup Rescue Cushion",
                    "Setup a rescue cushion",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleRescueCushion(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove Rescue Cushion",
                    "Remove a rescue cushion",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleRescueCushion(false)
                        end
                    end
                )
                if a then
                    RageUI.Button(
                        "Remove Spreaders",
                        "Remove vehicle spreaders",
                        {RightLabel = ""},
                        true,
                        function(b, c, d)
                            if d then
                                handleSpreaders()
                            end
                        end
                    )
                else
                    RageUI.Button(
                        "Use Spreaders",
                        "Use vehicle spreaders",
                        {RightLabel = ""},
                        true,
                        function(b, c, d)
                            if d then
                                handleSpreaders()
                            end
                        end
                    )
                end
                RageUI.Button(
                    "Setup Stabilisers",
                    "Setup vehicle stabilisers",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleStabilisers(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove Stabilisers",
                    "Remove vehicle stabilisers",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleStabilisers(false)
                        end
                    end
                )
                RageUI.Button(
                    "Setup extractor fan",
                    "Setup an extractor fan",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleFan(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove extractor fan",
                    "Remove an extractor fan",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleFan(false)
                        end
                    end
                )
                RageUI.Button(
                    "Setup inflatable jack",
                    "Setup an inflatable jack",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleJack(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove inflatable jack",
                    "Remove an inflatable jack",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleJack(false)
                        end
                    end
                )
                RageUI.Button(
                    "Setup wheel chocks",
                    "Setup wheel chocks",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleChock(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove wheel chocks",
                    "Remove wheel chocks",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleChock(false)
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "water"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Get Fire Hose",
                    "Get a fire hose",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            GiveWeaponToPed(PlayerPedId(), "weapon_hose", 0, false, true)
                        end
                    end
                )
                RageUI.Button(
                    "Setup Supply Line",
                    "Setup a supply line",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleSupplyLine(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove Supply Line",
                    "Remove a supply line",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleSupplyLine(false)
                        end
                    end
                )
                RageUI.Button(
                    "Setup Water Monitor",
                    "Setup a water monitor",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleWaterMonitor(true)
                        end
                    end
                )
                RageUI.Button(
                    "Remove Water Monitor",
                    "Remove a water monitor",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            handleWaterMonitor(false)
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "ba"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Remove BA",
                    "Removes your BA",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            VICE.loadCustomisationPreset("NoBreathingApperatus")
                        end
                    end
                )
                RageUI.Button(
                    "BA Down",
                    "Puts your BA down",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            VICE.loadCustomisationPreset("BreathingApperatusDown")
                        end
                    end
                )
                RageUI.Button(
                    "BA Up",
                    "Puts your BA up",
                    {RightLabel = ""},
                    true,
                    function(b, c, d)
                        if d then
                            VICE.loadCustomisationPreset("BreathingApperatusUp")
                        end
                    end
                )
            end,
            function()
            end
        )
    end
)
local e = {fireType = 1, size = 1}
local f = {
    ["normal"] = {dict = "core", name = "ent_ray_meth_fires", smoke = false, smokeType = "normal", chance = 30},
    ["normal2"] = {
        dict = "scr_trevor3",
        name = "scr_trev3_trailer_plume",
        smoke = false,
        smokeType = "normal",
        chance = 30
    },
    ["bonfire"] = {
        dict = "scr_michael2",
        name = "scr_mich3_heli_fire",
        smoke = false,
        smokeType = "normal",
        chance = 20
    },
    ["chemical"] = {dict = "core", name = "fire_petroltank_truck", smoke = false, smokeType = "normal", chance = 20},
    ["electrical"] = {
        dict = "core",
        name = "fire_petroltank_truck",
        smoke = true,
        smokeType = "electrical",
        chance = 20
    }
}
local g = {}
for h, i in pairs(f) do
    table.insert(g, h)
end
local j = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0}
local k = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}
local l = true
local m = 8
local n = 5.0
local o = 5
local p = 8
RageUI.CreateWhile(
    1.0,
    RMenu:Get("lfb", "firemain"),
    function()
        RageUI.IsVisible(
            RMenu:Get("lfb", "firemain"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Start Fires",
                    "Start Fires",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "fire")
                )
                RageUI.Button(
                    "Call Settings",
                    "Manage fire call settings",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "settings")
                )
                RageUI.Button(
                    "Manage Fires",
                    "Manage Fires",
                    {RightBadge = RageUI.BadgeStyle.Key},
                    true,
                    function(b, c, d)
                    end,
                    RMenu:Get("lfb", "management")
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "settings"),
            true,
            false,
            true,
            function()
                RageUI.Checkbox(
                    "Toggle Automatic Fires",
                    "Toggle automatic fire calls",
                    l,
                    {},
                    function(b, d, c, q)
                        l = q
                    end
                )
                RageUI.List(
                    "Automatic Fires Size",
                    j,
                    o,
                    nil,
                    {},
                    true,
                    function(b, c, d, r)
                        if c then
                            o = r
                            n = j[o]
                        end
                    end
                )
                RageUI.List(
                    "Fire Cooldown (minutes)",
                    k,
                    p,
                    nil,
                    {},
                    true,
                    function(b, c, d, r)
                        if c then
                            p = r
                            m = k[p]
                        end
                    end
                )
                RageUI.Button(
                    "Save Options",
                    nil,
                    {},
                    true,
                    function(b, c, d)
                        if d then
                            TriggerServerEvent("VICE:updateFireOptions", l, n, m)
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "management"),
            true,
            false,
            true,
            function()
                RageUI.Button(
                    "Stop All Fires",
                    nil,
                    {},
                    function(b, c, d)
                        if d then
                            TriggerServerEvent("VICE:stopAllFires")
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("lfb", "fire"),
            true,
            false,
            true,
            function()
                RageUI.List(
                    "Fire Type",
                    g,
                    e.fireType,
                    nil,
                    {},
                    true,
                    function(b, c, d, r)
                        if c then
                            e.fireType = r
                        end
                    end
                )
                RageUI.List(
                    "Fire Size",
                    j,
                    e.size,
                    nil,
                    {},
                    true,
                    function(b, c, d, r)
                        if c then
                            e.size = r
                        end
                    end
                )
                RageUI.Button(
                    "Start Fire",
                    nil,
                    {},
                    true,
                    function(b, c, d)
                        if d then
                            local s = createFireId()
                            local t = VICE.getPlayerCoords()
                            local u = {coords = t, size = j[e.size], type = g[e.fireType], active = false}
                            TriggerServerEvent("VICE:updateFireTableServer", s, u, false, false, true)
                        end
                    end
                )
            end,
            function()
            end
        )
    end
)

RegisterNetEvent("VICE:setLFBOnDuty",function(value)
    globalLFBOnDuty = value
end)

RegisterNetEvent("VICE:toggleLFBMenu",function()
    if VICE.globalOnLFBDuty() then
        RageUI.Visible(RMenu:Get("lfb", "main"), not RageUI.Visible(RMenu:Get("lfb", "main")))
        RMenu:Get("lfb", "main"):SetSubtitle("~r~LFB")
    end
end)
TriggerServerEvent("VICE:receiveLFBTablesServer")
local v = {}
local w = {}
local x = {}
local y = {}
local z = {}
local A = {}
local B = {}
local C = {}
local D = {}
RegisterNetEvent(
    "VICE:updateFires",
    function()
        for h, i in pairs(v) do
            if i.active then
                removeFire(h)
            end
            v[h] = nil
        end
        v = {}
    end
)
local E = {["normal"] = {dict = "", name = ""}, ["electrical"] = {dict = "core", name = "ent_amb_elec_crackle"}}
function createFireId()
    return tVICE.generateUUID("fire", 20, "alphanumeric")
end
RegisterNetEvent("VICE:startFireMenu",function(F, G, H)
    RageUI.ActuallyCloseAll()
    RageUI.Visible(RMenu:Get("lfb", "tools"), false)
    RageUI.Visible(RMenu:Get("lfb", "main"), false)
    RageUI.Visible(RMenu:Get("lfb", "water"), false)
    RageUI.Visible(RMenu:Get("lfb", "fire"), false)
    RageUI.Visible(RMenu:Get("lfb", "management"), false)
    RageUI.Visible(RMenu:Get("lfb", "settings"), false)
    RageUI.Visible(RMenu:Get("lfb", "firemain"), true)
    l = F
    m = G
    n = H
end)

RegisterNetEvent("VICE:receiveLFBTables",function(I, J, K, L, M, N, O, P, Q)
    v = I
    w = J
    x = K
    y = L
    z = z
    A = N
    B = O
    C = P
    D = Q
    setupMonitors()
end)

RegisterNetEvent("VICE:updateFireTable",function(R, S, T, U)
    if T then
        if v[R] and v[R].active and v[R].active then
            removeFire(R)
        end
        v[R] = nil
        return
    end
    if U then
        if v[R] and S.size then
            v[R].size = S.size
        end
        if v[R] and v[R].active then
            updateFire(R)
        end
    else
        v[R] = S
    end
end)

function spawnFires()
    local t = VICE.getPlayerCoords()
    if v == nil then
        v = {}
    end
    for h, i in pairs(v) do
        local V = #(t - i.coords)
        if V < 350.0 then
            if i.active and not i.active then
                createFire(h)
            end
        else
            if i.active then
                removeFire(h)
            end
        end
    end
end
function createFire(R)
    v[R].active = true
    VICE.loadPtfx(f[v[R].type].dict)
    UseParticleFxAsset(f[v[R].type].dict)
    local W = {0.0, 0.0, 0.0}
    v[R].handle = StartParticleFxLoopedAtCoord(f[v[R].type].name,v[R].coords.x,v[R].coords.y,v[R].coords.z,W[1],W[2],W[3],v[R].size,false,false,false,false)
    if f[v[R].type].smoke then
        VICE.loadPtfx(E[f[v[R].type].smokeType].dict)
        UseParticleFxAsset(E[f[v[R].type].smokeType].dict)
        local W = {0.0, 0.0, 0.0}
        local H = v[R].size * 2
        v[R].smokeHandle =
            StartParticleFxLoopedAtCoord(E[f[v[R].type].smokeType].name,v[R].coords.x,v[R].coords.y,v[R].coords.z,W[1],W[2],W[3],H,false,false,false,false)
        RemoveNamedPtfxAsset(E[f[v[R].type].smokeType].dict)
    end
    RemoveNamedPtfxAsset(f[v[R].type].dict)
end
function updateFire(R)
    if v[R].handle and DoesParticleFxLoopedExist(v[R].handle) then
        SetParticleFxLoopedScale(v[R].handle, v[R].size)
    end
end
function removeFire(R)
    if v[R].handle then
        StopParticleFxLooped(v[R].handle, false)
    end
    if f[v[R].type].smoke and v[R].smokeHandle then
        StopParticleFxLooped(v[R].smokeHandle, false)
    end
    v[R].active = false
end
local X = false
local Y = 0
local Z = {}
local _ = 0
local a0 = false
local a1 = 12.0
local a2 = "prop_supplyline"
local a3 = {
    {model = "firetruk", bone = "", offSet = {2.0, -18.0, -0.75}, rotation = {0.0, 0.0, 180.0}},
    {model = "polrange", bone = "", offSet = {2.0, -18.0, -0.75}, rotation = {0.0, 0.0, 180.0}}
}
RegisterNetEvent("VICE:updateSupplyLineTable",function(R, S, T)
    if T then
        w[R] = nil
        return
    end
    w[R] = S
    if Z[R] then
        Z[R] = nil
    end
end)
function supplyLineRaycast()
    local a4 = VICE.getPlayerPed()
    local a5 = VICE.getPlayerCoords()
    local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 10.0, 0.0)
    local a7 = StartShapeTestCapsule(a5.x, a5.y, a5.z, a6.x, a6.y, a6.z, 10.0, 2, a4, 0)
    local a8, a9, aa, ab, ac = GetShapeTestResult(a7)
    return ac
end
function handleSupplyLine(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local ae = supplyLineRaycast()
    if ae ~= 0 and ae then
        local af = NetworkGetNetworkIdFromEntity(ae)
        local ag = false
        for h, i in pairs(w) do
            if i[1] == af then
                ag = true
            end
        end
        if ad then
            if ag then
                VICE.notify("Error~w~: A supply line is already setup on this vehicle")
            else
                local ah = GetEntityModel(ae)
                local R = 0
                local ai = false
                for h, i in pairs(a3) do
                    if i.model == ah then
                        R = h
                        ai = true
                        break
                    end
                end
                if ai then
                    FreezeEntityPosition(ae, true)
                    VICE.loadModel(a2)
                    local t = GetEntityCoords(ae)
                    local aj = CreateObject(a2, t.x, t.y, t.z, true, true, true)
                    while not DoesEntityExist(aj) do
                        Wait(0)
                    end
                    TriggerServerEvent("VICE:createLFBPropLog", "Supply Line", GetEntityCoords(aj, true))
                    local ak = GetEntityBoneIndexByName(ae, a3[R].bone)
                    FreezeEntityPosition(aj, true)
                    AttachEntityToEntity(aj,ae,ak,a3[R].offSet[1],a3[R].offSet[2],a3[R].offSet[3],a3[R].rotation[1],a3[R].rotation[2],a3[R].rotation[3],true,false,true,false,1,true)
                    Wait(1000)
                    local al = NetworkGetNetworkIdFromEntity(aj)
                    w[af] = {af, al, t}
                    TriggerServerEvent("VICE:updateSupplyLineTable", af, w[af], false)
                    SetModelAsNoLongerNeeded(a2)
                    VICE.notify("~g~Success~w~: Supply line setup")
                else
                    VICE.notify("Error~w~: You cannot setup a supply line on this vehicle")
                end
            end
        else
            if ag then
                TriggerServerEvent("VICE:updateSupplyLineTable", af, w[af], true)
                TriggerServerEvent("VICE:lfbDeleteSupplyLine", w[af][2])
                TriggerServerEvent("VICE:removeVehicleStablisers", af)
                w[af] = nil
                VICE.notify("~g~Success~w~: Supply line removed")
            else
                VICE.notify("~g~Success~w~: No supply line found")
            end
        end
    else
        VICE.notify("Error~w~: No vehicle found")
    end
end
local am = 200
local an = {}
local ao = "weapon_hose"
local ap = false
RegisterNetEvent("VICE:hoseUpdate",function(aq, ar, T)
    if T then
        if an[aq] then
            an[aq][3] = false
            if an[aq][4] then
                StopParticleFxLooped(an[aq][4], false)
            end
            if an[aq][5] then
                StopParticleFxLooped(an[aq][5], false)
            end
            if an[aq][6] then
                StopParticleFxLooped(an[aq][6], false)
            end
            an[aq] = nil
        end
    else
        an[aq] = {aq, ar, true, 0, 0, 0}
        hoseParticle(aq, ar)
    end
end)
Citizen.CreateThread(function()
    DecorRegister("HosePitch", 1)
    while true do
        local a4 = VICE.getPlayerPed()
        local ae = VICE.getPlayerVehicle()
        if globalLFBOnDuty then
            if ae == 0 then
                local as = GetSelectedPedWeapon(a4)
                if as == GetHashKey(ao) and IsPlayerFreeAiming(VICE.getPlayerId()) then
                    a0 = true
                    DisableControlAction(0, 24, true)
                    if IsDisabledControlPressed(0, 24) then
                        if _ > 0 or X then
                            handleHose()
                        else
                            VICE.notify("Notice~w~: You have no active supply of water")
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        spawnFires()
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        for h, i in pairs(an) do
            if i[3] then
                local ar = DecorGetFloat(VICE.getObjectId(i[1]), "HosePitch")
                if i[4] then
                    SetParticleFxLoopedOffsets(i[4], 0.26, 0.2, 0.13, ar, 0.0, 0.0)
                    SetParticleFxLoopedOffsets(i[5], 0.2, 9.5 + ar * 0.4, -0.6, ar, 0.0, 0.8)
                    SetParticleFxLoopedOffsets(i[6], 0.2, 5.0 + ar * 0.4, ar - 23.0, ar, 0.0, 0.0)
                end
            end
        end
        Wait(0)
    end
end)

function hoseParticle(aq, ar)
    local at = VICE.getObjectId(an[aq][1], "hoseParticle")
    local t = GetEntityCoords(at)
    if #(VICE.getPlayerCoords() - t) < 100.0 and GetSelectedPedWeapon(at) == GetHashKey(ao) then
        VICE.loadPtfx("core")
        UseParticleFxAsset("core")
        an[aq][4] = StartParticleFxLoopedOnEntity("water_cannon_jet",at,0.2,0.15,0.0,0.1,0.0,0.0,0.7,false,false,false)
        UseParticleFxAsset("core")
        an[aq][5] = StartParticleFxLoopedOnEntity("water_cannon_spray",at,0.2,9.0 + an[aq][2] * 0.4,0,0.1,0.0,0.0,0.9,false,false,false)
        UseParticleFxAsset("core")
        an[aq][6] = StartParticleFxLoopedOnEntity("water_cannon_spray",at,0.2,9.0 + an[aq][2] * 0.4,0,0.1,0.0,0.0,0.001,false,false,false)
        RemoveNamedPtfxAsset("core")
    end
end
function handleHose()
    local a4 = VICE.getPlayerPed()
    local aq = VICE.getNetId(a4, "handleHose()")
    TriggerServerEvent("VICE:hoseUpdateServer", aq, 0.0, false)
    ap = true
    while ap do
        DisableControlAction(0, 24, true)
        DecorSetFloat(a4, "HosePitch", GetGameplayCamRelativePitch())
        DisablePlayerFiring(VICE.getPlayerId(), true)
        putOutFires()
        if not IsDisabledControlPressed(0, 24) or VICE.getPlayerVehicle() ~= 0 or IsPauseMenuActive() or GetSelectedPedWeapon(a4) ~= GetHashKey(ao) or not IsPlayerFreeAiming(VICE.getPlayerId()) or not X and _ < 1 then
            ap = false
            TriggerServerEvent("VICE:hoseUpdateServer", aq, 0.0, true)
        end
        Wait(0)
    end
end
local au = 30.0
function putOutFires()
    local t = VICE.getPlayerCoords()
    for h, i in pairs(v) do
        if i.active and #(t - i.coords) < au then
            local a6 = GetOffsetFromEntityInWorldCoords(VICE.getPlayerPed(), 0.0, 3.0, 0.5)
            if #(a6 - i.coords) < 7.0 then
                local av = math.random(1, f[i.type].chance)
                if av == 1 then
                    local H = i.size * 0.92
                    if H < 0.5 then
                        TriggerServerEvent("VICE:updateFireTableServer", h, v[h], true, false)
                        Wait(5000)
                    else
                        v[h].size = H
                        TriggerServerEvent("VICE:updateFireTableServer", h, v[h], false, true)
                        Wait(5000)
                    end
                    break
                end
            end
        end
    end
end
local aw = {}
function setupMonitors()
    for h, i in pairs(x) do
        if x[h][4] then
            UseParticleFxAsset("core")
            SetParticleFxShootoutBoat(1)
            local t = x[h][2]
            aw[h] = {}
            aw[h].handle = StartParticleFxLoopedAtCoord("water_cannon_jet",t.x + 0.0,t.y + 0.0,t.z + 0.7,50.0,0.0,x[h][3],1.0,false,false,false,false)
            aw[h].handle2 = StartParticleFxLoopedAtCoord("water_cannon_spray",t.x + 0.0,t.y + 0.0,t.z + 0.7,50.0,0.0,x[h][3],1.0,false,false,false,false)
            aw[h].pitch = 50.0
        end
    end
end
RegisterNetEvent("VICE:updateMonitorsTable",function(R, S, T)
    if T then
        x[R] = nil
        return
    end
    x[R] = S
end)

RegisterNetEvent("VICE:toggleWaterClient",function(R)
    if x[R] then
        x[R][4] = not x[R][4]
    end
    if aw[R] and aw[R].handle and DoesParticleFxLoopedExist(aw[R].handle) then
        StopParticleFxLooped(aw[R].handle, false)
        StopParticleFxLooped(aw[R].handle2, false)
        aw[R] = nil
    end
    if x[R][4] then
        VICE.loadPtfx("core")
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        local t = x[R][2]
        aw[R] = {}
        aw[R].pitch = 50.0
        aw[R].handle = StartParticleFxLoopedAtCoord("water_cannon_jet",t.x,t.y,t.z,50.0,0.0,x[R][3],1.0,false,false,false,false)
        aw[R].handle2 = StartParticleFxLoopedAtCoord("water_cannon_spray",t.x,t.y,t.z,50.0,0.0,x[R][3],1.0,false,false,false,false)
        RemoveNamedPtfxAsset("core")
    end
end)
local ax = "prop_water_monitor"
function handleWaterMonitor(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local t = VICE.getPlayerCoords()
    if ad then
        VICE.loadModel(ax)
        local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 1.5, 0.0)
        local aj = CreateObject(ax, a6.x, a6.y, a6.z, true, true, true)
        while not DoesEntityExist(aj) do
            Wait(0)
        end
        TriggerServerEvent("VICE:createLFBPropLog", "Water Monitor", GetEntityCoords(aj, true))
        SetEntityCollision(aj, false, true)
        local al = NetworkGetNetworkIdFromEntity(aj)
        PlaceObjectOnGroundProperly(aj)
        FreezeEntityPosition(aj, true)
        SetEntityHeading(aj, GetEntityHeading(a4))
        a6 = GetOffsetFromEntityInWorldCoords(aj, 0.10, 0.22, 0.70)
        x[al] = {al, a6, GetEntityHeading(aj), false, false}
        TriggerServerEvent("VICE:updateMonitorsTable", al, x[al], false)
        SetModelAsNoLongerNeeded(ax)
        VICE.notify("~g~Success~w~: Water monitor setup")
    else
        local ai = false
        local ay = 0
        for h, i in pairs(x) do
            local V = #(t - i[2])
            if V < 15.0 then
                ay = h
                ai = true
                break
            end
        end
        if ai then
            if x[ay][4] then
                VICE.notify("Error~w~: This monitor is active and cannot be removed")
            else
                local aj = VICE.getObjectId(x[ay][1], "handleWaterMonitor")
                TriggerServerEvent("VICE:updateMonitorsTable", ay, x[ay], true)
                if DoesEntityExist(aj) then
                    DeleteEntity(aj)
                end
                x[ay] = nil
                VICE.notify("~g~Success~w~: Water monitor removed")
            end
        else
            VICE.notify("Error~w~: No water monitor found")
        end
    end
end
RegisterNetEvent("VICE:adjustPitchClient",function(R, az)
    if aw[R] and aw[R].handle and DoesParticleFxLoopedExist(aw[R].handle) then
        local t = x[R][2]
        StopParticleFxLooped(aw[R].handle, false)
        StopParticleFxLooped(aw[R].handle2, false)
        aw[R].pitch = aw[R].pitch + az
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(0)
        end
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        aw[R].handle = StartParticleFxLoopedAtCoord("water_cannon_jet",t.x,t.y,t.z,aw[R].pitch,0.0,x[R][3],1.0,false,false,false,false)
        aw[R].handle2 = StartParticleFxLoopedAtCoord("water_cannon_spray",t.x,t.y,t.z,aw[R].pitch,0.0,x[R][3],1.0,false,false,false,false)
        RemoveNamedPtfxAsset("core")
    end
end)
local aA = 5.0
local aB = 5.0
local aC = 3
Citizen.CreateThread(function()
    while true do
        if globalLFBOnDuty then
            local a4 = VICE.getPlayerPed()
            local t = VICE.getPlayerCoords()
            for h, i in pairs(x) do
                if not i[5] then
                    local V = #(t - i[2])
                    if V < aA then
                        if V < aB then
                            if i[4] then
                                DisableControlAction(0, 172, true)
                                DisableControlAction(0, 173, true)
                                local az = 0.0
                                if IsDisabledControlPressed(0, 172) then
                                    az = az + 15.0
                                end
                                if IsDisabledControlPressed(0, 173) then
                                    az = az - 15.0
                                end
                                if az ~= 0.0 then
                                    TriggerServerEvent("VICE:adjustPitchServer", h, az)
                                    Wait(1000)
                                end
                                DisableControlAction(0, 38, true)
                                if IsDisabledControlPressed(0, 38) then
                                    pressed = true
                                    TriggerServerEvent("VICE:toggleWaterServer", h)
                                    VICE.notify("~g~Success~w~: Water monitor toggled")
                                    Wait(aC * 1000)
                                end
                            else
                                if supplyLineNearby(t) then
                                    DisableControlAction(0, 38, true)
                                    if IsDisabledControlPressed(0, 38) then
                                        TriggerServerEvent("VICE:toggleWaterServer", h)
                                        VICE.notify("~g~Success~w~: Water monitor toggled")
                                        Wait(aC * 1000)
                                    end
                                else
                                    VICE.notify("Error~w~: No active supply line found to enable this water monitor")
                                end
                            end
                        else
                            if supplyLineNearby(t) then
                                local aD = false
                                local pressed = false
                                while not aD do
                                    DisableControlAction(0, 38, true)
                                    if IsDisabledControlPressed(0, 38) then
                                        pressed = true
                                        aD = true
                                    end
                                    Wait(0)
                                end
                                if pressed then
                                    TriggerServerEvent("VICE:toggleWaterServer", h)
                                    VICE.notify("~g~Success~w~: Water monitor toggled")
                                    Wait(aC * 1000)
                                end
                            else
                                VICE.notify("Error~w~: No active supply line found to enable this water monitor")
                                if i[4] then
                                    DisableControlAction(0, 38, true)
                                    if IsDisabledControlPressed(0, 38) then
                                        pressed = true
                                        TriggerServerEvent("VICE:toggleWaterServer", h)
                                        VICE.notify("~g~Success~w~: Water monitor toggled")
                                        Wait(aC * 1000)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)

function supplyLineNearby(t)
    for h, i in pairs(w) do
        local V = #(t - i[3])
        if V < 25.0 then
            return true
        end
    end
    return false
end
local aE = 0
Citizen.CreateThread(function()
    while true do
        if not globalLFBOnDuty then
            a0 = false
        end
        if a0 then
            if ap then
                if not X then
                    if _ < 1 then
                        _ = 0
                        VICE.notify("Notice~w~: You have no active supply of water")
                    end
                    _ = _ - 1
                end
                Wait(1000)
            end
            aE = _ / am * 100
            aE = math.floor(aE + 0.5)
            if aE == -1 then
                aE = 0
            end
            if not X then
                local t = VICE.getPlayerCoords()
                if VICE.getPlayerVehicle() == 0 then
                    local ae = supplyLineRaycast()
                    local ai = false
                    for h, i in pairs(w) do
                        local V = #(t - i[3])
                        if V < a1 then
                            local aF = false
                            Citizen.SetTimeout(5000,function()
                                aF = true
                            end)
                            drawNativeNotification("Press ~INPUT_FRONTEND_RDOWN~ to connect to this vehicle")
                            while not aF do
                                DisableControlAction(0, 191, true)
                                if IsDisabledControlJustPressed(0, 191) then
                                    X = true
                                    Y = h
                                    VICE.notify("~g~Success~w~: You are now connected to this vehicle")
                                    aF = true
                                    _ = am
                                    break
                                end
                                Wait(0)
                            end
                        end
                    end
                    if not X then
                        if ae ~= 0 and ae then
                            local ah = GetEntityModel(ae)
                            local aG = false
                            for h, i in pairs(a3) do
                                if i.model == ah then
                                    aG = true
                                    break
                                end
                            end
                            if aG then
                                local af = NetworkGetNetworkIdFromEntity(ae)
                                local aH = false
                                for h in pairs(Z) do
                                    if af == Z[h] then
                                        aH = true
                                    end
                                end
                                if not aH then
                                    if _ < 1 then
                                        _ = am
                                        Z[af] = af
                                        Citizen.SetTimeout(180000,function()
                                            Z[af] = nil
                                        end)
                                        VICE.notify("~g~Success~w~: You now have a limited supply of water from the nearest vehicle")
                                    end
                                else
                                    if _ < 1 then
                                        VICE.notify("Notice~w~: This vehicle has already supplied you with water, setup a supply line for more")
                                        Wait(5000)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                if Y ~= 0 then
                    if w[Y] == nil then
                        VICE.notify("Notice~w~: You have now been disconnected from the supply line")
                        X = false
                    end
                end
                if X then
                    local t = VICE.getPlayerCoords()
                    local V = #(t - w[Y][3])
                    if V > 200.0 then
                        X = false
                        Y = 0
                        VICE.notify("Notice~w~: You have now been disconnected from the supply line")
                    end
                end
            end
        end
        Wait(1000)
    end
end)
function func_displayHoseLeft()
    if a0 then
        drawNativeText("Supply Line~w~: " .. tostring(aE) .. "/100 %")
    end
end
VICE.createThreadOnTick(func_displayHoseLeft)
local aI = {}
local aJ = 2.0
RegisterNetEvent("VICE:toggleWaterTents",function(R)
    if y[R] then
        y[R][8] = not y[R][8]
    end
    if aI[R] and aI[R].handle and DoesParticleFxLoopedExist(aI[R].handle) then
        StopParticleFxLooped(aI[R].handle, false)
        StopParticleFxLooped(aI[R].handle2, false)
        StopParticleFxLooped(aI[R].handle3, false)
        StopParticleFxLooped(aI[R].handle4, false)
        aI[R] = nil
    end
    if y[R] and y[R][8] then
        VICE.loadPtfx("core")
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        aI[R] = {}
        aI[R].handle = StartParticleFxLoopedAtCoord("water_cannon_jet",y[R][3].x,y[R][3].y,y[R][3].z,-90.0,0.0,0.0,aJ,false,false,false,false)
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        aI[R].handle2 = StartParticleFxLoopedAtCoord("water_cannon_jet",y[R][4].x,y[R][4].y,y[R][4].z,-90.0,0.0,0.0,aJ,false,false,false,false)
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        aI[R].handle3 = StartParticleFxLoopedAtCoord("water_cannon_jet",y[R][5].x,y[R][5].y,y[R][5].z,-90.0,0.0,0.0,aJ,false,false,false,false)
        UseParticleFxAsset("core")
        SetParticleFxShootoutBoat(1)
        aI[R].handle4 = StartParticleFxLoopedAtCoord("water_cannon_jet",y[R][6].x,y[R][6].y,y[R][6].z,-90.0,0.0,0.0,aJ,false,false,false,false)
        RemoveNamedPtfxAsset("core")
    end
end)
local aK = "prop_decon_tent"
function handleDecontaminationTent(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local t = VICE.getPlayerCoords()
    if ad then
        VICE.loadModel(aK)
        local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 5.0, 0.0)
        local aj = CreateObject(aK, a6.x, a6.y, a6.z, true, true, true)
        while not DoesEntityExist(aj) do
            Wait(0)
        end
        TriggerServerEvent("VICE:createLFBPropLog", "Decontamination Tent", GetEntityCoords(aj, true))
        local al = NetworkGetNetworkIdFromEntity(aj)
        PlaceObjectOnGroundProperly(aj)
        FreezeEntityPosition(aj, true)
        SetEntityHeading(aj, GetEntityHeading(a4))
        local aL = GetOffsetFromEntityInWorldCoords(aj, -1.75, 0.0, 2.9)
        local aM = GetOffsetFromEntityInWorldCoords(aj, -0.63, 0.0, 2.9)
        local aN = GetOffsetFromEntityInWorldCoords(aj, 0.63, 0.0, 2.9)
        local aO = GetOffsetFromEntityInWorldCoords(aj, 1.75, 0.0, 2.9)
        y[al] = {al, a6, aL, aM, aN, aO, GetEntityHeading(aj), false}
        TriggerServerEvent("VICE:updateTentsTable", al, y[al], false)
        SetModelAsNoLongerNeeded(aK)
        VICE.notify("~g~Success~w~: Decontamination tent setup")
    else
        local ai = false
        local ay = 0
        for h, i in pairs(y) do
            local V = #(t - i[2])
            if V < 25.0 then
                ay = h
                ai = true
                break
            end
        end
        if ai then
            if y[ay][8] then
                VICE.notify("Error~w~: This decontamination tent is active and cannot be removed")
            else
                local aj = VICE.getObjectId(y[ay][1], "handleDecontaminationTent")
                TriggerServerEvent("VICE:updateTentsTable", ay, y[ay], true)
                if DoesEntityExist(aj) then
                    DeleteEntity(aj)
                end
                y[ay] = nil
                VICE.notify("~g~Success~w~: Decontamination tent removed")
            end
        else
            VICE.notify("Error~w~: No decontamination tent found")
        end
    end
end
RegisterNetEvent("VICE:updateTentsTable",function(R, S, T)
    if T then
        y[R] = nil
        return
    end
    y[R] = S
end)
local aP = 15.0
local aQ = 3
Citizen.CreateThread(function()
    while true do
        if globalLFBOnDuty then
            local a4 = VICE.getPlayerPed()
            local t = VICE.getPlayerCoords()
            for h, i in pairs(y) do
                local V = #(t - i[2])
                if V < aP then
                    drawNativeNotification("Press ~INPUT_PICKUP~ to toggle the ~b~decontamination showers")
                    DisableControlAction(0, 38, true)
                    if IsDisabledControlPressed(0, 38) then
                        TriggerServerEvent("VICE:toggleWaterTents", h)
                        VICE.notify("~g~Success~w~: Decontamination showers toggled")
                    end
                end
            end
        end
        Wait(0)
    end
end)

RegisterNetEvent("VICE:updateCushionsTable",function(R, S, T)
    if T then
        z[R] = nil
        return
    end
    z[R] = S
end)
local aR = "prop_rescue_cushion"
function handleRescueCushion(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local t = VICE.getPlayerCoords()
    if ad then
        VICE.loadModel(aR)
        local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 1.5, 0.0)
        local aj = CreateObject(aR, a6.x, a6.y, a6.z, true, true, true)
        while not DoesEntityExist(aj) do
            Wait(0)
        end
        TriggerServerEvent("VICE:createLFBPropLog", "Rescue Cushion", GetEntityCoords(aj, true))
        SetEntityCollision(aj, false, true)
        PlaceObjectOnGroundProperly(aj)
        FreezeEntityPosition(aj, true)
        while NetworkGetNetworkIdFromEntity(aj) == 0 do
            Wait(0)
        end
        local al = NetworkGetNetworkIdFromEntity(aj)
        z[al] = {al, a6}
        TriggerServerEvent("VICE:updateCushionsTable", al, z[al], false)
        SetModelAsNoLongerNeeded(aR)
        VICE.notify("~g~Success~w~: Rescue cushion setup")
    else
        local ai = false
        local ay = 0
        for h, i in pairs(z) do
            local V = #(t - i[2])
            if V < 15.0 then
                ay = h
                ai = true
                break
            end
        end
        if ai then
            TriggerServerEvent("VICE:deleteProp", z[ay][1])
            local aj = VICE.getObjectId(z[ay][1], "handleRescueCushion")
            TriggerServerEvent("VICE:updateCushionsTable", ay, z[ay], true)
            if DoesEntityExist(aj) then
                DeleteEntity(aj)
            end
            z[ay] = nil
            VICE.notify("~g~Success~w~: Rescue cushion removed")
        else
            VICE.notify("Error~w~: No rescue cushion found")
        end
    end
end
local aS = false
local aT = 10
local aU = 60
Citizen.CreateThread(function()
    while true do
        if not aS then
            if table.count(z) > 0 then
                local a4 = VICE.getPlayerPed()
                local ae = VICE.getPlayerVehicle()
                if ae == 0 then
                    local t = VICE.getPlayerCoords()
                    local ai = false
                    for h, i in pairs(z) do
                        local V = #(t - vector3(i[2].x, i[2].y, t.z))
                        if V < 20.0 then
                            ai = true
                            if GetEntityHeightAboveGround(a4) >= 2.0 then
                                SetPlayerFallDistance(VICE.getPlayerId(), 250.0)
                                heightSet = true
                            else
                                SetPlayerFallDistance(VICE.getPlayerId(), 5.0)
                            end
                        else
                            SetPlayerFallDistance(VICE.getPlayerId(), 5.0)
                        end
                        if V < 12.0 then
                            if IsPedFalling(a4) then
                                SetEntityInvincible(a4, true)
                                local aD = false
                                Citizen.SetTimeout(
                                    7000,
                                    function()
                                        aD = true
                                    end
                                )
                                while not aD do
                                    if not IsPedFalling(a4) then
                                        Wait(500)
                                        aD = true
                                    end
                                    Wait(0)
                                end
                                SetEntityInvincible(a4, false)
                                local V = #(VICE.getPlayerCoords() - i[2])
                                if V < 4.0 then
                                    SetPedToRagdoll(a4, aT * 1000, aT * 1000, 0, 0, 0, 0)
                                end
                                heightSet = false
                                SetPlayerFallDistance(VICE.getPlayerId(), 5.0)
                                aS = true
                                Citizen.SetTimeout(
                                    aU * 1000,
                                    function()
                                        aS = false
                                    end
                                )
                            end
                        end
                    end
                    if not ai then
                        if heightSet then
                            SetPlayerFallDistance(VICE.getPlayerId(), 5.0)
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end
)
RegisterNetEvent("VICE:updateStabilisersTable",function(R, S, T)
    if T then
        A[R] = nil
        return
    end
    A[R] = S
end)
RegisterNetEvent("VICE:updateFansTable",function(R, S, T)
    if T then
        B[R] = nil
        return
    end
    B[R] = S
end)
RegisterNetEvent("VICE:stopRtcParticles",function(t)
    Wait(20 * 1000)
end)
local aV = "prop_spreaders"
local aW = 0
function handleSpreaders()
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    if not a then
        VICE.loadModel(aV)
        VICE.loadAnimDict("weapons@heavy@minigun")
        TaskPlayAnim(a4, "weapons@heavy@minigun", "idle_2_aim_right_med", -8.0, 8.0, -1, 50, 8.0, false, false, false)
        RemoveAnimDict("weapons@heavy@minigun")
        local t = VICE.getPlayerCoords()
        local aj = CreateObject(aV, t.x, t.y, t.z, true, true, true)
        TriggerServerEvent("VICE:createLFBPropLog", "Rescue Cushion", GetEntityCoords(aj, true))
        aW = aj
        SetEntityCollision(aj, false, true)
        local aX = GetPedBoneIndex(a4, 57005)
        AttachEntityToEntity(aj, a4, aX, 1.0, 0.4, 0.7, 0.0, 220.0, 200.0, true, true, true, true, 1, true)
        SetModelAsNoLongerNeeded(aV)
        a = true
        continueSpreaders()
    else
        a = false
        if DoesEntityExist(aW) then
            TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(aW))
            DetachEntity(a4)
            DetachEntity(aW)
            DeleteEntity(aW)
            ClearPedTasks(a4)
        end
    end
end
function spreadersRaycast()
    local a4 = VICE.getPlayerPed()
    local a5 = VICE.getPlayerCoords()
    local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 8.0, 0.0)
    local a7 = StartShapeTestCapsule(a5.x, a5.y, a5.z, a6.x, a6.y, a6.z, 10.0, 2, a4, 0)
    local a8, a9, aa, ab, ac = GetShapeTestResult(a7)
    return ac
end
function continueSpreaders()
    Citizen.CreateThread(
        function()
            local aY = "door_dside_f"
            local aZ = "door_dside_r"
            local a_ = "door_pside_f"
            local b0 = "door_pside_r"
            local b1 = "boot"
            while a do
                local a4 = VICE.getPlayerPed()
                local t = VICE.getPlayerCoords()
                local ae = spreadersRaycast()
                if ae ~= 0 and ae then
                    drawNativeText("Error~w~: No vehicle found")
                    local b2 = GetEntityBoneIndexByName(ae, aY)
                    local b3 = GetEntityBoneIndexByName(ae, aZ)
                    local b4 = GetEntityBoneIndexByName(ae, a_)
                    local b5 = GetEntityBoneIndexByName(ae, b0)
                    local b6 = GetEntityBoneIndexByName(ae, b1)
                    local ak = {}
                    ak[1] = {GetWorldPositionOfEntityBone(ae, b2)}
                    ak[2] = {GetWorldPositionOfEntityBone(ae, b3)}
                    ak[3] = {GetWorldPositionOfEntityBone(ae, b4)}
                    ak[4] = {GetWorldPositionOfEntityBone(ae, b5)}
                    ak[5] = {GetWorldPositionOfEntityBone(ae, b6)}
                    ak[1][2] = 0
                    ak[2][2] = 2
                    ak[3][2] = 1
                    ak[4][2] = 3
                    ak[4][2] = 5
                    local b7 = 1
                    local b8 = 0.0
                    for b9 = 1, 5 do
                        local V = #(t - ak[b9][1])
                        if b8 == 0.0 then
                            b8 = V
                        else
                            if V < b8 then
                                b8 = V
                                b7 = b9
                            end
                        end
                        b9 = b9 + 1
                    end
                    drawNativeText("Vehicle ~g~door found")
                    local aD = false
                    Citizen.SetTimeout(
                        5000,
                        function()
                            aD = true
                        end
                    )
                    drawNativeNotification("Press ~b~ENTER ~w~to open or ~b~SPACE~w~ to break the vehicle door")
                    while not aD do
                        DisableControlAction(0, 191)
                        DisableControlAction(0, 22)
                        if IsDisabledControlJustPressed(0, 22) then
                            local ba = NetworkGetNetworkIdFromEntity(ae)
                            TriggerServerEvent("VICE:rtcOpenDoor", ba, ak[b7][2], VICE.getPlayerCoords(), true)
                            aD = true
                        end
                        if IsDisabledControlJustPressed(0, 191) then
                            local ba = NetworkGetNetworkIdFromEntity(ae)
                            TriggerServerEvent("VICE:rtcOpenDoor", ba, ak[b7][2], VICE.getPlayerCoords(), false)
                            aD = true
                        end
                        Wait(0)
                    end
                else
                    drawNativeText("Vehicle not found")
                end
                Wait(100)
            end
        end
    )
end
RegisterNetEvent("VICE:rtcOpenDoor",function(ba, ak, t, bb)
    local ae = VICE.getObjectId(ba, "VICE:rtcOpenDoor")
    if DoesEntityExist(ae) then
        if bb then
            SetVehicleDoorOpen(ae, ak, false, true)
            SetVehicleDoorBroken(ae, ak, false)
        else
            SetVehicleDoorOpen(ae, ak, false, true)
        end
    end
end)
RegisterNetEvent("VICE:spreadersSound",function(t)
    local bc = VICE.getPlayerCoords()
    local V = #(t - bc)
    if V < 15.0 then
        SendNUIMessage({transactionType = "spreader"})
    end
end)
function tableHas(table, R)
    for h in pairs(table) do
        if h == R then
            return true
        end
    end
    return false
end
local bd = "prop_stabilisers"
function handleStabilisers(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local ae = spreadersRaycast()
    if ae ~= 0 and ae then
        local af = NetworkGetNetworkIdFromEntity(ae)
        local ag = tableHas(A, af)
        if ad then
            if ag then
                VICE.notify("Error~w~: Stabilisers are already setup on this vehicle")
            else
                FreezeEntityPosition(ae, true)
                VICE.loadModel(bd)
                local t = GetEntityCoords(ae)
                local be = GetOffsetFromEntityInWorldCoords(a4, -0.7, 1.0, 0.0)
                local aj = CreateObject(bd, be.x, be.y, be.z, true, true, true)
                while not DoesEntityExist(aj) do
                    Wait(0)
                end
                TriggerServerEvent("VICE:createLFBPropLog", "Vehicle Stablisers", GetEntityCoords(aj, true))
                SetEntityCollision(aj, false, true)
                local bf = GetOffsetFromEntityInWorldCoords(a4, -0.7, 0.0, 0.0)
                local bg = CreateObject(bd, bf.x, bf.y, bf.z, true, true, true)
                SetEntityCollision(bg, false, true)
                while not DoesEntityExist(aj) or not DoesEntityExist(bg) do
                    Wait(0)
                end
                local bh = GetEntityHeading(a4)
                SetEntityHeading(aj, bh)
                SetEntityHeading(bg, bh)
                local bi = GetEntityCoords(aj)
                local a8, bj = GetGroundZFor_3dCoord(bi.x, bi.y + 0.9, bi.z - 0.3, 0)
                SetEntityCoords(aj, bi.x, bi.y, bj, true, true, true, false)
                local bk = GetEntityCoords(bg)
                a8, bj = GetGroundZFor_3dCoord(bk.x, bk.y + 0.9, bk.z - 0.3, 0)
                SetEntityCoords(bg, bk.x, bk.y, bj, true, true, true, false)
                PlaceObjectOnGroundProperly(aj)
                PlaceObjectOnGroundProperly(bg)
                FreezeEntityPosition(aj, true)
                FreezeEntityPosition(bg, true)
                local al = NetworkGetNetworkIdFromEntity(aj)
                local bl = NetworkGetNetworkIdFromEntity(bg)
                A[af] = {af, al, bl}
                TriggerServerEvent("VICE:updateStabilisersTable", af, A[af], false)
                SetModelAsNoLongerNeeded(bd)
                VICE.notify("~g~Success~w~: Stabilisers setup")
            end
        else
            if ag then
                local aj = VICE.getObjectId(A[af][2], "handleStabilisers 1")
                local bg = VICE.getObjectId(A[af][3], "handleStabilisers 2")
                TriggerServerEvent("VICE:updateStabilisersTable", af, A[af], true)
                if DoesEntityExist(aj) then
                    TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(aj))
                    DeleteEntity(aj)
                end
                if DoesEntityExist(bg) then
                    TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(bg))
                    DeleteEntity(bg)
                end
                TriggerServerEvent("VICE:removeVehicleStablisers", af)
                A[af] = nil
                VICE.notify("~g~Success~w~: Stabilisers removed")
            else
                VICE.notify("Error~w~: No stabilisers found")
            end
        end
    else
        VICE.notify("Error~w~: No vehicle found")
    end
end
RegisterNetEvent("VICE:removeVehicleStablisers",function(bm)
    if NetworkDoesNetworkIdExist(bm) then
        local ae = NetworkGetEntityFromNetworkId(bm)
        FreezeEntityPosition(ae, false)
        DetachEntity(ae)
    end
end)
local bn = "prop_fan_fire"
function handleFan(ad)
    local a4 = VICE.getPlayerPed()
    local ae = VICE.getPlayerVehicle()
    if ae ~= 0 then
        VICE.notify("Error~w~: You must not be inside a vehicle")
        return
    end
    local t = VICE.getPlayerCoords()
    if ad then
        VICE.loadModel(bn)
        local a6 = GetOffsetFromEntityInWorldCoords(a4, 0.0, 1.6, 0.0)
        local aj = CreateObject(bn, a6.x, a6.y, a6.z, true, true, true)
        while not DoesEntityExist(aj) do
            Wait(0)
        end
        TriggerServerEvent("VICE:createLFBPropLog", "Extractor Fan", GetEntityCoords(aj, true))
        SetEntityCollision(aj, false, true)
        local al = NetworkGetNetworkIdFromEntity(aj)
        PlaceObjectOnGroundProperly(aj)
        FreezeEntityPosition(aj, true)
        B[al] = {al, a6}
        TriggerServerEvent("VICE:updateFansTable", al, B[al], false)
        SetModelAsNoLongerNeeded(bn)
        VICE.notify("~g~Success~w~: Fan setup")
        TriggerServerEvent("VICE:stopRtcParticles", t)
    else
        local ai = false
        local ay = 0
        for h, i in pairs(B) do
            local V = #(t - i[2])
            if V < 15.0 then
                ay = h
                ai = true
                break
            end
        end
        if ai then
            local aj = VICE.getObjectId(B[ay][1], "handleFan")
            TriggerServerEvent("VICE:updateFansTable", ay, B[ay], true)
            if DoesEntityExist(aj) then
                TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(aj))
                DeleteEntity(aj)
            end
            B[ay] = nil
            VICE.notify("~g~Success~w~: Fan removed")
        else
            VICE.notify("Error~w~: No fan found")
        end
    end
end
local bo = false
local bp = 0
Citizen.CreateThread(function()
    while true do
        local a4 = VICE.getPlayerPed()
        local t = VICE.getPlayerCoords()
        if bo then
            if B[bp] and B[bp][2] then
                local V = #(t - B[bp][2])
                if V > 20.0 then
                    bo = false
                else
                    SendNUIMessage({transactionType = "fan"})
                    Wait(10000)
                end
            end
        else
            for h, i in pairs(B) do
                local V = #(t - B[h][2])
                if V < 20.0 then
                    bo = true
                    bp = h
                    SendNUIMessage({transactionType = "fan"})
                    Wait(10000)
                end
            end
        end
        Wait(2000)
    end
end)
RegisterNetEvent("VICE:updateJackTable",function(R, S, T)
    if T then
        C[R] = nil
        return
    end
    C[R] = S
end)
RegisterNetEvent("VICE:updateChockTable",function(R, S, T)
    if T then
        D[R] = nil
        return
    end
    D[R] = S
end)
RegisterNetEvent("VICE:toggleChockWheels",function(af)
    local ae = VICE.getObjectId(af, "VICE:toggleChockWheels")
    if DoesEntityExist(ae) then
        ResetVehicleWheels(ae, true)
    end
end)
local bq = "prop_inflatable_jack"
function handleJack(ad)
    local ae = spreadersRaycast()
    if ae ~= 0 and ae then
        local af = NetworkGetNetworkIdFromEntity(ae)
        local ag = tableHas(C, af)
        local br = false
        if ag then
            br = C[af][5]
        end
        if usingCarJack then
            VICE.notify("Error~w~: You are currently using a jack. Press ENTER to stop.")
            return
        end
        if ad then
            if ag then
                if not br then
                    C[af][5] = true
                    TriggerServerEvent("VICE:updateJackTable", af, C[af], false)
                    local bs = VICE.getObjectId(C[af][2], "handleJack 1")
                    local bt = VICE.getObjectId(C[af][3], "handleJack 2")
                    TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(bs))
                    VICE.notify("~g~Success~w~: You're now controlling the inflatable jack")
                    handleLifting(ae, af, bs)
                else
                    VICE.notify("Error~w~: This inflatable jack is in use")
                end
            else
                local bu = GetOffsetFromEntityInWorldCoords(ae, -0.7, 0.0, 0.0)
                local bv = GetOffsetFromEntityInWorldCoords(ae, 0.7, 0.0, 0.0)
                VICE.loadModel(bq)
                local bs = CreateObject(bq, bu.x, bu.y, bu.z, true, true, true)
                local bt = CreateObject(bq, bv.x, bv.y, bv.z, true, true, true)
                while not DoesEntityExist(bs) or not DoesEntityExist(bt) do
                    Wait(0)
                end
                TriggerServerEvent("VICE:createLFBPropLog", "Inflatable Jack", GetEntityCoords(bs, true))
                local bh = GetEntityHeading(ae)
                SetEntityHeading(bs, bh)
                SetEntityHeading(bt, bh + 180.0)
                SetEntityCollision(bs, false, true)
                SetEntityCollision(bt, false, true)
                PlaceObjectOnGroundProperly(bs)
                PlaceObjectOnGroundProperly(bt)
                FreezeEntityPosition(bs, true)
                FreezeEntityPosition(bt, true)
                local bw = NetworkGetNetworkIdFromEntity(bs)
                local bx = NetworkGetNetworkIdFromEntity(bt)
                C[af] = {af, bw, bx, -0.3, true}
                TriggerServerEvent("VICE:updateJackTable", af, C[af], false)
                SetModelAsNoLongerNeeded(bq)
                VICE.notify("~g~Success~w~: Inflatable jack setup")
                handleLifting(ae, af, bs)
            end
        else
            if ag then
                if br then
                    VICE.notify("Error~w~: This inflatable jack is in use")
                else
                    local bs = VICE.getObjectId(C[af][2], "handleJack 3")
                    local bt = VICE.getObjectId(C[af][3], "handleJack 4")
                    TriggerServerEvent("VICE:updateJackTable", af, C[af], true)
                    if DoesEntityExist(bs) then
                        TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(bs))
                        DeleteEntity(bs)
                    end
                    if DoesEntityExist(bt) then
                        TriggerServerEvent("VICE:deleteProp", NetworkGetNetworkIdFromEntity(bt))
                        DeleteEntity(bt)
                    end
                    TriggerServerEvent("VICE:removeVehicleStablisers", af)
                    C[af] = nil
                    VICE.notify("~g~Success~w~: Inflatable jack removed")
                end
            else
                VICE.notify("Error~w~: No inflatable jack found")
            end
        end
    else
        VICE.notify("Error~w~: No vehicle found")
    end
end
function handleLifting(ae, af, bs)
    local bm = NetworkGetNetworkIdFromEntity(ae)
    local by = NetworkGetNetworkIdFromEntity(bs)
    if bm == 0 or by == 0 then
        return
    end
    usingCarJack = true
    drawNativeNotification("Use ~INPUT_CELLPHONE_UP~ and ~INPUT_CELLPHONE_DOWN~ to adjust the height")
    VICE.notify("~g~Success~w~: Use ARROW UP and ARROW DOWN to adjust the height. Press ENTER when done")
    local bz = C[af][4]
    C[af][5] = true
    while usingCarJack do
        DisableControlAction(0, 172, true)
        DisableControlAction(0, 173, true)
        if IsDisabledControlJustPressed(0, 172) then
            bz = bz + 0.007
            if bz > 0.8 then
                bz = 0.8
            end
            TriggerServerEvent("VICE:lfbHandlingLifting", bm, by, bz)
        end
        if IsDisabledControlJustPressed(0, 173) then
            bz = bz - 0.007
            if bz < -0.7 then
                bz = -0.7
            end
            TriggerServerEvent("VICE:lfbHandlingLifting", bm, by, bz)
        end
        if IsDisabledControlJustPressed(0, 215) then
            TriggerServerEvent("VICE:lfbLiftingFreeze", bm)
            C[af][5] = false
            C[af][4] = bz
            TriggerServerEvent("VICE:updateJackTable", af, C[af], false)
            VICE.notify("~g~Success~w~: You've stopped controlling the inflatable jack")
            usingCarJack = false
        end
        Wait(0)
    end
end
RegisterNetEvent("VICE:lfbHandlingLifting",function(bm, by, bz)
    if not NetworkDoesNetworkIdExist(bm) or not NetworkDoesNetworkIdExist(by) then
        return
    end
    local ae = NetworkGetEntityFromNetworkId(bm)
    local bA = NetworkGetEntityFromNetworkId(by)
    if ae == 0 or bA == 0 then
        return
    end
    DetachEntity(ae)
    AttachEntityToEntity(ae, bA, -1, 0.7, 0.0, bz, 0.0, 0.0, 0.0, true, false, true, false, 1, true)
end)
RegisterNetEvent("VICE:lfbLiftingFreeze",function(bm)
    if not NetworkDoesNetworkIdExist(bm) then
        return
    end
    local ae = NetworkGetEntityFromNetworkId(bm)
    if ae == 0 then
        return
    end
    DetachEntity(ae)
    FreezeEntityPosition(ae, true)
end)
local bB = "prop_air_chock_04"
function handleChock(ad)
    local ae = spreadersRaycast()
    if ae ~= 0 and ae then
        local af = NetworkGetNetworkIdFromEntity(ae)
        local ag = tableHas(D, af)
        if ad then
            if ag then
                VICE.notify("Error~w~: This vehicle already has chocks setup")
            else
                local bu = GetEntityCoords(ae)
                ResetVehicleWheels(ae, true)
                VICE.loadModel(bB)
                TriggerServerEvent("VICE:toggleChockWheels", af)
                local bC = CreateObject(bB, bu.x, bu.y, bu.z, true, true, true)
                local bD = CreateObject(bB, bu.x, bu.y, bu.z, true, true, true)
                local bE = CreateObject(bB, bu.x, bu.y, bu.z, true, true, true)
                local bF = CreateObject(bB, bu.x, bu.y, bu.z, true, true, true)
                while not DoesEntityExist(bC) or not DoesEntityExist(bD) or not DoesEntityExist(bE) or
                    not DoesEntityExist(bF) do
                    Wait(0)
                end
                TriggerServerEvent("VICE:createLFBPropLog", "Air Chocks", GetEntityCoords(bC, true))
                local bh = GetEntityHeading(ae)
                local bG = GetEntityBoneIndexByName(ae, "wheel_lf")
                local bH = GetEntityBoneIndexByName(ae, "wheel_lr")
                local bI = GetEntityBoneIndexByName(ae, "wheel_rf")
                local bJ = GetEntityBoneIndexByName(ae, "wheel_rr")
                FreezeEntityPosition(bC, true)
                FreezeEntityPosition(bD, true)
                FreezeEntityPosition(bE, true)
                FreezeEntityPosition(bF, true)
                AttachEntityToEntity(bC, ae, bG, -0.05, 0.25, -0.29, 0.0, 0.0, 90.0, true, false, true, false, 1, true)
                AttachEntityToEntity(bE,ae,bI,-0.05,0.25,0.29,180.0,0.0,-270.0,true,false,true,false,1,true)
                AttachEntityToEntity(bD,ae,bH,-0.05,-0.25,-0.29,0.0,0.0,-90.0,true,false,true,false,1,true)
                AttachEntityToEntity(bF,ae,bJ,-0.05,-0.25,0.29,180.0,0.0,-90.0,true,false,true,false,1,true)
                SetEntityCollision(bC, false, true)
                SetEntityCollision(bD, false, true)
                SetEntityCollision(bE, false, true)
                SetEntityCollision(bF, false, true)
                local bK = NetworkGetNetworkIdFromEntity(bC)
                local bL = NetworkGetNetworkIdFromEntity(bD)
                local bM = NetworkGetNetworkIdFromEntity(bE)
                local bN = NetworkGetNetworkIdFromEntity(bF)
                D[af] = {af, bK, bL, bM, bN}
                TriggerServerEvent("VICE:updateChockTable", af, D[af], false)
                SetModelAsNoLongerNeeded(bB)
                TaskGoStraightToCoord(VICE.getPlayerPed(), bu.x, bu.y, bu.z, 30.0, 0.5, 0.0, 10.0)
                Wait(2000)
                FreezeEntityPosition(ae, true)
                VICE.notify("~g~Success~w~: Car chocks setup")
            end
        else
            if ag then
                Wait(2000)
                local bC = VICE.getObjectId(D[af][2], "chock1")
                local bD = VICE.getObjectId(D[af][3], "chock2")
                local bE = VICE.getObjectId(D[af][4], "chock3")
                local bF = VICE.getObjectId(D[af][5], "chock4")
                Wait(1000)
                if DoesEntityExist(bC) then
                    DeleteEntity(bC)
                end
                if DoesEntityExist(bD) then
                    DeleteEntity(bD)
                end
                if DoesEntityExist(bE) then
                    DeleteEntity(bE)
                end
                if DoesEntityExist(bF) then
                    DeleteEntity(bF)
                end
                TriggerServerEvent("VICE:updateChockTable", af, D[af], true)
                TriggerServerEvent("VICE:removeVehicleStablisers", af)
                VICE.notify("~g~Success~w~: Car chocks removed")
            else
                VICE.notify("Error~w~: No car chocks found")
            end
        end
    else
        VICE.notify("Error~w~: No vehicle found")
    end
end
function useThrowBag()
    local bO = true
    local a4 = VICE.getPlayerPed()
    local as = "weapon_throwbag"
    GiveWeaponToPed(PlayerPedId(), "weapon_throwbag", 1, false, true)
    local bP = false
    local at = 0
    while bO do
        local bQ = VICE.getPlayerId()
        local ai, bR = GetEntityPlayerIsFreeAimingAt(bQ)
        if IsPedShooting(a4) then
            if ai then
                bP = true
                at = bR
                throwbagAiming = false
            else
                bP = false
            end
            break
        end
        Wait(0)
    end
    if bP then
        VICE.notify("~g~Success~w~: Throw bag deployed")
        spawnRope(at)
    else
        VICE.notify("Error~w~: No player found")
    end
    bO = false
end
function spawnRope(bR)
    local a4 = VICE.getPlayerPed()
    local t = VICE.getPlayerCoords()
    TriggerServerEvent("VICE:spawnThrowBag",t,VICE.getNetId(bR, "spawnRope(entity)"),VICE.getNetId(a4, "spawnRope(ped)"))
    Wait(2000)
    VICE.notify("~g~Success~w~: Rope is now winding")
end
local bS = 100
RegisterNetEvent("VICE:spawnThrowBag",function(t, aq, bT)
    local a4 = VICE.getPlayerPed()
    local bv = VICE.getPlayerCoords()
    local V = #(bv - t)
    if V < 30.0 then
        RopeLoadTextures()
        local bU = VICE.getObjectId(aq, "spawnThrowBag 1")
        local bV = VICE.getObjectId(bT, "spawnThrowBag 2")
        local bW = GetEntityCoords(bU)
        local bX = #(GetEntityCoords(bU) - GetEntityCoords(bV))
        local bY = AddRope(t.x, t.y, t.z, 0.0, 0.0, 0.0, bX, 2, bX + 10.0, 1.0, 0, 0, 0, 0, 0, 0, 0)
        AttachEntitiesToRope(bY, bV, bU, t.x, t.y, t.z + 0.2, bW.x, bW.y, bW.z - 0.60, bX, true, true)
        StartRopeWinding(bY)
        local bZ = "rcmlastone2leadinout"
        local b_ = "sas_idle_sit"
        local c0 = "missprologueig_4@hold_head_base"
        local c1 = "hold_head_loop_base_brad"
        FreezeEntityPosition(bV, true)
        VICE.loadAnimDict(c0)
        TaskPlayAnim(bV, c0, c1, 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
        RemoveAnimDict(c0)
        local c2 = false
        while not (#(GetEntityCoords(bU) - GetEntityCoords(bV)) < 1.4) do
            if not c2 then
                if not IsPedSwimming(bU) then
                    c2 = true
                    VICE.loadAnimDict(bZ)
                    TaskPlayAnim(bU, bZ, b_, 8.0, -8.0, -1, 1, 0.0, 0, 0, 0)
                    RemoveAnimDict(bZ)
                end
            end
            local c3 = RopeGetDistanceBetweenEnds(bY)
            if c3 < 1.4 then
                break
            end
            RopeForceLength(bY, c3 - 0.1)
            if bS < 0 then
                Wait(0)
            else
                Wait(bS)
            end
        end
        DeleteRope(bY)
        ClearPedTasks(bU)
        ClearPedTasks(bV)
        FreezeEntityPosition(bV, false)
        RopeUnloadTextures()
    end
end)
