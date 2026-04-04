ViceTips= {
    "Watch out, there is more recoil than usual in this city",
    "Support Vice @store.Vicestudios.net for some cool VIP perks!",
    "Support Vice @store.Vicestudios.net for some cool VIP perks!",
    "Support Vice @store.Vicestudios.net for some cool VIP perks!",
    "Support Vice @store.Vicestudios.net for some cool VIP perks!",
    "Press L to open your inventory",
    "KOS is only allowed at redzones!",
    "You can point with B",
    "You can make your minimap bigger with Z",
    "You can perform CPR on your dead friends, with a small chance of resuscitation using /cpr",
    "You sell all legal goods (Copper,Gold etc..) at the Trader which is south of the map near the docks",
    "You can get your GP to take a look at you and restore your health at any Hospital",
    "Check out our Website for whitelisted faction applications, https://www.Vicestudios.net",
    "Want to join the PD? Apply at #police-info on our discord!",
    "Use /ooc or // to ask out of character questions",
    "To call an admin, type /calladmin",
    "To report a player you can create a player report at https://www.Vicestudios.net/forums/",
    "You can lock your car with the comma key [,]",
    "If you are experiencing texture loss set your Texture Quality to Normal in graphics settings!",
    "F6 to see your licenses",
    "F5 to see your gang menu",
    "F10 to see your past warnings/kicks/bans",
    "M for vehicle functions/control",
    "Join our discord for discussion & development news https://discord.gg/UTzM4kcCjG",
    "Join our discord for discussion & development news https://discord.gg/UTzM4kcCjG",
    "Join our discord for discussion & development news https://discord.gg/UTzM4kcCjG",
    "Join our discord for discussion & development news https://discord.gg/UTzM4kcCjG",
    "Remember, selling or advertising the sale of anything in out of character chat is not allowed!",
    "Remember, selling or advertising the sale of anything in out of character chat is not allowed!",
    "Remember, selling or advertising the sale of anything in out of character chat is not allowed!",
    "Remember, selling or advertising the sale of anything in out of character chat is not allowed!",
    "Remember, selling or advertising the sale of anything in out of character chat is not allowed!",
    "For an ingame reward of £500k and 7 days plat boost our discord @ https://discord.gg/UTzM4kcCjG and do /redeem!",
    "For an ingame reward of £500k and 7 days plat boost our discord @ https://discord.gg/UTzM4kcCjG and do /redeem!",
    "For an ingame reward of £500k and 7 days plat boost our discord @ https://discord.gg/UTzM4kcCjG and do /redeem!",
    "For an ingame reward of £500k and 7 days plat boost our discord @ https://discord.gg/UTzM4kcCjG and do /redeem!",
    "For an ingame reward of £500k and 7 days plat boost our discord @ https://discord.gg/UTzM4kcCjG and do /redeem!"
}


Citizen.CreateThread(function()
    Wait(100000)
    while true do
        math.randomseed(GetGameTimer())
        num = math.random(1, #ViceTips)
        num = math.random(1, #ViceTips)
        num = math.random(1, #ViceTips)
        TriggerEvent("chatMessage", "", {255, 0, 0}, "^1[Vice Tips]^1  " .. "^5" .. ViceTips[num], "ooc")
        Wait(600000)
    end
end)
