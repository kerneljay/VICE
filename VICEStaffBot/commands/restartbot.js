const resourcePath = global.GetResourcePath ? global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

const listRunningNodeProcesses = async () => {
    return new Promise((resolve, reject) => {
        exec('tasklist | find "node.exe"', (error, stdout, stderr) => {
            if (error) {
                reject(`Error listing Node.js processes: ${stderr}`);
            } else {
                const processes = stdout.split('\n').map(line => line.trim()).filter(Boolean);
                resolve(processes);
            }
        });
    });
}

const findRestartedProcesses = (before, after) => {
    return after.filter(process => !before.includes(process));
}

const delay = (milliseconds) => {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
}

const restartBots = async () => {
    const beforeRestart = await listRunningNodeProcesses();
    killGithubBot();
    await delay(5000);
    const afterRestart = await listRunningNodeProcesses();
    const restartedProcesses = findRestartedProcesses(beforeRestart, afterRestart);

    return restartedProcesses;
}

exports.runcmd = async (fivemexports, client, message, params) => {
    let embed = {
        "title": "Restarting External Bots",
        "description": `External bots are being restarted now`,
        "color": settingsjson.settings.botColour,
        "timestamp": new Date()
    };

    message.channel.send({ embed }).then(async (msg) => {
        const messageId = msg.id;

        const restartedProcesses = await restartBots();

        let completionEmbed = {
            "title": "Result",
            "description": `External bots have been successfully restarted. \n\nRestarted Processes:\n\`\`\`
            ${restartedProcesses.map(process => process.replace(/\s+/g, ' ')).join('\n').replace(/\n\s+/g, '\n')}
            \`\`\``,
            "color": settingsjson.settings.botColour,
            "timestamp": new Date()
        };
        msg.edit({ embed: completionEmbed });
    });
}

exports.conf = {
    name: "restartbot",
    perm: 7,
    guild: "1458466924974313527"
};
