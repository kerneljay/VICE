const { RichEmbed } = require('discord.js');

exports.runcmd = (fivemexports, client, message, params) => {
    const guildId = "1458466924974313527";
    const staffRoleName = "Staff";
    const managementRoleName = "Management";

    const guild = client.guilds.get(guildId);

    if (guild) {
        const staffEmbed = new RichEmbed()
            .setTitle("Staff Members with Custom Status's")
            .setColor(settingsjson.settings.botColour);

        const managementEmbed = new RichEmbed()
            .setTitle("Management Members with Custom Status's")
            .setColor(settingsjson.settings.botColour);

        const staffRole = guild.roles.find(role => role.name === staffRoleName);
        const managementRole = guild.roles.find(role => role.name === managementRoleName);

        if (!staffRole || !managementRole) {
            message.channel.send("Staff or Management role not found. Please check the role names.");
            return;
        }

        const processMembers = (members, index) => {
            if (index >= members.length) {
                if (staffEmbed.fields.length > 0) {
                    message.channel.send({ embed: staffEmbed });
                } else {
                    message.channel.send("No staff members found with matching custom status.");
                }

                if (managementEmbed.fields.length > 0) {
                    message.channel.send({ embed: managementEmbed });
                } else {
                    message.channel.send("No management members found with matching custom status.");
                }
            } else {
                const member = members[index];

                if (member.presence.status && member.presence.status !== "offline" && member.presence.game && member.presence.game.type === 4 &&
                    (member.presence.game.state.includes(".gg") || member.presence.game.state.includes("https://"))) {
                    if (member.roles.has(staffRole.id)) {
                        staffEmbed.addField("User", `<@${member.user.id}>`);
                        staffEmbed.addField("Custom Status",`${member.presence.game.state}\n\n`);
                    }

                    if (member.roles.has(managementRole.id)) {
                        managementEmbed.addField("User", `<@${member.user.id}>`);
                        managementEmbed.addField("Custom Status", `${member.presence.game.state}\n\n`);
                    }                    
                }

                processMembers(members, index + 1);
            }
        };

        guild.fetchMembers().then(updatedGuild => {
            const membersArray = updatedGuild.members.array();
            processMembers(membersArray, 0);
        }).catch(error => {
            console.error("Error fetching members:", error);
        });
    } else {
        message.channel.send("Guild not found. Please check the guild ID.");
    }
};

exports.conf = {
    name: "checkstatus",
    perm: 10,
    guild: "1458466924974313527"
};