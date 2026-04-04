function VICE.add3DTextForCoord(a, b, c, d, e)
    local function f(g)
        VICE.DrawText3D(g.coords, g.text, 0.2)
    end
    local h = tVICE.generateUUID("3dtext", 8, "alphanumeric")
    VICE.createArea("3dtext_" .. h,vector3(b, c, d),e,6.0,function()end,function()end,f,{coords = vector3(b, c, d), text = a})
end
function VICE.drawFloatingHelpText(a, i)
    AddTextEntry("instructionalText", a)
    SetFloatingHelpTextWorldPosition(1, i.x, i.y, i.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("instructionalText")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayHelp(2, false, false, -1)
end
function VICE.checkDistanceToCoords(coords, distance)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local targetCoords = vector3(coords.x, coords.y, coords.z)
    local actualDistance = #(playerCoords - targetCoords)
    return actualDistance <= distance
end
function VICE.floatingMarker(coords, middleText, largeTitle, subText, color)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local markerCoords = vector3(coords.x, coords.y, coords.z)
    local distance = #(playerCoords - markerCoords)
    local playerCoords = GetEntityCoords(PlayerPedId())
    local direction = vector3(playerCoords.x - markerCoords.x, playerCoords.y - markerCoords.y, 0)
    local rotation = vector3(0.0, 0.0, 270.0 - math.deg(math.atan2(direction.y, direction.x)))
    local Q = RequestScaleformMovie("mp_mission_name_freemode")
    while not HasScaleformMovieLoaded(Q) do
        Citizen.Wait(0)
    end
    DrawMarker(1, markerCoords.x, markerCoords.y, markerCoords.z - 1.0, 0, 0, 0, 0, 0, 0, 12.0, 12.0, 4.0, color.r, color.g, color.b, color.a, false, false, 2, false, false, false, false)
    BeginScaleformMovieMethod(Q, "SET_MISSION_INFO")
    ScaleformMovieMethodAddParamPlayerNameString(middleText)
    ScaleformMovieMethodAddParamPlayerNameString(largeTitle)
    ScaleformMovieMethodAddParamPlayerNameString("0")
    ScaleformMovieMethodAddParamPlayerNameString("")
    ScaleformMovieMethodAddParamPlayerNameString("")
    ScaleformMovieMethodAddParamPlayerNameString("")
    ScaleformMovieMethodAddParamPlayerNameString("")
    ScaleformMovieMethodAddParamPlayerNameString("0")
    ScaleformMovieMethodAddParamPlayerNameString("0")
    ScaleformMovieMethodAddParamPlayerNameString(subText)
    EndScaleformMovieMethod()
    DrawScaleformMovie_3dSolid(Q, markerCoords.x, markerCoords.y, markerCoords.z - 0.5, rotation.x, rotation.y, rotation.z, 4.0, 4.0, 1.0, 14.0, 14.0, 2.0, 2)
end
function VICE.DrawText3D(i, a, j, k, l, m, noShadow, noOutline)
    local n, b, c = GetScreenCoordFromWorldCoord(i.x, i.y, i.z, 0.0, 0.0)
    if not n then
        return
    end
    SetTextScale(j, j)
    SetTextFont(k or 0)
    if m then
        SetTextColour(m[1], m[2], m[3], m[4])
    else
        SetTextColour(255, 255, 255, 255)
    end
    SetTextCentre(true)
    SetTextDropshadow(0, 0, 0, 0, 55)
    if not noShadow then
        SetTextDropShadow()
    end
    if not noOutline then
        SetTextOutline()
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b, c)
    if l then
        local o = #a / 370
        DrawRect(b, c + 0.0125, 0.015 + o, 0.03, 41, 41, 41, 125)
    end
end
function VICE.DrawText(b, c, a, j, k, p, m, q)
    SetTextScale(j, j)
    SetTextFont(k or 0)
    if p then
        SetTextJustification(p)
    end
    if m then
        SetTextColour(m[1], m[2], m[3], m[4])
    else
        SetTextColour(255, 255, 255, 255)
    end
    if q then
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextDropShadow()
        SetTextOutline()
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b, c)
end
function DrawAdvancedText(b, c, r, s, t, a, u, v, w, x, k, y)
    SetTextFont(k)
    SetTextScale(t, t)
    SetTextJustification(y)
    SetTextColour(u, v, w, x)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b - 0.1 + r, c - 0.02 + s)
end
function DrawAdvancedTextNoOutline(b, c, r, s, t, a, u, v, w, x, k, y)
    SetTextFont(k)
    SetTextScale(t, t)
    SetTextJustification(y)
    SetTextColour(u, v, w, x)
    SetTextDropShadow()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b - 0.1 + r, c - 0.02 + s)
end
function DrawGTAText(a, b, c, j, z, A)
    SetTextFont(0)
    SetTextScale(j, j)
    SetTextColour(254, 254, 254, 255)
    if z then
        SetTextWrap(b - A, b)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b, c)
end
function VICE.DrawSprite3d(data)
    local dist = #(GetGameplayCamCoords().xy - data.pos.xy)
    local fov = (1 / GetGameplayCamFov()) * 250
    local scale = 0.3
    SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
	if not HasStreamedTextureDictLoaded(data.textureDict) then
		local timer = 1000
		RequestStreamedTextureDict(data.textureDict, true)
		while not HasStreamedTextureDictLoaded(data.textureDict) and timer > 0 do
			timer = timer-1
			Citizen.Wait(100)
		end
	end
    DrawSprite(data.textureDict,data.textureName,(data.x or 0) * scale,(data.y or 0) * scale,data.width * scale,data.height * scale,data.heading or 0,data.r or 0,data.g or 0,data.b or 0,data.a or 255)
    ClearDrawOrigin()
end