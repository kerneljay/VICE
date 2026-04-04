local a = {
    ["fbiBuilding"] = {
        [1] = {
            coords = vector3(136.41923522949, -748.74853515625, 42.16618347168),
            name = "Basement",
            otherLocs = {2, 3, 4, 5, 6, 7, 8}
        },
        [2] = {
            coords = vector3(136.06645202637, -761.75689697266, 45.763332366943),
            name = "Ground Floor",
            otherLocs = {1, 3, 4, 5, 6, 7, 8}
        },
        [3] = {
            coords = vector3(151.33334350586, -738.76287841797, 50.138023376465),
            name = "First Floor",
            otherLocs = {1, 2, 4, 5, 6, 7, 8}
        },
        [4] = {
            coords = vector3(136.16481018066, -761.80847167969, 242.15209960938),
            name = "2 - Communications",
            otherLocs = {1, 2, 3, 5, 6, 7, 8}
        },
        [5] = {
            coords = vector3(136.16780090332, -761.8671875, 234.15197753906),
            name = "Floor 47",
            otherLocs = {1, 2, 3, 4, 6, 7, 8}
        },
        [6] = {
            coords = vector3(139.16221618652, -768.35607910156, 246.15219116211),
            name = "Floor 50",
            otherLocs = {1, 2, 3, 4, 5, 7, 8}
        },
        [7] = {
            coords = vector3(133.76487731934, -732.63513183594, 250.15225219727),
            name = "Floor 51",
            otherLocs = {1, 2, 3, 4, 5, 6, 8}
        },
        [8] = {
            coords = vector3(120.47282409668, -733.80236816406, 258.1520690918),
            name = "Top Floor",
            otherLocs = {1, 2, 3, 4, 5, 6, 7}
        },
        [9] = {coords = vector3(141.2733, -735.0833, 262.8515), name = "Rooftop", otherLocs = {10}},
        [10] = {coords = vector3(114.8448, -741.8557, 258.152), name = "Rooftop exit", otherLocs = {9}}
    },
    ["surrealsHotel"] = {
        [1] = {
            coords = vector3(380.54278564453, -15.391418457031, 82.997825622559),
            name = "Elevator Garage",
            otherLocs = {2, 3, 4}
        },
        [2] = {
            coords = vector3(414.70465087891, -15.230644226074, 99.645545959473),
            name = "Left Lift",
            otherLocs = {1, 3, 4}
        },
        [3] = {
            coords = vector3(417.26272583008, -10.588271141052, 99.645538330078),
            name = "Right Lift",
            otherLocs = {1, 2, 4}
        },
        [4] = {
            coords = vector3(419.90054321289, -15.72283744812, 152.95458984375),
            name = "Roof lift",
            otherLocs = {1, 2, 3}
        }
    },
    ["nhsNewHospital1"] = {
        [1] = {
            coords = vector3(-490.51202392578, -327.44174194336, 41.420713043213),
            name = "Pharmacy",
            otherLocs = {2, 3, 4, 5, 6}
        },
        [2] = {
            coords = vector3(-418.69403076172, -344.67877197266, 23.331834411621),
            name = "Parking",
            otherLocs = {1, 3, 4, 5, 6}
        },
        [3] = {
            coords = vector3(-452.4372253418, -288.46655273438, 33.894596099854),
            name = "Main Ward",
            otherLocs = {1, 2, 4, 5, 6}
        },
        [4] = {coords = vector3(-452.63, -288.5, -131.84), name = "Surgical Ward", otherLocs = {1, 2, 3, 5, 6}},
        [5] = {
            coords = vector3(-452.58471679688, -288.41131591797, 68.604219055176),
            name = "Private Rooms",
            otherLocs = {1, 2, 3, 4, 6}
        },
        [6] = {
            coords = vector3(-490.54724121094, -327.59460449219, 68.604783630371),
            name = "Offices",
            otherLocs = {1, 2, 3, 4, 5}
        }
    }
}
local b = 2
local c = ""
RMenu.Add(
    "vicefbielevators",
    "main",
    RageUI.CreateMenu("VICE Elevators", "FBI Building", VICE.getRageUIMenuWidth(), VICE.getRageUIMenuHeight())
)
RageUI.CreateWhile(
    1.0,
    true,
    RMenu:Get("vicefbielevators", "main"),
    function()
        RageUI.IsVisible(
            RMenu:Get("vicefbielevators", "main"),
            true,
            false,
            true,
            function()
                for d = 1, #a[c][b].otherLocs, 1 do
                    local e = a[c][b].otherLocs[d]
                    RageUI.Button(
                        a[c][e].name,
                        nil,
                        {RightLabel = "→→"},
                        function(f, g, h)
                            if h then
                                local i = VICE.getPlayerPed()
                                DoScreenFadeOut(500)
                                Citizen.Wait(500)
                                SetEntityCoords(i, a[c][e].coords)
                                SetEntityHeading(i, 35.0)
                                DoScreenFadeIn(700)
                                Citizen.Wait(500)
                            end
                        end
                    )
                end
            end,
            function()
            end
        )
    end
)
AddEventHandler(
    "VICE:onClientSpawn",
    function(j, k)
        if k then
            local l = function(m)
                c = m.locationId
                b = m.closestId
                RageUI.Visible(RMenu:Get("vicefbielevators", "main"), true)
            end
            local n = function()
                RageUI.Visible(RMenu:Get("vicefbielevators", "main"), false)
            end
            local o = function()
                RMenu:Get("vicefbielevators", "main"):SetSubtitle(string.format("~w~You are on ~b~%s", a[c][b].name))
            end
            for p, q in pairs(a) do
                for r, s in pairs(q) do
                    VICE.createArea(
                        "elevator_" .. tVICE.generateUUID("elevator", 10, "alphabet"),
                        s.coords,
                        1.5,
                        6,
                        l,
                        n,
                        o,
                        {locationId = p, closestId = r}
                    )
                    tVICE.addMarker(
                        s.coords.x,
                        s.coords.y,
                        s.coords.z - 0.98,
                        1.0001,
                        1.0001,
                        0.5001,
                        255,
                        255,
                        255,
                        200,
                        20.0,
                        27,
                        true,
                        false,
                        false,
                        nil,
                        nil,
                        0.0,
                        0.0,
                        0.0
                    )
                end
            end
        end
    end
)
