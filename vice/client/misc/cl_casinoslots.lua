local cfg = module("cfg/cfg_casinoslots")
local ReelData = {[1] = 0, [2] = 0, [3] = 0}
local selectedSlotID = ""
local Data = {OnSlot = false, BetIndex = 1, CurrentlySpinning = false}

local function CallScaleformMethod(method, ...)
    if not SlotScaleform then return end

    BeginScaleformMovieMethod(SlotScaleform, method)

    local args = { ... }
    for i = 1, #args do
        local arg = args[i]

        if type(arg) == "string" then
            PushScaleformMovieMethodParameterString(arg)
        elseif type(arg) == "number" then
            PushScaleformMovieMethodParameterInt(arg)
        elseif type(arg) == "boolean" then
            PushScaleformMovieMethodParameterBool(arg)
        end
    end

    EndScaleformMovieMethod()
end



local function DeleteReels()
    for i,v in pairs(ReelData) do
        DeleteObject(v)
    end
    ReelData = {[1] = 0, [2] = 0, [3] = 0}
end

local function PlayCasinoSound(sound)
    if cfg.slot_location[selectedSlotID] then
        local soundID = GetSoundId()
        PlaySoundFromCoord(soundID, sound, VICE.getPlayerCoords(), cfg.slot_location[selectedSlotID]["Info"]["sound"], false, 20, false)
        ReleaseSoundId(soundID)
    end
end

