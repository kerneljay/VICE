local cfg = {}

cfg.groups = {

--
--    ░██████╗████████╗░█████╗░███████╗███████╗
--    ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝
--    ╚█████╗░░░░██║░░░███████║█████╗░░█████╗░░
--    ░╚═══██╗░░░██║░░░██╔══██║██╔══╝░░██╔══╝░░
--    ██████╔╝░░░██║░░░██║░░██║██║░░░░░██║░░░░░
--    ╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚═╝░░░░░╚═╝░░░░░     

    ["Founder"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "soaps.workshop",
        "admin.getgroups",
        "rebellicense.whitelisted",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.addcar",
        "admin.managecommunitypot",
        "admin.moneymenu",
        "group.add.vip",
        "group.add.founder",
        "group.add.operationsmanager",
        "group.add.staffmanager",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.founder",
        "group.remove.operationsmanager",
        "group.remove.staffmanager",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "dev.menu",
        "admin.tickets",
        "cardev.menu",
        "vip.gunstore",
        "vip.aircraft",
        "vip.garage",
        "police.dev"
    },
    ["Lead Developer"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "soaps.workshop",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "rebellicense.whitelisted",
        "admin.getgroups",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.addcar",
        "pay.ldev",
        "admin.managecommunitypot",
        "admin.moneymenu",
        "group.add.vip",
        "group.add.operationsmanager",
        "group.add.staffmanager",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.operationsmanager",
        "group.remove.staffmanager",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "cardev.menu",
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
        "police.dev"
    },
    ["Developer"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "soaps.workshop",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "rebellicense.whitelisted",
        "admin.getgroups",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.addcar",
        "pay.dev",
        "admin.managecommunitypot",
        "admin.moneymenu",
        "group.add.vip",
        "group.add.operationsmanager",
        "group.add.staffmanager",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.operationsmanager",
        "group.remove.staffmanager",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "cardev.menu",
        "vip.gunstore",
        "vip.garage",
        "police.dev"
    },
    ["."] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "soaps.workshop",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "rebellicense.whitelisted",
        "admin.getgroups",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.addcar",
        "pay.dev",
        "group.add.vip",
        "group.add.operationsmanager",
        "group.add.staffmanager",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.operationsmanager",
        "group.remove.staffmanager",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "cardev.menu",
        "vip.gunstore",
        "vip.garage",
        "police.dev",
        "dev.menu",
        "admin.players",
        "admin.menu"
    },
    ["Staff Manager"] = {
        "admin.ban",
        "admin.unban",
        "soaps.workshop",
        "admin.kick",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "admin.getgroups",
        "admin.spectate",
        "admin.addcar",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "cardev.menu",
        "group.add.vip",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "pay.staffmanager",
    },
    ["Community Manager"] = {
        "admin.managecommunitypot",
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "admin.revive",
        "soaps.workshop",
        "admin.tp2player",
        "admin.addcar",
        "admin.freeze",
        "admin.getgroups",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "pay.commanager",
    },
    ["Head Administrator"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "pay.headadmin",
    },
    ["Senior Administrator"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.tickets",
        "pay.sradmin",
    },
    ["Administrator"] = {
        "admin.ban",
        "admin.unban",
        "admin.kick",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.noclip",
        "admin.tickets",
        "pay.admin",
    },
    ["Senior Moderator"] = {
        "admin.ban",
        "admin.kick",
        "admin.revive",
        "admin.slap",
        "admin.tp2player",
        "admin.freeze",
        "admin.screenshot",
        "admin.video",
        "admin.spectate",
        "admin.tickets",
        "pay.srmoderator",
    },
    ["Moderator"] = {
        "admin.ban",
        "admin.kick",
        "admin.tp2player",
        "admin.freeze",
        "admin.screenshot",
        "admin.video",
        "admin.spectate",
        "admin.tickets",
        "admin.revive",
        "pay.mod",
    },
    ["Support Team"] = {
        "admin.kick",
        "admin.spectate",
        "admin.tp2player",
        "admin.freeze",
        "admin.tickets",
        "admin.screenshot",
        "admin.video",
       -- "admin.ban", Erm nuh uh
        "pay.steam", 
    },
    ["Trial Staff"] = {
        "admin.kick",
        "admin.tp2player",
        "admin.freeze",
        "admin.spectate",
        "admin.tickets",
        "pay.trial",
    },
     ["External Contributor"] = {
       "admin.ban",
        "admin.unban",
        "admin.kick",
        "soaps.workshop",
        "admin.revive",
        "admin.tp2player",
        "admin.freeze",
        "rebellicense.whitelisted",
        "admin.getgroups",
        "admin.spectate",
        "admin.screenshot",
        "admin.video",
        "admin.slap",
        "admin.tp2waypoint",
        "admin.tp2coords",
        "admin.removewarn",
        "admin.noclip",
        "admin.addcar",
        "pay.dev",
        "admin.managecommunitypot",
        "admin.moneymenu",
        "group.add.vip",
        "group.add.operationsmanager",
        "group.add.staffmanager",
        "group.add.commanager",
        "group.add.headadmin",
        "group.add.senioradmin",
        "group.add.administrator",
        "group.add.srmoderator",
        "group.add.moderator",
        "group.add.supportteam",
        "group.add.trial",
        "group.add.pov",
        "group.add",
        "group.remove.vip",
        "group.remove.operationsmanager",
        "group.remove.staffmanager",
        "group.remove.commanager",
        "group.remove.headadmin",
        "group.remove.senioradmin",
        "group.remove.administrator",
        "group.remove.srmoderator",
        "group.remove.moderator",
        "group.remove.supportteam",
        "group.remove.trial",
        "group.remove.pov",
        "group.remove",
        "admin.tickets",
        "cardev.menu",
        "vip.gunstore",
        "vip.garage",
        "police.dev"
       
       
    },

   ["Events Team"] = {
        'admin.revive',
        "admin.tp2player",
        "admin.slap",
        "admin.spectate",
       
       
    },

    ["Car Developer"] = {
        "cardev.menu"
    },

    -- UKBF

    ["Director General"] = {
        "ukbf.whitelisted",
        "ukbf.director.whitelisted"
    },

    ["Director General Clocked"] = {
        "ukbf.director.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },

    --
    ["Regional Director"] = {
        "ukbf.regional.whitelisted",
        "ukbf.whitelisted",
    },

    ["Regional Director Clocked"] = {
        "ukbf.regional.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Assistant Director"] = {
        "ukbf.whitelisted",
        "ukbf.assistantdirector.whitelisted"
    },

    ["Assistant Director Clocked"] = {
        "ukbf.assistantdirector.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },
    --
    ["HM Inspector"] = {
        "ukbf.whitelisted",
        "ukbf.hminspector.whitelisted"
    },

    ["HM Inspector Clocked"] = {
        "ukbf.hminspector.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Chief Immigration Officer"] = {
        "ukbf.whitelisted",
        "ukbf.chiefimmigrationofficer.whitelisted"
    },

    ["Chief Immigration Officer Clocked"] = {
        "ukbf.chiefimmigrationofficer.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Tactical Command"] = {
        "ukbf.whitelisted",
        "ukbf.tacticalcommand.whitelisted"
    },

    ["Tactical Command Clocked"] = {
        "ukbf.tacticalcommand.whitelisted",
        "ukbf.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Senior Immigration Officer"] = {
        "ukbf.whitelisted",
        "ukbf.seniorimmigrationofficer.whitelisted"
    },

    ["Senior Immigration Officer Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.seniorimmigrationofficer.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Higher Immigration Officer"] = {
        "ukbf.whitelisted",
        "ukbf.higherimmigrationofficer.whitelisted"
    },

    ["Higher Immigration Officer Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.higherimmigrationofficer.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Assistant Immigration Officer"] = {
        "ukbf.whitelisted",
        "ukbf.assistantimmigrationofficer.whitelisted"
    },

    ["Assistant Immigration Officer Clocked"] = {
        "ukbf.assistantimmigrationofficer.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Administrative Assistant"] = {
        "ukbf.whitelisted",
        "ukbf.administrativeassistant.whitelisted"
    },

    ["Administrative Assistant Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.administrativeassistant.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Special Officer"] = {
        "ukbf.whitelisted",
        "ukbf.specialofficer.whitelisted"
    },

    ["Special Officer Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.specialofficer.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Cutters Specialist"] = {
        "ukbf.whitelisted",
        "ukbf.cuttersspecialist.whitelisted"
    },

    ["Cutters Specialist Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.cuttersspecialist.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Cutters Instructor"] = {
        "ukbf.whitelisted",
        "ukbf.cuttersinstructor.whitelisted"
    },

    ["Cutters Instructor Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.cuttersinstructor.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Chief Captain"] = {
        "ukbf.whitelisted",
        "ukbf.chiefcaptain.whitelisted"
    },

    ["Chief Captain Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.chiefcaptain.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Captain"] = {
        "ukbf.whitelisted",
        "ukbf.captain.whitelisted"
    },

    ["Captain Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.captain.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Coxswain"] = {
        "ukbf.whitelisted",
        "ukbf.coxswain.whitelisted"
    },

    ["Coxswain Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.coxswain.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Senior Deckhand"] = {
        "ukbf.whitelisted",
        "ukbf.seniordeckhand.whitelisted"
    },

    ["Senior Deckhand Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.seniordeckhand.whitelisted",
        "ukbf.armoury",
    },
    --
    ["Deckhand"] = {
        "ukbf.whitelisted",
        "ukbf.deckhand.whitelisted"
    },

    ["Deckhand Clocked"] = {
        "ukbf.whitelisted",
        "ukbf.deckhand.whitelisted",
        "ukbf.armoury",
    },
    --
    
   

--  ███╗░░░███╗███████╗████████╗  ██████╗░░█████╗░██╗░░░░░██╗░█████╗░███████╗
--  ████╗░████║██╔════╝╚══██╔══╝  ██╔══██╗██╔══██╗██║░░░░░██║██╔══██╗██╔════╝
--  ██╔████╔██║█████╗░░░░░██║░░░  ██████╔╝██║░░██║██║░░░░░██║██║░░╚═╝█████╗░░
--  ██║╚██╔╝██║██╔══╝░░░░░██║░░░  ██╔═══╝░██║░░██║██║░░░░░██║██║░░██╗██╔══╝░░
--  ██║░╚═╝░██║███████╗░░░██║░░░  ██║░░░░░╚█████╔╝███████╗██║╚█████╔╝███████╗
--  ╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░  ╚═╝░░░░░░╚════╝░╚══════╝╚═╝░╚════╝░╚══════╝
                                                              
    ["Large Arms Access"] = {
        "police.loadshop2",
        "police.maxarmour"
    }, 
    ["Police Horse Trained"] = {}, 
    ["K9 Trained"] = {}, 
    ["Drone"] = {},
    ["NPAS Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.npas",
    },
    ["NPAS"] = {
        "cop.whitelisted"
    },
    ["Trident Command Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.undercover",
        "police.tridentcommand",
    },
    ["Trident Command"] = {
        "cop.whitelisted"
    },
    ["Trident Officer Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.undercover",
        "police.tridentofficer",
    },
    ["Trident Officer"] = {
        "cop.whitelisted"
    },
    ["Commissioner Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.announce",
        "police.commissioner",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Commissioner"] = {
        "cop.whitelisted"
    },
    ["Deputy Commissioner Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.announce",
        "police.deputycommissioner",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Deputy Commissioner"] = {
        "cop.whitelisted"
    },
    ["Assistant Commissioner Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.announce",
        "police.assistantcommissioner",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Assistant Commissioner"] = {
        "cop.whitelisted"
    },
    ["Dep. Asst. Commissioner Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.announce",
        "police.deputyassistantcommissioner",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Dep. Asst. Commissioner"] = {
        "cop.whitelisted"
    },
    ["Commander Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.announce",
        "police.commander",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Commander"] = {
        "cop.whitelisted"
    },
    ["Chief Superintendent Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.chiefsuperintendent",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Chief Superintendent"] = {
        "cop.whitelisted"
    },
    ["Superintendent Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.superintendent",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Superintendent"] = {
        "cop.whitelisted"
    },
    ["Special Constable Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.specialconstable",
        "police.announce",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Special Constable"] = {
        "cop.whitelisted",
    },
    ["Chief Inspector Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.chiefinspector",
        "police.maxarmour",
        "police.onduty.permission",
    },
    ["Chief Inspector"] = {
        "cop.whitelisted"
    },
    ["Inspector Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.inspector",
        "police.onduty.permission",
    },
    ["Inspector"] = {
        "cop.whitelisted"
    },
    ["Sergeant Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.sergeant",
        "police.onduty.permission",
    },
    ["Sergeant"] = {
        "cop.whitelisted"
    },
    ["Senior Constable Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.seniorconstable",
        "police.onduty.permission",
    },
    ["Senior Constable"] = {
        "cop.whitelisted"
    },
    ["PC Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.constable",
        "police.onduty.permission",
    },
    ["PC"] = {
        "cop.whitelisted"
    },
    ["PCSO Clocked"] = {
        "cop.whitelisted",
        "police.armoury",
        "police.armoury",
        "police.pcso",
        "police.onduty.permission",
    },
    ["PCSO"] = {
        "cop.whitelisted",

    },

    -- START LFB --

["LFBTrainee Firefighter Clocked"] = {
    "lfb.provisionalfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Firefighter Clocked"] = {
    "lfb.juniorfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Crew Manager Clocked"] = {
    "lfb.firefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Watch Manager Clocked"] = {
    "lfb.seniorfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Station Manager Clocked"] = {
    "lfb.advancedfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Group Manager Clocked"] = {
    "lfb.specialistfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Area Manager Clocked"] = {
    "lfb.leadingfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Sector Command Clocked"] = {
    "lfb.sectorcommand",
"lfb.menu",
"lfb.whitelisted",
},

["Divisional Command Clocked"] = {
    "lfb.divisionalcommand",
"lfb.menu",
"lfb.whitelisted",
},

["Divisional Officer Clocked"] = {
    "lfb.divisionalofficer",
"lfb.menu",
"lfb.whitelisted",
},

["Honourable Firefighter Clocked"] = {
    "lfb.honaryfirefighter",
"lfb.menu",
"lfb.whitelisted",
},

["Fire Command Advisor Clocked"] = {
    "lfb.firecommandadvisor",
"lfb.menu",
"lfb.whitelisted",
},

["Assistant Chief Fire Officer Clocked"] = {
    "lfb.assistantchieffireofficer",
"lfb.menu",
"lfb.whitelisted",
},

["Deputy Chief Fire Officer Clocked"] = {
    "lfb.deputychieffireofficer",
"lfb.menu",
"lfb.whitelisted",
},

["Chief Fire Officer Clocked"] = {
"lfb.chieffirecommand",
"lfb.menu",
"lfb.whitelisted",
},

["Trainee Firefighter"] = {
"lfb.whitelisted",
},

["Firefighter"] = {
"lfb.whitelisted",
},

["Crew Manager"] = {
"lfb.whitelisted",
},

["Watch Manager"] = {
"lfb.whitelisted",
},

["Station Manager"] = {
"lfb.whitelisted",
},

["Group Manager"] = {
"lfb.whitelisted",
},

["Area Manager"] = {
"lfb.whitelisted",
},

["Sector Command"] = {
"lfb.whitelisted",
},

["Divisional Command"] = {
"lfb.whitelisted",
},

["Divisional Officer"] = {
"lfb.whitelisted",
},

["Honourable Firefighter"] = {
"lfb.whitelisted",
},

["Fire Command Advisor"] = {
"lfb.whitelisted",
},

["Assistant Chief Fire Officer"] = {
"lfb.whitelisted",
},

["Deputy Chief Fire Officer"] = {
"lfb.whitelisted",
},

["Chief Fire Officer"] = {
"lfb.whitelisted",
},


-- END OF LFB --

-- START HMP --

  ["Trainee Prison Officer Clocked"] = {
		"hmp.traineeprisonofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Prison Officer Clocked"] = {
		"hmp.prisonofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Senior Officer Clocked"] = {
		"hmp.seniorofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Specialist Officer Clocked"] = {
		"hmp.specialistofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Principal Officer Clocked"] = {
		"hmp.principalofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Supervising Officer Clocked"] = {
		"hmp.supervisingofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Honourable Guard Clocked"] = {
	"hmp.honourableguard",
    "hmp.menu",
"hmp.announce",
	},

  ["Custodial Officer Clocked"] = {
		"hmp.custodialofficer",
    "hmp.menu",
"hmp.announce",
	},

  ["Custodial Supervisor Clocked"] = {
	"hmp.custodialsupervisor",
    "hmp.menu",
"hmp.announce",
	},
  
  ["Divisional Commander Clocked"] = {
	"hmp.divisionalcommander",
    "hmp.menu",
"hmp.announce",
	},

  ["Deputy Governor Clocked"] = {
	"hmp.deputygovernor",
    "hmp.menu",
"hmp.announce",
	},

  ["Governor Clocked"] = {
	"hmp.governor",
    "hmp.menu",
"hmp.announce",
	},

  ["Prison Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Senior Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Specialist Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Principal Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Supervising Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Honourable Guard"] = {
    "prisonguard.whitelisted",
	},

  ["Custodial Officer"] = {
    "prisonguard.whitelisted",
	},

  ["Custodial Supervisor"] = {
    "prisonguard.whitelisted",
	},
  
  ["Divisional Commander"] = {
    "prisonguard.whitelisted",
	},

  ["Deputy Governor"] = {
    "prisonguard.whitelisted",
	},

  ["Governor"] = {
    "prisonguard.whitelisted",

	},

  -- END OF HMP --


--  ███╗░░██╗██╗░░██╗░██████╗
--  ████╗░██║██║░░██║██╔════╝
--  ██╔██╗██║███████║╚█████╗░
--  ██║╚████║██╔══██║░╚═══██╗
--  ██║░╚███║██║░░██║██████╔╝
--  ╚═╝░░╚══╝╚═╝░░╚═╝╚═════╝░

    ["HEMS Clocked"] = {
        "nhs.whitelisted",
        "nhs.menu",
        "nhs.hems",
    },
    ["HEMS"] = {
        "nhs.whitelisted"
    },                                               
    ["NHS Head Chief Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.headchief",
        "nhs.announce",
    },
    ["NHS Head Chief"] = {
        "nhs.whitelisted",
    },
    ["NHS Assistant Chief Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.assistantchief",
        "nhs.announce",
    },
    ["NHS Assistant Chief"] = {
        "nhs.whitelisted",
    },
    ["NHS Deputy Chief Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.deputychief",
        "nhs.announce",
    },
    ["NHS Deputy Chief"] = {
        "nhs.whitelisted",
    },
    ["NHS Combat Medic Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.combatmedic",
        "nhs.announce",
    },
    ["NHS Combat Medic"] = {
        "nhs.whitelisted",
    },
    ["NHS Captain Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.announce",
    },
    ["NHS Captain"] = {
        "nhs.whitelisted",
        "nhs.captain",
    },
    ["NHS Consultant Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.consultant",
    },
    ["NHS Consultant"] = {
        "nhs.whitelisted",
    },
    ["NHS Specialist Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.specialist",
    },
    ["NHS Specialist"] = {
        "nhs.whitelisted",
    },
    ["NHS Senior Doctor Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.seniordoctor",
    },
    ["NHS Senior Doctor"] = {
        "nhs.whitelisted",
    },
    ["NHS Doctor Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.doctor",
    },
    ["NHS Doctor"] = {
        "nhs.whitelisted",
    },
    ["NHS Junior Doctor Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.juniordoctor",
    },
    ["NHS Junior Doctor"] = {
        "nhs.whitelisted",
    },
    ["NHS Critical Care Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.criticalcare",
    },
    ["NHS Critical Care"] = {
        "nhs.whitelisted",
    },
    ["NHS Paramedic Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.paramedic",
    },
    ["NHS Paramedic"] = {
        "nhs.whitelisted",
    },
    ["NHS Trainee Paramedic Clocked"] = {
        "nhs.menu",
        "nhs.whitelisted",
        "nhs.traineeparamedic",
    },
    ["NHS Trainee Paramedic"] = {
        "nhs.whitelisted",
    },

--  ██╗░░░░░██╗░█████╗░███████╗███╗░░██╗░██████╗███████╗░██████╗
--  ██║░░░░░██║██╔══██╗██╔════╝████╗░██║██╔════╝██╔════╝██╔════╝
--  ██║░░░░░██║██║░░╚═╝█████╗░░██╔██╗██║╚█████╗░█████╗░░╚█████╗░
--  ██║░░░░░██║██║░░██╗██╔══╝░░██║╚████║░╚═══██╗██╔══╝░░░╚═══██╗
--  ███████╗██║╚█████╔╝███████╗██║░╚███║██████╔╝███████╗██████╔╝
--  ╚══════╝╚═╝░╚════╝░╚══════╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═════╝░

    ["Weed"] = {},
    ["Cocaine"] = {},
    ["Meth"] = {},
    ["Heroin"] = {},
    ["LSD"] = {},
    ["Copper"] = {},
    ["Limestone"] = {},
    ["Gold"] = {},
    ["Diamond"] = {},
    ["Trapping"] = {},
    ["Gang"] = {
        "gang.whitelisted"
    },
    ["Highroller"] = {
        "casino.highrollers"
    },
    ["Rebel"] = {
        "rebellicense.whitelisted"
    },
    ["AdvancedRebel"] = {
        "advancedrebel.license"
    },
    
--  ██████╗░░█████╗░███╗░░██╗░█████╗░████████╗░█████╗░██████╗░
--  ██╔══██╗██╔══██╗████╗░██║██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗
--  ██║░░██║██║░░██║██╔██╗██║███████║░░░██║░░░██║░░██║██████╔╝
--  ██║░░██║██║░░██║██║╚████║██╔══██║░░░██║░░░██║░░██║██╔══██╗
--  ██████╔╝╚█████╔╝██║░╚███║██║░░██║░░░██║░░░╚█████╔╝██║░░██║
--  ╚═════╝░░╚════╝░╚═╝░░╚══╝╚═╝░░╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝
                                                                         
    ["Supporter"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Premium"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Beta"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Supreme"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Kingpin"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Rainmaker"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },
    ["Baller"] = {
        "vip.gunstore",
        "vip.garage",
        "vip.aircraft",
    },

--  ███╗░░░███╗██╗░██████╗░█████╗░███████╗██╗░░░░░██╗░░░░░░█████╗░███╗░░██╗███████╗░█████╗░██╗░░░██╗░██████╗
--  ████╗░████║██║██╔════╝██╔══██╗██╔════╝██║░░░░░██║░░░░░██╔══██╗████╗░██║██╔════╝██╔══██╗██║░░░██║██╔════╝
--  ██╔████╔██║██║╚█████╗░██║░░╚═╝█████╗░░██║░░░░░██║░░░░░███████║██╔██╗██║█████╗░░██║░░██║██║░░░██║╚█████╗░
--  ██║╚██╔╝██║██║░╚═══██╗██║░░██╗██╔══╝░░██║░░░░░██║░░░░░██╔══██║██║╚████║██╔══╝░░██║░░██║██║░░░██║░╚═══██╗
--  ██║░╚═╝░██║██║██████╔╝╚█████╔╝███████╗███████╗███████╗██║░░██║██║░╚███║███████╗╚█████╔╝╚██████╔╝██████╔╝
--  ╚═╝░░░░░╚═╝╚═╝╚═════╝░░╚════╝░╚══════╝╚══════╝╚══════╝╚═╝░░╚═╝╚═╝░░╚══╝╚══════╝░╚════╝░░╚═════╝░╚═════╝░   

    ["pov"] = {
        "pov.list"
    },
    ["DJ"] = {
        "dj.menu"
    },
    ["PilotLicense"] = {
        "air.whitelisted"
    },
    ["OG"] = {
        "og.menu"
    },
    ["OG Admin"] = {
        "og.giveaways"
    },
    ["NewPlayer"] = {
        -- "pov.list"
    },
    ["AA Mechanic"] = {
        "aa.menu"
    },
    ["Cinematic"] = {},
    ["TutorialDone"] = {
        "tutorial.user"
    },
    ["polblips"] = {},
    -- Default Jobs
    ["Royal Mail Driver"] = {},
    ["Deliveroo"] = {},
    ["G4S Driver"] = {},
    ["Lorry Driver"] = {},
    ["Taco Seller"] = {},
}

return cfg
