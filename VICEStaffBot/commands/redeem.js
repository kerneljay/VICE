const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')


exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "Booster Perks",
        "description": `If you are a <@1257756376588091452> You can do /redeem in game and receive a week of plat and £500k!`,        
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "redeem",
    perm: 0,
    guild: "1458466924974313527"
}