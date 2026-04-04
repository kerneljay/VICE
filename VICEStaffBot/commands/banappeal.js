const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.channel.send('**If you have a ongoing ban and wish to appeal it please open a ticket in** \nhttps://discord.gg/TzxccJNkVB')
   // message.channel.send('https://forms.gle/k59k3jSqEERGuQmt6')
}

// https://forms.gle/k59k3jSqEERGuQmt6

exports.conf = {
    name: "banappeal",
    perm: 0,
    guild: "1458466924974313527"
}