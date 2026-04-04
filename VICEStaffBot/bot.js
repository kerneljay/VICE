const Discord = require('discord.js');
const client = new Discord.Client();
const path = require('path')
const resourcePath = global.GetResourcePath ?
    global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname
require('dotenv').config({ path: path.join(resourcePath, './.env') })
const fs = require('fs');
const { spawn, exec } = require('child_process');
const settingsjson = require(resourcePath + '/settings.js')
var statusLeaderboard = require(resourcePath + '/statusleaderboard.json');
const { Webhook, MessageBuilder } = require('discord-webhook-node');
const schedule = require('node-schedule');

client.path = resourcePath
client.ip = settingsjson.settings.ip

if (process.env.TOKEN == "" || process.env.TOKEN == "TOKEN") {
    console.log(`Error! No Token Provided you forgot to edit the .env`);
    throw new Error('Whoops!')
}

client.on('ready', () => {
    console.log(`Bot User: ${client.user.tag}`);
   // console.log(`Your Prefix Is ${process.env.PREFIX}`)

    killGithubBot();
    init()
});

let onlinePD = 0
let onlineStaff = 0
let onlineNHS = 0
let memberCount = 0;
let serverStatus = ""
let currentFooterEmoji = '⚪';

setInterval(() => {
    if (currentFooterEmoji === "⚪") {
        currentFooterEmoji = "⚫";
    } else {
        currentFooterEmoji = "⚪";
    }
}, 300);

if (settingsjson.settings.StatusEnabled) {
    setInterval(() => {
        if (!client.guilds.get(settingsjson.settings.GuildID)) return console.log(`Status is enabled but not configured correctly and will not work as intended.`);

        let guild = client.guilds.get(settingsjson.settings.GuildID);
        memberCount = guild.memberCount;
        serverIP = client.ip;

        let channelid = client.guilds.get(settingsjson.settings.GuildID).channels.find(r => r.name === settingsjson.settings.StatusChannel);
        if (!channelid) return console.log(`Status channel is not available / cannot be found.`);
        let settingsjsons = require(resourcePath + '/params.json');
        let totalSeconds = (client.uptime / 1000);
        totalSeconds %= 86400;
        let hours = Math.floor(totalSeconds / 3600);
        totalSeconds %= 3600;
        let minutes = Math.floor(totalSeconds / 60);
        const formattedHours = hours.toString().padStart(2, '');
        const formattedMinutes = minutes.toString().padStart(2, '');
        client.user.setActivity(`${GetNumPlayerIndices()}/${GetConvarInt("sv_maxclients", 600)} players`, { type: 'WATCHING' });
        exports.vice.VICEStaffBot('getUsersByPermission', ['admin.tickets'], function (result) {
            onlineStaff = result.length || 0;
        });
        exports.vice.VICEStaffBot('getUsersByPermission', ['police.armoury'], function (result) {
            onlinePD = result.length || 0;
        });
        exports.vice.VICEStaffBot('getUsersByPermission', ['nhs.menu'], function (result) {
            onlineNHS = result.length || 0;
        });
        exports.vice.VICEStaffBot('getUsersByPermission', ['lfb.onduty.permission'], function (result) {
            onlineLFB = result.length || 0;
        });
        exports.vice.VICEStaffBot('getUsersByPermission', ['hmp.menu'], function (result) {
            onlineHMP = result.length || 0;
        });
        exports.vice.VICEStaffBot('getUsersByPermission', ['ukbf.onduty.permission'], function (result) {
            onlineUKBF = result.length || 0;
        });
        exports.vice.getServerStatus([], function (result) {
            serverStatus = result;
        });
        channelid.fetchMessage(settingsjsons.messageid).then(msg => {
            let status = {
                "color": 0x3498db,
                "fields": [
                    {
                        "name": "Server Status",
                        "value": serverStatus === '❌ Offline' ? '❌ Offline' : serverStatus,
                        "inline": true
                    },
                    {
                        "name": "Average Player Ping",
                        "value": serverStatus === '❌ Offline' ? '?' : `${Math.floor(Math.random() * 18) + 2}ms`,
                        "inline": true
                    },
                    {
                        "name": "Ping",
                        "value": serverStatus === '❌ Offline' ? '?' : `${Math.floor(Math.random() * 19) + 4}ms`,
                        "inline": true
                    },
                    {
                        "name": "<:met:1168982765144899606> Police",
                        "value": serverStatus === '❌ Offline' ? '?' : onlinePD,
                        "inline": true
                    },
                    {
                        "name": "<:nhs:1168982768408088606> NHS",
                        "value": serverStatus === '❌ Offline' ? '?' : onlineNHS,
                        "inline": true
                    },
                    // {
                    //     "name": "<:lfb:1168982766520631416> LFB",
                    //     "value": serverStatus === '❌ Offline' ? '?' : onlineLFB,
                    //     "inline": true
                    // },
                    {
                        "name": "<:hmp:1168983005881192558> HMP",
                        "value": serverStatus === '❌ Offline' ? '?' : onlineHMP,
                        "inline": true
                    },
                    {
                        "name": "<:staff:1191337321463816192> Staff",
                        "value": serverStatus === '❌ Offline' ? '?' : onlineStaff,
                        "inline": true
                    },
                    {
                        "name": "<:members:1191337320452984852> Players",
                        "value": serverStatus === '❌ Offline' ? '?' : `${GetNumPlayerIndices()}/${GetConvarInt("sv_maxclients", 600)}`,
                        "inline": true
                    },
                    {
                        "name": "<:discord:1191337326153056316> Members",
                        "value": serverStatus === '❌ Offline' ? '?' : memberCount,
                        "inline": true
                    },
                    {
                        "name": "<:status:1191337322558529586> Uptime",
                        "value": serverStatus === '❌ Offline' ? '?' : `${formattedHours} hours, ${formattedMinutes} minutes`, // Not too sure if i like this so for now it will stay out
                        "inline": true
                    },
                    {
                        "name": "",
                        "value": ``,
                        "inline": false
                    },
                    {
                        "name": "How do I direct connect?",
                        "value": serverStatus === '❌ Offline' ? '`?`' : '`F8 -> connect 76vgze`',
                        "inline": true
                    },

                ],
                "author": {
                    "name": "VICE Server Status",
                    "icon_url": ""
                },
                "footer": {
                    "text": `${currentFooterEmoji} VICE`
                },
                "timestamp": new Date()
            };
            msg.edit({ embed: status }); // uncomment when not using testing bot
        }).catch(err => {
            channelid.send('VICEs Status Page is starting up...').then(id => {
                settingsjsons.messageid = id.id;
                fs.writeFile(`${resourcePath}/params.json`, JSON.stringify(settingsjsons), function (err) { });
                return;
            });
        });
    }, 10000);
}


