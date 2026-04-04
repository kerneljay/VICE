local cfg = {}

cfg.staffDoor = vector3(256.72, 220.39, 106.29)
cfg.staffDoorModel = -222270721
cfg.staffDoorThermiteModel = `hei_v_ilev_bk_gate_molten`

cfg.vaultDoor = vector3(262.06, 222.07, 106.28)
cfg.vaultDoorModel = 746855201
cfg.vaultDoorHack = vector3(261.62, 223.21, 106.28)

cfg.lockedDoor = vector3(265.74, 218.27, 110.28)
cfg.lockedDoorModel = 1956494919

cfg.safeDoor = vector3(254.16, 224.3, 101.88)
cfg.safeDoorModel = 961976194
cfg.safeDoorButton = vector3(253.28, 228.29, 101.68)

cfg.alarms = {
    vector3(237.26, 228.38, 108.27),
    vector3(237.16, 228.02, 112.30),
    vector3(256.61, 206.84, 112.31),
    vector3(265.78, 217.90, 112.37),
    vector3(250.38, 231.17, 108.50),
    vector3(244.62, 209.08, 108.07),
    vector3(259.72, 213.95, 108.21),
    vector3(268.14, 224.70, 107.15),
    vector3(259.80, 227.74, 103.71)
}

cfg.staffDoorHack = {
    position = vector3(257.40, 220.20, 106.35),
    heading = 336.48,
    particle = vector3(257.39, 221.20, 106.29)
}

cfg.terminalHack = {
    words = {
        "BANKDOOR",
        "LOCKGATE",
        "TERMINAL",
        "GREENKEY"
    }
}

cfg.trollies = {
    {
        model = 269934519,
        position = vector3(257.44, 215.07, 101.15),
        handModel = `hei_prop_heist_cash_pile`,
        heading = 0.0,
        name = "cash",
        item = "bankheists_cash"
    },
    {
        model = 269934519,
        position = vector3(262.34, 213.28, 101.15),
        handModel = `hei_prop_heist_cash_pile`,
        heading = 0.0,
        name = "cash",
        item = "bankheists_cash"
    },
    {
        model = 269934519,
        position = vector3(263.45, 216.05, 101.15),
        handModel = `hei_prop_heist_cash_pile`,
        heading = 150.0,
        name = "cash",
        item = "bankheists_cash"
    },
    {
        model = 2007413986,
        position = vector3(266.02, 215.34, 101.15),
        handModel = `ch_prop_gold_bar_01a`,
        heading = 150.0,
        name = "gold",
        item = "bankheists_gold"
    },
    {
        model = 881130828,
        position = vector3(265.11, 212.05, 101.15),
        handModel = `ch_prop_vault_dimaondbox_01a`,
        heading = 0.0,
        name = "diamonds",
        item = "bankheists_diamonds"
    },
    {
        model = 881130828,
        position = vector3(256.0, 218.5, 101.15),
        handModel = `ch_prop_vault_dimaondbox_01a`,
        heading = 150.0,
        name = "diamonds",
        item = "bankheists_diamonds"
    },
    {
        model = 2007413986,
        position = vector3(260.45, 217.04, 101.15),
        handModel = `ch_prop_gold_bar_01a`,
        heading = 150.0,
        name = "gold",
        item = "bankheists_gold"
    }
}

cfg.gases = {
    {
        position = vector3(262.78, 213.22, 101.68),
        scale = 1.8
    },
    {
        position = vector3(257.71, 216.64, 101.68),
        scale = 2.5
    },
    {
        position = vector3(252.71, 218.22, 101.6),
        scale = 2.5
    }
}

cfg.timeToGas = 60000

cfg.setupVehicles = {
    {
        model = `gtr`,
        position = vector3(732.99, -981.34, 23.83),
        heading = 273.11
    },
    {
        model = `focusrs`,
        position = vector3(732.44, -986.76, 24.22),
        heading = 274.39
    },
    {
        model = `punto`,
        position = vector3(722.24, -987.22, 23.4),
        heading = 271.77
    },
    {
        model = `yzfr6`,
        position = vector3(711.15, -988.32, 23.46),
        heading = 270.46
    },
    {
        model = `yzfr6`,
        position = vector3(710.94, -968.27, 23.46),
        heading = 270.46
    },
    {
        model = `16m5`,
        position = vector3(703.52, -987.33, 23.47),
        heading = 275.33
    }
}

cfg.sellLocation = vector3(515.69, -1617.43, 29.28)

cfg.sellableItems = {
    ["Gold Pile"] = "bankheists_gold",
    ["Diamond Pile"] = "bankheists_diamonds"
}

cfg.payouts = {
    ["bankheists_cash"] = 142857,
    ["bankheists_gold"] = 285714,
    ["bankheists_diamonds"] = 501428
}

cfg.setups = {
    {
        title = "Setup One: Aquire Hacking Device",
        description = "Penetrate the security of the facility to gain access to the hacking device.\nDifficulty: Easy",
        position = vector3(-661.81,-230.36,53.71),
        heading = 53.85,
        rotation = vector3(-27.91, 0.05, -60.49),
        cost = 500000
    },
    {
        title = "Setup Two: Vangelico Heist",
        description = "Gass out the members inside, Hack into the computer to steal the jewerly.\nDifficulty: Hard",
        position = vector3(3693.81, 3857.69, 68.04),
        heading = 120.37,
        rotation = vector3(-5.68, 0.0, 130.89),
        cost = 1000000
    }
}

cfg.armourCost = 100000

cfg.alarmDisablePos = vector3(258.52, 275.43, 105.62)

cfg.playerDelayBetweenHeists = 259200 -- 3 days in seconds

return cfg