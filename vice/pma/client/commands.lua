local wasProximityDisabledFromOverride = false
disableProximityCycle = false
local maxProximityMode = 1000
RegisterCommand('setvoiceintent', function(source, args)
	if GetConvarInt('voice_allowSetIntent', 1) == 1 then
		local intent = args[1]
		if intent == 'speech' then
			MumbleSetAudioInputIntent(`speech`)
		elseif intent == 'music' then
			MumbleSetAudioInputIntent(`music`)
		end
		LocalPlayer.state:set('voiceIntent', intent, true)
	end
end)

-- TODO: Better implementation of this?
RegisterCommand('vol', function(_, args)
	if not args[1] then return end
	setVolume(tonumber(args[1]))
end)

exports('setAllowProximityCycleState', function(state)
	type_check({state, "boolean"})
	disableProximityCycle = state
end)

function setProximityState(proximityRange, isCustom)
	local voiceModeData = Cfg.voiceModes[mode]
	MumbleSetTalkerProximity(proximityRange + 0.0)
	LocalPlayer.state:set('proximity', {
		index = mode,
		distance = proximityRange,
		mode = isCustom and "Custom" or voiceModeData[2],
	}, true)
	sendUIMessage({
		-- JS expects this value to be - 1, "custom" voice is on the last index
		voiceMode = isCustom and #Cfg.voiceModes or mode - 1
	})
end

exports("overrideProximityRange", function(range, disableCycle)
	type_check({range, "number"})
	if disableCycle then
		disableProximityCycle = true
		wasProximityDisabledFromOverride = true
	end
	setProximityState(range, true)
end)

exports("clearProximityOverride", function()
	local voiceModeData = Cfg.voiceModes[mode]
	if wasProximityDisabledFromOverride then
		disableProximityCycle = false
	end
	setProximityState(voiceModeData[1], false)
end)

RegisterCommand('cycleproximity', function()
	if GetConvarInt('voice_enableProximityCycle', 1) ~= 1 or disableProximityCycle then return end
	local newMode = mode + 1

	-- If we're within the range of our voice modes, allow the increase, otherwise reset to the first state
	if newMode <= #Cfg.voiceModes and newMode <= maxProximityMode then
		mode = newMode
	else
		mode = 1
	end

	TriggerEvent('pma-voice:setTalkingMode', mode)
	setProximityState(Cfg.voiceModes[mode][1], false)
end, false)

RegisterCommand('cycleproximitybackwards', function()
	-- Proximity is either disabled, or manually overwritten.
	if GetConvarInt('voice_enableProximityCycle', 1) ~= 1 or disableProximityCycle then return end
	local newMode = mode - 1

	-- If we're within the range of our voice modes, allow the increase, otherwise reset to the first state
	if newMode > 0 then
		mode = newMode
	else
		mode = #Cfg.voiceModes
		if mode > maxProximityMode then
			mode = maxProximityMode
		end
	end
	TriggerEvent('pma-voice:setTalkingMode', mode)
	setProximityState(Cfg.voiceModes[mode][1], false)
end, false)

if gameVersion == 'fivem' then
	RegisterKeyMapping('cycleproximity', 'Cycle Proximity', 'keyboard', 'PAGEUP')
	RegisterKeyMapping('cycleproximitybackwards', 'Cycle Proximity Backwards', 'keyboard', 'PAGEDOWN')
end

exports("setMaxProximityMode", function(maxMode)
	if maxMode > 0 then
		if mode > maxMode then
			mode = maxMode
			TriggerEvent('pma-voice:setTalkingMode', mode)
			setProximityState(Cfg.voiceModes[mode][1], false)
		end
		maxProximityMode = maxMode
	end
end)

exports("clearMaxProximityMode", function()
	maxProximityMode = 1000
end)