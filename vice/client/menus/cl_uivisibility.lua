local disableMainUI = false
local disableKillfeed = false
local disableChat = false
local hC = false
local hD = false
local hZ = true
local hF = false
local A = 1
local B = {"VICE", "Fortnite"}

function VICE.setShowHealthPercentageFlag(q)
    SetResourceKvp("vice_healthpercentage", tostring(q))
end

local t = GetResourceKvpString("vice_healthpercentage") or "false"
if t == "false" then
    h = false
else
    h = true
end

local C = GetResourceKvpString("vice_hideeventannouncement") or "false"
if C == "false" then
    g = false
else
    g = true
end

-- local B = GetResourceKvpString("vice_reducedchatopacity") or "false"
-- if B == "false" then
--     f = false
--     TriggerEvent("VICE:chatReduceOpacity", false)
-- else
--     f = true
--     TriggerEvent("VICE:chatReduceOpacity", true)
-- end
local Dz = GetResourceKvpString("vice_healthcolour") or "false"
if Dz == "false" then
    hC = false
else
    hC = true
end

function VICE.setReducedChatOpacity(A)
    SetResourceKvp("vice_reducedchatopacity", tostring(A))
end

function VICE.colourHealthBar(A)
    SetResourceKvp("vice_healthcolour", tostring(A))
end

function VICE.setHideEventAnnouncementFlag(A)
    SetResourceKvp("vice_hideeventannouncement", tostring(A))
end

function VICE.getShowHealthPercentageFlag()
    return h
end

function VICE.getShowCurrentWeapon()
    return hD
end

function VICE.getShowNewInventoryUI()
    return hZ
end

function VICE.getShowcolourHealthBar()
    return hC
end

function VICE.getHideEventAnnouncementFlag()
    return g
end

RMenu.Add("uivisibility", "main", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~UI Visibility", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))
RMenu.Add("uivisibility", "misc", RageUI.CreateSubMenu(RMenu:Get("SettingsMenu", "MainMenu"), "", "~b~UI Visibility", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "settings"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('uivisibility', 'main')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            local function a9()
                VICE.showUI()
                hideUI = true
            end
            local function aa()
                VICE.showUI()
                hideUI = false
            end
            local function a9()
                tVICE.toggleBlackBars()
                e = true
                ExecuteCommand("hideui")
            end
            local function aa()
                tVICE.toggleBlackBars()
                e = false
                ExecuteCommand("showui")
            end
            RageUI.Checkbox(
                "Hide Event Announcements",
                "Hides the big messages across your screen. The event will still be shown in chat.",
                g,
                {},
                function()
                end,
                function()
                    g = true
                    VICE.setHideEventAnnouncementFlag(true)
                end,
                function()
                    g = false
                    VICE.setHideEventAnnouncementFlag(false)
                end
            )
            RageUI.Checkbox(
                "Show Health Percentage",
                "Displays the health and armour percentage on the bars.",
                h,
                {},
                function()
                end,
                function()
                    h = true
                    VICE.setShowHealthPercentageFlag(true)
                end,
                function()
                    h = false
                    VICE.setShowHealthPercentageFlag(false)
                end
            )
            RageUI.List(
                    "Health UI Type",
                    B,
                    A,
                    "Switch between health UI displays.",
                    {},
                    true,
                    function(at, au, av, aw)
                        if aw ~= A then
                            A = aw
                            tVICE.setHealthUIType(B[A])
                            SetResourceKvpInt("vice_health_ui_type", A)
                        end
                    end
                )
            RageUI.Checkbox(
                "Streetnames",
                "",
                tVICE.isStreetnamesEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tVICE.setStreetnamesEnabled(true)
                end,
                function()
                    tVICE.setStreetnamesEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Compass",
                "",
                tVICE.isCompassEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tVICE.setCompassEnabled(true)
                end,
                function()
                    tVICE.setCompassEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Cinematic Black Bars",
                "",
                e,
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                a9,
                aa
            )        
            RageUI.ButtonWithStyle("Miscellaneous","More useful settings.",{RightLabel = "→→→"},true,function(ad, ae, af)
            end,RMenu:Get("uivisibility", "misc"))
            RageUI.Separator("~y~These changes are persistent across restarts")
            RageUI.ButtonWithStyle(
                "Crosshair",
                "Create a custom built-in crosshair here.",
                {RightLabel = "→→→"},
                true,
                function(a4, a5, a6)
                end,
                RMenu:Get("crosshair", "main")
            )
            RageUI.Checkbox("Disable Main UI","/hideui",disableMainUI,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disableMainUI then
                        ExecuteCommand("showui")
                    else
                        ExecuteCommand("hideui")
                    end
                    disableMainUI = not disableMainUI
                end
            end)
            
            RageUI.Checkbox("Disable Killfeed","/togglekillfeed",disablekillfeed,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disablekillfeed then
                        ExecuteCommand("showkillfeed")
                    else
                        ExecuteCommand("disablekillfeed")
                    end
                    disablekillfeed = not disablekillfeed
                end
            end)

            RageUI.Checkbox("Disable Chat","/hidechat",disableChat,{Style = RageUI.CheckboxStyle.Car},function(Hovered, Active, Selected)
                if Selected then
                    if disableChat then
                        ExecuteCommand("showchat")
                    else
                        ExecuteCommand("hidechat")
                    end
                    disableChat = not disableChat
                end
            end)
            RageUI.Checkbox(
                "Reduce Chat Opacity",
                "",
                f,
                {},
                function()
                end,
                function()
                    f = true
                    VICE.setReducedChatOpacity(true)
                    TriggerEvent("VICE:chatReduceOpacity", true)
                end,
                function()
                    f = false
                    VICE.setReducedChatOpacity(false)
                    TriggerEvent("VICE:chatReduceOpacity", false)
                end
            )
        end)
    end
    if RageUI.Visible(RMenu:Get('uivisibility', 'misc')) then
        RageUI.DrawContent({ header = true, glare = true, instructionalButton = false}, function()
            RageUI.Checkbox(
                "What Three Words",
                "",
                tVICE.isW3WEnabled(),
                {RightBadge = RageUI.CheckboxStyle.Car},
                function(a4, a6, a5, a8)
                end,
                function()
                    tVICE.setW3WEnabled(true)
                end,
                function()
                    tVICE.setW3WEnabled(false)
                end
            )
            RageUI.Checkbox(
                "Show Health Colour",
                "Displays health colours depending on the damage.",
                hC,
                {},
                function()
                end,
                function()
                    hC = true
                    VICE.colourHealthBar(true)
                end,
                function()
                    hC = false
                    VICE.colourHealthBar(false)
                end
            )
        end)
    end
end)
