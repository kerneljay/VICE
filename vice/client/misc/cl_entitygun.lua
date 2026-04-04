local comand = false
local comand2 = false
local comand3 = false
local owner = ''
local text = ''
local netID = ''
local entcoords = 0
local entcords2 = '~s~Coords : ~o~0'
local model = ''
local playerid = ''
local serverid = ''
local hit, entity
local text2 = '0'
local netID2 = '~s~Net ID: ~o~0'
local entcoords2 = 0
local model2 = '~s~Model: ~o~0'
local owner2 = '~s~Owner: ~o~0'
local playerid2 = 'PlayerID: '
local serverid2 = 'ServerID: '
local entity2 = '0'
local heading2 = '0'
local heading = '0'
local health = '~s~Health: ~o~'
local health_eng = '~s~Engine HP: ~o~'
local health_num = 0
local health_num_eng = 0
RegisterCommand("entitygun", function()
    if VICE.getStaffLevel() > 0 then
        print("Staff mode activated for entity gun.")
        comand = not comand

        while comand do
            Wait(0)

            local hit, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if hit and DoesEntityExist(entity) then
                local entCoords = GetEntityCoords(entity)
                local heading = GetEntityHeading(entity)
                local health = GetEntityHealth(entity)
                local modelHash = GetEntityModel(entity)
                local hashString = string.format("0x%X", modelHash)

                local netIDText = ""
                local ownerText = ""
                local playerIDText = ""
                local serverIDText = ""
                local healthEngine = ""
                local tankHealth = ""
                local isNet = NetworkGetEntityIsNetworked(entity)

                if isNet then
                    local netID = ObjToNet(entity)
                    netIDText = "~s~NetID: ~o~" .. netID
                else
                    netIDText = "~s~NetID: ~r~NOT NETWORKED"
                end

               local modelName = GetDisplayNameFromVehicleModel(modelHash)
local modelText = string.format("~s~Model: ~o~%s ~c~(0x%X)", modelName, modelHash)

                if IsEntityAVehicle(entity) then
                    healthEngine = GetVehicleEngineHealth(entity)
                    tankHealth = GetVehiclePetrolTankHealth(entity)
                end

                if isNet then
                    local ownerPlayer = NetworkGetEntityOwner(entity)
                    local ownerServerID = GetPlayerServerId(ownerPlayer)

                    if IsEntityAPed(entity) and IsPedAPlayer(entity) then
                        local playerID = NetworkGetPlayerIndexFromPed(entity)
                        local serverID = GetPlayerServerId(playerID)
                        playerIDText = "~s~PlayerID: ~o~" .. playerID
                        serverIDText = "~s~SID: ~o~" .. serverID

                        text = string.format("~s~EntityID: ~o~%s\n%s\n~s~Health: ~o~%s", entity, modelText, health)
                        text2 = string.format("%s\n%s\n%s", netIDText, playerIDText, serverIDText)

                    elseif IsEntityAVehicle(entity) then
                        ownerText = "~s~Owner: ~o~" .. ownerServerID
                        text = string.format("~s~EntityID: ~o~%s\n%s\n~s~Body HP: ~o~%s", entity, modelText, health)
                        text2 = string.format("~s~Tank HP: ~o~%s\n~s~Engine HP: ~o~%s\n%s\n%s", tankHealth, healthEngine, netIDText, ownerText)

                    else
                        ownerText = "~s~Owner: ~o~" .. ownerServerID
                        text = string.format("~s~EntityID: ~o~%s\n%s\n~s~Health: ~o~%s", entity, modelText, health)
                        text2 = string.format("%s\n%s", netIDText, ownerText)
                    end
                else
                    ownerText = "~s~Owner: ~r~NOT NETWORKED"
                    if IsEntityAVehicle(entity) then
                        text = string.format("~s~EntityID: ~o~%s\n%s\n~s~Body HP: ~o~%s", entity, modelText, health)
                        text2 = string.format("~s~Tank HP: ~o~%s\n~s~Engine HP: ~o~%s\n%s", tankHealth, healthEngine, netIDText)
                    else
                        text = string.format("~s~EntityID: ~o~%s\n%s\n~s~Health: ~o~%s", entity, modelText, health)
                        text2 = netIDText
                    end
                end

                DrawText3D(entCoords.x, entCoords.y, entCoords.z + 0.70,
                    string.format("~s~Coords: ~o~%.2f, ~g~%.2f, ~b~%.2f\n~s~Heading: ~o~%.2f", entCoords.x, entCoords.y, entCoords.z, heading),
                    0.07, 255, 255, 255, 255)

                DrawText3D(entCoords.x, entCoords.y, entCoords.z + 0.45, text, 0.07, 255, 255, 255, 255)
                DrawText3D(entCoords.x, entCoords.y, entCoords.z + 0.15, text2, 0.07, 255, 255, 255, 255)
            end
        end
    else
        VICE.notify("You don't have permission to use this command.")
    end
end)


