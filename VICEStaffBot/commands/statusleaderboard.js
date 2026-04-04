const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

var statusLeaderboard = require(resourcePath + '/statusleaderboard.json')

exports.runcmd = (fivemexports, client, message, params) => {
    const sortable = Object.fromEntries(
        Object.entries(statusLeaderboard['leaderboard']).sort(([,a],[,b]) => b-a)
    );
    let foundInLeaderboard = false;
    for (i = 0; i < Object.keys(statusLeaderboard['leaderboard']).length; i++) {
        if (Object.keys(sortable)[i] == message.author.id) {
            foundInLeaderboard = true;
            let embed = {
                "title": `Leaderboard Info`,
                "description": 'To take part in the competition, place `discord.gg/vice5m` in your status.'+'```\nYou are currently '+(i+1)+'/'+Object.keys(statusLeaderboard['leaderboard']).length+' on the leaderboard with '+(Object.values(sortable)[i]/60).toFixed(2)+' hours promoted.```\n<@'+message.author.id+'>',
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
            break;
        }
    }
    if(!foundInLeaderboard) {
        let embed = {
            "title": `Leaderboard Info`,
            "description": 'You need to have `discord.gg/vice5m` in your status to participate in the leaderboard competition.'+'```\nYou are currently not on the leaderboard due to the missing status.```\n<@'+message.author.id+'>',
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        }
        message.channel.send({ embed });
    }
}

exports.conf = {
    name: "leaderboard",
    perm: 0,
    guild: "1458466924974313527"
}
