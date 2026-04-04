turfData = {
    {name = 'Weed', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- weed
    {name = 'Cocaine', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- cocaine
    {name = 'Meth', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- meth
    {name = 'Heroin', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- heroin
    {name = 'LargeArms', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- large arms
    {name = 'LSDNorth', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0}, -- lsd north
    {name = 'LSDSouth', gangOwner = "N/A", commission = 0, beingCaptured = false, timeLeft = 300, cooldown = 0} -- lsd south
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for k,v in pairs(turfData) do
            if v.cooldown > 0 then
                v.cooldown = v.cooldown - 1
            end
        end
    end
end)

RegisterNetEvent('VICE:refreshTurfOwnershipData')
AddEventHandler('VICE:refreshTurfOwnershipData', function()
    local source = source
	local user_id = VICE.getUserId(source)
	local data = turfData
	local gangname = VICE.getGangName(user_id)
	if gangname and gangname ~= "" then
		for a,b in pairs(data) do
			data[a].ownership = false
			if b.gangOwner == gangname then
				data[a].ownership = true
			end
			TriggerClientEvent('VICE:updateTurfOwner', source, a, b.gangOwner)
		end
		TriggerClientEvent('VICE:gotTurfOwnershipData', source, data)
		TriggerClientEvent('VICE:recalculateLargeArms', source, turfData[5].commission)
		VICE.updateTraderInfo()
	end
end)


RegisterNetEvent('VICE:checkTurfCapture')
AddEventHandler('VICE:checkTurfCapture', function(turfid)
    local source = source
    local user_id = VICE.getUserId(source)
    if not VICE.hasPermission(user_id, 'police.armoury') or not VICE.hasPermission(user_id, 'nhs.menu') or not VICE.hasPermission(user_id, 'hmp.menu') then
        if turfData[turfid].cooldown > 0 then 
            VICE.notify(source, 'This turf is on cooldown for another '..turfData[turfid].cooldown..' seconds.')
            return
        end
        -- Check if player has a weapon
        local ped = GetPlayerPed(source)
        local currentWeapon = GetSelectedPedWeapon(ped)
        if currentWeapon == GetHashKey("WEAPON_UNARMED") then
            VICE.notify(source, 'You need a weapon in hand to capture a turf!')
            return
        end
        local gangname = VICE.getGangName(user_id)
        if gangname and turfData[turfid].gangOwner == gangname and gangname ~= "" then
            TriggerClientEvent('VICE:captureOwnershipReturned', source, turfid, true, turfData[turfid].name)
        else
            TriggerClientEvent('VICE:captureOwnershipReturned', source, turfid, false, turfData[turfid].name)
        end
    end
end)

RegisterNetEvent('VICE:gangDefenseLocationUpdate')
AddEventHandler('VICE:gangDefenseLocationUpdate', function(turfname, atkdfnd, trueorfalse)
    local source = source
	local user_id = VICE.getUserId(source)
	local turfID = 0
	for k,v in pairs(turfData) do
		if v.name == turfname then
			turfID = k
		end
	end
	if atkdfnd == 'Attackers' then
		if trueorfalse then
			turfData[turfID].beingCaptured = false
			turfData[turfID].timeLeft = 300
			turfData[turfID].cooldown = 300
			TriggerClientEvent('chatMessage', -1, "^0The "..turfData[turfID].name.." trader is no longer being captured.", { 128, 128, 128 }, "", "alert")
		end
	elseif atkdfnd == 'Defenders' then
		if trueorfalse then
			turfData[turfID].beingCaptured = true
			turfData[turfID].timeLeft = turfData[turfID].timeLeft - 1
			turfData[turfID].cooldown = 300
			TriggerClientEvent('VICE:setBlockedStatus', -1, turfname, true)
		else
			turfData[turfID].beingCaptured = false
			turfData[turfID].timeLeft = 300
			turfData[turfID].cooldown = 300
			TriggerClientEvent('chatMessage', -1, "^0The "..turfData[turfID].name.." is no longer being captured.", { 128, 128, 128 }, "", "alert")
		end
	end
	
end)

RegisterNetEvent('VICE:failCaptureTurfOwned')
AddEventHandler('VICE:failCaptureTurfOwned', function(x)
    local source = source
	local user_id = VICE.getUserId(source)
end)

RegisterNetEvent('VICE:initiateGangCapture')
AddEventHandler('VICE:initiateGangCapture', function(x,y)
    local source = source
	local user_id = VICE.getUserId(source)
	if not VICE.hasPermission(user_id, 'police.armoury') or not VICE.hasPermission(user_id, 'nhs.menu') or not VICE.hasPermission(user_id, 'hmp.menu') then
		if not turfData[x].beingCaptured then
			exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
				for K,V in pairs(gotGangs) do
					for I,L in pairs(json.decode(V.gangmembers)) do
						if tostring(user_id) == I then
							TriggerClientEvent('VICE:initiateGangCaptureCheck', source, y, true)
							turfData[x].beingCaptured = true 
							TriggerClientEvent('chatMessage', -1, "^0The "..turfData[x].name.." trader is being attacked by "..V.gangname..".", {0, 255, 0}, "", "alert")
							if turfData[x].gangOwner ~= 'N/A' then
								exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
									for K,V in pairs(gotGangs) do
										if V.gangname == turfData[x].gangOwner then
											for I,L in pairs(json.decode(V.gangmembers)) do
												if VICE.getUserSource(I) then
													TriggerClientEvent('VICE:defendGangCapture', VICE.getUserSource(I))
												end
											end
										end
									end
								end)
							end
						end
					end
				end
			end)
		else
			VICE.notify(source, 'This turf is currently being captured.')
		end
	else
		VICE.notify(source, 'You cannot capture a turf while on duty.')
	end
end)

RegisterNetEvent('VICE:gangCaptureSuccess')
AddEventHandler('VICE:gangCaptureSuccess', function(turfname)
    local source = source
	local user_id = VICE.getUserId(source)
	for k,v in pairs(turfData) do
		if v.name == turfname then
			exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
				for K,V in pairs(gotGangs) do
					for I,L in pairs(json.decode(V.gangmembers)) do
						if tostring(user_id) == I then
							TriggerClientEvent('chatMessage', -1, "^0The "..v.name.." trader has been captured by "..V.gangname..".", { 128, 128, 128 }, "", "alert")
							for a,b in pairs(json.decode(V.gangmembers)) do
								turfData[k].gangOwner = V.gangname
								turfData[k].commission = V.commission
								turfData[k].cooldown = 300
								turfData[k].beingCaptured = false
								local data = turfData
								data[k].ownership = true
								TriggerClientEvent('VICE:updateTurfOwner', -1, k, V.gangname)
								if VICE.getUserSource(tonumber(a)) then
									TriggerClientEvent('VICE:gotTurfOwnershipData', VICE.getUserSource(tonumber(a)), data)
								end
							end
						end
					end
				end
			end)
		end
	end
end)

RegisterNetEvent('VICE:gangDefenseSuccess')
AddEventHandler('VICE:gangDefenseSuccess', function(turfname)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I then
					for a,b in pairs(turfData) do
						if b.name == turfname then
							TriggerClientEvent('chatMessage', -1, "^0The "..b.name.." trader is no longer being attacked.", { 128, 128, 128 }, "", "alert")
							turfData[a] = {ownership = true, gangOwner = V.gangname, commission = b.commission, cooldown = 300, beingCaptured = false}
							TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
							return
						end
					end
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewWeedPrice')
AddEventHandler('VICE:setNewWeedPrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[1].gangOwner then
					turfData[1].commission = price
					TriggerClientEvent('chatMessage', -1, "^0Weed trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewCocainePrice')
AddEventHandler('VICE:setNewCocainePrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[2].gangOwner then
					turfData[2].commission = price
					TriggerClientEvent('chatMessage', -1, "^0Cocaine trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewMethPrice')
AddEventHandler('VICE:setNewMethPrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[3].gangOwner then
					turfData[3].commission = price
					TriggerClientEvent('chatMessage', -1, "^0Meth trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewHeroinPrice')
AddEventHandler('VICE:setNewHeroinPrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[4].gangOwner then
					turfData[4].commission = price
					TriggerClientEvent('chatMessage', -1, "^0Heroin trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewLargeArmsCommission')
AddEventHandler('VICE:setNewLargeArmsCommission', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[5].gangOwner then
					turfData[5].commission = price
					TriggerClientEvent('chatMessage', -1, "^0Large Arms trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					TriggerClientEvent('VICE:recalculateLargeArms', -1, price)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewLSDNorthPrice')
AddEventHandler('VICE:setNewLSDNorthPrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[6].gangOwner then
					turfData[6].commission = price
					TriggerClientEvent('chatMessage', -1, "^0LSD North trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

RegisterNetEvent('VICE:setNewLSDSouthPrice')
AddEventHandler('VICE:setNewLSDSouthPrice', function(price)
    local source = source
	local user_id = VICE.getUserId(source)
	exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
		for K,V in pairs(gotGangs) do
			for I,L in pairs(json.decode(V.gangmembers)) do
				if tostring(user_id) == I and V.gangname == turfData[7].gangOwner then
					turfData[7].commission = price
					TriggerClientEvent('chatMessage', -1, "^0LSD South trader commission has been set to "..price.."%", { 128, 128, 128 }, "", "alert")
					VICE.updateTraderInfo()
					TriggerClientEvent('VICE:gotTurfOwnershipData', -1, turfData)
					return
				end
			end
		end
	end)
end)

function VICE.turfSaleToGangFunds(amount, drugtype)
	for k,v in pairs(turfData) do
		if v.name == drugtype then
			exports['vice']:execute('SELECT * FROM vice_gangs', function(gotGangs)
				for a,b in pairs(gotGangs) do
					if v.gangOwner == b.gangname then
						if drugtype ~= 'LargeArms' then
							amount = amount*(v.commission/100)/(1-v.commission/100)
						else
							if v.commission == nil then
								v.commission = 0
							end
							amount = amount/(1+v.commission)
						end
						exports['vice']:execute('UPDATE vice_gangs SET funds = funds+@funds WHERE gangname = @gangname', {funds = amount, gangname = b.gangname})
					end
				end
			end)
		end
	end
end