RegisterCommand("myentid", function()
    if VICE.getStaffLevel() > 0 then
        comand2 = not comand2
        local ped = PlayerPedId()
        while comand2 do
            Wait(0)
            local text = ''
            local netID = ''
            local entcoords = GetEntityCoords(ped)
            local netID = NetworkGetNetworkIdFromEntity(ped)
            local model = GetEntityModel(PlayerPedId())
            drawTxt(0.51, 0.782, 1.0, 1.0, 0.305, '~y~Me', 255, 255, 255, 255, true)
            drawTxt(0.51, 0.8, 1.0, 1.0, 0.305,
                '~s~Coords : ~o~' .. entcoords.x .. ', ~g~' .. entcoords.y .. ', ~b~' .. entcoords.z, 255, 255, 255, 255,
                true)
            drawTxt(0.51, 0.818, 1.0, 1.0, 0.305, '~s~Heading: ~o~' .. GetEntityHeading(PlayerPedId()), 255,
                255, 255, 255, true)
            drawTxt(0.51, 0.836, 1.0, 1.0, 0.305, '~s~EntityID: ~o~' .. ped, 255, 255, 255, 255, true)
            drawTxt(0.51, 0.872, 1.0, 1.0, 0.305, '~s~Model: ~o~' .. model, 255, 255, 255, 255, true)
            drawTxt(0.51, 0.854, 1.0, 1.0, 0.305, '~s~Net ID: ~o~' .. netID, 255, 255, 255, 255, true)
            drawTxt(0.51, 0.890, 1.0, 1.0, 0.305, '~s~PlayerID: ~o~' .. NetworkGetPlayerIndexFromPed(ped),
                255,
                255, 255, 255, true)
            drawTxt(0.51, 0.908, 1.0, 1.0, 0.305, '~s~ServerID: ~o~' .. GetPlayerServerId(PlayerId()), 255,
                255,
                255, 255, true)
            drawTxt(0.51, 0.926, 1.0, 1.0, 0.305, '~s~Health: ~o~' .. GetEntityHealth(PlayerPedId()), 255,
                255,
                255, 255, true)
        end
    else
        VICE.notify("you havent got perms to use this command.")
    end
end)

RegisterCommand("displayintid", function()
    comand3 = not comand3
    while comand3 do
        Wait(0)
        drawTxt(0.51, 1.0, 1.0, 1.0, 0.305, '~y~Target', 255, 255, 255, 255, true)
        drawTxt(0.51, 1.018, 1.0, 1.0, 0.305, '' .. entcords2, 255, 255, 255, 255, true)
        drawTxt(0.51, 1.036, 1.0, 1.0, 0.305, '~s~Heading: ~o~' .. heading2, 255, 255, 255, 255, true)
        drawTxt(0.51, 1.054, 1.0, 1.0, 0.305, '~s~Entity ID: ~o~' .. entity2, 255, 255, 255, 255, true)
        drawTxt(0.51, 1.072, 1.0, 1.0, 0.305, '' .. model2, 255, 255, 255, 255, true)
        if NetworkGetEntityIsNetworked(entity2) then
            if IsEntityAPed(entity2) and IsPedAPlayer(entity2) then
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Health: ~o~' .. health_num, 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.126, 1.0, 1.0, 0.305, '~s~Player ID: ~o~' .. playerid2, 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.144, 1.0, 1.0, 0.305, '~s~Server ID: ~o~' .. serverid2, 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305, '' .. netID2, 255, 255, 255, 255, true)
            elseif IsEntityAVehicle(entity2) then
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Body Health: ~o~' .. health_num, 255, 255, 255,
                    255, true)
                drawTxt(0.51, 1.126, 1.0, 1.0, 0.305, '~s~Engine Health: ~o~' .. health_num_eng, 255, 255,
                    255, 255, true)
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305,
                    '~s~Tank Health: ~o~' .. GetVehiclePetrolTankHealth(entity2), 255, 255, 255, 255, true)
                drawTxt(0.51, 1.162, 1.0, 1.0, 0.305, '' .. owner2, 255, 255, 255, 255, true)
                drawTxt(0.51, 1.144, 1.0, 1.0, 0.305, '' .. netID2, 255, 255, 255, 255, true)
            else
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Health: ~o~' .. health_num, 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.126, 1.0, 1.0, 0.305, '' .. owner2, 255, 255, 255, 255, true)
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305, '' .. netID2, 255, 255, 255, 255, true)
            end
        else
            if IsEntityAPed(entity2) then
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305, '~s~Net ID: ~r~NOT NETWORKED', 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Health: ~o~' .. health_num, 255, 255, 255, 255,
                    true)
            elseif IsEntityAVehicle(entity2) then
                drawTxt(0.51, 1.144, 1.0, 1.0, 0.305, '~s~Net ID: ~r~NOT NETWORKED', 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Body Health: ~o~' .. health_num, 255, 255, 255,
                    255, true)
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305, '~s~Engine Health: ~o~' .. health_num_eng, 255, 255,
                    255, 255, true)
                drawTxt(0.51, 1.126, 1.0, 1.0, 0.305,
                    '~s~Tank Health: ~o~' .. GetVehiclePetrolTankHealth(entity2), 255, 255, 255, 255, true)
            else
                drawTxt(0.51, 1.108, 1.0, 1.0, 0.305, '~s~Net ID: ~r~NOT NETWORKED', 255, 255, 255, 255,
                    true)
                drawTxt(0.51, 1.090, 1.0, 1.0, 0.305, '~s~Health: ~o~' .. health_num, 255, 255, 255, 255,
                    true)
            end
        end
    end
end)

function DrawText3D(x, y, z, text, scale, r, g, b, a)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(pX, pY, pZ) - vector3(x, y, z))
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
        SetTextScale(0.0 * scale, 0.50 * scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextEntry("STRING")
        SetTextCentre(true)
        SetTextOutline()
        SetTextColour(r, g, b, a)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function drawTxt(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    if outline then SetTextOutline() end
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x - width / 2, y - height / 2 + 0.005)
end
