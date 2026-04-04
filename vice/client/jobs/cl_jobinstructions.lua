RegisterNetEvent("viceui:jobInstructions",function(a) -- send this when selecting job from sv job selector
    if a == "AA Mechanic" then
        aaInstructions()
    elseif a == "Royal Mail Driver" then
        royalMailInstructions()
    elseif a == "Deliveroo" then
        deliverooInstructions()
    elseif a == "G4S Driver" then
        G4SInstructions()
    elseif a == "Lorry Driver" then
        LORRYInstructions()
        TriggerEvent("VICE:setTruckerOnDuty", true)
    elseif a == "Taco Seller" then
        tacoInstructions()
    elseif a == "Pilot" then
        pilotInstructions()
    end
end)

function aaInstructions()
    globalOnAADuty = true
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Welcome to the AA","I have set a waypoint to the AA garage where you can pickup your truck.")
    SetNewWaypoint(494.83721923828, -1329.7965087891)
end
function royalMailInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Royal Mail","I have set a waypoint to the Royal Mail garage where you can start your shift.")
    SetNewWaypoint(-19.447393417358, -705.32580566406)
end
function deliverooInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Deliveroo","I have set a waypoint to the restaurant where you can start your shift.")
    SetNewWaypoint(-1174.4127197266, -872.98626708984)
end
function G4SInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("G4S","I have set a waypoint to the G4S depot where you'll start your first job.")
    SetNewWaypoint(-710.4659, 269.6835)
end
function LORRYInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Lorry Driver","I have set a waypoint to the Trucking depot where you'll start your first job.")
    SetNewWaypoint(862.5780, -3195.4426)
end
function tacoInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Taco Seller", "Buy a Taco truck at Simeons then type /taco to start selling!")
    SetNewWaypoint(-47.174137115479, -1109.6021728516)
end
function pilotInstructions()
    PlaySound(-1, "CHECKPOINT_BEHIND", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
    initializeInstructionalJobScaleform("Pilot", "Head down to the airport and plan your flight!")
    SetNewWaypoint(-980.85607910156, -2950.3618164062)
end
function initializeInstructionalJobScaleform(b, c)
    Citizen.CreateThread(function()
        function Initialize(d)
            local d = RequestScaleformMovie(d)
            while not HasScaleformMovieLoaded(d) do
                Citizen.Wait(0)
            end
            BeginScaleformMovieMethod(d, "SHOW_SHARD_WASTED_MP_MESSAGE")
            ScaleformMovieMethodAddParamTextureNameString(b)
            ScaleformMovieMethodAddParamTextureNameString(c)
            ScaleformMovieMethodAddParamInt(5)
            EndScaleformMovieMethod()
            return d
        end
        local d = Initialize("mp_big_message_freemode")
        local e = true
        SetTimeout(
            10000,
            function()
                e = false
            end
        )
        while e do
            local f = 0.5
            local g = 0.35
            local h = 1.0
            local i = h
            DrawScaleformMovie(d, f, g, h, i)
            Wait(0)
        end
    end)
end

function subtitleText(E)
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(E)
    EndTextCommandPrint(1000,1)
end