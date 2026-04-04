const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    if (!message.member.hasPermission('BAN_MEMBERS')) {
        let embed = {
            "title": "Community Unban",
            "description": "You don't have permission to unban members.",
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    const discordId = params[0];

    if (!discordId) {
        let embed = {
            "title": "",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + "\n`!uncomban [discord-id]`",
            "color": settingsjson.settings.botErrorColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    try {
        const guilds = client.guilds.array();
        let unbannedFromAll = true;

        for (const guild of guilds) {
            await guild.fetchBans()
                .then(async (bans) => {
                    if (bans.has(discordId)) {
                        await guild.unban(discordId);
                        unbannedFromAll = false;
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        }

        fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [discordId], async (adminResult) => {
            if (adminResult.length > 0) {
                const permId = adminResult[0].user_id;

                const result = fivemexports.vice.VICEStaffBot('setBanned', [permId, false]);

              //  let description = `**Discord ID:** [${discordId}](https://lookup.guru/${discordId})\n`;
              let description = ``;

                if (unbannedFromAll) {
                    description += `\n> User <@${discordId}> is not banned in any vice-related servers.`;
                } else {
                    description += `\n> User <@${discordId}> has been unbanned from all vice-related servers, including in-game and discords.`;
                }

                let embed = {
                    "title": "",
                    "description": description,
                    "color": settingsjson.settings.botColour,
                };
                message.channel.send({ embed });
            } else {
                message.reply('User does not have a Perm ID linked to their discord.');
            }
        });
    } catch (error) {
        console.error("Error unbanning user:", error);
        let embed = {
            "title": "Community Unban",
            "description": "An error occurred while unbanning the user.",
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "uncomban",
    perm: 10,
    guild: "1458466924974313527"
};
