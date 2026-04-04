const resourcePath = global.GetResourcePath ?
  global.GetResourcePath(global.GetCurrentResourceName()) : global.__dirname;
const settingsjson = require(resourcePath + '/settings.js');

exports.runcmd = (fivemexports, client, message, params) => {
  if (params.length !== 6 || params.some(param => !param)) {
    const embed = {
      title: "An Error Occurred",
      description: "Incorrect Usage\n\nCorrect Usage: " + process.env.PREFIX + "\n`!addweaponwhitelist [permid] [Weapon name] [Weapon Spawncode] [Weapon price] [Weapon Category] [Is weapon owner]`",
      color: settingsjson.settings.botErrorColour,
    };
    return message.channel.send('', { embed });
  }

  const [permid, weaponName, gunhash, price, category, isOwnerStr] = params;

  const isOwner = isOwnerStr === 'true'; 

  const weaponInfo = JSON.stringify({
    name: weaponName,
    gunhash: gunhash,
    price: price,
    category: category,
    owner: isOwner, 
  });

  fivemexports.vice.execute(
    "UPDATE vice_weapon_whitelists SET weapon_info = ? WHERE user_id = ?",
    [weaponInfo, permid],
    (result) => {
      if (result.affectedRows > 0) {
        const embed = {
          title: "Updated Whitelist",
          description: `
            **Perm ID:** ${permid}
            **Weapon Name:** ${weaponName}
            **Weapon hash:** ${gunhash}
            **Weapon Price:** ${price}
            **Weapon Category:** ${category}
            **Weapon Owner:** ${isOwner ? 'True' : 'False'}
            **Admin:** <@${message.author.id}>
          `,
          color: settingsjson.settings.botColour,
          footer: { text: "" },
          timestamp: new Date(),
        };
        message.channel.send('', { embed });
      } else {
        const embed = {
          title: "Failed to update whitelist",
          description: `PermID: **${permid}** does not exist in the database.`,
          color: settingsjson.settings.botColour,
          footer: { text: "" },
          timestamp: new Date(),
        };
        message.channel.send('', { embed });
      }
    }
  );
};

exports.conf = {
  name: "addweaponwhitelist",
  perm: 1,
  guild: "1458466924974313527",
  support: true,
};
