const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('https://docs.google.com/document/d/1_mEm3XMy6OYOcM_jOr6hFy7_HsHwdtGdWKuKdu13Y4w/edit?usp=sharing')
}

exports.conf = {
    name: "fivemrules",
    perm: 0,
    guild: "1458466924974313527"
}