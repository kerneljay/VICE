local verifyCodes = {}
local alreadyVerified = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        for k, v in pairs(verifyCodes) do
            if verifyCodes[k] then
                verifyCodes[k] = nil
            end
        end
    end
end)

RegisterServerEvent("VICE:AllowDiscordVerify")
AddEventHandler("VICE:AllowDiscordVerify", function(player_temp)
    local source = source
    local user_id = VICE.getUserId(source)
    local player_perm = VICE.getUserId(player_temp)
    if VICE.hasPermission(user_id,"admin.tp2waypoint") then
        if player_perm == user_id then
            VICE.notify(source, '~r~You cannot re-verify yourself.')
            return
        end
        if not alreadyVerified[player_perm] then
            VICE.notify(source, '~r~User already can verify their discord.')
            return
        end
        alreadyVerified[player_perm] = false
        VICE.notify(source, '~g~User can now re-verify their discord account.')
        VICE.notify(player_temp, '~b~You can now re-verify your discord account.')
        VICE.sendDCLog('discord-reverify',"VICE Change Linked Discord Logs", "> Admin Name: **"..VICE.getPlayerName(user_id).."**\n> Admin TempID: **"..source.."**\n> Admin PermID: **"..user_id.."**\n> Players Name: **"..VICE.getPlayerName(player_perm).."**\n> Players TempID: **"..player_temp.."**\n> Players PermID: **"..player_perm.."**")
    else
        VICE.ACBan(15,user_id,"AllowDiscordVerify")
    end
end)


RegisterServerEvent('VICE:changeLinkedDiscord', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if alreadyVerified[user_id] then
        VICE.notify(source, '~r~You cannot verify another discord account, wait till next restart.')
        return
    end
    VICE.prompt(source, "Enter Discord Id:", "", function(source, discordid)
        if discordid and discordid ~= "" and discordid:match("^%d+$") then
            TriggerClientEvent('VICE:gotDiscord', source)
            VICEclient.generateUUID(source, {"linkcode", 5, "alphanumeric"}, function(code)
                verifyCodes[user_id] = { code = code, discordid = discordid, timestamp = os.time() }
                exports['VICEStaffBot']:dmUser(source, { discordid, code, user_id }, function() end)
            end)
        else
            VICE.notify(source, '~r~Invalid Discord ID provided.')
            Wait(100)
            VICE.notify(source, '~y~Your Discord ID is a number such as  which identifies your account.')
            Wait(100)
            VICE.notify(source, '~y~Right click your Discord account and press Copy User ID. You may need to enable Developer Mode.')
            Wait(100)
            VICE.notify(source, '~y~Developer mode can be enabled under Discord Settings -> Advanced -> Developer Mode.')
        end
    end)
end)

RegisterServerEvent('VICE:enterDiscordCode', function()
    local source = source
    local user_id = VICE.getUserId(source)
    local currentTimestamp = os.time()
    local verification = verifyCodes[user_id]
    if alreadyVerified[user_id] then
        VICE.notify(source, '~r~You have already verified your discord account.')
        return
    end
    if verification and currentTimestamp - verification.timestamp <= 300 then
        VICE.prompt(source, "Enter Code:", "", function(source, code)
            if code and code ~= "" then
                if verification.code == code then
                    exports['vice']:execute("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", { user_id = user_id }, function(result)
                        local previousDiscordId = result[1].discord_id or "Unknown"
                        exports['vice']:execute("UPDATE `vice_verification` SET discord_id = @discord_id WHERE user_id = @user_id", { user_id = user_id, discord_id = verification.discordid }, function() end)
                        VICE.notify(source, '~g~Successfully re-verified discord.')
                        VICE.sendDCLog('discord-reverify',"VICE Change Linked Discord Logs", "\n> Players Name: **"..VICE.getPlayerName(user_id).."**\n> Players TempID: **"..source.."**\n> Players PermID: **"..user_id.."**\n> Previous Discord ID: **"..previousDiscordId.."**\n> New Discord ID: **"..verification.discordid.."**\n> Code: **"..verification.code.."**")
                        alreadyVerified[user_id] = true
                    end)
                else
                    VICE.notify(source, '~r~Invalid code provided.')
                end
            else
                VICE.notify(source, '~r~You need to enter a code!')
            end
        end)
    else
        VICE.notify(source, '~r~Your code has expired.')
    end
end)