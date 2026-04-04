RMenu.Add("SettingsMenu", "MainMenu", RageUI.CreateMenu("", "VICE Settings", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "graphicpresets", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Graphics Presets", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "changediscord", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "Link Discord", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "compensation", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Compensation", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "compensationinfo", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "compensation"), "", "~b~Compensation", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "killeffects", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Kill Effects", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "bloodeffects", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Blood Effects", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "weaponsettings", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Weapon Related Settings", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "weaponswhitelist", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Custom Weapons Owned", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "generateaccesscode", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "weaponswhitelist"), "", "~b~Generate Access Code", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "viewwhitelisted", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "generateaccesscode"), "", "~b~View Whilelisted Users", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "gangsettings", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Gang Related Settings", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("SettingsMenu", "miscsettings", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~Miscellaneous Settings", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
local a = module("cfg/cfg_settings")
local b = 0
local c = 0
local C = {"Discord", "Steam", "Custom", "None"}
local E = {32, 40, 48, 56}
local F = tonumber(GetResourceKvpString("vice_pfp_size")) or 1
local G = tonumber(GetResourceKvpString("vice_pfp_type")) or 1
local d = 0
local e = false
local g = false
local h = false
local i = false
local j = 1
local k = {30.0, 45.0, 60.0, 75.0, 90.0, 500.0}
local l = {"30m", "45m", "60m", "75m", "90m", "500m"}
local m = 1
local n = {"None", "1", "2", "3", "4", "5", "6", "7", "8"}
local o = 1
local p = {"10%", "20%", "30%", "40%", "50%", "60%", "70%", "80%", "90%", "100%"}
local q = 3
local DR = 3
local r = 1
local s = {"1%"}
local t = 1
local A = 1
local B = {"VICE", "Fortnite"}
local u = {"1%"}
local v = {"Visible", "Muted", "Hidden"}
local w = 1
local zz = false
for x = 20, 500, 20 do
    table.insert(s, string.format("%d%%", x))
end
for x = 5, 200, 5 do
    table.insert(u, string.format("%d%%", x))
end
local MaxDjVolume = 100
function GetMaxDjVolume()
    return MaxDjVolume
end

Citizen.CreateThread(
    function()
        local djs = GetResourceKvpString("vice_djvolume") or "false"
        if djs ~= "false" and tonumber(djs) and tonumber(djs) >= 0 then
            MaxDjVolume = tonumber(djs)
        end
        local y = GetResourceKvpString("vice_diagonalweapons") or "false"
        if y == "false" then
            b = false
            TriggerEvent("VICE:setVerticalWeapons")
        else
            b = true
            TriggerEvent("VICE:setDiagonalWeapons")
        end
        local z = GetResourceKvpString("vice_viceontars") or "false"
        if z == "false" then
            c = false
            TriggerEvent("VICE:setBackAR")
        else
            c = true
            TriggerEvent("VICE:setFrontAR")
        end
        local _ = GetResourceKvpInt("vice_health_ui_type")
        if _ > 0 then
            A = _
            tVICE.setHealthUIType(B[A])
        end
        tVICE.updatePFPType(C[G]) -- delete
        tVICE.updatePFPSize(E[F])
        local A = GetResourceKvpString("vice_hitmarkersounds") or "false"
        if A == "false" then
            d = false
            TriggerEvent("VICE:hsSoundsOff")
        else
            d = true
            TriggerEvent("VICE:hsSoundsOn")
        end
        local B = GetResourceKvpString("vice_reducedchatopacity") or "false"
        if B == "false" then
            f = false
            TriggerEvent("VICE:chatReduceOpacity", false)
        else
            f = true
            TriggerEvent("VICE:chatReduceOpacity", true)
        end
        local C = GetResourceKvpString("vice_hideeventannouncement") or "false"
        if C == "false" then
            g = false
        else
            g = true
        end
        local D = GetResourceKvpString("vice_healthpercentage") or "false"
        if D == "false" then
            h = false
        else
            h = true
        end
        local E = GetResourceKvpString("vice_flashlightnotaiming") or "false"
        if E == "false" then
            i = false
        else
            i = true
            SetFlashLightKeepOnWhileMoving(true)
        end
        local F = GetResourceKvpInt("vice_gang_name_distance")
        if F > 0 then
            j = F
            if k[j] then
                TriggerEvent("VICE:setGangNameDistance", k[j])
            end
        end
        local G = GetResourceKvpInt("vice_gang_ping_sound")
        if G > 0 then
            m = G
        end
        local H = GetResourceKvpInt("vice_gang_ping_volume")
        if H > 0 then
            o = H
        end
        local N = GetResourceKvpString("vice_gang_ping_minimap") or "false"
        if N == "false" then
            gangPingMinimap = false
        else
            gangPingMinimap = true
        end
        local I = GetResourceKvpInt("vice_gang_ping_marker")
        if I > 0 then
            q = I
        end
        local J = GetResourceKvpInt("vice_gang_position_x")
        if J > 0 then
            r = J
            VICE.setGangUIXPos(s[r])
        end
        local K = GetResourceKvpInt("vice_gang_position_y")
        if K > 0 then
            t = K
            VICE.setGangUIYPos(u[t])
        end
        local L = GetResourceKvpInt("vice_doorbell_index")
        if L > 0 then
            w = L
        end
    end
)
function VICE.setDiagonalWeaponSetting(i)
    SetResourceKvp("vice_diagonalweapons", tostring(i))
end
function VICE.setFrontARSetting(i)
    SetResourceKvp("vice_viceontars", tostring(i))
end
function VICE.setFrontSMGSetting(i)
    SetResourceKvp("vice_frontsmg", tostring(i))
end
function VICE.setHitMarkerSetting(i)
    SetResourceKvp("vice_hitmarkersounds", tostring(i))
end
function VICE.setCODHitMarkerSetting(i)
    SetResourceKvp("vice_codhitmarkersounds", tostring(i))
end
function VICE.setKillListSetting(G)
    SetResourceKvp("vice_killlistsetting", tostring(G))
end
function VICE.setOldKillfeed(G)
    SetResourceKvp("vice_oldkillfeed", tostring(G))
