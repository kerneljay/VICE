
local items = {}

local cocaine_sniff = {}
cocaine_sniff["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"Cocaine",1) then
      VICE.notify(player, "~g~Snorting Cocaine.")
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:cocaineEffect', player)
    end
  end
end}

local heroin_take = {}
heroin_take["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"Heroin",1) then
      VICE.notify(player, "~g~Injecting Heroin.")
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:heroinEffect', player)
    end
  end
end}


local lsd_take = {}
lsd_take["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"LSD",1) then
      VICE.notify(player, "~g~Taking LSD.")
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:doAcid', player)
    end
  end
end}

local morphine_choices = {}
morphine_choices["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"Morphine",1) then
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:applyMorphine', player)
    end
  end
end}

local taco_choices = {}
taco_choices["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"Taco",1) then
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:eatTaco', player)
    end
  end
end}--

local bluerush_take = {}
bluerush_take["Take"] = {function(player,choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    if VICE.tryGetInventoryItem(user_id,"Joint",1) then
      VICE.notify(player, "~g~Smoking a Joint.")
      TriggerEvent('VICE:RefreshInventory', player)
      TriggerClientEvent('VICE:blueRushEffect', player)
    end
  end
end}

-- Drugs
items["Cocaine"] = {"Cocaine","Some Cocaine.",function(args) return cocaine_sniff end,4}
items["Heroin"] = {"Heroin","Some Heroin.",function(args) return heroin_take end,4}
items["LSD"] = {"LSD","Some LSD.",function(args) return lsd_take end,4}
items["Joint"] = {"Joint","A joint that boosts health and speed.",function(args) return bluerush_take end,4}

-- Edibles
items["Morphine"] = {"Morphine","Some Morphine.",function(args) return morphine_choices end,1}
items["Taco"] = {"Taco","A Taco.",function(args) return taco_choices end,1}

return items
