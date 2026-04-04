require('dotenv').config();

const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = async (fivemexports, client, message, params) => {
    try {
        const commandPrefix = process.env.PREFIX || '!';

        const user = message.member;
        const userRoles = user.roles.map(role => role.name);
      //  console.log("User Roles:", userRoles);

        const userPermLevels = new Set();

        userRoles.forEach(role => {
            const trimmedRole = role.trim();

            if (trimmedRole === "[Founder]") {
                userPermLevels.add(11); // founder
            } else if (trimmedRole === "[Lead Developer]" || trimmedRole === "[Developer]") {
                userPermLevels.add(10); // lead dev
            } else if (trimmedRole === "[Car Developer]") {
                userPermLevels.add(12); // Car Developer
            } else if (trimmedRole === "[Management]") {
                userPermLevels.add(9); // Community Manager
                userPermLevels.add(8);
                userPermLevels.add(7);
            } else if (trimmedRole === "[Staff Manager]") {
                userPermLevels.add(8);
            } else if (trimmedRole === "[Head Administrator]") {
                userPermLevels.add(7);
            } else if (trimmedRole === "[Senior Administrator]") {
                userPermLevels.add(6);
            } else if (trimmedRole === "[Administrator]") {
                userPermLevels.add(5);
            } else if (trimmedRole === "[Senior Moderator]") {
                userPermLevels.add(4);
            } else if (trimmedRole === "[Moderator]") {
                userPermLevels.add(3);
            } else if (trimmedRole === "[Support Team]") {
                userPermLevels.add(2);
            } else if (trimmedRole === "[Trial Staff]") {
                userPermLevels.add(1);
            } else if (trimmedRole === "[Staff]") {
                userPermLevels.add(6);
                userPermLevels.add(5);
                userPermLevels.add(4);
                userPermLevels.add(3);
                userPermLevels.add(2);
                userPermLevels.add(1);
            }
        });

     //   console.log("User Permission Levels:", Array.from(userPermLevels));

        const groupedCommands = {};

        client.commands.forEach(command => {
            if (userPermLevels.has(command.conf.perm) || command.conf.perm === 0) {
                let role;

                if (command.conf.perm === 0) {
                    role = 'Public Commands';
                } else if (command.conf.perm >= 1 && command.conf.perm <= 6) {
                    role = 'Staff Commands';
                } else if (command.conf.perm >= 7 && command.conf.perm <= 9) {
                    role = 'Management';
                } else if (command.conf.perm == 10) {
                    role = 'Developer';
                } else if (command.conf.perm === 12) {
                    role = 'Car Developer';
                } else if (command.conf.perm === 11) {
                    role = 'Founder';
                } else {
                    role = 'Undefined Role';
                }

                if (!groupedCommands[role]) {
                    groupedCommands[role] = [];
                }
                groupedCommands[role].push(commandPrefix + command.conf.name);
            }
        });

        let description = "";
        for (const role in groupedCommands) {
            description += `**${role}:**\n`;
            description += groupedCommands[role].join('\n') + '\n\n';
        }

        const embed = {
            "title": "Commands available for you",
            "description": description,
            "color": settingsjson.settings.botColour,
            "footer": {
                "text": ""
            },
            "timestamp": new Date()
        };
        message.channel.send({ embed });
    } catch (error) {
        console.error("Error fetching user roles:", error);
    }
};

exports.conf = {
    name: "help",
    guild: "1458466924974313527",
    perm: 0
};