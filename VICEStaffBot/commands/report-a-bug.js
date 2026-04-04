const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "Bug Report Information",
        "color": settingsjson.settings.botColour,
        "fields": [
            {
                "name": "Progress of Bug Reports",
                "value": "https://github.com/orgs/vicestudiosuk/projects/2",
            },
            {
                "name": "Report Issues",
                "value": "https://github.com/vicestudiosuk/issue-tracker/issues",
            },
        ],
    };

    message.channel.send({embed});
};

exports.conf = {
    name: "bugreportinfo",
    perm: 11,
    guild: "1458466924974313527",
};
