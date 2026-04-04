const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    if (!message.guild.me.hasPermission('BAN_MEMBERS')) {
        message.reply('No permissions to ban.');
        return;
    }

    const discordId = params[0];

    if (!discordId) {
        let embed = {
            "title": "",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + "\n`!comban [discord-id] [reason]`",
            "color": settingsjson.settings.botErrorColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    const user = message.guild.members.get(discordId);

    if (!user) {
        let embed = {
            "title": "An Error Occurred",
            "description": "User was not detected in this guild.",
            "color": settingsjson.settings.botErrorColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }
    const permID = params[0];

    if (discordId === '239792203927388161' || discordId === '1014844514894106705' || discordId === '422444198835257363' || discordId === '620232047671377931') {
        let embed = {
            "title": "Cannot Ban",
            "description": "Can't ban this User ID: `" + discordId + "`",
            "color": settingsjson.settings.botColour,
            "thumbnail": {
            }
        };
        return message.channel.send({ embed });
    }

    let adminPermID;
    await fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [discordId], async (adminResult) => {
        if (adminResult.length > 0) {
            adminPermID = adminResult[0].user_id;
            let reason = params.slice(1).join(" ");
            let banTime = "perm";

            await user.ban({ reason: `Community Ban - Reason: ${reason}` })
                .then(async () => {
                    let embed = {
                        "title": "",
                        "description": `> User <@${discordId}> has been community banned from all vice-related servers, including in-game and discords.`,
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

                    if (banTime === "perm") {
                        let newval = fivemexports.vice.VICEStaffBot('banDiscord', [adminPermID, "perm", `Community Ban`, `${message.author.tag}`]);
                    } else {
                        let newval = fivemexports.vice.VICEStaffBot('banDiscord', [adminPermID, banTime, `${reason}`, `${message.author.tag}`]);
                    }
                })
                .catch(error => {
                    console.error(error);
                    let embed = {
                        "title": "An Error Occurred",
                        "description": "Failed to ban user, Contact <@620232047671377931> About this issue",
                        "color": settingsjson.settings.botErrorColour,
                        "timestamp": new Date()
                    };
                    return message.channel.send({ embed });
                });
        } else {
            message.reply('User does not have a Perm ID linked to their discord.');
        }
    });
}

exports.conf = {
    name: "comban",
    perm: 10,
    guild: "1458466924974313527"
};
