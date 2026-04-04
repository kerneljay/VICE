exports.runcmd = (fivemexports, client, message, params) => {
    if (!params || params.length < 2) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'close [reportid] [notes]');
    }

    let reportid = params[0];
    let notes = params.slice(1).join(' ');

    fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE reportid = ? AND completed = 0 AND discord_id = ?", [reportid, message.author.id], (result) => {
        if (result[0]) {
            fivemexports.vice.execute("UPDATE vice_cardev SET completed = 1, notes = ? WHERE reportid = ?", [notes, reportid]);
            fivemexports.vice.execute("UPDATE vice_cardev SET completed = ? WHERE reportid = ?", [result[0].completed + 1, reportid]);

            let spawnCode = result[0].spawncode;

            let embed = {
                "title": "Car Report Closed",
                "description": `Car Report **${reportid}** Has Been Closed\n\nChanges: **${notes}**`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": "" 
                },
                "timestamp": new Date()
            };

            message.channel.send({ embed });

            const reporterId = result[0].discord_id;
            const adminMention = `<@${message.author.id}>`; 
            if (reporterId) {
                const reporter = client.users.get(reporterId);
                if (reporter) {
                    let embedDM = {
                        "title": "Car Report Closed",
                        "description": `Your car report for **${spawnCode}** has been closed by ${adminMention}.\n\nChanges: **${notes}**\n\n*If you have any feedback or other complaints about the changes contact a car developer*`,
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    };
            
                    reporter.send({ embed: embedDM })
                        .catch(error => {
                            console.error(`Error sending DM to reporter: ${error}`);
                        });
                }
            }
        } else {
            let embed = {
                "title": "Car Report",
                "description": `You are not assigned to or the report is completed for ID: ${reportid}`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            };

            message.channel.send({ embed });
        }
    });
};

exports.conf = {
    name: "close",
    perm: 12,
    guild: "1458466924974313527"
};
