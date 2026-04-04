const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

let bootsCleared = 0;

function runMonthlyWipe(fivemexports, client, message) {
    fivemexports.vice.execute("SELECT * FROM vice_srv_data", (result) => {
        bootsCleared = result.length;

        fivemexports.vice.execute("SELECT COUNT(DISTINCT user_id) as uniquePlayers FROM vice_user_data WHERE dkey = 'VICE:datatable' AND (JSON_UNQUOTE(JSON_EXTRACT(dvalue, '$.inventory')) != '[]' OR JSON_UNQUOTE(JSON_EXTRACT(dvalue, '$.weapons')) != '{}')", (playerResult) => {
            const uniquePlayers = playerResult[0].uniquePlayers;

            fivemexports.vice.execute("SELECT COUNT(DISTINCT UserID) as pointsRemoved, SUM(points) as totalPoints FROM vice_bans_offenses", (pointsResult) => {
                const pointsRemoved = pointsResult[0].totalPoints || 0;

                const resetType = isAutomaticReset() ? "Monthly" : "Triggered";

                const timestamp = new Date().toLocaleString("en-UK", { timeZone: "VICE" });
                const formattedTimestamp = `VICE - ${timestamp}`;

                let embed = {
                    "title": "Boot wipe is complete",
                    "description": `**Boots Wiped:** ${bootsCleared}\n**Players wiped:** ${uniquePlayers}\n**F10 Points removed:** ${pointsRemoved}\n**Statistics Reset:** ${resetType}`,
                    "color": settingsjson && settingsjson.settings ? settingsjson.settings.botColour : "#ffffff",
                    "footer": {
                        "text": formattedTimestamp
                    },
                };

                const channel = client.channels.find(channel => channel.name === settingsjson.settings.AnnouncementChannel);

                channel.send({ embed: embed });
                channel.send(`@everyone`);
                message.channel.send(`Sent announcement to ${channel}`);

                fivemexports.vice.execute("UPDATE vice_user_data SET dvalue = JSON_SET(dvalue, '$.weapons', '{}', '$.inventory', '[]') WHERE dkey = 'VICE:datatable'");
            });
        });

        fivemexports.vice.execute("DELETE FROM vice_srv_data");
        fivemexports.vice.execute("DELETE FROM vice_user_homes");
    });
}
function isAutomaticReset() {
    const now = new Date();
    const isFirstDayOfMonth = now.getDate() === 1;
    const isTenAM = now.getHours() === 10;
    const isFiveMinutes = now.getMinutes() === 5;

    return isFirstDayOfMonth && isTenAM && isFiveMinutes;
}

exports.runMonthlyWipe = runMonthlyWipe;

exports.runcmd = (fivemexports, client, message, params) => {
    message.delete();
    const resetType = isAutomaticReset() ? "Monthly" : "Triggered";
    message.channel.send(`Bootwipe ${resetType} reset initiated.`);

    runMonthlyWipe(fivemexports, client, message);
}

exports.conf = {
    name: "bootwipe",
    perm: 6,
    guild: "1458466924974313527"
};