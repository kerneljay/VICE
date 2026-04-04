local outfitCodes = {}

RegisterNetEvent("VICE:saveWardrobeOutfit")
AddEventHandler("VICE:saveWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        VICEclient.getCustomization(source,{},function(custom)
            sets[outfitName] = custom
            VICE.setUData(user_id,"VICE:home:wardrobe",json.encode(sets))
            VICE.notify(source, "~g~Saved outfit "..outfitName.." to wardrobe!")
            TriggerClientEvent("VICE:refreshOutfitMenu", source, sets)
        end)
    end)
end)

RegisterNetEvent("VICE:deleteWardrobeOutfit")
AddEventHandler("VICE:deleteWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        sets[outfitName] = nil
        VICE.setUData(user_id,"VICE:home:wardrobe",json.encode(sets))
        VICE.notify(source, "~g~Removed outfit "..outfitName.." from wardrobe!")
        TriggerClientEvent("VICE:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("VICE:equipWardrobeOutfit")
AddEventHandler("VICE:equipWardrobeOutfit", function(outfitName)
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:home:wardrobe", function(data)
        local sets = json.decode(data)
        VICEclient.setCustomization(source, {sets[outfitName]})
        VICEclient.getHairAndTats(source, {})
    end)
end)

RegisterNetEvent("VICE:initWardrobe")
AddEventHandler("VICE:initWardrobe", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICE.getUData(user_id, "VICE:home:wardrobe", function(data)
        local sets = json.decode(data)
        if sets == nil then
            sets = {}
        end
        TriggerClientEvent("VICE:refreshOutfitMenu", source, sets)
    end)
end)

RegisterNetEvent("VICE:getCurrentOutfitCode")
AddEventHandler("VICE:getCurrentOutfitCode", function()
    local source = source
    local user_id = VICE.getUserId(source)
    VICEclient.getCustomization(source,{},function(custom)
        VICEclient.generateUUID(source, {"outfitcode", 5, "alphanumeric"}, function(uuid)
            local uuid = string.upper(uuid)
            outfitCodes[uuid] = custom
            VICEclient.CopyToClipBoard(source, {uuid})
           -- VICE.notify(source, "~g~Outfit code copied to clipboard.")
            TriggerClientEvent("VICE:showNotification",
                {
                    text = "Outfit code Copied To Clipboard.",
                    height = "200px",
                    width = "auto",
                    colour = "#FFF",
                    background = "#32CD32",
                    pos = "bottom-right",
                    icon = "good"
                }, 5000
            )
            VICE.notify(source, "The code ~y~"..uuid.."~w~ will persist until restart.")
        end)
    end)
end)

RegisterNetEvent("VICE:applyOutfitCode")
AddEventHandler("VICE:applyOutfitCode", function(outfitCode)
    local source = source
    local user_id = VICE.getUserId(source)
    if outfitCodes[outfitCode] then
        VICEclient.setCustomization(source, {outfitCodes[outfitCode]})
        VICE.notify(source, "~g~Outfit code applied.")
        VICEclient.getHairAndTats(source, {})
    else
        VICE.notify(source, "Outfit code not found.")
    end
end)

RegisterCommand('wardrobe', function(source)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id == 1 then
        TriggerClientEvent("VICE:openOutfitMenu", source)
    end
end)

RegisterCommand('copyfit', function(source, args)
    local source = source
    local user_id = VICE.getUserId(source)
    local permid = tonumber(args[1])
    if VICE.hasGroup(user_id, 'Founder') or VICE.hasGroup(user_id, 'Lead Developer') then
        VICEclient.getCustomization(VICE.getUserSource(permid),{},function(custom)
            VICEclient.setCustomization(source, {custom})
        end)
    end
end)

