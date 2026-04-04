local a = module("cfg/cfg_groupselector")
local b = a.selectors
local c = {}
local d = false
local e = ""
RMenu.Add("main","groupselector",RageUI.CreateMenu("", "", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus", "licenses"))
RMenu:Get("main", "groupselector"):SetSubtitle("Select a job.")
AddEventHandler("VICE:onClientSpawn",function(D, E)
    if E and not VICE.isInPurge() then
		TriggerServerEvent("VICE:getJobSelectors")
        TriggerServerEvent('VICE:getFactionWhitelistedGroups')
	end
end)
RegisterNetEvent("VICE:gotJobSelectors",function(h)
    c = h
    local i = function(j)
        e = j.selectorId
    end
    local k = function(j)
        RageUI.ActuallyCloseAll()
        RageUI.Visible(RMenu:Get("main", "groupselector"), false)
    end
    local l = function(j)
        if IsControlJustPressed(1, 38) then
            local m = b[j.selectorId].type
            RageUI.ActuallyCloseAll()
            RMenu:Get("main", "groupselector"):SetSpriteBanner(a.selectorTypes[m]._config.TextureDictionary,a.selectorTypes[m]._config.texture)
            RageUI.Visible(RMenu:Get("main", "groupselector"), true)
        end
        local n, o, p = table.unpack(GetFinalRenderedCamCoord())
        DrawText3D(b[j.selectorId].position.x,b[j.selectorId].position.y,b[j.selectorId].position.z,"Press [E] to open Job Selector.",n,o,p)
    end
    for q, r in pairs(c) do
        VICE.createArea("selector_" .. q, r.position, 1.5, 6, i, k, l, {selectorId = q})
        tVICE.addMarker(r.position.x, r.position.y, r.position.z - 1, 1.0, 1.0, 1.0, 255, 0, 0, 170, 50, 27)
        tVICE.addBlip(r.position.x,r.position.y,r.position.z,r._config.blipid,r._config.blipcolor,r._config.name)
    end
end)

local enabledJobs = true

RegisterNetEvent("VICE:jobSelectorCooldown")
AddEventHandler("VICE:jobSelectorCooldown", function(value)
    enabledJobs = value
end)

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get('main', 'groupselector')) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            for q, r in pairs(c) do
                if q == e then
                    for s, t in pairs(r.jobs) do
                        RageUI.Button(t[1],r._config.name,{RightLabel = "→→→"},enabledJobs,function(u, v, w)
                            if w and enabledJobs then
                                TriggerServerEvent("VICE:jobSelector", q, t[1])
                                SetTimeout(1000,function()
                                    TriggerServerEvent("VICE:refreshGaragePermissions")
                                    ExecuteCommand("blipson")
                                end)
                            end
                        end)
                    end
                    RageUI.Button("Unemployed","",{RightLabel = "→→→"},true,function(u, v, w)
                        if w then
                            TriggerServerEvent("VICE:jobSelector", q, "Unemployed")
                            SetTimeout(1000,function()
                                TriggerServerEvent("VICE:refreshGaragePermissions")
                            end)
                        end
                    end)
                end
            end
        end)
    end
end)

