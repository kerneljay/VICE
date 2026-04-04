exports.runcmd = (fivemexports, client, message, params) => {
    const authorID = message.author.id;

    fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [authorID], (result) => {
        if (result.length > 0) {
            const permId = result[0].user_id;

            const embed = {
                "color": settingsjson.settings.botColour,
                "description": `**PermID:** ${permId}** \nDiscord:** <@${authorID}>`,
            };

            message.channel.send(`||<@${message.author.id}>||`, { embed });
        } else {
            message.reply('You do not have a linked Perm ID');
        }
    });
};

exports.conf = {
    name: "getmyid",
    perm: 0,
    guild: "1458466924974313527"
};