client.commands = new Discord.Collection();

const init = async() => {
  fs.readdir(resourcePath + '/commands/', (err, files) => {
    if (err) console.error(err);
    console.log(`Loaded ${files.length} commands.`);
    files.forEach(f => {
      let command = require(`${resourcePath}/commands/${f}`);
      client.commands.set(command.conf.name, command);
    });
    if (!statusLeaderboard['leaderboard']) {
      statusLeaderboard['leaderboard'] = {}
    }
    else {
      statusLeaderboard['leaderboard'] = statusLeaderboard['leaderboard']
    }
  });
}

setInterval(function(){
  promotionDetection();
}, 60000);

function promotionDetection(){
  client.users.forEach(user =>{ //iterate over each user
    if (user.id != 268072312366956545){
        if(user.presence.status == "online" || user.presence.status == 'dnd' || user.presence.status == 'idle' && !user.bot){ //check if user is online and is not a bot
            if(Object.entries(user.presence.activities).length > 0 && typeof(user.presence.activities[0].state) === 'string' && user.presence.activities[0].state.includes('discord.gg/vice5m') ){ //check if they have a status
                if(!statusLeaderboard['leaderboard'][user.id]){ // if user hasn't  created a profile before
                    var userProfile = {}; // create new profile
                    statusLeaderboard['leaderboard'][user.id] = userProfile; //set profile to object literal
                    statusLeaderboard['leaderboard'][user.id] = 0; //set minutes to 0
                }
                statusLeaderboard['leaderboard'][user.id] += 1;
                fs.writeFileSync(`${resourcePath}/statusleaderboard.json`, JSON.stringify(statusLeaderboard), function(err) {});
            }
        }
    }
  })
}

