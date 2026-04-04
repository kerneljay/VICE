local gangWithdraw = {}
local gangDeposit = {}
local gangTable = {}
local playerinvites = {}
local fundscooldown = {}
local cooldown = 5
MySQL.createCommand("vice_edituser", "UPDATE vice_user_gangs SET gangname = @gangname WHERE user_id = @user_id")
MySQL.createCommand("vice_adduser", "INSERT IGNORE INTO vice_user_gangs (user_id,gangname) VALUES (@user_id,@gangname)")
function addGangLog(playername,userid,action,actionvalue)
    local gangname = VICE.getGangName(userid)
    if gangname and gangname ~= "" then
        exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
            if #ganginfo > 0 then
                local ganglogs = {}
                if ganginfo[1].logs == "NOTHING" then
                    ganglogs = {}
                else
                    ganglogs = json.decode(ganginfo[1].logs)
                    if ganglogs == nil then
                        ganglogs = {}
                    end
                end
                if ganginfo[1].webhook then
                    VICE.sendDCLog(ganginfo[1].webhook, "(".. gangname..") Gang Logs", "**Name:** " ..playername.. "**\n**User ID:** " ..userid.. "\n**Action:** " ..actionvalue .. "**")
                else
                    VICE.sendDCLog("gang-info", "(".. gangname..") Gang Logs", "**Name:** " ..playername.. "**\n**User ID:** " ..userid.. "\n**Action:** " .. action.. " ("..actionvalue.. ")**")
                end
                table.insert(ganglogs,1,{playername,userid,os.date("%d/%m/%Y at %X"),action,actionvalue})
                exports["vice"]:execute("UPDATE vice_gangs SET logs = @logs WHERE gangname = @gangname", {logs = json.encode(ganglogs), gangname = gangname})
                TriggerClientEvent("VICE:ForceRefreshData",VICE.getUserSource(userid))
            end
        end)
    end
end
RegisterServerEvent('VICE:CreateGang', function(gangName)
    local source = source
    local user_id = VICE.getUserId(source)
    local currenttime = os.time()
    
    if VICE.hasGroup(user_id,"Gang") then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            local hasgang = VICE.getGangName(user_id)
            if hasgang == nil or hasgang == "" then
                exports['vice']:execute("SELECT * FROM vice_user_gangs WHERE gangname = @gang", {gang = gangName}, function(gangData)
                    if #gangData <= 0 then
                        local gangTable = {[tostring(user_id)] = {["rank"] = 4,["gangPermission"] = 4,["color"] = "White"}}
                        gangTables = json.encode(gangTable)
                        VICE.notify(source, "~g~Gang created.")
                        MySQL.execute("vice_edituser", {user_id = user_id, gangname = gangName})
                        exports['vice']:execute("INSERT INTO vice_gangs (gangname,gangmembers,funds,logs) VALUES(@gangname,@gangmembers,@funds,@logs)", {gangname=gangName,gangmembers=gangTables,funds=0,logs="NOTHING"}, function() end)
                        TriggerClientEvent("VICE:gangNameNotTaken",source)
                        TriggerClientEvent("VICE:ForceRefreshData",source)
                    else
                        VICE.notify(source, "~r~Gang already exists.")
                    end
                end)
            else
                VICE.notify(source, "~r~You already have a gang, If not contact a developer.")
            end
        else
            VICE.notify(source, "~r~You are being rate limited, please wait")
        end
    else
        VICE.notify(source, "~r~A gang license is required to create a gang.")
    end
    syncRadio(source)
end)

