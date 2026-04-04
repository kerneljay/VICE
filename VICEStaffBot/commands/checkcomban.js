const settingsjson = require(resourcePath + '/settings.js');
const Discord = require('discord.js');
const client = new Discord.Client();

exports.runcmd = async (fivemexports, client, message, params) => {
    const discordId = params[0];
    if (!discordId || !discordId.match(/^\d{17,19}$/)) {
        let embed = {
            "title": "Community Ban Check",
            "description": "Please provide a valid Discord ID to check for bans.",
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        return message.channel.send({ embed });
    }

    try {
        const guilds = client.guilds.array();
        let bannedGuilds = [];
        let inGameBanStatus = false;
        let userId = null;

        await fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [discordId], async (adminResult) => {
            if (adminResult.length > 0) {
                userId = adminResult[0].user_id;

                fivemexports.vice.execute("SELECT * FROM `vice_users` WHERE id = ?", [userId], async (result) => {
                    if (result.length > 0) {
                        if (result[0].banned) {
                            let baninfo = result[0].baninfo
                            if (baninfo == null) {
                                baninfo = "No ban info provided"
                            }
                            var banExpires = new Date(result[0].bantime * 1000)
                            if (banExpires == "Invalid Date") {
                                banExpires = "Never"
                            }
                            var embed = {
                                "title": `Checking Ban Status for ${result[0].username}`,
                                "description": `Discord ID: [${discordId}](https://lookup.guru/${discordId})\nPerm ID: **${userId}**\nIn-game Ban: **true**\nPlayer Name: **${result[0].username}**\nPlayer PermID: **${result[0].id}**\nBan Reason: **${result[0].banreason}**\nBan Expires: **${banExpires}**\nBan Admin: **${result[0].banadmin}**\nBan Info: **${result[0].baninfo}**`,
                                "color": settingsjson.settings.botColour,
                                "footer": {
                                    "text": ""
                                },
                                "timestamp": new Date()
                            }
                            inGameBanStatus = true;
                        }
                    }

                    for (const guild of guilds) {
                        await guild.fetchBans()
                            .then(async (bans) => {
                                if (bans.has(discordId)) {
                                    bannedGuilds.push(guild.name);
                                }
                            })
                            .catch(error => {
                                console.error(error);
                            });
                    }

                    let description = `Discord ID: [${discordId}](https://lookup.guru/${discordId})\nPerm ID: **${userId}**\nIn-game ban: **${inGameBanStatus}**\n`;

                    if (bannedGuilds.length > 0) {
                        let embed = {
                            "title": "Community Ban Check",
                            "description": description + `\n**Banned Servers:**\n${bannedGuilds.join('\n')}`,
                            "color": settingsjson.settings.botColour,
                            "timestamp": new Date()
                        };
                        message.channel.send({ embed });
                    } else {
                        let embed = {
                            "title": "Community Ban Check",
                            "description": description + `\n> User <@${discordId}> is not banned from any vice-related servers, including in-game and discords.`,
                            "color": settingsjson.settings.botColour,
                            "timestamp": new Date()
                        };
                        message.channel.send({ embed });
                    }
                });
            } else {
                message.reply('User does not have a Perm ID linked to their discord.');
            }
        });
    } catch (error) {
        console.error("Error checking bans:", error);
        let embed = {
            "title": "Community Ban Check",
            "description": "An error occurred while checking bans.",
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "checkcom",
    perm: 10,
    guild: "1458466924974313527"
};