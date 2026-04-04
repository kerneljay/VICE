local htmlEntities = module("util/server/htmlEntities")

local cfg = module("cfg/cfg_identity")
local lang = VICE.lang

local sanitizes = module("cfg/sanitizes")

-- this module describe the identity system

MySQL.createCommand("VICE/get_user_identity","SELECT * FROM vice_user_identities WHERE user_id = @user_id")
MySQL.createCommand("VICE/init_user_identity","INSERT IGNORE INTO vice_user_identities(user_id,registration,phone,firstname,name,age) VALUES(@user_id,@registration,@phone,@firstname,@name,@age)")
MySQL.createCommand("VICE/update_user_identity","UPDATE vice_user_identities SET firstname = @firstname, name = @name, age = @age, registration = @registration, phone = @phone WHERE user_id = @user_id")
MySQL.createCommand("VICE/get_userbyreg","SELECT user_id FROM vice_user_identities WHERE registration = @registration")
MySQL.createCommand("VICE/get_userbyphone","SELECT user_id FROM vice_user_identities WHERE phone = @phone")
MySQL.createCommand("VICE/update_user_phone","UPDATE vice_user_identities SET phone = @phone WHERE user_id = @user_id")



-- api

-- cbreturn user identity
function VICE.getUserIdentity(user_id, cbr)
    local task = Task(cbr)
    if cbr then 
        MySQL.query("VICE/get_user_identity", {user_id = user_id}, function(rows, affected)
            if #rows > 0 then 
              task({rows[1]})
            else 
               task({})
            end
        end)
    else 
        print('Mis usage detected! CBR Does not exist')
    end
end

-- cbreturn user_id by registration or nil
function VICE.getUserByRegistration(registration, cbr)
  local task = Task(cbr)

  MySQL.query("VICE/get_userbyreg", {registration = registration or ""}, function(rows, affected)
    if #rows > 0 then
      task({rows[1].user_id})
    else
      task()
    end
  end)
end

-- cbreturn user_id by phone or nil
function VICE.getUserByPhone(phone, cbr)
  local task = Task(cbr)

  MySQL.query("VICE/get_userbyphone", {phone = phone or ""}, function(rows, affected)
    if #rows > 0 then
      task({rows[1].user_id})
    else
      task()
    end
  end)
end

function VICE.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- cbreturn a unique registration number
function VICE.generateRegistrationNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate registration number
    local registration = VICE.generateStringNumber("DDDLLL")
    VICE.getUserByRegistration(registration, function(user_id)
      if user_id ~= nil then
        search() -- continue generation
      else
        task({registration})
      end
    end)
  end

  search()
end

-- cbreturn a unique phone number (0DDDDD, D => digit)
function VICE.generatePhoneNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate phone number
    local phone = VICE.generateStringNumber(cfg.phone_format)
    VICE.getUserByPhone(phone, function(user_id)
      if user_id ~= nil then
        search() -- continue generation
      else
        task({phone})
      end
    end)
  end

  search()
end

