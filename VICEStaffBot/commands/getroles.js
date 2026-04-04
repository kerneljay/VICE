const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

let groups = [
    'Supporter',
    'Premium',
    'Supreme',
    'Kingpin',
    'Baller',
]

exports.runcmd = async (fivemexports, client, message, params) => {
    let rolesCount = 0;
    let rolesAdded = [];

    const addRoleByName = async (roleName) => {
        try {
            let role = message.guild.roles.find(r => r.name === `| ${roleName}`);
            if (!role || message.member.roles.has(role.id)) {
                return;
            }
            rolesAdded.push(`<@&${role.id}>`);
            rolesCount += 1;
            message.member.addRole(role.id);
        } catch (error) {
            // console.error('Error adding role');
        }
    };

    try {
        fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [message.author.id], async (result) => {
            try {
                if (result.length === 0) {
                    let notVerifiedEmbed = {
                        "title": "An Error Occurred",
                        "description": "You are not verified. Please contact management about your issue.",
                        "color": settingsjson.settings.botErrorColour,
                    }
                    message.channel.send({ embed: notVerifiedEmbed }).catch(() => {});
                    return;
                }

                let user_id = result[0].user_id;
                fivemexports.vice.execute("SELECT dvalue FROM `vice_user_data` WHERE user_id = ? AND dkey = 'VICE:datatable'", [user_id], async (data) => {
                    try {
                        let groupsdata = JSON.parse(Object.values(data[0])).groups;
                        for (const [key, value] of Object.entries(groupsdata)) {
                            for (j = 0; j < groups.length; j++) {
                                if (groups[j] === key) {
                                    addRoleByName(key); 
                                }
                            }
                        }

                        let playtime = data[0].PlayerTime / 60;
                        if (playtime > 1000) {
                            let role = message.guild.roles.find(r => r.name === `1,000 hours`);
                            if (role && !message.member.roles.has(role.id)) {
                                rolesCount++;
                                rolesAdded.push(`<@&${role.id}>`);
                                message.member.addRole(role.id); 
                            }
                        }

                        if (rolesCount === 0) {
                            let noRolesEmbed = {
                                "title": "",
                                "description": "You have no missing roles that need adding",
                                "color": settingsjson.settings.botErrorColour,
                            }
                            message.channel.send({ embed: noRolesEmbed }).catch(() => {});
                            return;
                        }

                        let embed = {
                            "title": "Added the following missing roles:",
                            "description": `${rolesAdded.join(', ')}`,
                            "color": settingsjson.settings.botColour,
                            "footer": {
                                "text": "VICE Studios"
                            },
                        }
                        message.channel.send({ embed: embed }).catch(() => {});
                    } catch (error) {
                        console.error('Error processing data:', error);
                    }
                });
            } catch (error) {
                console.error('Error querying user_id:', error);
            }
        });
    } catch (error) {
        console.error('Error executing SQL query:', error);
    }
}

exports.conf = {
    name: "getroles",
    perm: 0,
    guild: "1458466924974313527"
};
