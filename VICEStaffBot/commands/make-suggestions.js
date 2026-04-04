const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "How to Make a Suggestion",
        "description": "Start off with `!suggest` and then type out your suggestion afterwards.",
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": "Please don't use this channel for general chit-chat. If you do, you may be muted.",
        },
    };

    message.channel.send({embed});
};

exports.conf = {
    name: "suggestioninfo",
    perm: 11,
    guild: "1458466924974313527",
};
