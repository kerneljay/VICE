exports.runcmd = (fivemexports, client, message, params) => {
    if (!params) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'next')
    }

    fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE completed = ? AND claimed = ? ORDER BY reportid", [false, false], (report) => {
        if (report && report.length > 0) {
          //  fivemexports.vice.execute("UPDATE vice_cardev SET claimed = ? WHERE reportid = ?", [message.author.id, report[0].reportid]);
            
            let embed = {
                "title": "Next Car Report",
                "description": `Spawn Code: **${report[0].spawncode}**\n\nIssue: **${report[0].issue}**\n\nReporter: **<@${report[0].reporter}>**\n\nReport ID: **${report[0].reportid}**\n\n*When Completed !close [reportid] [changes]*\n\n *Use !claim [reportid] to view the next car report*\n\n`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
        } else {
            let embed = {
                "title": "Next Car Report",
                "description": `No Reports Available! You Are All Up To Date!`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });
        }
    });
}

exports.conf = {
    name: "next",
    perm: 12,
    guild: "1458466924974313527"
}
