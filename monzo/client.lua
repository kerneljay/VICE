local lastMoneyAmount = 0

local function AddApp()
    local added, errorMessage = exports["lb-phone"]:AddCustomApp({
        identifier = "monzo",
        name = "Monzo",
        description = "VICE Banking",
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

local function updateMonzoMoney(amount)
    exports["lb-phone"]:SendCustomAppMessage("monzo", {
        type = "setMonzoMoney",
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

    RegisterNUICallback("transferMonzoMoney", function(data, cb)
        if data.permId and data.moneyAmount then
            local permId = tonumber(data.permId)
            local moneyAmount = tonumber(data.moneyAmount)
            if permId and moneyAmount then
                TriggerServerEvent("VICE:bankTransfer", permId, moneyAmount)
            end
        end
        cb("ok")
    end)

    RegisterNUICallback("getMoneyMoney", function(data, cb)
        updateMonzoMoney(lastMoneyAmount)
        cb("ok")
    end)
end)

RegisterNetEvent("VICE:initMoney", function(_, bank)
    lastMoneyAmount = bank
    while GetResourceState("lb-phone") ~= "started" do
        Wait(2000)
    end
    updateMonzoMoney(bank)
end)

RegisterNetEvent("VICE:setDisplayBankMoney", function(value)
    lastMoneyAmount = value
    while GetResourceState("lb-phone") ~= "started" do
        Wait(2000)
    end
    updateMonzoMoney(value)
end)