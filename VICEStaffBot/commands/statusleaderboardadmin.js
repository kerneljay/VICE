const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

var statusLeaderboard = require(resourcePath + '/statusleaderboard.json');
let descriptionText = '';

exports.runcmd = (fivemexports, client, message, params) => {
    var promoters = [];
    const sortable = Object.fromEntries(
        Object.entries(statusLeaderboard['leaderboard']).sort(([,a],[,b]) => b-a)
    );
    for (i = 0; i < Object.keys(statusLeaderboard['leaderboard']).length; i++) {
        if (i < 10) {
            promoters.push(`<@${Object.keys(sortable)[i]}> - ${(Object.values(sortable)[i]/60).toFixed(2)} hours promoted\n`);
        }
    }

    let mentionList = promoters.join('').replace(',', ''); 

    let embed = {
        "title": `Promotion Leaderboard`,
        "description": `To take part in the competition for the **£70**, place \`discord.gg/vice5m\` in your status.${descriptionText}\n\n${mentionList}`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    };
    message.channel.send({ embed });
};

exports.conf = {
    name: "leaderboardadmin",
    perm: 5,
    guild: "1458466924974313527"
};
