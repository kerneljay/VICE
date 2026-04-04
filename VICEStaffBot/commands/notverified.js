const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "You are not verified",
        "description": "In order to see channels in this discord, you must be verified in our main discord. Head over there and see the #verify channel.",
        "color": settingsjson.settings.botColour,
    };
    message.channel.send({ embed });
    message.channel.send("discord.gg/vice5m");
};

exports.conf = {
    name: "supportdcmessage",
    perm: 0,
    guild: "1191170042549772540",
    support: true,
};
