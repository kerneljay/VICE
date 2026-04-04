const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('`No current website made`')
    message.channel.send('**If you have any questions open a ticket using !support**')
}

exports.conf = {
    name: "faq",
    perm: 0,
    guild: "1458466924974313527"
}