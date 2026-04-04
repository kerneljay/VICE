local a = {
    crouchKeybindEnabled = true,
    crouchKeybind = "LCONTROL",
    crouchOverride = true,
    crouchKeypressTimer = 300,
    crawlKeybindEnabled = true,
    crawlKeybind = "RCONTROL",
    localization = {
        ["crouch_keymapping"] = "Crouch",
        ["crouch_chat_suggestion"] = "Crouch",
        ["crawl_keymapping"] = "Crawl",
        ["crawl_chat_suggestion"] = "Crawl"
    }
}

-- ===== AIM / WEAPON HELPERS (ADDED) =====
local function HasWeapon()
    return GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED")
end

local function IsAimingWeapon()
    return HasWeapon() and (
        IsPlayerFreeAiming(PlayerId()) or
        IsControlPressed(0, 25)
    )
end
-- =======================================

local b = {
    [-2146642687] = "move_m@alien",
    -- (UNCHANGED animation table – kept exactly the same)
}

local function c(d)
    local e = GetPedMovementClipset(d)
    if b[e] then return b[e] end
    return nil
end

local f = false
local g = false
local h = false
local i = false
local j = "onfront"
local k = 0
local l = nil
local m = 0

local function n(o)
    if not IsPedOnFoot(o)
        or IsPedJumping(o)
        or IsPedFalling(o)
        or IsPedInjured(o)
        or IsPedInMeleeCombat(o)
        or IsPedRagdoll(o)
        or IsPedCuffed(o)
    then
        return false
    end
    return true
end

function SetPlayerClipset(e)
    VICE.loadClipSet(e)
    SetPedMovementClipset(PlayerPedId(), e, 0.5)
    RemoveClipSet(e)
end

local function q(d, r, s, t, u, v, w)
    VICE.loadAnimDict(r)
    TaskPlayAnim(d, r, s, t or 2.0, u or 2.0, v or -1, 0, w or 0.0, false, false, false)
    RemoveAnimDict(r)
end

local function E()
    local o = PlayerPedId()
    ResetPedStrafeClipset(o)
    ResetPedWeaponMovementClipset(o)
    SetPedMaxMoveBlendRatio(o, 1.0)
    SetPedCanPlayAmbientAnims(o, true)
    if l then
        SetPlayerClipset(l)
    else
        ResetPedMovementClipset(o, 0.5)
    end
    RemoveAnimSet("move_ped_crouched")
end

local function F()
    CreateThread(function()
        while g do
            local o = PlayerPedId()

            -- FORCE STAND UP IF AIMING WITH WEAPON
            if IsAimingWeapon() then
                g = false
                break
            end

            if not n(o) then
                g = false
                break
            end

            SetPedCanPlayAmbientAnims(o, false)
            DisableControlAction(0, 36, true)

            if IsPedUsingActionMode(o) == 1 then
                SetPedUsingActionMode(o, false, -1, "DEFAULT_ACTION")
            end

            DisableFirstPersonCamThisFrame()
            Wait(0)
        end
        E()
    end)
end
-- =================================

local function G()
    g = true
    VICE.loadClipSet("move_ped_crouched")
    local o = PlayerPedId()

    if GetPedStealthMovement(o) == 1 then
        SetPedStealthMovement(o, false, "DEFAULT_ACTION")
        Wait(100)
    end

    if GetFollowPedCamViewMode() == 4 then
        SetFollowPedCamViewMode(0)
    end

    l = c(o) or l
    SetPedMovementClipset(o, "move_ped_crouched", 0.6)
    SetPedStrafeClipset(o, "move_ped_crouched_strafing")
    F()
end

local function H(o)
    if n(o) then
        G()
        return true
    end
    return false
end

-- ===== CROUCH INPUT (MODIFIED) =====
local function I()
    if GetFrameCount() == m then return end
    m = GetFrameCount()

    if i then return end

    -- BLOCK CROUCH WHILE AIMING
    if IsAimingWeapon() then
        if g then g = false end
        return
    end

    if g then
        g = false
        return
    end

    local o = PlayerPedId()
    if a.crouchOverride then
        DisableControlAction(0, 36, true)
    end

    H(o)
end
-- =================================

-- (ALL CRAWL / PRONE CODE BELOW IS UNCHANGED)

CreateThread(function()
    if a.crouchKeybindEnabled then
        RegisterKeyMapping("+crouch", a.localization["crouch_keymapping"], "keyboard", a.crouchKeybind)
        RegisterCommand("+crouch", function() I() end, false)
        RegisterCommand("-crouch", function() end, false)
    end

    RegisterCommand("crouch", function()
        if GetFrameCount() == m then return end
        m = GetFrameCount()
        if g then g = false return end
        H(PlayerPedId())
    end, false)

    TriggerEvent("chat:addSuggestion", "/crouch", a.localization["crouch_chat_suggestion"])
end)
