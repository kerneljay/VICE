exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage: " + process.env.PREFIX + '\n`!vote [vote contents]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    }
    const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
    require('dotenv').config({ path: path.join(resourcePath, './.env') });
    const settingsjson = require(resourcePath + '/settings.js');

    const vote = params.slice(0).join(' ');

    const endTime = new Date(new Date().getTime() + 12 * 60 * 60 * 1000); // 12 hours from command being ran

    let embed = {
        "title": "Community Vote",
        "description": `**${vote}**`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": `Results will be automatically drawn at: ${endTime.toLocaleTimeString()}`,
        },
        "timestamp": new Date(),
    };
    const channel = client.channels.find(channel => channel.name === settingsjson.settings.VoteChannel);

    let thumbsUpCount = 0;
    let thumbsDownCount = 0;

    channel.send({ embed }).then(function (message) {
        message.react("👍").then(() => message.react("👎"));

        setTimeout(() => {
            const reactions = message.reactions;
            reactions.forEach(reaction => {
                if (reaction.emoji.name === '👍') {
                    thumbsUpCount = reaction.count - 1;
                } else if (reaction.emoji.name === '👎') {
                    thumbsDownCount = reaction.count - 1;
                }
            });

            let voteResult = `**Results:** `;

            if (thumbsUpCount > thumbsDownCount) {
                voteResult += "This will be implemented.";
            } else if (thumbsDownCount > thumbsUpCount) {
                voteResult += "This will not be implemented.";
            } else {
                voteResult += "This will not be implemented, As it was a tie";
            }

            let resultsEmbed = {
                "title": "VICE Vote!",
                "description": `**${vote}** \n\n${voteResult}`,
                "timestamp": new Date(),
                "color": settingsjson.settings.botColour,
            };

            channel.send({ embed: resultsEmbed });

        }, 5 * 60 * 60 * 1000); 
    });

    channel.send(`@everyone`);
    message.channel.send(`Started vote in ${channel}`);
};

exports.conf = {
    name: "vote",
    perm: 9,
    guild: "1458466924974313527",
};
