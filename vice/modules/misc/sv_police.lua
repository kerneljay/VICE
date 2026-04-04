-- this module define some police tools and functions
local lang = VICE.lang
local a = module("cfg/weapons")

local isStoring = {}
choice_store_weapons = function(player, choice, death)
  local user_id = VICE.getUserId(player)
  local data = VICE.getUserDataTable(user_id)
  VICEclient.getWeapons(player, {}, function(weapons)
    if not isStoring[player] then
      VICE.getSubscriptions(user_id, function(cb, plushours, plathours)
        if cb then
          local maxWeight = 30
          if plathours > 0 then
            maxWeight = 50
          elseif plushours > 0 then
            maxWeight = 40
          end
          if VICE.getInventoryWeight(user_id) <= maxWeight or death then
            isStoring[player] = true
            local weaponWeights = 0
            for k, v in pairs(weapons) do
              if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k ~= 'WEAPON_SMOKEGRENADE' and k ~= 'WEAPON_FLASHBANG' then
                weaponWeights = weaponWeights + VICE.getItemWeight(k)
              end
            end
            if VICE.getInventoryWeight(user_id) + weaponWeights > maxWeight then
              VICE.notify(player, "~r~You do not have enough Weight to store Weapons.")
              isStoring[player] = nil
              return
            end
            VICEclient.giveWeapons(player, { {}, true, globalpasskey }, function(removedwep)
              for k, v in pairs(weapons) do
                if k ~= 'GADGET_PARACHUTE' and k ~= 'WEAPON_STAFFGUN' and k ~= 'WEAPON_SMOKEGRENADE' and k ~= 'WEAPON_FLASHBANG' then
                  VICE.giveInventoryItem(user_id, "wbody|" .. k, 1, not death)
                  if v.ammo > 0 and k ~= 'WEAPON_STUNGUN' then
                    for i, c in pairs(a.weapons) do
                      if i == k and c.class ~= 'Melee' then
                        if v.ammo > 250 then
                          v.ammo = 250
                        end
                        VICE.giveInventoryItem(user_id, c.ammo, v.ammo, not death)
                      end
                    end
                  end
                end
              end
              VICE.notify(player, "~g~Weapons Stored")
              TriggerEvent('VICE:RefreshInventory', player)
              VICEclient.ClearWeapons(player, {})
              data.weapons = {}
              if choice then
                choice(true)
              end
            end)
          else
            VICE.notify(player, '~r~You do not have enough Weight to store Weapons.')
          end
        end
        if choice then
          choice(false)
        end
        isStoring[player] = nil
      end)
    end
  end)
end

RegisterServerEvent("VICE:forceStoreSingleWeapon")
AddEventHandler("VICE:forceStoreSingleWeapon", function(model)
  local source = source
  local user_id = VICE.getUserId(source)
  if model then
    VICEclient.getWeapons(source, {}, function(weapons)
      for k, v in pairs(weapons) do
        if k == model then
          local new_weight = VICE.getInventoryWeight(user_id) + VICE.getItemWeight(model)
          if new_weight <= VICE.getInventoryMaxWeight(user_id) then
            SetPedAmmo(GetPlayerPed(source), k, 0)
            RemoveWeaponFromPed(GetPlayerPed(source), k)
            VICEclient.removeWeapon(source, { k })
            VICE.giveInventoryItem(user_id, "wbody|" .. k, 1, true)
            if v.ammo > 0 then
              for i, c in pairs(a.weapons) do
                if i == model and c.class ~= 'Melee' then
                  VICE.giveInventoryItem(user_id, c.ammo, v.ammo, true)
                  TriggerEvent('VICE:RefreshInventory', source)
                end
              end
            end
          end
        end
      end
    end)
  end
end)

local swcd = {}

RegisterCommand('storeallweapons', function(source)
  local source = source
  local user_id = VICE.getUserId(source)
  if swcd[user_id] and (os.time() - swcd[user_id]) < 3 then
    VICE.notify(source, "~r~Store weapon cooldown. Please wait!")
    return
  end
  swcd[user_id] = os.time()
  choice_store_weapons(source, nil, false)
end)

RegisterServerEvent("VICE:ForceStoreAllWeapons", function(death)
  choice_store_weapons(source, nil, death)
end)

