local a = {}
local b = 0.1
local c = false
local d = {0, 168, 255, 215}
local function e(f, g, h)
    local i, j, k, l = 255, 255, 255, 215
    if h then
        i, j, k, l = table.unpack(h)
    end
    local m, n, o = GetScreenCoordFromWorldCoord(f.x, f.y, f.z)
    local p = GetFinalRenderedCamCoord()
    local q = #(p - f)
    local r = 1 / q * 2
    local s = 1 / GetGameplayCamFov() * 100
    local r = r * s
    if m then
        SetTextScale(0.5, 0.5)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(i, j, k, l)
        SetTextDropShadow(0, 0, 0, 3,255)
        SetTextEdge(2, 0, 0, 0, 255)
        BeginTextCommandDisplayText("STRING")
        SetTextCentre(1)
        AddTextComponentSubstringPlayerName(g)
        EndTextCommandDisplayText(n, o)
    end
end
local function t(u, v, h, w, x)
    if not a[w] then
        a[w] = {}
    end
    table.insert(a[w], {type = u, msg = v, color = h})
    SetTimeout(
        x,
        function()
            table.remove(a[w], 1)
            if #a[w] == 0 then
                a[w] = nil
            end
        end
    )
end
local function y()
    for z, A in pairs(a) do
        local F = GetEntityBoneIndexByName(z, "IK_Head")
        local G = GetWorldPositionOfEntityBone(z, F)
        for C, D in pairs(a[z]) do
            local E = G + vector3(0.0, 0.0, 0.4 + b * C)
            e(E, D.msg, D.color)
        end
    end
end

VICE.createThreadOnTick(y)
RegisterNetEvent(
    "VICE:sendLocalChat",
    function(H, I, J)
        local K = GetPlayerFromServerId(H)
        if K ~= -1 then
            if GetPlayerFromServerId(H) == PlayerId() then
                if c then
                    TriggerEvent("chatMessage", "", {255, 0, 0}, " ^6 me | " .. I .. "  " .. "^6  " .. J)
                end
                t("me", J, d, VICE.getPlayerPed(), 10000)
            elseif
                #(GetEntityCoords(VICE.getPlayerPed()) - GetEntityCoords(GetPlayerPed(K))) < 7.01 and
                    HasEntityClearLosToEntity(VICE.getPlayerPed(), GetPlayerPed(K), 17) == 1
             then
                if c then
                    TriggerEvent("chatMessage", "", {255, 0, 0}, " ^6 me | " .. I .. "  " .. "^6  " .. J)
                end
                t("me", J, d, GetPlayerPed(K), 10000)
            end
        end
    end
)
