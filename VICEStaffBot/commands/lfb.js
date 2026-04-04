const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('https://discord.gg/s5A8jsVg')
}

exports.conf = {
    name: "lfb",
    perm: 0,
    guild: "1458466924974313527"
}