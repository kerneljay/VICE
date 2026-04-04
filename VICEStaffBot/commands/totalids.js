const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.vice.execute("SELECT id, username FROM `vice_users`", [], (result) => {
        if (result.length > 0) {
            let registeredIds = result.filter(entry => entry.username !== null);
            let unregisteredIds = result.filter(entry => entry.username === null);

            let totalRegisteredIds = registeredIds.length;
            let totalUnregisteredIds = unregisteredIds.length;

            let registeredIdsList = registeredIds.map(entry => `${entry.id} - ${entry.username}`).join('\n');
            let unregisteredIdsList = unregisteredIds.map(entry => `${entry.id}`).join('\n');

            let embed = {
                "title": "PermID's",
                "description": `\nRegistered\n\`\`\`${registeredIdsList}\`\`\`\nUnregistered\n\`\`\`${unregisteredIdsList}\`\`\`\nTotal Registered IDs: ${totalRegisteredIds}\nTotal Unregistered IDs: ${totalUnregisteredIds}`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": `VICE`
                },
                "timestamp": new Date()
            };

            message.channel.send({ embed });
        } else {
            let embed = {
                "title": "No IDs Found",
                "description": `There are no PermIDs in the database.`,
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
    name: "totalids",
    perm: 11,
    guild: "1458466924974313527",
    support: true,
};
