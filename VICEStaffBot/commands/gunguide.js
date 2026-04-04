const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('There is no current gunguide for VICE')
}

exports.conf = {
    name: "gunguide",
    perm: 0,
    guild: "1458466924974313527"
}