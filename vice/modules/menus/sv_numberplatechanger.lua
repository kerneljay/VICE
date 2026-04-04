local forbiddenNames = {
	"%^1",
	"%^2",
	"%^3",
	"%^4",
	"%^5",
	"%^6",
	"%^7",
	"%^8",
	"%^9",
	"%^%*",
	"%^_",
	"%^=",
	"%^%~",
	"admin",
	"nigger",
	"cunt",
	"faggot",
	"fuck",
	"fucker",
	"fucking",
	"anal",
	"stupid",
	"damn",
	"cock",
	"cum",
	"dick",
	"dipshit",
	"dildo",
	"douchbag",
	"douch",
	"kys",
	"jerk",
	"jerkoff",
	"gay",
	"homosexual",
	"lesbian",
	"suicide",
	"mothafucka",
	"negro",
	"pussy",
	"queef",
	"queer",
	"weeb",
	"retard",
	"masterbate",
	"suck",
	"tard",
	"allahu akbar",
	"terrorist",
	"twat",
	"vagina",
	"wank",
	"whore",
	"wanker",
	"n1gger",
	"f4ggot",
	"n0nce",
	"d1ck",
	"h0m0",
	"n1gg3r",
	"h0m0s3xual",
	"free up mandem",
	"nazi",
	"hitler",
	"cheater",
	"cheating",
}

MySQL.createCommand("VICE/update_numplate","UPDATE vice_user_vehicles SET vehicle_plate = @registration WHERE user_id = @user_id AND vehicle = @vehicle")
MySQL.createCommand("VICE/check_numplate","SELECT * FROM vice_user_vehicles WHERE vehicle_plate = @plate")

RegisterNetEvent('VICE:getCars')
AddEventHandler('VICE:getCars', function()
    local cars = {}
    local source = source
    local user_id = VICE.getUserId(source)
    exports['vice']:execute("SELECT * FROM `vice_user_vehicles` WHERE user_id = @user_id", {user_id = user_id}, function(result)
        if result then 
            for k,v in pairs(result) do
                if v.user_id == user_id then
                    cars[v.vehicle] = {v.vehicle, v.vehicle_plate}
                end
            end
            TriggerClientEvent('VICE:carsTable', source, cars)
        end
    end)
end)

RegisterNetEvent("VICE:ChangeNumberPlate")
AddEventHandler("VICE:ChangeNumberPlate", function(vehicle)
	local source = source
    local user_id = VICE.getUserId(source)
	VICE.prompt(source,"Plate Name:","",function(source, plateName)
		if plateName == '' then return end
		exports['vice']:execute("SELECT * FROM `vice_user_vehicles` WHERE vehicle_plate = @plate", {plate = plateName}, function(result)
            if next(result) then 
                VICE.notify(source, "This plate is already taken.")
                return
			else
				for name in pairs(forbiddenNames) do
					if plateName == forbiddenNames[name] then
						VICE.notify(source, "You cannot have this plate.")
						return
					end
				end
				if VICE.tryFullPayment(user_id,50000) then
					VICE.notify(source, "~g~Changed plate of ~y~"..vehicle.."~g~ to "..plateName)
					MySQL.execute("VICE/update_numplate", {user_id = user_id, registration = plateName, vehicle = vehicle})
					TriggerClientEvent("VICE:ReceiveNumberPlate", source, plateName)
					TriggerClientEvent("vice:PlaySound", source, "apple")
					TriggerEvent('VICE:getCars')
				else
					VICE.notify(source, "You don't have enough money!")
				end
            end
        end)
	end)
end)

RegisterNetEvent("VICE:checkPlateAvailability")
AddEventHandler("VICE:checkPlateAvailability", function(plate)
	local source = source
    local user_id = VICE.getUserId(source)
	MySQL.query("VICE/check_numplate", {plate = plate}, function(result)
		if #result > 0 then 
			VICE.notify(source, "~r~The plate "..plate.." is already taken.")
		else
			VICE.notify(source, "~g~The plate "..plate.." is available.")
		end
	end)
end)