client.getPerms = function(msg) {

    let settings = settingsjson.settings
    let lvl1 = msg.guild.roles.find(r => r.name === settings.Level1Perm);
    let lvl2 = msg.guild.roles.find(r => r.name === settings.Level2Perm);
    let lvl3 = msg.guild.roles.find(r => r.name === settings.Level3Perm);
    let lvl4 = msg.guild.roles.find(r => r.name === settings.Level4Perm);
    let lvl5 = msg.guild.roles.find(r => r.name === settings.Level5Perm);
    let lvl6 = msg.guild.roles.find(r => r.name === settings.Level6Perm);
    let lvl7 = msg.guild.roles.find(r => r.name === settings.Level7Perm);
    let lvl8 = msg.guild.roles.find(r => r.name === settings.Level8Perm);
    let lvl9 = msg.guild.roles.find(r => r.name === settings.Level9Perm);
    let lvl10 = msg.guild.roles.find(r => r.name === settings.Level10Perm);
    let lvl11 = msg.guild.roles.find(r => r.name === settings.Level11Perm);
    let lvl12 = msg.guild.roles.find(r => r.name === settings.Level12Perm);
    if (!lvl1 || !lvl2 || !lvl3 || !lvl4 || !lvl5 || !lvl6 || !lvl7 || !lvl8 || !lvl9 || !lvl10 || !lvl11 || !lvl12) {
        console.log(`Your permissions are not setup correctly and the bot will not function as intended.\nStatus: Please check permission levels are setup correctly.`)
    }

    // hot fix for Discord role caching 
    const guild = client.guilds.get(msg.guild.id);
    if (guild.members.has(msg.author.id)) {
        guild.members.delete(msg.author.id);
    }
    const member = guild.members.get(msg.author.id);
    // hot fix for Discord role caching 

    let level = 0;
    if (msg.member.roles.has(lvl12.id)) {
        level = 12;
    } else if (msg.member.roles.has(lvl11.id)) {
        level = 11;
    } else if (msg.member.roles.has(lvl10.id)) {
        level = 10;
    } else if (msg.member.roles.has(lvl9.id)) {
        level = 9;
    } else if (msg.member.roles.has(lvl8.id)) {
        level = 8;
    } else if (msg.member.roles.has(lvl7.id)) {
        level = 7;
    } else if (msg.member.roles.has(lvl6.id)) {
        level = 6;
    } else if (msg.member.roles.has(lvl5.id)) {
        level = 5;
    } else if (msg.member.roles.has(lvl4.id)) {
        level = 4;
    } else if (msg.member.roles.has(lvl3.id)) {
        level = 3;
    } else if (msg.member.roles.has(lvl2.id)) {
        level = 2;
    } else if (msg.member.roles.has(lvl1.id)) {
        level = 1;
    }
    return level
}
client.on('message', (message) => {
    if (!message.author.bot) {
        if (message.channel.name && message.channel.name.includes('auction-')) {
            if (message.channel.name == 'auction-info') {
                return;
            } else {
                if (!message.content.includes(`${process.env.PREFIX}bid`)) {
                    if (!message.content.includes(`${process.env.PREFIX}auction`) && !message.content.includes(`${process.env.PREFIX}houseauction`) && !message.content.includes(`${process.env.PREFIX}embed`)) {
                        message.delete();
                        return;
                    }
                }
            }
        } else if (message.channel.name && message.channel.name.includes('verify')) {
            if (!message.content.includes(`${process.env.PREFIX}verify `)) {
                message.delete();
                return;
            }
        }
    }
    let client = message.client;
    if (message.author.bot) return;
    if (!message.content.startsWith(process.env.PREFIX)) return;
    let command = message.content.split(' ')[0].slice(process.env.PREFIX.length).toLowerCase();
    let params = message.content.split(' ').slice(1);
    let cmd;
    let permissions = 0
    if (message.guild.id === settingsjson.settings.GuildID) {
        permissions = client.getPerms(message)
    }
    if (client.commands.has(command)) {
        cmd = client.commands.get(command);
    }
    if (cmd) {
        if (message.guild.id === cmd.conf.guild) {
            if (!message.channel.name.includes('verify') && cmd.conf.name === 'verify'){
                message.delete()
                message.reply('Please use #verify for this command.').then(msg => {
                    msg.delete(5000)
                })
                return
            }else if (!message.channel.name.includes('bot') && !message.channel.name.includes('verify') && !cmd.name === 'embed') {
                message.delete()
                message.reply('Please use https://discord.com/channels/1237182920511455312/1168904452514783322 for this command.').then(msg => {
                    msg.delete(5000)
                })
            }
            else {
                if (permissions < cmd.conf.perm) return;
                try {
                    cmd.runcmd(exports, client, message, params, permissions);
                    if (cmd.conf.perm > 0 && params) { // being above 0 means won't log commands meant for anyone that isn't staff
                        params = params.join('\n ');
                        if (params != '') {
                            let { Webhook, MessageBuilder } = require('discord-webhook-node');
                            let hook = new Webhook(settingsjson.settings.botLogWebhook);
                            let embed = new MessageBuilder()
                            .setTitle('Bot Logs')
                            .addField('Command Used:', `${cmd.conf.name}`)
                            .addField('Parameters:', `${params}`)
                            .addField('Admin:', `${message.author.username} - <@${message.author.id}>`)
                            .setColor(settingsjson.settings.botColour)
                            .setFooter('VICE')
                            .setTimestamp();
                            hook.send(embed);
                        }
                    }
                } catch (err) {
                    let embed = {
                        "title": "An Error Occured",
                        "description": "\nAn error occured. Contact <@268072312366956545> about the issue:\n\n```" + err.message + "\n```",
                        "footer": "Please contact a developer",
                        "color": settingsjson.settings.botErrorColour,
                    }
                    message.channel.send({ embed })
                }
            }
        } else {
            if (cmd.conf.support && message.guild.id === "1233336203839934605"){ // Support Guild
                if (message.member.roles.has("1148483821331808308")){ // Donation Support 
                    cmd.runcmd(exports, client, message, params, permissions);
                }
            } else {
                message.reply('This command is expected to be used within another guild. <:vice:1191336281263841290>').then(msg => {
                    msg.delete(5000)
                })
                return;
            }
        }
    }
});

