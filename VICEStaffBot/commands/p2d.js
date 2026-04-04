const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let result = [];

    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: " + process.env.PREFIX + '\n`p2d [perm_id]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    if (params[0] && parseInt(params[0])) {
        fivemexports.vice.execute("SELECT discord_id FROM `vice_verification` WHERE user_id = ?", [params[0]], (queryResult) => {
            result = queryResult; 
            if (result.length > 0) {
                const discordID = result[0].discord_id; 
                const discordProfileLink = `https://lookup.guru/${discordID}`;

                let embed = {
                    "title": "Perm ID to Discord",
                    "description": `\n\n **Perm ID:** ${params[0]}\n**Discord:** <@${discordID}> \n**Discord ID:** [${discordID}](${discordProfileLink})`,
                    "color": settingsjson.settings.botColour,
                    "timestamp": new Date()
                }
                message.channel.send({ embed });
            } else {
                let embed = {
                    "title": "Perm ID to Discord",
                    "description": `\n\n Perm ID: **${params[0]}** has not yet been registered.`,
                    "color": settingsjson.settings.botColour,
                    "timestamp": new Date()
                }
                message.channel.send({ embed });
            }
        });
    } else {
        let embed = {
            "title": "Perm ID to Discord",
            "description": `\n\n Linked Discords: ${result.length > 0 ? `<@${result[0].discord_id}>` : 'None'}\n\nVerified Discord: Non Found`,
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        }
        message.channel.send({ embed });
    }
}

exports.conf = {
    name: "p2d",
    perm: 1,
    guild: "1458466924974313527",
    support: true,
}