RegisterServerEvent("VICE:GetGangData", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local gangName = VICE.getGangName(user_id)
    if gangName and gangName ~= "" then
        local gangmembers = {}
        local gangData = {}
        local ganglogs = {}
        local memberids = {}
        local gangpermission = {}  -- Initialize gangpermission as a table
        exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(gangInfo)
            if #gangInfo == 0 then return end -- Ensure gangInfo is not empty before accessing its elements
            local gangInfo = gangInfo[1]
            local gangMembers = json.decode(gangInfo.gangmembers)
            gangData["money"] = math.floor(gangInfo.funds)
            gangData["id"] = gangName
            gangpermission = tonumber(gangMembers[tostring(user_id)].gangPermission) or 0
            ganglogs = json.decode(gangInfo.logs)
            ganglock = tobool(gangInfo.lockedfunds)
            for member_id, member_data in pairs(gangMembers) do
                memberids[#memberids + 1] = tostring(member_id)
            end
            local placeholders = string.rep('?,', #memberids):sub(1, -2)
            local playerData = exports['vice']:executeSync('SELECT * FROM vice_users WHERE id IN (' .. placeholders .. ')', memberids)
            local userData = exports['vice']:executeSync('SELECT * FROM vice_user_data WHERE user_id IN (' .. placeholders .. ')', memberids)
            for _, playerRow in ipairs(playerData) do
                local member_id = tonumber(playerRow.id)
                local member_gangpermission = tonumber(gangMembers[tostring(member_id)].gangPermission) or 0  
                local online
                if playerRow.banned then
                    online = '~r~Banned'
                elseif VICE.getUserSource(member_id) then
                    online = '~g~Online'
                elseif playerRow.last_login then
                    online = '~y~Offline'
                else
                    online = '~r~Never joined'
                end
                local playtime = 0

                for _, userData in ipairs(userData) do
                    if userData.user_id == member_id and userData.dkey == 'VICE:datatable' then
                        local data = json.decode(userData.dvalue)

                        playtime = math.ceil((data.PlayerTime or 0) / 60)
                        if playtime < 1 then
                            playtime = 0
                        end
                        break
                    end
                end
                table.insert(gangmembers, { playerRow.username, member_id, member_gangpermission, online, playtime })
            end
            for _, member_id in ipairs(memberids) do
                local tempid = VICE.getUserSource(tonumber(member_id))
                if tempid then
                    TriggerClientEvent('VICE:GotGangData', tempid, gangData, gangmembers, gangpermission, ganglogs, ganglock, false)
                end
            end
        end)
    end
end)

RegisterServerEvent("VICE:addUserToGang",function(gangName)
    local source = source
    local user_id = VICE.getUserId(source)
    if table.includes(playerinvites[source],gangName) then
        exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname",{gangname = gangName}, function(ganginfo)
            if json.encode(ganginfo) == "[]" and ganginfo == nil and json.encode(ganginfo) == nil then
                VICE.notify(source, "~b~Gang no longer exists.")
                return
            end
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(ganginfo) do
                gangmembers[tostring(user_id)] = {["rank"] = 1,["gangPermission"] = 1,["color"] = "White"}
                exports["vice"]:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname",{gangmembers = json.encode(gangmembers),gangname = gangName})
                MySQL.execute("vice_edituser", {user_id = user_id, gangname = gangName})
                TriggerClientEvent("VICE:ForceRefreshData",source)
                syncRadio(source)
            end
        end)
    else
        VICE.notify(source, "~r~You have not been invited to this gang.")
    end
end)
local colourwait = false
RegisterServerEvent("VICE:setPersonalGangBlipColour")
AddEventHandler("VICE:setPersonalGangBlipColour", function(color)
    local source = source
    local user_id = VICE.getUserId(source)
    local gangName = VICE.getGangName(user_id)
    if gangName and gangName ~= "" then
        exports['vice']:execute('SELECT * FROM vice_gangs WHERE gangname = @gangname', {gangname = gangName}, function(gangs)
            if #gangs > 0 then
                local gangmembers = json.decode(gangs[1].gangmembers)
                gangmembers[tostring(user_id)] = {["rank"] = gangmembers[tostring(user_id)].rank, ["gangPermission"] = gangmembers[tostring(user_id)].gangPermission,["color"] = color}
                exports['vice']:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangName})
                TriggerClientEvent("VICE:setGangMemberColour",-1,user_id,color)
            end
        end)
    end
end)

