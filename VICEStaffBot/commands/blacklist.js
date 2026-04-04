const settingsjson = require(resourcePath + '/settings.js');
const Discord = require('discord.js');
const client = new Discord.Client();

exports.runcmd = async (fivemexports, client, message, params) => {
    const discordId = params[0];
    if (!discordId || !discordId.match(/^\d{17,19}$/)) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!blacklist [discord_id]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    try {
        const result = await fivemexports.vice.execute("SELECT * FROM `vice_blacklisted` WHERE discord_id = ?", [discordId]);

        if (!result || (Array.isArray(result) && result.length === 0)) {
            await fivemexports.vice.execute("INSERT INTO `vice_blacklisted` (discord_id, blacklisted) VALUES (?, 1)", [discordId]);
        } else {
            await fivemexports.vice.execute("UPDATE `vice_blacklisted` SET blacklisted = 1 WHERE discord_id = ?", [discordId]);
        }

        let embed = {
            "title": "Blacklist a user",
            "description": `Discord ID **${discordId}** has been blacklisted. \nThey can no longer join **VICE Public.**`,
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };

        message.channel.send({ embed });
    } catch (error) {
        console.error("Error blacklisting Discord ID:", error);

        if (error.response && error.response.status === 404) {
            console.error("Error sending webhook: 404 status code. Response:", error.response.data);
            let embed = {
                "title": "Blacklist a user",
                "description": "Error sending webhook: Unknown Webhook",
                "color": settingsjson.settings.botColour,
                "timestamp": new Date()
            };
            return message.channel.send({ embed });
        }

        let embed = {
            "title": "Blacklist a user",
            "description": "An error occurred while blacklisting the Discord ID.",
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "blacklist",
    perm: 10,
    guild: "1458466924974313527"
};