local function CreateSlotsScaleForm(scaleformName)
    local function waitForScaleform(scaleform)
        while not HasScaleformMovieLoaded(scaleform) do
            Citizen.Wait(0)
        end
    end

    local function addDataSlot(scaleform, slotIndex, control, label)
        BeginScaleformMovieMethod(scaleform, "SET_DATA_SLOT")
        ScaleformMovieMethodAddParamInt(slotIndex)
        Button(GetControlInstructionalButton(0, control, true))
        ButtonMessage(label)
        EndScaleformMovieMethod()
    end

    local scaleform = RequestScaleformMovie(scaleformName)
    waitForScaleform(scaleform)

    BeginScaleformMovieMethod(scaleform, "CLEAR_ALL")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_CLEAR_SPACE")
    ScaleformMovieMethodAddParamInt(200)
    EndScaleformMovieMethod()

    for i, slot in ipairs(cfg.slots_controls) do
        addDataSlot(scaleform, i - 1, slot.control, slot.label)
    end

    BeginScaleformMovieMethod(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    EndScaleformMovieMethod()

    BeginScaleformMovieMethod(scaleform, "SET_BACKGROUND_COLOUR")
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(0)
    ScaleformMovieMethodAddParamInt(80)
    EndScaleformMovieMethod()
    return scaleform
end

local function slotsScaleform(SlotData)
    CreateThread(function()
        Scaleform = RequestScaleformMovie("SLOT_MACHINE")
        while not HasScaleformMovieLoaded(Scaleform) do 
            Wait(0) 
        end
        if SlotData["Info"]["theme"] then 
            CallScaleformMethod("SET_THEME", SlotData["Info"]["theme"])
        else 
            CallScaleformMethod("SET_THEME") 
        end
        local handle = CreateNamedRenderTargetForModel("machine_"..SlotData["Info"]["scriptrt"], SlotData["Model"])
        while Data["OnSlot"] do
            N_0x32f34ff7f617643b(Scaleform, 1)
            SetTextRenderId(handle)
            SetScriptGfxDrawOrder(4)
            SetScriptGfxDrawBehindPausemenu(true)
            DrawScaleformMovie(Scaleform, 0.401, 0.09, 0.805, 0.195, 255, 255, 255, 255, 0)
            SetTextRenderId(GetDefaultScriptRendertargetRenderId())
            Wait(0)
        end
    end)
end

RMenu.Add("CasinoSlots", "instructions", RageUI.CreateMenu("", "SLOTS", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus","admin"))
RMenu:Get("CasinoSlots","instructions"):AddInstructionButton({"~INPUT_FRONTEND_RS~", "Hide Instructions"})
RageUI.CreateWhile(1.0,true,function()
    if RageUI.Visible(RMenu:Get("CasinoSlots", "instructions")) then
        
        local betStrings = {}
        if selectedSlotID ~= "" then
            for i,v in pairs(cfg.slot_location[selectedSlotID]["Info"]["betamounts"]) do
                table.insert(betStrings, getMoneyStringFormatted(v))
            end
            RageUI.Separator("~g~Mininum Bet: "..getMoneyStringFormatted(cfg.slot_location[selectedSlotID]["Info"]["betamounts"][1]))
            RageUI.Separator("The payouts displayed on the front of the machine are based on the minimum bet.")
            RageUI.Separator("~g~Conversions")
            RageUI.Separator("Bets: "..table.concat(betStrings, ", "))
        end
    end
end)
RMenu.Add(
    "CasinoSlots",
    "instructions",
    RageUI.CreateMenu(
        "",
        "SLOTS",
        VICE.getRageUIMenuWidth(),
        VICE.getRageUIMenuHeight()
    )
)

-- -- Add instructional buttons (like help tips in bottom right)
-- RMenu:Get("CasinoSlots", "instructions"):AddInstructionButton({"~INPUT_FRONTEND_RS~", "Hide Instructions"})

-- -- Create While Menu
-- RageUI.CreateWhile(1.0, true, function()
    
--     if RageUI.Visible(RMenu:Get("CasinoSlots", "instructions")) then
--         print("paprparpar")
--                 if selectedSlotID ~= "" and cfg.slot_location[selectedSlotID] then
--                     local betStrings = {}
--                     local betAmounts = cfg.slot_location[selectedSlotID]["Info"]["betamounts"]

--                     for _, v in ipairs(betAmounts) do
--                         table.insert(betStrings, getMoneyStringFormatted(v))
--                     end

--                     RageUI.Separator("~g~Minimum Bet: " .. getMoneyStringFormatted(betAmounts[1]))
--                     RageUI.Separator("The payouts displayed on the front of the machine are based on the minimum bet.")
--                     RageUI.Separator("~g~Conversions")
--                     RageUI.Separator("Bets: " .. table.concat(betStrings, ", "))
--                 else
--                     RageUI.Separator("~r~No machine selected.")
--                 end
          
--     end
-- end)

local function DoNetworkAnim(animname)
    if selectedSlotID ~= "" then
        local SlotData = cfg.slot_location[selectedSlotID]
        if GetEntityModel(VICE.getPlayerPed()) == `mp_f_freemode_01` then
            cfg.anim_dict = "anim_casino_a@amb@casino@games@slots@female"
        end
        local AnimScene = NetworkCreateSynchronisedScene(SlotData["Coords"].x, SlotData["Coords"].y, SlotData["Coords"].z, SlotData["Rotation"].x, SlotData["Rotation"].y, SlotData["Rotation"].z, 2, true, false, 1.0, 0, 1.0)
        VICE.loadAnimDict(cfg.anim_dict)
        NetworkAddPedToSynchronisedScene(VICE.getPlayerPed(), AnimScene, cfg.anim_dict, animname, 2.0, -1.5, 13, 16, 2.0, 0)
        NetworkStartSynchronisedScene(AnimScene)
        return AnimScene
    end
end

RegisterNetEvent("VICE:enterSlotMachine", function(SlotID)
    local SlotData = cfg.slot_location[SlotID]
    if SlotData then
        local SlotInfo = SlotData["Info"]
        for i,v in pairs(SlotData["Reels"]) do
            ReelData[i] = CreateObject(SlotInfo["reela"], v.x, v.y, v.z, true, false, false)
            while not DoesEntityExist(ReelData[i]) do 
                Wait(0) 
            end
            FreezeEntityPosition(ReelData[i], true)
            SetEntityRotation(ReelData[i], 0.0, 0.0, SlotData["Heading"], 2, true)
        end
        local randomAnim = cfg.random["enter"][math.random(1, #cfg.random["enter"])]
        selectedSlotID = SlotID
        Data["OnSlot"] = true
        DoNetworkAnim(randomAnim)
        slotsScaleform(SlotData)
        Wait(GetAnimDuration(cfg.anim_dict, randomAnim) * 700)
        CallScaleformMethod("SET_MESSAGE", cfg.random_enter_message[math.random(1, #cfg.random_enter_message)])
        CallScaleformMethod("SET_BET", SlotInfo["betamounts"][Data["BetIndex"]])
        CreateThread(function()
            local ScaleForm = CreateSlotsScaleForm("instructional_buttons")
            while true do
                SetPedCapsule(VICE.getPlayerPed(), 0.2)
                DrawScaleformMovieFullscreen(ScaleForm, 255, 255, 255, 255, 0)
                if not Data["CurrentlySpinning"] then
                    if IsControlJustPressed(0, 202) then
                        DeleteReels()
                        local randomAnim = cfg.random["leave"][math.random(1, #cfg.random["leave"])]
                        local AnimScene = DoNetworkAnim(randomAnim)
                        Wait(GetAnimDuration(cfg.anim_dict, randomAnim) * 700)
                        NetworkStopSynchronisedScene(AnimScene)
                        CallScaleformMethod("SET_BET")
                        CallScaleformMethod("SET_LAST_WIN")
                        CallScaleformMethod("SET_MESSAGE", "")
                        TriggerServerEvent("VICE:ExitSlotMachine", selectedSlotID)
                        Data = {OnSlot = false, BetIndex = 1,CurrentlySpinning = false}
                        selectedSlotID = ""
                        break
                    elseif IsControlJustPressed(0, 38) then -- Increase (E)
                        if not SlotInfo["betamounts"][Data["BetIndex"] + 1] then
                            Data["BetIndex"] = 1
                        else
                            Data["BetIndex"] = Data["BetIndex"] + 1
                        end
                        CallScaleformMethod("SET_BET", SlotInfo["betamounts"][Data["BetIndex"]])
                    elseif IsControlJustPressed(0, 44) then -- Decrease (Q)
                        if not SlotInfo["betamounts"][Data["BetIndex"] - 1] then
                            Data["BetIndex"] = #SlotInfo["betamounts"]
                        else
                            Data["BetIndex"] = Data["BetIndex"] - 1
                        end
                        CallScaleformMethod("SET_BET", SlotInfo["betamounts"][Data["BetIndex"]])
                    elseif IsControlJustPressed(0, 210) then -- View Instructions (Left Control)
                        RageUI.Visible(RMenu:Get("CasinoSlots", "instructions"), not RageUI.Visible(RMenu:Get("CasinoSlots", "instructions")))
                        RMenu:Get("CasinoSlots", "instructions"):SetSpriteBanner(SlotInfo["texture"],SlotInfo["texture"])
                        if not RageUI.Visible(RMenu:Get("CasinoSlots", "instructions")) then
                            ScaleForm = CreateSlotsScaleForm("instructional_buttons")
                        end
                    elseif IsControlJustPressed(0, 201) then -- Spin (Space)
                        local randomAnim = cfg.random["spin"][math.random(1, #cfg.random["spin"])]
                        DoNetworkAnim(randomAnim)
                        Wait(GetAnimDuration(cfg.anim_dict, randomAnim) * 500)
                        PlayCasinoSound("start_spin")
                        TriggerServerEvent("VICE:spinSlotMachine", selectedSlotID, SlotInfo["betamounts"][Data["BetIndex"]])
                    end
                end
                Wait(0)
            end
        end)
    end
end)

RegisterNetEvent("VICE:spinSlotMachine",function(SlotRewards,RewardMulti)
    local SlotData = cfg.slot_location[selectedSlotID]
    local Time = 5000
    local EndSlot = GetGameTimer() + Time
    local FirstSlotFinish = Time * math.random(2,4) / 10
    local SecondSlotFinish = Time * math.random(5,7) / 10
    Data["CurrentlySpinning"] = true
    PlayCasinoSound("spinning")
    while GetGameTimer() < EndSlot do
        if EndSlot - GetGameTimer() > FirstSlotFinish then
            if EndSlot - GetGameTimer() > SecondSlotFinish then
                SetEntityRotation(ReelData[1], math.random(0, 15) * 22.5 + math.random(1, 60), 0.0, SlotData["Heading"], 2, true)
                if EndSlot - GetGameTimer() < SecondSlotFinish + 15 then
                    SetEntityRotation(ReelData[1],SlotRewards[1] * 22.5, 0.0, SlotData["Heading"], 2, true) -- Finish Slot 1
                    if SlotRewards[1] == math.floor(SlotRewards[1]) then
                        PlayCasinoSound("wheel_stop_clunk")
                    else
                        PlayCasinoSound("wheel_stop_on_prize")
                    end
                end
            end
            SetEntityRotation(ReelData[2], math.random(0, 15) * 22.5 + math.random(1, 60), 0.0, SlotData["Heading"], 2, true)
            if EndSlot - GetGameTimer() < FirstSlotFinish + 15 then
                SetEntityRotation(ReelData[2],SlotRewards[2] * 22.5, 0.0, SlotData["Heading"], 2, true)  -- Finish Slot 2
                if SlotRewards[2] == math.floor(SlotRewards[2]) then
                    PlayCasinoSound("wheel_stop_clunk")
                else
                    PlayCasinoSound("wheel_stop_on_prize")
                end
            end
        end
        SetEntityRotation(ReelData[3], math.random(0, 15) * 22.5 + math.random(1, 60), 0.0, SlotData["Heading"], 2, true)
        Wait(0)
    end
    SetEntityRotation(ReelData[3],SlotRewards[3] * 22.5, 0.0, SlotData["Heading"], 2, true) -- Finish Slot 3
    CallScaleformMethod("SET_LAST_WIN", SlotData["Info"]["betamounts"][Data["BetIndex"]] * RewardMulti)
    if SlotRewards[3] == math.floor(SlotRewards[3]) then
        PlayCasinoSound("wheel_stop_clunk")
    else
        PlayCasinoSound("wheel_stop_on_prize")
    end
    local RandomAnim = ""
    if RewardMulti == 0 then
        PlayCasinoSound("no_win")
        RandomAnim = cfg.random["lose"][math.random(1, #cfg.random["lose"])]
        DoNetworkAnim(RandomAnim)
    elseif RewardMulti > 7 then
        if ReelData[1] == 5 and ReelData[2] == 5 and ReelData[3] == 5 then
            PlayCasinoSound("jackpot") 
        else 
            PlayCasinoSound("big_win") 
        end
        RandomAnim = cfg.random["big_win"][math.random(1, #cfg.random["big_win"])]
        DoNetworkAnim(RandomAnim)
    else
        PlayCasinoSound("small_win")
        RandomAnim = cfg.random["win"][math.random(1, #cfg.random["win"])]
        DoNetworkAnim(RandomAnim)
    end
    Data["CurrentlySpinning"] = false
end)

Citizen.CreateThread(function()
    -- while not RequestScriptAudioBank("dlc_vinewood/casino_slot_machines_01", false) do Wait(0) end
    -- while not RequestScriptAudioBank("dlc_vinewood/casino_slot_machines_02", false) do Wait(0) end
    -- while not RequestScriptAudioBank("dlc_vinewood/casino_slot_machines_03", false) do Wait(0) end
    while true do
        
            local Coords = VICE.getPlayerCoords()
            if not Data["OnSlot"] then
                for ID,SlotData in pairs(cfg.slot_location) do
                    if #(Coords - SlotData["Coords"]) <= 1.7 then
                        drawNativeNotification("Press ~INPUT_CONTEXT~ to play " ..SlotData["Info"]["name"])
                        if IsControlJustPressed(0, 38) then -- E
                            TriggerServerEvent("VICE:requestSlotData", ID)
                        end
                    end
                end
            else
                if #(Coords - cfg.slot_location[selectedSlotID]["Coords"]) > 1.8 then
                    CallScaleformMethod("SET_BET")
                    CallScaleformMethod("SET_MESSAGE", "")
                    TriggerServerEvent("VICE:ExitSlotMachine", selectedSlotID)
                    DeleteReels()
                    Data = {OnSlot = false, BetIndex = 1,CurrentlySpinning = false}
                    selectedSlotID = ""
                end
            end
        
        Citizen.Wait(0)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        DeleteReels()
    end
end)

