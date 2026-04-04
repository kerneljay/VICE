RMenu.Add("viceannouncements","main",RageUI.CreateMenu("","~s~A~w~nnouncement Menu",VICE.getRageUIMenuWidth(),VICE.getRageUIMenuHeight(),"menus","announcement"))
local a = {}

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('viceannouncements', 'main')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for b, c in pairs(a) do
                RageUI.Button(c.name, string.format("%s Price: £%s", c.desc, getMoneyStringFormatted(c.price)), {RightLabel = "→→→"}, true, function(d, e, f)
                    if f then
                        TriggerServerEvent("VICE:serviceAnnounce", c.name)
                    end
                end)
            end
        end)
    end
end)

RegisterNetEvent("VICE:serviceAnnounceCl",function(h, i)
    if h and i then
        tVICE.announce(h, i)
    end
end)

RegisterNetEvent("VICE:buildAnnounceMenu",function(g)
    a = g
    RageUI.Visible(RMenu:Get("viceannouncements", "main"), not RageUI.Visible(RMenu:Get("viceannouncements", "main")))
end)

RegisterCommand("amenu",function()
    TriggerServerEvent('VICE:getAnnounceMenu')
end)
