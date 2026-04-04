const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!hmc [spawncode]`',
            "color": settingsjson.settings.botErrorColour,
    }
    return message.channel.send({ embed })
    }
    fivemexports.vice.execute("SELECT * FROM vice_user_vehicles WHERE vehicle = ?", [params[0].toLowerCase()], (result) => {
        if (result) {
            let embed = {
                "title": "Car Count",
                "description": `\nThere are **${result.length}** ${params[0]}'s in the city.`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                //"timestamp": new Date()
            }
            message.channel.send({ embed })
        }
    })
}

exports.conf = {
    name: "hmc",
    perm: 0,
    guild: "1458466924974313527"
}