const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    if (!message.guild.me.hasPermission('BAN_MEMBERS')) {
        return message.channel.send('No permissions to ban.');
    }

    const discordId = params[0];

    if (!discordId) {
        const embed = {
            "title": "",
            "description": "Incorrect Usage\n\nCorrect Usage: `" + process.env.PREFIX + "combandc [discord-id] [reason]`",
            "color": settingsjson.settings.botErrorColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    const user = message.guild.members.get(discordId);

    if (!user) {
        const embed = {
            "title": "An Error Occurred",
            "description": "User was not detected in this guild.",
            "color": settingsjson.settings.botErrorColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    let reason = params.slice(1).join(" ");

    await user.ban({ reason: `Community Ban - Reason: ${reason}` })
        .then(async () => {
            const embed = {
                "title": "",
                "description": `> User <@${discordId}> has been community banned from all vice-related discord servers.`,
                "color": settingsjson.settings.botColour,
            };
            await message.channel.send({ embed });

            client.guilds.forEach(async (guild) => {
                if (guild.id !== message.guild.id) {
                    await guild.fetchBans()
                        .then(async (bans) => {
                            if (!bans.has(user.id)) {
                                await guild.ban(user, { reason: `Community Ban - Reason: ${reason}` });
                            }
                        })
                        .catch(error => {
                            console.error(error);
                        });
                }
            });
        })
        .catch(error => {
            console.error(error);
            const embed = {
                "title": "An Error Occurred",
                "description": "Failed to ban the user. Please contact <@620232047671377931> about this issue.",
                "color": settingsjson.settings.botErrorColour,
                "timestamp": new Date()
            };
            return message.channel.send({ embed });
        });
};

exports.conf = {
    name: "combandc",
    perm: 10,
    guild: "1458466924974313527"
};