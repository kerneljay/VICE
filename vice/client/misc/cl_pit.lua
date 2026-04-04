local cfg = module("cfg/cfg_pit")

local pitEventActive = false
local pitEarnings = 0
local timeInsidePit = 0

function isPersonInSquare(personCoords, squareCenter, squareSize)
    local halfSize = squareSize / 2
    local minX = squareCenter.x - halfSize
    local maxX = squareCenter.x + halfSize
    local minY = squareCenter.y - halfSize
    local maxY = squareCenter.y + halfSize
    
    if personCoords.x >= minX and personCoords.x <= maxX and
       personCoords.y >= minY and personCoords.y <= maxY then
        return true
    else
        return false
    end
end

local function DrawGTAText(a,b,c,j,z,A)
    SetTextFont(0)
    SetTextScale(j,j)
    SetTextColour(220,20,60,255)
    if z then 
        SetTextWrap(b-A,b)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b,c)
end

local function DrawGTAText2(a,b,c,j,z,A)
    SetTextFont(0)
    SetTextScale(j,j)
    SetTextColour(254,254,254,255)
    if z then 
        SetTextWrap(b-A,b)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(a)
    EndTextCommandDisplayText(b,c)
end

local function DrawGTATimerBar(ac,A,ad)
    local ab=0.17
    local ae=-0.01
    local af=0.038
    local ag=0.008
    local ah=0.005
    local ai=0.32
    local aj=-0.04
    local ak=0.014
    local al=GetSafeZoneSize()
    local am=ak+al-ab+ab/2
    local an=aj+al-af+af/2-(ad-1)*(af+ah)
    DrawSprite("timerbars","all_black_bg",am,an,ab,0.038,0,0,0,0,128)
    DrawGTAText2(ac,al-ab+0.06,an-ag,ai)
    DrawGTAText(string.upper(A),al-ae,an-0.0175,0.5,true,ab/2)
end

local function getMoney()
    math.randomseed(GetGameTimer()*955)
    return math.random(cfg.money[1], cfg.money[2])
end
globalHideGunHud = false
globalPreventStaff = false
local currentTimeInPit = 0
local HasBeenSecond = 0
local IsInPit = false
local moneyMadeInCurrentPit = 0
local peopleInPit = 0
local function InitPitEvent()
    Citizen.CreateThread(function()
        while true do
            if not pitEventActive then
                return
            end
            Wait(0)
            local personCoords = GetEntityCoords(PlayerPedId())
            if #(cfg.pitCoords - personCoords) < cfg.greaterPitRadius then
                DrawGTATimerBar("People In Pit:", peopleInPit, 3)
                DrawGTATimerBar("Time In Pit:", decimalsToMinutes(timeInsidePit), 2)
                DrawGTATimerBar("Pit Money:", "£"..getMoneyStringFormatted(pitEarnings), 1)
                globalHideGunHud = true
                if HasBeenSecond==true then
                    HasBeenSecond = 0
                else
                    HasBeenSecond = HasBeenSecond + 0.01
                    if HasBeenSecond>=1 then
                        HasBeenSecond = true
                    end
                end
                if isPersonInSquare(personCoords, cfg.pitCoords, cfg.pitRadius) and personCoords.z < cfg.pitCoords.z + 2 and personCoords.z > cfg.pitCoords.z - 4 and HasBeenSecond==true then
                    if not IsInPit then
                        if tVICE.staffMode(false) then
                            VICE.notify("~r~You have been staffed off, Exit the pit to staff on.")
                            tVICE.staffMode(true) 
                        end
                        globalPreventStaff = true
                        TriggerServerEvent("VICE:PlayerEnteredPit", getMoney())
                    end
                    IsInPit = true
                    timeInsidePit = timeInsidePit + 1
                    currentTimeInPit = currentTimeInPit + 1
                    if currentTimeInPit >= cfg.timeNeededForPay then
                        TriggerServerEvent("VICE:PitReceiveMoney", getMoney())
                        currentTimeInPit = 0
                    end
                elseif HasBeenSecond==true and IsInPit==true then
                    IsInPit = false
                    TriggerServerEvent("VICE:PlayerLeftPit", moneyMadeInCurrentPit)
                    currentTimeInPit = 0
                    moneyMadeInCurrentPit = 0
                    globalHideGunHud = false
                    globalPreventStaff = false
                end
            elseif HasBeenSecond~=true then
                IsInPit = false
                currentTimeInPit = 0
                globalHideGunHud = false
                globalPreventStaff = false
            end
        end
    end)
end

RegisterNetEvent("VICE:SetPitEventActive",function(active)
    pitEventActive = active
    if pitEventActive then
        InitPitEvent()
    end
end)

RegisterNetEvent("VICE:PitReceiveMoney",function(money)
    pitEarnings = pitEarnings + money
    moneyMadeInCurrentPit = moneyMadeInCurrentPit + money
end)

RegisterNetEvent("VICE:SetPitPlayers",function(num)
    peopleInPit = num
end)