client.on('guildMemberAdd', async (member) => {
    exports.vice.VICEStaffBot("SELECT * FROM vice_verification WHERE discord_id = ?", [member.id], (result) => {
            if (result && result.length > 0) {
                member.roles.add("1481830175934251089");
            }
        }) 
});

client.on('guildMemberUpdate', async (oldMember, newMember) => {
    const mainGuildID = '1237182920511455312';
    const secondaryGuildID = '1233336203839934605';

    const staffRoleIDMainGuild = '1237182920511455318';
    const staffRoleIDSecondaryGuild = '1156410440570642432';

    const hasStaffRoleMainGuild = newMember.roles && newMember.roles.has(staffRoleIDMainGuild);

    await delay(5000);

    if (newMember.guild && newMember.guild.id === mainGuildID) {
        const secondaryGuild = client.guilds.get(secondaryGuildID);

        if (secondaryGuild) {
            const secondaryGuildMember = secondaryGuild.members.get(newMember.id);

            if (secondaryGuildMember) {
                if (hasStaffRoleMainGuild) {
                    const roleToAdd = secondaryGuild.roles.get(staffRoleIDSecondaryGuild);

                    if (roleToAdd) {
                        try {
                            await secondaryGuildMember.addRole(roleToAdd);
                            // console.log(`Added verified role ${staffRoleIDSecondaryGuild} to ${newMember.user.tag} in the secondary guild.`);
                        } catch (error) {
                            console.error(`Error adding verified role to member in the secondary guild: ${error}`);
                        }
                    } else {
                        console.error(`Verified role to add not found in the secondary guild.`);
                    }
                } else {
                    const roleToRemove = secondaryGuild.roles.get(staffRoleIDSecondaryGuild);

                    if (roleToRemove) {
                        try {
                            await secondaryGuildMember.removeRole(roleToRemove);
                            // console.log(`Removed verified role ${staffRoleIDSecondaryGuild} from ${newMember.user.tag} in the secondary guild.`);
                        } catch (error) {
                            console.error(`Error removing verified role from member in the secondary guild: ${error}`);
                        }
                    } else {
                        console.error(`Verified role to remove not found in the secondary guild.`);
                    }
                }
            } else {
                // console.error(`Member not found in secondary guild.`);
            }
        } else {
            console.error(`Secondary guild not found.`);
        }
    }
});

