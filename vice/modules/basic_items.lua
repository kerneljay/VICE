-- load config items
local cfg = module("cfg/items")
local waps = module("cfg/weapons")
local items = {}

for k,v in pairs(cfg.items) do
  VICE.defInventoryItem(k,v[1],v[2],v[3],v[4])
  if k ~= "wammo" and k ~= "wbody" then
    local name = v[1]
    local desc = v[2]
    local weight = v[4]
    if type(name) == "function" then
      name = k
    end
    if type(desc) == "function" then
      desc = ""
    end
    if type(weight) == "function" then
      weight = 0.1
    end
    if type(name) ~= "string" or type(desc) ~= "string" or type(weight) ~= "number" then
      print("[VICE] invalid item name ["..k.."]",name,desc,weight)
    end
    if items[k] then
      print("[VICE] duplicate item name ["..k.."]")
    end
    items[k] = {name = name, desc = desc, weight = weight}
  end
end

for wap,data in pairs(waps.weapons) do
  local name = data.name
  local desc = ""
  local weight = cfg.items.wbody[4]({wap})
  items["wbody|"..wap] = {name = name, desc = desc, weight = weight}
end

AddEventHandler("VICE:onServerSpawn", function(user_id, source, first_spawn)
  TriggerClientEvent("VICE:GottenItems",source,items)
end)

RegisterServerEvent("VICE:getItemInfo",function(user_id)
  local source = source
  local admin_id = VICE.getUserId(source)
  local tempId = VICE.getUserSource(user_id)
  if not tempId then
      VICE.notify(source,"~r~This player is not online")
      return
  end
  local name = VICE.getPlayerName(user_id)
  TriggerClientEvent("VICE:GottenItemInfo",source,{name = name, user_id = user_id, temp_id = tempId})
end)

RegisterServerEvent("VICE:GiveItemMenu",function(user_id,item,amount)
  local source = source
  local admin_id = VICE.getUserId(source)
  local tempId = VICE.getUserSource(user_id)
  if not VICE.hasPermission(admin_id,"group.remove.founder") then
    VICE.notify(source,"~r~You don't have perms")
    return
  end
  if not tempId then
      VICE.notify(source,"~r~This player is not online")
      return
  end
  if not item or not amount then
      VICE.notify(source,"~r~Invalid item or amount")
      return
  end
  if not items[item] then
      VICE.notify(source,"~r~Invalid item")
      return
  end
  VICE.giveInventoryItem(user_id,item,amount)
  item = items[item].name
  VICE.notify(source,"~g~You gave "..amount.." "..item.." to "..VICE.getPlayerName(user_id))
  VICE.notify(tempId,"~g~You received "..amount.." "..item.." from "..GetPlayerName(source))
end)