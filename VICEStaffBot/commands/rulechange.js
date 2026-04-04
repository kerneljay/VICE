const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    message.delete()
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!rulechange [description]`',
            "color": settingsjson.settings.botErrorColour,
    }
    return message.channel.send({ embed })
    }
    else {
        let embed = {
            "author" : {
                name: "VICE Announcement!",
                icon_url: "https://imgur.com/a/xmYNJG7"
            },
            //"title": `${params[0]}`,
            "description": `${params.join(' ')}`,
            "color": 0xffa358,
            // "thumbnail": {
            //     url: 'https://imgur.com/a/xmYNJG7',
            // },
            "footer": {
                "text": `Posted by ${message.author.username}`
            },
            "timestamp": new Date()
        }
        const channel = client.channels.find(channel => channel.name === settingsjson.settings.RuleChangesChannel)
        channel.send({embed})
        message.channel.send(`Rule Change Sent in ${channel}`)
    }
}

exports.conf = {
    name: "rulechange",
    perm: 7,
    guild: "1458466924974313527"
}