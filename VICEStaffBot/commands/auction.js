const Discord = require('discord.js');
const fs = require('fs');
const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');
let prevbids = require(resourcePath + '/prevbid.json');
let auctionnames = {};
let auctions = {};

exports.runcmd = (fivemexports, client, message, params) => {
    message.delete();
    if (params[0] == 'end') {
        let embed = {
            "description": `${message.author.username} has won the auction`,
            "color": settingsjson.settings.botColour,
        };
        message.channel.send({embed});

        const bidAmount = prevbids.prevbid;
        const user = message.author;

        fivemexports.vice.execute("SELECT user_id FROM `vice_verification` WHERE discord_id = ?", [user.id], (verificationResult) => {
            if (verificationResult.length > 0) {
                const userId = verificationResult[0].user_id;

                fivemexports.vice.execute("UPDATE vice_user_moneys SET bank = bank - ? WHERE user_id = ?", [bidAmount, userId], (result) => {
                    if (result) {
                        console.log(`Deducted £${bidAmount} from user ${user.username}'s bank`);
                        
                        const wonVehicle = params[0].toLowerCase();
                        fivemexports.vice.execute("INSERT INTO vice_user_vehicles (user_id, vehicle) VALUES (?, ?)", [userId, wonVehicle], (vehicleResult) => {
                            if (vehicleResult) {
                                console.log(`Added vehicle ${wonVehicle} to user ${user.username}`);
                            } else {
                                console.error(`Failed to add vehicle ${wonVehicle} to user ${user.username}`);
                            }
                        });
                    } else {
                        console.error(`Failed to deduct £${bidAmount} from user ${user.username}'s bank`);
                    }
                });
            } else {
                console.error(`User ${user.username} does not have a Perm ID linked to their Discord account.`);
            }
        });

        prevbids.prevbid = 0;
        fs.writeFile(`${resourcePath}/prevbid.json`, JSON.stringify(prevbids), function(err) {});
        fs.writeFile(`${resourcePath}/auctionnames.json`, JSON.stringify(auctionnames), function(err) {});
        fs.writeFile(`${resourcePath}/auctions.json`, JSON.stringify(auctions), function(err) {});
        const role = message.guild.roles.find(r => r.name === "@everyone");

        message.channel.overwritePermissions(role, { SEND_MESSAGES: false });
    }
    if (!params[0] || !params[1] || !params[2] || !params[4]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!auction [spawncode] [imagelink] [ends-at] [item-name]`',
            "color": settingsjson.settings.botErrorColour,
        };
        return message.channel.send({ embed });
    } else {
        spawncode = params[0];
        imagelink = params[1];
        endsat = params[2];
        carName = `${params.join(' ').replace(params[0], '').replace(params[1], '').replace(params[2], '')}`;
        fivemexports.vice.execute("SELECT * FROM vice_user_vehicles WHERE vehicle = ?", [params[0].toLowerCase()], (result) => {
            if (result) {
                carcount = result.length;
                message.guild.createChannel(`・auction-${carName}`, 'text')
                .then(channel => {
                    let category = message.guild.channels.find(c => c.name == "| AUCTIONS" && c.type == "category");
                    channel.setParent(category.id);
                    let embed = {
                        "title": `VICE Auction`,
                        "fields": [
                            {
                                "name": '**Item**',
                                "value": carName,
                                "inline": true,
                            },
                            {
                                "name": '**Info**',
                                "value": `1:${carcount} 🔒`,
                                "inline": true,
                            },
                            {
                                "name": '**Bidding Ends**',
                                "value": endsat,
                                "inline": true,
                            },
                        ],
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": "!bid [amount] to place a bid"
                        },
                        "image": {
                            "url": imagelink,
                        },
                    }
                    channel.send({embed})
                }).catch(console.error);
                let embed = {
                    "title": `Created Auction`,
                    "description": `**Name:** ${carName}\n**Car Count:** 1:${carcount}\n**Ends At:** ${endsat}\n\n**Created By:** ${message.author}`,
                    "color": settingsjson.settings.botColour,
                    "image": {
                        "url": imagelink,
                    },
                }
                message.channel.send({embed})
            }
        })
    }
}

exports.conf = {
    name: "auction",
    perm: 9,
    guild: "1458466924974313527"
};
