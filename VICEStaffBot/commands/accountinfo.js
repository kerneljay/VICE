const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || isNaN(params[0])) {
        const embed = {
            title: "An Error Occurred",
            description: `Incorrect Usage\n\nCorrect Usage: \`${process.env.PREFIX}!accountinfo [user_id]\``,
            color: settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }

    const user_id = parseInt(params[0]);

    fivemexports.vice.execute("SELECT * FROM `vice_user_info` WHERE user_id = ?", [user_id], function (result) {
        if (result && result.length > 0) {
            const userInfo = result[0];
            const trimmedGPU = userInfo.gpu.replace(/Direct3D.*D3D\d+/i, "").trim();
            const osVersionMatch = userInfo.user_agent.match(/Windows NT \d+\.\d+/);
            const osVersion = osVersionMatch ? osVersionMatch[0] : "Not Available";
            const profileVisibility = convertVisibility(parseInt(userInfo.profile_visibility));
            const communityVisibility = convertVisibility(parseInt(userInfo.community_visibility));  
            const lastLogOffStatus = getLastLogOffStatus(userInfo.last_logoff);
            const devices = userInfo.devices.split('\n').map(device => device.trim().split(':')[1]).join('\n');

            const embed = {
                title: `Account Information for ID ${user_id}`,
                fields: [
                    { name: 'Status', value: `${lastLogOffStatus}`, inline: true },
                    { name: 'Profile Visibility', value: `${profileVisibility}`, inline: true },
                    { name: 'Community Visibility', value: `${communityVisibility}`, inline: true },
                    { name: 'Banned', value: userInfo.banned ? "Yes" : "No", inline: true },
                    { name: 'Steam Age', value: `${userInfo.steam_age}`, inline: true },
                    { name: 'Country Code', value: `${userInfo.country_code}`, inline: true },
                    // { name: 'Device', value: `${userInfo.device}`, inline: true }, // tayser
                    { name: 'CPU Cores', value: `${userInfo.cpu_cores}`, inline: true },
                    { name: 'GPU', value: `${trimmedGPU}`, inline: true },
                    { name: 'User Agent OS', value: `${osVersion}`, inline: true },
                    { name: 'Steam ID', value: `${userInfo.steam_id}`, inline: true },
                    { name: 'Steam Name', value: `${userInfo.steam_name}`, inline: true },
                    { name: 'Steam Country', value: `${userInfo.steam_country}`, inline: true },
                    { name: 'Steam Creation Date', value: `${userInfo.steam_creation_date}`, inline: true },
                    { name: 'Devices', value: `${devices}`, inline: true }, 
                    { name: 'Real Name', value: `${userInfo.real_name}`, inline: true },
                ],
                color: settingsjson.settings.botColour,
                footer: { text: "" },
                timestamp: new Date(),
                thumbnail: { url: userInfo.avatar_url }
            };
            message.channel.send({ embed });
        } else {
            const embed = {
                title: `User ID ${user_id} not found`,
                color: settingsjson.settings.botErrorColour,
                timestamp: new Date()
            };
            message.channel.send({ embed });
        }
    });
};

exports.conf = {
    name: "accountinfo",
    perm: 7,
    guild: "1458466924974313527"
};

function convertVisibility(visibility) {
    switch (visibility) {
        case 1:
            return "Private";
        case 2:
            return "Friends";
        case 3:
            return "Public";
        default:
            return "Not Available";
    }
}

function getLastLogOffStatus(lastLogOff) {
    const onlineThreshold = 300;  

    if (lastLogOff === 0) {
        return "Online";
    } else if (lastLogOff > 0) {
        const currentTime = Math.floor(Date.now() / 1000);
        const timeSinceLastLogOff = currentTime - lastLogOff;

        if (timeSinceLastLogOff < onlineThreshold) {
            return "Online";
        } else if (timeSinceLastLogOff < 1800) {  
            return "Away";
        } else {
            return "Offline";
        }
    } else {
        return "Not Available";
    }
}