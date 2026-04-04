MySQL = module("modules/database/MySQL")

Proxy = module("util/server/Proxy")
Tunnel = module("util/server/Tunnel")
Lang = module("util/server/Lang")
Debug = module("util/server/Debug")

local config = module("cfg/base")
local version = module("version")
local verify_card = {
    ["type"] = "AdaptiveCard",
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"] = "1.3",
    ["backgroundImage"] = {
        ["url"] = "https://vicestudios.ltd/assets/vicemotelbanner.png",
    },
    ["body"] = {
        {
            ["type"] = "TextBlock",
            ["text"] = "",
            ["horizontalAlignment"] = "Left",
            ["size"] = "Medium",
            ["wrap"] = true,
            ["weight"] = "Bolder"
        },
        {
            ["type"] = "Container",
            ["horizontalAlignment"] = "Left",
            ["size"] = "Medium",
            ["items"] = {
                {
                    ["type"] = "TextBlock",
                    ["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions.",
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Medium",
                    ["wrap"] = false,
                },
                {
                    ["type"] = "TextBlock",
                    ["text"] = "Join the VICE Discord (https://discord.gg/UTzM4kcCjG)",
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Medium",
                    ["wrap"] = false,
                },
                {
                    ["type"] = "TextBlock",
                    ["text"] = "In the #verify channel (or any channel you can type in), type the following command:",
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Medium",
                    ["wrap"] = false,
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "Attention",
                    ["text"] = "3. !verify NULL",
                    ["wrap"] = true,
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Left",
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "Attention",
                    ["text"] = "Your account has not beem verified yet. (Attempt 0)",
                    ["wrap"] = true,
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Left",
                },
            }
        },
        {
            ['type'] = 'ActionSet',
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ['actions'] = {
                {
                    ['type'] = 'Action.Submit',
                    ['title'] = 'Enter VICE',
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ['id'] = 'connectButton', -- Add an ID to the button action
                    ['data'] = {
                        ['action'] = 'connectClicked',
                    },
                }, 
                {
                    ['type'] = 'Action.OpenUrl',
                    ['title'] = 'VICE Discord',
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["url"] = "https://discord.gg/UTzM4kcCjG",
                },            
            },
        },
    }
}
local finished_card = {
    ["type"] = "AdaptiveCard",
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"] = "1.3",
    ["backgroundImage"] = {
        ["url"] = "",
    },
    ["body"] = {
        {
            ["type"] = "TextBlock",
            ["text"] = "Connection Rejected",
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ["wrap"] = true,
            ["weight"] = "Bolder"
        },
        {
            ["type"] = "Container",
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ["items"] = {
                {
                    ["type"] = "TextBlock",
                    ["text"] = "You must be in our Discord and Verify your account.",
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["wrap"] = false,
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "White",
                    ["text"] = "", 
                    ["wrap"] = true,
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Left",
                },
            }
        },
        {
            ['type'] = 'ActionSet',
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ['actions'] = {
                {
                    ['type'] = 'Action.OpenUrl',
                    ['title'] = 'VICE Support Discord',
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["url"] = "https://discord.gg/eZsjN87pFQ",
                    
                    
                    ["isVisible"] = false 
                },    
                {
                    ['type'] = 'Action.OpenUrl',
                    ['title'] = 'VICE Discord',
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["url"] = "https://discord.gg/UTzM4kcCjG",
                },            
            },
        },
    }
}
local connecting_card = {
    ["type"] = "AdaptiveCard",
    ["$schema"] = "http://adaptivecards.io/schemas/adaptive-card.json",
    ["version"] = "1.3",
    ["backgroundImage"] = {
        ["url"] = "https://i.imgur.com/Yeyt5Jy.png",
    },
    ["body"] = {
        {
            ["type"] = "TextBlock",
            ["text"] = "Connecting To VICE ROLEPLAY",
            ["horizontalAlignment"] = "Right",
            ["size"] = "Large",
            ["wrap"] = true,
            ["weight"] = "Bolder"
        },
        {
            ["type"] = "Container",
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ["items"] = {
                {
                    ["type"] = "TextBlock",
                    ["text"] = "You must be in our Discord and Verify your account.",
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["wrap"] = false,
                },
                {
                    ["type"] = "TextBlock",
                    ["color"] = "White",
                    ["text"] = "Your ID is: ",
                    ["wrap"] = true,
                    ["size"] = "Medium",
                    ["horizontalAlignment"] = "Left",
                },
            }
        },
        {
            ['type'] = 'ActionSet',
            ["horizontalAlignment"] = "Left",
            ["size"] = "Large",
            ['actions'] = {
                {
                    ['type'] = 'Action.OpenUrl',
                    ['title'] = 'VICE Discord',
                    ["horizontalAlignment"] = "Left",
                    ["size"] = "Large",
                    ["url"] = "https://discord.gg/UTzM4kcCjG",
                },          
            },
        },
    }
}
local devs = {
    [1] = true,
}

local testing = true

Debug.active = config.debug
VICE = {}
Proxy.addInterface("VICE",VICE)

tVICE = {}
Tunnel.bindInterface("VICE",tVICE) -- listening for client tunnel

-- load language 
local dict = module("cfg/lang/"..config.lang) or {}
VICE.lang = Lang.new(dict)

-- init
VICEclient = Tunnel.getInterface("VICE","VICE") -- server -> client tunnel

VICE.users = {} -- will store logged users (id) by first identifier
VICE.averagefps = {} -- will store average fps for each player
VICE.rusers = {} -- store the opposite of users
VICE.user_tables = {} -- user data tables (logger storage, saved to database)
VICE.user_tmp_tables = {} -- user tmp data tables (logger storage, not saved)
VICE.user_sources = {} -- user sources 
-- queries
Citizen.CreateThread(function()
    print("^1VICE Framework.^7")
    print("^3Initializing VICE Framework Tables.^7")
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
    CREATE TABLE IF NOT EXISTS vice_trucking(
    user_id INTEGER,
    level INTEGER NOT NULL DEFAULT 0,
    xp INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT pk_trucking PRIMARY KEY(user_id)
    );
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
    dirtycash bigint, 
    CONSTRAINT pk_user_moneys PRIMARY KEY(user_id),
    CONSTRAINT fk_user_moneys_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_offshore(
    user_id INTEGER,
    money bigint,
    CONSTRAINT pk_user_offshore PRIMARY KEY(user_id),
    CONSTRAINT fk_user_offshore_users FOREIGN KEY(user_id) REFERENCES vice_users(id) ON DELETE CASCADE
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
    CREATE TABLE IF NOT EXISTS vice_disputedata (
    user_id INT PRIMARY KEY,
    name VARCHAR(255),
    disputeData TEXT
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_user_vehicles(
    user_id INTEGER,
    vehicle VARCHAR(100),
    vehicle_plate varchar(255) NOT NULL,
    nitro INT NOT NULL DEFAULT 0,
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
    point INT,
    PRIMARY KEY (warning_id)
    )
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_gangs (
    gangname VARCHAR(255) NULL DEFAULT NULL,
    gangmembers VARCHAR(3000) NULL DEFAULT NULL,
    funds BIGINT NULL DEFAULT NULL,
    logs VARCHAR(3000) NULL DEFAULT NULL,
    webhook VARCHAR(3000) NULL DEFAULT NULL,
    gangfit TEXT DEFAULT NULL,
    lockedfunds BOOLEAN DEFAULT FALSE,
    friendly_fire BOOLEAN DEFAULT FALSE,
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
    CREATE TABLE IF NOT EXISTS lottery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pot_value DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    ticket_price DECIMAL(10, 2) NOT NULL DEFAULT 25000.00
    )
    ]])
    -- MySQL.SingleQuery([[
    -- CREATE TABLE IF NOT EXISTS participation (
    -- id INT AUTO_INCREMENT PRIMARY KEY,
    -- player_id INT NOT NULL,
    -- FOREIGN KEY (player_id) REFERENCES users(id) -- Assuming you have a users table
    -- )
    -- ]])
    -- MySQL.SingleQuery([[
    -- INSERT INTO lottery (pot_value, ticket_price) VALUES (0.00, 25000.00)
    -- ]])
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
    CREATE TABLE IF NOT EXISTS vice_subscriptions (
    user_id INT(11) NULL DEFAULT NULL,
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
    user_id INT(11) NULL DEFAULT NULL,
    chips bigint NOT NULL DEFAULT 0,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_verification(
    user_id INT(11) NULL DEFAULT NULL,
    code VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    discord_id VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
    verified TINYINT NULL DEFAULT NULL,
    CONSTRAINT pk_user PRIMARY KEY(user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_staff_warnings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    admin_name VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    target_id INT,
    warning_message VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
    timestamp DATETIME
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_cardev(
    reportid INT(11) AUTO_INCREMENT,
    spawncode VARCHAR(255) NOT NULL,
    issue VARCHAR(255) NOT NULL,
    reporter VARCHAR(255) NOT NULL,
    discord_id VARCHAR(255) NOT NULL,
    user_id INT(11) NOT NULL, -- Add user_id column
    claimed BOOLEAN NOT NULL,
    completed BOOLEAN NOT NULL,
    notes TEXT NOT NULL,
    PRIMARY KEY(reportid),
    UNIQUE KEY unique_reportid (reportid)
    );
    ]]);  
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_vehicle_mods (
    mod_uuid INT(11) NOT NULL AUTO_INCREMENT,
    user_id INT(11) NULL DEFAULT NULL,
    spawncode VARCHAR(350),
    enabled BOOLEAN NOT NULL DEFAULT 1,
    savekey VARCHAR(350),
    `mod` VARCHAR(350),
    PRIMARY KEY (mod_uuid)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_vehicle_stancer (
    stancer_uuid INT(11) NOT NULL AUTO_INCREMENT,
    user_id INT(11) NULL DEFAULT NULL,
    spawncode VARCHAR(350),
    `mod` VARCHAR(100),
    value VARCHAR(100) NOT NULL DEFAULT "10",
    PRIMARY KEY (stancer_uuid)
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
    user_id INT(11) NULL DEFAULT NULL,
    quests_completed INT(11) NOT NULL DEFAULT 0,
    reward_claimed BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_weapon_whitelists (
    user_id INT(11) NULL DEFAULT NULL,
    weapon_info varchar(2048) DEFAULT '{}',
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_weapon_codes (
    user_id INT(11) NULL DEFAULT NULL,
    spawncode varchar(2048) NOT NULL DEFAULT '',
    weapon_code int(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (weapon_code)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_dvsa(
    user_id INT(11) NULL DEFAULT NULL,
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
    CREATE TABLE IF NOT EXISTS vice_prison (
    user_id INT(11) NULL DEFAULT NULL,
    prison_time INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_staff_tickets (
    user_id INT(11) NULL DEFAULT NULL,
    ticket_count INT(11) NOT NULL DEFAULT 0,
    username VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_daily_rewards (
    user_id INT(11) NULL DEFAULT NULL,
    last_reward INT(11) NOT NULL DEFAULT 0,
    streak INT(11) NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_police_hours (
    user_id INT(11) NULL DEFAULT NULL,
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
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS `vice_compensation` (
    compid INT(11) NOT NULL AUTO_INCREMENT,
    user_id int(11) NOT NULL,
    compensator int(11) NOT NULL,
    compensationdata varchar(2048) NOT NULL,
    PRIMARY KEY (`compid`)
    );
    ]])
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS `vice_statistics` (
    user_id INT(11) NOT NULL,
    name VARCHAR(100) NOT NULL,
    monthlystats TEXT NOT NULL,
    totalstats TEXT NOT NULL,
    PRIMARY KEY (user_id)
    );
    ]])
    
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS bantime varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS banreason varchar(100) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_users ADD IF NOT EXISTS banadmin varchar(100) NOT NULL DEFAULT ''; ")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rented BOOLEAN NOT NULL DEFAULT 0;")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rentedid varchar(200) NOT NULL DEFAULT '';")
    MySQL.SingleQuery("ALTER TABLE vice_user_vehicles ADD IF NOT EXISTS rentedtime varchar(2048) NOT NULL DEFAULT '';")
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
    MySQL.SingleQuery([[
    CREATE TABLE IF NOT EXISTS vice_forced_weather (
        weather_type VARCHAR(32) NOT NULL
    );
    ]])
    print("^3VICE Framework Tables Created.^7")
end)

MySQL.createCommand("VICE/create_user","INSERT INTO vice_users(whitelisted,banned) VALUES(false,false)")
MySQL.createCommand("VICE/add_identifier","INSERT INTO vice_user_ids(identifier,user_id) VALUES(@identifier,@user_id)")
MySQL.createCommand("VICE/userid_byidentifier","SELECT user_id FROM vice_user_ids WHERE identifier = @identifier")
MySQL.createCommand("VICE/GetUserByIdentifier", "SELECT user_id FROM vice_user_ids WHERE identifier = @identifier")
MySQL.createCommand("VICE/AddIdentifier", "INSERT INTO vice_user_ids (identifier, user_id, banned) VALUES(@identifier, @user_id, false)")
MySQL.createCommand("VICE/identifier_all","SELECT * FROM vice_user_ids WHERE identifier = @identifier")
MySQL.createCommand("VICE/select_identifier_byid_all","SELECT * FROM vice_user_ids WHERE user_id = @id")

MySQL.createCommand("VICE/set_userdata","REPLACE INTO vice_user_data(user_id,dkey,dvalue) VALUES(@user_id,@key,@value)")
MySQL.createCommand("VICE/get_userdata","SELECT dvalue FROM vice_user_data WHERE user_id = @user_id AND dkey = @key")

MySQL.createCommand("VICE/set_srvdata","REPLACE INTO vice_srv_data(dkey,dvalue) VALUES(@key,@value)")
MySQL.createCommand("VICE/get_srvdata","SELECT dvalue FROM vice_srv_data WHERE dkey = @key")

MySQL.createCommand("VICE/get_banned","SELECT banned FROM vice_users WHERE id = @user_id")
MySQL.createCommand("VICE/set_banned","UPDATE vice_users SET banned = @banned, bantime = @bantime,  banreason = @banreason,  banadmin = @banadmin, baninfo = @baninfo WHERE id = @user_id")
MySQL.createCommand("VICE/set_identifierbanned","UPDATE vice_user_ids SET banned = @banned WHERE identifier = @iden")
MySQL.createCommand("VICE/getbanreasontime", "SELECT * FROM vice_users WHERE id = @user_id")

MySQL.createCommand("VICE/get_whitelisted","SELECT whitelisted FROM vice_users WHERE id = @user_id")
MySQL.createCommand("VICE/set_whitelisted","UPDATE vice_users SET whitelisted = @whitelisted WHERE id = @user_id")
MySQL.createCommand("VICE/set_last_login","UPDATE vice_users SET last_login = @last_login WHERE id = @user_id")
MySQL.createCommand("VICE/get_last_login","SELECT last_login FROM vice_users WHERE id = @user_id")

--Token Banning 
MySQL.createCommand("VICE/add_token","INSERT INTO vice_user_tokens(token,user_id) VALUES(@token,@user_id)")
MySQL.createCommand("VICE/check_token","SELECT user_id, banned FROM vice_user_tokens WHERE token = @token")
MySQL.createCommand("VICE/check_token_userid","SELECT token FROM vice_user_tokens WHERE user_id = @id")
MySQL.createCommand("VICE/ClearTokens", "DELETE FROM vice_user_tokens WHERE user_id = @id")
MySQL.createCommand("VICE/ban_token","UPDATE vice_user_tokens SET banned = @banned WHERE token = @token")
--Token Banning

-- warning system
MySQL.createCommand("VICE/checkWarningPoints", "SELECT points FROM vice_bans_offenses WHERE UserID = @user_id")

-- removing anticheat ban entry
MySQL.createCommand("ac/delete_ban","DELETE FROM vice_anticheat WHERE @user_id = user_id")

-- names
MySQL.createCommand("VICE/setusername","UPDATE vice_users SET username = @username WHERE id = @user_id")

-- init tables

-- identification system

function VICE.getUserIdByIdentifiers(ids, cbr)
    local task = Task(cbr)
    if ids and #ids then
        local i = 0
        local function search()
            i = i+1
            if i <= #ids then
                if not config.ignore_ip_identifier or (string.find(ids[i], "ip:") == nil) then  -- ignore ip identifier
                    MySQL.query("VICE/userid_byidentifier", {identifier = ids[i]}, function(rows, affected)
                        if #rows > 0 then  -- found
                            task({rows[1].user_id})
                        else -- not found
                            search()
                        end
                    end)
                else
                    search()
                end
            else -- no ids found, create user
                MySQL.query("VICE/create_user", {}, function(rows, affected)
                    if rows.affectedRows > 0 then
                        local user_id = rows.insertId
                        -- add identifiers
                        for l,w in pairs(ids) do
                            if not config.ignore_ip_identifier or (string.find(w, "ip:") == nil) then  -- ignore ip identifier
                                MySQL.execute("VICE/add_identifier", {user_id = user_id, identifier = w})
                            end
                        end
                        VICE.sendDCLog("new-users", "New User", "> User ID: **"..user_id.. "**\n> Name: **" .. VICE.getPlayerName(user_id) .. "")
                        --  **\n> Identifiers: ```"..json.encode(ids).. "```
                        for k,v in pairs(VICE.getUsers()) do
                            VICE.notify(v, '~g~You have received £250,000 as someone new has joined the server.')
                            VICE.giveBankMoney(k, 250000)
                        end
                        task({user_id})
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

-- return identification string for the source (used for non VICE identifications, for rejected players)
function VICE.getSourceIdKey(source)
    local ids = GetPlayerIdentifiers(source)
    local idk = "idk_"
    for k,v in pairs(ids) do
        idk = idk..v
    end
    return idk
end

function VICE.getPlayerIP(player)
    return GetPlayerEP(player) or "0.0.0.0"
end

--- sql

function VICE.ReLoadChar(source)
    local ids = GetPlayerIdentifiers(source)
    VICE.getUserIdByIdentifiers(ids, function(user_id)
        if user_id then  
            VICE.StoreTokens(source, user_id) 
            VICE.GetDiscordName(user_id)
            Wait(500)
            local name = VICE.getPlayerName(user_id)
            if VICE.rusers[user_id] == nil then -- not present on the server, init
                VICE.StoreTables(user_id,source,ids)
                VICE.getUData(user_id, "VICE:datatable", function(sdata)
                    local data = json.decode(sdata)
                    if type(data) == "table" then VICE.user_tables[user_id] = data end
                    local tmpdata = VICE.getUserTmpTable(user_id)
                    VICE.getLastLogin(user_id, function(last_login)
                        tmpdata.last_login = last_login or ""
                        tmpdata.spawns = 0
                        local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                        MySQL.execute("VICE/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                        print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Joined.^7")
                        TriggerEvent("VICE:playerJoin", user_id, source, name, tmpdata.last_login)
                        TriggerClientEvent("VICE:CheckIdRegister", source)
                    end)
                end)
            else -- already connected
                print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Re-Joined.^7")
                TriggerEvent("VICE:playerRejoin", user_id, source, name)
                TriggerClientEvent("VICE:CheckIdRegister", source)
                local tmpdata = VICE.getUserTmpTable(user_id)
                tmpdata.spawns = 0
            end
        else -- user_id is nil
            print("^3VICE: User ID = nil ^7")
        end
    end)
end

exports("VICEStaffBot", function(method_name, params, cb)
    if cb then 
        cb(VICE[method_name](table.unpack(params)))
    else 
        return VICE[method_name](table.unpack(params))
    end
end)

RegisterNetEvent("VICE:CheckID")
AddEventHandler("VICE:CheckID", function()
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then
        VICE.ReLoadChar(source)
    end
end)

function VICE.isBanned(user_id, cbr)
    local task = Task(cbr, {false})
    MySQL.query("VICE/get_banned", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].banned})
        else
            task()
        end
    end)
end
function VICE.isWhitelisted(user_id, cbr)
    local task = Task(cbr, {false})
    MySQL.query("VICE/get_whitelisted", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].whitelisted})
        else
            task()
        end
    end)
