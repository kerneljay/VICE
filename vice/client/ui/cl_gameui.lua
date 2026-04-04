local a = {
    ["AIRP"] = "Los Santos International Airport",
    ["ALAMO"] = "Alamo Sea",
    ["ALTA"] = "Alta",
    ["ARMYB"] = "Fort Zancudo",
    ["BANHAMC"] = "Banham Canyon Dr",
    ["BANNING"] = "Banning",
    ["BEACH"] = "Vespucci Beach",
    ["BHAMCA"] = "Banham Canyon",
    ["BRADP"] = "Braddock Pass",
    ["BRADT"] = "Braddock Tunnel",
    ["BURTON"] = "Burton",
    ["CALAFB"] = "Calafia Bridge",
    ["CANNY"] = "Raton Canyon",
    ["CCREAK"] = "Cassidy Creek",
    ["CHAMH"] = "Chamberlain Hills",
    ["CHIL"] = "Vinewood Hills",
    ["CHU"] = "Chumash",
    ["CMSW"] = "Chiliad Mountain State Wilderness",
    ["CYPRE"] = "Cypress Flats",
    ["DAVIS"] = "Davis",
    ["DELBE"] = "Del Perro Beach",
    ["DELPE"] = "Del Perro",
    ["DELSOL"] = "La Puerta",
    ["DESRT"] = "Grand Senora Desert",
    ["DOWNT"] = "Downtown",
    ["DTVINE"] = "Downtown Vinewood",
    ["EAST_V"] = "East Vinewood",
    ["EBURO"] = "El Burro Heights",
    ["ELGORL"] = "El Gordo Lighthouse",
    ["ELYSIAN"] = "Elysian Island",
    ["GALFISH"] = "Galilee",
    ["GOLF"] = "GWC and Golfing Society",
    ["GRAPES"] = "Grapeseed",
    ["GREATC"] = "Great Chaparral",
    ["HARMO"] = "Harmony",
    ["HAWICK"] = "Hawick",
    ["HORS"] = "Vinewood Racetrack",
    ["HUMLAB"] = "Humane Labs and Research",
    ["JAIL"] = "Bolingbroke Penitentiary",
    ["KOREAT"] = "Little Seoul",
    ["LACT"] = "Land Act Reservoir",
    ["LAGO"] = "Lago Zancudo",
    ["LDAM"] = "Land Act Dam",
    ["LEGSQU"] = "Legion Square",
    ["LMESA"] = "La Mesa",
    ["LOSPUER"] = "La Puerta",
    ["MIRR"] = "Mirror Park",
    ["MORN"] = "Morningwood",
    ["MOVIE"] = "Richards Majestic",
    ["MTCHIL"] = "Mount Chiliad",
    ["MTGORDO"] = "Mount Gordo",
    ["MTJOSE"] = "Mount Josiah",
    ["MURRI"] = "Murrieta Heights",
    ["NCHU"] = "North Chumash",
    ["NOOSE"] = "N.O.O.S.E",
    ["OCEANA"] = "Pacific Ocean",
    ["PALCOV"] = "Paleto Cove",
    ["PALETO"] = "Paleto Bay",
    ["PALFOR"] = "Paleto Forest",
    ["PALHIGH"] = "Palomino Highlands",
    ["PALMPOW"] = "Palmer-Taylor Power Station",
    ["PBLUFF"] = "Pacific Bluffs",
    ["PBOX"] = "Pillbox Hill",
    ["PROCOB"] = "Procopio Beach",
    ["RANCHO"] = "Rancho",
    ["RGLEN"] = "Richman Glen",
    ["RICHM"] = "Richman",
    ["ROCKF"] = "Rockford Hills",
    ["RTRAK"] = "Redwood Lights Track",
    ["SANAND"] = "San Andreas",
    ["SANCHIA"] = "San Chianski Mountain Range",
    ["SANDY"] = "Sandy Shores",
    ["SKID"] = "Mission Row",
    ["SLAB"] = "Stab City",
    ["STAD"] = "Maze Bank Arena",
    ["STRAW"] = "Strawberry",
    ["TATAMO"] = "Tataviam Mountains",
    ["TERMINA"] = "Terminal",
    ["TEXTI"] = "Textile City",
    ["TONGVAH"] = "Tongva Hills",
    ["TONGVAV"] = "Tongva Valley",
    ["VCANA"] = "Vespucci Canals",
    ["VESP"] = "Vespucci",
    ["VINE"] = "Vinewood",
    ["WINDF"] = "Ron Alternates Wind Farm",
    ["WVINE"] = "West Vinewood",
    ["ZANCUDO"] = "Zancudo River",
    ["ZP_ORT"] = "Port of South Los Santos",
    ["ZQ_UAR"] = "Davis Quartz"
}
local b = false
local w3w = false
local c
local w3wWord = "N/A"
local d = ""
Citizen.CreateThread(function()
    while true do
        local e = VICE.getPlayerCoords()
        local zone = GetNameOfZone(e.x, e.y, e.z)
        c, _ = GetStreetNameAtCoord(e.x, e.y, e.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        d = a[zone] or "N/A"
        Wait(2000)
    end
end)
function func_drawStreetNamesGameUi(f)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    if b and not globalHideUi and not globalHideEmergencyCallUI then
        local g = tVICE.getCachedMinimapAnchor()
        VICE.DrawText(g.leftX + 0.0045, g.topY - 0.03, tostring(GetStreetNameFromHashKey(c)) .. " ~w~| ~b~" .. d, 0.4)
    end
end
function func_drawW3WGameUi(f)
    HideHudComponentThisFrame(2)
    HideHudComponentThisFrame(3)
    HideHudComponentThisFrame(4)
    if w3w and not globalHideUi and not globalHideEmergencyCallUI then
        local g = tVICE.getCachedMinimapAnchor()
        w3wWord = VICE.getW3W()
        VICE.DrawText(g.leftX + 0.0045, g.topY - 0.06, "~y~W3W ~w~| ~b~" .. w3wWord, 0.4)
    end
end
VICE.createThreadOnTick(func_drawStreetNamesGameUi)
VICE.createThreadOnTick(func_drawW3WGameUi)
RegisterCommand("streetnames",function()
    b = not b
end)
RegisterCommand("w3w",function()
    w3w = not w3w
end)
function tVICE.isStreetnamesEnabled()
    return b
end
function tVICE.setStreetnamesEnabled(h)
    b = h
    SetResourceKvp("vice_streetnames", tostring(h))
end
function tVICE.isW3WEnabled()
    return w3w
end
function tVICE.setW3WEnabled(h)
    w3w = h
    SetResourceKvp("vice_w3w", tostring(h))
end
Citizen.CreateThread(function()
    local i = GetResourceKvpString("vice_streetnames") or "false"
    if i == "false" then
        b = false
    else
        b = true
    end
end)

Citizen.CreateThread(function()
    local ii = GetResourceKvpString("vice_w3w") or "false"
    if ii == "false" then
        w3w = false
    else
        w3w = true
    end
end)

function VICE.getCurrentLocation()
    return d
end

