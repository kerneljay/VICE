const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "Hey, welcome to VICE!",
        "description": "If you'd like to know how you can start playing follow the instructions below. \n\n<:vice2:1257500713253077043> VICE FiveM is available on PC only. \n\n<:fivem:1261900819033493627> Download and install **FiveM** https://fivem.net/ \n\n<:vicesearch:1261904764279586868> Search **VICE** in the server browser and press connect and you'll be presented with a verification code. \n\n<:yes:1254855168495845578> Verify by typing `!verify [verification_code]` in https://discord.com/channels/1458466924974313527/1258210949765140602 \n\n <:danny2:1254855118453477478> You'll now have access to the full discord & VICE in-game.",
        "color": settingsjson.settings.botColour,
    };
    message.channel.send({ embed });
};

exports.conf = {
    name: "howtoplay",
    perm: 11,
    guild: "1458466924974313527"
};
