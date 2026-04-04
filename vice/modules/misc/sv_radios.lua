local cfg = module("cfg/cfg_radios")

local function getRadioType(user_id)
    if VICE.hasPermission(user_id, "police.armoury") then
        return "Police"
    elseif VICE.hasPermission(user_id, "nhs.menu") then
        return "NHS"
    elseif VICE.hasPermission(user_id, "hmp.menu") then
        return "HMP"
    elseif VICE.hasPermission(user_id, "ukbf.armoury") then
        return "UKBF"
    elseif VICE.hasPermission(user_id, "lfb.menu") then
        return "LFB"
    end
    return false
end

local function getFactionRadioType(user_id)
    if VICE.hasPermission(user_id, "nhs.menu") or VICE.hasPermission(user_id, "hmp.menu") or VICE.hasPermission(user_id, "police.armoury") then
        return "Faction"
    end
    return false
end

local radioChannels = {
    ['Police'] = {
        name = 'Police',
        players = {},
        channel = 1,
        callsign = true,
    },
    ['NHS'] = {
        name = 'NHS',
        players = {},
        channel = 2,
    },
    ['HMP'] = {
        name = 'HMP',
        players = {},
        channel = 3,
    },
    ['Faction'] = {
        name = 'Faction',
        players = {},
        channel = 4,
    },
    ['UKBF'] = {
        name = 'UKBF',
        players = {},
        channel = 5,
        callsign = true,
    },
    ['LFB'] = {
        name = 'LFB',
        players = {},
        channel = 6,
    },
}

function createRadio(source)
    local source = source
    local user_id = VICE.getUserId(source)
    local radioType = getRadioType(user_id)
    local factionType = getFactionRadioType(user_id)
    
    if radioType then
        Wait(1000)
        for k,v in pairs(cfg.sortOrder[radioType]) do
            if VICE.hasPermission(user_id, v) then
                local sortOrder = k
                local name = VICE.getPlayerName(user_id)
                local callsign = getCallsign(radioType, source, user_id, radioType)
                if radioChannels[radioType].callsign then
                    if callsign then
                        name = name.." ["..callsign.."]"
                    end
                end
                radioChannels[radioType]['players'][source] = {name = name, sortOrder = sortOrder}
                TriggerClientEvent('VICE:radiosCreateChannel', source, radioChannels[radioType].channel, radioChannels[radioType].name, radioChannels[radioType].players, true)
                if factionType then
                    TriggerClientEvent('VICE:radiosCreateChannel', source, radioChannels[factionType].channel, radioChannels[factionType].name, radioChannels[factionType].players, false)
                    TriggerClientEvent('VICE:radiosAddPlayer', -1, radioChannels[factionType].channel, source, {name = name, sortOrder = sortOrder})
                    TriggerEvent("VICE:ChatClockOn", source, factionType, true)
                end
                TriggerClientEvent('VICE:radiosAddPlayer', -1, radioChannels[radioType].channel, source, {name = name, sortOrder = sortOrder})
                TriggerEvent("VICE:ChatClockOn", source, radioType, true)
                TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
            end
        end
    else
        local gang = VICE.getGangName(user_id)
        if gang and gang ~= "" then
            if not radioChannels[gang] then
                radioChannels[gang] = {name = gang, players = {}, channel = math.random(5, 1000)}
            end
            
            local name = VICE.getPlayerName(user_id)
            radioChannels[gang]['players'][source] = {name = name, sortOrder = 1}
            TriggerClientEvent('VICE:radiosCreateChannel', source, radioChannels[gang].channel, radioChannels[gang].name, radioChannels[gang].players, true)
            TriggerClientEvent('VICE:radiosAddPlayer', -1, radioChannels[gang].channel, source, {name = name, sortOrder = 1})
            TriggerEvent("VICE:ChatClockOn", source, "Gang", true)
        end
    end
end

function VICE.getCurrentRadio(source)
    local source = source
    local user_id = VICE.getUserId(source)
    local radioType = getRadioType(user_id)
    local factionType = getFactionRadioType(user_id)
    if radioType then
        return radioType
    elseif factionType then
        return factionType
    else
        local gang = VICE.getGangName(user_id)
        if gang then
            return gang
        end
    end
    return "None"
end

