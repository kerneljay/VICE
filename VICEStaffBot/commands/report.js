const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('You can report a player like this: `DM Either <@1041903927253286952> or a member of management`')
}

exports.conf = {
    name: "report",
    perm: 0,
    guild: "1458466924974313527"
}