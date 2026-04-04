const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!did2p [discord_id]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    if (params.length === 1) {
        let discordId = params[0];
        const discordProfileLink = `https://lookup.guru/${discordId}`;
        let regex = /^\d+$/;

        if (discordId.match(regex)) {
            fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [discordId], (result) => {
                if (result.length > 0) {
                    let embed = {
                        "title": "Discord ID to Perm ID",
                        "description": `\nPerm ID: **${result[0].user_id}**\nDiscord ID: **[${discordId}](${discordProfileLink})**`,
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    };
                    message.channel.send({ embed });
                } else {
                    let embed = {
                        "title": "An Error Occurred",
                        "description": "No account is linked for this user.",
                        "color": settingsjson.settings.botErrorColour,
                    };
                    message.channel.send({ embed });
                }
            });
        } else {
            let embed = {
                "title": "An Error Occurred",
                "description": "Invalid Discord ID format\n\nPlease provide a valid Discord ID (NUMBERS ONLY)",
                "color": settingsjson.settings.botErrorColour,
            };
            message.channel.send({ embed });
        }
    } 
};

exports.conf = {
    name: "did2p",
    perm: 1,
    guild: "1458466924974313527",
    support: true,
};