-- events, init user identity at connection
AddEventHandler("VICE:playerJoin",function(user_id,source,name,last_login)
  VICE.getUserIdentity(user_id, function(identity)
    if identity == nil then
      VICE.generateRegistrationNumber(function(registration)
        VICE.generatePhoneNumber(function(phone)
          MySQL.execute("VICE/init_user_identity", {
            user_id = user_id,
            registration = registration,
            phone = phone,
            firstname = cfg.random_first_names[math.random(1,#cfg.random_first_names)],
            name = cfg.random_last_names[math.random(1,#cfg.random_last_names)],
            age = math.random(25,40)
          })
        end)
      end)
    end
  end)
end)

RegisterNetEvent("VICE:getIdentity")
AddEventHandler("VICE:getIdentity", function()
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id ~= nil then
    VICE.getUserIdentity(user_id, function(identity)
      TriggerClientEvent('VICE:gotCurrentIdentity', source, identity['firstname'], identity['name'], identity['age'])
    end)
  end
end)

RegisterNetEvent("VICE:getNewIdentity")
AddEventHandler("VICE:getNewIdentity", function()
  local source = source
  local user_id = VICE.getUserId(source)
  if user_id ~= nil then
    VICE.prompt(source, 'First Name:', '', function(source,firstname)
      if firstname == '' then return end
      if string.len(firstname) >= 2 and string.len(firstname) < 50 then
        local firstname = sanitizeString(firstname, sanitizes.name[1], sanitizes.name[2])
       VICE.prompt(source, 'Last Name:', '', function(source, lastname)
          if lastname == '' then return end
          if string.len(lastname) >= 2 and string.len(lastname) < 50 then
            local lastname = sanitizeString(lastname, sanitizes.name[1], sanitizes.name[2])
            VICE.prompt(source, 'Age:', '', function(source,age)
              if age == '' then return end
              age = parseInt(age)
              if age >= 18 and age <= 150 then
                TriggerClientEvent('VICE:gotNewIdentity', source, firstname, lastname, age)
              else
                VICEclient.notify(source, {'Invalid age'})
              end
            end)
          else
            VICEclient.notify(source, {'Invalid Last Name'})
          end
        end)
      else
        VICEclient.notify(source, {'Invalid First Name'})
      end
    end)
  end
end)

MySQL.createCommand("VICE/set_identity","UPDATE vice_user_identities SET firstname = @firstname, name = @name, age = @age WHERE user_id = @user_id")


RegisterNetEvent("VICE:ChangeIdentity")
AddEventHandler("VICE:ChangeIdentity", function(first, second, age)
    local source = source
    local user_id = VICE.getUserId(source)
    if user_id ~= nil then
        if VICE.tryBankPayment(user_id,5000) then
          TriggerClientEvent("VICE:gotCurrentIdentity", source, first, second, age)
            MySQL.execute("VICE/set_identity", {user_id = user_id, firstname = first, name = second, age = age})
            VICEclient.notifyPicture(source,{"CHAR_FACEBOOK",1,"GOV.UK",false,"You have purchased a new identity!"})
            TriggerClientEvent("VICE:PlaySound", source, "playMoney")
        else
            VICEclient.notify(source,{"You don't have enough money!"})
        end
    end
end)


RegisterServerEvent("VICE:askId")
AddEventHandler("VICE:askId", function(nplayer)
  local player = source
  local playerid = VICE.getUserId(source)
  local nuser_id = VICE.getUserId(nplayer)
  if nuser_id ~= nil then
    VICEclient.notify(player,{'~g~Request sent.'})
    VICE.request(nplayer,"Do you want to give your ID card ?",15,function(nplayer,ok)
      if ok then
        VICE.getUserIdentity(nuser_id, function(identity)
          if identity then
            TriggerClientEvent('VICE:showIdentity', player, nplayer, true, identity.firstname, identity.name, '19/01/1990', identity.phone, '10/02/2015', '10/02/2025', {})
            TriggerClientEvent('VICE:setNameFields', player, identity.name, identity.firstname)
            VICE.request(player, "Hide the ID card.", 1000, function(player,ok)
              TriggerClientEvent('VICE:hideIdentity', player)
            end)
          end
        end)
      else
        VICEclient.notify(player,{"Request refused."})
      end
    end)
  else
    VICEclient.notify(player,{"No player near you."})
  end
end)

RegisterServerEvent("VICE:askIdPD")
AddEventHandler("VICE:askIdPD", function(nplayer)
  local player = source
  local playerid = VICE.getUserId(source)
  local nuser_id = VICE.getUserId(nplayer)
  if nuser_id ~= nil then
    VICEclient.notify(player,{'~g~Request sent.'})
    VICE.request(nplayer,"Do you want to give your ID card ?",15,function(nplayer,ok)
      if ok then
        VICE.getUserIdentity(nuser_id, function(identity)
          if identity then
            TriggerClientEvent('VICE:showIdentity', player, nplayer, true, identity.firstname, identity.name, '19/01/1990', identity.phone, '10/02/2015', '10/02/2025', {})
            TriggerClientEvent('VICE:setNameFields', player, identity.name, identity.firstname)
            VICE.request(player, "Hide the ID card.", 1000, function(player,ok)
              TriggerClientEvent('VICE:hideIdentity', player)
            end)
          end
        end)
      else
        VICEclient.notify(player,{"Request refused."})
      end
    end)
  else
    VICEclient.notify(player,{"No player near you."})
  end
end)

RegisterServerEvent("VICE:showMyIdentity", function()
  local source = source
  local user_id = VICE.getUserId(source)
  VICE.getUserIdentity(user_id, function(identity)
    if identity then
      TriggerClientEvent('VICE:showIdentity', source, source, true, identity.firstname, identity.name, '19/01/1990', identity.phone, '10/02/2015', '10/02/2025', {})
      TriggerClientEvent('VICE:setNameFields', source, identity.name, identity.firstname)
      VICE.request(source, "Hide the ID card.", 1000, function(player,ok)
        TriggerClientEvent('VICE:hideIdentity', source)
      end)
    end
  end)
end)