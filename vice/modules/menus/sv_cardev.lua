RegisterServerEvent('VICE:setCarDevMode')
AddEventHandler('VICE:setCarDevMode', function(status)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id and VICE.hasPermission(user_id, "cardev.menu") then 
      if status then
      --  VICEclient.teleport(player,{2370.8, 2856.58, 40.46})
        VICE.setBucket(source, 333)
      else
        VICE.setBucket(source, 0)
      end
    else
      VICE.ACBan(15,user_id,"VICE:setCarDevMode")
    end
end)

local screenshotdata = {}

RegisterServerEvent('VICE:takeCarScreenshot')
AddEventHandler('VICE:takeCarScreenshot', function()
    local source = source
    local user_id = VICE.getUserId(source)

    if user_id and VICE.hasPermission(user_id, "cardev.menu") then 
      --TriggerClientEvent("VICE:takeCarScreenshotAndUpload", source, 'http://vicestudios.ltd/uplds.php',screenshotid)
      local screenshotid = #screenshotdata + 1
      screenshotdata[screenshotid] = {target = user_id, admin = user_id}
      TriggerClientEvent("VICE:takeClientScreenshotAndUpload", source, VICE.getWebhook('media-cache'),screenshotid)  
    end
end)

RegisterServerEvent('VICE:sendWebhookCarDev')
AddEventHandler('VICE:sendWebhookCarDev', function(output, car)
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)

    if user_id and VICE.hasPermission(user_id, "cardev.menu") then 
        VICE.sendDCLog('car-dev', 'VICE Car Dev Logs', "> Players TempID: **" .. source .. "**\n> Players PermID: **" .. user_id .. "**\n> Players Name: **" .. name .. "**\n\n Requested the following for car: **" .. car .. "**\n\n```" .. output .. "```")
    else
        VICE.ACBan(15,user_id,"VICE:sendWebhookCarDev")
    end
end)

RegisterServerEvent('vice:getUserVehicles')
AddEventHandler('vice:getUserVehicles', function()
  local source = source
  local user_id = VICE.getUserId(source)
    local vehicles = {}

    exports['vice']:execute('SELECT * FROM vice_cardev WHERE user_id = @user_id AND claimed = true', {['@user_id'] = user_id}, function(result, affectedRows, lastInsertId)
      if result then
          vehicles = result
         -- print("Fetched vehicles for user_id " .. user_id .. ":")
          for _, v in pairs(vehicles) do
              for key, value in pairs(v) do
                --  print(key, value)
              end
          end
      else
          print("Error executing SQL query:", affectedRows, lastInsertId)
      end
      TriggerClientEvent('vice:receiveUserVehicles', source, vehicles)
  end)  
end)

RegisterServerEvent('vice:markVehicleComplete')
AddEventHandler('vice:markVehicleComplete', function(reportid, reason)
    local source = source
    local user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)
    exports['vice']:execute('UPDATE vice_cardev SET completed = true, notes = @reason WHERE user_id = @user_id AND reportid = @reportid', {
        ['@user_id'] = user_id,
        ['@reportid'] = reportid,
        ['@reason'] = reason
    })
    VICE.notify(source, "~g~Report ID: " .. reportid .. " has been marked as complete.")
    VICE.sendDCLog('car-report', name.. " has completed report id: "..reportid, "> Name: **"..name.."**\n> User TempID: **"..source.."**\n> User PermID: ** "..user_id.."**\n> Report ID: **" .. reportid .. "**\n> Notes: **" .. reason .. "**")
end)

function carReportReceived()
  TriggerClientEvent('VICE:carDevTicket', -1)
end

exports('carReportReceived', carReportReceived)