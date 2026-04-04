local processing = {request = {},claim = {}}

local function RefreshCompensations(user_id)
    local db = exports["vice"]:executeSync("SELECT * FROM vice_compensation WHERE user_id = @user_id",{user_id = user_id})
    local compensations = {}
    if db and #db > 0 then
        for A,B in pairs(db) do
            compensations[B.compid] = {compensator = B.compensator, weapons = json.decode(B.compensationdata)}
        end
    end
    TriggerClientEvent("VICE:ReceiveCompensations",VICE.getUserSource(user_id),compensations)
end


RegisterServerEvent("VICE:RequestCompensations",function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not processing.request[user_id] then
        RefreshCompensations(user_id)
        processing.request[user_id] = nil
    end
end)

RegisterServerEvent("VICE:StartCompensation",function(compensationid)
    local source = source
    local user_id = VICE.getUserId(source)
    if compensationid ~= user_id then
        if VICE.getUserSource(compensationid) then -- online check mkay
            local data = VICE.getUserDataTable(user_id)
            if data and data.inventory then
                local inventory = {}
                for A,B in pairs(data.inventory) do
                    inventory[A] = {amount = B.amount, ItemName = VICE.getItemName(A), Weight = VICE.getItemWeight(A)}
                end
                TriggerClientEvent("VICE:StartCompensation",source,inventory,compensationid)
            else
                print("No data found for user_id: "..user_id)
            end
        else
            VICE.notify(source, "~r~User is not online")
        end
    else
        VICE.notify(source, "~r~You can't compensate yourself")
    end
end)

RegisterServerEvent("VICE:SubmitCompensation",function(compdata,compensationid)
    local source = source
    local user_id = VICE.getUserId(source)
    local compsrc = VICE.getUserSource(compensationid)
    local tbl = {}
    if compsrc then
        for A,B in pairs(compdata.inventory) do
            if compdata.selected[B.ItemName] then
                if VICE.tryGetInventoryItem(user_id,A,B.amount) then
                    tbl[A] = B.amount
                end
            end
        end
        if next(tbl) then
            local inventoryStr = ""
            for A,B in pairs(compdata.inventory) do
                inventoryStr = inventoryStr .. B.ItemName .. " - " .. B.amount .. "x, "
            end
            inventoryStr = inventoryStr:sub(1, -3) 

            local compensatedItemsStr = ""
            for A,B in pairs(tbl) do
                local itemName = compdata.inventory[A].ItemName
                compensatedItemsStr = compensatedItemsStr .. itemName .. " - " .. B .. "x, "
            end
            compensatedItemsStr = compensatedItemsStr:sub(1, -3) 

            exports["vice"]:execute("INSERT INTO vice_compensation (user_id,compensator,compensationdata) VALUES (@user_id,@compensator,@compensationdata)",{user_id = compensationid,compensator = user_id,compensationdata = json.encode(tbl)},function()
                VICE.notify(source, "~g~Compensation submitted for ID: " .. compensationid)
                VICE.notify(compsrc, "~g~You have received compensation")
                RefreshCompensations(compensationid)
                VICE.sendDCLog('compensation-request', 'VICE Compensation Request Logs', "> Requester Name: **"..VICE.getPlayerName(user_id).."**\n> Requester TempID: **"..source.."**\n> Requester PermID: **"..user_id.."**\n> Player PermID: **".. compensationid .. "**\n> Player Name **" .. VICE.getPlayerName(compensationid) .. "**\n> Inventory: **"..inventoryStr.."**\n> Compensated Items: **"..compensatedItemsStr.."**")
            end)
        else
            VICE.notify(source, "~r~Unsuccessful compensation.\nIf this is a bug please report it to a staff member.")
        end
    else
        VICE.notify(source, "~r~User is not online")
    end
end)

RegisterServerEvent("VICE:ClaimCompensation",function(compid)
    local source = source
    local user_id = VICE.getUserId(source)
    if not processing.claim[user_id] then
        processing.claim[user_id] = true
        local db = exports["vice"]:executeSync("SELECT * FROM vice_compensation WHERE compid = @compid AND user_id = @user_id",{compid = compid,user_id = user_id})[1]
        if db then
            for A,B in pairs(json.decode(db.compensationdata)) do
                VICE.giveInventoryItem(user_id,A,B)
            end
            VICE.notify(source, "~g~Compensation claimed")
        else
            VICE.notify(source, "~r~Compensation not found")
        end
        exports["vice"]:execute("DELETE FROM vice_compensation WHERE compid = @compid AND user_id = @user_id",{compid = compid,user_id = user_id},function()
            RefreshCompensations(user_id)
            processing.claim[user_id] = nil
        end)
        processing.claim[user_id] = nil
    end
end)