RegisterCommand('shield', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent('VICE:toggleShieldMenu', source)
  end
end)

RegisterCommand('cuff', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  VICEclient.isHandcuffed(source, {}, function(handcuffed)
    if handcuffed then
      return
    else
      VICEclient.isStaffedOn(source, {}, function(staffedOn)
        if (staffedOn and VICE.hasPermission(user_id, 'admin.tickets')) or VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'ukbf.armoury') or VICE.hasPermission(user_id, 'hmp.menu') then
          VICEclient.getNearestPlayer(source, { 5 }, function(nplayer)
            if nplayer then
              local nplayer_id = VICE.getUserId(nplayer)
              if (not VICE.hasPermission(nplayer_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') or VICE.hasPermission(nplayer_id, 'police.undercover') or VICE.hasPermission(user_id, 'ukbf.armoury')) then
                VICEclient.isHandcuffed(nplayer, {}, function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('VICE:uncuffAnim', source, nplayer, false)
                    TriggerClientEvent('VICE:unHandcuff', source, false)
                  else
                    TriggerClientEvent('VICE:arrestCriminal', nplayer, source)
                    TriggerClientEvent('VICE:arrestFromPolice', source)
                  end
                  TriggerClientEvent('VICE:toggleHandcuffs', nplayer, false)
                  TriggerClientEvent('VICE:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              VICE.notify(source, lang.common.no_player_near())
            end
          end)
        end
      end)
    end
  end)
end)

RegisterCommand('frontcuff', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  VICEclient.isHandcuffed(source, {}, function(handcuffed)
    if handcuffed then
      return
    else
      VICEclient.isStaffedOn(source, {}, function(staffedOn)
        if (staffedOn and VICE.hasPermission(user_id, 'admin.tickets')) or VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'ukbf.armoury') then
          VICEclient.getNearestPlayer(source, { 5 }, function(nplayer)
            if nplayer then
              local nplayer_id = VICE.getUserId(nplayer)
              if (not VICE.hasPermission(nplayer_id, 'police.armoury') or VICE.hasPermission(nplayer_id, 'police.undercover') or VICE.hasPermission(user_id, 'ukbf.armoury')) then
                VICEclient.isHandcuffed(nplayer, {}, function(handcuffed)
                  if handcuffed then
                    TriggerClientEvent('VICE:uncuffAnim', source, nplayer, true)
                    TriggerClientEvent('VICE:unHandcuff', source, true)
                  else
                    TriggerClientEvent('VICE:arrestCriminal', nplayer, source)
                    TriggerClientEvent('VICE:arrestFromPolice', source)
                  end
                  TriggerClientEvent('VICE:toggleHandcuffs', nplayer, true)
                  TriggerClientEvent('VICE:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
                end)
              end
            else
              VICE.notify(source, lang.common.no_player_near())
            end
          end)
        end
      end)
    end
  end)
end)

function VICE.handcuffKeys(source)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.getInventoryItemAmount(user_id, 'handcuffkeys') >= 1 then
    VICEclient.getNearestPlayer(source, { 5 }, function(nplayer)
      if nplayer then
        local nplayer_id = VICE.getUserId(nplayer)
        VICEclient.isHandcuffed(nplayer, {}, function(handcuffed)
          if handcuffed then
            VICE.tryGetInventoryItem(user_id, 'handcuffkeys', 1)
            TriggerClientEvent('VICE:uncuffAnim', source, nplayer, false)
            TriggerClientEvent('VICE:unHandcuff', source, false)
            TriggerClientEvent('VICE:toggleHandcuffs', nplayer, false)
            TriggerClientEvent('VICE:playHandcuffSound', -1, GetEntityCoords(GetPlayerPed(source)))
          end
        end)
      else
        VICE.notify(source, lang.common.no_player_near())
      end
    end)
  end
end

local section60s = {}
RegisterCommand('s60', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.announce') then
    if args[1] and args[2] then
      local radius = tonumber(args[1])
      local duration = tonumber(args[2]) * 60
      local section60UUID = #section60s + 1
      section60s[section60UUID] = { radius = radius, duration = duration, uuid = section60UUID }
      TriggerClientEvent("VICE:addS60", -1, GetEntityCoords(GetPlayerPed(source)), radius, section60UUID)
    else
      VICE.notify(source, '~r~Invalid Arguments.')
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    for k, v in pairs(section60s) do
      if section60s[k].duration > 0 then
        section60s[k].duration = section60s[k].duration - 1
      else
        TriggerClientEvent('VICE:removeS60', -1, section60s[k].uuid)
      end
    end
    Citizen.Wait(1000)
  end
end)

RegisterCommand('handbook', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent('VICE:toggleHandbook', source)
  end
end)

local draggingPlayers = {}

RegisterServerEvent('VICE:dragPlayer')
AddEventHandler('VICE:dragPlayer', function(playersrc)
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id and (VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, "hmp.menu") or VICE.hasPermission(user_id, "ukbf.armoury")) then
    if playersrc then
      local nuser_id = VICE.getUserId(playersrc)
      if nuser_id then
        VICEclient.isHandcuffed(playersrc, {}, function(handcuffed)
          if handcuffed then
            if draggingPlayers[user_id] then
              TriggerClientEvent("VICE:undrag", playersrc, source)
              draggingPlayers[user_id] = nil
            else
              TriggerClientEvent("VICE:drag", playersrc, source)
              draggingPlayers[user_id] = playersrc
            end
          else
            VICE.notify(source, "~r~Player is not handcuffed.")
          end
        end)
      else
        VICE.notify(source, "~r~There is no player nearby")
      end
    else
      VICE.notify(source, "~r~There is no player nearby")
    end
  end
end)

RegisterServerEvent('VICE:putInVehicle')
AddEventHandler('VICE:putInVehicle', function(playersrc)
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id and VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, "ukbf.armoury") then
    if playersrc then
      VICEclient.isHandcuffed(playersrc, {}, function(handcuffed)  -- check handcuffed
        if handcuffed then
          VICEclient.putInNearestVehicleAsPassenger(playersrc, { 10 })
        else
          VICE.notify(source, lang.police.not_handcuffed())
        end
      end)
    end
  end
end)

RegisterServerEvent('VICE:ejectFromVehicle')
AddEventHandler('VICE:ejectFromVehicle', function()
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id and VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, 'ukbf.armoury') then
    VICEclient.getNearestPlayer(source, { 10 }, function(nplayer)
      local nuser_id = VICE.getUserId(nplayer)
      if nuser_id then
        VICEclient.isHandcuffed(nplayer, {}, function(handcuffed)  -- check handcuffed
          if handcuffed then
            VICEclient.ejectVehicle(nplayer, {})
          else
            VICE.notify(source, lang.police.not_handcuffed())
          end
        end)
      else
        VICE.notify(source, lang.common.no_player_near())
      end
    end)
  end
end)


