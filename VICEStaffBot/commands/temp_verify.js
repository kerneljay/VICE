const path = require('path');
const settings = require(path.join(global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname, 'settings.js'));

exports.runcmd = (fivemexports, client, message, params) => {
    const verificationEmbed = {
        title: "Temporary Verification",
        description: "As we approach release, We want you to engage with our community! To gain full access, react to this message and familiarize yourself with our rules.",
        color: settingsjson.settings.botErrorColour, 
    };

    message.channel.send({ embed: verificationEmbed });
    message.channel.send(`@everyone`);
};

exports.conf = {
    name: "tempverify",
    perm: 11,
    guild: "1458466924974313527"
};