end
function VICE.setBulletTracers(G)
    SetResourceKvp("vice_bullettracers", tostring(G))
end
function VICE.setDamageIndicator(G)
    SetResourceKvp("vice_damageindicator", tostring(G))
end
function VICE.setDamageIndicatorColour(G)
    SetResourceKvp("vice_damageindicatorcolour", tostring(G))
end
function VICE.setBulletTracersColour(index)
    local gD = {"Red", "Blue", "Green", "Pink", "Yellow", "Orange", "Purple"}
    local color = gD[index]
    if color then
        SetResourceKvp("vice_bullettracercolour", color)
    end
end
function VICE.setReducedChatOpacity(A)
    SetResourceKvp("vice_reducedchatopacity", tostring(A))
end
function VICE.setHideEventAnnouncementFlag(A)
    SetResourceKvp("vice_hideeventannouncement", tostring(A))
end
function VICE.getHideEventAnnouncementFlag()
    return g
end
function VICE.displayPingsOnMinimap()
    return gangPingMinimap
end
function VICE.setShowHealthPercentageFlag(A)
    SetResourceKvp("vice_healthpercentage", tostring(A))
end
function VICE.setFlashlightNotAimingFlag(H)
    SetFlashLightKeepOnWhileMoving(H)
    i = H
    SetResourceKvp("vice_flashlightnotaiming", tostring(H))
end
function VICE.getShowHealthPercentageFlag()
    return h
end
function VICE.getGangPingSound()
    return m
end
function VICE.getGangPingVolume()
    return o
end
function VICE.getGangPingMarkerIndex()
    return q
end
function VICE.getDoorbellIndex()
    return w
end
function VICE.setRadioAnim(Ra)
    xA = Ra
    SetResourceKvp("vice_radio_anim", tostring(Ra))
end
function VICE.getRadioAnim()
    return xA
end
local function M(j)
    RageUI.CloseAll()
    RageUI.Visible(RMenu:Get("SettingsMenu", "settings"), j)
end
local x = {
    {"50%", 0.5},
    {"60%", 0.6},
    {"70%", 0.7},
    {"80%", 0.8},
    {"90%", 0.9},
    {"100%", 1.0},
    {"150%", 1.5},
    {"200%", 2.0},
    {"1000%", 10.0}
}
local N = {"50%", "60%", "70%", "80%", "90%", "100%", "150%", "200%", "1000%"}
local y = 6
local z = {}
local A
local B
local C
local D
RegisterNetEvent("VICE:gotCustomWeaponsOwned", function(E)
    -- print("gotCustomWeaponsOwned", dump(E))
    z = E
end)
RegisterNetEvent(
    "VICE:generatedAccessCode",
    function(O)
        --print("got accessCode", O)
        C = O
    end
)
RegisterNetEvent(
    "VICE:getWhitelistedUsers",
    function(F)
        D = F
    end
)
local G = {}
local function H(I, J)
    return G[I.name .. J.name]
end
local function K(I)
    local L = false
    for P, J in pairs(I.presets) do
        if G[I.name .. J.name] then
            L = true
            G[I.name .. J.name] = nil
        end
    end
    if L then
        for Q, R in pairs(I.default) do
            SetVisualSettingFloat(Q, R)
        end
    end
end
local function S(J)
    for Q, R in pairs(J.values) do
        SetVisualSettingFloat(Q, R)
    end
end
local disableLowPriorityProps = false
local objettable = {}

local function T(I, J, U)
    K(I)
    if J.name == "Disable Low Priority Props" then
        disableLowPriorityProps = U
        if U then
            objettable = J.values
        else
            objettable = {}
        end
    end
    if U then
        G[I.name .. J.name] = true
        S(J)
    else
        G[I.name .. J.name] = nil
    end
    local V = json.encode(G)
    SetResourceKvp("vice_graphic_presets", V)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if disableLowPriorityProps then
            while objettable == nil do
                Citizen.Wait(0)
            end
            if objettable ~= nil and #objettable > 0 then
                local d = GetGamePool("CObject")
                for c = 1, #objettable do
                    local e = GetHashKey(objettable[c])
                    for f, g in ipairs(d) do
                        if GetEntityModel(g) == e then
                            SetEntityAsMissionEntity(g, true, true)
                            DeleteObject(g)
                        end
                    end
                end
            end
        end
    end
end)


