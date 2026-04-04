const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('[Pete & Bas - The Generals Corner W/ Kenny Allstar](https://www.youtube.com/watch?v=a4aVSVbZJbs)')
}

exports.conf = {
    name: "loadingsong",
    perm: 0,
    guild: "1458466924974313527"
}