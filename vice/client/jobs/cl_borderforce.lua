local a = {
    [1] = {
        prop = "prop_gate_military_01",
        prop_frame = "prop_gate_frame_02",
        prop_controller = "prop_rail_controller",
        offset = vector3(0.0, 0.0, 0.0),
        position = vector3(3036.9948730469, -3720.1071777344, 52.316680908203),
        gateRotation = vector3(0.0, 0.0, 60.0),
        gateClosePos = vector3(3043.5104980469, -3708.2917480469, 52.306392669678),
        controllerPos = vector3(3075.48, -3726.61, 53.12),
        controllerRotation = 60.0,
        rotation = 60.0,
        propObjHandler = 0,
        propFrameObjHandler = 0,
        propControllerHandler = 0,
        open = false,
        instruction = "none"
    },
    [2] = {
        prop = "prop_gate_military_01",
        prop_frame = "prop_gate_frame_02",
        prop_controller = "prop_rail_controller",
        offset = vector3(0.0, 0.0, 0.0),
        position = vector3(3051.1203613281, -3695.0749511719, 52.144271850586),
        gateRotation = vector3(0.0, 0.0, 240.0),
        gateClosePos = vector3(3044.7419433594, -3706.8791503906, 52.315803527832),
        controllerPos = vector3(3076.63, -3724.26, 53.12),
        controllerRotation = 60.0,
        rotation = 240.0,
        propObjHandler = 0,
        propFrameObjHandler = 0,
        propControllerHandler = 0,
        open = false,
        instruction = "none"
    },
    [3] = {
        prop = "prop_gate_military_01",
        prop_frame = "prop_gate_frame_02",
        prop_controller = "prop_rail_controller",
        offset = vector3(0.0, 0.0, 0.0),
        position = vector3(3110.7670898438, -3761.17578125, 53.426260070801),
        gateRotation = vector3(0.0, 0.0, 60.0),
        gateClosePos = vector3(3116.8354492188, -3749.6352539062, 53.429805755615),
        controllerPos = vector3(3079.81, -3729.21, 53.32),
        controllerRotation = 240.0,
        rotation = 60.0,
        propObjHandler = 0,
        propFrameObjHandler = 0,
        propControllerHandler = 0,
        open = false,
        instruction = "none"
    },
    [4] = {
        prop = "prop_gate_military_01",
        prop_frame = "prop_gate_frame_02",
        prop_controller = "prop_rail_controller",
        offset = vector3(0.0, 0.0, 0.0),
        position = vector3(3124.4362792969, -3736.4191894531, 53.42196975708),
        gateRotation = vector3(0.0, 0.0, 240.0),
        gateClosePos = vector3(3118.3889160156, -3747.9411621094, 53.429008483887),
        controllerPos = vector3(3081.18, -3727.03, 53.32),
        controllerRotation = 240.0,
        rotation = 240.0,
        propObjHandler = 0,
        propFrameObjHandler = 0,
        propControllerHandler = 0,
        open = false,
        instruction = "none"
    }
}
Citizen.CreateThread(function()
    for b, c in pairs(a) do
        local d = VICE.loadModel(c.prop)
        local e = VICE.loadModel(c.prop_frame)
        local f = VICE.loadModel(c.prop_controller)
        local g = CreateObject(d, c.position.x, c.position.y, c.position.z - 1, false, false, true)
        a[b]["propObjHandler"] = g
        SetEntityHeading(a[b].propObjHandler, a[b].rotation)
        SetEntityInvincible(a[b].propObjHandler, true)
        FreezeEntityPosition(a[b].propObjHandler, true)
        if a[b].gateRotation ~= nil then
            SetEntityRotation(a[b].propObjHandler,a[b].gateRotation.x,a[b].gateRotation.y,a[b].gateRotation.z,2,false)
        end
        local g =CreateObject(e,c.position.x + c.offset.x,c.position.y + c.offset.y,c.position.z + c.offset.z - 1,false,true,false)
        a[b]["propFrameObjHandler"] = g
        SetEntityHeading(a[b].propFrameObjHandler, a[b].rotation)
        SetEntityInvincible(a[b].propFrameObjHandler, true)
        FreezeEntityPosition(a[b].propFrameObjHandler, true)
        if a[b].gateRotation ~= nil then
            SetEntityRotation(a[b].propFrameObjHandler,a[b].gateRotation.x,a[b].gateRotation.y,a[b].gateRotation.z,2,false)
        end
        local g = CreateObject(f, c.controllerPos.x, c.controllerPos.y, c.controllerPos.z - 1, false, false, true)
        a[b]["propControllerHandler"] = g
        SetEntityHeading(g, a[b].controllerRotation)
        SetEntityInvincible(g, true)
        FreezeEntityPosition(g, true)
        SetModelAsNoLongerNeeded(d)
        SetModelAsNoLongerNeeded(e)
        SetModelAsNoLongerNeeded(f)
    end
end)
Citizen.CreateThread(function()
    local h = 500
    while true do
        for b, c in pairs(a) do
            if c.instruction == "open" then
                local i = a[b].propObjHandler
                local j = GetEntityCoords(i)
                if #(j - c.position) < 1.5 then
                    a[b].instruction = "none"
                end
                SetEntityCoordsNoOffset(i,j.x + (c.position.x - c.gateClosePos.x) / h,j.y + (c.position.y - c.gateClosePos.y) / h,j.z)
            end
            if c.instruction == "close" then
                local i = a[b].propObjHandler
                local j = GetEntityCoords(i)
                if #(j - c.gateClosePos) < 7 then
                    a[b].instruction = "none"
                end
                SetEntityCoordsNoOffset(i,j.x + (c.gateClosePos.x - c.position.x) / h,j.y + (c.gateClosePos.y - c.position.y) / h,j.z)
            end
        end
        Wait(0)
    end
end)
RegisterNetEvent("VICE:setUKBFOnDuty",function(value)
    globalOnUKBFDuty = value
end)
AddEventHandler("VICE:onClientSpawn", function(k, l)
    if l then
        local m = function(n) end
        local o = function(n) end
        local p = function(n)
            if globalOnUKBFDuty or VICE.getStaffLevel() > 0 then
                local b = n.objectId
                if a[b].open then
                    if IsControlJustPressed(0, 38) then
                        VICE.notify("~g~Gate closing...")
                        TriggerServerEvent("VICE:setBorderState", b, "close")
                    end
                    VICE.DrawText3D(a[b].controllerPos, "Press [E] to close gate", 0.35)
                else
                    VICE.DrawText3D(a[b].controllerPos, "Press [E] to open gate", 0.35)
                    if IsControlJustPressed(0, 38) then
                        VICE.notify("~g~Gate opening...")
                        TriggerServerEvent("VICE:setBorderState", b, "open")
                    end
                end
            end
        end
        for b, c in pairs(a) do
            VICE.createArea("border_" .. b, c.controllerPos, 1.5, 6, m, o, p, {objectId = b})
        end
    end
end)

AddEventHandler("onResourceStop", function(q)
    if q == GetCurrentResourceName() then
        for b, c in pairs(a) do
            DeleteObject(a[b].propObjHandler)
            DeleteObject(a[b].propFrameObjHandler)
            DeleteObject(a[b].propControllerHandler)
        end
    end
end)

RegisterNetEvent("VICE:gotBorderState")
AddEventHandler("VICE:gotBorderState", function(b, r)
    a[b].instruction = r
    if r == "open" then
        a[b].open = true
    elseif r == "close" then
        a[b].open = false
    end
end)

RegisterNetEvent("VICE:gotFullBorderStates")
AddEventHandler("VICE:gotFullBorderStates", function(s)
    for b, c in pairs(s) do
        if c.open and not a[b].open then
            a[b].instruction = "open"
            a[b].open = true
        end
        if not c.open and not a[b].open then
            a[b].instruction = "close"
            a[b].open = false
        end
    end
end)

AddEventHandler("VICE:onClientSpawn", function(k, l)
    if l then
        TriggerServerEvent("VICE:getGateStates")
    end
end)