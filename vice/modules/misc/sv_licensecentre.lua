
local cfg = module("cfg/cfg_licensecentre")

RegisterServerEvent("LicenseCentre:BuyGroup")
AddEventHandler('LicenseCentre:BuyGroup', function(job, name)
    local source = source
    local user_id = VICE.getUserId(source)
    local coords = cfg.location
    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    if not VICE.hasGroup(user_id, "Rebel") and job == "AdvancedRebel" then
        VICE.notify(source, "You need to have Rebel License.")
        return
    end
    if #(playerCoords - coords) <= 20.0 then
        if VICE.hasGroup(user_id, job) then 
            VICE.notify(source, "~o~You have already purchased this license!")
            TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
        else
            for k,v in pairs(cfg.licenses) do
                if v.group == job then
                    if VICE.tryFullPayment(user_id, v.price) then
                        VICE.addUserGroup(user_id,job)
                        VICE.notify(source, "~g~Purchased " .. name .. " for ".. '£' ..tostring(getMoneyStringFormatted(v.price)) .. " ")
                        VICE.sendDCLog('purchases',"VICE License Centre Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**\n> Purchased: **"..name.."**")
                        TriggerClientEvent("vice:PlaySound", source, "playMoney")
                        TriggerClientEvent("VICE:gotOwnedLicenses", source, getLicenses(user_id))
                        TriggerClientEvent("VICE:refreshGunStorePermissions", source)
                        TriggerEvent("VICE:tutorialStageServerUpdate", source, "license")
                        TriggerClientEvent("VICE:tutorialLicenseBought", source)
                    else 
                        VICE.notify(source, "You do not have enough money to purchase this license!")
                        TriggerClientEvent("vice:PlaySound", source, "playCasinoLose")
                    end
                end
            end
        end
    else 
        VICE.ACBan(15,user_id,"License Centre Distance: "..(#(playerCoords - coords)))
    end
end)

function getLicenses(user_id)
    local licenses = {}
    if user_id then
        for k, v in pairs(cfg.licenses) do
            if VICE.hasGroup(user_id, v.group) then
                table.insert(licenses, v.name)
            end
        end
        return licenses
    end
end

RegisterNetEvent("VICE:GetLicenses")
AddEventHandler("VICE:GetLicenses", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        TriggerClientEvent("VICE:ReceivedLicenses", source, getLicenses(user_id))
    end
end)

RegisterNetEvent("VICE:getOwnedLicenses")
AddEventHandler("VICE:getOwnedLicenses", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        TriggerClientEvent("VICE:gotOwnedLicenses", source, getLicenses(user_id))
    end
end)
