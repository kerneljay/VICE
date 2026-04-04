const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('https://docs.google.com/spreadsheets/d/1KrT-sUSF6V9s2iku3_BUSzXfeLC7Al4yNgqMaQwil7I/edit?gid=0#gid=0')
}

exports.conf = {
    name: "locklist",
    perm: 0,
    guild: "1458466924974313527"
}