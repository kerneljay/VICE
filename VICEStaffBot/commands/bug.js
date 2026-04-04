const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('To report a bug, please use our bug reporting system. \nhttps://github.com/vicestudiosuk/issue-tracker/issues')
}

exports.conf = {
    name: "bug",
    perm: 0,
    guild: "1458466924974313527"
}