async function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

client.on('guildMemberRemove', async (newMember) => {
    exports.vice.CheckDiscordActivity();
});

async function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

client.on('guildMemberUpdate', async (oldMember, newMember) => {
    const mainGuildID = '1237182920511455312';
    const secondaryGuildID = '1233336203839934605';

    const staffRoleIDMainGuild = '1168904404615831553';
    const staffRoleIDSecondaryGuild = '1094033938378399802';

    const hasStaffRoleMainGuild = newMember.roles && newMember.roles.has(staffRoleIDMainGuild);

    await delay(5000);

    if (newMember.guild && newMember.guild.id === mainGuildID) {
        const secondaryGuild = client.guilds.get(secondaryGuildID);

        if (secondaryGuild) {
            const secondaryGuildMember = secondaryGuild.members.get(newMember.id);

            if (secondaryGuildMember) {
                if (hasStaffRoleMainGuild) {
                    const roleToAdd = secondaryGuild.roles.get(staffRoleIDSecondaryGuild);

                    if (roleToAdd) {
                        try {
                            await secondaryGuildMember.addRole(roleToAdd);
                            // console.log(`Added verified role ${staffRoleIDSecondaryGuild} to ${newMember.user.tag} in the secondary guild.`);
                        } catch (error) {
                            console.error(`Error adding verified role to member in the secondary guild: ${error}`);
                        }
                    } else {
                        console.error(`Verified role to add not found in the secondary guild.`);
                    }
                } else {
                    const roleToRemove = secondaryGuild.roles.get(staffRoleIDSecondaryGuild);

                    if (roleToRemove) {
                        try {
                            await secondaryGuildMember.removeRole(roleToRemove);
                            // console.log(`Removed verified role ${staffRoleIDSecondaryGuild} from ${newMember.user.tag} in the secondary guild.`);
                        } catch (error) {
                            console.error(`Error removing verified role from member in the secondary guild: ${error}`);
                        }
                    } else {
                        console.error(`Verified role to remove not found in the secondary guild.`);
                    }
                }
            } else {
                // console.error(`Member not found in secondary guild.`);
            }
        } else {
            console.error(`Secondary guild not found.`);
        }
    }
});

let isBootwipeScheduled = false;
const rule = new schedule.RecurrenceRule();
rule.date = 1;
rule.hour = 10;
rule.minute = 5;

schedule.scheduleJob(rule, () => {
    if (!isBootwipeScheduled) {
        isBootwipeScheduled = true;

        const bootwipe = require('./commands/bootwipe.js');
        bootwipe.runMonthlyWipe(exports, client, { channel: channel });
    } else {
        console.error(`Bootwipe is already scheduled.`);
    }
});

async function syncRoles(newMember, mainGuildID, viceLogsGuildID, management, staff, managementlogs, stafflogs) {
    if (newMember.guild && newMember.guild.id === mainGuildID) {
        const hasRole1MainGuild = newMember.roles && newMember.roles.has(management);
        const hasRole2MainGuild = newMember.roles && newMember.roles.has(staff);

        const viceLogsGuild = client.guilds.get(viceLogsGuildID); 

        if (viceLogsGuild) {
            const viceLogsMember = viceLogsGuild.members.get(newMember.id); 

            if (!viceLogsMember) {
               // console.error(`Member not found in VICE Logs guild.`);
                return;
            }

            if (hasRole1MainGuild) {
                const role1LunaLogs = viceLogsGuild.roles.get(managementlogs);

                if (role1LunaLogs) {
                    try {
                        await viceLogsMember.addRole(role1LunaLogs);
                    } catch (error) {
                        console.error(`Error adding role1 to member in VICE Logs guild: ${error}`);
                    }
                } else {
                    console.error(`Role1 not found in VICE Logs guild.`);
                }
            } else {
                const role1LunaLogs = viceLogsGuild.roles.get(managementlogs);

                if (role1LunaLogs) {
                    try {
                        await viceLogsMember.removeRole(role1LunaLogs);
                    } catch (error) {
                        console.error(`Error removing role1 from member in VICE Logs guild: ${error}`);
                    }
                } else {
                    console.error(`Role1 not found in VICE Logs guild.`);
                }
            }

            if (hasRole2MainGuild) {
                const role2LunaLogs = viceLogsGuild.roles.get(stafflogs);

                if (role2LunaLogs) {
                    try {
                        await viceLogsMember.addRole(role2LunaLogs);
                    } catch (error) {
                        console.error(`Error adding role2 to member in VICE Logs guild: ${error}`);
                    }
                } else {
                    console.error(`Role2 not found in VICE Logs guild.`);
                }
            } else {
                const role2LunaLogs = viceLogsGuild.roles.get(stafflogs);

                if (role2LunaLogs) {
                    try {
                        await viceLogsMember.removeRole(role2LunaLogs);
                    } catch (error) {
                        console.error(`Error removing role2 from member in VICE Logs guild: ${error}`);
                    }
                } else {
                    console.error(`Role2 not found in VICE Logs guild.`);
                }
            }
        } else {
            console.error(`VICE Logs guild not found.`);
        }
    }
}

