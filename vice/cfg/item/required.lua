local items = {}
local a = module("cfg/weapons")

items["repairkit"] = {"DIY Repair Kit","Used to repair vehicles.",nil,0.5}
items["Headbag"] = {"Head Bag","Used to cover someone's head.",nil,0.5}
items["Shaver"] = {"Shaver","Used to shave someone's head.",nil,0.5}
items["handcuffkeys"] = {"Handcuff Keys","Used to uncuff someone.",nil,0.5}
items["boltcutters"] = {"Bolt Cutters","Used to rob houses.",nil,5}
items["medkit"] = {"Medkit","Used to revive players.",nil,5}
items["armourplate"] = {"Armour Plate","",nil,5}

local get_wname = function(weapon_id)
  for k,v in pairs(a.weapons) do
    if k == weapon_id then
      return v.name
    end
  end
end

--- weapon body
local wbody_name = function(args)
  return get_wname(args[2])
end

local wbody_desc = function(args)
  return ""
end

local wbody_choices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")

  choices["Equip"] = {function(player,choice)
    local user_id = VICE.getUserId(player)
    if user_id then
      if VICE.tryGetInventoryItem(user_id, fullidname, 1, true) then
        local weapons = {}
        weapons[args[2]] = {ammo = 0}
        for k,v in pairs(a.weapons) do
          if k == args[2] then
            if v.policeWeapon then
              if VICE.hasPermission(user_id, 'police.armoury') then
                VICEclient.giveWeapons(player, {weapons, false,globalpasskey})
              else
                VICE.notify(player, '~r~You cannot equip this weapon.')
              end
            else
              VICEclient.giveWeapons(player, {weapons, false,globalpasskey})
            end
          end
        end
      end
    end
  end}

  return choices
end

local wbody_weight = function(args)
  for k,v in pairs(a.weapons) do
    for c,d in pairs(args) do
      if k == d then
        if v.class == "Melee" then
          return 1.00
        elseif v.class == "Pistol" then
          return 5.00
        elseif v.class == "SMG" or v.class == "Shotgun" then
          return 7.50
        elseif v.class == "AR" then
          return 10.00
        elseif v.class == "Mosin" then
          return 7.50
        elseif v.class == "Heavy" or v.class == "LMG" then
          return 15.00
        elseif v.class == "Super" then
          return 20.00
        else
          return 1.00
        end
      end
    end
  end
end

items["wbody"] = {wbody_name,wbody_desc,wbody_choices,wbody_weight}

--- weapon ammo
local wammo_name = function(args)
  --print('helloo', json.encode(args))
  return args[1]
end

local wammo_desc = function(args)
  return ""
end

