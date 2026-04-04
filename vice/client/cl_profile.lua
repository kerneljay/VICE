local pfp = nil

RegisterNetEvent('VICE:receiveAvatar')
AddEventHandler('VICE:receiveAvatar', function(url)
    print("[DEBUG] Received avatar URL from server:", url)
    pfp = url
    updateProfilePicture()
end)

local function updateProfilePicture()
    print("[DEBUG] Attempting to get profile picture...")
    if pfp then
        print("[DEBUG] Sending profile picture to UI:", pfp)
        SendNUIMessage({
            type = "UPDATE_PROFILE_PIC",
            url = pfp
        })
    else
        print("[DEBUG] No profile picture URL yet, requesting from server...")
        TriggerServerEvent("VICE:requestAvatar", VICE.getUserId())
    end
end

RegisterNetEvent('VICE:playerSpawned')
AddEventHandler('VICE:playerSpawned', function()
    print("[DEBUG] Player spawned, updating profile picture")
    updateProfilePicture()
end)

RegisterNetEvent('VICE:profilePicUpdated')
AddEventHandler('VICE:profilePicUpdated', function()
    print("[DEBUG] Profile picture updated event received")
    updateProfilePicture()
end) 