const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    //message.channel.send('You can buy merch from our store here: `TBD`')
    message.channel.send('We currently do not have a merch store for VICE')
}

exports.conf = {
    name: "merch",
    perm: 0,
    guild: "1458466924974313527"
}