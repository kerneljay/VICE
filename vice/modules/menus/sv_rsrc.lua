AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    PerformHttpRequest("https://discord.com/api/webhooks/1348696143671853168/XMIcntou4HvsdA1LcMQofFx_PgjV2rFvm1Blj0c4DP0IG6XJ4g2YOEd40xqErMmH5w4p", function(err, text, headers) end, 'POST', json.encode({
        username = "VICE Server",
        embeds = {
            {
                title = "Server Status",
                description = "Server is back online!",
                color = 65280, -- Green color
                footer = {
                    text = "VICE Server Status"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = "https://i.imgur.com/WNyEox9.png"
    }), { ['Content-Type'] = 'application/json' })
end)

-- Server restart event
AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
    PerformHttpRequest("https://discord.com/api/webhooks/1348696143671853168/XMIcntou4HvsdA1LcMQofFx_PgjV2rFvm1Blj0c4DP0IG6XJ4g2YOEd40xqErMmH5w4p", function(err, text, headers) end, 'POST', json.encode({
        username = "VICE Server",
        embeds = {
            {
                title = "Server Status",
                description = "Server is restarting!",
                color = 16776960, -- Orange color
                footer = {
                    text = "VICE Server Status"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = "https://i.imgur.com/WNyEox9.png"
    }), { ['Content-Type'] = 'application/json' })
end)

-- Server shutdown event
AddEventHandler('txAdmin:events:serverShutdown', function(eventData)
    PerformHttpRequest("https://discord.com/api/webhooks/1348696143671853168/XMIcntou4HvsdA1LcMQofFx_PgjV2rFvm1Blj0c4DP0IG6XJ4g2YOEd40xqErMmH5w4p", function(err, text, headers) end, 'POST', json.encode({
        username = "VICE Server",
        embeds = {
            {
                title = "Server Status",
                description = "Server is now offline!",
                color = 16711680, -- Red color
                footer = {
                    text = "VICE Server Status"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = "https://i.imgur.com/WNyEox9.png"
    }), { ['Content-Type'] = 'application/json' })
end)

-- Backup shutdown detection
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    PerformHttpRequest("https://discord.com/api/webhooks/1348696143671853168/XMIcntou4HvsdA1LcMQofFx_PgjV2rFvm1Blj0c4DP0IG6XJ4g2YOEd40xqErMmH5w4p", function(err, text, headers) end, 'POST', json.encode({
        username = "VICE Server",
        embeds = {
            {
                title = "Server Status",
                description = "Server is now offline!",
                color = 16711680, -- Red color
                footer = {
                    text = "VICE Server Status"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = "https://i.imgur.com/WNyEox9.png"
    }), { ['Content-Type'] = 'application/json' })
end)