RegisterServerEvent("VICE:Knockout")
AddEventHandler('VICE:Knockout', function()
  local source = source
  local user_id = VICE.getUserId(source)
  VICEclient.getNearestPlayer(source, { 2 }, function(nplayer)
    local nuser_id = VICE.getUserId(nplayer)
    if nuser_id then
      TriggerClientEvent('VICE:knockOut', nplayer)
      SetTimeout(30000, function()
        TriggerClientEvent('VICE:knockOutDisable', nplayer)
      end)
    end
  end)
end)

RegisterServerEvent("VICE:KnockoutNoAnim")
AddEventHandler('VICE:KnockoutNoAnim', function()
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasGroup(user_id, 'Founder') then
    VICEclient.getNearestPlayer(source, { 2 }, function(nplayer)
      local nuser_id = VICE.getUserId(nplayer)
      if nuser_id then
        TriggerClientEvent('VICE:knockOut', nplayer)
        SetTimeout(30000, function()
          TriggerClientEvent('VICE:knockOutDisable', nplayer)
        end)
      end
    end)
  end
end)

RegisterServerEvent("VICE:requestPlaceBagOnHead")
AddEventHandler('VICE:requestPlaceBagOnHead', function()
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.getInventoryItemAmount(user_id, 'Headbag') >= 1 then
    VICEclient.getNearestPlayer(source, { 10 }, function(nplayer)
      local nuser_id = VICE.getUserId(nplayer)
      if nuser_id then
        VICE.tryGetInventoryItem(user_id, 'Headbag', 1, true)
        TriggerClientEvent('VICE:placeHeadBag', nplayer)
      end
    end)
  end
end)

