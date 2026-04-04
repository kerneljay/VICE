exports.runcmd = (fivemexports, client, message) => {
    fivemexports.vice.execute("SELECT COUNT(*) AS totalTickets FROM vice_cardev WHERE claimed = ? AND discord_id = ? AND completed = ?", [true, message.author.id, true], (result) => {
       // console.log("Result of the totalTickets query:", result);

        if (result && result.length > 0) {
            let tickets = result[0].totalTickets;

            fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE claimed = ? AND discord_id = ? AND completed = ? ORDER BY reportid DESC LIMIT 1", [true, message.author.id, false], (currentReportResult) => {
              //  console.log("Result of the currentReport query:", currentReportResult);

                let currentReport = currentReportResult.length > 0 ? currentReportResult[0].reportid : "None";

                fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE claimed = ? ORDER BY claimed DESC", [true], (lb) => {
                    let rank = lb.findIndex((entry) => entry.discord_id === message.author.id) + 1;

                    let embed = {
                        "title": "Car Dev Stats",
                        "description": `Tickets Completed: **${tickets}**\n\nCurrent Report: **${currentReport}**\n\nRank On Leaderboard: **${rank}**\n\nThese stats are only for you\n\n`,
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    };

                    message.channel.send({ embed });
                });
            });
        } else {
            let embed = {
                "title": "Car Dev Stats",
                "description": `No Reports Claimed! You Are All Up To Date!`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            };
            message.channel.send({ embed });
        }
    });
}

exports.conf = {
    name: "stats",
    perm: 12,
    guild: "1458466924974313527"
};
