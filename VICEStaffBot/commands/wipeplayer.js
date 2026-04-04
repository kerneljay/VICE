const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    const user_id = params[0];

    if (!user_id || !parseInt(user_id)) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!wipeplayer [permid]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    const userConnected = await isPlayerConnected(fivemexports, user_id);

    if (userConnected) {
        let embed = {
            "title": "Wipe Player",
            "description": `Player is in-game, Cannot preform a wipe.\n\nID: **${user_id}**\nStatus: **Connected**`,
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    const deletedTables = [];
    
    // vice_casino_chips
    const deleteQuery1 = `DELETE FROM vice_casino_chips WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery1, [user_id], "\nCasino");

    // vice_custom_garages
    const deleteQuery2 = `DELETE FROM vice_custom_garages WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery2, [user_id], "Custom Folders");

    // vice_daily_rewards
    const deleteQuery3 = `DELETE FROM vice_daily_rewards WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery3, [user_id], "Daily Rewards");

    // vice_quests
    const deleteQuery5 = `DELETE FROM vice_quests WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery5, [user_id], "Quests");

    // vice_stores
    const deleteQuery6 = `DELETE FROM vice_stores WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery6, [user_id], "Stores");

    // vice_subscriptions
    const deleteQuery7 = `DELETE FROM vice_subscriptions WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery7, [user_id], "Vipclub");

    // vice_user_vehicles
    const deleteQuery8 = `DELETE FROM vice_user_vehicles WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery8, [user_id], "Vehicles");

    // vice_weapon_whitelists
    const deleteQuery9 = `DELETE FROM vice_weapon_whitelists WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery9, [user_id], "Weapon Whitelists");

    // vice_user_moneys
    const deleteQuery10 = `DELETE FROM vice_user_moneys WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery10, [user_id], "Money");

    // vice_user_identities
    const deleteQuery11 = `DELETE FROM vice_user_identities WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery11, [user_id], "Identities");

    // vice_user_homes
    const deleteQuery12 = `DELETE FROM vice_user_homes WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery12, [user_id], "Homes");

    // vice_user_gangs
    const deleteQuery13 = `DELETE FROM vice_user_gangs WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery13, [user_id], "Gangs");

    // vice_user_data
    const deleteQuery14 = `DELETE FROM vice_user_data WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery14, [user_id], "User Data");

    // vice_weapon_codes
    const deleteQuery15 = `DELETE FROM vice_weapon_codes WHERE user_id = ?`;
    checkAndExecuteQuery(deleteQuery15, [user_id], "Weapon codes");

    // vice_srv_data
    const deleteQuery16 = `DELETE FROM vice_srv_data WHERE dkey LIKE ?`;
    const dkeyPattern = `chest:u1veh_%|${user_id}`;
    checkAndExecuteQuery(deleteQuery16, [dkeyPattern], "Boot data");

    executeQueries();

    async function executeQueries() {
        try {
            await Promise.all([
                checkAndExecuteQuery(deleteQuery1, [user_id], "vice_casino_chips"),
                checkAndExecuteQuery(deleteQuery2, [user_id], "vice_custom_garages"),
                checkAndExecuteQuery(deleteQuery3, [user_id], "vice_daily_rewards"),
                checkAndExecuteQuery(deleteQuery5, [user_id], "vice_quests"),
                checkAndExecuteQuery(deleteQuery6, [user_id], "vice_stores"),
                checkAndExecuteQuery(deleteQuery7, [user_id], "vice_subscriptions"),
                checkAndExecuteQuery(deleteQuery8, [user_id], "vice_user_vehicles"),
                checkAndExecuteQuery(deleteQuery9, [user_id], "vice_weapon_whitelists"),
                checkAndExecuteQuery(deleteQuery10, [user_id], "vice_user_moneys"),
                checkAndExecuteQuery(deleteQuery11, [user_id], "vice_user_identities"),
                checkAndExecuteQuery(deleteQuery12, [user_id], "vice_user_homes"),
                checkAndExecuteQuery(deleteQuery13, [user_id], "vice_user_gangs"),
                checkAndExecuteQuery(deleteQuery14, [user_id], "vice_user_data"),
                checkAndExecuteQuery(deleteQuery15, [user_id], "vice_weapon_codes"),
                checkAndExecuteQuery(deleteQuery16, [dkeyPattern], "vice_srv_data"),
            ]);
    
            sendEmbed();
        } catch (error) {
            console.error('Error executing queries:', error);
        }
    }    

    function checkAndExecuteQuery(query, params, tableName) {
        return new Promise((resolve, reject) => {
            fivemexports.vice.execute(query, params, (result) => {
                if (result.error) {
                    console.error(`Error executing query: ${query}`, result.error);
                    reject(result.error);
                } else {
                  //  console.log(`Query executed successfully: ${query}`);
                   // console.log(`Affected Rows: ${result.affectedRows}`);
                    if (result.affectedRows > 0) {
                        //console.log(`Adding ${tableName} to deletedTables array.`);
                        deletedTables.push(tableName);
                    } else {
                      //  console.log(`No rows affected for ${tableName}.`);
                    }
                    resolve();
                }
            });
        });
    }    

    function sendEmbed() {
        let embed;

        if (deletedTables.length > 0) {
            embed = {
                "title": "Wipe Player",
                "description": `Successfully wiped all player's data \n\nID: **${user_id}** \nTables:\n\`\`\`${deletedTables.join(",\n ")}\`\`\``,
                "color": settingsjson.settings.botColour,
            };
        } else {
            embed = {
                "title": "Wipe Player",
                "description": `No tables affected.\n\n ID: **${user_id}** \nStatus: **No data**`,
                "color": settingsjson.settings.botErrorColour,
            };
        }

        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "wipeplayer",
    perm: 11,
    guild: "1458466924974313527",
};

async function isPlayerConnected(fivemexports, user_id) {
    return new Promise((resolve) => {
        fivemexports.vice.getConnected([parseInt(user_id)], function (connected) {
            resolve(connected === 'connected');
        });
    });
}