local W = {
    "0%",
    "5%",
    "10%",
    "15%",
    "20%",
    "25%",
    "30%",
    "35%",
    "40%",
    "45%",
    "50%",
    "55%",
    "60%",
    "65%",
    "70%",
    "75%",
    "80%",
    "85%",
    "90%",
    "95%",
    "100%"
}
local X = {
    0.0,
    0.05,
    0.1,
    0.15,
    0.2,
    0.25,
    0.3,
    0.35,
    0.4,
    0.45,
    0.5,
    0.55,
    0.6,
    0.65,
    0.7,
    0.75,
    0.8,
    0.85,
    0.9,
    0.95,
    1.0
}
local Y = {
    "25%",
    "50%",
    "75%",
    "100%",
    "125%",
    "150%",
    "175%",
    "200%",
    "250%",
    "300%",
    "350%",
    "400%",
    "450%",
    "500%",
    "750%",
    "1000%"
}
local Z = {0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 7.5, 10.0}
local _ = {
    "0.1s",
    "0.2s",
    "0.3s",
    "0.4s",
    "0.5s",
    "0.6s",
    "0.7s",
    "0.8s",
    "0.9s",
    "1s",
    "1.25s",
    "1.5s",
    "1.75s",
    "2.0s"
}
local a0 = {100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1250, 1500, 1750, 2000}
local a1 = {
    "Disabled",
    "Fireworks",
    "Celebration",
    "Firework Burst",
    "Water Explosion",
    "Ramp Explosion",
    "Gas Explosion",
    "Electrical Spark",
    "Electrical Explosion",
    "Concrete Impact",
    "EMP 1",
    "EMP 2",
    "EMP 3",
    "Spike Mine",
    "Kinetic Mine",
    "Tar Mine",
    "Short Burst",
    "Fog Sphere",
    "Glass Smash",
    "Glass Drop",
    "Falling Leaves",
    "Wood Smash",
    "Train Smoke",
    "Money",
    "Confetti",
    "Marbles",
    "Sparkles"
}
local a2 = {
    {"DISABLED", "DISABLED", 1.0},
    {"scr_indep_fireworks", "scr_indep_firework_shotburst", 0.2},
    {"scr_xs_celebration", "scr_xs_confetti_burst", 1.2},
    {"scr_rcpaparazzo1", "scr_mich4_firework_burst_spawn", 1.0},
    {"particle cut_finale1", "cs_finale1_car_explosion_surge_spawn", 1.0},
    {"des_fib_floor", "ent_ray_fbi5a_ramp_explosion", 1.0},
    {"des_gas_station", "ent_ray_paleto_gas_explosion", 0.5},
    {"core", "ent_dst_electrical", 1.0},
    {"core", "ent_sht_electrical_box", 1.0},
    {"des_vaultdoor", "ent_ray_pro1_concrete_impacts", 1.0},
    {"scr_xs_dr", "scr_xs_dr_emp", 1.0},
    {"scr_xs_props", "scr_xs_exp_mine_sf", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_emp", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_spike", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_kinetic", 1.0},
    {"veh_xs_vehicle_mods", "exp_xs_mine_tar", 1.0},
    {"scr_stunts", "scr_stunts_shotburst", 1.0},
    {"scr_tplaces", "scr_tplaces_team_swap", 1.0},
    {"des_fib_glass", "ent_ray_fbi2_window_break", 1.0},
    {"des_fib_glass", "ent_ray_fbi2_glass_drop", 2.5},
    {"des_stilthouse", "ent_ray_fam3_falling_leaves", 1.0},
    {"des_stilthouse", "ent_ray_fam3_wood_viceags", 1.0},
    {"des_train_crash", "ent_ray_train_smoke", 1.0},
    {"core", "ent_brk_banknotes", 2.0},
    {"core", "ent_dst_inflate_ball_clr", 1.0},
    {"core", "ent_dst_gen_gobstop", 1.0},
    {"core", "ent_sht_telegraph_pole", 1.0}
}
local a3 = {
    "Disabled",
    "BikerFilter",
    "CAMERA_BW",
    "drug_drive_blend01",
    "glasses_blue",
    "glasses_brown",
    "glasses_Darkblue",
    "glasses_green",
    "glasses_purple",
    "glasses_red",
    "helicamfirst",
    "hud_def_Trvicer",
    "Kifflom",
    "LectroDark",
    "MP_corona_tournament_DOF",
    "MP_heli_cam",
    "mugShot",
    "NG_filmic02",
    "REDMIST_blend",
    "trvicerspliff",
    "ufo",
    "underwater",
    "WATER_LAB",
    "WATER_militaryPOOP",
    "WATER_river",
    "WATER_salton"
}
local a4 = {
    lightning = false,
    pedFlash = false,
    pedFlashRGB = {11, 11, 11},
    pedFlashIntensity = 4,
    pedFlashTime = 1,
    screenFlash = false,
    screenFlashRGB = {11, 11, 11},
    screenFlashIntensity = 4,
    screenFlashTime = 1,
    particle = 1,
    timecycle = 1,
    timecycleTime = 1
}
local Xz = GetResourceKvpString("vice_radio_anim") or "true"
if Xz == "false" then
    xA = false
else
    xA = true
end
local a5 = 0
local function a6()
    local a7 = json.encode(a4)
    SetResourceKvp("vice_kill_effects", a7)
end
local a8 = {head = 1, body = 1, arms = 1, legs = 1}
local function a9()
    local aa = json.encode(a8)
    SetResourceKvp("vice_blood_effects", aa)
end
Citizen.CreateThread(
    function()
        Citizen.Wait(1000)
        local V = GetResourceKvpString("vice_graphic_presets")
        if V and V ~= "" then
            G = json.decode(V) or {}
        end
        for P, I in pairs(a.presets) do
            for P, J in pairs(I.presets) do
                if H(I, J) then
                    S(J)
                end
            end
        end
        local a7 = GetResourceKvpString("vice_kill_effects")
        if a7 and a7 ~= "" then
            local ab = json.decode(a7)
            for ac, U in pairs(ab) do
                if a4[ac] then
                    a4[ac] = U
                end
            end
        end
        local aa = GetResourceKvpString("vice_blood_effects")
        if aa and aa ~= "" then
            local ab = json.decode(aa)
            for ac, U in pairs(ab) do
                if a8[ac] then
                    a8[ac] = U
                end
            end
        end
    end
)
local userCompensations = {}
local compdata = {inventory = {},selected = {},compensatingid = 0}
local resetdata = compdata
RegisterNetEvent("VICE:ReceiveCompensations",function(receivedComp)
    userCompensations = receivedComp
    table.sort(userCompensations, function(a, b) 
        return a.compensator < b.compensator
    end)
end)

RegisterNetEvent("VICE:StartCompensation",function(inventory,compid)
    compdata.inventory,compdata.selected,compdata.compensatingid = inventory,{},compid
    for A,B in pairs(compdata.inventory) do
        compdata.selected[A] = false
    end
    RageUI.Visible(RMenu:Get("SettingsMenu", "compensation"), false)
    RageUI.Visible(RMenu:Get("SettingsMenu", "compensationinfo"), true)
end)

RageUI.CreateWhile(
    1.0,
    true,
    function()
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "MainMenu"),
            true,
            true,
            true,
            function()
                -- if VICE.isNewPlayer() then
                --     drawNativeNotification("Press ~INPUT_REPLAY_START_STOP_RECORDING_SECONDARY~ to toggle the Settings Menu.")
                -- end
                RageUI.ButtonWithStyle(
                    "Weapon Whitelists",
                    "Sell your custom weapon whitelists here.",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                        if af then
                            C = nil
                            A = nil
                            B = nil
                            D = nil
                            TriggerServerEvent("VICE:getCustomWeaponsOwned")
                        end
                    end,
                    RMenu:Get("SettingsMenu", "weaponswhitelist")
                )
                RageUI.ButtonWithStyle(
                    "Weapon Options",
                    "Toggle options to do with weapons and their placement.",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                    end,
                    RMenu:Get("SettingsMenu", "weaponsettings")
                )
                if PlayerIsInGang then
                    RageUI.ButtonWithStyle(
                        "Gang Options",
                        "Toggle settings which affect the gang UI.",
                        {RightLabel = "→→→"},
                        true,
                        function(ad, ae, af)
                        end,
                        RMenu:Get("SettingsMenu", "gangsettings")
                    )
                end
                RageUI.ButtonWithStyle(
                    "Graphic Presets",
                    "View a list of preconfigured graphic settings.",
                    {RightLabel = "→→→"},
                    true,
                    function()
                    end,
                    RMenu:Get("SettingsMenu", "graphicpresets")
                )
                RageUI.ButtonWithStyle(
                    "Blood Effects",
                    "Toggle effects that occur when damaging a player.",
                    {RightLabel = "→→→"},
                    true,
                    function()
                    end,
                    RMenu:Get("SettingsMenu", "bloodeffects")
                )
                RageUI.ButtonWithStyle(
                    "Kill Effects",
                    "Toggle effects that occur on killing a player.",
                    {RightLabel = "→→→"},
                    true,
                    function()
                    end,
                    RMenu:Get("SettingsMenu", "killeffects")
                )
                --RageUI.ButtonWithStyle("Inventory Customiser","Loads of settings to customize the players inventory.",{RightLabel = "→→→"},true,function(ad, ae, af)
               -- end,RMenu:Get("inventorycolour", "main"))
                RageUI.ButtonWithStyle(
                    "UI Visibility",
                    "Options to permanently disable certain UIs.",
                    {RightLabel = "→→→"},
                    true,
                    function()
                    end,
                    RMenu:Get("uivisibility", "main")
                )
                RageUI.ButtonWithStyle(
                    "Change Linked Discord",
                    "Begins the process of changing your linked Discord. Your linked discord is used to sync roles with the server.",
                    {RightLabel = "→→→"},
                    true,
                    function(a4, a5, a6)
                        if a6 then
                            TriggerServerEvent("VICE:changeLinkedDiscord")
                        end
                    end
                )
                RageUI.ButtonWithStyle("Compensation","Vew any unclaimed compensations",{RightLabel = "→→→"},true,function(Hovered, Active, Selected)
                    if Selected then
                        TriggerServerEvent("VICE:RequestCompensations")
                    end
                end,RMenu:Get("SettingsMenu", "compensation"))
                RageUI.ButtonWithStyle(
                    "Miscellaneous",
                    "Miscellaneous options.",
                    {RightLabel = "→→→"},
                    true,
                    function(a4, a5, a6)
                    end,
                    RMenu:Get("SettingsMenu", "miscsettings")
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "weaponsettings"),
            true,
            true,
            true,
            function()
                local function ai()
                    TriggerEvent("VICE:setDiagonalWeapons")
                    b = true
                    VICE.setDiagonalWeaponSetting(b)
                end
                local function aj()
                    TriggerEvent("VICE:setVerticalWeapons")
                    b = false
                    VICE.setDiagonalWeaponSetting(b)
                end
                RageUI.Checkbox(
                    "Enable Diagonal Weapons",
                    "~g~This changes the way weapons look on your back from vertical to diagonal.",
                    b,
                    {Style = RageUI.CheckboxStyle.Car},
                    function(ad, af, ae, ah)
                    end,
                    ai,
                    aj
                )
                RageUI.Checkbox(
                    "Enable Front Assault Rifles",
                    "~g~This changes the positioning of Assault Rifles from back to front.",
                    c,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        TriggerEvent("VICE:setFrontAR")
                        c = true
                        VICE.setFrontARSetting(c)
                    end,
                    function()
                        TriggerEvent("VICE:setBackAR")
                        c = false
                        VICE.setFrontARSetting(c)
                    end
                )
                RageUI.Checkbox(
                    "Enable Front SMGs",
                    "~g~This changes the positioning of SMGs from back to front.",
                    zz,
                    {Style = RageUI.CheckboxStyle.Car},
                    function()
                    end,
                    function()
                        TriggerEvent("VICE:setFrontSMG")
                        zz = true
                        VICE.setFrontSMGSetting(c)
                    end,
                    function()
                        TriggerEvent("VICE:setFrontSMG")
                        zz = false
                        VICE.setFrontSMGSetting(c)
                    end
                )
                local function ai()
                    TriggerEvent("VICE:hsSoundsOn")
                    d = true
                    VICE.setHitMarkerSetting(d)
                    VICE.notify("~y~Experimental Headshot sounds now set to " .. tostring(d))
                end
                local function aj()
                    TriggerEvent("VICE:hsSoundsOff")
                    d = false
                    VICE.setHitMarkerSetting(d)
                    VICE.notify("~y~Experimental Headshot sounds now set to " .. tostring(d))
                end
                RageUI.Checkbox(
                    "Enable Experimental Hit Marker Sounds",
                    "~g~This adds 'hit marker' sounds when shooting another player, however it can be unreliable.",
                    d,
                    {Style = RageUI.CheckboxStyle.Car},
                    function(ad, af, ae, ah)
                    end,
                    ai,
                    aj
                )
                RageUI.Checkbox(
                    "Keep Flashlight On Whilst Moving",
                    "Makes weapon flashlight beams stay visible while moving.",
                    i,
                    {},
                    function()
                    end,
                    function()
                        VICE.setFlashlightNotAimingFlag(true)
                    end,
                    function()
                        VICE.setFlashlightNotAimingFlag(false)
                    end
                )
                RageUI.Checkbox(
                    "Toggle Radio Animation",
                    "The player will play an animation when speaking over radio.",
                    xA,
                    {},
                    function()
                    end,
                    function()
                        VICE.setRadioAnim(true)
                    end,
                    function()
                        VICE.setRadioAnim(false)
                    end
                )
                RageUI.ButtonWithStyle(
                    "Scope Settings",
                    "Add a toggleable range finder when using sniper scopes.",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                    end,
                    RMenu:Get("scope", "main")
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "gangsettings"),
            true,
            true,
            true,
            function()
                RageUI.List(
                    "Gang Ping Marker",
                    {"Only Text", "Marker", "Icon"},
                    q,
                    "Display of gang markers.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= q then
                            q = an
                            SetResourceKvpInt("vice_gang_ping_marker", an)
                        end
                    end
                )               
                RageUI.List(
                    "Gang Ping Volume",
                    p,
                    o,
                    "Volume of the gang ping sound.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= o then
                            o = an
                            SetResourceKvpInt("vice_gang_ping_volume", an)
                        end
                    end
                )
                RageUI.List(
                    "Gang Ping Sound",
                    n,
                    m,
                    "Sound to play when a gang member pings.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= m then
                            m = an
                            SetResourceKvpInt("vice_gang_ping_sound", an)
                        end
                    end
                )
                RageUI.List(
                    "Gang Name Distance",
                    l,
                    j,
                    "Max distance to display gang member names.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= j then
                            j = an
                            SetResourceKvpInt("vice_gang_name_distance", an)
                            TriggerEvent("VICE:setGangNameDistance", k[an])
                        end
                    end
                )
                RageUI.List(
                    "Health UI X",
                    s,
                    r,
                    "Change the X position of the gang health UI.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= r then
                            r = an
                            VICE.setGangUIXPos(s[an])
                            SetResourceKvpInt("vice_gang_position_x", r)
                        end
                    end
                )
                RageUI.List(
                    "Health UI Y",
                    u,
                    t,
                    "Change the Y position of the gang health UI.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= t then
                            t = an
                            VICE.setGangUIYPos(u[an])
                            SetResourceKvpInt("vice_gang_position_y", t)
                        end
                    end
                )
                RageUI.Checkbox(
                    "Display Pings on Minimap",
                    "Display gang pings on the minimap.",
                    gangPingMinimap,
                    {},
                    function()
                    end,
                    function()
                        gangPingMinimap = true
                        SetResourceKvp("vice_gang_ping_minimap", tostring(true))
                    end,
                    function()
                        gangPingMinimap = false
                        SetResourceKvp("vice_gang_ping_minimap", tostring(false))
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "miscsettings"),
            true,
            true,
            true,
            function()
                RageUI.ButtonWithStyle(
                    "Store Inventory",
                    "View your store inventory here.",
                    {RightLabel = "→→→"},
                    true,
                    function()
                    end,
                    RMenu:Get("store", "mainmenu")
                )
                RageUI.SliderProgress("DJ Max Volume",MaxDjVolume,100,"Set The Max DJ Volume",{ProgressBackgroundColor={R=0,G=0,B=0,A=255},ProgressColor={R=0,G=117,B=194,A=255}},true,function(k,m,l,n)
                    if m then 
                        if n~=MaxDjVolume then 
                            MaxDjVolume=n
                            SetResourceKvp("vice_djvolume",tostring(n))
                        end 
                    end
                    MaxDjVolume=n 
                end)
                RageUI.List(
                    "Doorbell Status",
                    v,
                    w,
                    "Change the status of the doorbell.",
                    {},
                    true,
                    function(ak, al, am, an)
                        if an ~= w then
                            w = an
                            SetResourceKvpInt("vice_doorbell_index", an)
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "changediscord"),
            true,
            true,
            true,
            function()
                RageUI.Separator("~g~A code has been messaged to the Discord account")
                RageUI.Separator("-----")
                RageUI.Separator("~y~If you have not received a message verify:")
                RageUI.Separator("~y~1. Your direct messages are open.")
                RageUI.Separator("~y~2. The account you provided was correct.")
                RageUI.Separator("-----")
                RageUI.ButtonWithStyle(
                    "Enter Code",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                        if af then
                            TriggerServerEvent("VICE:enterDiscordCode")
                        end
                    end
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "weaponswhitelist"),
            true,
            true,
            true,
            function()
                for ao, ap in pairs(z) do
                    RageUI.ButtonWithStyle(
                        ap,
                        "",
                        {RightLabel = "→→→"},
                        true,
                        function(ad, ae, af)
                            if af then
                                A = ap
                                B = ao
                                D = nil
                            end
                        end,
                        RMenu:Get("SettingsMenu", "generateaccesscode")
                    )
                end
                RageUI.Separator("~y~If you do not see your custom weapon here.")
                RageUI.Separator("~y~Please open a ticket on our support discord.")
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "generateaccesscode"),
            true,
            true,
            true,
            function()
                RageUI.Separator("~g~Weapon Whitelist for " .. A)
                RageUI.Separator("How it works:")
                RageUI.Separator("You generate an access code for the player who wishes")
                RageUI.Separator("to purchase your custom weapon whitelist, which they ")
                RageUI.Separator("enter on there weapon whitelist to receive their")
                RageUI.Separator("weapon whitelist.")
                RageUI.ButtonWithStyle(
                    "Create access code",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                        if af then
                            local aq = getGenericTextInput("User ID of player purchasing your weapon whitelist.")
                            if tonumber(aq) then
                                aq = tonumber(aq)
                                if aq > 0 then
                                  --  print("selling", B, "to", aq)
                                    TriggerServerEvent("VICE:generateWeaponAccessCode", B, aq)
                                end
                            end
                        end
                    end
                )
                RageUI.ButtonWithStyle(
                    "View whitelisted users",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                        if af then
                            TriggerServerEvent("VICE:requestWhitelistedUsers", B)
                        end
                    end,
                    RMenu:Get("SettingsMenu", "viewwhitelisted")
                )
                if C then
                    RageUI.Separator("~g~Access code generated: " .. C)
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "viewwhitelisted"),
            true,
            true,
            true,
            function()
                RageUI.Separator("~g~Whitelisted users for " .. A)
                if D == nil then
                    RageUI.Separator("~r~Requesting whitelisted users...")
                else
                    for ar, as in pairs(D) do
                        RageUI.ButtonWithStyle("ID: " .. tostring(ar),
                            "",
                            {RightLabel = as},
                            true,
                            function()
                            end
                        )
                    end
                end
            end,
            function()
            end
        )
        RageUI.IsVisible(RMenu:Get("SettingsMenu", "compensation"),true,true,true,function()
            if not userCompensations then
                RageUI.Separator("~r~Request data...")
            else
                RageUI.ButtonWithStyle("Submit","Submit the compensation request",{},true,function(Hovered, Active, Selected)
                    if Selected then
                        if not tVICE.isInComa() then
                            if VICE.getPlayerCombatTimer() == 0 then
                                if isInGreenzone then
                                    tVICE.clientPrompt("User ID: ","",function(input)
                                        if tonumber(input) then
                                            TriggerServerEvent("VICE:StartCompensation",tonumber(input))
                                        else
                                            VICE.notify("~r~Invalid User ID.")
                                        end
                                    end)
                                else
                                    VICE.notify("~r~You must be in a greenzone to submit a compensation request.")
                                end
                            else
                                VICE.notify("~r~You currently have a combat timer.")
                            end
                        else
                            VICE.notify("~r~You cannot submit a compensation while dead.")
                        end
                    end
                end)
                if next(userCompensations) then
                    RageUI.Separator("~g~Compensations Available.")
                    for _,v in pairs(userCompensations) do
                        RageUI.ButtonWithStyle("ID: "..v.compensator,"Claim Your compensation",{},true,function(Hovered,Active,Selected)
                            if Selected then
                                if not tVICE.isInComa() then
                                    if VICE.getPlayerCombatTimer() == 0 then
                                        if isInGreenzone then
                                            TriggerServerEvent("VICE:ClaimCompensation",_)
                                        else
                                            VICE.notify("~r~You must be in a greenzone to claim your compensation.")
                                        end
                                    else
                                        VICE.notify("~r~You currently have a combat timer.")
                                    end
                                else
                                    VICE.notify("~r~You cannot claim a compensation while dead.")
                                end
                            end
                        end)
                    end
                else
                    RageUI.Separator("~r~No Compensations Available.")
                end
            end
        end,function()
        end)         
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "graphicpresets"),
            true,
            true,
            true,
            function()
                RageUI.ButtonWithStyle(
                    "Graphic Pack's",
                    "",
                    {RightLabel = "→→→"},
                    true,
                    function(ad, ae, af)
                    end,
                    RMenu:Get("VICE","graphicpacks")
                )
                for P, I in pairs(a.presets) do
                    RageUI.Separator(I.name)
                    for P, J in pairs(I.presets) do
                        local at = H(I, J)
                        RageUI.Checkbox(
                            J.name,
                            nil,
                            at,
                            {},
                            function(ad, af, ae, ah)
                                if ah ~= at then
                                    T(I, J, ah)
                                end
                            end,
                            function()
                            end,
                            function()
                            end
                        )
                    end
                end
                RageUI.List(
                    "Render Distance Modifier",
                    N,
                    y,
                    "~g~Lowering this will increase your FPS!",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        y = ag
                    end,
                    function()
                    end,
                    nil
                )
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "killeffects"),
            true,
            true,
            true,
            function()
                RageUI.Checkbox(
                    "Create Lightning",
                    "",
                    a4.lightning,
                    {},
                    function(ad, af, ae, ah)
                        if af then
                            a4.lightning = ah
                            a6()
                        end
                    end
                )
                RageUI.Checkbox(
                    "Ped Flash",
                    "",
                    a4.pedFlash,
                    {},
                    function(ad, af, ae, ah)
                        if af then
                            a4.pedFlash = ah
                            a6()
                        end
                    end
                )
                if a4.pedFlash then
                    RageUI.List(
                        "Ped Flash Red",
                        W,
                        a4.pedFlashRGB[1],
                        "",
                        {},
                        a4.pedFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.pedFlashRGB[1] ~= ag then
                                a4.pedFlashRGB[1] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Ped Flash Green",
                        W,
                        a4.pedFlashRGB[2],
                        "",
                        {},
                        a4.pedFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.pedFlashRGB[2] ~= ag then
                                a4.pedFlashRGB[2] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Ped Flash Blue",
                        W,
                        a4.pedFlashRGB[3],
                        "",
                        {},
                        a4.pedFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.pedFlashRGB[3] ~= ag then
                                a4.pedFlashRGB[3] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Ped Flash Intensity",
                        Y,
                        a4.pedFlashIntensity,
                        "",
                        {},
                        a4.pedFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.pedFlashIntensity ~= ag then
                                a4.pedFlashIntensity = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Ped Flash Time",
                        _,
                        a4.pedFlashTime,
                        "",
                        {},
                        a4.pedFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.pedFlashTime ~= ag then
                                a4.pedFlashTime = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                end
                RageUI.Checkbox(
                    "Screen Flash",
                    "",
                    a4.screenFlash,
                    {},
                    function(ad, af, ae, ah)
                        if af then
                            a4.screenFlash = ah
                            a6()
                        end
                    end
                )
                if a4.screenFlash then
                    RageUI.List(
                        "Screen Flash Red",
                        W,
                        a4.screenFlashRGB[1],
                        "",
                        {},
                        a4.screenFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.screenFlashRGB[1] ~= ag then
                                a4.screenFlashRGB[1] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Screen Flash Green",
                        W,
                        a4.screenFlashRGB[2],
                        "",
                        {},
                        a4.screenFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.screenFlashRGB[2] ~= ag then
                                a4.screenFlashRGB[2] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Screen Flash Blue",
                        W,
                        a4.screenFlashRGB[3],
                        "",
                        {},
                        a4.screenFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.screenFlashRGB[3] ~= ag then
                                a4.screenFlashRGB[3] = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Screen Flash Intensity",
                        Y,
                        a4.screenFlashIntensity,
                        "",
                        {},
                        a4.screenFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.screenFlashIntensity ~= ag then
                                a4.screenFlashIntensity = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                    RageUI.List(
                        "Screen Flash Time",
                        _,
                        a4.screenFlashTime,
                        "",
                        {},
                        a4.screenFlash,
                        function(ad, ae, af, ag)
                            if ae and a4.screenFlashTime ~= ag then
                                a4.screenFlashTime = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                end
                RageUI.List(
                    "Timecycle Flash",
                    a3,
                    a4.timecycle,
                    "",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if ae and a4.timecycle ~= ag then
                            a4.timecycle = ag
                            a6()
                        end
                    end,
                    function()
                    end
                )
                if a4.timecycle ~= 1 then
                    RageUI.List(
                        "Timecycle Flash Time",
                        _,
                        a4.timecycleTime,
                        "",
                        {},
                        true,
                        function(ad, ae, af, ag)
                            if ae and a4.timecycleTime ~= ag then
                                a4.timecycleTime = ag
                                a6()
                            end
                        end,
                        function()
                        end
                    )
                end
                RageUI.List(
                    "~y~Particles~w~",
                    a1,
                    a4.particle,
                    "",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if ae and a4.particle ~= ag then
                            if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
                                notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                                notify("~y~Available @ store.vicestudios.uk")
                            end
                            a4.particle = ag
                            a6()
                        end
                    end,
                    function()
                    end
                )
                local au = 0
                if a4.lightning then
                    au = math.max(au, 1000)
                end
                if a4.pedFlash then
                    au = math.max(au, a0[a4.pedFlashTime])
                end
                if a4.screenFlash then
                    au = math.max(au, a0[a4.screenFlashTime])
                end
                if a4.timecycleTime ~= 1 then
                    au = math.max(au, X[a4.timecycleTime])
                end
                if a4.particle ~= 1 then
                    au = math.max(au, 1000)
                end
                if GetGameTimer() - a5 > au + 1000 then
                    VICE.addKillEffect(PlayerPedId(), true)
                    a5 = GetGameTimer()
                end
                DrawAdvancedTextNoOutline(0.59, 0.9, 0.005, 0.0028, 1.5, "PREVIEW", 255, 0, 0, 255, 2, 0)
            end,
            function()
            end
        )
        RageUI.IsVisible(
            RMenu:Get("SettingsMenu", "bloodeffects"),
            true,
            true,
            true,
            function()
                RageUI.List(
                    "~y~Head",
                    a1,
                    a8.head,
                    "Effect that displays when you hit the head.",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if a8.head ~= ag then
                            if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
                                notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                                notify("~y~Available @ store.vicestudios.uk")
                            end
                            a8.head = ag
                            a9()
                        end
                        if af then
                            VICE.addBloodEffect("head", 0x796E, PlayerPedId())
                        end
                    end
                )
                RageUI.List(
                    "~y~Body",
                    a1,
                    a8.body,
                    "Effect that displays when you hit the body.",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if a8.body ~= ag then
                            if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
                                notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                                notify("~y~Available @ store.vicestudios.uk")
                            end
                            a8.body = ag
                            a9()
                        end
                        if af then
                            VICE.addBloodEffect("body", 0x0, PlayerPedId())
                        end
                    end
                )
                RageUI.List(
                    "~y~Arms",
                    a1,
                    a8.arms,
                    "Effect that displays when you hit the arms.",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if a8.arms ~= ag then
                            if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
                                notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                                notify("~y~Available @ store.vicestudios.uk")
                            end
                            a8.arms = ag
                            a9()
                        end
                        if af then
                            VICE.addBloodEffect("arms", 0xBB0, PlayerPedId())
                            VICE.addBloodEffect("arms", 0x58B7, PlayerPedId())
                        end
                    end
                )
                RageUI.List(
                    "~y~Legs",
                    a1,
                    a8.legs,
                    "Effect that displays when you hit the legs.",
                    {},
                    true,
                    function(ad, ae, af, ag)
                        if a8.legs ~= ag then
                            if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
                                notify("~y~You need to be a subscriber of VICE Plus or VICE Platinum to use this feature.")
                                notify("~y~Available @ store.vicestudios.uk")
                            end
                            a8.legs = ag
                            a9()
                        end
                        if af then
                            VICE.addBloodEffect("legs", 0x3FCF, PlayerPedId())
                            VICE.addBloodEffect("legs", 0xB3FE, PlayerPedId())
                        end
                    end
                )
            end,
            function()
            end
        )
    end
)
RegisterNetEvent("VICE:OpenSettingsMenu")
AddEventHandler("VICE:OpenSettingsMenu", function(av)
    if not av then
        RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu"), true)
       -- drawNativeNotification("Press ~INPUT_REPLAY_START_STOP_RECORDING_SECONDARY~ to toggle the Settings Menu.")
    end
end)

RegisterCommand("opensettingsmenu",function()
        local user_id = GetPlayerServerId(PlayerId())
        TriggerServerEvent("VICE:OpenSettings")
    end
)
RegisterKeyMapping("opensettingsmenu", "Opens the Settings menu", "keyboard", "F2")
Citizen.CreateThread(
    function()
        while true do
            OverrideLodscaleThisFrame(x[y][2])
            if not (VICE.getStaffLevel() > 0) then
                if IsUsingKeyboard(2) and IsControlJustPressed(1, 289) then
                    RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu"), not RageUI.Visible(RMenu:Get("SettingsMenu", "MainMenu")))
                end
            end
            Wait(0)
        end
    end
)
AddEventHandler("VICE:enteredCity", function()
end)
AddEventHandler("VICE:leftCity", function()
end)
local function al(am)
    local an = GetEntityCoords(am, true)
    local aw = GetGameTimer()
    local ax = math.floor(X[a4.pedFlashRGB[1]] * 255)
    local ay = math.floor(X[a4.pedFlashRGB[2]] * 255)
    local az = math.floor(X[a4.pedFlashRGB[3]] * 255)
    local aA = Z[a4.pedFlashIntensity]
    local aB = a0[a4.pedFlashTime]
    while GetGameTimer() - aw < aB do
        local aC = (aB - (GetGameTimer() - aw)) / aB
        local aD = aA * 25.0 * aC
        DrawLightWithRange(an.x, an.y, an.z + 1.0, ax, ay, az, 50.0, aD)
        Citizen.Wait(0)
    end
end
local function aE()
    local aw = GetGameTimer()
    local ax = math.floor(X[a4.screenFlashRGB[1]] * 255)
    local ay = math.floor(X[a4.screenFlashRGB[2]] * 255)
    local az = math.floor(X[a4.screenFlashRGB[3]] * 255)
    local aA = Z[a4.screenFlashIntensity]
    local aB = a0[a4.screenFlashTime]
    while GetGameTimer() - aw < aB do
        local aC = (aB - (GetGameTimer() - aw)) / aB
        local aD = math.floor(25.5 * aA * aC)
        DrawRect(0.0, 0.0, 2.0, 2.0, ax, ay, az, aD)
        Citizen.Wait(0)
    end
end
local function aF(am)
    local an = GetEntityCoords(am, true)
    local aG = a2[a4.particle]
    VICE.loadPtfx(aG[1])
    UseParticleFxAsset(aG[1])
    StartParticleFxNonLoopedAtCoord(aG[2], an.x, an.y, an.z, 0.0, 0.0, 0.0, aG[3], false, false, false)
    RemoveNamedPtfxAsset(aG[1])
end
local function aH()
    local aw = GetGameTimer()
    local aB = a0[a4.timecycleTime]
    SetTimecycleModifier(a3[a4.timecycle])
    while GetGameTimer() - aw < aB do
        local aC = (aB - (GetGameTimer() - aw)) / aB
        SetTimecycleModifierStrength(1.0 * aC)
        Citizen.Wait(0)
    end
    ClearTimecycleModifier()
end
function VICE.addKillEffect(aI, aJ)
    if a4.lightning then
        ForceLightningFlash()
    end
    if a4.pedFlash then
        Citizen.CreateThreadNow(
            function()
                al(aI)
            end
        )
    end
    if a4.screenFlash then
        Citizen.CreateThreadNow(
            function()
                aE()
            end
        )
    end
    if a4.particle ~= 1 and (tVICE.isPlatClub() or aJ) then
        Citizen.CreateThreadNow(
            function()
                aF(aI)
            end
        )
    end
    if a4.timecycle ~= 1 then
        Citizen.CreateThreadNow(
            function()
                aH()
            end
        )
    end
end
function VICE.addBloodEffect(aK, aL, am)
    local aM = a8[aK]
    if aM > 1 then
        local aG = a2[aM]
        VICE.loadPtfx(aG[1])
        UseParticleFxAsset(aG[1])
        StartParticleFxNonLoopedOnPedBone(aG[2], am, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, aL, aG[3], false, false, false)
        RemoveNamedPtfxAsset(aG[1])
    end
end
AddEventHandler(
    "VICE:onPlayerKilledPed",
    function(aN)
        VICE.addKillEffect(aN, false)
    end
)
local aO = {
    [0x0] = "body",
    [0x2E28] = "body",
    [0xE39F] = "legs",
    [0xF9BB] = "legs",
    [0x3779] = "legs",
    [0x83C] = "legs",
    [0xCA72] = "legs",
    [0x9000] = "legs",
    [0xCC4D] = "legs",
    [0x512D] = "legs",
    [0xE0FD] = "body",
    [0x5C01] = "body",
    [0x60F0] = "body",
    [0x60F1] = "body",
    [0x60F2] = "body",
    [0xFCD9] = "body",
    [0xB1C5] = "arms",
    [0xEEEB] = "arms",
    [0x49D9] = "arms",
    [0x67F2] = "arms",
    [0xFF9] = "arms",
    [0xFFA] = "arms",
    [0x67F3] = "arms",
    [0x1049] = "arms",
    [0x104A] = "arms",
    [0x67F4] = "arms",
    [0x1059] = "arms",
    [0x105A] = "arms",
    [0x67F5] = "arms",
    [0x1029] = "arms",
    [0x102A] = "arms",
    [0x67F6] = "arms",
    [0x1039] = "arms",
    [0x103A] = "arms",
    [0x29D2] = "arms",
    [0x9D4D] = "arms",
    [0x6E5C] = "arms",
    [0xDEAD] = "arms",
    [0xE5F2] = "arms",
    [0xFA10] = "arms",
    [0xFA11] = "arms",
    [0xE5F3] = "arms",
    [0xFA60] = "arms",
    [0xFA61] = "arms",
    [0xE5F4] = "arms",
    [0xFA70] = "arms",
    [0xFA71] = "arms",
    [0xE5F5] = "arms",
    [0xFA40] = "arms",
    [0xFA41] = "arms",
    [0xE5F6] = "arms",
    [0xFA50] = "arms",
    [0xFA51] = "arms",
    [0x9995] = "head",
    [0x796E] = "head",
    [0x5FD4] = "head",
    [0xD003] = "body",
    [0x45FC] = "body",
    [0x1D6B] = "legs",
    [0xB23F] = "legs"
}
AddEventHandler(
    "VICE:onPlayerDamagePed",
    function(aN)
        if not tVICE.isPlusClub() and not tVICE.isPlatClub() then
            return
        end
        local aP, aL = GetPedLastDamageBone(aN, 0)
        if aP then
            local aQ = GetPedBoneIndex(aN, aL)
            local aR = GetWorldPositionOfEntityBone(aN, aQ)
            local aS = aO[aL]
            if not aS then
                local aT = GetWorldPositionOfEntityBone(aN, GetPedBoneIndex(aN, 0x9995))
                local aU = GetWorldPositionOfEntityBone(aN, GetPedBoneIndex(aN, 0x2E28))
                if aR.z >= aT.z - 0.01 then
                    aS = "head"
                elseif aR.z < aU.z then
                    aS = "legs"
                else
                    local aV = GetEntityCoords(aN, true)
                    local aW = #(aV.xy - aR.xy)
                    if aW > 0.075 then
                        aS = "arms"
                    else
                        aS = "body"
                    end
                end
            end
            VICE.addBloodEffect(aS, aL, aN)
        end
    end
)
RegisterNetEvent("VICE:gotDiscord")
AddEventHandler(
    "VICE:gotDiscord",
    function()
        RageUI.Visible(RMenu:Get("SettingsMenu", "changediscord"), true)
    end
)



local pfp = nil

function VICE.getUserProfilePFP()
    if pfp == nil then
        TriggerServerEvent("VICE:requestAvatar", VICE.getUserId())
    end
    return pfp
end


RegisterNetEvent('VICE:receiveAvatar')
AddEventHandler('VICE:receiveAvatar', function(avatar)
    pfp = avatar
end)