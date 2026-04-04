RegisterServerEvent('VICE:openAAMenu')
AddEventHandler('VICE:openAAMenu', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasPermission(user_id, "aa.menu")then
      VICEclient.openAAMenu(source,{})
    end
end)

RegisterServerEvent('VICE:setAAMenu')
AddEventHandler('VICE:setAAMenu', function(status)
    local source = source
    local user_id = VICE.getUserId(source)
end)