end

function VICE.setWhitelisted(user_id,whitelisted)
    MySQL.execute("VICE/set_whitelisted", {user_id = user_id, whitelisted = whitelisted})
end

function VICE.getLastLogin(user_id, cbr)
    local task = Task(cbr,{""})
    MySQL.query("VICE/get_last_login", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].last_login})
        else
            task()
        end
    end)
end

function VICE.fetchBanReasonTime(user_id,cbr)
    MySQL.query("VICE/getbanreasontime", {user_id = user_id}, function(rows, affected)
        if #rows > 0 then 
            cbr(rows[1].bantime, rows[1].banreason, rows[1].banadmin)
        end
    end)
end

function VICE.setUData(user_id,key,value)
    MySQL.execute("VICE/set_userdata", {user_id = user_id, key = key, value = value})
end

function VICE.getUData(user_id,key,cbr)
    local task = Task(cbr,{""})
    MySQL.query("VICE/get_userdata", {user_id = user_id, key = key}, function(rows, affected)
        if #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

function VICE.setSData(key,value)
    MySQL.execute("VICE/set_srvdata", {key = key, value = value})
end

function VICE.getSData(key, cbr)
    local task = Task(cbr,{""})
    MySQL.query("VICE/get_srvdata", {key = key}, function(rows, affected)
        if rows and #rows > 0 then
            task({rows[1].dvalue})
        else
            task()
        end
    end)
end

-- return user data table for VICE internal persistant connected user storage
function VICE.getUserDataTable(user_id)
    return VICE.user_tables[user_id]
end

function VICE.getUserTmpTable(user_id)
    return VICE.user_tmp_tables[user_id]
end

function VICE.isConnected(user_id)
    return VICE.rusers[user_id] ~= nil
end

function VICE.isFirstSpawn(user_id)
    local tmp = VICE.getUserTmpTable(user_id)
    return tmp and tmp.spawns == 1
end

function VICE.getUserId(source)
    if source then
        local ids = GetPlayerIdentifiers(source)
        if ids and #ids > 0 then
            return VICE.users[ids[1]]
        end
    end
    return nil
end

exports('getUserId', function(source)
    if source then
        local ids = GetPlayerIdentifiers(source)
        if ids and #ids > 0 then
            return VICE.users[ids[1]]
        end
    end
    return nil
end)

-- return map of user_id -> player source
function VICE.getUsers()
    local users = {}
    for k,v in pairs(VICE.user_sources) do
        users[k] = v
    end
    return users
end

-- return source or nil
function VICE.getUserSource(user_id)
    return VICE.user_sources[user_id]
end

function VICE.IdentifierBanCheck(source,user_id,cb)
    for i,v in pairs(GetPlayerIdentifiers(source)) do 
        MySQL.query('VICE/identifier_all', {identifier = v}, function(rows)
            for i = 1,#rows do 
                if rows[i].banned then 
                    if user_id ~= rows[i].user_id then 
                        cb(true, rows[i].user_id)
                    end 
                end
            end
        end)
    end
end

function VICE.BanIdentifiers(user_id, value)
    MySQL.query('VICE/select_identifier_byid_all', {id = user_id}, function(rows)
        for i = 1, #rows do 
            MySQL.execute("VICE/set_identifierbanned", {banned = value, iden = rows[i].identifier })
        end
    end)
end
function calculateTimeRemaining(expireTime)
    if expireTime == nil or expireTime == "perm" then
        return 'Expired'
    end
    local secondsLeft = tonumber(expireTime) - os.time()
    if secondsLeft < 0 then
        return 'Expired'
    end

    local timeUnits = {
        { unit = 'year',   value = secondsLeft / 60 / 60 / 24 / 30 / 12 },
        { unit = 'month',  value = secondsLeft / 60 / 60 / 24 / 30 % 12 },
        { unit = 'day',    value = secondsLeft / 60 / 60 / 24 % 30 },
        { unit = 'hour',   value = secondsLeft / 60 / 60 % 24 },
        { unit = 'minute', value = secondsLeft / 60 % 60 },
        { unit = 'second', value = secondsLeft % 60 },
    }

    local datetime = ''
    for i = 1, #timeUnits - 1 do
        local firstUnitValue = math.floor(timeUnits[i].value)
        local secondUnitValue = math.floor(timeUnits[i + 1].value)
        if firstUnitValue > 0 and secondUnitValue > 0 then
            datetime = firstUnitValue .. ' ' .. timeUnits[i].unit .. (firstUnitValue > 1 and 's' or '') .. ' and ' .. secondUnitValue .. ' ' .. timeUnits[i + 1].unit .. (secondUnitValue > 1 and 's' or '')
            break
        elseif firstUnitValue > 0 then
            datetime = firstUnitValue .. ' ' .. timeUnits[i].unit .. (firstUnitValue > 1 and 's' or '')
            break
        end
    end

    if datetime == '' and secondsLeft > 0 then
        datetime = secondsLeft .. ' seconds'
    end

    return datetime ~= '' and datetime or 'Expired'
end

function VICE.setBanned(user_id,banned,time,reason,admin,baninfo)
    if banned then 
        MySQL.execute("VICE/set_banned", {user_id = user_id, banned = banned, bantime = time, banreason = reason, banadmin = admin, baninfo = baninfo})
        VICE.BanIdentifiers(user_id, true)
        VICE.BanTokens(user_id, true)
        VICE.BanUserInfo(user_id, true)
        local source = VICE.getUserSource(user_id)
        local discord_id = exports['vice']:executeSync("SELECT discord_id FROM `vice_verification` WHERE user_id = @user_id", {user_id = user_id})[1].discord_id
        print("[VICE] Banned: " .. user_id .. "Admin: " .. admin)
    else 
        MySQL.execute("VICE/set_banned", {user_id = user_id, banned = banned, bantime = "", banreason =  "", banadmin =  "", baninfo = ""})
        VICE.BanIdentifiers(user_id, false)
        VICE.BanTokens(user_id, false)
        VICE.BanUserInfo(user_id, false)
        MySQL.execute("ac/delete_ban", {user_id = user_id})
    end 
end

function VICE.ban(adminsource,permid,time,reason,baninfo)
    local adminPermID = VICE.getUserId(adminsource)
    local getBannedPlayerSrc = VICE.getUserSource(tonumber(permid))
    if time == nil then
        time = "perm"
    end
    if getBannedPlayerSrc then 
        if tonumber(time) then
            VICE.setBanned(permid,true,time,reason,VICE.getPlayerName(adminPermID),baninfo)
            VICE.kick(getBannedPlayerSrc,"[VICE] Ban expires in: "..calculateTimeRemaining(time).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG") 
        else
            VICE.setBanned(permid,true,"perm",reason,VICE.getPlayerName(adminPermID),baninfo)
            VICE.kick(getBannedPlayerSrc,"[VICE] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG") 
        end
        VICE.notify(adminsource, "~g~Success banned! User PermID: " .. permid)
    else 
        if tonumber(time) then 
            VICE.setBanned(permid,true,time,reason,VICE.getPlayerName(adminPermID),baninfo)
        else 
            VICE.setBanned(permid,true,"perm",reason,VICE.getPlayerName(adminPermID),baninfo)
        end
        VICE.notify(adminsource, "~g~Success banned! User PermID: " .. permid)
    end
end

-- function VICE.ban(adminsource, permid, time, reason, baninfo)
--     local function BanPlayer(userid, bantime, reason, adminname, baninfo)
--         local current_time = os.time()
--         bantime = tonumber(bantime) or 0 
--         VICE.setBanned(userid, true, tonumber(current_time + (60 * 60 * bantime)) or "perm", reason, adminname, baninfo or "")
--         DropPlayer(VICE.getUserSource(userid), "\n[VICE] " .. (bantime and "Ban expires in: " .. calculateTimeRemaining(current_time + (60 * 60 * bantime)) or "Permanent Ban") .. "\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG")
--     end
--     time = time or "0" 
--     local playersource = VICE.getUserSource(tonumber(permid))
--     if adminsource == "Discord" then
--         if playersource then
--             BanPlayer(permid, time, reason, "Discord Bot", baninfo or "")
--         else
--             VICE.setBanned(permid, true, tonumber(time), reason, "Discord Bot", baninfo or "")
--         end
--     elseif adminsource ~= "Console" then
--         if playersource then
--             BanPlayer(permid, time, reason, VICE.getPlayerName(adminsource) .. "(" .. adminsource .. ")", baninfo or "")
--         else
--             VICE.setBanned(permid, true, tonumber(time) or "perm", reason, "Console", baninfo or "")
--         end
--     else
--         local adminsource = VICE.getUserSource(tonumber(adminsource))
--         if playersource then
--             BanPlayer(permid, time, reason, VICE.getPlayerName(adminsource) .. "(" .. adminsource .. ")", baninfo or "")
--             VICE.notify(adminsource, "~g~Successfully Banned UserID: " .. permid)
--         else
--             VICE.setBanned(permid, true, tonumber(time) or "perm", reason, VICE.getPlayerName(adminsource), baninfo or "")
--         end
--         VICE.notify(adminsource, "~g~Success banned! User PermID: " .. permid)
--     end
-- end

function VICE.banConsole(permid,time,reason)
    local adminPermID = "VICE FrameWork"
    local getBannedPlayerSrc = VICE.getUserSource(tonumber(permid))
    if getBannedPlayerSrc then 
        if tonumber(time) and tonumber(time) ~= -1 then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            VICE.setBanned(permid,true,banTime,reason, adminPermID)
            VICE.kick(getBannedPlayerSrc,"[VICE] Ban expires in "..calculateTimeRemaining(banTime).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nBanned by VICE FrameWork \nAppeal @ https://discord.gg/UTzM4kcCjG") 
        else 
            VICE.setBanned(permid,true,"perm",reason, adminPermID)
            VICE.kick(getBannedPlayerSrc,"[VICE] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nBanned by VICE FrameWork \nAppeal @ https://discord.gg/UTzM4kcCjG") 
        end
        print("Successfully banned User ID: " .. permid)
    else 
        if tonumber(time) and tonumber(time) ~= -1 then 
            local banTime = os.time()
            banTime = banTime  + (60 * 60 * tonumber(time))  
            VICE.setBanned(permid,true,banTime,reason, adminPermID)
        else 
            VICE.setBanned(permid,true,"perm",reason, adminPermID)
        end
        print("Successfully banned User ID: " .. permid)
    end
end

function VICE.banDiscord(permid,time,reason,adminPermID)
    local getBannedPlayerSrc = VICE.getUserSource(tonumber(permid))
    if tonumber(time) then 
        local banTime = os.time()
        banTime = banTime  + (60 * 60 * tonumber(time))  
        VICE.setBanned(permid,true,banTime,reason, adminPermID)
        if getBannedPlayerSrc then 
            VICE.kick(getBannedPlayerSrc,"[VICE] Ban expires in "..calculateTimeRemaining(banTime).."\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG") 
        end
    else 
        VICE.setBanned(permid,true,"perm",reason,  adminPermID)
        if getBannedPlayerSrc then 
            VICE.kick(getBannedPlayerSrc,"[VICE] Permanent Ban\nYour ID is: "..permid.."\nReason: " .. reason .. "\nAppeal @ https://discord.gg/UTzM4kcCjG") 
        end
    end
end

-- To use token banning you need the latest artifacts.
function VICE.StoreTokens(source,userid)
    for i=1, GetNumPlayerTokens(source) do
        local token = GetPlayerToken(source,i)
        MySQL.query("VICE/check_token", {token = token},function(rows)
            if token and rows and #rows <= 0 then
                MySQL.query("VICE/add_token", {token = token, user_id = userid})
            end
        end)
    end
end


function VICE.CheckTokens(source,userid,callback)
    for i=1, GetNumPlayerTokens(source) do
        local token = GetPlayerToken(source,i)
        local rows = MySQL.asyncQuery("VICE/check_token", {token = token})
        if rows[1] then
            if rows[1].banned then
                callback(true, rows[1].user_id,token)
            end
        end
    end
    callback(false)
end

function VICE.BanTokens(user_id, banned) 
    MySQL.query("VICE/check_token_userid", {id = userid}, function(rows)
        if banned then
            for i=1, #rows do
                MySQL.query("VICE/ban_token", {token = rows[i].token, banned = true})
                Wait(100)
            end
        else
            MySQL.query("VICE/ClearTokens", {user_id = userid})
        end
    end)
end


function VICE.kick(source,reason)
   -- print("[VICE] Kicking: " .. VICE.getUserId(source))
    DropPlayer(source,reason)
end

-- [[ Warning Information ]] --

function VICE.checkWarningPoints(user_id, callback)
    MySQL.query("VICE/checkWarningPoints", {user_id = user_id}, function(result)
        if result and #result > 0 and result[1].points then
            if result[1].points >= 10 then
                callback(true, result[1].points, "You have reached 10 points and have received a 3-month ban.", "You have reached 10 points and have received a 3-month ban.")
            else
                callback(false, result[1].points, "Less than or equal to 10 points", "Less than or equal to 10 points")
            end
        else
            callback(false, 0, "No points found", "No points found")
        end
    end)
end

-- [[ User Information ]] --

function VICE.checkidentifiers(userid,identifier,cb)
    for A,B in pairs(identifier) do
        MySQL.query("VICE/GetUserByIdentifier", {identifier = B}, function(rows, affected)
            if rows[1] then
                if rows[1].id ~= userid then
                    VICE.isBanned(rows[1].id, function(banned)
                        if banned then
                            cb(true, rows[1].id,"Ban Evading",B)
                        else
                            cb(true, rows[1].id,"Multi Accounting",B)
                        end
                    end)
                end
            else
                if A ~= "ip" then
                    MySQL.query("VICE/AddIdentifier", {identifier = B, user_id = userid})
                end
            end
        end)
    end
end


function VICE.getUserByLicense(license, cb)
    MySQL.query('VICE/GetUserByLicense', {license = license}, function(rows, affected)
        if rows[1] then
            cb(rows[1].id)
        else
            MySQL.query('VICE/CreateUser', {license = license}, function(rows, affected)
                if rows.affectedRows > 0 then
                    VICE.getUserByLicense(license, cb)
                end
            end)
            for k, v in pairs(VICE.getUsers()) do
                VICE.notify(v, '~g~You have received £250,000 as someone new has joined the server.')
                VICE.giveBankMoney(k, 250000)
            end
        end
    end)
end


function VICE.SetIdentifierban(user_id,banned)
    MySQL.query("VICE/GetIdentifiers", {user_id = user_id}, function(rows)
        if banned then
            for i=1, #rows do
                MySQL.query("VICE/BanIdentifier", {identifier = rows[i].identifier, banned = true})
                Wait(50)
            end
        else
            for i=1, #rows do
                MySQL.query("VICE/BanIdentifier", {identifier = rows[i].identifier, banned = false})
            end
        end
    end)
end

function table.maxKeys(table)
    local count = 0
    for k,v in pairs(table) do
        count = count + 1
    end
    return count
end

-- tasks

function task_save_datatables()
    TriggerEvent("VICE:save")
    Debug.pbegin("VICE save datatables")
    for k,v in pairs(VICE.user_tables) do
        VICE.setUData(k,"VICE:datatable",json.encode(v))
    end
    Debug.pend()
    SetTimeout(config.save_interval*1000, task_save_datatables)
end
task_save_datatables()
function VICE.GetPlayerIdentifiers(source)
    local Identifiers = GetPlayerIdentifiers(source)
    local ids = {}
    for _,identifier in pairs(Identifiers) do
        local key,value = string.match(identifier, "([^:]+):(.+)")
        if key and value then
            ids[key] = ids[key] or key..":"..value
        end
    end
    return ids
end

function VICE.inWhitelist()
  return config.whitelist
end

-- handlers

local isConnectionFinished = false
local isFinishedCardShown = false
local isVerifiedCardShown = false
-- local IsShowResourcesCard = false
--local maxPlayers = GetConvar("sv_maxclients", "128")
local queue = {}
local currentTask = 0 

function isPlayerConnected(user_id)
    local players = GetPlayers()
    for i=1, #players do
        local player_user_id = GetPlayerIdentifier(players[i], 0)
        if player_user_id == user_id then
            return true
        end
    end
    return false
end

-- [[ Error Codes ]] --
-- VICE: #0000 - Default Error
-- VICE: #0001 - Deferrals not provided
-- VICE: #0002 - Error while fetching data
-- VICE: #0003 - Rollback Error
-- VICE: #0004 - Provided wrong data

-- [[ Adaptive Cards ]] --

local currentTasks = {}
local referenceCode = "VICE: #0000"

function VICE.updateCard(message, deferrals, id)
    local startTime = os.time()
    Wait(100)
    local progressText = ""
    if isFinishedCardShown then
        return
    end
    if isVerifiedCardShown then
        return
    end
    VICE.isBanned(id, function(banned)
        if not banned then
            if queue[id] then
                progressText = "Sittin in queue..."
            end
            if message == "" then
                referenceCode = "VICE: #0001"
                VICE.doneCard("Failure to connect, Contact a developer about your issue.\n Reference code: " .. referenceCode, deferrals, user_id)
                isConnectionFinished = true
                isFinishedCardShown = true
               return
            end
            if message then
                if connecting_card["body"][2] and connecting_card["body"][2]["items"] then
                    if connecting_card["body"][2]["items"][1] then
                        connecting_card["body"][2]["items"][1]["text"] = message
                    end
                    if connecting_card["body"][2]["items"][2] and id then
                        connecting_card["body"][2]["items"][2]["text"] = "Your ID is: "..id
                    end
                end
            end
            if not currentTasks[id] then
                currentTasks[id] = 0
            end
            currentTasks[id] = currentTasks[id] + 1
            if not queue[id] then
                if currentTasks[id] <= 13 then
                    progressText = "Running Checks..."
                elseif currentTasks[id] >= 14 then
                    progressText = "Downloading Resources..."
                else
                    progressText = "Loading..."
                end
            end
            
            progressBar = string.rep("⚡", currentTasks[id]) .. " " .. progressText
            
            if connecting_card["body"][3] then
                connecting_card["body"][3]["text"] = progressBar
            else
                table.insert(connecting_card["body"], {
                    ["type"] = "TextBlock",
                    ["text"] = progressBar,
                    ["wrap"] = true
                })
            end
            deferrals.presentCard(connecting_card)
        end
    end)
end

function VICE.doneCard(message, deferrals, id)
    isConnectionFinished = true
    isFinishedCardShown = true
    Wait(100)
    if message == "" then
        deferrals.done()
        return
    end
    if message then
        if finished_card["body"][2] and finished_card["body"][2]["items"] then
            if finished_card["body"][2]["items"][1] then
                finished_card["body"][2]["items"][1]["text"] = message
                finished_card["body"][2]["items"][1]["size"] = "Medium"
            end
        end
        for i = #finished_card["body"][3]["actions"], 1, -1 do
            if finished_card["body"][3]["actions"][i]["title"] == "VICE Support Discord" then
                table.remove(finished_card["body"][3]["actions"], i)
            end
        end
        if string.match(message, "Ban") then
            table.insert(finished_card["body"][3]["actions"], {
                ['type'] = 'Action.OpenUrl',
                ['title'] = 'VICE Support Discord',
                ["horizontalAlignment"] = "Left",
                ["size"] = "Large",
                ["url"] = "https://discord.gg/eZsjN87pFQ",
            })
        end
    end
    deferrals.presentCard(finished_card)
    -- Wait(5000)
    -- deferrals.done(message)
    return
end

function tVICE.sPrint(message)
    print("^1[VICE] " .. message .. "^7")
end  

Citizen.CreateThread(function()
    while true do
        for i, player in ipairs(queue) do
            if not isPlayerConnected(player.user_id) then
                table.remove(queue, i)
                break
            end
        end
        Wait(1000)
    end
end)

-- [[ Handle Player Connections ]] --

local blacklistedNames = {
    "nigger",
    "nigga",
    "coon",
    "faggot",
    "administrator",
    "staff",
    "admin",
    "blacky",
    "kkk",
    "hitler",
    "n1gger",
    "n1gga",
    "fagg0t",
    "wog",
    "paki",
    "anal",
    "kys",
    "homosexual",
    "lesbian",
    "suicide",
    "negro",
    "queef",
    "queer",
    "allahu akbar",
    "terrorist",
    "wanker",
    "n1gger",
    "f4ggot",
    "n0nce",
    "d1ck",
    "h0m0",
    "n1gg3r",
    "h0m0s3xual",
    "nazi",
	"fag",
	"fa5",
    "cmg",
    "hdn",

}

AddEventHandler("playerConnecting",function(name,setMessage, deferrals)
    isConnectionFinished = false
    isFinishedCardShown = false
    isVerifiedCardShown = false
    -- IsShowResourcesCard = false
    deferrals.defer()
    local source = source
    currentTask = 0
    Debug.pbegin("playerConnecting")
    local ids = GetPlayerIdentifiers(source)
    local idz = {}
    for _, id in pairs(GetPlayerIdentifiers(source)) do 
        local key, value = string.match(id, "([^:]+):(.+)")
        if key and value then
            idz[key] = idz[key] or key..":"..value
        end
    end
    if GetNumPlayerTokens(source) <= 0 then
        VICE.doneCard("[VICE] Please attempt to connect again.", deferrals)
    end
    if ids and #ids > 0 then
        VICE.getUserIdByIdentifiers(ids, function(user_id)
            currentTasks[user_id] = 0
            VICE.updateCard("Checking identifiers...", deferrals, user_id)
            local numtokens = GetNumPlayerTokens(source)
            if numtokens == 0 then
                VICE.doneCard("[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                VICE.sendDCLog('ban-evaders', 'VICE Ban Evade Logs', "> Player Name: **"..name.."**\n> Player Current Perm ID: **"..user_id.."**\n> Player Token Amount: **"..numtokens.."**")
                return 
            end
            -- VICE.updateCard("Checking connection status...", deferrals, user_id)
            -- if VICE.user_sources[user_id] then
            --     VICE.doneCard("[VICE] Your account is still connected to the server, please allow up to 120 seconds for disconnection.", deferrals, user_id)
            --     return
            -- end
           -- print((VICE.getPlayerName(user_id) .. "(" .. user_id .. ")" or (name .. "(" .. user_id .. ")")) .. " ^2 | Attempting to connect^7")
            VICE.updateCard("Checking warning points...", deferrals, user_id)
            VICE.checkWarningPoints(user_id, function(exceeded, points, message, reason)
                if exceeded and points >= 10 then
                    VICE.isBanned(user_id, function(isBanned)
                        if isBanned then
                            return
                        else
                            if user_id then
                                if reason then
                                    local threeMonthsFromNow = os.time() + (3 * 30 * 24 * 60 * 60)
                                    VICE.setBanned(user_id, true, threeMonthsFromNow, reason, "VICE Framework", "Automatic Ban | ID:"..user_id)
                                    VICE.doneCard("\n[VICE] Ban expires in 3 months\nYour ID is: "..user_id.."\nReason: "..reason.."\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                                    VICE.sendDCLog('ban', 'VICE Ban Logs', "> Player Name: **"..name.."**\n> Player Perm ID: **"..user_id.."**\n> Points: **"..points.."**")
                                end
                            end
                        end
                    end)
                end
            end)
            VICE.updateCard("Checking account info...", deferrals, user_id)
            VICE.SteamAccountInfo(steamid, name, function(steaminfo)
                if steaminfo then
                    TriggerClientEvent("VICE:requestAccountInfo", source, false)
                    VICE.checkDevicesBanned(user_id, steaminfo.gpu, steaminfo.cpu_cores, steaminfo.user_agent, steaminfo.devices, function(banned, banned_user_id)
                        if banned then
                            VICE.BanUserInfo(user_id, true)
                            VICE.doneCard("[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                            VICE.sendDCLog('ban-evaders', 'VICE Ban Evade Logs', "> Player Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Player Current Perm ID: **" .. user_id .. "**\n> Player Banned PermID: **" .. banned_user_id .. "**")
                            return
                        end
                    end)
                end
            end)
            VICE.updateCard("Checking identifiers...", deferrals, user_id)
            VICE.checkidentifiers(user_id, ids, function(banned, userid, reason, identifier)
                userid = userid or "N/A" 
                if banned and reason == "Ban Evading" then
                    VICE.doneCard("\n[VICE] Permanently Banned\nUser ID: "..user_id.."\nReason: "..reason.."\nAppeal: https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                    VICE.setBanned(user_id,true,"perm","Ban Evading","VICE","ID Banned: "..userid)
                    VICE.sendDCLog('ban-evaders', 'VICE Ban Evade Logs', "> Player Name: **"..name.."**\n> Player Current Perm ID: **"..user_id.."**\n> Player Banned PermID: **"..userid.."**\n> Banned Identifier: **"..identifier.."**")
                elseif reason == "Multi Accounting" then
                    VICE.sendDCLog("multiaccounting","Multi Accounting","> Player Name: "..name.."\n> User ID: "..user_id.."\n> Multi Account ID: "..userid.."\n> Multi Account Identifier: "..identifier)
                end
            end)
            if user_id then -- check user validity 
                VICE.updateCard("Fetching Tokens...", deferrals, user_id)
                VICE.StoreTokens(source, user_id)
                -- VICE.updateCard("Checking If server full...", deferrals, user_id)
                -- maxPlayers = tonumber(maxPlayers)
                -- if #GetPlayers() >= maxPlayers then
                --     VICE.updateCard("Server Full, Placing you into queue...", deferrals, user_id)
                --     table.insert(queue, {user_id = user_id, name = name})
                --     while #GetPlayers() >= maxPlayers do
                --         for i, player in ipairs(queue) do
                --             if player.user_id == user_id then
                --                 VICE.updateCard("[VICE] Server Full\nYou are " .. i .. "/" .. #queue .. " in queue\nServer Slots: " .. #GetPlayers() .. "/" .. maxPlayers, deferrals, user_id)
                --                 progressText = "Sittin in queue..."
                --             end
                --         end
                --         Wait(500)
                --     end
                -- end
                VICE.updateCard("Checking banned...", deferrals, user_id)
                VICE.isBanned(user_id, function(banned)
                    if not banned then
                        VICE.updateCard("Checking whitelisted...", deferrals, user_id)
                        VICE.isWhitelisted(user_id, function(whitelisted)
                            if not config.whitelist or whitelisted or devs[user_id] then
                                Debug.pbegin("playerConnecting_delayed")
                                VICE.updateCard("Checking if verified...", deferrals, user_id)
                                if VICE.rusers[user_id] == nil then -- not present on the server, init
                                    ::try_verify::
                                    local verified = exports["vice"]:executeSync("SELECT * FROM vice_verification WHERE user_id = @user_id", {user_id = user_id})
                                    if #verified > 0 then 
                                        if verified[1]["verified"] == 0 then
                                            local code = nil
                                            local data_code = exports["vice"]:executeSync("SELECT * FROM vice_verification WHERE user_id = @user_id", {user_id = user_id})
                                            code = data_code[1]["code"]
                                            if code == nil then
                                                code = generateVerificationCode()
                                            end
                                            ::regen_code::
                                            local checkCode = exports["vice"]:executeSync("SELECT * FROM vice_verification WHERE code = @code", {code = code})
                                            if checkCode then
                                                if #checkCode > 0 then
                                                    code = generateVerificationCode()
                                                    goto regen_code
                                                end
                                            end
                                            exports["vice"]:executeSync("UPDATE vice_verification SET code = @code WHERE user_id = @user_id", { user_id = user_id, code = code })
                                            VICE.genCard(code, deferrals, function(data)
                                                VICE.presentVerified(deferrals, code, user_id)
                                            end)
                                            Wait(100000)
                                        else
                                            VICE.CheckTokens(source,user_id,function(banned,userid,token)
                                                if banned then
                                                    print("User: "..user_id.." Banned for Ban Evading")
                                                    VICE.SetBanned(user_id,true,"perm","Ban Evading","VICE Framework","Token Banned")
                                                    VICE.doneCard("\n[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                                                    VICE.sendDCLog("banevading","Ban Evading","> Player Name: "..plrname.."\n> User ID: "..user_id.."\n> Banned ID: "..userid.."\n> Banned Token: "..token)
                                                end
                                            end)
                                            if VICE.inWhitelist() then
                                                if not VICE.checkForRole(user_id, '1387888781218152468') then
                                                    VICE.doneCard("[VICE]: You are not part of the Testing Team", deferrals, user_id)
                                                    return
                                                end
                                            elseif not VICE.checkForRole(user_id, '1481830175934251089') then
                                                VICE.doneCard("\n[VICE]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server.\n If you previously were verified, please contact management.", deferrals, user_id)
                                                return
                                            end
                                            VICE.GetDiscordName(user_id)
                                          --  if not idz["steam"] then
                                                -- delete
                                              --  VICE.doneCard("[VICE] Steam account not found. Please open Steam and relaunch FiveM.", deferrals, user_id)
                                              --  return
                                          --  end  
                                            VICE.StoreTables(user_id,source,ids)
                                            VICE.getUData(user_id, "VICE:datatable", function(sdata)
                                                local data = json.decode(sdata)
                                                if type(data) == "table" then VICE.user_tables[user_id] = data end
                                                local tmpdata = VICE.getUserTmpTable(user_id)
                                                VICE.getLastLogin(user_id, function(last_login)
                                                    tmpdata.last_login = last_login or ""
                                                    tmpdata.spawns = 0
                                                    local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                    MySQL.execute("VICE/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                    print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Joined. ^7")
                                                    TriggerEvent("VICE:playerJoin", user_id, source, name, tmpdata.last_login)
                                                    Wait(500)
                                                    VICE.doneCard("", deferrals, user_id)
                                                end)
                                            end)
                                        end
                                    else
                                        exports["vice"]:executeSync("INSERT IGNORE INTO vice_verification(user_id,verified) VALUES(@user_id,false)", {user_id = user_id})
                                        goto try_verify
                                    end
                                else -- already connected           
                                    VICE.CheckTokens(source,user_id,function(banned,userid,token)
                                        if banned then
                                            print("User: "..user_id.." Banned for Ban Evading")
                                            VICE.SetBanned(user_id,true,"perm","Ban Evading","VICE Framework","Token Banned")
                                            VICE.doneCard("\n[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                                            VICE.sendDCLog("banevading","Ban Evading","> Player Name: "..plrname.."\n> User ID: "..user_id.."\n> Banned ID: "..userid.."\n> Banned Token: "..token)
                                        end
                                    end)
                                    if VICE.inWhitelist() then
                                        if not VICE.checkForRole(user_id, '1387888781218152468') then
                                            VICE.doneCard("[VICE]: You are not part of the Testing Team", deferrals, user_id)
                                            return
                                        end
                                    elseif not VICE.checkForRole(user_id, '1481830175934251089') then
                                        VICE.doneCard("\n[VICE]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server.\n If you previously were verified, please contact management.", deferrals, user_id)
                                        return
                                    end
                                    VICE.GetDiscordName(user_id)
                                  --  if not idz["steam"] then -- delete
                                   --     VICE.doneCard("[VICE] Steam account not found. Please open Steam and relaunch FiveM.", deferrals, user_id)
                                    --    return
                                  --  end  
                                    print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Reconnected.^7")
                                    TriggerEvent("VICE:playerRejoin", user_id, source, name)
                                    Wait(500)
                                    VICE.doneCard("", deferrals, user_id)
                                    local tmpdata = VICE.getUserTmpTable(user_id)
                                    tmpdata.spawns = 0
                                end
                                Debug.pend()
                            else
                                print("(" .. user_id .. ") ^1 | rejected not whitelist.^7")
                               -- VICE.doneCard("[VICE] Not whitelisted\nID: " .. user_id, deferrals, user_id)
                                VICE.doneCard("[VICE] Server is currently in development, Join https://discord.gg/UTzM4kcCjG for updates.", deferrals, user_id)
                            end
                        end)
                    else
                        VICE.updateCard("Fetching tokens...", deferrals, user_id)
                        VICE.StoreTokens(source, user_id) 
                        VICE.fetchBanReasonTime(user_id,function(bantime, banreason, banadmin)
                            if tonumber(bantime) then 
                                local timern = os.time()
                                if timern > tonumber(bantime) then 
                                    VICE.setBanned(user_id,false)
                                    if VICE.rusers[user_id] == nil then -- not present on the server, init
                                        VICE.StoreTables(user_id,source,ids)
                                        VICE.updateCard("Loading datatable...", deferrals, user_id)
                                        VICE.getUData(user_id, "VICE:datatable", function(sdata)
                                            local data = json.decode(sdata)
                                            if type(data) == "table" then VICE.user_tables[user_id] = data end
                                            local tmpdata = VICE.getUserTmpTable(user_id)
                                            VICE.updateCard("Getting last login...", deferrals, user_id)
                                            VICE.getLastLogin(user_id, function(last_login)
                                                tmpdata.last_login = last_login or ""
                                                tmpdata.spawns = 0
                                                local last_login_stamp = os.date("%H:%M:%S %d/%m/%Y")
                                                MySQL.execute("VICE/set_last_login", {user_id = user_id, last_login = last_login_stamp})
                                                print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Joined after their ban expired.^7")
                                                TriggerEvent("VICE:playerJoin", user_id, source, name, tmpdata.last_login)
                                                VICE.doneCard("", deferrals, user_id)
                                            end)
                                        end)
                                    else -- already connected
                                        VICE.CheckTokens(source,user_id,function(banned,userid,token)
                                            if banned then
                                                print("User: "..user_id.." Banned for Ban Evading")
                                                VICE.SetBanned(user_id,true,"perm","Ban Evading","VICE Framework","Token Banned")
                                                VICE.doneCard("\n[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                                                VICE.sendDCLog("banevading","Ban Evading","> Player Name: "..plrname.."\n> User ID: "..user_id.."\n> Banned ID: "..userid.."\n> Banned Token: "..token)
                                            end
                                        end)
                                        if VICE.inWhitelist() then
                                            if not VICE.checkForRole(user_id, '1387888781218152468') then
                                                VICE.doneCard("[VICE]: You are not part of the Testing Team", deferrals, user_id)
                                                return
                                            end
                                        elseif not VICE.checkForRole(user_id, '1481830175934251089') then
                                            VICE.doneCard("\n[VICE]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server.\n If you previously were verified, please contact management.", deferrals, user_id)
                                            return
                                        end
                                        VICE.GetDiscordName(user_id)
                                        -- if not idz["steam"] then -- delete
                                        --     VICE.doneCard("[VICE] Steam account not found. Please open Steam and relaunch FiveM.", deferrals, user_id)
                                        --     return
                                        -- end  
                                        print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^2 | Re-Joined after their ban expired.")
                                        TriggerEvent("VICE:playerRejoin", user_id, source, name)
                                        VICE.doneCard("", deferrals, user_id)
                                        local tmpdata = VICE.getUserTmpTable(user_id)
                                        tmpdata.spawns = 0
                                    end
                                    return 
                                end
                                print("(" .. user_id .. ") rejected ^1 | banned.^7")
                                VICE.doneCard("\n[VICE] Ban expires in "..calculateTimeRemaining(bantime).."\nYour ID is: "..user_id.."\nReason: "..banreason.."\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                            else 
                                print("(" .. user_id .. ") rejected ^1 | banned.^7")
                                VICE.doneCard("\n[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: "..banreason.."\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
                            end
                        end)
                    end
                end)
            else
                print("(" .. user_id .. ") rejected ^1 | missing identifiers.^7")
                VICE.doneCard("[VICE] Identification error.", deferrals, user_id)
            end
        end)
    else
        print("(" .. user_id .. ") rejected ^1 | missing identifiers.^7")
        VICE.doneCard("[VICE] Missing identifiers.", deferrals, user_id)
    end
    Debug.pend()
end)

-- function VICE.commonChecks(source, user_id, deferrals) -- delete
--     local ids = GetPlayerIdentifiers(source)
--     local commonIdz = {}
--     for _, id in pairs(GetPlayerIdentifiers(source)) do 
--         local key, value = string.match(id, "([^:]+):(.+)")
--         if key and value then
--             commonIdz[key] = commonIdz[key] or key..":"..value
--         end
--     end
--     if user_id then 
--         if VICE.CheckTokens(source, user_id) then 
--             VICE.doneCard("\n[VICE] Permanent Ban\nYour ID is: "..user_id.."\nReason: Ban evading is not permitted.\nAppeal @ https://discord.gg/UTzM4kcCjG", deferrals, user_id)
--             return
--         end
--         if not VICE.checkForRole(user_id, '1481830175934251089') then
--             VICE.doneCard("[VICE]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server. If you previously were verified, please contact management.", deferrals, user_id)
--             return
--         end
--         VICE.GetDiscordName(user_id)
--         if not commonIdz["steam"] then
--             VICE.doneCard("[VICE] Steam account not found. Please open Steam and relaunch FiveM.", deferrals, user_id)
--             return
--         end  
--     else
--         VICE.doneCard("Failure to connect, Contact a developer about your issue.\n Reference code: VICE: #0004", deferrals)
--         return
--     end
-- end -- delete

function VICE.isVerified(user_id)
    local isverified = exports["vice"]:executeSync("SELECT * FROM vice_verification WHERE user_id = @user_id", {user_id = user_id})
    return #isverified > 0 and verified[1]["verified"] or false
end

Citizen.CreateThread(function()
    while true do
        for UserID, source in pairs(VICE.user_sources) do 
            local Name = GetPlayerName(source)
            if Name == nil then 
                print("Dropped ^2 | ID: " .. UserID .. "^7")
                TriggerEvent("VICE:onServerLeave",source,UserID,false,true)
            end
        end
        Wait(60000)
    end
end)

AddEventHandler("VICE:onServerLeave",function(source,user_id,first_spawn)
    VICE.StoreTables(user_id,source,false,true)
end)

function VICE.StoreTables(user_id,source,ids,remove)
    if not remove and ids then 
        VICE.users[ids[1]] = user_id
        VICE.averagefps[user_id] = {}
        VICE.rusers[user_id] = ids[1]
        VICE.user_tables[user_id] = {}
        VICE.user_tmp_tables[user_id] = {}
        VICE.user_sources[user_id] = source
    else
        Wait(2000)
        VICE.user_sources[user_id] = nil 
        if VICE.rusers[user_id] then
            VICE.users[VICE.rusers[user_id]] = nil
        end
        VICE.averagefps[user_id] = nil
        VICE.rusers[user_id] = nil
        VICE.user_tables[user_id] = nil
        VICE.user_tmp_tables[user_id] = nil
    end
end

-- [[ Verification ]] --

local trys = {}
function VICE.genCard(code, deferrals, callback)
    isVerifiedCardShown = true
    Wait(1000)
    if trys[code] == nil then
        trys[code] = 0
    end
    verify_card["body"][2]["items"][1]["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions."
    verify_card["body"][2]["items"][2]["text"] = "Join the VICE discord (https://discord.gg/UTzM4kcCjG)"
    verify_card["body"][2]["items"][3]["text"] = "In the #verify channel (or any channel you can type in), type the following command:"
    verify_card["body"][2]["items"][4]["text"] = "!verify "..code
    verify_card["body"][2]["items"][4]["color"] = "Attention"
    verify_card["body"][2]["items"][5]["text"] = "Your account has not been verified yet. (Attempt "..trys[code]..")"
    deferrals.presentCard(verify_card, callback)
end                                                                                     
function VICE.presentVerified(deferrals, code, user_id, data)
    local data_verified = exports["vice"]:executeSync("SELECT verified FROM vice_verification WHERE user_id = @user_id", { user_id = user_id })
    if trys[code] == nil then
        trys[code] = 0
    end
    if trys[code] ~= 5 then
        verify_card["body"][2]["items"][1]["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions."
        verify_card["body"][2]["items"][2]["text"] = "Join the VICE discord (https://discord.gg/UTzM4kcCjG)"
        verify_card["body"][2]["items"][3]["text"] = "In the #verify channel (or any channel you can type in), type the following command:"
        verify_card["body"][2]["items"][4]["text"] = "!verify "..code
        verify_card["body"][2]["items"][5]["text"] = "Checking Verification..."
        verify_card["body"][2]["items"][5]["color"] = "Attention"
        deferrals.presentCard(verify_card, callback)
        Wait(2000)
        verify_card["body"][2]["items"][1]["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions."
        verify_card["body"][2]["items"][2]["text"] = "Join the VICE discord (https://discord.gg/UTzM4kcCjG)"
        verify_card["body"][2]["items"][3]["text"] = "In the #verify channel (or any channel you can type in), type the following command:"
        verify_card["body"][2]["items"][4]["text"] = "!verify "..code
    else
        verify_card["body"][2]["items"][1]["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions."
        verify_card["body"][2]["items"][2]["text"] = "Join the VICE discord (https://discord.gg/UTzM4kcCjG)"
        verify_card["body"][2]["items"][3]["text"] = "In the #verify channel (or any channel you can type in), type the following command:"
        verify_card["body"][2]["items"][4]["text"] = "!verify "..code
        verify_card["body"][2]["items"][5]["text"] = "You Have Reached The Maximum Amount Of Attempts"
        verify_card["body"][2]["items"][5]["color"] = "Attention"
        deferrals.presentCard(verify_card, callback)
        Wait(2000)
        VICE.doneCard("[VICE]: Failed to verify your account, please try again.", deferrals, user_id)
        return
    end
    if data_verified[1] and data_verified[1].verified == 1 then
        verify_card["body"][2]["items"][1]["text"] = "In order to connect to VICE you must be in our discord and verify your account. please follow the below instructions."
        verify_card["body"][2]["items"][2]["text"] = "Join the VICE discord (https://discord.gg/UTzM4kcCjG)"
        verify_card["body"][2]["items"][3]["text"] = "In the #verify channel (or any channel you can type in), type the following command:"
        verify_card["body"][2]["items"][4]["text"] = "!verify "..code
        verify_card["body"][2]["items"][5]["text"] = "Verification Successful!"
        verify_card["body"][2]["items"][5]["color"] = "Good"
        deferrals.presentCard(verify_card, callback)
        Wait(2000)
        isVerifiedCardShown = false
        if VICE.inWhitelist() then
            if not VICE.checkForRole(user_id, '1387888781218152468') then
                VICE.doneCard("[VICE]: You are not part of the Testing Team", deferrals, user_id)
                return
            end
        elseif not VICE.checkForRole(user_id, '1481830175934251089') then
            VICE.doneCard("\n[VICE]: You are required to be verified within https://discord.gg/UTzM4kcCjG to join the server.\n If you previously were verified, please contact management.", deferrals, user_id)
            return
        end
        VICE.doneCard("", deferrals, user_id)
        VICE.sendDCLog("new-users", "Newly Verified", "> User ID: **"..user_id.. "**\n> Name: **" .. VICE.getPlayerName(user_id) .. "**\n> Identifiers: ```"..json.encode(ids).. "```")
        VICE.GetDiscordName(user_id)
        print(VICE.getPlayerName(user_id).."(" .. user_id .. ") Joined ^2 | Newly Verified.^7")
    end
    trys[code] = trys[code] + 1
    VICE.genCard(code, deferrals, callback)
end

function generateVerificationCode()
    local characters = "0123456789"
    local code = ""
    for _ = 1, 6 do
        local randIndex = math.random(1, #characters)
        code = code .. string.sub(characters, randIndex, randIndex)
    end
    return code
end

-- [[ Player Join/Leave ]] --

AddEventHandler("playerDropped", function(reason)
    local source = source
    local user_id = VICE.getUserId(source)
    local totalfps = 0
    if user_id then
        TriggerEvent("VICE:playerLeave", user_id, source)
        VICE.setUData(user_id, "VICE:datatable", json.encode(VICE.getUserDataTable(user_id)))
        for i = 1, #VICE.averagefps[user_id] do
            totalfps = totalfps + VICE.averagefps[user_id][i]
        end
        local averagefps = tostring(totalfps / #VICE.averagefps[user_id])
        if averagefps == "-nan(ind)" or averagefps == "inf" then
            averagefps = "0"
        end
        TriggerEvent("VICE:onServerLeave",source,user_id,false,true)
        print(VICE.getPlayerName(user_id).."(" .. user_id .. ") ^1 | disconnected.^7")
        VICE.sendDCLog('join-leave', VICE.getPlayerName(user_id) .. " Disconnected", "\n> **Player Name:** " .. VICE.getPlayerName(user_id) .. "\n> **PermID:** " .. user_id .. "\n> **Temp ID:** " .. source .. "\n> **Average FPS:** " .. averagefps .. "\nReason:" .. reason and string.format("\n```%s```", reason) or "Exiting")
    else
        print(VICE.getPlayerName(user_id) .. " ^1 | VICE: #0003^7")
    end
    VICEclient.removeBasePlayer(-1, { source })
    VICEclient.removePlayer(-1, { source })
end)

RegisterServerEvent("VICEcli:playerSpawned")
AddEventHandler("VICEcli:playerSpawned", function()
    Debug.pbegin("playerSpawned")
    local source = source
    local user_id = VICE.getUserId(source)
    local player = source
    local identifiers = {}
    for k, v in pairs(GetPlayerIdentifiers(source)) do
        if not string.match(v, "^ip:") then
            table.insert(identifiers, v)
        end
    end
    for i, player in ipairs(queue) do
        if player.user_id == user_id then
            table.remove(queue, i)
            break
        end
    end
    VICEclient.addBasePlayer(-1, { player, user_id })
    if user_id then
        VICE.user_sources[user_id] = source
        local tmp = VICE.getUserTmpTable(user_id)
        if not tmp.spawns then
            tmp.spawns = 0 
        end
        tmp.spawns = tmp.spawns + 1
        local first_spawn = (tmp.spawns == 1)
        VICE.sendDCLog('join-leave', VICE.getPlayerName(user_id) .. " Connected", "\nUser Info:\n")
        -- VICE.sendDCLog('beams', VICE.getPlayerName(user_id) .. " Connected")
        if first_spawn then
            for k, v in pairs(VICE.user_sources) do
                VICEclient.addPlayer(source, { v })
            end
            VICEclient.addPlayer(-1, { source })
            MySQL.execute("VICE/setusername", { user_id = user_id, username = VICE.getPlayerName(user_id) })
        end
        TriggerEvent("VICE:onServerSpawn", user_id, player, first_spawn)
        TriggerClientEvent("VICE:onClientSpawn", player, user_id, first_spawn)
    end
    Debug.pend()
end)

RegisterServerEvent("VICE:playerRespawned")
AddEventHandler("VICE:playerRespawned", function()
    local source = source
    TriggerClientEvent('VICE:onClientSpawn', source)
end)

-- [[ Status Related ]] --

RegisterServerEvent("VICE:CloseToRestartServer")
AddEventHandler("VICE:CloseToRestartServer", function(x)
    CloseToRestart = x 
end)


exports("getServerStatus", function(params, cb)
    if CloseToRestart then
        cb("❌ Offline")
    elseif config.whitelist then
        cb("<:beta:1222020883024187503> Beta")
    else
        cb("✅ Online") 
    end
end)

exports("getConnected", function(params, cb)
    local success, result = pcall(function()
        if VICE.getUserSource(params[1]) then
            cb('connected')
        else
            cb('not connected')
        end
    end)

    if not success then
       -- print("Error for getConnected:", result)
    end
end)

-- FPS shit

RegisterServerEvent("VICE:FPS:Update",function(fps)
    local source = source
    local user_id = VICE.getUserId(source)
    if not user_id then
        return
    end
    table.insert(VICE.averagefps[user_id],fps)
end)

-- [[ Misc Idk ]] --

local UUIDs = {}

local uuidTypes = {
    ["alphabet"] = "abcdefghijklmnopqrstuvwxyz",
    ["numerical"] = "0123456789",
    ["alphanumeric"] = "abcdefghijklmnopqrstuvwxyz0123456789",
}

local function randIntKey(length,type)
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

function generateUUID(key,length,type)
    if UUIDs[key] == nil then
        UUIDs[key] = {}
    end

    if type == nil then type = "alphanumeric" end

    local uuid = randIntKey(length,type)
    if UUIDs[key][uuid] then
        while UUIDs[key][uuid] do
            uuid = randIntKey(length,type)
            Wait(0)
        end
    end
    UUIDs[key][uuid] = true
    return uuid
end

local devs = {
    [1] = true,
    [2] = true,
    
}

-- [[ Staff ]] --

local adminlevels = {
    ["Founder"] = 12,
    ["Lead Developer"] = 11,
    ["Developer"] = 10,
    ["Community Manager"] = 9,
    ["Staff Manager"] = 8,
    ["Head Administrator"] = 7,
    ["Senior Administrator"] = 6,
    ["Administrator"] = 5,
    ["Senior Moderator"] = 4,
    ["Moderator"] = 3,
    ["Support Team"] = 2,
    ["Trial Staff"] = 1,
    ["User"] = 0,
}


function VICE.isDeveloper(user_id)
    if IsDuplicityVersion() then
        return devs[tonumber(user_id)]
    else
        return devs[VICE.getUserId()]
    end
end

function VICE.GetStaffTable()
    return adminlevels
end

function VICE.GetStaffLevel(user_id)
    adminlevel = 0
    for k, v in pairs(adminlevels) do
        if VICE.hasGroup(user_id, k) then
            adminlevel = v
            if v >= 10 then
                VICEclient.setDev(VICE.getUserSource(user_id),{})
            end
            break
        end
    end
    return adminlevel
end



