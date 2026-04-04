const fs = require('fs');
const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    if (params.length !== 2) {
        return message.channel.send("Usage: !removeauthid <Discord ID> <Authorization ID>");
    }

    const discordID = params[0];
    const authIDToRemove = params[1];

    let authData = {};
    try {
        authData = JSON.parse(fs.readFileSync('authids.json', 'utf8'));
    } catch (error) {
        authData = {};
    }

    if (!authData[discordID]) {
        return message.channel.send(`No authorization IDs found for Discord ID ${discordID}.`);
    }

    const authIndex = authData[discordID].findIndex(item => item.authID === authIDToRemove);

    if (authIndex === -1) {
        return message.channel.send(`Authorization ID ${authIDToRemove} not found for Discord ID ${discordID}.`);
    }

    authData[discordID].splice(authIndex, 1);

    fs.writeFileSync('authids.json', JSON.stringify(authData, null, 4), 'utf8');

    let embed = {
        "title": "Authorization IDs",
        "description": `Removed ID: ${authIDToRemove}\n\nDiscord ID ${discordID}`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed });
};

exports.conf = {
    name: "removeauthid",
    perm: 0,
    guild: "1191170042549772540",
    support: true,
};