const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
   // message.channel.send('You can visit our forums here: **TBD**')
   message.channel.send('VICE Forums is being developed')
}

exports.conf = {
    name: "forums",
    perm: 0,
    guild: "1458466924974313527"
}