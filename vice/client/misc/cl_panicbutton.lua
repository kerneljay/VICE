local a = {}
a.Cooldown = 15
a.DisableAllMessages = false
a.ChatSuggestions = true
a.Reminder = true
a.Message = "Attention all units, MET officer in distress!"
local b = {}
b.Cooling = 0
b.Tuned = true
function getHeadshot(c)
    local handle = RegisterPedheadshot(c)
    if not IsPedheadshotValid(handle) then
        return "CHAR_BLOCKED"
    end
    local d = GetGameTimer()
    while not IsPedheadshotReady(handle) do
        if GetGameTimer() - d > 2500 then
            UnregisterPedheadshot(handle)
            return "CHAR_BLOCKED"
        end
        Wait(0)
    end
    local e = GetPedheadshotTxdString(handle)
    return e, handle
end
RegisterCommand(
    "panic",
    function()
        if globalOnPoliceDuty or globalNHSOnDuty or globalUKBFOnDuty or globalOnPrisonDuty or globalLFBOnDuty or PlayerIsInGang then
            if b.Cooling == 0 then
                local f = {}
                f.Player = VICE.getPlayerId()
                f.Ped = VICE.getPlayerPed()
                f.Name = VICE.getPlayerName(f.Player)
                f.Coords = GetEntityCoords(f.Ped)
                f.Location = {}
                f.Location.Street, f.Location.CrossStreet = GetStreetNameAtCoord(f.Coords.x, f.Coords.y, f.Coords.z)
                f.Location.Street = GetStreetNameFromHashKey(f.Location.Street)
                if f.Location.CrossStreet ~= 0 then
                    f.Location.CrossStreet = GetStreetNameFromHashKey(f.Location.CrossStreet)
                    f.Location = f.Location.Street .. " X " .. f.Location.CrossStreet
                else
                    f.Location = f.Location.Street
                end
                if globalOnPoliceDuty then
                    TriggerServerEvent("VICE:newPanic", f, 3)
                elseif globalNHSOnDuty then
                    TriggerServerEvent("VICE:newPanic", f, 2)
                elseif globalOnPrisonDuty then
                    TriggerServerEvent("VICE:newPanic", f, 4)
                elseif globalLFBOnDuty then
                    TriggerServerEvent("VICE:newPanic", f, 5)
                elseif globalUKBFOnDuty then
                    TriggerServerEvent("VICE:newPanic", f, 7)
                elseif PlayerIsInGang then
                    TriggerServerEvent("VICE:newGangPanic", f, 6)
                end
                b.Cooling = a.Cooldown
            else
                NewNoti("~r~Panic Button still cooling down.", true)
            end
        end
    end
)

RegisterNetEvent("VICE:returnPanic", function(g, f, h,radioname)
    local i = VICE.getUserId()
    if globalOnPoliceDuty or globalNHSOnDuty or globalUKBFOnDuty or globalOnPrisonDuty or globalLFBOnDuty and h == 5 or h == 6 and not VICE.isEmergencyService() then
        if h == 6 and VICE.isEmergencyService() then
            return
        end
        SendNUIMessage({PayloadType = "Panic", Payload = g})
        f.Headshot, handle = getHeadshot(GetPlayerPed(GetPlayerFromServerId(f.Source)))
        if h == 2 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("NHS - %s", f.Name), false, "~r~NHS Paramedic in distress! - " .. f.Location.. "\n~y~In Radio: "..radioname)
        elseif h == 3 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("MET Police - %s", f.Name), false, "~r~Officer in distress! - " .. f.Location.. "\n~y~In Radio: "..radioname)
        elseif h == 4 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("HMP Prison - %s", f.Name), false, "~r~Prison Guard in distress! - " .. f.Location.. "\n~y~In Radio: "..radioname)
        elseif h == 5 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("LFB - %s", f.Name), false, "~r~LFB Panic Alarm Activated! - " .. f.Location.. "\n~y~In Radio: "..radioname)
        elseif h == 6 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("%s", f.Name), false, "~r~Gang Member Panic! - " .. f.Location.. "\n~y~In Radio: "..radioname)
        elseif h == 7 then
            VICE.notifyPicture2(f.Headshot, 2, string.format("%s", f.Name), false, "~r~UK Border Force Panic! - " .. f.Location)
        end
        if handle then
            UnregisterPedheadshot(handle)
        end
        Citizen.CreateThread(function()
            local j = AddBlipForRadius(f.Coords.x, f.Coords.y, f.Coords.z, 100.0)
            SetBlipRoute(j, true)
            Citizen.CreateThread(function()
                while j do
                    SetBlipRouteColour(j, 1)
                    Citizen.Wait(150)
                    SetBlipRouteColour(j, 6)
                    Citizen.Wait(150)
                    SetBlipRouteColour(j, 35)
                    Citizen.Wait(150)
                    SetBlipRouteColour(j, 6)
                end
            end)
            SetBlipColour(j, h)
            SetBlipAlpha(j, 60)
            SetBlipFlashes(j, true)
            SetBlipFlashInterval(j, 200)
            Citizen.Wait(90000)
            RemoveBlip(j)
            j = nil
        end)
        local k = GetSoundId()
        PlaySoundFrontend(k, "police_notification", "DLC_AS_VNT_Sounds", true)
        ReleaseSoundId(k)
    end
end)

function NewNoti(l, m)
    if not a.DisableAllMessages then
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(l)
        EndTextCommandThefeedPostTicker(m, true)
    end
end
Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(0)
            if b.Cooling ~= 0 then
                b.Cooling = b.Cooling - 1
                Citizen.Wait(1000)
            end
        end
    end
)
