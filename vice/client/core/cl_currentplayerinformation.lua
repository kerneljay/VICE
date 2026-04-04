local a = {}
RegisterNetEvent("VICE:receiveCurrentPlayerInfo")
AddEventHandler("VICE:receiveCurrentPlayerInfo",function(b)
    a = b
end)
function tVICE.getCurrentPlayerInfo(c)
    for d, e in pairs(a) do
        if d == c then
            return e
        end
    end
end
function VICE.clientGetPlayerIsStaff(f)
    local g = tVICE.getCurrentPlayerInfo("currentStaff")
    if g then
        for h, i in pairs(g) do
            if i == f then
                return true
            end
        end
        return false
    end
end
