const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
    let embed = {
        "title": "VICE MET Police",
        "description": "To join the MET Police, please apply [here](https://soon).\n\nMore information can be found at our E-Library [here](https://soon).",
        "color": settingsjson.settings.botColour,
        "image": {
            "url": "https://i.imgur.com/gC6DQqJ.png",
        },
        "fields": [
            {
                "name": "Official VICE MetPD PD Discord",
                "value": "[Discord](https://discord.gg/qaZ7xNzaJc)",
            },
            {
                "name": "How do I make a complaint on an officer?",
                "value": "To make a complaint on a police officer, you must join the PD Discord linked above and look for the #police-complaints channel.\n A member of the Executive team will assist you.",
            }
        ],
    };

    message.channel.send({ embed });
    message.channel.send("||                              https://discord.gg/qaZ7xNzaJc                                 ||");
};

exports.conf = {
    name: "metpdembed",
    perm: 11,
    guild: "1458466924974313527",
};
