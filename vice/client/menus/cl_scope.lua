local function a()
    local b = GetResourceKvpString("vice_scope_horizontal")
    if b == nil or b == "" then
        return 50
    else
        return tonumber(b)
    end
end
local c = {}
local d = a()
for e = 1, 100 do
    table.insert(c, string.format("%d%%", e))
end
local function f()
    local b = GetResourceKvpString("vice_scope_vertical")
    if b == nil or b == "" then
        return 30
    else
        return tonumber(b)
    end
end
local g = {}
local h = f()
for e = 1, 100 do
    table.insert(g, string.format("%d%%", e))
end
local i = GetResourceKvpString("vice_scope_enabled") == "true"
local j = false
RMenu.Add(
    "scope",
    "main",
    RageUI.CreateMenu("Scope Settings", "Main Menu", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RageUI.CreateWhile(
    1.0,
    RMenu:Get("scope", "main"),
    function()
        RageUI.IsVisible(
            RMenu:Get("scope", "main"),
            true,
            false,
            true,
            function()
                j = true
                RageUI.List(
                    "Horizontal Position",
                    c,
                    d,
                    "The horizontal position of the distance text",
                    {},
                    true,
                    function(k, l, m, n)
                        d = n
                        if l then
                            SetResourceKvp("vice_scope_horizontal", tostring(n))
                        end
                    end,
                    function()
                    end
                )
                RageUI.List(
                    "Vertical Position",
                    g,
                    h,
                    "The vertical position of the distance text",
                    {},
                    true,
                    function(k, l, m, n)
                        h = n
                        if l then
                            SetResourceKvp("vice_scope_vertical", tostring(n))
                        end
                    end,
                    function()
                    end
                )
                RageUI.Checkbox(
                    "Enabled",
                    "Whether the distance should be shown when using a weapon scope",
                    i,
                    {},
                    function(k, m, l, o)
                        i = o
                        if l then
                            SetResourceKvp("vice_scope_enabled", tostring(o))
                        end
                    end
                )
            end
        )
    end
)
RegisterCommand(
    "scope",
    function()
        RageUI.Visible(RMenu:Get("scope", "main"), true)
    end,
    false
)
function VICE.doesCurrentWeaponHaveScope()
    local p = PlayerPedId()
    local q = GetCurrentPedWeaponEntityIndex(p)
    if q == 0 then
        return false
    end
    local r = {
        "component_at_scope_large",
        "component_at_scope_large_mk2",
        "component_at_scope_max",
        "component_at_scope_large_fixed_zoom",
        "component_at_scope_large_fixed_zoom_mk2"
    }
    for s, t in ipairs(r) do
        if HasWeaponGotWeaponComponent(q, t) then
            return true
        end
    end
    local u = GetSelectedPedWeapon(p)
    local v = GetWeapontypeGroup(u)
    local w = GetPedAmmoTypeFromWeapon(p, u)
    if v == "GROUP_SNIPER" and w ~= "AMMO_SHOTGUN" then
        return true
    end
    return false
end
local function x()
    local y = GetGameplayCamCoord()
    local z = GetGameplayCamRot(2)
    local A = VICE.rotationToDirection(z)
    local B = y + A * 500.0
    local C = StartExpensiveSynchronousShapeTestLosProbe(y.x, y.y, y.z, B.x, B.y, B.z, -1, PlayerPedId(), 4)
    local s, s, D, s, s = GetShapeTestResult(C)
    return #(y - D)
end
local function E()
    if i and (j or VICE.doesCurrentWeaponHaveScope() and IsPlayerFreeAiming(PlayerId())) then
        if j then
            j = RageUI.Visible(RMenu:Get("scope", "main"))
        end
        local F = math.round(x(), 0)
        DrawAdvancedText(d / 100.0, 1.0 - h / 100.0, 0.1, 0.002, 0.4, string.format("%dm", F), 255, 255, 255, 255, 0, 0)
    end
end
VICE.createThreadOnTick(E)
