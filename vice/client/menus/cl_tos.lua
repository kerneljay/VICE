local countdown = 3
local menuVisible = false 
local startTime = 0 
local color = "~r~"

RMenu.Add("tos", "mainmenu", RageUI.CreateMenu("", "~s~Terms And Conditions", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(), "menus", "garagesresize"))

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("tos", "mainmenu")) then
        menuVisible = true 
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = true }, function()
            RageUI.Separator('~y~Terms of selling the vehicle:')
            RageUI.Separator('Any agreements made between you and the buyer are not covered by VICE')
            RageUI.Separator('You forfeit any right to claim the vehicle back after payment')
            RageUI.Separator('You agree the buyer has full discretion over the vehicle hereafter')

            if startTime == 0 then
                startTime = GetGameTimer()
                color = "~r~"
            end

            local currentTime = GetGameTimer()
            local elapsedSeconds = (currentTime - startTime) / 1000 

            local remainingSeconds = math.max(countdown - elapsedSeconds, 0) 
            local minutes = math.floor(remainingSeconds / 60)
            local seconds = math.floor(remainingSeconds % 60)

            if remainingSeconds == 0 then
                color = "~g~"
            end

            local countdownLabel = string.format(color.. "I agree to the above")

            RageUI.Button(countdownLabel, "", { RightLabel = seconds }, remainingSeconds <= 0, function(Hovered, Active, Selected)
                if Selected then
                    TriggerServerEvent('VICE:SellVehicle', e)
                end
            end)
        end)
    elseif menuVisible then
        menuVisible = false 
        startTime = 0 
    end
end)