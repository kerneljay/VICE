const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let mentionedUser = message.mentions.members.first() || message.author;

    if (!mentionedUser) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: " + process.env.PREFIX + "permid [mention] or [reply]",
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [mentionedUser.id], (result) => {
        if (result.length > 0) {
            let embed = {
                "title": "Perm ID for " + (mentionedUser.user ? mentionedUser.user.username : mentionedUser.username),
                "description": `\n\`\`\`${result[0].user_id}\`\`\``,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": `VICE`
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed });
        } else {
            let embed = {
                "title": "An Error Occurred",
                "description": `No IDs found for ${(mentionedUser.user ? mentionedUser.user.username : mentionedUser.username)}`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": `VICE`
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed });
        }
    });
};

exports.conf = {
    name: "permid",
    perm: 1,
    guild: "1458466924974313527",
    support: true,
};
