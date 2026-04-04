local killdata = {}
local combatRollStates = {}
local f = module("cfg/weapons")
f = f.weapons
local illegalWeapons = f.nativeWeaponModelsToNames

local function getWeaponName(weapon)
    for k,v in pairs(f) do
        if weapon == 'Mosin Nagant' then
            return 'Mosin'
        elseif weapon == 'Nerf Mosin' then
            return 'Mosin'
        elseif weapon == 'CB Mosin' then
            return 'Mosin'
        elseif weapon == 'Black Ice Mosin' then
            return 'Mosin'
        elseif weapon == 'Manor Mosin' then
            return 'Mosin'
        elseif weapon == 'Spongebob Mosin' then
            return 'Mosin'
        elseif weapon == 'Fists' then
            return 'Fist'
        elseif weapon == 'Fire' then
            return 'Fire'
        elseif weapon == 'Explosion' then
            return 'Explode'
        elseif weapon == 'Suicide' then
            return 'Suicide'
        elseif weapon == 'Knife' then
            return 'Knife'
        elseif weapon == 'Pistol' then
            return 'Handgun'
        elseif weapon == 'Shotgun' then
            return 'Shotgun'
        elseif weapon == 'Sniper' then
            return 'Sniper'
        end
        if v.name == weapon then
            return v.class
        end
    end
    return "Unknown"
end

local WeaponCFG = module("cfg/weapons")
WeaponNames = {}

for hash,table in pairs(WeaponCFG.weapons) do
    WeaponNames[hash] = table.name
end

function GetWeaponClass(WeaponHash)
    for _,table in pairs(WeaponCFG.weapons) do
        if table.name == WeaponHash then
            return table.class
        elseif weapon == 'Fists' then
            return 'Fist'
        elseif weapon == 'Fire' then
            return 'Fire'
        elseif weapon == 'Explosion' then
            return 'Explode'
        end
    end
    return "Unknown"
end

local function getweaponnames(weaponHash)
    for k,v in pairs(f) do
        if v.hash == weaponHash then
            return v.name
        end
    end
    return "Unknown"
end

RegisterNetEvent('VICE:KillProcessed')
AddEventHandler('VICE:KillProcessed', function(killid,videodata)
    local source = source
    local user_id = VICE.getUserId(source)
    if not videodata then
     print('videodata is nill')
      -- print("Fatal Error videodata is nil? further info\nkillid: "..tostring(killid).."\nuser_id: "..tostring(user_id).."\n"..(killdata[killid] and killdata[killid].killerid or "No killerid found").."\n"..(killdata[killid] and killdata[killid].victimid or "No victimid found"))
        return
    end
    if killdata[killid] and killdata[killid].killerid == user_id then
        VICE.sendDCLog('kills',"VICE Kill Video","> **Killer:** "..VICE.getPlayerName(killdata[killid].killerid).." ["..killdata[killid].killerid.."]\n> **Victim:** "..VICE.getPlayerName(killdata[killid].victimid).." ["..killdata[killid].victimid.."]\n> **Video:** https://discord.com/channels/1257084836800233517/"..videodata.channel_id.."/"..videodata.id)
    end
end)

RegisterNetEvent('VICE:onPlayerKilled')
AddEventHandler('VICE:onPlayerKilled', function(killtype, killer, weaponhash, suicide, distance)
    local source = source
    local killergroup = 'none'
    local killedgroup = 'none'
    local headShot = false
    local user_id = VICE.getUserId(source)
    local killerID = VICE.getUserId(killer)
    weaponhash = getWeaponName(weaponhash)
    if distance then
        distance = math.floor(distance)
    end
    if killtype == 'killed' then
        if VICE.hasPermission(user_id, 'police.armoury') then
            killedgroup = 'police'
        elseif VICE.hasPermission(user_id, 'nhs.menu') then
            killedgroup = 'nhs'
        end
        if VICE.hasPermission(killerID, 'police.armoury') then
            killergroup = 'police'
        elseif VICE.hasPermission(killerID, 'nhs.menu') then
            killergroup = 'nhs'
        end
        if killer then
            local killWhileRolling = combatRollStates[killerID] == true
            if not VICEclient.InMainEvent(user_id) then
                local killid = #killdata +1
                killdata[killid] = {killerid = killerID,victimid = user_id}
                if killerID ~= user_id then
                    TriggerClientEvent("VICE:takeClientVideoAndUploadKills",killer,VICE.getWebhook('media-cache'),killid)
                end
                headShot = VICE.GetLatestHeadShot(killerID) == user_id
                local bucket = GetPlayerRoutingBucket(source)
                for k,v in pairs(GetPlayers()) do
                    if GetPlayerRoutingBucket(v) == bucket then
                        TriggerClientEvent('VICE:newKillFeed', v, VICE.getPlayerName(killerID), VICE.getPlayerName(user_id), weaponhash, suicide, distance, killedgroup, killergroup, headShot, killWhileRolling)
                    end
                end
              --  VICE.sendDCLog('killfeed-logs', "VICE Kill Logs", "> Killer Name: **"..VICE.getPlayerName(killerID).."**\n> Killer ID: **"..VICE.getUserId(killer).."**\n> Weapon: **"..getweaponnames(weaponhash).."**\n> Victim Name: **"..VICE.getPlayerName(source).."**\n> Victim ID: **"..VICE.getUserId(source).."**\n> Distance: **"..distance.."m**")
                VICE.AddStat(killerID,"kills",1)
            else
                VICE.ManagePlayerDeath(source,killer,getweaponnames(weaponhash),distance)
            end
            return
        end
    end
    if suicide then
        local bucket = GetPlayerRoutingBucket(source)
        for k,v in pairs(GetPlayers()) do
            if GetPlayerRoutingBucket(v) == bucket then
                TriggerClientEvent('VICE:newKillFeed', v, VICE.getPlayerName(user_id), VICE.getPlayerName(user_id), 'suicide', suicide, distance, killedgroup, killergroup, false, false)
            end
        end
    end
    TriggerEvent("VICE:playerKilled", source, killerID)
    TriggerClientEvent('VICE:deathSound', -1, GetEntityCoords(GetPlayerPed(source)))
    VICE.AddStat(user_id,"deaths",1)
end)

RegisterNetEvent("VICE:updateCombatRollState")
AddEventHandler("VICE:updateCombatRollState", function(isRolling)
    local src = source
    local user_id = VICE.getUserId(src)
    if user_id then
        combatRollStates[user_id] = isRolling == true
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local user_id = VICE.getUserId(src)
    if user_id then
        combatRollStates[user_id] = nil
    end
end)

AddEventHandler('weaponDamageEvent', function(sender, ev)
    local user_id = VICE.getUserId(sender)
    local name = VICE.getPlayerName(user_id)
    if user_id then
        if ev.weaponDamage ~= 0 then
            if ev.weaponType == 911657153 and not VICE.hasPermission(user_id, 'police.armoury') or ev.weaponType == 3452007600 then
                VICE.ACBan(5,user_id,"Using a weapon that is not allowed")
            end
            VICE.sendDCLog('damage-logs', "VICE Damage Logs", "> Player Name: **"..name.."**\n> Player Temp ID: **"..sender.."**\n> Player Perm ID: **"..user_id.."**\n> Damage: **"..ev.weaponDamage.."**\n> Weapon : **"..getweaponnames(ev.weaponType).."**")
        end
    else
        print("user "..tostring(sender)" id is nill")
    end
end)
