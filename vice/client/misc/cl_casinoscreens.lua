function loadScaleform(a)
    local b=RequestScaleformMovie(a)
    while not HasScaleformMovieLoaded(b)do 
        Wait(0)
        print("loading",a)
    end;
    return b 
end;
local c='https://www.youtube.com/embed/lX_IN4v-RnA?version=3&fs=1&autoplay=1&loop=1&playlist=lX_IN4v-RnA'
local d='https://www.youtube.com/embed/n9v-2xF54HM?version=3&fs=1&disablekb=1&modestbranding=1&mute=1&autoplay=1&loop=1&playlist=n9v-2xF54HM'
local e=0.2;
local f='generic_texture_renderer'
local g=1280;
local h=720;
local i;
local j=false;
local k;
local l;
function CreateNamedRenderTargetForModel(m,n)
    local o=0;
    if not IsNamedRendertargetRegistered(m)then 
        RegisterNamedRendertarget(m,0)
    end;
    if not IsNamedRendertargetLinked(n)then 
        LinkNamedRendertarget(n)
    end;
    if IsNamedRendertargetRegistered(m)then 
        o=GetNamedRendertargetRenderId(m)
    end;
    return o 
end;
local p=false;
local function q()
    Citizen.Wait(60000)
    if p then 
        DestroyDui(k)p=false 
    end 
end;
function jimmy()
    if p then 
        return 
    end;
    p=true;
    print("jimmy tv lego!")
    local n=`des_tvsmash_start`
    local r=vector3(-810.59,170.46,77.25)
    local s=GetClosestObjectOfType(r.x,r.y,r.z,0.05,n,0,0,0)
    local o=CreateNamedRenderTargetForModel("tvscreen",n)
    txd=CreateRuntimeTxd('meows')
    k=CreateDui(c,g,h)
    dui=GetDuiHandle(k)
    tx=CreateRuntimeTextureFromDuiHandle(txd,'woof',dui)
    local t=vector3(-808.93231201172,170.99266052246,76.74536895752)
    notify("Go to ~p~Jimmy's room~w~ in Michael's house to stop the music.")
    SetNewWaypoint(t.x,t.y)
    -- if VICE.isNewPlayer()then 
    --     Citizen.CreateThread(q)
    -- end;
    while p do 
        if#(VICE.getPlayerCoords()-t)<4.0 then 
            drawNativeNotification("Press ~INPUT_PICKUP~ to turn the TV off")
            if IsControlJustPressed(0,38)then 
                DestroyDui(k)
                p=false;
                return 
            end 
        end;
        SetTextRenderId(o)
        SetScriptGfxDrawOrder(4)
        SetScriptGfxDrawBehindPausemenu(1)
        DrawSprite("meows","woof",0.5,0.5,1.0,1.0,0.0,255,255,255,255)
        SetTextRenderId(GetDefaultScriptRendertargetRenderId())
        SetScriptGfxDrawBehindPausemenu(0)
        Citizen.Wait(0)
    end 
end;
RegisterCommand("jimmy",function()
    jimmy()
end,false)
local u={}u.VideoType='CASINO_DIA_PL'
local v=nil;
local w=false;
function startCasinoThreads()
    RequestStreamedTextureDict('Prop_Screen_Vinewood',false)
    while not HasStreamedTextureDictLoaded('Prop_Screen_Vinewood')do 
        Citizen.Wait(100)
    end;
    RegisterNamedRendertarget('casinoscreen_01',false)
    LinkNamedRendertarget(`vw_vwint01_video_overlay`)
    v=GetNamedRendertargetRenderId('casinoscreen_01')
    Citizen.CreateThread(function()
        local x=0;
        while true do Citizen.Wait(0)
            if not insideDiamondCasino then 
                ReleaseNamedRendertarget('casinoscreen_01')
                v=nil;
                w=false;
                break 
            end;
            if v then 
                local y=GetGameTimer()
                if w then 
                    setVideoWallTvChannelWin()
                    x=GetGameTimer()-33666;
                    w=false 
                else 
                    if y-x>=42666 then 
                        setVideoWallTvChannel()
                        x=y 
                    end 
                end;
                SetTextRenderId(v)
                SetScriptGfxDrawOrder(4)
                SetScriptGfxDrawBehindPausemenu(true)
                DrawInteractiveSprite('Prop_Screen_Vinewood','BG_Wall_Colour_4x4',0.25,0.5,0.5,1.0,0.0,255,255,255,255)
                DrawTvChannel(0.5,0.5,1.0,1.0,0.0,255,255,255,255)SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            end 
        end 
    end)
end;
function setVideoWallTvChannel()
    SetTvChannelPlaylist(0,u.VideoType,true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(0)
end;
function setVideoWallTvChannelWin()
    SetTvChannelPlaylist(0,'CASINO_WIN_PL',true)
    SetTvAudioFrontend(true)
    SetTvVolume(-100.0)
    SetTvChannel(-1)
    SetTvChannel(0)
end;
AddEventHandler("VICE:enteredDiamondCasino",function()
    insideDiamondCasino=true;
    startCasinoThreads()
end)
AddEventHandler("VICE:exitedDiamondCasino",function()
    insideDiamondCasino=false 
end)
AddEventHandler("VICE:bigWinDiamondCasino",function()
    if not insideDiamondCasino then 
        return 
    end;
    w=true 
end)