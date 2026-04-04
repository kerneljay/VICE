const fetch = require('node-fetch');
const settingsjson = require(resourcePath + '/settings.js');

const statusMap = {
    online: {
        text: 'Online',
        emoji: '🟢',
    },
    idle: {
        text: 'Idle',
        emoji: '🌙',
    },
    dnd: {
        text: 'Do Not Disturb',
        emoji: '🔴',
    },
    offline: {
        text: 'Offline',
        emoji: '⚫',
    },
};

exports.runcmd = async (fivemexports, client, message, params) => {
    if (!client) {
        console.error("Discord.js client is not properly initialized.");
        return;
    }

    const discordID = params[0];
    if (!discordID || !discordID.match(/^\d{17,19}$/)) {
        const embed = {
            "title": "Discord ID Lookup",
            "description": "Please provide a valid Discord ID in the format `!dlookup [DISCORD_ID]`.",
            "color": settingsjson.settings.botErrorColour,
        };
        message.channel.send({ embed });
        return;
    }

    try {
        const response = await fetch(`https://discord.com/api/v11/users/${discordID}`, {
            method: 'GET',
            headers: {
                Authorization: `Bot ${client.token}`
            }
        });

        if (response.status === 404) {
            const embed = {
                "title": "Discord ID Lookup",
                "description": "User not found.",
                "color": settingsjson.settings.botErrorColour,
            };
            message.channel.send({ embed });
            return;
        }

        const member = message.guild.members.get(discordID);

        if (!member && discordID !== message.author.id) {
            const embed = {
                "title": "Discord ID Lookup",
                "description": "User not found in this server.",
                "color": settingsjson.settings.botErrorColour,
            };
            message.channel.send({ embed });
            return;
        }

        const user = member ? member.user : message.author;

        const userGuilds = client.guilds.filter(guild => guild.members.has(discordID)).map(guild => guild.name).join('\n');

        const discordProfileLink = `https://lookup.guru/${discordID}`;

        const avatarURL = `https://cdn.discordapp.com/avatars/${discordID}/${user.avatar}.png`;

        const formattedCreationDate = new Date(user.createdAt).toLocaleString('en-UK', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric'
        });

        const richPresenceActivities = user.presence.activities.map(activity => {
            let activityDetails = `*${activity.name}*`;
            if (activity.type === 'PLAYING') {
                activityDetails += `\n${activity.details}`;
                if (activity.state) {
                    activityDetails += `\n${activity.state}`;
                }
            }
            return activityDetails;
        });

        const richPresence = richPresenceActivities.join('\n') || "None";

        const status = user.presence.status;
        const statusInfo = statusMap[status] || { text: 'Unknown', emoji: '❓' };

        const richPresenceImages = user.presence.activities
        .filter(activity => activity.assets && activity.assets.largeImage) 
        .map(activity => {
            return {
                "thumbnail": {
                    "url": activity.assets.largeImageURL,
                },
            };
        });
    
    const richPresenceImagesString = richPresenceImages.map(image => {
        return `**${image.name}**\n${image.value}`;
    }).join('\n');

    const richPresenceEmbed = {
        "title": `Rich Presence for ${user.tag}`,
        "color": settingsjson.settings.botColour,
        "timestamp": new Date(),
        "thumbnail": richPresenceImages.length > 0 ? richPresenceImages[0].thumbnail : null,
        "fields": [],
    };
    
    richPresenceActivities.forEach((activity, index) => {
        const activityData = activity.split('\n');
        let title = "Unknown Activity";
        let description = "";
    
        if (activityData.length > 0) {
            title = activityData[0];
        }
    
        if (activityData.length > 1) {
            description = activityData.slice(1).join('\n');
        }
    
        richPresenceEmbed.fields.push({
            "name": `Activity ${index + 1} - ${title}`,
            "value": description,
        });
    });
    
    const embed = {
    "title": `Discord ID Lookup for ${user.tag}`,
    "color": settingsjson.settings.botColour,
    "timestamp": new Date(),
    "thumbnail": {
        "url": avatarURL,
    },
    "fields": [
        {
            "name": "User Type",
            "value": user.bot ? "Bot Account" : "Normal Account",
            "inline": true
        },
        {
            "name": "Creation Date",
            "value": formattedCreationDate,
            "inline": true,
        },
        {
            "name": "Account Age",
            "value": agearroony(user.createdAt),
            "inline": true,
        },
        {
            "name": "Status",
            "value": `${statusInfo.emoji} ${statusInfo.text}`,
        },
        {
            "name": "Mention",
            "value": user.toString(),
        },
        {
            "name": "Discord ID",
            "value": `[${discordID}](${discordProfileLink})`,
            "inline": true,
        },
        {
            "name": "User's Guilds",
            "value": userGuilds || "Not in any guilds with the bot.",
            "inline": false,
        },
    ],
};

message.channel.send({ embed });
// message.channel.send({ embed: richPresenceEmbed });
    } catch (error) {
        console.error("Error fetching user data:", error);
        const embed = {
            "title": "Discord ID Lookup",
            "description": "User not found or an error occurred.",
            "color": settingsjson.settings.botErrorColour,
        };
        message.channel.send({ embed });
    }
};

exports.conf = {
    name: "dlookup",
    perm: 6,
    guild: "1458466924974313527",
    support: true,
};

function agearroony(createdAt) {
    const now = new Date();
    const diff = now - createdAt;
    const ageInMilliseconds = Math.abs(diff);
    const ageInMonths = Math.floor(ageInMilliseconds / (1000 * 60 * 60 * 24 * 30.44));
    const ageInYears = Math.floor(ageInMonths / 12);
    return `${ageInYears} years and ${ageInMonths % 12} months`;
}