RegisterServerEvent('VICE:gunshotTest')
AddEventHandler('VICE:gunshotTest', function(playersrc)
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id and VICE.hasPermission(user_id, "police.armoury") or VICE.hasPermission(user_id, "ukbf.armoury") then
    if playersrc then
      VICEclient.hasRecentlyShotGun(playersrc, {}, function(shotagun)
        if shotagun then
          VICE.notify(source, "~r~Player has recently shot a gun.")
        else
          VICE.notify(source, "~r~Player has no gunshot residue on fingers.")
        end
      end)
    end
  end
end)

RegisterServerEvent('VICE:tryTackle')
AddEventHandler('VICE:tryTackle', function(id)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, "ukbf.armoury") or VICE.hasPermission(user_id, 'hmp.menu') or VICE.hasPermission(user_id, 'admin.tickets') then
    TriggerClientEvent('VICE:playTackle', source)
    TriggerClientEvent('VICE:getTackled', id, source)
  end
end)

RegisterCommand('drone', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasGroup(user_id, 'Drone') then
    TriggerClientEvent('toggleDrone', source)
  end
end)

RegisterCommand('trafficmenu', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, 'hmp.menu') or VICE.hasPermission(user_id, 'nhs.menu') then
    TriggerClientEvent('VICE:toggleTrafficMenu', source)
  end
end)

RegisterCommand('lfb', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'lfb.menu') then
    TriggerClientEvent('VICE:toggleLFBMenu', source)
  end
end)

RegisterCommand('lfbfire', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'lfb.menu') then
    TriggerClientEvent('VICE:startFireMenu', source)
  end
end)


RegisterServerEvent('VICE:startThrowSmokeGrenade')
AddEventHandler('VICE:startThrowSmokeGrenade', function(name)
  local source = source
  TriggerClientEvent('VICE:displaySmokeGrenade', -1, name, GetEntityCoords(GetPlayerPed(source)))
end)

RegisterCommand('breathalyse', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent('VICE:breathalyserCommand', source)
  end
end)

RegisterServerEvent('VICE:breathalyserRequest')
AddEventHandler('VICE:breathalyserRequest', function(temp)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent('VICE:beingBreathalysed', temp)
    TriggerClientEvent('VICE:breathTestResult', source, math.random(0, 100), VICE.getPlayerName(VICE.getUserId(temp)))
  end
end)

seizeBullets = {
  ['9mm Bullets'] = true,
  ['7.62mm Bullets'] = true,
  ['.357 Bullets'] = true,
  ['12 Gauge Bullets'] = true,
  ['.308 Sniper Rounds'] = true,
  ['5.56mm NATO'] = true,
}

RegisterServerEvent('VICE:seizeWeapons')
AddEventHandler('VICE:seizeWeapons', function(playerSrc)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, "ukbf.armoury") then
    VICEclient.isHandcuffed(playerSrc, {}, function(handcuffed)
      if handcuffed then
        RemoveAllPedWeapons(GetPlayerPed(playerSrc), true)
        local player_id = VICE.getUserId(playerSrc)
        local cdata = VICE.getUserDataTable(player_id)
        for a, b in pairs(cdata.inventory) do
          if string.find(a, 'wbody|') then
            c = a:gsub('wbody|', '')
            cdata.inventory[c] = b
            cdata.inventory[a] = nil
          end
        end
        for k, v in pairs(a.weapons) do
          if cdata.inventory[k] then
            if not v.policeWeapon then
              cdata.inventory[k] = nil
            end
          end
        end
        for c, d in pairs(cdata.inventory) do
          if seizeBullets[c] then
            cdata.inventory[c] = nil
          end
        end
        TriggerEvent('VICE:RefreshInventory', playerSrc)
        VICE.notify(source, 'Seized weapons.')
        VICE.notify(playerSrc, 'Your weapons have been seized.')
      end
    end)
  end
end)

