local a = 0
local b = 0
local c = 0
local d = 3
proximityIdToString = {[1] = "Whisper", [2] = "Talking", [3] = "Shouting"}
local e, f = GetActiveScreenResolution()
local g = {}
local h = GetResourceKvpString("vice_custom_pfp") or ""
g["Custom"] = h
RegisterNetEvent("VICE:showHUD")
AddEventHandler(
    "VICE:showHUD",
    function(i)
        showhudUI(i)
    end
)
AddEventHandler(
    "pma-voice:setTalkingMode",
    function(j)
        d = j
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
function updateMoneyUI(l, m, n, o, k, p)
    SendNUIMessage(
        {
            updateMoney = true,
            cash = l,
            bank = m,
            redmoney = n,
            proximity = proximityIdToString[o],
            topLeftAnchor = k,
            yAnchor = p
        }
    )
end
function showhudUI(i)
    SendNUIMessage({showMoney = i})
    SendNUIMessage({
        permId = VICE.getUserId()
    })
end
RegisterNetEvent("VICE:setProfilePictures")
AddEventHandler(
    "VICE:setProfilePictures",
    function(q)
        g = q
    end
)
RegisterNetEvent("VICE:setDisplayMoney")
RegisterNetEvent(
    "VICE:setDisplayMoney",
    function(r)
        local s = tostring(math.floor(r))
        a = getMoneyStringFormatted(s)
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("VICE:setDisplayBankMoney")
AddEventHandler(
    "VICE:setDisplayBankMoney",
    function(r)
        local s = tostring(math.floor(r))
        b = getMoneyStringFormatted(s)
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("VICE:setDisplayRedMoney")
AddEventHandler(
    "VICE:setDisplayRedMoney",
    function(r)
        local s = tostring(math.floor(r))
        c = getMoneyStringFormatted(s)
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
RegisterNetEvent("VICE:initMoney")
AddEventHandler(
    "VICE:initMoney",
    function(l, m)
        local t = tostring(math.floor(l))
        a = getMoneyStringFormatted(t)
        local s = tostring(math.floor(m))
        b = getMoneyStringFormatted(s)
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, k.rightX * k.resX)
    end
)
Citizen.CreateThread(
    function()
        Wait(4000)
        while VICE.getUserId() == nil do
            Wait(100)
        end
        TriggerServerEvent("VICE:requestPlayerBankBalance")
        TriggerServerEvent("VICE:SetDiscordName")
        local u = false
        while true do
            local v, w = GetActiveScreenResolution()
            if v ~= e or w ~= f then
                e, f = GetActiveScreenResolution()
                cachedMinimapAnchor = GetMinimapAnchor()
                updateMoneyUI("£" .. a, "£" .. b, "£" .. c, d, cachedMinimapAnchor.rightX * cachedMinimapAnchor.resX)
            end
            if NetworkIsPlayerTalking(PlayerId()) then
                if not u then
                    u = true
                    SendNUIMessage({moneyTalking = true})
                end
            else
                if u then
                    u = false
                    SendNUIMessage({moneyTalking = false})
                end
            end
            Wait(0)
        end
    end
)
RegisterNUICallback(
    "moneyUILoaded",
    function(data, cb)
        local k = tVICE.getCachedMinimapAnchor()
        updateMoneyUI("£" .. tostring(a), "£" .. tostring(b), "£" .. tostring(c), d, k.rightX * k.resX)

        -- Trigger server event to get user ID
        TriggerServerEvent('requestUserId')
    end
)


RegisterNetEvent('receiveUserId')
AddEventHandler('receiveUserId', function(userId)
    SendNUIMessage({
        action = "displayUserId",
        userId = userId
    })
end)

-- Request user ID from the server
TriggerServerEvent('requestUserId')


local pfp = nil
function tVICE.updatePFPType(z)
    pfp = z
    if z == "Custom" then
        SendNUIMessage({setPFP = GetResourceKvpString("vice_custom_pfp")})
    else
        SendNUIMessage({setPFP = g[z]})
    end
end
function tVICE.updatePFPSize(A)
    SendNUIMessage({setPFPSize = A})
end                                     

function tVICE.GetPFP()
    return pfp == "Custom" and GetResourceKvpString("vice_custom_pfp") or g[pfp]
end

-- Request the Discord avatar from the server when the HUD loads
Citizen.CreateThread(function()
    Wait(5000) -- Wait a bit to make sure everything is loaded
    TriggerServerEvent("VICE:requestAvatar", VICE.getUserId())
end)

RegisterNetEvent('VICE:receiveAvatar')
AddEventHandler('VICE:receiveAvatar', function(url)
    SendNUIMessage({
        setPFP = url
    })
end)

RegisterNetEvent("VICE:showMoneyHUD")
AddEventHandler("VICE:showMoneyHUD", function()
    -- ... your other HUD code ...
    SendNUIMessage({
        permId = VICE.getUserId()
    })
end)

Citizen.CreateThread(function()
    Citizen.Wait(5000) -- wait for HUD to load
    SendNUIMessage({
        permId = VICE.getUserId()
    })
end)