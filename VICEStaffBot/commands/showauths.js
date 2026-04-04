const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (params.length !== 1) {
        return message.channel.send("Usage: !showauthids <Discord ID>");
    }

    const discordID = params[0];

    let authData = {};
    try {
        authData = JSON.parse(fs.readFileSync('authids.json', 'utf8'));
    } catch (error) {
        authData = {};
    }

    if (authData[discordID]) {
        const authList = authData[discordID].map(item => `${item.authID} - ${item.description}`).join('\n');
        let embed = {
            "title": "Authorization Check",
            "description": `Discord ID ${discordID} \n\n${authList}`,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed })
    } else {
        let embed = {
            "title": "Authorization Check",
            "description": `No Authorization ids for ${discordID}`,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed })
    }
};

exports.conf = {
    name: "showauthids",
    perm: 0,
    guild: "1191170042549772540",
    support: true,
};