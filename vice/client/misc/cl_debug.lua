isDebugModeEnabled = false
function tVICE.toggleDebugMode()
    isDebugModeEnabled = not isDebugModeEnabled
    local a = isDebugModeEnabled and "enabled" or "disabled"
    print("[VICE] debug mode " .. a)
end
function tVICE.debugLog(...)
    if isDebugModeEnabled then
        print("[VICE DEBUG] ", ...)
    end
end
function tVICE.debugLog_export(b, ...)
    if isDebugModeEnabled then
        local c = string.format("[VICE DEBUG : %s]", b)
        print(c, ...)
    end
end
RegisterCommand(
    "debugmode",
    function()
        tVICE.toggleDebugMode()
    end,
    false
)
exports(
    "debugLog",
    function(...)
        local b = GetInvokingResource()
        tVICE.debugLog_export(b, ...)
    end
)
