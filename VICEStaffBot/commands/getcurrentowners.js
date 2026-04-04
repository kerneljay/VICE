var AsciiTable = require('ascii-table');
const Discord = require('discord.js');
const fs = require('fs');

let descriptionText = ''

exports.runcmd = (fivemexports, client, message, params) => {
    if (!params[0]) {
        let embed = {
            "title": "An Error Occurred",
            "description": "Incorrect Usage\n\nCorrect Usage" + process.env.PREFIX + '\n`!gco [spawn code]`',
            "color": settingsjson.settings.botErrorColour,
    }
    return message.channel.send({ embed })
    }
    let count = 0
    fivemexports.vice.execute("SELECT * FROM `vice_user_vehicles` WHERE vehicle = ?", [params[0]], (result) => {
        var owners = []
        for (i = 0; i < result.length; i++) { 
            let user_id = result[i].user_id
            let results =  result.length
            let rented = false
            let locked = false
            if (result[i].rented)  {
                rented = true
            } 
            if (result[i].locked)  {
                descriptionText = '🔒 Vehicle is baller locked'
            }  
            else{
                descriptionText = '🔓 Vehicle is not baller locked'
            }
            fivemexports.vice.execute("SELECT * FROM `vice_users` WHERE id = ?", [user_id], (result) => {
                if (result[0].bantime == 'perm' || result[0].bantime == '-1') {
                    if (rented){
                        owners.push(`${result[0].username}(${user_id}) - Rented Permanently Banned\n`)
                    }
                    else{
                        owners.push(`${result[0].username}(${user_id}) - Permanently Banned\n`)
                    }
                }
                else{
                    if (rented){
                        owners.push(`${result[0].username}(${user_id}) - Rented\n`)
                    }
                    else{
                        owners.push(`${result[0].username}(${user_id})\n`)
                    }
                }
                count ++ 
                if (count == results){
                    let embed = {
                        "title": `All Users that own ${params[0]}:`,
                        "description": descriptionText+'```\n'+owners.join('').replace(',', '')+'```',
                        "color": settingsjson.settings.botColour,
                        "footer": {
                            "text": `VICE Studios | vicestudios.uk`
                        },
                        "timestamp": new Date()
                    }
                    message.channel.send({ embed }).catch(err => {
                        message.channel.send(`Too many people own this vehicle to be shown normally.`)
                    })
                }    
            });  
        }
        if (result.length == 0){
            let embed = {
                "description": `No one owns this vehicle`,
                "color": settingsjson.settings.botErrorColour,
            }
            return message.channel.send({ embed })
        }
    });
}

exports.conf = {
    name: "gco",
    perm: 1,
    guild: "1458466924974313527"
}