client.on('guildMemberUpdate', (oldMember, newMember) => {
    const mainGuildID = '1237182920511455312';
    const viceLogsGuildID = '1135232364428148756';
    
    const management = '1168904398030770238';
    const staff = '1168904404615831553';

    const managementlogs = '1135232364428148758';
    const stafflogs = '1135232364428148757';

    syncRoles(newMember, mainGuildID, viceLogsGuildID, management, staff, managementlogs, stafflogs);
});


client.on("guildMemberAdd", function (member) {
    if (member.guild.id === settingsjson.settings.GuildID){
        try {
            exports.vice.execute("SELECT * FROM `vice_verification` WHERE discord_id = ? AND verified = 1", [member.id], (result) => {
                if (result.length > 0){
                    let existingRole = member.guild.roles.find(r => r.name === 'Member');
                    member.addRole(existingRole);
                }
            });
        
        } catch (error) {}
    } else if (member.guild.id === settingsjson.settings.SupportGuildID){
        try {
            exports.vice.execute("SELECT * FROM `vice_verification` WHERE discord_id = ? AND verified = 1", [member.id], (result) => {
                if (result.length > 0){
                    let newRole = member.guild.roles.find(r => r.name === 'Member');
                    member.addRole(newRole);
                }
            });
        
        } catch (error) {}
    }
});

const dmlogger = new Webhook('https://discord.com/api/webhooks/1168943529972736020/WlpeTKZa0bxRrVvuRX84ozZNQQl9zQyvyY5aWYj8IIDXlThis31YSlr0l4-CX-l8ij-m');
const roleIdToMention = '1168943602051858553';

client.on('message', async (message) => {
    if (!message.author.bot && message.channel.type === 'dm') {
        const authorMention = `<@${message.author.id}>`;

        const roleMention = `<@&${roleIdToMention}>`;

        dmlogger.send(roleMention);

        const embed = new MessageBuilder()
            .setTitle('Received Message')
            .addField('Author', authorMention, true)
            .setColor(settingsjson.settings.botColour)
            .setTimestamp();

        let contentWithLinks = message.content;

        contentWithLinks = contentWithLinks.replace(/(https:\/\/\S+)/g, (match) => {
            if (/\.(png|jpg|jpeg|gif|webp)$/i.test(match)) {
                dmlogger.send(match);
                return '';
            } else {
                dmlogger.send(`${match}${match}`);
                return `[LINK](${match})`;
            }
        });

        if (message.attachments.size > 0) {
            message.attachments.forEach(attachment => {
                dmlogger.send(attachment.url);
            });
        }

        if (contentWithLinks.trim() !== '') {
            embed.addField('Content', contentWithLinks);
        }

        dmlogger.send(embed);
    }
});

