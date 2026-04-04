local a = {}
function tVICE.createCheckpoint(b, c, d, e, f, g, h, i, j, k, l, m, n, o, p)
    if a[b] == nil then
        a[b] = {}
    end
    local q = "checkpoint_" .. tVICE.generateUUID("checkpoints", 7, "alphanumeric")
    local r = CreateCheckpoint(c, d, e, f, g, h, i, j, k, l, m, n, o)
    SetCheckpointRgba2(r, 0, 204, 204, 150)
    local s = tVICE.addBlip(d, e, f, 570, 5)
    a[b][q] = {checkpointId = r, blipId = s}
    local function t()
    end
    local function u()
    end
    local function v()
        p(q, r)
    end
    tVICE.useIncreasedAreaRefreshRate(true)
    VICE.createArea(q, vector3(d, e, f), j * 1.25, 10, v, t, u, {})
    return r, q
end
function tVICE.deleteCheckpoint(b, r)
    if a[b] then
        if a[b][r] then
            if a[b][r].checkpointId then
                DeleteCheckpoint(a[b][r].checkpointId)
            end
        end
        if a[b][r] then
            if a[b][r].blipId then
                tVICE.removeBlip(a[b][r].blipId)
            end
        end
        tVICE.removeArea(r)
        a[b][r] = nil
        if table.count(a) == 0 then
            tVICE.useIncreasedAreaRefreshRate(false)
        end
    else
        print(b .. " is not valid.")
    end
end
RegisterCommand(
    "previewcheckpointstypes",
    function()
        for w = 1, 100, 1 do
            local r =
                CreateCheckpoint(
                w,
                475.82565307617 + w * 25,
                5562.2729492188,
                794.68963623047,
                475.82565307617,
                5562.2729492188,
                794.68963623047,
                10.0,
                255,
                255,
                0,
                127,
                0
            )
            print("made", w, r)
            Wait(250)
        end
    end,
    false
)
