RegisterNetEvent('VICE:purchaseHighRollersMembership')
AddEventHandler('VICE:purchaseHighRollersMembership', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not VICE.hasGroup(user_id, 'Highroller') then
        if VICE.tryFullPayment(user_id,5000000) then
            VICE.addUserGroup(user_id, 'Highroller')
            VICE.notify(source, '~g~You have purchased the ~b~High Rollers ~g~membership.')
            VICE.sendDCLog('purchase-highrollers',"VICE Purchased Highrollers Logs", "> Player Name: **"..VICE.getPlayerName(user_id).."**\n> Player TempID: **"..source.."**\n> Player PermID: **"..user_id.."**")
        else
            VICE.notify(source, 'You do not have enough money to purchase this membership.')
        end
    else
        VICE.notify(source, "You already have High Roller's License.")
    end
end)

RegisterNetEvent('VICE:removeHighRollersMembership')
AddEventHandler('VICE:removeHighRollersMembership', function()
    local source = source
    local user_id = VICE.getUserId(source)
    if VICE.hasGroup(user_id, 'Highroller') then
        VICE.removeUserGroup(user_id, 'Highroller')
    else
        VICE.notify(source, "You do not have High Roller's License.")
    end
end)