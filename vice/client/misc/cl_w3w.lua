local a = LoadResourceFile(GetCurrentResourceName(), "/ui/words.txt")
local b = {}
TriggerEvent("chat:addSuggestion","/w3w","Get your current W3W or search for another",{{name = "Words", help = "Example: tree.house.fall"}})
local function c(d)
    return math.floor(d + 0.5)
end
local function e(f)
    TriggerEvent("chat:addMessage", {color = {255, 0, 0}, multiline = true, args = {"W3W", f}})
end
local function g(table, h)
    for i in pairs(table) do
        if table[i] == h then
            return i
        end
    end
    return nil
end
local function j(k)
    if k:sub(-1) ~= "\n" then
        k = k .. "\n"
    end
    return k:gmatch("(.-)\n")
end
local function l(k)
    return k:match "^%s*(.*)":match "(.-)%s*$"
end
local function m(n, o)
    if o == nil then
        o = "%s"
    end
    local p = {}
    for q in string.gmatch(n, "([^" .. o .. "]+)") do
        table.insert(p, q)
    end
    return p
end
for r in j(a) do
    local p = r == "" and "(blank)" or r
    local k = l(r)
    if string.len(tostring(k)) > 1 then
        table.insert(b, tostring(k))
    end
end
function VICE.getW3W()
    local playerPed = VICE.getPlayerPed()
    local playerCoords = VICE.getPlayerCoords()
    local index1 = c(math.abs(playerCoords.x + 8000) / 8)
    local word1 = b[index1]
    local index2 = c(math.abs(playerCoords.y + 8000) / 8)
    local word2 = b[index2]
    local word3 = b[index1 + 10]
    return word1 .. "." .. word2 .. "." .. word3
end
RegisterCommand("w3wc",function(s, t)
    local u = VICE.getPlayerPed()
    if t[1] == nil then
        local v = VICE.getPlayerCoords()
        local w = c(math.abs(v.x + 8000) / 8)
        local x = b[w]
        local y = c(math.abs(v.y + 8000) / 8)
        local z = b[y]
        local A = b[w + 10]
        e("Your location is " .. x .. "." .. z .. "." .. A .. ".")
    else
        if t[1] then
            local B = m(t[1], ".")
            if B[1] ~= nil and B[2] ~= nil then
                local w = c(g(b, B[1]) * 8 - 8000)
                local y = c(g(b, B[2]) * 8 - 8000)
                if w ~= nil and y ~= nil then
                    local v = vector3(w, y, 20.0)
                    local C, D = GetGroundZFor_3dCoord(v.x, v.y, v.z, 0, false)
                    if C then
                        v.groundZ = D
                    end
                    ClearGpsPlayerWaypoint()
                    SetNewWaypoint(v.x, v.y)
                    e("Waypoint set for " .. t[1])
                else
                    e("Invalid W3W location")
                end
            else
                return
            end
        end
    end
end,false)
