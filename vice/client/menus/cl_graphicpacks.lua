RMenu.Add("VICE","graphicpacks", RageUI.CreateMenu("", "~b~Graphic Packs",VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight(),"menus", "graphics"))


local graphicsdata = {
    enabled = false,
    Types = {
        tbl = {"Default","Far Clip","Low Clip"},
        index = 1,
    },
    Weather = {
        tbl = {"Clear Sky","Neon Sky","Color 2","Color","Grey Sky"},
        variables = {"EXTRASUNNY","FOGGY","OVERCAST","NEUTRAL","CLEAR"},
        index = 1,
    },
    Time = {
        tbl = {},
        index = 1,
    }
}
for i = 0, 23 do
    table.insert(graphicsdata.Time.tbl, i)
end

local function GraphicsEnable()
    graphicsdata.enabled = not graphicsdata.enabled
    SetResourceKvp("vice_graphics1", json.encode(graphicsdata))
end

local function GraphicsDisable()
    graphicsdata.enabled = not graphicsdata.enabled
    SetResourceKvp("vice_graphics1", json.encode(graphicsdata))
end

local function SetTimeCycle(TimeCycle)
    if TimeCycle == "Default" then
        ClearTimecycleModifier()
    elseif TimeCycle == "Far Clip" then
        SetTimecycleModifier("wts_far")
    elseif TimeCycle == "Low Clip" then
        SetTimecycleModifier("wts_low")
    end
end

local function SetWeather(weather)
    if weather == "Neon Sky" then
        VICE.setWeather("FOGGY")
    elseif weather == "Color 2" then
        VICE.setWeather("OVERCAST")
    elseif weather == "Color" then
        VICE.setWeather("NEUTRAL")
    elseif weather == "Grey Sky" then
        VICE.setWeather("CLEAR")
    elseif weather == "Clear Sky" then
        VICE.setWeather("EXTRASUNNY")
    end
end

RageUI.CreateWhile(1.0, true, function()
    if RageUI.Visible(RMenu:Get("VICE","graphicpacks")) then
        RageUI.DrawContent({ header = true, glare = false, instructionalButton = false}, function()
            RageUI.Checkbox("Enable/Disable","",graphicsdata.enabled,{Style = RageUI.CheckboxStyle.Car},function(z, w, v, A)
            end,GraphicsEnable,GraphicsDisable)

            if graphicsdata.enabled then
                RageUI.List("Type",graphicsdata.Types.tbl,graphicsdata.Types.index,nil,{},true,function(Hovered,Active,Selected,Index)
                    if graphicsdata.Types.index ~= Index then
                        graphicsdata.Types.index = Index
                        SetTimeCycle(graphicsdata.Types.tbl[Index])
                        SetResourceKvp("vice_graphics1", json.encode(graphicsdata))
                    end
                end)
                RageUI.List("Weather",graphicsdata.Weather.tbl,graphicsdata.Weather.index,nil,{},true,function(Hovered,Active,Selected,Index)
                    if graphicsdata.Weather.index ~= Index then
                        graphicsdata.Weather.index = Index
                        SetWeather(graphicsdata.Weather.tbl[Index])
                        SetResourceKvp("vice_graphics1", json.encode(graphicsdata))
                    end
                end)
                RageUI.List("Time",graphicsdata.Time.tbl,graphicsdata.Time.index,nil,{},true,function(Hovered,Active,Selected,Index)
                    if graphicsdata.Time.index ~= Index then
                        graphicsdata.Time.index = Index
                        VICE.overrideTime(graphicsdata.Time.index,0,0)
                        SetResourceKvp("vice_graphics1", json.encode(graphicsdata))
                    end
                end)
            end
        end)
    end
end)

Citizen.CreateThread(function()
    local data = json.decode(GetResourceKvpString("vice_graphics1"))
    if data then
        graphicsdata = data
        if graphicsdata.enabled then
            SetTimeCycle(graphicsdata.Types.tbl[graphicsdata.Types.index])
            SetWeather(graphicsdata.Weather.tbl[graphicsdata.Weather.index])
            VICE.overrideTime(graphicsdata.Time.index,0,0)
        end
    end
end)