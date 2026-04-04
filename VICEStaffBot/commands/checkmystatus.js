const resourcePath = global.GetResourcePath ?
global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    let description = '';
    if (message.author.presence.status == "online" || message.author.presence.status == 'dnd' || message.author.presence.status == 'idle' && !message.author.bot){ //check if user is online and is not a bot
        if(Object.entries(message.author.presence.activities).length > 0 && typeof(message.author.presence.activities[0].state) === 'string' && message.author.presence.activities[0].state.toLowerCase().includes('discord.gg/vice5m'.toLowerCase()) ){ 
        description = 'You have `discord.gg/vice5m` in your status and you are participating in the leaderboard competition'+'```\nYou are currently on the leaderboard check your position with !leaderboard.```\n<@'+message.author.id+'>';
    } else {
        description = 'You do not have `discord.gg/vice5m` in your status and you are not participating in the leaderboard competition'+'```\nYou are not on the leaderboard, Check your position with !leaderboard.```\n<@'+message.author.id+'>';
    }
    } else {
        description = 'You are offline, We cannot tell if you are participating in the leaderboard competition'+'```\nPlease change your status, Check your position with !leaderboard.```\n<@'+message.author.id+'>';
    }
    const embed = {
        "title": `Check My Status`,
        "description": description,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": ""
        },
        "timestamp": new Date()
    };
    message.channel.send({ embed });
}

exports.conf = {
    name: "checkmystatus",
    perm: 0,
    guild: "1458466924974313527"
}
