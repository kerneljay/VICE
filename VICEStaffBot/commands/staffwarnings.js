const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!staffwarnings [perm_id]`',
            "color": settingsjson.settings.botErrorColour,
        }
        return message.channel.send({ embed })
    }

    fivemexports.vice.execute("SELECT * FROM `vice_staff_warnings` WHERE target_id = ?", [params[0]], (result) => {
        if (result.length > 0) {
            let warningList = result.map((warning, index) => `\n\nWarning **${index + 1}**\nAdmin Perm ID:** ${warning.admin_id}**\nAdmin Name:** ${warning.admin_name}**\nMessage:** ${warning.warning_message}**\nTimestamp:** ${new Date(warning.timestamp).toLocaleString()}**`).join('\n');

            let embed = {
                "title": `Staff Warnings`,
                "description": `Showing staff warnings for User ID: **${params[0]}**`,
                "color": settingsjson.settings.botColour,
                "fields": [
                    {
                        name: '',
                        value: `${warningList}`
                    },
                    {
                        name: 'Total Warnings',
                        value: result.length.toString() 
                    }                   
                ],
                "footer": {
                    "text": "VICE"
                },
                "timestamp": new Date()
            }

            message.channel.send({ embed });
        } else {
            let embed = {
                "title": `Staff Warnings`,
                "description": `This user has no staff warnings`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
            }

            message.channel.send({ embed });
        }
    });
}

exports.conf = {
    name: "staffwarnings",
    perm: 6,
    guild: "1458466924974313527"
}
