const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('discord.gg/vice5m')
}

exports.conf = {
    name: "discord",
    perm: 0,
    guild: "1458466924974313527"
}