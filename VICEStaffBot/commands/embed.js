const resourcePath = global.GetResourcePath ?
global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
message.delete()
if (!params[0] || !params[1]) {
    let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!embed [title] [description]`',
            "color": settingsjson.settings.botErrorColour,
    }
    return message.channel.send({ embed })
}
else {
    let embed = {
        "title": `${params[0]}`,
        "description": `${params.join(' ').replace(params[0], '')}`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": "VICE"
        },
        "timestamp": new Date()
    }
    message.channel.send( { embed })
}
}

exports.conf = {
    name: "embed",
    perm: 6,
    guild: "1458466924974313527"
}