function removeRadio(source)
    for a,b in pairs(radioChannels) do
        if next(radioChannels[a]['players']) then
            for k,v in pairs(radioChannels[a]['players']) do
                if k == source then
                    if a then
                        TriggerEvent("VICE:ChatClockOn", source, a, false)
                    end
                    TriggerClientEvent('VICE:radiosRemovePlayer', -1, radioChannels[a].channel, k)
                    radioChannels[a]['players'][source] = nil
                end
            end
        end
    end
end

RegisterServerEvent("VICE:clockedOnCreateRadio")
AddEventHandler("VICE:clockedOnCreateRadio", function(source)
    local source = source
    syncRadio(source)
end)

RegisterServerEvent("VICE:clockedOffRemoveRadio")
AddEventHandler("VICE:clockedOffRemoveRadio", function(source)
    local source = source
    syncRadio(source)
end)

RegisterServerEvent("VICE:AddRadio")
AddEventHandler("VICE:AddRadio", function(source)
    local source = source
    syncRadio(source)
end)

RegisterServerEvent("VICE:RemoveRadio")
AddEventHandler("VICE:RemoveRadio", function(source)
    local source = source
    removeRadio(source)
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    syncRadio(source)
end)

AddEventHandler('playerDropped', function(reason)
    local source = source
    removeRadio(source)
end)

RegisterCommand("reconnectradio", function(source, args, rawCommand) -- To Recoonect Source To Radio
    local source = source
    syncRadio(source)
end)

function syncRadio(source)
    removeRadio(source)
    TriggerClientEvent('VICE:radiosClearAll', source)
    Wait(500)
    createRadio(source)
end

RegisterServerEvent("VICE:radiosSetIsMuted")
AddEventHandler("VICE:radiosSetIsMuted", function(mutedState)
    local source = source
    local user_id = VICE.getUserId(source)
    local radioType = getRadioType(user_id)
    if radioType then
        for k,v in pairs(radioChannels[radioType]['players']) do
            if k == source then
                TriggerClientEvent('VICE:radiosSetPlayerIsMuted', -1, radioChannels[radioType].channel, k, mutedState)
            end
        end
    else
        local gang = VICE.getGangName(user_id)
        if gang then
            for k,v in pairs(radioChannels[gang]['players']) do
                if k == source then
                    TriggerClientEvent('VICE:radiosSetPlayerIsMuted', -1, radioChannels[gang].channel, k, mutedState)
                end
            end
        end
    end
end)


AddEventHandler("VICE:ChatClockOn", function(source, mode, state)
    local policechat = {
        name = "Police",
        displayName = "Police",
        isChannel = "Police",
        color = {0, 0, 255},
        isGlobal = false,
    }
    local nhschat = {
        name = "NHS",
        displayName = "NHS",
        isChannel = "NHS",
        color = {0, 0, 255},
        isGlobal = false,
    }
    local factionchat = {
        name = "Faction",
        displayName = "Faction",
        isChannel = "Faction",
        color = {0, 255, 0},
        isGlobal = false,
    }
    local lfbchat = {
        name = "LFB",
        displayName = "LFB",
        isChannel = "LFB",
        color = {255, 0, 0},
        isGlobal = false,
    }
    local hmpchat = {
        name = "HMP",
        displayName = "HMP",
        isChannel = "HMP",
        color = {0, 0, 255},
        isGlobal = false,
    }
    local gangchat = {
        name = "Gang",
        displayName = "Gang",
        isChannel = "Gang",
        color = {0, 255, 0},
        isGlobal = false,
    }
    if state then
        if mode == "Police" then
            TriggerClientEvent('chat:addMode', source, policechat)
        elseif mode == "NHS" then
            TriggerClientEvent('chat:addMode', source, nhschat)
        elseif mode == "HMP" then
            TriggerClientEvent('chat:addMode', source, hmpchat)
        elseif mode == "LFB" then
            TriggerClientEvent('chat:addMode', source, lfbchat)
        elseif mode == "Faction" then
            TriggerClientEvent('chat:addMode', source, factionchat)
        elseif mode == "Gang" then
            TriggerClientEvent('chat:addMode', source, gangchat)
        end
    else
        TriggerClientEvent('chat:removeMode', source, mode)
    end
end)
