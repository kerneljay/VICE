const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

var statusLeaderboard = require(resourcePath + '/statusleaderboard.json')

exports.runcmd = (fivemexports, client, message, params) => {
    const sortable = Object.fromEntries(
        Object.entries(statusLeaderboard['leaderboard']).sort(([,a],[,b]) => b-a)
    );
    // how many people are in the leaderboard
    let leaderboardLength = Object.keys(statusLeaderboard['leaderboard']).length;
    let embed = {
        "title": `Promotion Leaderboard`,
        "description": `There are currently **${leaderboardLength}** participants in the competition\n\nCurrent Top 3:\n1. <@${Object.keys(sortable)[0]}> - ${(Object.values(sortable)[0]/60).toFixed(2)} hours promoted\n2. <@${Object.keys(sortable)[1]}> - ${(Object.values(sortable)[1]/60).toFixed(2)} hours promoted\n3. <@${Object.keys(sortable)[2]}> - ${(Object.values(sortable)[2]/60).toFixed(2)} hours promoted`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    };
    message.channel.send({ embed });
}

exports.conf = {
    name: "statuslb",
    perm: 0,
    guild: "1458466924974313527"
}
