insideDiamondCasino = false
AddEventHandler("VICE:onClientSpawn",function(a, b)
    if b then
        local c = {
            vector3(1121.7922363281, 239.42251586914, -50.440742492676),
            vector3(410.70236206055,9.4184703826904,91.935424804688),
        }
        local d = function(e)
            insideDiamondCasino = true
            tVICE.setCanAnim(false)
            VICE.overrideTime(12, 0, 0)
            TriggerEvent("VICE:enteredDiamondCasino")
            TriggerServerEvent('VICE:getChips')
        end
        local f = function(e)
            insideDiamondCasino = false
            tVICE.setCanAnim(true)
            VICE.cancelOverrideTimeWeather()
            TriggerEvent("VICE:exitedDiamondCasino")
        end
        local g = function(e)
        end
        for _, coord in ipairs(c) do
            VICE.createArea("diamondcasino", coord, 100.0, 20, d, f, g, {})
        end
    end
end)