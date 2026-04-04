local cfg=module("cfg/cfg_groupselector")

function VICE.getJobSelectors(source)
    local source=source
    local jobSelectors={}
    local user_id = VICE.getUserId(source)
    for k,v in pairs(cfg.selectors) do
        for i,j in pairs(cfg.selectorTypes) do
            if v.type == i then
                if j._config.permissions[1]~=nil then
                    if VICE.hasPermission(VICE.getUserId(source),j._config.permissions[1])then
                        v['_config'] = j._config
                        v['jobs'] = {}
                        for a,b in pairs(j.jobs) do
                            if VICE.hasGroup(user_id, b[1]) then
                                table.insert(v['jobs'], b)
                            end
                        end
                        jobSelectors[k] = v
                    end
                else
                    v['_config'] = j._config
                    v['jobs'] = j.jobs
                    jobSelectors[k] = v
                end
            end
        end
    end
    TriggerClientEvent("VICE:gotJobSelectors",source,jobSelectors)
end

RegisterNetEvent("VICE:getJobSelectors")
AddEventHandler("VICE:getJobSelectors",function()
    local source = source
    VICE.getJobSelectors(source)
end)

function VICE.removeAllJobs(user_id)
    local source = VICE.getUserSource(user_id)
    for i,j in pairs(cfg.selectorTypes) do
        for k,v in pairs(j.jobs)do
            if i == 'default' and VICE.hasGroup(user_id, v[1]) then
                VICE.removeUserGroup(user_id, v[1])
            elseif i ~= 'default' and VICE.hasGroup(user_id, v[1]..' Clocked') then
                VICE.removeUserGroup(user_id, v[1]..' Clocked')
                RemoveAllPedWeapons(GetPlayerPed(source), true)
                VICEclient.setArmour(source, {0})
                TriggerEvent('VICE:clockedOffRemoveRadio', source)
            end
        end
    end
    -- remove all faction ranks
    VICEclient.setPolice(source, {false})
    TriggerClientEvent('viceui:globalOnPoliceDuty', source, false)
    VICEclient.setNHS(source, {false})
    TriggerClientEvent('viceui:globalOnNHSDuty', source, false)
    VICEclient.setHMP(source, {false})
    TriggerClientEvent('viceui:globalOnUKBFDuty', source, false)
    VICEclient.setUKBF(source, {false})
    TriggerClientEvent('viceui:globalOnPrisonDuty', source, false)
    VICEclient.setLFB(source, {false})
    TriggerClientEvent('viceui:globalLFBOnDuty', source, false)
    VICEclient.setAA(source, {false})
    TriggerClientEvent('viceui:globalOnAADuty', source, false)
    TriggerClientEvent('VICE:disableFactionBlips', source)
    TriggerClientEvent('VICE:radiosClearAll', source)
    -- toggle all main jobs to false
    TriggerClientEvent('VICE:toggleTacoJob', source, false)
    TriggerClientEvent('VICE:setTruckerOnDuty', source, false)
end

