let { Webhook, MessageBuilder } = require('discord-webhook-node');

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        return message.reply('Invalid args! Correct term is: ' + process.env.PREFIX + 'carreport [spawncode] [issue]')
    }
    let spawncode = params[0];
    let issue = params.slice(1).join(' ');
    let reporter = message.author.id;


    fivemexports.vice.execute("INSERT INTO vice_cardev (spawncode, issue, reporter, claimed, completed, notes) VALUES(?, ?, ?, ?, ?, ?)", [spawncode, issue, reporter, false, false, ""], (result) => {
        fivemexports.vice.execute("SELECT * FROM vice_cardev WHERE reporter = ? AND spawncode = ? AND issue = ?", [message.author.id, spawncode, issue], (result) => {

            let embed = {
                "title": "Car Report Submitted",
                "description": `Spawn Code: **${spawncode}**\nIssue: **${issue}**\nReporter: **<@${message.author.id}>**\nReport ID: **${result[0].reportid}**\n`,
                "color": settingsjson.settings.botColour,
                "footer": {
                    "text": ""
                },
                "timestamp": new Date()
            }
            message.channel.send({ embed });


            let logsEmbed = new MessageBuilder()
                .setTitle('Car Report Received')
                .setDescription(`Spawn Code: **${spawncode}**\nIssue: **${issue}**\nReporter: **<@${message.author.id}>**\nReport ID: **${result[0].reportid}**\n`)
                .setColor(settingsjson.settings.botColour)
                .setFooter('VICE')
                .setTimestamp();

            let hook = new Webhook(settingsjson.settings.carReportWebhook);

            // Send embed to logs
            hook.send(logsEmbed);
        });
    });
}

exports.conf = {
    name: "carreport",
    perm: 0,
    guild: "1458466924974313527"
}
