const fs = require('fs').promises;
const path = require('path');

exports.runcmd = async (fivemexports, client, message, params) => {
    message.delete();
    const storeMessageID = await readStoredMessageID();

    if (storeMessageID) {
        try {
            const editMessage = await message.channel.fetchMessage(storeMessageID);

            const newEmbed = {
                title: "Support VICE",
                description: `If you love the frequent updates, original code, fantastic admin team, and the joy each time you click join, \n\nThen please consider supporting VICE so that we can remain online bringing smiles across the globe ❤`,
                color: settingsjson.settings.botColour,
                footer: {
                    text: `Last Updated: ${new Date().toLocaleDateString()}`
                },
                fields: [
                    {
                        name: "**Explore our Perks**",
                        value: "More information posted on the [store](https://store.vicestudios.net/)",
                        inline: true
                    },
                    {
                        name: `**${params[0]}**`,
                        value: params.slice(1).join(" "),
                        inline: true
                    },
                ],
            };

            await editMessage.edit({ embed: newEmbed });
            console.log('Message edited successfully.');
        } catch (error) {
            console.error("Error editing store embed:", error);
        }
    } else {
        message.channel.send("Please use `!storeembed` command first before editing the store.");
    }
};

async function readStoredMessageID() {
    try {
        const filePath = path.join(__dirname, '..', 'storeMessageID.json');
        const data = await fs.readFile(filePath, 'utf8');
        const storeMessageID = JSON.parse(data).messageID;
        return storeMessageID;
    } catch (err) {
        console.error('Error reading storeMessageID.json:', err);
        return null;
    }
}

exports.conf = {
    name: "editstore",
    perm: 11,
    guild: "1458466924974313527"
};