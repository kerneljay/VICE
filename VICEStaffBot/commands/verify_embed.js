const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "!verify Instructions",
        "description": "Connect to VICE to recieve your 6 digit code in order to verify your account. Once you have your code, type the following command. \n\n`!verify XXXXXX` \n\nPlease replace `XXXXXX` with your 6 digit code provided in the box highlighted red.",
        "color": settingsjson.settings.botColour,
    };
    message.channel.send({ embed });
};

exports.conf = {
    name: "verified",
    perm: 11, //
    guild: "1458466924974313527"
};