RegisterServerEvent("VICE:depositGangBalance",function(gangname, amount)
    local source = source
    local user_id = VICE.getUserId(source)
    exports['vice']:execute('SELECT * FROM vice_gangs WHERE gangname = @gangname', {gangname = gangname}, function(gotGangs)
        for K,V in pairs(gotGangs) do
            local array = json.decode(V.gangmembers)
            for I,L in pairs(array) do
                if tostring(user_id) == I then
                    local funds = V.funds
                    local gangname = V.gangname
                    if tonumber(amount) < 0 then
                        VICE.notify(source, "~r~Invalid Amount")
                        return
                    end
                    if tonumber(VICE.getBankMoney(user_id)) < tonumber(amount) then
                        VICE.notify(source, "~r~Not enough Money.")
                    else
                        VICE.setBankMoney(user_id, (VICE.getBankMoney(user_id))-tonumber(amount))
                        VICE.notify(source, "~g~Deposited £"..getMoneyStringFormatted(amount))
                        addGangLog(VICE.getPlayerName(user_id),user_id,"Deposited","£"..getMoneyStringFormatted(amount))
                        exports['vice']:execute("UPDATE vice_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tonumber(amount)+tonumber(funds), gangname = gangname})
                    end
                end
            end
        end
    end)
end)
RegisterServerEvent("VICE:depositAllGangBalance", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local gangName = exports['vice']:executeSync("SELECT * FROM vice_user_gangs WHERE user_id = @user_id", {user_id = user_id})[1].gangname
    local currenttime = os.time()

    if gangName and gangName ~= "" then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            local bank = VICE.getBankMoney(user_id)
            exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A, B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            local gangfunds = ganginfo[1].funds
                            if tonumber(bank) < 0 then
                                VICE.notify(source, "~r~Invalid Amount")
                                return
                            end
                            VICE.setBankMoney(user_id, 0)
                            VICE.notify(source, "~g~Deposited £" .. getMoneyStringFormatted(bank))
                            VICE.notify(source, "~g~£" .. getMoneyStringFormatted(tonumber(bank) * 0.02) .. " tax paid.")
                            addGangLog(VICE.getPlayerName(user_id), user_id, "Deposited", "£" .. getMoneyStringFormatted(bank))
                            local newbal = tonumber(bank) + tonumber(gangfunds) - tonumber(bank) * 0.02
                            exports["vice"]:execute("UPDATE vice_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tostring(newbal), gangname = gangName})
                        end
                    end
                end
            end)
        else
            VICE.notify(source, "~r~You are being rate limited, please wait")
        end
    end
end)

local fundscooldown = {}
local gangFundsLock = {}

RegisterServerEvent("VICE:withdrawAllGangBalance", function()
    local source = source
    local user_id = VICE.getUserId(source)
    local gangName = exports['vice']:executeSync("SELECT * FROM vice_user_gangs WHERE user_id = @user_id", {user_id = user_id})[1].gangname
    local currenttime = os.time()

    if gangName and gangName ~= "" then
        if not fundscooldown[source] or (currenttime - fundscooldown[source]) >= cooldown then
            fundscooldown[source] = currenttime
            
            -- Ensure only one person can withdraw at a time
            if gangFundsLock[gangName] then
                VICE.notify(source, "~r~Another withdrawal is already in progress. Please wait.")
                return
            end

            gangFundsLock[gangName] = true

            exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A, B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            -- Check if user is leader (rank 4)
                            if B.rank < 3 then
                                VICE.notify(source, "~r~Only senior members or higher can withdraw funds.")
                                gangFundsLock[gangName] = nil
                                return
                            end
                            
                            local gangfunds = ganginfo[1].funds
                            if tonumber(gangfunds) < 0 then
                                VICE.notify(source, "~r~Invalid Amount")
                                gangFundsLock[gangName] = nil
                                return
                            end
                            VICE.setBankMoney(user_id, (VICE.getBankMoney(user_id)) + tonumber(gangfunds))
                            VICE.notify(source, "~g~Withdrew £" .. getMoneyStringFormatted(gangfunds))
                            addGangLog(VICE.getPlayerName(user_id), user_id, "Withdrew", "£" .. getMoneyStringFormatted(gangfunds))
                            exports["vice"]:execute("UPDATE vice_gangs SET funds = @funds WHERE gangname = @gangname", {funds = 0, gangname = gangName})
                        end
                    end
                end
                gangFundsLock[gangName] = nil
            end)
        else
            VICE.notify(source, "~r~You are being rate limited, please wait")
        end
    end
end)

