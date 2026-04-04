RMenu.Add('vicetruckmenu','job',RageUI.CreateMenu("","~s~VICE Trucking",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","vice_truckingjob"))
local a=module("cfg/cfg_trucking")
local b=""
local c=false;
local d={vehicle=nil,trailer=nil,checkpoint=nil}
local e=1;
local f={}
local g={}
local h={}
local i=false;
local j=false;
local currentLevel = 0
globalIsDoingTruckRoute=false;
globalCurrentJob={}
globalJobOnPause=false;
local Military = false
local idk = false
local m = nil
for k,l in pairs(a.jobs)do 
    m=l;
    if m["config"]then 
        local n=m["config"][1]
        local o=m["config"][2]
        tVICE.addBlip(n.x,n.y,n.z,67,5,o)
        tVICE.addMarker(n.x,n.y,n.z,0.7,0.7,0.5,0,255,125,125,50,39,true,true)
    end 
end;
RegisterNetEvent("VICE:SetInitialXPLevels")
AddEventHandler("VICE:SetInitialXPLevels", function(NetCurrentXP)
	currentLevel = NetCurrentXP
end)
RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('vicetruckmenu', 'job')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            if b~=""then 
                if not globalIsDoingTruckRoute then 
                    RageUI.ButtonWithStyle("Start Job",nil,{RightLabel="→→→"},true,function(p,q,Selected)
                        if Selected and not globalIsDoingTruckRoute then 
                            if GetResourceKvpInt("vice_trucking_done_cutscene")==1 then 
                                TriggerServerEvent("VICE:startTruckerJob",b,false)
                            else 
                                sequence()
                                TriggerServerEvent("VICE:startTruckerJob",b,false)
                                SetResourceKvpInt("vice_trucking_done_cutscene",1)
                            end 
                        end 
                    end)
                elseif globalIsDoingTruckRoute then 
                    RageUI.Separator("~r~You are currently on a " .. b .. " job")
                    RageUI.Separator("~r~End this one to start a new one")
                    RageUI.ButtonWithStyle("End Job",nil,{RightLabel="→→→"},true,function(p,q,r)
                        if r then 
                            globalIsDoingTruckRoute = false
                            TriggerServerEvent("VICE:endTruckerJob","~r~You ended the job")
                        end 
                    end)
                end 
                RageUI.Separator("Current Level: " .. currentLevel)
                if a.jobs[b][1]["payout"] then
                    RageUI.Separator("Payout: ~g~£" .. getMoneyStringFormatted(a.jobs[b][1]["payout"]))
                end
            end 
        end)
    end
end)
AddEventHandler("VICE:onClientSpawn",function(s,t)
    if t then 
        local u=function(v)
            drawNativeNotification("Press ~INPUT_PICKUP~ to open the Trucking menu.")
        end;
        local w=function(v)
            closeTruckerMenu()
        end;
        local x=function(v)
            if IsControlJustReleased(1,38)then 
                if globalOnTruckJob then 
                    openTruckerMenu(v.job)
                else 
                    VICE.notify("~r~You aren't clocked on as a Trucker, head to cityhall to sign up.")
                   -- VICE.notify("~r~This feature is currently under developement.")
                end 
            end 
        end;
        for k,l in pairs(a.jobs)do 
            local y=l["config"]
            local n=y[1]
            VICE.createArea("trucking_"..k,y[1],1.15,6,u,w,x,{job=k})
        end 
    end 
end)
function openTruckerMenu(z)
    b=z;
    c=true;
    RMenu:Get('vicetruckmenu','job'):SetSubtitle(a.jobs[z]["config"][2])
    RageUI.Visible(RMenu:Get('vicetruckmenu','job'),true)
end;
function closeTruckerMenu()
    c=false;
    RageUI.Visible(RMenu:Get('vicetruckmenu','job'),false)
