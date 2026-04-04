local cfg = {}

cfg.metPoliceRanks = {
    {"CID Constable", 60000, "police.cidconstable.whitelisted"},
    {"Special Constable", 82500, "police.specialconstable.whitelisted"},
    {"NPAS", 67500, "police.npas.whitelisted"},
    {"Custody Sergeant", 30000, "police.custodysergeant.whitelisted"},
    {"PCSO", 30000, "police.pcso.whitelisted"},
    {"PC", 37500, "police.constable.whitelisted"},
    {"Senior Constable", 45000, "police.seniorconstable.whitelisted"},
    {"Sergeant", 52500, "police.sergeant.whitelisted"},
    {"Inspector", 60000, "police.inspector.whitelisted"},
    {"Chief Inspector", 67500, "police.chiefinspector.whitelisted"},
    {"Superintendent", 75000, "police.superintendent.whitelisted"},
    {"Chief Superintendent", 82500, "police.chiefsuperintendent.whitelisted"},
    {"GC Advisor", 90000, "police.advisor.whitelisted"},
    {"Commander", 90000, "police.commander.whitelisted"},
    {"Dep. Asst. Commissioner", 97500, "police.deputyassistantcommissioner.whitelisted"},
    {"Assistant Commissioner", 105000, "police.assistantcommissioner.whitelisted"},
    {"Deputy Commissioner", 112500, "police.deputycommissioner.whitelisted"},
    {"Commissioner", 120000, "police.commissioner.whitelisted"}
}

cfg.ukbfRanks = {
    {"Director General", 80000, "ukbf.director.whitelisted"},
    {"Regional Director", 75000, "ukbf.regional.whitelisted"},
    {"Assistant Director", 70000, "ukbf.assistantdirector.whitelisted"},
    {"HM Inspector", 65000, "ukbf.hminspector.whitelisted"},
    {"Chief Immigration Officer", 60000, "ukbf.chiefimmigrationofficer.whitelisted"},
    {"Tactical Command", 55000, "ukbf.tacticalcommand.whitelisted"},
    {"Senior Immigration Officer", 50000, "ukbf.seniorimmigrationofficer.whitelisted"},
    {"Higher Immigration Officer", 45000, "ukbf.higherimmigrationofficer.whitelisted"},
    {"Assistant Immigration Officer", 40000, "ukbf.assistantimmigrationofficer.whitelisted"},
    {"Administrative Assistant", 35000, "ukbf.administrativeassistant.whitelisted"},
    {"Special Officer", 30000, "ukbf.specialofficer.whitelisted"},
    {"Cutters Specialist", 25000, "ukbf.cuttersspecialist.whitelisted"},
    {"Cutters Instructor", 20000, "ukbf.cuttersinstructor.whitelisted"},
    {"Chief Captain", 15000, "ukbf.chiefcaptain.whitelisted"},
    {"Captain", 10000, "ukbf.captain.whitelisted"},
    {"Coxswain", 5000, "ukbf.coxswain.whitelisted"},
    {"Senior Deckhand", 3000, "ukbf.seniordeckhand.whitelisted"},
    {"Deckhand", 1000, "ukbf.deckhand.whitelisted"},
}

cfg.nhsRanks = {
    {"HEMS", 60000, "nhs.hems.whitelisted"},
    {"NHS Trainee Paramedic", 37500, "nhs.traineeparamedic.whitelisted"},
    {"NHS Paramedic", 45000, "nhs.paramedic.whitelisted"},
    {"NHS Critical Care", 52500, "nhs.criticalcare.whitelisted"},
    {"NHS Junior Doctor", 60000, "nhs.juniordoctor.whitelisted"},
    {"NHS Doctor", 67500, "nhs.doctor.whitelisted"},
    {"NHS Senior Doctor", 75000, "nhs.seniordoctor.whitelisted"},
    {"NHS Specialist", 82500, "nhs.specialist.whitelisted"},
    {"NHS Consultant", 90000, "nhs.consultant.whitelisted"},
    {"NHS Captain", 97500, "nhs.captain.whitelisted"},
    {"NHS Medical Advisor", 90000, "nhs.advisor.whitelisted"},
    {"NHS Combat Medic", 105000, "nhs.combatmedic.whitelisted"},
    {"NHS Deputy Chief", 105000, "nhs.deputychief.whitelisted"},
    {"NHS Assistant Chief", 112500, "nhs.assistantchief.whitelisted"},
    {"NHS Head Chief", 120000, "nhs.headchief.whitelisted"}
}