RegisterServerEvent("VICE:withdrawGangBalance",function(amount)
    local source = source
    local user_id = VICE.getUserId(source)
    if not amount or not tonumber(amount) then
        VICE.notify(source, "~r~Invalid Amount")
        return
    end
    local gangName = VICE.getGangName(user_id)
    if gangName and gangName ~= "" then
        if not gangWithdraw[source] then
            gangWithdraw[source] = true
            exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
                if #ganginfo > 0 then
                    local gangmembers = json.decode(ganginfo[1].gangmembers)
                    for A,B in pairs(gangmembers) do
                        if tostring(user_id) == A then
                            -- Check if user is leader (rank 4)
                            if B.rank < 3 then
                                VICE.notify(source, "~r~Only senior members or higher can withdraw funds.")
                                gangWithdraw[source] = false
                                return
                            end
                            
                            local gangfunds = ganginfo[1].funds
                            if tonumber(amount) < 0 then
                                VICE.notify(source, "~r~Invalid Amount")
                                gangWithdraw[source] = false
                                return
                            end
                            if tonumber(gangfunds) < tonumber(amount) then
                                VICE.notify(source, "~r~Not enough Money.")
                            else
                                VICE.setBankMoney(user_id, (VICE.getBankMoney(user_id))+tonumber(amount))
                                VICE.notify(source, "~g~Withdrew £"..getMoneyStringFormatted(amount))
                                addGangLog(VICE.getPlayerName(user_id),user_id,"Withdrew","£"..getMoneyStringFormatted(amount))
                                exports["vice"]:execute("UPDATE vice_gangs SET funds = @funds WHERE gangname = @gangname", {funds = tonumber(gangfunds)-tonumber(amount), gangname = gangName})
                            end
                        end
                    end
                    gangWithdraw[source] = false
                end
            end)
        end
    end
end)

RegisterServerEvent("VICE:PromoteUser",function(gangname,memberid)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            if not gangmembers[tostring(user_id)] then
                VICE.notify(source, "~r~You are not in this gang.")
                return
            end
            -- Allow both leader (4) and senior (3) to promote
            if gangmembers[tostring(user_id)].rank < 3 then
                VICE.notify(source, "~r~Only senior members or higher can promote members.")
                return
            end
            if not gangmembers[tostring(memberid)] then
                VICE.notify(source, "~r~Member not found in gang.")
                return
            end
            local targetRank = gangmembers[tostring(memberid)].rank
            local targetPermission = gangmembers[tostring(memberid)].gangPermission
            if tonumber(memberid) == tonumber(user_id) then
                VICE.notify(source, "~r~You cannot promote yourself.")
                return
            end
            if targetRank >= 4 then
                VICE.notify(source, "~r~Member is already at maximum rank.")
                return
            end
            gangmembers[tostring(memberid)].rank = targetRank + 1
            gangmembers[tostring(memberid)].gangPermission = targetPermission + 1
            VICE.notify(source, "~g~Successfully promoted member.")
            addGangLog(VICE.getPlayerName(user_id), user_id, "Promoted", "ID: "..memberid)
            exports["vice"]:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
        end
    end)
end)

RegisterServerEvent("VICE:DemoteUser", function(gangname,member)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname},function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            if not gangmembers[tostring(user_id)] then
                VICE.notify(source, "~r~You are not in this gang.")
                return
            end
            -- Allow both leader (4) and senior (3) to demote
            if gangmembers[tostring(user_id)].rank < 3 then
                VICE.notify(source, "~r~Only senior members or higher can demote members.")
                return
            end
            if not gangmembers[tostring(member)] then
                VICE.notify(source, "~r~Member not found in gang.")
                return
            end
            local targetRank = gangmembers[tostring(member)].rank
            local targetPermission = gangmembers[tostring(member)].gangPermission
            if tonumber(member) == tonumber(user_id) then
                VICE.notify(source, "~r~You cannot demote yourself.")
                return
            end
            if targetRank <= 1 then
                VICE.notify(source, "~r~Member is already at minimum rank.")
                return
            end
            gangmembers[tostring(member)].rank = targetRank - 1
            gangmembers[tostring(member)].gangPermission = targetPermission - 1
            VICE.notify(source, "~g~Successfully demoted member.")
            addGangLog(VICE.getPlayerName(user_id), user_id, "Demoted", "ID: "..member)
            exports["vice"]:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
        end
    end)
