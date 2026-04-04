local announceTables = {
    {permission = 'admin.managecommunitypot', info = {name = "Server Announcement", desc = "Announce something to the server", price = 0}, image = 'nui://vice/ui/imagesforannoucment/ancc.png'},
    {permission = 'police.announce', info = {name = "PD Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/I7c5LsN.png'},
    {permission = 'nhs.announce', info = {name = "NHS Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/SypLbMo.png'},
    {permission = 'lfb.announce', info = {name = "LFB Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/AFqPgYk.png'},
    {permission = 'hmp.announce', info = {name = "HMP Announcement", desc = "Announce something to the server", price = 10000}, image = 'https://i.imgur.com/rPF5FgQ.png'},
}

-- Cache for announcement images
local imageCache = {}

-- Preload images
Citizen.CreateThread(function()
    for _, v in pairs(announceTables) do
        if v.image then
            imageCache[v.info.name] = v.image
        end
    end
end)

RegisterServerEvent("VICE:getAnnounceMenu")
AddEventHandler("VICE:getAnnounceMenu", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local hasPermsFor = {}
    
    for k,v in pairs(announceTables) do
        if VICE.hasGroup(user_id, 'Founder') or VICE.hasGroup(user_id, 'Lead Developer') or VICE.hasGroup(user_id, 'Developer') or VICE.hasGroup(user_id, 'Community Manager') or VICE.hasGroup(user_id, 'Staff Manager') or VICE.hasGroup(user_id, 'Head Administrator') or VICE.hasGroup(user_id, 'Senior Administrator') or VICE.hasGroup(user_id, 'Administrator') or VICE.hasGroup(user_id, 'Senior Moderator') then
            table.insert(hasPermsFor, v.info)
        end
    end
    
    if #hasPermsFor > 0 then
        TriggerClientEvent("VICE:buildAnnounceMenu", source, hasPermsFor)
    end
end)

RegisterServerEvent("VICE:serviceAnnounce")
AddEventHandler("VICE:serviceAnnounce", function(announceType)
    local source = source
    local user_id = VICE.getUserId(source)
    
    for k,v in pairs(announceTables) do
        if v.info.name == announceType then
            if VICE.hasGroup(user_id, 'Founder') or VICE.hasGroup(user_id, 'Lead Developer') or VICE.hasGroup(user_id, 'Developer') or VICE.hasGroup(user_id, 'Community Manager') or VICE.hasGroup(user_id, 'Staff Manager') or VICE.hasGroup(user_id, 'Head Administrator') or VICE.hasGroup(user_id, 'Senior Administrator') or VICE.hasGroup(user_id, 'Administrator') or VICE.hasGroup(user_id, 'Senior Moderator') then
                if VICE.tryFullPayment(user_id, v.info.price) then
                    VICE.prompt(source, "Input text to announce", "", function(source, data)
                        if data and data ~= "" then
                            -- Send announcement immediately
                            if v.info.name == "Server Announcement" then
                                -- Add "Sinco Government: " prefix for server announcements
                                TriggerClientEvent('VICE:serviceAnnounceCl', -1, v.image, "Vice Government: " .. data)
                            else
                                TriggerClientEvent('VICE:serviceAnnounceCl', -1, v.image, data)
                            end
                            
                            if v.info.price > 0 then
                                VICE.notify(source, "~g~Purchased a "..v.info.name.." for £"..v.info.price..".")
                                VICE.notify(source, "~g~Content ~b~"..data)
                            else
                                VICE.notify(source, "~g~Sending a "..v.info.name.." with content ~b~"..data)
                                -- Log the announcement
                                VICE.sendDCLog('announce', "VICE Announcement Logs", 
                                    "```"..data.."```"..
                                    "\n> Player Name: **"..VICE.getPlayerName(user_id).."**"..
                                    "\n> Player PermID: **"..user_id.."**"..
                                    "\n> Player TempID: **"..source.."**"
                                )
                            end
                        else
                            VICE.notify(source, "~r~Announcement cannot be empty.")
                            -- Refund if payment was made
                            if v.info.price > 0 then
                                VICE.giveBank(user_id, v.info.price)
                            end
                        end
                    end)
                else
                    VICE.notify(source, "~r~You do not have enough money to do this.")
                end
            else
                VICE.ACBan(15, user_id, "VICE:serviceAnnounce")
            end
            break -- Exit the loop once we find the matching announcement type
        end
    end
end)