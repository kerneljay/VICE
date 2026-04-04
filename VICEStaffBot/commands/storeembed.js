const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');
const editstore = require('./editstore.js'); 
const fs = require('fs');
const path = require('path');

exports.runcmd = (fivemexports, client, message, params) => {
    const currentDate = new Date().toLocaleDateString();

    let embed = {
        "title": "Support VICE",
        "description": "If you love the frequent updates, original code, fantastic admin team, and the joy each time you click join, \n\nThen please consider supporting VICE so that we can remain online bringing smiles across the globe ❤",
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": `Last Updated: ${currentDate}`
        },
        "fields": [
            {
                name: "**Explore our Perks**",
                value: "More information posted on the [store](https://storevicestudiosnet.tebex.io/)",
                inline: true
            },
        ]
    };

    message.channel.send({ embed }).then(sentMessage => {
        saveMessageID(sentMessage.id);
    });
};

function saveMessageID(messageID) {
    const filePath = path.join(__dirname, '..', 'storeMessageID.json');
    const data = JSON.stringify({ messageID }); 

    fs.writeFile(filePath, data, (err) => {
        if (err) {
            console.error('Error saving message ID:', err);
        } else {
            console.log('Message ID saved to storeMessageID.json');
        }
    });
}

exports.runcmd_editstore = (fivemexports, client, message, params) => {
    editstore.runcmd_editstore(fivemexports, client, message, params, storeMessageID);
};

exports.conf = {
    name: "storeembed",
    perm: 11,
    guild: "1458466924974313527"
};