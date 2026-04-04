local a = false
local b = {}
SetNuiFocus(false, false)
local c, d, e, ukbf, f, g = {}, {}, {}, {}, {}
RegisterNetEvent(
    "VICE:gotJobTypes",
    function(h, i, j, ukbf, k, l)
        c = h
        d = i
        e = j
        ukbf = j
        f = k
        g = l
    end
)
function VICE.getJobType(m)
    jobGroups = tVICE.getCurrentPlayerInfo("jobs")
    if jobGroups then
        for a, b in pairs(jobGroups) do
            if b.user_id == m then
                for n, o in pairs(b.jobs) do
                    if c[n] and n == "HEMS Clocked" then
                        return "hems"
                    elseif c[n] then
                        return "nhs"
                    elseif d[n] and n == "NPAS Clocked" then
                        return "npas"
                    elseif d[n] then
                        return "metpd"
                    elseif e[n] then
                        return "lfb"
                    elseif ukbf[n] then
                        return "ukbf"
                    elseif f[n] then
                        return "hmp"
                    elseif g and g[n] then
                        return "cid"
                    end
                end
                return ""
            end
        end
        return ""
    end
end