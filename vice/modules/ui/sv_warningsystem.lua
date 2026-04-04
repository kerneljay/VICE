function VICE.GetWarnings(user_id, source)
    local vicewarningstables = exports['vice']:executeSync("SELECT * FROM vice_warnings WHERE user_id = @uid", { uid = user_id })
    for warningID, warningTable in pairs(vicewarningstables) do
        local date = warningTable["warning_date"]
        local newdate = tonumber(date) / 1000
        newdate = os.date('%Y-%m-%d', newdate)
        warningTable["warning_date"] = newdate
		local points = warningTable["point"]
    end
    return vicewarningstables
end

function VICE.AddWarnings(target_id, adminName, warningReason, warning_duration, point)
    if warning_duration == -1 then
        warning_duration = 0
    end
    exports['vice']:execute("INSERT INTO vice_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`, `point`) VALUES (@user_id, @warning_type, @duration, @admin, @warning_date, @reason, @point);", { user_id = target_id, warning_type = "Ban", admin = adminName, duration = warning_duration, warning_date = os.date("%Y/%m/%d"), reason = warningReason, point = point })
end

RegisterServerEvent("VICE:refreshWarningSystem")
AddEventHandler("VICE:refreshWarningSystem", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id then
        local vicewarningstables = VICE.GetWarnings(user_id, source)
        local ndata = VICE.getUserDataTable(user_id)
        local a = exports['vice']:executeSync("SELECT * FROM vice_bans_offenses WHERE UserID = @uid", { uid = user_id })
        
        local current_points = 0
        if a and a[1] then
            current_points = a[1].points or 0
        end

        -- Ensure warnings and info are not nil
        vicewarningstables = vicewarningstables or {}
        local info = { user_id = user_id }

        TriggerClientEvent("VICE:recievedRefreshedWarningData", source, vicewarningstables, current_points, info, ndata.PlayerTime, user_id)
    end
end)

RegisterCommand('sw', function(source, args)
    local user_id = VICE.getUserId(source)
    local permID = tonumber(args[1])
    if permID then
        if VICE.hasPermission(user_id, "admin.tickets") then
            local vicewarningstables = VICE.GetWarnings(permID, source)
            local ndata = VICE.getUserDataTable(permID)
            local a = exports['vice']:executeSync("SELECT * FROM vice_bans_offenses WHERE UserID = @uid", { uid = permID })
            for k, v in pairs(a) do
                if v.UserID == permID then
                    for warningID, warningTable in pairs(vicewarningstables) do
                        warningTable["points"] = v.points
                    end
                    local info = { user_id = permID}
                    TriggerClientEvent("VICE:showWarningsOfUser", source, vicewarningstables, v.points, info, ndata.PlayerTime, permID)
                end
            end
        end
    end
end)
