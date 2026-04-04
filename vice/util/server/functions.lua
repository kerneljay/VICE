-- [[ Notifys ]] -- 

function VICE.notify(source,msg)
    if type(msg) == "table" then
        msg = table.unpack(msg)
    end
    if source == 0 then
        print(msg)
    else
        TriggerClientEvent("VICE:Notify",source,msg)
    end
end

function VICE.notifyPicture(ay,az,l,ac,aA,aB,aC)
    TriggerClientEvent("VICE:notifyPicture",ay,az,l,ac,aA,aB,aC)
end

function VICE.notifyPicture2(a8, type, a9, aa, ab)
    TriggerClientEvent("VICE:notifyPicture2", a8, type, a9, aa, ab)
end

function VICE.notifyPicture5(headshot, iconType, title, usePicture, message)
    TriggerClientEvent("VICE:notifyPicture5", headshot, iconType, title, usePicture, message)
end

function VICE.notifyPicture(ay,az,l,ac,aA,aB,aC)
    TriggerClientEvent("VICE:notifyPicture",ay,az,l,ac,aA,aB,aC)
end

-- [[ Weapons ]] --

function VICE.giveWeapons(h, i,passkey)
    TriggerClientEvent("VICE:giveWeapons",h, i,passkey)
end

function VICE.calculateTimeRemaining(expireTime)
    if tonumber(expireTime) then
        local datetime = ''
        local expiry = os.date("%d/%m/%Y at %H:%M", tonumber(expireTime))
        local hoursLeft = ((tonumber(expireTime)-os.time()))/3600
        local minutesLeft = nil
        if hoursLeft < 1 then
            minutesLeft = hoursLeft * 60
            minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
            datetime = minutesLeft .. " mins" 
            return datetime
        else
            hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
            datetime = hoursLeft .. " hours" 
            return datetime
        end
        return datetime
    else
        return "Permanent Ban"
    end
end

function VICE.getGangName(user_id)
    return exports["vice"]:scalarSync("SELECT gangname FROM vice_user_gangs WHERE user_id = @user_id", {user_id = user_id}) or ""
end

function VICE.calculateTimeAgo(creationTime)
    if tonumber(creationTime) then
        local datetime = ''
        local secondsAgo = os.time() - tonumber(creationTime)
        local minutesAgo = secondsAgo / 60
        local hoursAgo = minutesAgo / 60
        local daysAgo = hoursAgo / 24
        if daysAgo >= 1 then
            daysAgo = math.floor(daysAgo)
            datetime = daysAgo .. (daysAgo == 1 and " day" or " days") .. " ago"
        elseif hoursAgo >= 1 then
            hoursAgo = math.floor(hoursAgo)
            datetime = hoursAgo .. (hoursAgo == 1 and " hour" or " hours") .. " ago"
        elseif minutesAgo >= 1 then
            minutesAgo = math.floor(minutesAgo)
            datetime = minutesAgo .. (minutesAgo == 1 and " minute" or " minutes") .. " ago"
        else
            secondsAgo = math.floor(secondsAgo)
            datetime = secondsAgo .. (secondsAgo == 1 and " second" or " seconds") .. " ago"
        end
        return datetime
    else
        return "Invalid timestamp"
    end
end

function VICE.GetPlayersInRoutingBucket(bucketid)
    local players = {}
    for k,v in pairs(GetPlayers()) do
        if GetPlayerRoutingBucket(v) == bucketid then
            table.insert(players,v)
        end
    end
    return players
end