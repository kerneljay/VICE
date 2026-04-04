const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

exports.runcmd = (fivemexports, client, message, params) => {
    fivemexports.vice.execute("SELECT * FROM vice_users WHERE banned = 1", (result) => {
        if (result) {
            let bansRemoved = 0; 
            for (i = 0; i < result.length; i++) {
                const banreason = result[i].banreason;
                
                if (banreason && (banreason.includes("Community Ban") || banreason.includes("1.10 Cheating"))) {
                    continue;
                }
                
                let newval = fivemexports.vice.VICEStaffBot('setBanned', [parseInt(result[i].id), false]);
                bansRemoved++; 
            }
            let embed = {
                "title": "Ban Database Cleared",
                "description": `Number of Bans removed: ${bansRemoved}\n\nAdmin: <@${message.author.id}>`,
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
    name: "clearbans",
    perm: 11,
    guild: "1458466924974313527"
};
