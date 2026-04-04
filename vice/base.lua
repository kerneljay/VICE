MySQL = module("modules/MySQL")

Proxy = module("lib/Proxy")
Tunnel = module("lib/Tunnel")
Lang = module("lib/Lang")
Debug = module("lib/Debug")

local config = module("cfg/base")
local version = module("version")


local verify_card = {
    ["type"] = "AdaptiveCard",
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"] = "1.3",
    ["backgroundImage"] = {
        ["url"] =
        "https://cdn.discordapp.com/attachments/1257756119347101807/1265033442576564325/BANNER.png?ex=66a009b3&is=669eb833&hm=191c7ff46f333f8350b22a9c8c80f5dd1178074267203f4c7eb2bbcc3abb7d90&",
    },
    ["body"] = {
        {
            ["type"] = "TextBlock",
            ["text"] =
            "In order to connect to vice you must be in our discord and verify your account, please follow the instructions below",
            ["wrap"] = true,
            ["weight"] = "Bolder"
        },
        {
            ["type"] = "Container",
            ["items"] = {
                {
                    ["type"] = "TextBlock",
                    ["text"] = "1. Join the vice discord (https://discord.gg/UTzM4kcCjG)",
                    ["wrap"] = true,
                },
                {
                    ["type"] = "TextBlock",
                    ["text"] = "2. In the #verify channel, type the following command:",
                    ["wrap"] = true,
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "Attention",
                    ["text"] = "3. !verify NULL",
                    ["wrap"] = true,
                }
            }
        },
        {
            ["type"] = "ActionSet",
            ["actions"] = {
                {
                    ["type"] = "Action.Submit",
                    ["title"] = "Enter vice",
                    ["id"] = "attempt_connection"
                }
            }
        },
    }
}

Debug.active = config.debug
vice = {}
Proxy.addInterface("vice", vice)

tvice = {}
Tunnel.bindInterface("vice", tvice) -- listening for client tunnel

-- load language
local dict = module("cfg/lang/" .. config.lang) or {}
vice.lang = Lang.new(dict)

-- init
viceclient = Tunnel.getInterface("vice", "vice") -- server -> client tunnel

