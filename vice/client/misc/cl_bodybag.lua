RegisterCommand("bodybag",function()
    local a = tVICE.getNearestPlayer(3)
    if a then
        TriggerServerEvent("VICE:requestBodyBag", a)
    else
        VICE.notify("No one dead nearby")
    end
end)

RegisterNetEvent("VICE:removeIfOwned",function(b)
    local c = VICE.getObjectId(b, "bodybag_removeIfOwned")
    if c then
        if DoesEntityExist(c) then
            if NetworkHasControlOfEntity(c) then
                DeleteEntity(c)
            end
        end
    end
end)

RegisterNetEvent("VICE:placeBodyBag",function()
    local d = VICE.getPlayerPed()
    local e = GetEntityCoords(d)
    local f = GetEntityHeading(d)
    SetEntityVisible(d, false, 0)
    local g = VICE.loadModel("xm_prop_body_bag")
    local h = CreateObject(g, e.x, e.y, e.z, true, true, true)
    DecorSetInt(h, decor, 955)
    PlaceObjectOnGroundProperly(h)
    SetModelAsNoLongerNeeded(g)
    local b = ObjToNet(h)
    TriggerServerEvent("VICE:removeBodybag", b)
    while GetEntityHealth(VICE.getPlayerPed()) <= 102 do
        Wait(0)
    end
    DeleteEntity(h)
    SetEntityVisible(d, true, 0)
end)