end)

RegisterServerEvent("VICE:KickUser",function(gangname,member)
    local source = source
    local user_id = VICE.getUserId(source)
    local membersource = VICE.getUserSource(member)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    local memberrank = gangmembers[tostring(member)].rank
                    local leaderrank = gangmembers[tostring(user_id)].rank
                    if B.rank >= 3 then
                        if tonumber(member) == tonumber(user_id) then
                            VICE.notify(source, "~r~You cannot kick yourself.")
                            return
                        end
                        if tonumber(memberrank) >= leaderrank then
                            VICE.notify(source, "~r~You do not have permission to kick this member from this gang")
                            return
                        end
                        gangmembers[tostring(member)] = nil
                        addGangLog(VICE.getPlayerName(user_id),user_id,"Kicked","ID: "..member)
                        exports["vice"]:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
                        MySQL.execute("vice_edituser", {user_id = member, gangname = nil})
                        if membersource then
                            VICE.notify(membersource, "~r~You have been kicked from the gang.")
                            syncRadio(membersource)
                            TriggerClientEvent("VICE:disbandedGang",membersource)
                        end
                    else
                        VICE.notify(source, "~r~You do not have permission to kick this member from this gang")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:LeaveGang", function(gangname)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        VICE.notify(source, "~r~You cannot leave the gang as you are the leader.")
                        return
                    end
                    gangmembers[tostring(user_id)] = nil
                    exports["vice"]:execute("UPDATE vice_gangs SET gangmembers = @gangmembers WHERE gangname = @gangname", {gangmembers = json.encode(gangmembers), gangname = gangname})
                    MySQL.execute("vice_edituser", {user_id = user_id, gangname = nil})
                    if VICE.getUserSource(user_id) then
                        VICE.notify(source, "~r~You have left the gang.")
                        syncRadio(source)
                        TriggerClientEvent("VICE:disbandedGang",source)
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:InviteUser",function(gangname,playerid)
    local source = source
    local user_id = VICE.getUserId(source)
    local playersource = VICE.getUserSource(tonumber(playerid))
    if source ~= playersource then
        if playersource == nil then
            VICE.notify(source, "~r~Player is not online.")
            return
        else
            table.insert(playerinvites[playersource],gangname)
            addGangLog(VICE.getPlayerName(user_id),user_id,"Invited","ID: "..playerid)
            TriggerClientEvent("VICE:InviteReceived",playersource,"~g~Gang invite received from: " ..VICE.getPlayerName(user_id),gangname)
            VICE.notify(source, "~g~Successfully invited " ..VICE.getPlayerName(playerid).. " to the gang.")
        end
    else
        VICE.notify(source, "~r~You cannot invite yourself.")
    end
end)

