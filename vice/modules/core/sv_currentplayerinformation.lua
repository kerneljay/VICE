function VICE.updateCurrentPlayerInfo()
  local currentPlayersInformation = {}
  local playersJobs = {}
  for k,v in pairs(VICE.getUsers()) do
    table.insert(playersJobs, {user_id = k, jobs = VICE.getUserGroups(k)})
  end
  currentPlayersInformation['currentStaff'] = VICE.getUsersByPermission('admin.tickets')
  currentPlayersInformation['jobs'] = playersJobs
  TriggerClientEvent("VICE:receiveCurrentPlayerInfo", -1, currentPlayersInformation)
end

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
  if first_spawn then
    VICE.updateCurrentPlayerInfo()
  end
end)
