const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [message.author.id], (discord) => {
            if (discord.length > 0) {
                fivemexports.vice.execute("SELECT * FROM `vice_user_data` WHERE user_id = ?", [discord[0].user_id], (result) => {
                    if (result.length > 0) {
                        let embed = {
                            "description": `**${(JSON.parse(result[0].dvalue).PlayerTime/60).toFixed(2)}** hours`,
                            "color": settingsjson.settings.botColour,
                        }
                        message.reply({ embed })
                    } else {
                        message.reply('No hours for this user.')
                    }
                });
            } else {
                message.reply('No Perm ID linked to your discord.')
            }
        });
    } else {
        fivemexports.vice.execute("SELECT * FROM `vice_user_data` WHERE user_id = ?", [params[0]], (result) => {
            if (result.length > 0) {
                let embed = {
                    "description": `**${(JSON.parse(result[0].dvalue).PlayerTime/60).toFixed(2)}** hours`,
                    "color": settingsjson.settings.botColour,
                }
                message.reply({ embed })
            } else {
                message.reply('No hours for this user.')
            }
        });
    }
}

exports.conf = {
    name: "ch",
    perm: 0,
    guild: "1458466924974313527"
}