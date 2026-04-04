const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "AUCTIONS FAQ",
        "fields": [
            {
                "name": "How to start a bid",
                "value": "<:cata:1191337325138038895> Type `!bid [amount]` example: `!bid 250,000`",
            },
            {
                "name": "Upon winning an auction",
                "value": "<:cata:1191337325138038895> Payment is automatically taken from your account when the auction ends.\n<:cata:1191337325138038895> Your item will be added to your account within 48 hours.",
            },
            {
                "name": "When do auctions end?",
                "value": "<:cata:1191337325138038895> Auctions end at a random time between 00:00 - 00:01",
            },
        ],
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": "Failure to pay for an auction will result in a 7-day ban.",
        },
    };

    message.channel.send({embed});
};

exports.conf = {
    name: "auctionsfaq",
    perm: 11,
    guild: "1458466924974313527",
};