seizeDrugs = {
  ['Weed leaf'] = true,
  ['Weed'] = true,
  ['Coca leaf'] = true,
  ['Cocaine'] = true,
  ['Opium Poppy'] = true,
  ['Heroin'] = true,
  ['Ephedra'] = true,
  ['Meth'] = true,
  ['Frogs legs'] = true,
  ['Lysergic Acid Amide'] = true,
  ['LSD'] = true,
}
RegisterServerEvent('VICE:seizeIllegals')
AddEventHandler('VICE:seizeIllegals', function(playerSrc)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, "ukbf.armoury") then
    local player_id = VICE.getUserId(playerSrc)
    local cdata = VICE.getUserDataTable(player_id)
    for a, b in pairs(cdata.inventory) do
      for c, d in pairs(seizeDrugs) do
        if a == c then
          cdata.inventory[a] = nil
        end
      end
    end
    TriggerEvent('VICE:RefreshInventory', playerSrc)
    VICE.notify(source, '~r~Seized illegals.')
    VICE.notify(playerSrc, '~r~Your illegals have been seized.')
  end
end)

RegisterServerEvent("VICE:newPanic")
AddEventHandler("VICE:newPanic", function(a, b)
  local source = source
  local user_id = VICE.getUserId(source)
  local currentradio = VICE.getCurrentRadio(source)
  if VICE.hasPermission(user_id, 'police.armoury') or VICE.hasPermission(user_id, "ukbf.armoury") or VICE.hasPermission(user_id, 'hmp.menu') or VICE.hasPermission(user_id, 'nhs.menu') or VICE.hasPermission(user_id, 'lfb.menu') or VICE.hasPermission(user_id, 'gang.whitelisted') then
    TriggerClientEvent("VICE:returnPanic", -1, nil, a, b, currentradio)
    VICE.sendDCLog(getPlayerFaction(user_id) .. '-panic', 'VICE Panic Logs',
      "> Player Name: **" ..
      VICE.getPlayerName(VICE.getUserId(source)) ..
      "**\n> Player TempID: **" .. source .. "**\n> Player PermID: **" .. user_id ..
      "**\n> Location: **" .. a.Location .. "**")
  end
end)

RegisterNetEvent("VICE:flashbangThrown")
AddEventHandler("VICE:flashbangThrown", function(coords)
  local src = source
  local user_id = VICE.getUserId(src)
  if VICE.hasPermission(user_id, 'police.armoury') then
    TriggerClientEvent("VICE:flashbangExplode", -1, coords)
  else
    VICE.ACBan(15,user_id,"VICE:flashbangExplode")

  end
end)

RegisterNetEvent("VICE:updateSpotlight")
AddEventHandler("VICE:updateSpotlight", function(a)
  local source = source
  TriggerClientEvent("VICE:updateSpotlight", -1, source, a)
end)

RegisterCommand('wc', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    VICEclient.getNearestPlayer(source, { 2 }, function(nplayer)
      if nplayer then
        VICEclient.getPoliceCallsign(source, {}, function(callsign)
          VICEclient.getPoliceRank(source, {}, function(rank)
            VICEclient.playAnim(source, { true, { { 'paper_1_rcm_alt1-9', 'player_one_dual-9', 1 } }, false })
            VICE.notifyPicture(nplayer, "polnotification", "notification",
              "~b~Callsign: ~w~" ..
              callsign .. "\n~b~Rank: ~w~" .. rank .. "\n~b~Name: ~w~" .. VICE.getPlayerName(VICE.getUserId(source)),
              "Metropolitan Police", "Warrant Card", false, nil)
            TriggerClientEvent('VICE:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)

RegisterCommand('wca', function(source, args)
  local source = source
  local user_id = VICE.getUserId(source)
  if VICE.hasPermission(user_id, 'police.armoury') then
    VICEclient.getNearestPlayer(source, { 2 }, function(nplayer)
      if nplayer then
        VICEclient.getPoliceCallsign(source, {}, function(callsign)
          VICEclient.getPoliceRank(source, {}, function(rank)
            VICEclient.playAnim(source, { true, { { 'paper_1_rcm_alt1-9', 'player_one_dual-9', 1 } }, false })
            VICE.notifyPicture(nplayer, "polnotification", "notification",
              "~b~Callsign: ~w~" .. callsign .. "\n~b~Rank: ~w~" .. rank, "Metropolitan Police", "Warrant Card", false,
              nil)
            TriggerClientEvent('VICE:flashWarrantCard', source)
          end)
        end)
      end
    end)
  end
end)