end;
math.randomseed(GetGameTimer())
RegisterNetEvent("VICE:startTruckerJobCl",function(m,A)
    globalCurrentJob=m;
    globalIsDoingTruckRoute = true
    local index=getRandomTableKey(m) -- need to fix this when i have the time
    if m == nil then
        m=m[1]
    else
        m=m[math.random(index)]
    end
    local B=getRandomTableKey(m.trailers)
    if not A then 
        local C=getRandomTableKey(m.trailerSpawns["docks"])
        local n=m.trailerSpawns["docks"][C][2]
        if GetEntityModel(VICE.getPlayerPed())==`mp_m_freemode_01`then 
            VICE.loadCustomisationPreset("TruckerMale")
        elseif GetEntityModel(VICE.getPlayerPed())==`mp_f_freemode_01`then 
            VICE.loadCustomisationPreset("TruckerFemale")
        else 
            VICE.loadCustomisationPreset("TruckerMale")
        end;
        d.trailer=spawnTrailer(m.trailers[B][1],n,m.trailerSpawns["docks"][C][1],m.trailers[B][2])
        local D=GetEntityCoords(d.trailer)
        f.trailer=tVICE.addBigBlip(D.x,D.y,D.z, 479, 3, "Location")
        SetBlipSprite(f.trailer,479)
        SetBlipRoute(f.trailer,true)
        g.trailer=CreateCheckpoint(45,n.x,n.y,n.z-1.0,0,0,0,10.0,0,255,0,127,0)
        SetCheckpointCylinderHeight(g.trailer,50.0,100.0,25.0)
        Citizen.CreateThread(function()
            while GetVehiclePedIsIn(PlayerPedId(),false)==0 and globalIsDoingTruckRoute do 
                drawNativeText("~g~Rent or buy a truck outside then pickup your trailer to complete the job.")
                Wait(0)
            end 
        end)
        CreateScaleform(2,"~y~Job Started!","Pick up your trailer outside!")
    else 
        local C=getRandomTableKey(m.trailerSpawns["pickup"])
        local n=m.trailerSpawns["pickup"][C][2]
        createDistanceCheckForSpawn(m.trailerSpawns["pickup"][C][2],m.trailers[B][1],m.trailerSpawns["pickup"][C][1])
        local D=m.trailerSpawns["pickup"][C][2]
        f.trailer=tVICE.addBigBlip(D.x,D.y,D.z, 479, 3, "Location")
        SetBlipSprite(f.trailer,479)
        SetBlipRoute(f.trailer,true)
        g.trailer=CreateCheckpoint(45,n.x,n.y,n.z-1.0,0,0,0,10.0,0,255,0,127,0)
        SetCheckpointCylinderHeight(g.trailer,50.0,100.0,25.0)
        DeleteCheckpoint(d.checkpoint)
        j=false;
        Citizen.CreateThread(function()
            while GetVehiclePedIsIn(PlayerPedId(),false) == 0 and globalIsDoingTruckRoute do 
                drawNativeText("~g~You need a truck to then pickup your trailer to complete the job.")
                Wait(0)
            end 
        end)
        CreateScaleform(2,"~y~Job Started!","Pick up your trailer at the blip on the map!")
    end 
end)
RegisterNetEvent("VICE:startNextJob",function()
    DeleteEntity(d.trailer)
    TriggerServerEvent("VICE:startTruckerJob",b,true)
end)
Citizen.CreateThread(function()
    while true do 
        local E=PlayerPedId()
        if IsPedInAnyVehicle(E,false)and not j then 
            local F=GetVehiclePedIsIn(E,false)
            local G,H=GetVehicleTrailerVehicle(F)
            if IsVehicleAttachedToTrailer(F)and H==d.trailer then 
                j=true;
                i=true;
                CreateScaleform(2,"~g~Trailer Attached!","Continue to your destination")
                SetBlipRoute(f.trailer,false)
                tVICE.removeBlip(f.trailer)
                startTruckingJob()
            end 
        end;
        Citizen.Wait(150)
    end 
end)
function startTruckingJob()
    local m=globalCurrentJob;
    local jobCompleted = false
    local I = m[1].locations[math.random(#m[1].locations)]
    f.job=tVICE.addBigBlip(I[1],I[2],I[3], 479, 3, "Location")
    SetBlipSprite(f.job,85)
    SetBlipRoute(f.job,true)
    local F=GetVehiclePedIsIn(PlayerPedId(),false)
    local J=NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(PlayerPedId(),false))
    TriggerServerEvent("VICE:setTruck",J)
    DeleteCheckpoint(g.trailer)
    d.vehicle=GetVehiclePedIsIn(PlayerPedId(),false)
    d.checkpoint= CreateCheckpoint(45,I[1],I[2],I[3] -1.0,0,0,0,10.0,0,255,0,127,0)
    SetCheckpointCylinderHeight(d.checkpoint,50.0,100.0,25.0)
    globalIsDoingTruckRoute=true;
    globalJobOnPause=false;
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(1000) 
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, I[1], I[2], I[3])

            if distance < 10.0 and not jobCompleted then 
                if IsVehicleAttachedToTrailer(F) then
                    TriggerServerEvent('VICE:jobCompleted', b) 
                    DeleteCheckpoint(d.checkpoint)
                    tVICE.removeBlip(f.job)
                    jobCompleted = true 
                else
                    VICE.notify("~r~You need your cargo!")
                end
            end
        end
    end)
