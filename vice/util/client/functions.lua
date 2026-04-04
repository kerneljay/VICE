-- [[ Notifys ]] -- 

function VICE.notify(msg)
    TriggerEvent("VICE:Notify",msg)
end

RegisterNetEvent("VICE:Notify",function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(true, false)
end)

local function b(c,d,e)
    return c<d and d or c>e and e or c 
  end
  
  local function f(g)
    local h=math.floor(#g%99==0 and#g/99 or#g/99+1)
    local i={}
    for j=0,h-1 do 
        i[j+1]=string.sub(g,j*99+1,b(#string.sub(g,j*99),0,99)+j*99)
    end
    return i 
  end
  
  local function k(l,m)
    local n=f(l)
    SetNotificationTextEntry("CELL_EMAIL_BCON")
    for o,p in ipairs(n)do 
        AddTextComponentSubstringPlayerName(p)
    end
    if m then 
        local q=GetSoundId()
        PlaySoundFrontend(q,"police_notification","DLC_AS_VNT_Sounds",true)
        ReleaseSoundId(q)
    end 
  end

function VICE.notifyPicture(ay,az,l,ac,aA,aB,aC)
    TriggerEvent("VICE:notifyPicture",ay,az,l,ac,aA,aB,aC)
end

function VICE.notifyPicture2(a8, type, a9, aa, ab)
    TriggerEvent("VICE:notifyPicture2", a8, type, a9, aa, ab)
end

function VICE.notifyPicture5(headshot, iconType, title, usePicture, message)
    TriggerEvent("VICE:notifyPicture5", headshot, iconType, title, usePicture, message)
end

function VICE.notifyPicture(ay,az,l,ac,aA,aB,aC)
    TriggerEvent("VICE:notifyPicture",ay,az,l,ac,aA,aB,aC)
end

RegisterNetEvent("VICE:notifyPicture6",function(ay,az,l,ac,aA,aB,aC)
    if ay~=nil and az~=nil then 
        RequestStreamedTextureDict(ay,true)
        while not HasStreamedTextureDictLoaded(ay)do 
            print("stuck loading",ay)
            Wait(0)
        end 
    end
    k(l,aB=="natwest")
    if aC==nil then 
        aC=0 
    end
    local aD=false
    EndTextCommandThefeedPostMessagetext(ay,az,aD,aC,ac,aA)
    local aE=true
    local aF=false
    EndTextCommandThefeedPostTicker(aF,aE)
    DrawNotification(false,true)
    if aB==nil then 
        TriggerEvent("vice:PlaySound", "iphone_dodoDO")
    end 
end)

RegisterNetEvent("VICE:notifyPicture",function(ay,az,l,ac,aA,aB,aC)
    if ay~=nil and az~=nil then 
        RequestStreamedTextureDict(ay,true)
        local timeout = 1000 -- Add timeout to prevent infinite loop
        while not HasStreamedTextureDictLoaded(ay) and timeout > 0 do 
            timeout = timeout - 1
            Wait(10)
        end
        if timeout <= 0 then
            -- Fallback to default notification if texture fails to load
            SetNotificationTextEntry("STRING")
            AddTextComponentString(l)
            DrawNotification(true, false)
            return
        end
    end
    k(l,aB=="police")
    if aC==nil then 
        aC=0 
    end
    local aD=false
    EndTextCommandThefeedPostMessagetext(ay,az,aD,aC,ac,aA)
    local aE=true
    local aF=false
    EndTextCommandThefeedPostTicker(aF,aE)
    DrawNotification(false,true)
    if aB==nil then 
        PlaySoundFrontend(-1,"CHECKPOINT_NORMAL","HUD_MINI_GAME_SOUNDSET",1)
    end 
end)
  
RegisterNetEvent("VICE:notifyPicture2", function(a8, type, a9, aa, ab)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(ab)
    SetNotificationMessage(a8, a8, true, type, a9, aa, ab)
    DrawNotification(false, true)
end)

RegisterNetEvent("VICE:notifyPicture5", function(headshot, iconType, title, usePicture, message)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(headshot)
    local txdString = nil

    if mugshotStr then
        txdString = "CHAR_" .. mugshotStr
    else
        txdString = "CHAR_DEFAULT"
    end

    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(message)
    SetNotificationMessage(txdString, txdString, usePicture, iconType, title, message)
    DrawNotification(false, true)
    UnregisterPedheadshot(mugshot)
end)

--