RegisterNetEvent("VICE:jobSelector")
AddEventHandler("VICE:jobSelector",function(a,b)
    local source = source
    local user_id = VICE.getUserId(source)
    if #(GetEntityCoords(GetPlayerPed(source)) - cfg.selectors[a].position) > 20 then
        VICE.ACBan(15,user_id,"VICE:jobSelector")
        return
    end
    if b == "Unemployed" then
        VICE.removeAllJobs(user_id)
        VICE.notify(source, "~g~You are now unemployed.")
        TriggerClientEvent("VICE:jobSelectorCooldown", source, true)
    else
        if cfg.selectors[a].type == 'police' then
            if VICE.hasGroup(user_id, b) then
                if not VICE.hasGroup(user_id,b..' Clocked') then
                    VICE.removeAllJobs(user_id)
                    VICE.addUserGroup(user_id,b..' Clocked')
                    VICEclient.setPolice(source, {true})
                    TriggerClientEvent('viceui:globalOnPoliceDuty', source, true)
                    VICE.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    VICE.sendDCLog('pd-clock', 'VICE Police Clock On Logs',"> Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Officer TempID: **"..source.."**\n> Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                    TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
                else
                    VICE.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                VICE.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'nhs' then
            if VICE.hasGroup(user_id, b) then
                if not VICE.hasGroup(user_id,b..' Clocked') then
                    VICE.removeAllJobs(user_id)
                    VICE.addUserGroup(user_id,b..' Clocked')
                    VICEclient.setNHS(source, {true})
                    TriggerClientEvent('viceui:globalOnNHSDuty', source, true)
                    VICE.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    VICE.sendDCLog('nhs-clock', 'VICE NHS Clock On Logs',"> Medic Name: **"..VICE.getPlayerName(user_id).."**\n> Medic TempID: **"..source.."**\n> Medic PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                else
                    VICE.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                VICE.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'ukbf' then
            if VICE.hasGroup(user_id, b) then
                if not VICE.hasGroup(user_id,b..' Clocked') then
                    VICE.removeAllJobs(user_id)
                    VICE.addUserGroup(user_id,b..' Clocked')
                    VICEclient.setUKBF(source, {true})
                    TriggerClientEvent('viceui:globalOnUKBFDuty', source, true)
                    VICE.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
                else
                    VICE.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                VICE.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'lfb' then
            if VICE.hasGroup(user_id, b) then
                if not VICE.hasGroup(user_id,b..' Clocked') then
                    VICE.removeAllJobs(user_id)
                    VICE.addUserGroup(user_id,b..' Clocked')
                    VICEclient.setLFB(source, {true})
                    TriggerClientEvent('viceui:globalOnLFBDuty', source, true)
                    VICE.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
                else
                    VICE.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                VICE.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        elseif cfg.selectors[a].type == 'hmp' then
            if VICE.hasGroup(user_id, b) then
                if not VICE.hasGroup(user_id,b..' Clocked') then
                    VICE.removeAllJobs(user_id)
                    VICE.addUserGroup(user_id,b..' Clocked')
                    VICEclient.setHMP(source, {true})
                    TriggerClientEvent('viceui:globalOnPrisonDuty', source, true)
                    VICE.notify(source, "~g~Clocked on as "..b..".")
                    RemoveAllPedWeapons(GetPlayerPed(source), true)
                    VICE.sendDCLog('hmp-clock', 'VICE HMP Clock On Logs',"> Prison Officer Name: **"..VICE.getPlayerName(user_id).."**\n> Prison Officer TempID: **"..source.."**\n> Prison Officer PermID: **"..user_id.."**\n> Clocked Rank: **"..b.."**")
                else
                    VICE.notify(source, "~r~You are already clocked on as "..b..".")
                end
            else
                VICE.notify(source, "~r~You do not have permission to clock on as "..b..".")
            end
        else
            VICE.removeAllJobs(user_id)
            VICE.addUserGroup(user_id,b)
            VICE.notify(source, "~g~Employed as "..b..".")
            TriggerClientEvent('viceui:jobInstructions',source,b)
            if b == 'Taco Seller' then
                TriggerClientEvent('VICE:toggleTacoJob', source, true)
            end
            if b == 'AA Mechanic' then
                VICEclient.setAA(source, {true})
                TriggerClientEvent('viceui:globalOnAADuty', source, true)
            end
            if b == 'Lorry Driver' then
                TriggerClientEvent('VICE:setTruckerOnDuty', source, true)
            end
        end
        TriggerClientEvent("VICE:jobSelectorCooldown", source, false)
        TriggerEvent('VICE:clockedOnCreateRadio', source)
        TriggerClientEvent('VICE:radiosClearAll', source)
        TriggerClientEvent('VICE:refreshGunStorePermissions', source)
        VICE.updateCurrentPlayerInfo()
    end
end)