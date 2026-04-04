const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('To link your twitter account. Run `/linktwitter` in the in game chat.')
}

exports.conf = {
    name: "linktwitter",
    perm: 0,
    guild: "1458466924974313527"
}