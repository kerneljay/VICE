const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0] || !parseInt(params[0]) || !params[1]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!delgroup [permid] [group name]`',
            "color": settingsjson.settings.botErrorColour,
    }
    return message.channel.send({ embed })
    }
    fivemexports.vice.execute("SELECT * FROM `vice_user_data` WHERE user_id = ?", [params[0]], (result) => {
        if (result.length > 0) {
            let dvalue = JSON.parse(result[0].dvalue)
            let groups = dvalue.groups
            groups[params[1]] = undefined;
            fivemexports.vice.execute("UPDATE `vice_user_data` SET dvalue = ? WHERE user_id = ?", [JSON.stringify(dvalue), params[0]])
        }
    })
    let embed = {
        "title": "Removed Group",
        "description": `\nPerm ID: **${params[0]}**\nGroup Name: **${params[1]}**\n\nAdmin: <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    }
    message.channel.send({ embed })
}

exports.conf = {
    name: "delgroup",
    perm: 6,
    guild: "1458466924974313527"
}