local wammo_choices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")
  local ammotype = nil;
  ammotype = args[1]

  choices["Load"] = {function(player,choice)
    local user_id = VICE.getUserId(player)
    if user_id then
      local amount = VICE.getInventoryItemAmount(user_id, fullidname)
      if string.find(fullidname, "Police") and not VICE.hasPermission(user_id, 'police.armoury') then
        VICE.notify(player, '~r~You cannot load this ammo.')
        local bulletAmount = VICE.getInventoryItemAmount(user_id, fullidname)
        VICE.tryGetInventoryItem(user_id, fullidname, bulletAmount, false)
        return
      end
      VICE.prompt(player, "Amount to load ? (max "..amount..")", "", function(player,ramount)
        ramount = parseInt(ramount)
        VICEclient.getWeapons(player, {}, function(uweapons) -- gets current weapons
          for k,v in pairs(a.weapons) do -- goes through new weapons cfg
            for c,d in pairs(uweapons) do -- goes through current weapons
              if k == c then  -- if weapon in new cfg is the same as in current weapons
                if fullidname == v.ammo then -- check if ammo being loaded is the same as the ammo for that gun
                  if VICE.tryGetInventoryItem(user_id, fullidname, ramount, true) then -- take ammo from inv
                    local weapons = {}
                    weapons[k] = {ammo = ramount}
                    VICEclient.giveWeapons(player, {weapons,false,globalpasskey})
                    TriggerEvent('VICE:RefreshInventory', player)
                    return
                  end
                end
              end
            end
          end
        end)
      end)
    end
  end}
  choices["LoadAll"] = {function(player,choice)
    local user_id = VICE.getUserId(player)
    if user_id then
      ramount = parseInt(VICE.getInventoryItemAmount(user_id, fullidname))
      if ramount > 250 then ramount = 250 end
      if string.find(fullidname, "Police") and not VICE.hasPermission(user_id, 'police.armoury') then
        VICE.notify(player, '~r~You cannot load this ammo.')
        local bulletAmount = VICE.getInventoryItemAmount(user_id, fullidname)
        VICE.tryGetInventoryItem(user_id, fullidname, bulletAmount, false)
        return
      end
      VICEclient.getWeapons(player, {}, function(uweapons) -- gets current weapons
        for k,v in pairs(a.weapons) do -- goes through new weapons cfg
          for c,d in pairs(uweapons) do -- goes through current weapons
            if k == c then  -- if weapon in new cfg is the same as in current weapons
              if fullidname == v.ammo then -- check if ammo being loaded is the same as the ammo for that gun
                if VICE.tryGetInventoryItem(user_id, fullidname, ramount, true) then -- take ammo from inv
                  local weapons = {}
                  weapons[k] = {ammo = ramount}
                  VICEclient.giveWeapons(player, {weapons,false,globalpasskey})
                  TriggerEvent('VICE:RefreshInventory', player)
                  return
                end
              end
            end
          end
        end
      end)
    end
  end}
  choices["GiveAll"] = {
    function(idname, player, choice)
        local user_id = VICE.getUserId(player)

        if user_id == nil then
            return
        end

        local itemAmount = VICE.getInventoryItemAmount(user_id, idname)

        if itemAmount <= 0 then
            VICE.notify(player, '~r~You don\'t have any of that item to give!')
            return
        end

        VICEclient.getNearestPlayers(player, {10}, function(nplayers)
            local numPlayers = 0
            local nplayerIds = {}

            for k, _ in pairs(nplayers) do
                numPlayers = numPlayers + 1
                table.insert(nplayerIds, k)
            end

            if numPlayers == 1 then
                local nplayerId = nplayerIds[1]
                local nuser_id = VICE.getUserId(nplayerId)

                if nuser_id ~= nil then
                    local inventoryWeight = VICE.getInventoryWeight(nuser_id)
                    local itemWeight = VICE.getItemWeight(idname)
                    local maxWeight = VICE.getInventoryMaxWeight(nuser_id)
                    local availableSpace = math.floor((maxWeight - inventoryWeight) / itemWeight)
                    local amountToGive = math.min(itemAmount, availableSpace)

                    if amountToGive > 0 then
                        if VICE.tryGetInventoryItem(user_id, idname, amountToGive, true) then
                            VICE.giveInventoryItem(nuser_id, idname, amountToGive, true)
                            TriggerEvent('VICE:RefreshInventory', player)
                            TriggerEvent('VICE:RefreshInventory', nplayerId)
                            VICEclient.playAnim(player, {true, {{"mp_common", "givetake1_a", 1}}, false})
                            VICEclient.playAnim(nplayerId, {true, {{"mp_common", "givetake2_a", 1}}, false})
                        else
                            VICE.notify(player, '~r~Invalid value.')
                        end
                    end
                else
                    VICE.notify(player, '~r~Invalid Temp ID for Player ' .. nplayerId)
                end
            elseif numPlayers > 1 then
                VICEclient.NearbyDrawRect(player,{},function(nplayer)
                    nplayer = tonumber(nplayer)
                    if nplayer and nplayers[nplayer] then
                        local selectedPlayerId = nplayer
                        local selectedPlayer = nplayers[selectedPlayerId]
                        local nuser_id = VICE.getUserId(selectedPlayerId)

                        if nuser_id ~= nil then
                            local inventoryWeight = VICE.getInventoryWeight(nuser_id)
                            local itemWeight = VICE.getItemWeight(idname)
                            local maxWeight = VICE.getInventoryMaxWeight(nuser_id)
                            local availableSpace = math.floor((maxWeight - inventoryWeight) / itemWeight)
                            local amountToGive = math.min(itemAmount, availableSpace)

                            if amountToGive > 0 then
                                if VICE.tryGetInventoryItem(user_id, idname, amountToGive, true) then
                                    VICE.giveInventoryItem(nuser_id, idname, amountToGive, true)
                                    TriggerEvent('VICE:RefreshInventory', player)
                                    TriggerEvent('VICE:RefreshInventory', selectedPlayerId)
                                    VICEclient.playAnim(player, {true, {{"mp_common", "givetake1_a", 1}}, false})
                                    VICEclient.playAnim(selectedPlayerId, {true, {{"mp_common", "givetake2_a", 1}}, false})
                                else
                                    VICE.notify(player, '~r~Invalid value.')
                                end
                            end
                        else
                            VICE.notify(player, '~r~Invalid Temp ID for Player ' .. selectedPlayerId)
                        end
                    else
                        VICE.notify(player, '~r~Invalid selection or player.')
                    end
                end)
            else
                VICE.notify(player, '~r~Give selection cancelled.')
            end
        end)
    end
}
  return choices
end

local wammo_weight = function(args)
  return 0.01
end

for i,v in pairs(VICEAmmoTypes) do
  items[i] = {wammo_name,wammo_desc,wammo_choices,wammo_weight}
end

items["wammo"] = {wammo_name,wammo_desc,wammo_choices,wammo_weight}

return items