function killGithubBot() {
    const processNames = ['node.exe'];  
  
    exec('tasklist', (error, stdout, stderr) => {
      // console.log('Tasklist Output:', stdout); // Debug line
  
      if (error) {
        console.error(`Error listing processes: ${stderr}`);
      } else {

        const processesToKill = processNames.filter(name => stdout.includes(name));
  
        if (processesToKill.length > 0) {
          processesToKill.forEach(processName => {
            const taskkillCommand = `taskkill /F /FI "IMAGENAME eq ${processName}"`;
  
            exec(taskkillCommand, (killError, killStdout, killStderr) => {
              if (killError) {
                console.error(`Error killing process ${processName}: ${killStderr}`);
              } else {
                console.log(`^3Batch File: Process ${processName} killed successfully^0`);
                runGithubBot();
              }
            });
          });
        } else {
          console.log('^3No matching processes found.^0');
          runGithubBot();
        }
      }
    });
  }
  function runGithubBot() {
    const batchFilePath = 'C:/Users/Administrator/Desktop/VICE/VICE/resources/[VICE]/VICEStaffBot/github_bot.bat';
    const errorLogFilePath = 'C:/Users/Administrator/Desktop/VICE/VICE/resources/[VICE]/VICEStaffBot/error.log';

    if (fs.existsSync(batchFilePath)) {
        const batchProcess = spawn('cmd.exe', ['/c', batchFilePath]);

        batchProcess.stdout.on('data', (data) => {
            console.log(`^3Batch File: ${data}`.trim(), `^7`);
        });

        batchProcess.stderr.on('data', (data) => {
            const errorMessage = `${data}`;
            // console.error(errorMessage);

            fs.appendFileSync(errorLogFilePath, errorMessage + '\n');
            console.error("stored and logged - Error.log");

            const { Webhook, MessageBuilder } = require('discord-webhook-node');
            const hook = new Webhook(settingsjson.settings.errorLogWebhook);
            const embed = new MessageBuilder()
                .setTitle('External Bots Errors')
                .addField('Error:', `\`\`\`${errorMessage}\`\`\``)
                .setColor(settingsjson.settings.botErrorColour)
                .setTimestamp();

            if (errorMessage.includes("DeprecationWarning")) {
              return;
            } else {
                embed.setFooter('VICE');
            }

            hook.send(embed).catch(error => {
                const newErrorMessage = `Failed to send webhook: ${error.message}`;
                console.error(newErrorMessage);
                fs.appendFileSync(errorLogFilePath, newErrorMessage + '\n');
                console.error("stored and logged - Error.log");
                
                const newEmbed = new MessageBuilder()
                    .setTitle('External Bots Errors')
                    .addField('Error:', 'Could not send an empty embed')
                    .setColor(settingsjson.settings.botErrorColour)
                    .setTimestamp()
                    .setFooter('VICE');

                hook.send(newEmbed).catch(error => {
                    console.error(`Failed to send the error message: ${error.message}`);
                });
            });
        });

        batchProcess.on('close', (code) => {
            if (code === 0) {
                console.log('^3Batch File: Execution Completed Successfully^7');
            } else {
                console.error(`^3Batch File: Execution Failed with Code ${code}. Check the error log for details.^7`);
            }
        });
    } else {
        console.error(`Batch file not found at ${batchFilePath}`);
    }
}

const errorChannelId = '1232546504728772608';
const errorChannel = client.channels.get(errorChannelId);

process.on('uncaughtException', (error) => {
    if (errorChannel) {
        const now = new Date();
        const timestamp = `Today at ${now.toLocaleTimeString('en-UK', { hour: 'numeric', minute: 'numeric' })}`;

        const embed = {
            color: settingsjson.settings.botErrorColour,
            title: `An Error Occurred`,
            description: `An uncaught exception occurred:\n\`\`\`${error}\`\`\``,
            footer: {
                text: `${timestamp}`,
            },
        };

        errorChannel.send({ embed: embed });
        errorChannel.send('||<@268072312366956545>||');
    }
});

exports('dmUser', (source, args) => {
    let discordid = args[0].trim()
    let verifycode = args[1]
    let permid = args[2]
    const guild = client.guilds.get(settingsjson.settings.GuildID);
    const member = guild.members.get(discordid);
    try {
        let embed = {
            "title": `<:vice:1191336281263841290> Discord Account Link Request <:vice:1191336281263841290>`,
            "description": `User ID ${permid} has requested to link this Discord account.\n\nThe code to link is **${verifycode}**\nThis code will expire in 5 minutes.\n\nIf you have not requested this then you can safely ignore the message. Do **NOT** share this message or code with anyone else.`,
            "color": settingsjson.settings.botColour,
            "thumbnail": {
                "url": "https://i.imgur.com/xgSZGcA.png",
            },
        }
        member.send({embed})
    } catch (error) {}
});


client.login(process.env.TOKEN)