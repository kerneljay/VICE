local confettiParticles = {}
local confettiDuration = 5000

local start = false 

local cam = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        local triggerCoords = vector3(5325.208984375, -4882.478515625, 15.21821308136)

        local distance = #(playerCoords - triggerCoords)

        if distance < 2.0 then
            DisplayHelpText("Press ~INPUT_ENTER~ to pay respects")

            if IsControlJustPressed(0, 23) then -- "F" key
                if VICE.getPlayerCombatTimer() > 0 and not start then
                    VICE.notify("~r~You cannot do this while in combat!")
                else
                    VICE.notify("~g~Odin wishes you good fortune in the fights to come, you've been gifted some cash!")
                    ExecuteCommand("e rose") 

                    TriggerServerEvent("VICE:cayoPayment")
                    
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local playerHeading = GetEntityHeading(playerPed)
                    TriggerEvent("VICE:storeDrawEffects", playerPed)

                    local camPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.4) 
                    local camRot = vector3(20.0, 0.0, playerHeading + 180) 
            
                    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, camRot, 60.0, true, 0)
                    RenderScriptCams(true, true, 1000, true, true)
            
                    local startTime = GetGameTimer()
                    while GetGameTimer() - startTime < 10000 do
                        playerPed = PlayerPedId()
                        local newCamPos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.4)
                        local newCamRot = vector3(20.0, 0.0, GetEntityHeading(playerPed) + 180)
                        SetCamCoord(cam, newCamPos)
                        SetCamRot(cam, newCamRot, 2)
                        Citizen.Wait(0)
                    end
            
                    ExecuteCommand("e c")
                    RenderScriptCams(false, false, 0, true, true)
                    DestroyCam(cam, false)
                end
            end
        end
    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end
