const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "You are not staff",
        "description": "In order to see channels in this discord, you must be staff in our main discord.",
        "color": settingsjson.settings.botColour,
    };
    message.channel.send({ embed });
    message.channel.send("discord.gg/vice5m");
};

exports.conf = {
    name: "logdcmessage",
    perm: 0,
    guild: "1166684483831996448",
};
