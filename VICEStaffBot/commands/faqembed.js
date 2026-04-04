const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "VICE Community Information",
        "color": settingsjson.settings.botColour,
        "fields": [
            {
                "name": "Bug Report",
                "value": "[report-a-bug](https://discord.com/channels/1458466924974313527/1168904479672893601)",
            },
            {
                "name": "Suggestion",
                "value": "[create-suggestions](https://discordapp.com/channels/1458466924974313527/1168904475939983431)",
            },
            {
                "name": "Just Donated?",
                "value": "[support-tickets](https://discord.com/channels/1458466924974313527/1168904440259035177)",
            },
            {
                "name": "Reporting an Officer",
                "value": "DM Silver Command+",
            },
            {
                "name": "Reporting a Medic",
                "value": "DM the chief of NHS",
            },
            {
                "name": "Community Concern",
                "value": "DM the <@&1237182920569917549> or leave it in [feedback](https://discordapp.com/channels/1458466924974313527/1239943049312735335)",
            },
            {
                "name": "Banned Inquiry",
                "value": "Join 'Waiting for Support' on Discord",
            },
            {
                "name": "Interested in Donating",
                "value": "All information is available at the [store](https://discordapp.com/channels/1458466924974313527/1168904455866024016)",
            },
            {
                "name": "Donation Perk Question",
                "value": "[support-tickets](https://discordapp.com/channels/1458466924974313527/1168904475939983431)",
            },
            {
                "name": "Exploit Report",
                "value": "DM any admin+",
            },
            {
                "name": "Staff Member Report",
                "value": "DM the <@&1237182920569917548> or <@&1237182920569917547>",
            },
            {
                "name": "Discord Tag",
                "value": "[tag-request](https://discord.com/channels/1458466924974313527/1239943645256351754) or use !getroles",
            },
            {
                "name": "Car Report",
                "value": "Use !carreport",
            },
        ],
    };

    message.channel.send({embed});
};

exports.conf = {
    name: "communityinfo",
    perm: 11,
    guild: "1458466924974313527",
};
