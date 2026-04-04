local warningCooldown = 30000 
local lastWarningTime = 0

RegisterNetEvent("VICE:announceRestart")
AddEventHandler("VICE:announceRestart",function(a,b)
    local c=math.floor(tonumber(a))
    if a~=nil then 
        CreateThread(function()
            while c~=-1 do 
                c=c-1
                Wait(1000)
            end 
        end)
        scaleform=nil
        CreateThread(function()
            while c~=-1 do 
                scaleform=RequestScaleformMovie('MIDSIZED_MESSAGE')
                while not HasScaleformMovieLoaded(scaleform)do 
                    Wait(0)
                end
                PushScaleformMovieFunction(scaleform,"SHOW_SHARD_MIDSIZED_MESSAGE")
                if b then 
                    PushScaleformMovieFunctionParameterString("~r~Scheduled Server Restart")
                else 
                    PushScaleformMovieFunctionParameterString("~r~Unscheduled Server Restart")
                end
                if c~=0 then 
                    PushScaleformMovieFunctionParameterString("In ~r~"..c.."~s~ seconds!")
                else 
                    PushScaleformMovieFunctionParameterString("~r~Restarting")
                end
                EndScaleformMovieMethod()Wait(1000)
            end
        end)
        CreateThread(function()
            Wait(200)
            while true do 
                DrawScaleformMovieFullscreen(scaleform,255,255,255,255)
                Wait(0)
            end 
        end)
    end 
end)
RegisterNetEvent("VICE:smallAnnouncement",function(f,g,h,i)
    tVICE.announceMpSmallMsg(f,g,h,i)
end)
RegisterNetEvent("VICE:Announce")
AddEventHandler("VICE:Announce",function(d)
    if d ~= nil then
    CreateThread(function()
            local e = GetGameTimer()
            local scaleform = RequestScaleformMovie("MIDSIZED_MESSAGE")
            while not HasScaleformMovieLoaded(scaleform) do
                Wait(0)
            end
            BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_MIDSIZED_MESSAGE")
            ScaleformMovieMethodAddParamTextureNameString("~y~VICE Announcement")
            ScaleformMovieMethodAddParamTextureNameString(d)
            ScaleformMovieMethodAddParamInt(5)
            ScaleformMovieMethodAddParamBool(true)
            ScaleformMovieMethodAddParamBool(false)
            EndScaleformMovieMethod()
            while e + 6 * 1000 > GetGameTimer() do
                DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
                Wait(0)
            end
        end)
    end
end)
RegisterNetEvent("VICE:StaffDMMessage")
AddEventHandler("VICE:StaffDMMessage", function(admin, message)
    tVICE.announceMpSmallMsg("STAFF MESSAGE FROM " .. admin, message, 6, 15000) 
end)
RegisterNetEvent("VICE:SendWarning")
AddEventHandler("VICE:SendWarning", function(warningMessage)
    tVICE.announceWarning("~r~ADMIN WARNING", warningMessage, 29, 15000) 
end)

function tVICE.announceMpSmallMsg(f,g,h,i)
    local j=Scaleform("MIDSIZED_MESSAGE")
    j.RunFunction("SHOW_SHARD_MIDSIZED_MESSAGE",{f,g,h,false,false})
    PlaySoundFrontend(-1,"CHECKPOINT_NORMAL","HUD_MINI_GAME_SOUNDSET",1)
    local k=false
    SetTimeout(i,function()
        k=true 
    end)
    while not k do 
        j.Render2D()
        Wait(0)
    end 
end

function tVICE.announceWarning(f,g,h,i)
    local j=Scaleform("MP_BIG_MESSAGE_FREEMODE")
    j.RunFunction("SHOW_SHARD_WASTED_MP_MESSAGE",{f,g,h,false,false})
    PlaySoundFrontend(-1,"CHECKPOINT_NORMAL","HUD_MINI_GAME_SOUNDSET",1)
    local k=false
    SetTimeout(i,function()
        k=true 
    end)
    while not k do 
        j.Render2D()
        Wait(0)
    end 
end