local lang = VICE.lang
local cfg = module("VICEVeh", "inventory")

-- this module define the player inventory (lost after respawn, as wallet)

VICE.items = {}

function VICE.defInventoryItem(idname,name,description,choices,weight)
  if weight == nil then
    weight = 0
  end

  local item = {name=name,description=description,choices=choices,weight=weight}
  VICE.items[idname] = item

  -- build give action
  item.ch_give = function(player,choice)
  end

  -- build trash action
  item.ch_trash = function(player,choice)
    local user_id = VICE.getUserId(player)
    if user_id then
      -- prompt number
      VICE.prompt(player,lang.inventory.trash.prompt({VICE.getInventoryItemAmount(user_id,idname)}),"",function(player,amount)
        local amount = parseInt(amount)
        if VICE.tryGetInventoryItem(user_id,idname,amount,false) then
          VICE.notify(player, lang.inventory.trash.done({VICE.getItemName(idname),amount}))
          VICEclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
        else
          VICE.notify(player, lang.common.invalid_value())
        end
      end)
    end
  end
end

-- give action
function ch_give(idname, player, choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    VICEclient.NearbyDrawRect(player,{},function(selectedplayer)
      if selectedplayer then
        local nuser_id = VICE.getUserId(selectedplayer)
        if nuser_id then
          VICE.prompt(player,string.format("Amount to give: (max %s or 'all')",VICE.getInventoryItemAmount(user_id,idname)),"",function(player,amount)
            if amount == "all" then
              amount = VICE.getInventoryItemAmount(user_id,idname)
            end
            local amount = parseInt(amount)
            local new_weight = VICE.getInventoryWeight(nuser_id)+VICE.getItemWeight(idname)*amount
            if new_weight <= VICE.getInventoryMaxWeight(nuser_id) then
              if VICE.tryGetInventoryItem(user_id,idname,amount,true) then
                VICE.giveInventoryItem(nuser_id,idname,amount,true)
                TriggerEvent('VICE:RefreshInventory', player)
                TriggerEvent('VICE:RefreshInventory', selectedplayer)
                VICEclient.playAnim(player,{true,{{"mp_common","givetake1_a",1}},false})
                VICEclient.playAnim(selectedplayer,{true,{{"mp_common","givetake2_a",1}},false})
              else
                VICE.notify(player, lang.common.invalid_value())
              end
            else
              VICE.notify(player, lang.inventory.full())
            end
          end)
        else
          VICE.notify(player, '~r~Invalid Temp ID.')
        end
      else
        VICE.notify(player, "~r~No players nearby!")
      end
    end)
  end
end

-- trash action
function ch_trash(idname, player, choice)
  local user_id = VICE.getUserId(player)
  if user_id then
    -- prompt number
    if VICE.getInventoryItemAmount(user_id,idname) > 1 then 
      VICE.prompt(player,string.format("Amount to trash (max %s or 'all')",VICE.getInventoryItemAmount(user_id,idname)),"",function(player,amount)
        if amount == "all" then
          amount = VICE.getInventoryItemAmount(user_id,idname)
        end
        local amount = parseInt(amount)
        if VICE.tryGetInventoryItem(user_id,idname,amount,false) then
          TriggerEvent('VICE:RefreshInventory', player)
          VICE.createDropBag(player, idname, amount)
          VICE.notify(player, lang.inventory.trash.done({VICE.getItemName(idname),amount}))
          VICEclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
        else
          VICE.notify(player, lang.common.invalid_value())
        end
      end)
    else
      if VICE.tryGetInventoryItem(user_id,idname,1,false) then
        TriggerEvent('VICE:RefreshInventory', player)
        VICE.createDropBag(player, idname, 1)
        VICE.notify(player, lang.inventory.trash.done({VICE.getItemName(idname),1}))
        VICEclient.playAnim(player,{true,{{"pickup_object","pickup_low",1}},false})
      else
        VICE.notify(player, lang.common.invalid_value())
      end
    end
  end
end

function VICE.computeItemName(item,args)
  if type(item.name) == "string" then return item.name
  else return item.name(args) end
end

function VICE.computeItemDescription(item,args)
  if type(item.description) == "string" then return item.description
  else return item.description(args) end
end

function VICE.computeItemChoices(item,args)
  if item.choices then
    return item.choices(args)
  else
    return {}
  end
end

function VICE.computeItemWeight(item,args)
  if type(item.weight) == "number" then return item.weight
  else return item.weight(args) end
end


function VICE.parseItem(idname)
  return splitString(idname,"|")
end

-- return name, description, weight
function VICE.getItemDefinition(idname)
  local args = VICE.parseItem(idname)
  local item = VICE.items[args[1]]
  if item then
    return VICE.computeItemName(item,args), VICE.computeItemDescription(item,args), VICE.computeItemWeight(item,args)
  end

  return nil,nil,nil
end

function VICE.getItemName(idname)
  local args = VICE.parseItem(idname)
  local item = VICE.items[args[1]]
  if item then return VICE.computeItemName(item,args) end
  return args[1]
end

function VICE.getItemDescription(idname)
  local args = VICE.parseItem(idname)
  local item = VICE.items[args[1]]
  if item then return VICE.computeItemDescription(item,args) end
  return ""
end

function VICE.getItemChoices(idname)
  local args = VICE.parseItem(idname)
  local item = VICE.items[args[1]]
  local choices = {}
  if item then
    -- compute choices
    local cchoices = VICE.computeItemChoices(item,args)
    if cchoices then -- copy computed choices
      for k,v in pairs(cchoices) do
        choices[k] = v
      end
    end

    -- add give/trash choices
    choices[lang.inventory.give.title()] = {function(player,choice) ch_give(idname, player, choice) end, lang.inventory.give.description()}
    choices[lang.inventory.trash.title()] = {function(player, choice) ch_trash(idname, player, choice) end, lang.inventory.trash.description()}
  end

  return choices
end

function VICE.getItemWeight(idname)
  local args = VICE.parseItem(idname)
  local item = VICE.items[args[1]]
  if item then return VICE.computeItemWeight(item,args) end
  return 1
end

-- compute weight of a list of items (in inventory/chest format)
function VICE.computeItemsWeight(items)
  local weight = 0
  for k,v in pairs(items) do
    local iweight = VICE.getItemWeight(k)
    if iweight then
      weight = weight+iweight*v.amount
    end
  end
  return weight
end

-- add item to a connected user inventory
function VICE.giveInventoryItem(user_id,idname,amount,notify)
  local player = VICE.getUserSource(user_id)
  if notify == nil then notify = true end -- notify by default

  local data = VICE.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry then -- add to entry
      entry.amount = entry.amount+amount
    else -- new entry
      data.inventory[idname] = {amount=amount}
    end
    -- Only trigger red money for actual dirty money items, not for ammo or other items
    if idname == "redmoney" then
      VICE.setDirtyCash(user_id, data.inventory[idname].amount, true)
    end

    -- notify
    if notify then
      local player = VICE.getUserSource(user_id)
      if player then
        VICE.notify(player, lang.inventory.give.received({VICE.getItemName(idname),amount}))
      end
    end
  end
  TriggerEvent('VICE:RefreshInventory', player)
end


function VICE.RunTrashTask(source, itemName)
    local choices = VICE.getItemChoices(itemName)
    if choices['Trash'] then
        choices['Trash'][1](source)
    else 
        local user_id = VICE.getUserId(source)
        local data = VICE.getUserDataTable(user_id)
        data.inventory[itemName] = nil;
    end
    TriggerEvent('VICE:RefreshInventory', source)
end


function VICE.RunGiveTask(source, itemName)
    local choices = VICE.getItemChoices(itemName)
    if choices['Give'] then
        choices['Give'][1](source)
    end
    TriggerEvent('VICE:RefreshInventory', source)
end

function VICE.RunGiveAllTask(source, itemName)
  local choices = VICE.getItemChoices(itemName)
  if choices['GiveAll'] then
      choices['GiveAll'][1](itemName, source)
  end
  TriggerEvent('VICE:RefreshInventory', source)
end


function VICE.giveAllItems(source, itemName)
  local quantity = VICE.getInventoryItemAmount(source, itemName)
  if quantity then
      for i = 1, quantity do
          VICE.RunGiveTask(source, itemName)
      end
  end
  TriggerEvent('VICE:RefreshInventory', source)
end



function VICE.RunInventoryTask(source, itemName)
    local choices = VICE.getItemChoices(itemName)
    if choices['Use'] then 
        choices['Use'][1](source)
    elseif choices['Drink'] then
        choices['Drink'][1](source)
    elseif choices['Load'] then
        choices['Load'][1](source)
    elseif choices['Eat'] then
        choices['Eat'][1](source)
    elseif choices['Equip'] then 
        choices['Equip'][1](source)
    elseif choices['Take'] then 
        choices['Take'][1](source)
    end
    TriggerEvent('VICE:RefreshInventory', source)
end

function VICE.LoadAllTask(source, itemName)
  local choices = VICE.getItemChoices(itemName)
  choices['LoadAll'][1](source)
  TriggerEvent('VICE:RefreshInventory', source)
end

-- function to move all items from one inventory to another
function VICE.transferAllItems(user_id_source, itemId)
  local source_data = VICE.getUserDataTable(user_id_source)
  if source_data and source_data.inventory then
      for idname, entry in pairs(source_data.inventory) do
          local weightCalculation = VICE.getInventoryWeight(itemId) + (VICE.getItemWeight(idname) * entry.amount)
          if weightCalculation <= VICE.getInventoryMaxWeight(itemId) then
              if VICE.tryGetInventoryItem(user_id_source, idname, entry.amount, true) then
                  VICE.giveInventoryItem(itemId, idname, entry.amount, true)
              else
                  return false
              end
          else
              VICE.notify(VICE.getUserSource(itemId), '~r~You do not have enough inventory space.')
              return false
          end
      end
  else
      return false
  end
  return true
end


-- try to get item from a connected user inventory
function VICE.tryGetInventoryItem(user_id,idname,amount,notify)
  if notify == nil then notify = true end -- notify by default
  local player = VICE.getUserSource(user_id)

  local data = VICE.getUserDataTable(user_id)
  if data and amount > 0 then
    local entry = data.inventory[idname]
    if entry and entry.amount >= amount then -- add to entry
      -- Only update dirty cash for actual red money items, not for ammo or other items
      if idname == "redmoney" then
        entry.amount = entry.amount-amount
        VICE.setDirtyCash(user_id, entry.amount, true)
      else
        entry.amount = entry.amount-amount
      end

      -- remove entry if <= 0
      if entry.amount <= 0 then
        data.inventory[idname] = nil 
      end

      -- notify
      if notify then
        local player = VICE.getUserSource(user_id)
        if player then
          VICE.notify(player, lang.inventory.give.given({VICE.getItemName(idname),amount}))
        end
      end
      TriggerEvent('VICE:RefreshInventory', player)
      return true
    else
      -- notify
      if notify then
        local player = VICE.getUserSource(user_id)
        if player then
          local entry_amount = 0
          if entry then entry_amount = entry.amount end
          VICE.notify(player, lang.inventory.missing({VICE.getItemName(idname),amount-entry_amount}))
        end
      end
    end
  end

  return false
end

-- get user inventory amount of item
function VICE.getInventoryItemAmount(user_id,idname)
  local data = VICE.getUserDataTable(user_id)
  if data and data.inventory then
    local entry = data.inventory[idname]
    if entry then
      return entry.amount
    end
  end

  return 0
end

-- return user inventory total weight
function VICE.getInventoryWeight(user_id)
  local data = VICE.getUserDataTable(user_id)
  if data and data.inventory then
    return VICE.computeItemsWeight(data.inventory)
  end
  return 0
end

function VICE.getInventoryMaxWeight(user_id)
  local data = VICE.getUserDataTable(user_id)
  if data.invcap then
    return data.invcap
  end
  return 30
end


-- clear connected user inventory
function VICE.clearInventory(user_id)
  local data = VICE.getUserDataTable(user_id)
  if data then
    data.inventory = {}
  end
end


AddEventHandler("VICE:playerJoin", function(user_id,source,name,last_login)
  local data = VICE.getUserDataTable(user_id)
  if data.inventory == nil then
    data.inventory = {}
  end
end)


RegisterCommand("storebackpack", function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  local data = VICE.getUserDataTable(user_id)
  VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
    if cb then
      local invcap = 30
      if plathours > 0 then
          invcap = invcap + 20
      elseif plushours > 0 then
          invcap = invcap + 10
      end
      if invcap == 30 then
        VICE.notify(source, "~r~You do not have a backpack equipped.")
        return
      end
      if data.invcap - 15 == invcap then
        VICE.giveInventoryItem(user_id, "offwhitebag", 1, false)
      elseif data.invcap - 20 == invcap then
        VICE.giveInventoryItem(user_id, "guccibag", 1, false)
      elseif data.invcap - 30 == invcap  then
        VICE.giveInventoryItem(user_id, "nikebag", 1, false)
      elseif data.invcap - 30 == invcap  then
        VICE.giveInventoryItem(user_id, "primarkbag", 1, false)
      elseif data.invcap - 35 == invcap  then
        VICE.giveInventoryItem(user_id, "huntingbackpack", 1, false)
      elseif data.invcap - 40 == invcap  then
        VICE.giveInventoryItem(user_id, "tanhikingbackpack", 1, false)
      elseif data.invcap - 40 == invcap  then
        VICE.giveInventoryItem(user_id, "greenhikingbackpack", 1, false)
      elseif data.invcap - 70 == invcap  then
        VICE.giveInventoryItem(user_id, "rebelbackpack", 1, false)
      end
      VICE.updateInvCap(user_id, invcap)
      VICE.notify(source, "~g~Backpack Stored")
      TriggerClientEvent('VICE:removeBackpack', source)
    else
      if VICE.getInventoryWeight(user_id) + 5 > VICE.getInventoryMaxWeight(user_id) then
        VICE.notify(source, "~r~You do not have enough room to store your backpack")
      end
    end
  end)
end)