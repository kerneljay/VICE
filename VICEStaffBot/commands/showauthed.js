const fs = require('fs');

exports.runcmd = (fivemexports, client, message, params) => {
    if (params.length !== 0) {
        return message.channel.send("Usage: !showauthed");
    }

    let verifiedData = {};
    try {
        verifiedData = JSON.parse(fs.readFileSync('verifiedauths.json', 'utf8'));
    } catch (error) {
        verifiedData = {};
    }

    if (Object.keys(verifiedData).length === 0) {
        return message.channel.send("No verified Authorization IDs found.");
    }

    let authList = "";

    for (const discordID in verifiedData) {
        const authEntries = verifiedData[discordID].map(item => `${item.code}`).join(', ');
        const discordProfileLink = `https://lookup.guru/${discordID}`;
        authList += `Discord ID [${discordID}](${discordProfileLink})\nAuthed Codes: ${authEntries}\n\n`;
    }

    let embed = {
        "title": "Verified Authorization IDs",
        "description": authList,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed });
};

exports.conf = {
    name: "showauthed",
    perm: 0,
    guild: "1191170042549772540",
    support: true,
};
