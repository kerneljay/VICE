const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
const settingsjson = require(resourcePath + '/settings.js')

function formatMoney(number, decPlaces, decSep, thouSep) {
    decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces,
    decSep = typeof decSep === "undefined" ? "." : decSep;
    thouSep = typeof thouSep === "undefined" ? "," : thouSep;
    var sign = number < 0 ? "-" : "";
    var i = String(parseInt(number = Math.abs(Number(number) || 0).toFixed(decPlaces)));
    var j = (j = i.length) > 3 ? j % 3 : 0;

    return sign +
        (j ? i.substr(0, j) + thouSep : "") +
        i.substr(j).replace(/(\decSep{3})(?=\decSep)/g, "$1" + thouSep) +
        (decPlaces ? decSep + Math.abs(number - i).toFixed(decPlaces).slice(2) : "");
}

exports.runcmd = (fivemexports, client, message, params) => {
    let totalCash = 0
    let totalBank = 0
    let totalChips = 0
    fivemexports.vice.execute("SELECT * FROM `vice_user_vehicles`", [], (cars) => {
        fivemexports.vice.execute("SELECT * FROM `vice_user_vehicles` WHERE locked = 1", [], (lockedcars) => {
            fivemexports.vice.execute("SELECT * FROM `vice_user_data`", [], (userdata) => {
                fivemexports.vice.execute("SELECT * FROM vice_warnings", [], (warnings) => {
                    fivemexports.vice.execute("SELECT * FROM vice_user_moneys", [], (money) => {
                        fivemexports.vice.execute("SELECT * FROM vice_casino_chips", [], (chips) => {
                            fivemexports.vice.execute("SELECT * FROM `vice_users`", [], (users) => {
                                fivemexports.vice.execute("SELECT * FROM vice_users WHERE banned = 1", (bannedPlayers) => {
                                    fivemexports.vice.execute("SELECT * FROM vice_anticheat", (totalACBans) => {
                                        for (i = 0; i< chips.length; i++){
                                            totalChips = parseInt(totalChips) + parseInt(chips[i].chips)
                                        }
                                        for (i = 0; i< money.length; i++){
                                            totalCash = parseInt(totalCash) + parseInt(money[i].wallet)
                                            totalBank = parseInt(totalBank) + parseInt(money[i].bank)
                                        }
                                        let embed = {
                                            "title": `**Server Stats**`,
                                            "color": settingsjson.settings.botColour,
                                            "fields": [
                                                {
                                                    name: '**Players Online:**',
                                                    value: `${GetNumPlayerIndices()}`,
                                                    inline: true,
                                                },
                                                {
                                                    name: '**Discord Members:**',
                                                    value: `${message.guild.memberCount}`,
                                                    inline: true,
                                                },
                                                {
                                                    name: '**Total Perm IDs:**',
                                                    value: `${users.length}`,
                                                    inline: true,
                                                }, 
                                                {
                                                    name: '**Total Bans:**',
                                                    value: `${bannedPlayers.length}`,
                                                    inline: true,
                                                }, 
                                                {
                                                    name: '**Total Anticheat Bans:**',
                                                    value: `${totalACBans.length}`,
                                                    inline: true,
                                                },  
                                                {
                                                    name: '**Total F10 Warnings:**',
                                                    value: `${warnings.length}`,
                                                    inline: true,
                                                },  
                                                {
                                                    name: '**Total Owned Vehicles:**',
                                                    value: `${cars.length}`,
                                                    inline: true,
                                                }, 
                                                {
                                                    name: '**Total Locked Vehicles:**',
                                                    value: `${lockedcars.length}`,
                                                    inline: true,
                                                },  
                                                {
                                                    name: '**Total Cash:**',
                                                    value: `£${totalCash.toLocaleString()}`,
                                                    inline: true,
                                                },  
                                                {
                                                    name: '**Total Bank:**',
                                                    value: `£${totalBank.toLocaleString()}`,
                                                    inline: true,
                                                },  
                                                {
                                                    name: '**Total Casino Chips:**',
                                                    value: `${totalChips.toLocaleString()}`,
                                                    inline: true,
                                                },   
                                            ],
                                            "footer": {
                                                "text": `Requested by ${message.author.username}`
                                            },
                                            "timestamp": new Date()
                                        }
                                        message.channel.send({ embed })
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
}

exports.conf = {
    name: "serverstats",
    perm: 6,
    guild: "1458466924974313527"
}