RegisterServerEvent("VICE:DeleteGang",function(gangname)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        exports["vice"]:execute("DELETE FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname})
                        for A,B in pairs(gangmembers) do
                            MySQL.execute("vice_edituser", {user_id = A, gangname = nil})
                            if VICE.getUserSource(tonumber(A)) then
                                syncRadio(VICE.getUserSource(tonumber(A)))
                                TriggerClientEvent("VICE:disbandedGang",VICE.getUserSource(tonumber(A)))
                            else
                                print("User is not online, unable to disbanded gang for them.")
                            end
                        end
                        
                        VICE.notify(source, "~r~You have disbanded the gang.")
                    else
                        VICE.notify(source, "~r~You do not have permission to disband this gang.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:RenameGang", function(gangname,newname)
    local source = source
    local user_id = VICE.getUserId(source)
    local gangnamecheck = exports["vice"]:scalarSync("SELECT gangname FROM vice_gangs WHERE gangname = @gangname", {gangname = newname})
    if gangnamecheck == nil then
        exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
            if #ganginfo > 0 then
                local gangmembers = json.decode(ganginfo[1].gangmembers)
                for A,B in pairs(gangmembers) do
                    if tostring(user_id) == A then
                        if B.rank == 4 then
                            exports["vice"]:execute("UPDATE vice_gangs SET gangname = @gangname WHERE gangname = @oldgangname", {gangname = newname, oldgangname = gangname})
                            for A,B in pairs(gangmembers) do
                                MySQL.execute("vice_edituser", {user_id = A, gangname = newname})
                                syncRadio(VICE.getUserSource(tonumber(A)))
                            end
                            VICE.notify(source, "~g~You have renamed the gang to: " ..newname)
                            addGangLog(VICE.getPlayerName(user_id),user_id,"Renamed gang",newname)
                        else
                            VICE.notify(source, "~r~You do not have permission to rename this gang.")
                        end
                    end
                end
            end
        end)
    else
        VICE.notify(source, "~r~Gang name is already taken.")
        return
    end
end)

RegisterServerEvent("VICE:SetGangWebhook")
AddEventHandler("VICE:SetGangWebhook", function(gangid)
    local source = source 
    local user_id = VICE.getUserId(source)
    exports['vice']:execute('SELECT * FROM vice_gangs WHERE gangname = @gangname', {gangname = gangid}, function(G)
        for K, V in pairs(G) do
            local array = json.decode(V.gangmembers) -- Convert the JSON string to a table
            for I, L in pairs(array) do
                if tostring(user_id) == I then
                    if L["rank"] == 4 then
                        VICE.prompt(source, "Webhook (Enter the webhook here): ", "", function(source, webhook)
                            local pattern = "^https://discord.com/api/webhooks/%d+/%S+$"
                            if webhook and string.match(webhook, pattern) then 
                                exports['vice']:execute("UPDATE vice_gangs SET webhook = @webhook WHERE gangname = @gangname", {gangname = gangid, webhook = webhook}, function(gotGangs) end)
                                VICE.notify(source, "~g~Webhook set.")
                                TriggerClientEvent('VICE:ForceRefreshData', -1)
                            else
                                VICE.notify(source, "~r~Invalid value.")
                            end
                        end)
                    else
                        VICE.notify(source, "~r~You do not have permission.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:LockGangFunds", function(gangname)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        local newlocked = not tobool(ganginfo[1].lockedfunds)
                        exports["vice"]:execute("UPDATE vice_gangs SET lockedfunds = @lockedfunds WHERE gangname = @gangname", {lockedfunds = newlocked, gangname = gangname}) 
                        VICE.notify(source, "~g~You have " ..(newlocked and "locked" or "unlocked") .." the gang funds.")
                        TriggerClientEvent("VICE:ForceRefreshData",source)
                        addGangLog(VICE.getPlayerName(user_id),user_id,"Locked Funds","")
                    else
                        VICE.notify(source, "~r~You do not have permission to lock the gang funds.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:sendGangMarker",function(Gangname,coords)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = Gangname}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            -- Send ping to all gang members
            for C,D in pairs(gangmembers) do
                local temp = VICE.getUserSource(tonumber(C))
                if temp then
                    TriggerClientEvent("VICE:drawGangMarker",temp,VICE.getPlayerName(user_id),coords)
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:setGangFit",function(gangName)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT * FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
        if #ganginfo > 0 then
            local gangmembers = json.decode(ganginfo[1].gangmembers)
            for A,B in pairs(gangmembers) do
                if tostring(user_id) == A then
                    if B.rank == 4 then
                        VICEclient.getCustomization(source,{},function(customization)
                            exports["vice"]:execute("UPDATE vice_gangs SET gangfit = @gangfit WHERE gangname = @gangname", {gangfit = json.encode(customization), gangname = gangName})
                            VICE.notify(source, "~g~You have set the gang fit.")
                            addGangLog(VICE.getPlayerName(user_id),user_id,"Set Gang Fit","")
                            TriggerClientEvent("VICE:ForceRefreshData",source)
                        end)
                    else
                        VICE.notify(source, "~r~You do not have permission to set the gang fit.")
                    end
                end
            end
        end
    end)
end)

RegisterServerEvent("VICE:applyGangFit", function(gangName)
    local source = source
    local user_id = VICE.getUserId(source)
    exports["vice"]:execute("SELECT gangfit FROM vice_gangs WHERE gangname = @gangname", {gangname = gangName}, function(ganginfo)
        if #ganginfo > 0 then
            VICEclient.setCustomization(source, {json.decode(ganginfo[1].gangfit)}, function()
                VICE.notify(source, "~g~You have applied the gang fit.")
                addGangLog(VICE.getPlayerName(user_id),user_id,"Apply Gang Fit","")
            end)
        end
    end)
end)

AddEventHandler("VICE:onServerSpawn", function(user_id,source,fspawn)
    if fspawn then
        playerinvites[source] = {}
        exports["vice"]:execute("INSERT IGNORE INTO vice_user_gangs (user_id) VALUES (@user_id)", {user_id = user_id})
    end
end)
RegisterServerEvent("VICE:newGangPanic")
AddEventHandler("VICE:newGangPanic", function(a,playerName)
    local source = source
    local user_id = VICE.getUserId(source)   
    local peoplesids = {}
    local gangmembers = {}
    exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
        for K,V in pairs(gotGangs) do
            local array = json.decode(V.gangmembers)
            for I,L in pairs(array) do
                if tostring(user_id) == I then
                    isingang = true
                    for U,D in pairs(array) do
                        peoplesids[tostring(U)] = tostring(D.gangPermission)
                    end
                    exports['vice']:execute('SELECT * FROM vice_users', function(gotUser)
                        for J,G in pairs(gotUser) do
                            if peoplesids[tostring(G.id)] then
                                local player = VICE.getUserSource(tonumber(G.id))
                                if player then
                                    TriggerClientEvent("VICE:returnPanic", player, player, a, playerName,V.gangname)
                                    addGangLog(VICE.getPlayerName(user_id),user_id,"Panic","ID: "..G.id)
                                end
                            end
                        end
                    end)
                    break
                end
            end
        end
    end)
end)

local gangtable = {}
Citizen.CreateThread(function()
    while true do
        Wait(10000)
        for _,a in pairs(GetPlayers()) do
            local user_id = VICE.getUserId(a)
            if user_id then
                gangtable[user_id] = {health = GetEntityHealth(GetPlayerPed(a)), armor = GetPedArmour(GetPlayerPed(a))}
            end
        end
        TriggerClientEvent("VICE:sendGangHPStats", -1, gangtable)
    end
end)

AddEventHandler("playerDropped", function(reason)
    local source = source
    local user_id = VICE.getUserId(source)
    if gangtable[user_id] ~= nil then
        gangtable[user_id] = nil
        TriggerClientEvent("VICE:sendGangHPStats", -1, gangtable)
        syncRadio(source)
    end
end)

Citizen.CreateThread(function()
    Wait(2500)
    exports['vice']:execute([[
    CREATE TABLE IF NOT EXISTS `vice_user_gangs` (
    `user_id` int(11) NOT NULL,
    `gangname` VARCHAR(100) NULL,
    PRIMARY KEY (`user_id`)
    );]])
end)

RegisterCommand("gangconvert",function(source)
    if source == 0 then
        exports['vice']:execute("SELECT * FROM vice_gangs",{},function(gangs)
            for A,B in pairs(gangs) do
                local gangmembers = json.decode(B.gangmembers)
                for C,D in pairs(gangmembers) do
                    print("Setting gang for user: "..C.." to "..B.gangname)
                    MySQL.execute("vice_adduser", {user_id = C, gangname = B.gangname})
                end
            end
        end)
    end
end)

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
    local source = source
    syncRadio(source)
end)