vice.users = {}                                   -- will store logged users (id) by first identifier
vice.rusers = {}                                  -- store the opposite of users
vice.user_tables = {}                             -- user data tables (logger storage, saved to database)
vice.user_tmp_tables = {}                         -- user tmp data tables (logger storage, not saved)
vice.user_sources = {}                            -- user sources
-- queries
Citizen.CreateThread(function()
    Wait(1000) -- Wait for GHMatti to Initialize
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_users(
    id INTEGER AUTO_INCREMENT,
    last_login VARCHAR(100),
    username VARCHAR(100),
    whitelisted BOOLEAN,
    banned BOOLEAN,
    bantime VARCHAR(100) NOT NULL DEFAULT "",
    banreason VARCHAR(1000) NOT NULL DEFAULT "",
    banadmin VARCHAR(100) NOT NULL DEFAULT "",
    baninfo VARCHAR(2000) NOT NULL DEFAULT "",
    last_kit_usage INT NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(id)
    ) AUTO_INCREMENT = 1;
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_ids (
    identifier VARCHAR(100) NOT NULL,
    user_id INTEGER,
    banned BOOLEAN,
    CONSTRAINT pk_user_ids PRIMARY KEY(identifier)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_tokens (
    token VARCHAR(200),
    user_id INTEGER,
    banned BOOLEAN  NOT NULL DEFAULT 0,
    CONSTRAINT pk_user_tokens PRIMARY KEY(token)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_data(
    user_id INTEGER,
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_user_data PRIMARY KEY(user_id,dkey),
    CONSTRAINT fk_user_data_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_moneys(
    user_id INTEGER,
    wallet bigint,
    bank bigint,
    offshore bigint,
    dirtycash bigint,
    CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
    CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_srv_data(
    dkey VARCHAR(100),
    dvalue TEXT,
    CONSTRAINT pk_srv_data PRIMARY KEY(dkey)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_vehicles(
    user_id INTEGER,
    vehicle VARCHAR(100),
    vehicle_plate varchar(255) NOT NULL,
    rented BOOLEAN NOT NULL DEFAULT 0,
    rentedid varchar(200) NOT NULL DEFAULT '',
    rentedtime varchar(2048) NOT NULL DEFAULT '',
    locked BOOLEAN NOT NULL DEFAULT 0,
    fuel_level FLOAT NOT NULL DEFAULT 100,
    impounded BOOLEAN NOT NULL DEFAULT 0,
    impound_info varchar(2048) NOT NULL DEFAULT '',
    impound_time VARCHAR(100) NOT NULL DEFAULT '',
    CONSTRAINT pk_user_vehicles PRIMARY KEY(user_id,vehicle),
    CONSTRAINT fk_user_vehicles_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_identities(
    user_id INTEGER,
    registration VARCHAR(100),
    phone VARCHAR(100),
    firstname VARCHAR(100),
    name VARCHAR(100),
    age INTEGER,
    CONSTRAINT pk_user_identities PRIMARY KEY(user_id),
    CONSTRAINT fk_user_identities_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE,
    INDEX(registration),
    INDEX(phone)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_warnings (
    warning_id INT AUTO_INCREMENT,
    user_id INT,
    warning_type VARCHAR(25),
    duration INT,
    admin VARCHAR(100),
    warning_date DATE,
    reason VARCHAR(2000),
    PRIMARY KEY (warning_id)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_gangs (
    gangname VARCHAR(255) NULL DEFAULT NULL,
    gangmembers VARCHAR(3000) NULL DEFAULT NULL,
    funds BIGINT NULL DEFAULT NULL,
    logs VARCHAR(3000) NULL DEFAULT NULL,
    lockedfunds BOOLEAN DEFAULT FALSE,
    webhook VARCHAR(3000) NULL DEFAULT NULL,
    gangfit VARCHAR(3000) NULL DEFAULT NULL,
    PRIMARY KEY (gangname)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_notes (
    user_id INT,
    info VARCHAR(500) NULL DEFAULT NULL,
    PRIMARY KEY (user_id)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_homes(
    user_id INTEGER,
    home VARCHAR(100),
    number INTEGER,
    rented BOOLEAN NOT NULL DEFAULT 0,
    rentedid varchar(200) NOT NULL DEFAULT '',
    rentedtime varchar(2048) NOT NULL DEFAULT '',
    CONSTRAINT pk_user_homes PRIMARY KEY(home),
    CONSTRAINT fk_user_homes_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE,
    UNIQUE(home,number)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_bans_offenses(
    UserID INTEGER AUTO_INCREMENT,
    Rules TEXT NULL DEFAULT NULL,
    points INT(10) NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(UserID)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_dvsa(
    user_id INT(11),
    licence VARCHAR(100) NULL DEFAULT NULL,
    testsaves VARCHAR(1000) NULL DEFAULT NULL,
    points VARCHAR(500) NULL DEFAULT NULL,
    id VARCHAR(500) NULL DEFAULT NULL,
    datelicence VARCHAR(500) NULL DEFAULT NULL,
    penalties VARCHAR(500) NULL DEFAULT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_subscriptions (
    user_id INT(11),
    plathours FLOAT(10) NULL DEFAULT NULL,
    plushours FLOAT(10) NULL DEFAULT NULL,
    last_used VARCHAR(100) NOT NULL DEFAULT "",
    redeemed INT DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY (user_id)
    );
    ]]);
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_stores (
    code VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
    item VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
    user_id INT(11) NULL DEFAULT NULL,
    seller_id INT(11) NULL DEFAULT NULL,
    date VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
    PRIMARY KEY (code) USING BTREE
    )
    COLLATE='utf8mb4_general_ci'
    ENGINE=InnoDB
    ;
    ]]);
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_casino_chips(
    user_id INT(11),
    chips bigint NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_verification(
    user_id INT(11),
    code VARCHAR(100) NULL DEFAULT NULL,
    discord_id VARCHAR(100) NULL DEFAULT NULL,
    verified TINYINT NULL DEFAULT NULL,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_users_contacts (
    id int(11) NOT NULL AUTO_INCREMENT,
    identifier varchar(60) CHARACTER SET utf8mb4 DEFAULT NULL,
    number varchar(10) CHARACTER SET utf8mb4 DEFAULT NULL,
    display varchar(64) CHARACTER SET utf8mb4 NOT NULL DEFAULT '-1',
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_messages (
    id int(11) NOT NULL AUTO_INCREMENT,
    transmitter varchar(10) NOT NULL,
    receiver varchar(10) NOT NULL,
    message varchar(255) NOT NULL DEFAULT '0',
    time timestamp NOT NULL DEFAULT current_timestamp(),
    isRead int(11) NOT NULL DEFAULT 0,
    owner int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_calls (
    id int(11) NOT NULL AUTO_INCREMENT,
    owner varchar(10) NOT NULL COMMENT 'Num such owner',
    num varchar(10) NOT NULL COMMENT 'Reference number of the contact',
    incoming int(11) NOT NULL COMMENT 'Defined if we are at the origin of the calls',
    time timestamp NOT NULL DEFAULT current_timestamp(),
    accepts int(11) NOT NULL COMMENT 'Calls accept or not',
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS phone_app_chat (
    id int(11) NOT NULL AUTO_INCREMENT,
    channel varchar(20) NOT NULL,
    message varchar(255) NOT NULL,
    time timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS global_globals (
    id int(11) NOT NULL AUTO_INCREMENT,
    authorId int(11) NOT NULL,
    realUser varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
    message varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
    time timestamp NOT NULL DEFAULT current_timestamp(),
    likes int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY FK_global_globals_global_accounts (authorId),
    CONSTRAINT FK_global_globals_global_accounts FOREIGN KEY (authorId) REFERENCES global_accounts (id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS global_likes (
    id int(11) NOT NULL AUTO_INCREMENT,
    authorId int(11) DEFAULT NULL,
    tweetId int(11) DEFAULT NULL,
    PRIMARY KEY (id),
    KEY FK_global_likes_global_accounts (authorId),
    KEY FK_global_likes_global_globals (tweetId),
    CONSTRAINT FK_global_likes_global_accounts FOREIGN KEY (authorId) REFERENCES global_accounts (id),
    CONSTRAINT FK_global_likes_global_globals FOREIGN KEY (tweetId) REFERENCES global_globals (id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS global_accounts (
    id int(11) NOT NULL AUTO_INCREMENT,
    username varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '0',
    password varchar(50) COLLATE utf8mb4_bin NOT NULL DEFAULT '0',
    avatar_url varchar(255) COLLATE utf8mb4_bin DEFAULT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY username (username)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_community_pot (
    vice VARCHAR(65) NOT NULL,
    value BIGINT(11) NOT NULL,
    PRIMARY KEY (vice)
    );
    ]])
    MySQL.SingleQuery([[
    INSERT IGNORE INTO vice_community_pot (value) VALUES (1)
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_quests (
    user_id INT(11),
    quests_completed INT(11) NOT NULL DEFAULT 0,
    reward_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_weapon_whitelists (
    user_id INT(11),
    weapon_info varchar(2048) DEFAULT '{}',
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_weapon_codes (
    user_id INT(11),
    spawncode varchar(2048) NOT NULL DEFAULT '',
    weapon_code int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (weapon_code)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_prison (
    user_id INT(11),
    prison_time INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_staff_tickets (
    user_id INT(11),
    ticket_count INT(11) NOT NULL DEFAULT 0,
    username VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_daily_rewards (
    user_id INT(11),
    last_reward INT(11) NOT NULL DEFAULT 0,
    streak INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_police_hours (
    user_id INT(11),
    weekly_hours FLOAT(10) NOT NULL DEFAULT 0,
    total_hours FLOAT(10) NOT NULL DEFAULT 0,
    username VARCHAR(100) NOT NULL,
    last_clocked_date VARCHAR(100) NOT NULL,
    last_clocked_rank VARCHAR(100) NOT NULL,
    total_players_fined INT(11) NOT NULL DEFAULT 0,
    total_players_jailed INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS bantime varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS banreason varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS banadmin varchar(100) NOT NULL DEFAULT ''; ")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rented BOOLEAN NOT NULL DEFAULT 0;")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rentedid varchar(200) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rentedtime varchar(2048) NOT NULL DEFAULT '';")
    MySQL.createCommand("vicels/create_modifications_column",
        "alter table vice_user_vehicles add if not exists modifications text not null")
    MySQL.createCommand("vicels/update_vehicle_modifications",
        "update vice_user_vehicles set modifications = @modifications where user_id = @user_id and vehicle = @vehicle")
    MySQL.createCommand("vicels/get_vehicle_modifications",
        "select modifications, vehicle_plate from vice_user_vehicles where user_id = @user_id and vehicle = @vehicle")
    MySQL.execute("vicels/create_modifications_column")
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_playerdealership(
        listing_id INT AUTO_INCREMENT,
        vehicle_id VARCHAR(50) NOT NULL, -- Store vehicle spawn code, e.g. '4x4mini'
        owner_user_id INT NOT NULL,
        price BIGINT NOT NULL,
        list_time INT NOT NULL,
        status VARCHAR(50) NOT NULL DEFAULT 'for sale', -- e.g., 'for sale', 'sold', 'canceled'
        dealership_location VARCHAR(100), -- Optional: to store which dealership location it's listed at
        buyer_user_id INT NULL DEFAULT NULL, -- User ID of the buyer after sale
        sale_time INT NULL DEFAULT NULL, -- Timestamp of the sale
        PRIMARY KEY (listing_id),
        FOREIGN KEY (owner_user_id) REFERENCES vice_users(id) ON DELETE CASCADE
        -- No FOREIGN KEY for vehicle_id, as it's a spawn code string
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_dealership_vehicle_mods (
        id INT AUTO_INCREMENT,
        listing_id INT NOT NULL,
        savekey VARCHAR(350),
        `mod` VARCHAR(350),
        enabled BOOLEAN NOT NULL DEFAULT 1,
        PRIMARY KEY (id),
        FOREIGN KEY (listing_id) REFERENCES vice_playerdealership(listing_id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_points(
    user_id INTEGER PRIMARY KEY,
    points BIGINT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_points_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
    );
    ]])
    -- print("[vice] ^2Base tables initialised.^0")
end)

MySQL.createCommand("vice/create_user", "INSERT INTO vice_users(whitelisted,banned) VALUES(false,false)")
MySQL.createCommand("vice/add_identifier", "INSERT INTO vice_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
MySQL.createCommand("vice/userid_byidentifier", "SELECT user_id FROM vice_user_ids WHERE identifier = @identifier")
MySQL.createCommand("vice/identifier_all", "SELECT * FROM vice_user_ids WHERE identifier = @identifier")
MySQL.createCommand("vice/select_identifier_byid_all", "SELECT * FROM vice_user_ids WHERE user_id = @id")

MySQL.createCommand("vice/set_userdata",
    "REPLACE INTO vice_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
MySQL.createCommand("vice/get_userdata", "SELECT dvalue FROM vice_user_data WHERE user_id = @user_id AND dkey = @key")

MySQL.createCommand("vice/set_srvdata", "REPLACE INTO vice_srv_data(dkey,dvalue) VALUES(@key,@value)")
MySQL.createCommand("vice/get_srvdata", "SELECT dvalue FROM vice_srv_data WHERE dkey = @key")

MySQL.createCommand("vice/get_banned", "SELECT banned FROM vice_users WHERE id = @user_id")
MySQL.createCommand("vice/set_banned",
    "UPDATE vice_users SET banned = @banned, bantime = @bantime,  banreason = @banreason,  banadmin = @banadmin, baninfo = @baninfo WHERE id = @user_id")
MySQL.createCommand("vice/set_identifierbanned", "UPDATE vice_user_ids SET banned = @banned WHERE identifier = @iden")
MySQL.createCommand("vice/getbanreasontime", "SELECT * FROM vice_users WHERE id = @user_id")

MySQL.createCommand("vice/get_whitelisted", "SELECT whitelisted FROM vice_users WHERE id = @user_id")
MySQL.createCommand("vice/set_whitelisted", "UPDATE vice_users SET whitelisted = @whitelisted WHERE id = @user_id")
MySQL.createCommand("vice/set_last_login", "UPDATE vice_users SET last_login = @last_login WHERE id = @user_id")
MySQL.createCommand("vice/get_last_login", "SELECT last_login FROM vice_users WHERE id = @user_id")

--Token Banning
MySQL.createCommand("vice/add_token", "INSERT INTO vice_user_tokens(token,user_id) VALUES(@token,@user_id)")
MySQL.createCommand("vice/check_token", "SELECT user_id, banned FROM vice_user_tokens WHERE token = @token")
MySQL.createCommand("vice/check_token_userid", "SELECT token FROM vice_user_tokens WHERE user_id = @id")
MySQL.createCommand("vice/ban_token", "UPDATE vice_user_tokens SET banned = @banned WHERE token = @token")
--Token Banning

-- removing anticheat ban entry
MySQL.createCommand("ac/delete_ban", "DELETE FROM vice_anticheat WHERE @user_id = user_id")


-- init tables


-- identification system

function vice.getUserIdByIdentifiers(ids, cbr)
    local task = Task(cbr)
    if ids ~= nil and #ids then
        local i = 0
        local function search()
            i = i + 1
            if i <= #ids then
                if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then -- ignore ip identifier
                    MySQL.query("vice/userid_byidentifier", { identifier = ids[i] }, function(rows, affected)
                        if #rows > 0 then                                                      -- found
                            task({ rows[1].user_id })
                        else                                                                   -- not found
                            search()
                        end
                    end)
                else
                    search()
                end
            else -- no ids found, create user
                MySQL.query("vice/create_user", {}, function(rows, affected)
                    if rows.affectedRows > 0 then
                        local user_id = rows.insertId
                        -- add identifiers
                        for l, w in pairs(ids) do
                            if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then -- ignore ip identifier
                                MySQL.execute("vice/add_identifier", { user_id = user_id, identifier = w })
                            end
                        end
                        for k, v in pairs(vice.getUsers()) do
                            viceclient.notify(v, { '~g~You have received £250,000 as someone new has joined the server.' })
                            vice.giveBankMoney(k, 250000)
                        end
                        task({ user_id })
                    else
                        task()
                    end
                end)
            end
        end
        search()
    else
        task()
    end
end

-- return identification string for the source (used for non vice identifications, for rejected players)
function vice.getSourceIdKey(source)
    local ids = GetPlayerIdentifiers(source)
    local idk = "idk_"
    for k, v in pairs(ids) do
        idk = idk .. v
    end
    return idk
end

--- sql

function vice.ReLoadChar(source)
    local ids = GetPlayerIdentifiers(source)
    vice.getUserIdByIdentifiers(ids, function(user_id)
        if user_id ~= nil then
            vice.StoreTokens(source, user_id)
            vice.GetDiscordName(user_id)
            Wait(500)
            local name = vice.getPlayerName(user_id)
            if vice.rusers[user_id] == nil then -- not present on the server, init
                vice.users[ids[1]] = user_id
                vice.rusers[user_id] = ids[1]
                vice.user_tables[user_id] = {}
                vice.user_tmp_tables[user_id] = {}
                vice.user_sources[user_id] = source
                vice.getUData(user_id, "vice:datatable", function(sdata)
                    local data = json.decode(sdata)
                    if type(data) == "table" then vice.user_tables[user_id] = data end
                    local tmpdata = vice.getUserTmpTable(user_id)
                    vice.getLastLogin(user_id, function(last_login)
                        tmpdata.last_login = last_login or ""
                        tmpdata.spawns = 0
                        local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                        MySQL.execute("vice/set_last_login", { user_id = user_id, last_login = last_login_stamp })
                        print("[vice] " .. name .. " joined (Perm ID = " .. user_id .. ")")
                        TriggerEvent("vice:playerJoin", user_id, source, name, tmpdata.last_login)
                        TriggerClientEvent("vice:CheckIdRegister", source)
                    end)
                end)
            else -- already connected
                print("[vice] " .. name .. " re-joined (Perm ID = " .. user_id .. ")")
                TriggerEvent("vice:playerRejoin", user_id, source, name)
                TriggerClientEvent("vice:CheckIdRegister", source)
                local tmpdata = vice.getUserTmpTable(user_id)
                tmpdata.spawns = 0
            end
        end
    end)
end

exports("vicebot", function(method_name, params, cb)
    if cb then
        cb(vice[method_name](table.unpack(params)))
    else
        return vice[method_name](table.unpack(params))
    end
end)

RegisterNetEvent("vice:CheckID")
AddEventHandler("vice:CheckID", function()
    local source = source
    local user_id = vice.getUserId(source)
    if not user_id then
        vice.ReLoadChar(source)
    end
end)

function vice.isBanned(user_id, cbr)
    local task = Task(cbr, { false })
    MySQL.query("vice/get_banned", { user_id = user_id }, function(rows, affected)
        if #rows > 0 then
            task({ rows[1].banned })
        else
            task()
        end
    end)
end

function vice.isWhitelisted(user_id, cbr)
    local task = Task(cbr, { false })
    MySQL.query("vice/get_whitelisted", { user_id = user_id }, function(rows, affected)
        if #rows > 0 then
            task({ rows[1].whitelisted })
        else
            task()
        end
    end)
end

function vice.setWhitelisted(user_id, whitelisted)
    MySQL.execute("vice/set_whitelisted", { user_id = user_id, whitelisted = whitelisted })
end

function vice.getLastLogin(user_id, cbr)
    local task = Task(cbr, { "" })
    MySQL.query("vice/get_last_login", { user_id = user_id }, function(rows, affected)
        if #rows > 0 then
            task({ rows[1].last_login })
        else
            task()
        end
    end)
end

function vice.fetchBanReasonTime(user_id, cbr)
    MySQL.query("vice/getbanreasontime", { user_id = user_id }, function(rows, affected)
        if #rows > 0 then
            cbr(rows[1].bantime, rows[1].banreason, rows[1].banadmin)
        end
    end)
end

function vice.setUData(user_id, key, value)
    MySQL.execute("vice/set_userdata", { user_id = user_id, key = key, value = value })
end

function vice.getUData(user_id, key, cbr)
    local task = Task(cbr, { "" })
    MySQL.query("vice/get_userdata", { user_id = user_id, key = key }, function(rows, affected)
        if #rows > 0 then
            task({ rows[1].dvalue })
        else
            task()
        end
    end)
end

function vice.setSData(key, value)
    MySQL.execute("vice/set_srvdata", { key = key, value = value })
end

function vice.getSData(key, cbr)
    local task = Task(cbr, { "" })
    MySQL.query("vice/get_srvdata", { key = key }, function(rows, affected)
        if rows and #rows > 0 then
            task({ rows[1].dvalue })
        else
            task()
        end
    end)
end

-- return user data table for vice internal persistant connected user storage
function vice.getUserDataTable(user_id)
    return vice.user_tables[user_id]
end

function vice.getUserTmpTable(user_id)
    return vice.user_tmp_tables[user_id]
end

function vice.isConnected(user_id)
    return vice.rusers[user_id] ~= nil
end

function vice.isFirstSpawn(user_id)
    local tmp = vice.getUserTmpTable(user_id)
    return tmp and tmp.spawns == 1
end

function vice.getUserId(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return vice.users[ids[1]]
        end
    end
    return nil
end

-- return map of user_id -> player source
function vice.getUsers()
    local users = {}
    for k, v in pairs(vice.user_sources) do
        users[k] = v
    end
    return users
end

-- return source or nil
function vice.getUserSource(user_id)
    return vice.user_sources[user_id]
end

function vice.IdentifierBanCheck(source, user_id, cb)
    for i, v in pairs(GetPlayerIdentifiers(source)) do
        MySQL.query('vice/identifier_all', { identifier = v }, function(rows)
            for i = 1, #rows do
                if rows[i].banned then
                    if user_id ~= rows[i].user_id then
                        cb(true, rows[i].user_id)
                    end
                end
            end
        end)
    end
end

function vice.BanIdentifiers(user_id, value)
    MySQL.query('vice/select_identifier_byid_all', { id = user_id }, function(rows)
        for i = 1, #rows do
            MySQL.execute("vice/set_identifierbanned", { banned = value, iden = rows[i].identifier })
        end
    end)
end

function calculateTimeRemaining(expireTime)
    local datetime = ''
    local expiry = os.date("%d/%m/%Y at %H:%M", tonumber(expireTime))
    local hoursLeft = ((tonumber(expireTime) - os.time())) / 3600
    local minutesLeft = nil
    if hoursLeft < 1 then
        minutesLeft = hoursLeft * 60
        minutesLeft = string.format("%." .. (0) .. "f", minutesLeft)
        datetime = minutesLeft .. " mins"
        return datetime
    else
        hoursLeft = string.format("%." .. (0) .. "f", hoursLeft)
        datetime = hoursLeft .. " hours"
        return datetime
    end
    return datetime
end

function vice.setBanned(user_id, banned, time, reason, admin, baninfo)
    if banned then
        print("setBanned called with user_id:", user_id, "banned:", banned, "time:", time, "reason:", reason, "admin:",
            admin, "baninfo:", baninfo)
        MySQL.execute("vice/set_banned",
            { user_id = user_id, banned = banned, bantime = time, banreason = reason, banadmin = admin, baninfo = baninfo })
        vice.BanIdentifiers(user_id, true)
        vice.BanTokens(user_id, true)
    else
        MySQL.execute("vice/set_banned",
            { user_id = user_id, banned = banned, bantime = "", banreason = "", banadmin = "", baninfo = "" })
        vice.BanIdentifiers(user_id, false)
        vice.BanTokens(user_id, false)
        MySQL.execute("ac/delete_ban", { user_id = user_id })
    end
end

function vice.ban(adminsource, permid, time, reason, baninfo)
    local adminPermID = vice.getUserId(adminsource)
    local getBannedPlayerSrc = vice.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then
        if tonumber(time) then
            vice.setBanned(permid, true, time, reason, vice.getPlayerName(adminPermID), baninfo)
            vice.kick(getBannedPlayerSrc,
                "[vice] Ban expires in: " ..
                calculateTimeRemaining(time) ..
                "\nYour ID is: " .. permid .. "\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
        else
            vice.setBanned(permid, true, "perm", reason, vice.getPlayerName(adminPermID), baninfo)
            vice.kick(getBannedPlayerSrc,
                "[vice] Permanent Ban\nYour ID is: " .. permid ..
                "\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
        end
        viceclient.notify(adminsource, { "~g~Success banned! User PermID: " .. permid })
    else
        if tonumber(time) then
            vice.setBanned(permid, true, time, reason, vice.getPlayerName(adminPermID), baninfo)
        else
            vice.setBanned(permid, true, "perm", reason, vice.getPlayerName(adminPermID), baninfo)
        end
        viceclient.notify(adminsource, { "~g~Success banned! User PermID: " .. permid })
    end
end

function vice.banConsole(permid, time, reason)
    local adminPermID = "vice"
    local getBannedPlayerSrc = vice.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then
        if tonumber(time) then
            local banTime = os.time()
            banTime = banTime + (60 * 60 * tonumber(time))
            vice.setBanned(permid, true, banTime, reason, adminPermID)
            vice.kick(getBannedPlayerSrc,
                "[vice] Ban expires in " ..
                calculateTimeRemaining(banTime) ..
                "\nYour ID is: " .. permid .. "\nReason: " .. reason .. "\nBanned by vice \nAppeal @ https://discord.gg/UTzM4kcCjG")
        else
            vice.setBanned(permid, true, "perm", reason, adminPermID)
            vice.kick(getBannedPlayerSrc,
                "[vice] Permanent Ban\nYour ID is: " ..
                permid .. "\nReason: " .. reason .. "\nBanned by vice \nAppeal @ https://discord.gg/UTzM4kcCjG")
        end
        print("Successfully banned Perm ID: " .. permid)
    else
        if tonumber(time) then
            local banTime = os.time()
            banTime = banTime + (60 * 60 * tonumber(time))
            vice.setBanned(permid, true, banTime, reason, adminPermID)
        else
            vice.setBanned(permid, true, "perm", reason, adminPermID)
        end
        print("Successfully banned Perm ID: " .. permid)
    end
end

function vice.banDiscord(permid, time, reason, adminPermID)
    local getBannedPlayerSrc = vice.getUserSource(tonumber(permid))
    if tonumber(time) then
        local banTime = os.time()
        banTime = banTime + (60 * 60 * tonumber(time))
        vice.setBanned(permid, true, banTime, reason, adminPermID)
        if getBannedPlayerSrc then
            vice.kick(getBannedPlayerSrc,
                "[vice] Ban expires in " ..
                calculateTimeRemaining(banTime) ..
                "\nYour ID is: " .. permid .. "\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
        end
    else
        vice.setBanned(permid, true, "perm", reason, adminPermID)
        if getBannedPlayerSrc then
            vice.kick(getBannedPlayerSrc,
                "[vice] Permanent Ban\nYour ID is: " .. permid ..
                "\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
        end
    end
end

-- To use token banning you need the latest artifacts.
function vice.StoreTokens(source, user_id)
    if GetNumPlayerTokens then
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            MySQL.query("vice/check_token", { token = token }, function(rows)
                if token and rows and #rows <= 0 then
                    MySQL.execute("vice/add_token", { token = token, user_id = user_id })
                end
            end)
        end
    end
end

function vice.CheckTokens(source, user_id)
    if GetNumPlayerTokens then
        local banned = false;
        local numtokens = GetNumPlayerTokens(source)
        for i = 1, numtokens do
            local token = GetPlayerToken(source, i)
            local rows = MySQL.asyncQuery("vice/check_token", { token = token, user_id = user_id })
            if #rows > 0 then
                if rows[1].banned then
                    return rows[1].banned, rows[1].user_id
                end
            end
        end
    else
        return false;
    end
end

function vice.BanTokens(user_id, banned)
    if GetNumPlayerTokens then
        MySQL.query("vice/check_token_userid", { id = user_id }, function(id)
            for i = 1, #id do
                MySQL.execute("vice/ban_token", { token = id[i].token, banned = banned })
            end
        end)
    end
end

function vice.kick(source, reason)
    DropPlayer(source, reason)
end

-- tasks

function task_save_datatables()
    TriggerEvent("vice:save")
    Debug.pbegin("vice save datatables")
    for k, v in pairs(vice.user_tables) do
        vice.setUData(k, "vice:datatable", json.encode(v))
    end
    Debug.pend()
    SetTimeout(config.save_interval * 1000, task_save_datatables)
end

task_save_datatables()

-- handlers

AddEventHandler("playerConnecting", function(name, setMessage, deferrals)
    deferrals.defer()
    local source = source
    Debug.pbegin("playerConnecting")
    local ids = GetPlayerIdentifiers(source)
    if ids ~= nil and #ids > 0 then
        deferrals.update("[vice] Checking identifiers...")
        vice.getUserIdByIdentifiers(ids, function(user_id)
            local numtokens = GetNumPlayerTokens(source)
            if numtokens == 0 then
                deferrals.done("[vice] Permanent Ban\nYour ID is: " ..
                user_id .. "\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG")
                tvice.sendWebhook('ban-evaders', 'vice Ban Evade Logs',
                    "> Player Name: **" ..
                    name .. "**\n> Player Current Perm ID: **" ..
                    user_id .. "**\n> Player Token Amount: **" .. numtokens .. "**")
                return
            end
            vice.IdentifierBanCheck(source, user_id, function(status, id, bannedIdentifier)
                if status then
                    deferrals.done("[vice] Permanent Ban\nYour ID is: " ..
                    user_id .. "\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG")
                    tvice.sendWebhook('ban-evaders', 'vice Ban Evade Logs',
                        "> Player Name: **" ..
                        name ..
                        "**\n> Player Current Perm ID: **" ..
                        user_id ..
                        "**\n> Player Banned PermID: **" ..
                        id .. "**\n> Player Banned Identifier: **" .. bannedIdentifier .. "**")
                    return
                end
            end)
            if user_id ~= nil then -- check user validity
                deferrals.update("[vice] Fetching Tokens...")
                vice.StoreTokens(source, user_id)
                deferrals.update("[vice] Checking banned...")
                vice.isBanned(user_id, function(banned)
                    if not banned then
                        deferrals.update("[vice] Checking whitelisted...")
                        vice.isWhitelisted(user_id, function(whitelisted)
                            if not config.whitelist or whitelisted then
                                Debug.pbegin("playerConnecting_delayed")
                                if vice.rusers[user_id] == nil then -- not present on the server, init
                                    ::try_verify::
                                    local verified = exports["ghmattimysql"]:executeSync(
                                    "SELECT * FROM vice_verification WHERE user_id = @user_id", { user_id = user_id })
                                    if #verified > 0 then
                                        if verified[1]["verified"] == 0 then
                                            local code = nil
                                            local data_code = exports["ghmattimysql"]:executeSync(
                                            "SELECT * FROM vice_verification WHERE user_id = @user_id",
                                                { user_id = user_id })
                                            code = data_code[1]["code"]
                                            if code == nil then
                                                code = math.random(100000, 999999)
                                            end
                                            ::regen_code::
                                            local checkCode = exports["ghmattimysql"]:executeSync(
                                            "SELECT * FROM vice_verification WHERE code = @code", { code = code })
                                            if checkCode ~= nil then
                                                if #checkCode > 0 then
                                                    code = math.random(100000, 999999)
                                                    goto regen_code
                                                end
                                            end
                                            exports["ghmattimysql"]:executeSync(
                                            "UPDATE vice_verification SET code = @code WHERE user_id = @user_id",
                                                { user_id = user_id, code = code })
                                            local function show_auth_card(code, deferrals, callback)
                                                verify_card["body"][2]["items"][3]["text"] = "3. !verify " .. code
                                                deferrals.presentCard(verify_card, callback)
                                            end
                                            local function check_verified()
                                                local data_verified = exports["ghmattimysql"]:executeSync(
                                                "SELECT * FROM vice_verification WHERE user_id = @user_id",
                                                    { user_id = user_id })
                                                local verified_code = data_verified[1]["verified"]
                                                if verified_code == true then
                                                    if vice.CheckTokens(source, user_id) then
                                                        deferrals.done("\n[vice] Permanent Ban\nYour ID is: " ..
                                                        user_id ..
                                                        "\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG")
                                                    end
                                                    vice.GetDiscordName(user_id)
                                                    vice.users[ids[1]] = user_id
                                                    vice.rusers[user_id] = ids[1]
                                                    vice.user_tables[user_id] = {}
                                                    vice.user_tmp_tables[user_id] = {}
                                                    vice.user_sources[user_id] = source
                                                    vice.getUData(user_id, "vice:datatable", function(sdata)
                                                        local data = json.decode(sdata)
                                                        if type(data) == "table" then vice.user_tables[user_id] = data end
                                                        local tmpdata = vice.getUserTmpTable(user_id)
                                                        vice.getLastLogin(user_id, function(last_login)
                                                            tmpdata.last_login = last_login or ""
                                                            tmpdata.spawns = 0
                                                            local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                            MySQL.execute("vice/set_last_login",
                                                                { user_id = user_id, last_login = last_login_stamp })
                                                            print("[vice] " .. name ..
                                                            " Joined | PermID: " .. user_id .. ")")
                                                            TriggerEvent("vice:playerJoin", user_id, source, name,
                                                                tmpdata.last_login)

                                                            if not VICE.hasGroup(user_id, "Supporter") then
                                                                VICE.addUserGroup(user_id, "Supporter")
                                                            end
                                                            if not VICE.hasGroup(user_id, "Gang") then
                                                                VICE.addUserGroup(user_id, "Gang")
                                                            end
                                                            if not VICE.hasGroup(user_id, "Diamond") then
                                                                VICE.addUserGroup(user_id, "Diamond")
                                                            end
                                                            exports['vice']:execute(
                                                            "UPDATE vice_dvsa SET licence = 'full' WHERE user_id = @user_id",
                                                                { user_id = user_id })

                                                            Wait(500)
                                                            deferrals.done()
                                                        end)
                                                    end)
                                                else
                                                    show_auth_card(code, deferrals, check_verified)
                                                end
                                            end
                                            show_auth_card(code, deferrals, check_verified)
                                        else
                                            deferrals.update("[vice] Checking discord verification...")
                                            if not tvice.checkForRole(user_id, '1481830175934251089') then
                                                deferrals.done(
                                                "[vice]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server. If you previously were verified, please contact management.")
                                            end
                                            if vice.CheckTokens(source, user_id) then
                                                deferrals.done("\n[vice] Permanent Ban\nYour ID is: " ..
                                                user_id ..
                                                "\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG")
                                            end
                                            vice.users[ids[1]] = user_id
                                            vice.rusers[user_id] = ids[1]
                                            vice.user_tables[user_id] = {}
                                            vice.user_tmp_tables[user_id] = {}
                                            vice.user_sources[user_id] = source
                                            vice.getUData(user_id, "vice:datatable", function(sdata)
                                                local data = json.decode(sdata)
                                                if type(data) == "table" then vice.user_tables[user_id] = data end
                                                local tmpdata = vice.getUserTmpTable(user_id)
                                                vice.getLastLogin(user_id, function(last_login)
                                                    tmpdata.last_login = last_login or ""
                                                    tmpdata.spawns = 0
                                                    local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                    MySQL.execute("vice/set_last_login",
                                                        { user_id = user_id, last_login = last_login_stamp })
                                                    print("[vice] " .. name .. " Joined | PermID: " .. user_id .. ")")
                                                    TriggerEvent("vice:playerJoin", user_id, source, name,
                                                        tmpdata.last_login)

                                                   
                                                    viceclient.isPlatClub(source, {}, function(platclub)
                                                        if not platclub then
                                                            MySQL.execute("subscription/set_plathours",
                                                                { user_id = user_id, plathours = 240 })
                                                        end
                                                    end)
                                                    exports['vice']:execute(
                                                    "UPDATE vice_dvsa SET licence = 'full' WHERE user_id = @user_id",
                                                        { user_id = user_id })

                                                    Wait(500)
                                                    deferrals.done()
                                                end)
                                            end)
                                        end
                                    else
                                        exports["ghmattimysql"]:executeSync(
                                        "INSERT IGNORE INTO vice_verification(user_id,verified) VALUES(@user_id,false)",
                                            { user_id = user_id })
                                        goto try_verify
                                    end
                                else -- already connected
                                    if vice.CheckTokens(source, user_id) then
                                        deferrals.done("\n[vice] Permanent Ban\nYour ID is: " ..
                                        user_id .. "\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG")
                                    end
                                    vice.GetDiscordName(user_id)
                                    deferrals.update("[vice] Checking discord verification...")
                                   if not tvice.checkForRole(user_id, '1481830175934251089')  then
                                        deferrals.done(
                                        "[vice]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server. If you previously were verified, please contact management.")
                                    end

                                    print("[vice] " .. name .. " Reconnected | PermID: " .. user_id)
                                    TriggerEvent("vice:playerRejoin", user_id, source, name)

                                    if not VICE.hasGroup(user_id, "Supporter") then
                                        VICE.addUserGroup(user_id, "Supporter")
                                    end
                                    if not VICE.hasGroup(user_id, "Gang") then
                                        VICE.addUserGroup(user_id, "Gang")
                                    end
                                    if not VICE.hasGroup(user_id, "Diamond") then
                                        VICE.addUserGroup(user_id, "Diamond")
                                    end
                                    exports['vice']:execute(
                                    "UPDATE vice_dvsa SET licence = 'full' WHERE user_id = @user_id",
                                        { user_id = user_id })

                                    Wait(500)
                                    deferrals.done()

                                    -- reset first spawn
                                    local tmpdata = vice.getUserTmpTable(user_id)
                                    tmpdata.spawns = 0
                                end
                                Debug.pend()
                            else
                                print("[vice] " ..
                                name ..
                                " (" ..
                                vice.getPlayerName(user_id) .. ") rejected: not whitelisted (Perm ID = " .. user_id ..
                                ")")
                                --  deferrals.done("[vice] Not whitelisted (Perm ID = "..user_id..").")
                                deferrals.done(
                                "[vice] Server is currently in development, Join https://discord.gg/UTzM4kcCjG for updates.")
                            end
                        end)
                    else
                        deferrals.update("[vice] Fetching Tokens...")
                        vice.StoreTokens(source, user_id)
                        vice.fetchBanReasonTime(user_id, function(bantime, banreason, banadmin)
                            if tonumber(bantime) then
                                local timern = os.time()
                                if timern > tonumber(bantime) then
                                    vice.setBanned(user_id, false)
                                    if vice.rusers[user_id] == nil then -- not present on the server, init
                                        vice.users[ids[1]] = user_id
                                        vice.rusers[user_id] = ids[1]
                                        vice.user_tables[user_id] = {}
                                        vice.user_tmp_tables[user_id] = {}
                                        vice.user_sources[user_id] = source
                                        deferrals.update("[vice] Loading datatable...")
                                        vice.getUData(user_id, "vice:datatable", function(sdata)
                                            local data = json.decode(sdata)
                                            if type(data) == "table" then vice.user_tables[user_id] = data end
                                            local tmpdata = vice.getUserTmpTable(user_id)
                                            deferrals.update("[vice] Getting last login...")
                                            vice.getLastLogin(user_id, function(last_login)
                                                tmpdata.last_login = last_login or ""
                                                tmpdata.spawns = 0
                                                local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                MySQL.execute("vice/set_last_login",
                                                    { user_id = user_id, last_login = last_login_stamp })
                                                print("[vice] " ..
                                                name ..
                                                " (" ..
                                                vice.getPlayerName(user_id) ..
                                                ") joined after his ban expired. (Perm ID = " .. user_id .. ")")
                                                TriggerEvent("vice:playerJoin", user_id, source, name,
                                                    tmpdata.last_login)
                                                deferrals.done()
                                            end)
                                        end)
                                    else -- already connected
                                        deferrals.update("[vice] Checking discord verification...")
                                        -- if not tvice.checkForRole(user_id, '1481830175934251089') or not tvice.checkForRole(user_id, '1481830175934251089') then
                                        --     deferrals.done(
                                        --     "[vice]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server. If you previously were verified, please contact management.")
                                        -- end

                                        print("[vice] " ..
                                        name ..
                                        " (" ..
                                        vice.getPlayerName(user_id) ..
                                        ") re-joined after their ban expired.  (Perm ID = " .. user_id .. ")")
                                        TriggerEvent("vice:playerRejoin", user_id, source, name)
                                        deferrals.done()
                                        local tmpdata = vice.getUserTmpTable(user_id)
                                        tmpdata.spawns = 0
                                    end
                                    return
                                end
                                print("[vice] " ..
                                name ..
                                " (" .. vice.getPlayerName(user_id) .. ") rejected: banned (Perm ID = " .. user_id ..
                                ")")
                                deferrals.done("\n[vice] Ban expires in " ..
                                calculateTimeRemaining(bantime) ..
                                "\nYour ID: " .. user_id .. "\nReason: " .. banreason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
                            else
                                print("[vice] " ..
                                name ..
                                " (" .. vice.getPlayerName(user_id) .. ") rejected: banned (Perm ID = " .. user_id ..
                                ")")
                                deferrals.done("\n[vice] Permanent Ban\nYour ID: " ..
                                user_id .. "\nReason: " .. banreason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
                            end
                        end)
                    end
                end)
            else
                print("[vice] " .. name .. " (" .. vice.getPlayerName(user_id) .. ") rejected: identification error")
                deferrals.done("[vice] Identification error.")
            end
        end)
    else
        print("[vice] " .. name .. " (" .. vice.getPlayerName(user_id) .. ") rejected: missing identifiers")
        deferrals.done("[vice] Missing identifiers.")
    end
    Debug.pend()
end)

AddEventHandler("playerDropped", function(reason)
    local source    = source
    local user_id   = vice.getUserId(source)
    local playerHex = GetPlayerIdentifier(source)
    local player    = source
    local discord   = "N/A"
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end
    if user_id ~= nil then
        TriggerEvent("vice:playerLeave", user_id, source)
        -- save user data table
        vice.setUData(user_id, "vice:datatable", json.encode(vice.getUserDataTable(user_id)))
        print("[vice] " .. vice.getPlayerName(user_id) .. " disconnected (Perm ID = " .. user_id .. ")")
        vice.users[vice.rusers[user_id]] = nil
        vice.rusers[user_id] = nil
        vice.user_tables[user_id] = nil
        vice.user_tmp_tables[user_id] = nil
        vice.user_sources[user_id] = nil
        print('[vice] Player Leaving Save:  Saved data for: ' .. vice.getPlayerName(user_id))
        tvice.sendWebhook('leave', "vice Leave Logs",
            "\n> **Player Name:** " ..
            vice.getPlayerName(user_id) ..
            "\n> **PermID:** " ..
            user_id .. "\n> **Temp ID:** " .. source .. "\n> **Discord:** " .. discord ..
            "\n> **Steam:** " .. playerHex .. '')
    else
        print('[vice] SEVERE ERROR: Failed to save data for: ' .. vice.getPlayerName(user_id) .. ' Rollback expected!')
    end
    viceclient.removeBasePlayer(-1, { source })
    viceclient.removePlayer(-1, { source })
end)

MySQL.createCommand("vice/setusername", "UPDATE vice_users SET username = @username WHERE id = @user_id")

RegisterServerEvent("vicecli:playerSpawned")
AddEventHandler("vicecli:playerSpawned", function()
    Debug.pbegin("playerSpawned")
    -- register user sources and then set first spawn to false
    local source     = source
    local playerHex  = GetPlayerIdentifier(source)
    local user_id    = vice.getUserId(source)
    local player     = source
    local discord    = "N/A"
    local source     = source
    local discord_id = exports['vice']:Get_Client_Discord_ID(source)
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        end
    end
    viceclient.addBasePlayer(-1, { player, user_id })
    vice.GetDiscordName(user_id)
    local customLink = exports["vice"]:Get_Discord_Avatar(discord_id)
    if user_id ~= nil then
        vice.user_sources[user_id] = source
        local tmp = vice.getUserTmpTable(user_id)
        tmp.spawns = tmp.spawns + 1
        local first_spawn = (tmp.spawns == 1)
        tvice.sendWebhook('join', "vice Join Logs",
            "\n> **Player Name:** " ..
            vice.getPlayerName(user_id) ..
            "\n> **PermID:** " ..
            user_id .. "\n> **Temp ID:** " .. source .. "\n> **Discord:** " .. discord ..
            "\n> **Steam:** " .. playerHex .. '')
        if first_spawn then
            for k, v in pairs(vice.user_sources) do
                viceclient.addPlayer(source, { v })
            end
            viceclient.addPlayer(-1, { source })
            MySQL.execute("vice/setusername", { user_id = user_id, username = vice.getPlayerName(user_id) })
        end
        TriggerEvent("vice:playerSpawn", user_id, player, first_spawn)
        TriggerClientEvent("vice:onClientSpawn", player, user_id, first_spawn)
        TriggerClientEvent("VICE:setProfilePictures", source, customLink)
    end
    Debug.pend()
end)
RegisterServerEvent("vice:playerRespawned")
AddEventHandler("vice:playerRespawned", function()
    local source = source
    TriggerClientEvent('vice:onClientSpawn', source)
end)

RegisterNetEvent("vice:CloseToRestarting", function()
    CloseToRestart = true
end)

exports("getServerStatus", function(params, cb)
    if CloseToRestart then
        cb("❌ Offline")
    elseif config.whitelist then
        cb("<:lua:1165261379758985317> Development")
    else
        cb("✅ Online") -- Need to comment this back in when i release
    end
end)

exports("getConnected", function(params, cb)
    if vice.getUserSource(params[1]) then
        cb('connected')
    else
        cb('not connected')
    end
end)

local UUIDs = {}

local uuidTypes = {
    ["alphabet"] = "abcdefghijklmnopqrstuvwxyz",
    ["numerical"] = "0123456789",
    ["alphanumeric"] = "abcdefghijklmnopqrstuvwxyz0123456789",
}

local function randIntKey(length, type)
    local index, pw, rnd = 0, "", 0
    local chars = {
        uuidTypes[type]
    }
    repeat
        index = index + 1
        rnd = math.random(chars[index]:len())
        if math.random(2) == 1 then
            pw = pw .. chars[index]:sub(rnd, rnd)
        else
            pw = chars[index]:sub(rnd, rnd) .. pw
        end
        index = index % #chars
    until pw:len() >= length
    return pw
end

function generateUUID(key, length, type)
    if UUIDs[key] == nil then
        UUIDs[key] = {}
    end

    if type == nil then type = "alphanumeric" end

    local uuid = randIntKey(length, type)
    if UUIDs[key][uuid] then
        while UUIDs[key][uuid] ~= nil do
            uuid = randIntKey(length, type)
            Wait(0)
        end
    end
    UUIDs[key][uuid] = true
    return uuid
end
