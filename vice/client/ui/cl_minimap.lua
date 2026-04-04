local a = false
local b = 0
local function c()
    BeginScaleformMovieMethod(b, "SETUP_HEALTH_ARMOUR")
    ScaleformMovieMethodAddParamInt(3)
    EndScaleformMovieMethod()
    if IsDisabledControlJustReleased(0, 20) and IsUsingKeyboard(2) then
        if not a then
            SetBigmapActive(true, false)
            LastGameTimer = GetGameTimer()
            a = true
        elseif a then
            SetBigmapActive(false, false)
            LastGameTimer = 0
            a = false
        end
    end
end
VICE.createThreadOnTick(c)
Citizen.CreateThread(function()
    b = RequestScaleformMovie("minimap")
end)
