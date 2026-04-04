exports.runcmd = (fivemexports, client, message, params) => {
    if (!params) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'claim [reportid]');
    }

    let reportid = params[0];

    fivemexports.vice.execute("SELECT user_id FROM vice_verification WHERE discord_id = ?", [message.author.id], (verificationResult) => {
        if (verificationResult && verificationResult.length > 0) {
            let user_id = verificationResult[0].user_id;

            fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE reportid = ? AND completed = ? AND claimed = ?", [reportid, false, false], (result) => {
                if (result && result.length > 0) {
                    fivemexports.vice.execute("UPDATE vice_cardev SET claimed = ?, discord_id = ?, user_id = ? WHERE reportid = ?", [true, message.author.id, user_id, reportid]);
                    let embed = {
                        "title": "Claim Car Report",
                        "description": `You Claimed Report ID: **${reportid}**`,
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    }
                    message.channel.send({ embed });
                } else {
                    let embed = {
                        "title": "Claim Car Report",
                        "description": `Report ID: **${reportid}** is either completed or already claimed`,
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": ""
                        },
                        "timestamp": new Date()
                    }
                    message.channel.send({ embed });
                }
            });
        } else {
            message.reply('Unable to fetch user_id for the provided discord_id.');
        }
    });
};

exports.conf = {
    name: "claim",
    perm: 12,
    guild: "1458466924974313527"
};
