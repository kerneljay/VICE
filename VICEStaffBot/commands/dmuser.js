const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

const Discord = require('discord.js');
const client = new Discord.Client();

exports.runcmd = async (fivemexports, client, message, params) => {
    if (params.length < 2) {
        const embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + "\n`!dmuser [discord-id] [message]`",
            "color": settingsjson.settings.botErrorColour,
        };
        message.channel.send({ embed });
        return;
    }

    const userId = params[0];
    const mentionedUser = await client.users.get(userId);

    if (!mentionedUser) {
        const embed = {
            "title": "An Error Occurred",
            "description": "You have not provided a valid user ID" + process.env.PREFIX + "\n\n`!dmuser [discord-id] [message]`",
            "color": settingsjson.settings.botErrorColour,
        };
        message.channel.send({ embed });
        return;
    }

    const messageToSend = params.slice(1).join(' ');

    const embed = {
        "title": "",
        "description": `${messageToSend}\n\n Message from <@${message.author.id}>`,
        "color": settingsjson.settings.botColour,
        "footer": {
            "text": "VICE"
        },
        "timestamp": new Date()
    };

    try {
        await mentionedUser.send({ embed });

        const links = messageToSend.match(/(https:\/\/\S+)/g);

        if (links) {
            links.forEach(link => {
                mentionedUser.send(link);
            });
        }

        const responseEmbed = {
            "title": "Successfully Sent DM",
            "description": `User: <@${mentionedUser.id}>\n\n Message: ${messageToSend}`,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": "VICE"
            },
            "timestamp": new Date()
        };
        message.channel.send({ embed: responseEmbed });
    } catch (error) {
        if (error.message.includes("Cannot send messages to this user")) {
            const blockEmbed = {
                "title": "User has dm's turned off",
                "description": `User <@${mentionedUser.id}> has dm's turned off and cannot receive messages.`,
                "color": settingsjson.settings.botErrorColour,
            };
            message.channel.send({ embed: blockEmbed });
        } else {
            console.error(`Error sending message to ${mentionedUser.username}: ${error}`);
            const errorEmbed = {
                "title": "Error Occurred!",
                "description": "An error occurred. Contact <@620232047671377931> about the issue\n \`\`\`There was an error sending the message.\`\`\`",
                "color": settingsjson.settings.botErrorColour,
            };
            message.channel.send({ embed: errorEmbed });
        }
    }
}

exports.conf = {
    name: "dmuser",
    perm: 8,
    guild: "1458466924974313527"
};
