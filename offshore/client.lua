local lastMoneyAmount = 0

local function AddApp()
    local added, errorMessage = exports["lb-phone"]:AddCustomApp({
        identifier = "offshore",
        name = "Offshore",
        description = "Offshore Banking",
        developer = "VICE",
        defaultApp = true,
        size = 59812,
        images = {},
        ui = GetCurrentResourceName() .. "/ui/dist/index.html",
        icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/icon.png"
    })
    if not added then
        print("Error adding app: " .. errorMessage)
    end
end

local function updateOffshoreMoney(amount)
    exports["lb-phone"]:SendCustomAppMessage("offshore", {
        type = "setOffshoreMoney",
        amount = amount
    })
end

AddEventHandler("playerSpawned", function()
    Wait(3000)
    while GetResourceState("lb-phone") ~= "started" do
        Wait(2000)
    end

    AddApp()

    AddEventHandler("onResourceStart", function(resource)
        if resource == "lb-phone" then
            AddApp()
        end
    end)

    RegisterNUICallback("depositOffshoreMoney", function(data, cb)
        if data.moneyAmount then
            local moneyAmount = tonumber(data.moneyAmount)
            if moneyAmount then
                TriggerServerEvent("VICE:depositOffshoreMoney", moneyAmount)
            end
        end
        cb("ok")
    end)

    RegisterNUICallback("withdrawOffshoreMoney", function(data, cb)
        if data.moneyAmount then
            local moneyAmount = tonumber(data.moneyAmount)
            if moneyAmount then
                TriggerServerEvent("VICE:withdrawOffshoreMoney", moneyAmount)
            end
        end
        cb("ok")
    end)

    RegisterNUICallback("depositAllOffshoreMoney", function(data, cb)
        TriggerServerEvent("VICE:depositAllOffshoreMoney")
        cb("ok")
    end)

    RegisterNUICallback("withdrawAllOffshoreMoney", function(data, cb)
        TriggerServerEvent("VICE:withdrawAllOffshoreMoney")
        cb("ok")
    end)

    RegisterNUICallback("getOffshoreMoney", function(data, cb)
        updateOffshoreMoney(lastMoneyAmount)
        cb("ok")
    end)
end)

RegisterNetEvent("VICE:setDisplayOffshore", function(value)
    lastMoneyAmount = value
    while GetResourceState("lb-phone") ~= "started" do
        Wait(2000)
    end
    updateOffshoreMoney(lastMoneyAmount)
end)