cfg.lfbRanks = {
    {"Trainee Firefighter", 37500, "lfb.provisionalfirefighter.whitelisted"},
    {"Firefighter", 45000, "lfb.juniorfirefighter.whitelisted"},
    {"Crew Manager", 48750, "lfb.firefighter.whitelisted"},
    {"Watch Manager", 52500, "lfb.seniorfirefighter.whitelisted"},
    {"Station Manager", 56250, "lfb.advancedfirefighter.whitelisted"},
    {"Group Manager", 60000, "lfb.specialistfirefighter.whitelisted"},
    {"Area Manager", 67500, "lfb.leadingfirefighter.whitelisted"},
    {"Sector Command", 75000, "lfb.sectorcommand.whitelisted"},
    {"Divisional Command", 82500, "lfb.divisionalcommand.whitelisted"},
    {"Divisional Officer", 97500, "lfb.divisionalofficer.whitelisted"},
    {"Honourable Firefighter", 90000, "lfb.honaryfirefighter.whitelisted"},
    {"Fire Command Advisor", 90000, "lfb.firecommandadvisor.whitelisted"},
    {"Assistant Chief Fire Officer", 105000, "lfb.assistantchieffireofficer.whitelisted"},
    {"Deputy Chief Fire Officer", 112500, "lfb.deputychieffireofficer.whitelisted"},
    {"Chief Fire Officer", 120000, "lfb.chieffirecommand.whitelisted"},
}

cfg.hmpRanks = {
    {"HMP Transport", 52500, "hmp.transport.whitelisted"},
    {"Trainee Prison Officer", 37500, "hmp.traineeprisonofficer.whitelisted"},
    {"Prison Officer", 45000, "hmp.prisonofficer.whitelisted"},
    {"Senior Officer", 48750, "hmp.seniorofficer.whitelisted"},
    {"Specialist Officer", 52500, "hmp.specialistofficer.whitelisted"},
    {"Principal Officer", 60000, "hmp.principalofficer.whitelisted"},
    {"Supervising Officer", 70000, "hmp.supervisingofficer.whitelisted"},
    {"Honourable Guard", 90000, "hmp.honourableguard.whitelisted"},
    {"HMP Advisor", 90000, "hmp.advisor.whitelisted"},
    {"Custodial Officer", 90000, "hmp.custodialofficer.whitelisted"},
    {"Custodial Supervisor", 97500, "hmp.custodialsupervisor.whitelisted"},
    {"Divisional Commander", 105000, "hmp.divisionalcommander.whitelisted"},
    {"Deputy Governor", 112500, "hmp.deputygovernor.whitelisted"},
    {"Governor", 120000, "hmp.governor.whitelisted"},
}

cfg.casinoRanks = {
    {"Casino Security", 20000},
    {"Casino Manager", 30000},
    {"Casino Owner", 50000},
}

cfg.defaultPay = 5000

cfg.adminPay = {
    {"Founder", 26000, "group.add.founder"}, -- £26,000
    {"Lead Developer", 24000, "pay.ldev"}, -- £24,000
    {"Developer", 22000, "pay.dev"}, -- £22,000
    {"Staff Manager", 50000, "pay.staffmanager"}, -- £50,000
    {"Community Manager", 50000, "pay.commanager"}, -- £50,000
    {"Head Administrator", 50000, "pay.headadmin"}, -- £50,000
    {"Senior Administrator", 45000, "pay.sradmin"}, -- £45,000
    {"Administrator", 42500, "pay.admin"}, -- £42,500
    {"Senior Moderator", 40000, "pay.srmoderator"}, -- £40,000
    {"Moderator", 35000, "pay.mod"}, -- £35,000
    {"Support Team", 30000, "pay.steam"}, -- £30,000
    {"Trial Staff", 25000, "pay.trial"}, -- £25,000
}

return cfg