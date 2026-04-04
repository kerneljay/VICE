const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "Welcome to VICE",
        "description": "Discord guild rules: \n```- Do not send any nsfw content. \n- Do not spam.\n- Do not tag any staff members unless solicited.\n- Do not advertise other communities & personal projects.\n- Do not use a transparent discord profile picture.\n- Do not send any racist, sexist, toxic or hate speech messages, (nicknames & status' included)\n- Do not talk about cheating or post any cheating related links/images/videos  \n - We ask you speak English only.```",
        "color": settingsjson.settings.botColour,
        "fields": [
            {
                name: "<:vice:1191336281263841290> Website",
                value: "**soon**",
                inline: true
            },
            {
                name: "<:store:1168997677963419739> Store",
                value: "**soon**",
                inline: true
            },
            {
                name: "<:5m:1168997676243755108> FiveM Server IP",
                value: "**soon**",
                inline: true
            },
            {
                name: "<:discord:1191337326153056316> Discord",
                value: "[vicerp](https://discord.gg/vice5m)",
                inline: true
            },
            {
                name: "<:twitter:1168997672322088970> Twitter",
                value: "**soon**",
                inline: true
            },
            {
                name: "<:teamspeak:1168997674436001873> TeamSpeak",
                value: "**soon**",
                inline: true
            },
        ]
    };
    message.channel.send({ embed });
};

exports.conf = {
    name: "welcome",
    perm: 11,
    guild: "1458466924974313527"
};