end
function spawnTrailer(H,n,K,L)
    VICE.loadModel(H)
    local F=VICE.spawnVehicle(H,n.x,n.y,n.z,K, false, true, true)
    if L~=nil then 
        for M=1,9 do SetVehicleExtra(F,M,1)
        end;
        SetVehicleExtra(F,L,0)
    end;
    SetTrailerLegsLowered()
    return F 
end;
function CreateScaleform(N,O,P)
    local Q=true;
    local R=Scaleform("MIDSIZED_MESSAGE")
    R.RunFunction("SHOW_SHARD_MIDSIZED_MESSAGE",{O,P})
    Citizen.CreateThread(function()
        while Q do R.Render2D()
            Citizen.Wait(0)
        end 
    end)
    SetTimeout(N*1000,function()
        Q=false 
    end)
    return R 
end;
function getRandomTableKey(table)
    math.randomseed(GetGameTimer())
    num=math.random(1,#table)
    num=math.random(1,#table)
    num=math.random(1,#table)
    return num 
end
function createDistanceCheckForSpawn(I,H,K)
    tVICE.removeArea("trucking_spawn")
    local S=#h+1;
    h[S]=true;
    local T=function()
        if h[S]then 
            d.trailer=spawnTrailer(H,I,K)h[S]=false 
        end 
    end;
    local U=function()
    end;
    local V=function()
    end;
    VICE.createArea("trucking_spawn",I,106,6,T,U,V,{})
    return S 
end;
Citizen.CreateThread(function()
    while true do 
        local E=PlayerPedId()
        if IsPedInAnyVehicle(E,false)then 
            local D=GetEntityCoords(d.trailer)
            local F=GetVehiclePedIsIn(E,false)
            if#(D-GetEntityCoords(F))<=9.75 and not IsControlPressed(0,74)and not IsVehicleAttachedToTrailer(F)and not i then 
                AttachVehicleToTrailer(F,d.trailer,1.0)
            end 
        end;
        Wait(1000)
    end 
end)
Citizen.CreateThread(function()
    while true do 
        local E=PlayerPedId()
        if IsPedInAnyVehicle(E,false)then 
            local F=GetVehiclePedIsIn(E,false)
            if not IsVehicleAttachedToTrailer(F)and i then 
                i=false 
            end 
        end;
        Wait(1500)
    end 
end)
function VICE.isTrailerAttached(W)
    local X=VICE.getObjectId(W)
    return IsVehicleAttachedToTrailer(X)
end;
Citizen.CreateThread(function()
    while true do 
        if globalIsDoingTruckRoute then 
            if GetVehicleEngineHealth(d.vehicle)<0.0 then -- or not DoesEntityExist(d.vehicle)
                TriggerServerEvent("VICE:endTruckerJob","Truck was destroyed!")
            end 
        end;
        Wait(1000)
    end 
end)
RegisterNetEvent("VICE:endTruckerJobCl",function(Y)
    if globalOnTruckJob then 
        idk = false
        DeleteEntity(d.trailer)
        DeleteCheckpoint(g.trailer)
        globalIsDoingTruckRoute=false;
        globalCurrentJob={}
        globalJobOnPause=true;
        i=false;
        j=false;
        for M=1,#h do h[M]=false 
        end;
        CreateScaleform(2,"~r~JOB ENDED!",Y)
        SetBlipRoute(f.job,false)
        tVICE.removeBlip(f.job)
        tVICE.removeBlip(f.trailer)
    end 
end)
RegisterNetEvent("VICE:setTruckJobOnPause",function(Z)
    globalJobOnPause=Z 
end)
Citizen.CreateThread(function()
    while not globalJobOnPause do
        if IsEntityAVehicle(d.trailer)then 
            local E=PlayerPedId()
            local n=GetEntityCoords(E)
            local D=GetEntityCoords(d.trailer)
            if#(n-D)>450.0 then 
                TriggerServerEvent("VICE:endTruckerJob","You left the trailer behind")
            end 
        end;
        Citizen.Wait(1000)
    end 
end)
RegisterNetEvent("VICE:setParkingSpace",function(_)
    e=_ 
end)
function payout()
    TriggerServerEvent("VICE:truckerJobPayout")
end;
function salary()
    TriggerServerEvent("VICE:truckerJobSalary")
end;
function startOnTruckerJob()
    TriggerServerEvent("VICE:giveTruckerGroup")
end;
function sequence()
    TriggerServerEvent("VICE:truckingSequence")
    ExecuteCommand("hideui")
    local a0=GetRenderingCam()
    local E=VICE.getPlayerPed()
    local a1=VICE.getPlayerCoords()
    SetEntityCoords(E,vector3(856.022,-3188.11,4.05127))
    SetFocusPosAndVel(862.5825,-3195.493,6.002151,0.0,0.0,0.0)
    local a2=CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA",866.1363,-3191.314,7.14502,0.0,0.0,0.0,65.0,0,2)
    PointCamAtCoord(a2,862.5825,-3195.493,6.002151)
    SetCamActive(a2,true)
    RenderScriptCams(true,true,0,1,0)
    local a3=CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA",862.5231,-3190.259,7.14502,0.0,0.0,0.0,65.0,0,2)
    PointCamAtCoord(a3,862.5825,-3195.493,6.002151)
    SetCamActiveWithInterp(a3,a2,10000,5,5)
    drawNativeNotification("This is where you will start your trucking job. You can also come here to end the shift.")
    Wait(10000)
    PointCamAtCoord(a2,vector3(901.9878,-3185.827,5.898679))
    PointCamAtCoord(a3,vector3(901.9878,-3185.827,5.898679))
    SetCamCoord(a2,vector3(897.033,-3189.376,5.892334))
    SetCamCoord(a3,vector3(904.6154,-3189.428,5.892334))
    SetCamActiveWithInterp(a3,a2,10000,5,5)
    drawNativeNotification("Come here to rent or buy yourself a brand new truck to complete the trucking job with.")
    Wait(10000)
    local a4=createTrailers()
    Wait(1000)
    PointCamAtCoord(a2,vector3(934.8527,-3154.536,5.892334))
    PointCamAtCoord(a3,vector3(934.8527,-3154.536,5.892334))    
    SetCamCoord(a2,vector3(886.589,-3165.547,9.892334))
    SetCamCoord(a3,vector3(975.2308,-3166.602,9.892334))
    SetCamActiveWithInterp(a3,a2,25000,5,5)
    drawNativeNotification("You will be driving a wide selection of trailers around the city of VICE!")
    Wait(25000)
    for M=1,#a4 do DeleteEntity(a4[M])
    end;
    DestroyCam(a2,0)
    DestroyCam(a3,0)
    RenderScriptCams(false,true,3000,1,0)
    ClearFocus()
    FreezeEntityPosition(E,false)
    TriggerServerEvent("VICE:truckingSequence")
    SetEntityCoords(E,a1)
    ExecuteCommand("showui")
end;
local a5 = {"trailers", "trflat", "DockTrailer", "docktrailer", "trailers2", "trailers3", "tvtrailer", "raketrailer", "tanker", "trailerlogs", "tr2", "tr3", "tr4", "trailersmall"}
function getRandomNum(a6,a7)
    math.randomseed(GetGameTimer())
    return math.random(a6,a7)
end
function createTrailers()
    local a8=0;
    local a4={}
    for M=1,#a5 do 
        VICE.loadModel(a5[M])
        local X = VICE.spawnVehicle(a5[M], 896.7+a8,-3153.494,5.892334,177.1, false, true, true)
        FreezeEntityPosition(X,true)
        table.insert(a4,X)
        a8=a8+4 
    end;
    return a4 
end;
local function a9(n)
    local E=VICE.getPlayerPed()
    FreezeEntityPosition(E,true)
    cam=CreateCam("DEFAULT_SPLINE_CAMERA",true)
    SetCamCoord(cam,n.x,n.y,n.z)
    PointCamAtCoord(cam,n.x,n.y,n.z)
    SetCamActive(cam,true)
    RenderScriptCams(1,0,cam,0,0)
end;
RegisterCommand("setdonecutscene",function(aa,ab)
    if VICE.isDev(VICE.getUserId())then 
        SetResourceKvpInt("vice_trucking_done_cutscene",tonumber(ab[1]))
        print("set vice_trucking_done_cutscene to "..ab[1])
    end
end,false)

RegisterCommand("settrucker",function(aa,ab)
    if VICE.isDev(VICE.getUserId())then 
        TriggerEvent("VICE:setTruckerOnDuty", true)
    end
end,false)