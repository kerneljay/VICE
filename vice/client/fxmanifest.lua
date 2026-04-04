fx_version "cerulean"
games {"gta5"}
lua54 "yes"
resource_type "map" { gameTypes = { fivem = true } }
map "map.lua"
shared_script "@loader/shared/clientloader.lua"

ui_page "ui/index.html"

files{
  "cfg/client.lua",
  "cfg/cfg_*.lua",
  "cfg/*.lua",
  "cfg/blips_markers.lua",
  "cfg/atms.lua",
  "ui/index.html",
  "ui/killfeed/index.html",
  "ui/design.css",
  "ui/main.js",
  "ui/Menu.js",
  "ui/ProgressBar.js",
  "ui/WPrompt.js",
  "ui/RequestManager.js",
  "ui/AnnounceManager.js",
  "ui/Div.js",
  "ui/dynamic_classes.js",
  "ui/fonts/Pdown.woff",
  "ui/fonts/GTA.woff",
  "ui/fonts/*.ttf",
  "ui/fonts/*.otf",
  "ui/sounds/*",
  "ui/pma/*.ogg",
  "ui/*.ogg",
  "ui/*.mp3",
  "ui/pma/css/*.css",
  "ui/pma/js/*.js",
  "ui/index.css",
  "ui/index.js",
  "ui/SoundManager.js",
  "ui/pnc/js/index.js",
  "ui/pnc/js/fine_types.js",
  "ui/pnc/css/index.css",
  "ui/pnc/css/modal.css",
  "ui/pnc/fonts/modes.ttf",
  "ui/pnc/img/tax.png",
  "ui/*.html",
  "ui/tutorial/img/*.png",
  "ui/tutorial/*.css",
  "ui/tutorial/*.js",
  "ui/tutorial/font/*.ttf",
  "ui/*.png",
  "ui/pnc/img/plates.png",
  "ui/fortniteui/*.js",
  "ui/fortniteui/*.css",
  "ui/fortniteui/*.png",
  "ui/playerlist_images/*.png",
  "ui/killfeed/img/*.png",
  "ui/killfeed/font/stratum2-bold-webfont.woff",
  "ui/killfeed/index.js",
  "ui/killfeed/style.css",
  "ui/skin/img/*.png",
  "ui/skin/img/radio-check.png",
  "ui/skin/img/radio-check-black.png",
  "ui/skin/img/heritage/*.jpg",
  "ui/skin/front.js",
  "ui/skin/script.js",
  "ui/skin/style.css",
  "ui/skin/tabs.css",
  "ui/radialmenu/index.js",
  "ui/radialmenu/RadialMenu.js",
  "ui/radialmenu/index.css",
  "ui/radialmenu/RadialMenu.css",
  "ui/speedometer/index.js",
  "ui/speedometer/index.css",
	"ui/speedometer/assets/*.svg",
  "ui/pnc/components/*.js",
  "ui/pnc/components/*.html",
  "ui/pausemenu/*.html",
  "ui/pausemenu/css/*.css",
  "ui/pausemenu/js/*.js",
  "ui/pausemenu/assets/*.svg",
  "ui/pausemenu/assets/*.png",
  "ui/pausemenu/*.otf",
  "ui/pausemenu/css/*.otf",
  "ui/progress/*",
  "ui/radios/index.js",
  "ui/radios/index.css",
  "ui/words.txt",
  "ui/money/img/*.png",
  "ui/money/index.js",
  "ui/money/index.css",
  'ui/loading/**/*',
  "cfg/peds.meta",
  "cfg/hashes.json",
  "ui/wagers/*.js",
  "ui/wagers/*.css",
  "ui/wagers/*.html",
  "ui/wagers/images/*",
}

shared_scripts {
  "util/shared/*",
  "pma/shared.lua",
}

server_scripts{ 
  "modules/database/ghmattimysql-server.js",
  "modules/database/ghmattimysql-server.lua",
  "modules/database/MySQL.lua",
  "util/server/utils.lua",
  '@vice-ac/init.lua',
  "util/server/*.lua",
  --
  "modules/core/core.lua",
  "modules/core/callbacks.lua",
  "util/server/functions.lua",
  --
  "modules/core/survival.lua",
  "modules/core/player_state.lua",
  "modules/group.lua",
  "modules/admin.lua",
  "modules/map.lua",
  "modules/inventory.lua",
  "modules/basic_items.lua",
  "modules/server_commands.lua",
  --
  "modules/core/sv_*.lua",
  "modules/discord/sv_*.lua",
  "modules/events/*.lua",
  "modules/ui/*.lua",
  "modules/menus/*.lua",
  "modules/jobs/*.lua",
  "modules/misc/*.lua",
  "modules/misc/sv_blacklist.lua",
  --
  "cfg/discordroles.lua",
  "pma/server/**/*.lua",
	"pma/server/**/*.js"
}

-- client_scripts {
--   "client/cl_main.lua",
-- }

client_scripts  {
  "util/server/error.lua",
  "rageui/RMenu.lua",
	"rageui/menu/RageUI.lua",
	"rageui/menu/Menu.lua",
	"rageui/menu/MenuController.lua",
	"rageui/components/Audio.lua",
  "rageui/components/Rectangle.lua",
  "rageui/components/Screen.lua",
  "rageui/components/Sprite.lua",
  "rageui/components/Text.lua",
  "rageui/components/Visual.lua",
	"rageui/menu/elements/ItemsBadge.lua",
  "rageui/menu/elements/ItemsColour.lua",
  "rageui/menu/elements/PanelColour.lua",
	"rageui/menu/items/UIButton.lua",
  "rageui/menu/items/UICheckBox.lua",
  "rageui/menu/items/UIList.lua",
  "rageui/menu/items/UIProgress.lua",
  "rageui/menu/items/UISeparator.lua",
  "rageui/menu/items/UISlider.lua",
  "rageui/menu/items/UISliderHeritage.lua",
  "rageui/menu/items/UISliderProgress.lua",
  "rageui/menu/panels/UIColourPanel.lua",
  "rageui/menu/panels/UIGridPanel.lua",
  "rageui/menu/panels/UIGridPanelHorizontal.lua",
  "rageui/menu/panels/UIGridPanelVertical.lua",
  "rageui/menu/panels/UIPercentagePanel.lua",
  "rageui/menu/panels/UIStatisticsPanel.lua",
	"rageui/menu/windows/UIHeritage.lua",
  "pma/client/utils/Nui.lua",
  '@vice-ac/init.lua',
	"pma/client/init/proximity.lua",
	"pma/client/init/init.lua",
	"pma/client/init/main.lua",
	"pma/client/init/submix.lua",
	"pma/client/module/phone.lua",
  "pma/client/module/radio.lua",
  "pma/client/commands.lua",
  "pma/client/events.lua",
  "util/client/cl_mouse.lua",
  "util/client/cl_thread.lua",
  "util/client/cl_cache.lua",
  "util/client/functions.lua",
  "util/server/utils.lua",
  "dpclothing/Functions.lua", 		-- Global Functions / Events / Debug and Locale start.
  "dpclothing/en.lua", 	
	"dpclothing/Config.lua",			-- Configuration.
	"dpclothing/Variations.lua",		-- Variants, this is where you wanan change stuff around most likely.
	"dpclothing/Clothing.lua",
	"dpclothing/GUI.lua",				-- The GUI.
  "client/core/extra/Tunnel.lua",
  "client/core/extra/Proxy.lua",
  "client/core/cl_callbacks.lua",
  "client/core/extra/base.lua",
  "client/core/extra/player_state.lua",
  "client/core/extra/survival.lua",
  "client/core/extra/validSounds.lua",
  "client/core/cl_adminfunctions.lua",
  "util/client/cl_text.lua",
  "util/client/cl_util.lua",
  "util/client/cl_map.lua",
  "util/client/cl_fonts.lua",
  "util/client/cl_dynamicped.lua",
  "util/client/cl_checkpoints.lua",
  "client/core/extra/iplloader.lua",
  "client/core/extra/gui.lua",
  "client/core/extra/identity.lua",
  "client/core/cl_adminfunctions.lua",
  "client/core/extra/enumerators.lua",
  "client/core/extra/deathevents.lua",
  -- Start of all client scripts
  "client/menus/cl_adminmenu.lua",
  "client/menus/cl_wagers.lua",
  "client/core/cl_2step.lua",
  "client/menus/cl_aa.lua",
  "client/menus/cl_aastore.lua",

  "client/core/cl_adminfunctions.lua",

  "client/menus/cl_announcemenu.lua",

  "client/core/cl_anticheat.lua",

  "client/menus/cl_atm.lua",
  "client/menus/cl_backpacks.lua",

  "client/menus/cl_barbershops.lua",
  "client/events/cl_battlegrounds.lua",
  
  "client/jobs/cl_borderforce.lua",
  "client/jobs/cl_buytrucks.lua",
  "client/jobs/cl_vangelico.lua",
  "client/jobs/cl_datacrack.lua",
  "client/core/cl_callbacks.lua",


  "client/menus/cl_cardev.lua",
  "client/events/cl_golf.lua",

  "client/misc/cl_*",


  "client/menus/cl_clothingmenu.lua",
  
  "client/core/cl_currentplayerinformation.lua",
 
  "client/menus/cl_devmenu.lua",
  
  "client/menus/cl_dropmenu.lua",

 
  "client/discord/cl_discord.lua",
  "client/discord/cl_discordnitro.lua",
  "client/menus/cl_djmenu.lua",
  
  "client/menus/cl_emotes.lua",
  "client/core/cl_eulen.lua",
  "client/events/cl_eventmenu.lua",
  "client/events/cl_eventpvp.lua",
  "client/events/cl_events.lua",
 
  "client/jobs/cl_fishingjob.lua",
 
  "client/core/cl_fps.lua",
 
  "client/jobs/cl_g4s.lua",
  "client/ui/cl_gameui.lua",
  "client/menus/cl_gangmenu.lua",
  "client/menus/cl_garages.lua",
  "client/menus/cl_graphicpacks.lua",
  
  "client/menus/cl_grinding.lua",
  "client/menus/cl_groupselector.lua",
  "client/menus/cl_gunstores.lua",

  "client/menus/cl_homewardrobe.lua",
 
  "client/menus/cl_housing.lua",
  "client/menus/cl_identity.lua",
 
  "client/jobs/cl_jobinstructions.lua",
  "client/jobs/cl_jobtypes.lua",
 

 
  "client/menus/cl_licensecentre.lua",
  "client/menus/cl_liverymenu.lua",
 
  "client/menus/cl_loginrewards.lua",
  "client/menus/cl_lottery.lua",
  "client/menus/cl_lscustoms.lua",
 
  "client/ui/cl_minimap.lua",
  "client/ui/cl_moneyui.lua",
 
  "client/discord/cl_nitro.lua",
  "client/ui/cl_notificationui.lua",
  "client/menus/cl_numberplatechanger.lua",
  "client/events/cl_organheist.lua",
 
  "client/menus/cl_pausemenu.lua",
  
  "client/jobs/cl_pilotJobMenu.lua",
  "client/jobs/cl_pilotjob.lua",
  
  "client/core/cl_playercustomisation.lua",
  "client/ui/cl_playerlist.lua",
 
  "client/menus/cl_purgemenu.lua",
 
  "client/menus/cl_radialmenu.lua",
  "client/ui/cl_radios.lua",
  "client/ui/cl_rankbar.lua",
 
  "client/jobs/cl_royalmail.lua",
 
  "client/ui/cl_scaleforms.lua",
  "client/menus/cl_scenemenu.lua",
  "client/menus/cl_scope.lua",
 
  "client/menus/cl_settings.lua",
  "client/menus/cl_simeons.lua",
 
  "client/ui/cl_skin.lua",
 
  "client/menus/cl_store.lua",

  "client/menus/cl_stores.lua",
  
  "client/jobs/cl_taco.lua",
 
  "client/menus/cl_tos.lua",
  "client/menus/cl_trader.lua",
  "client/jobs/cl_trucking.lua",

  "client/ui/cl_tutorial.lua",
  "client/ui/cl_tutorialcharacter.lua",
  "client/ui/cl_ui.lua",
  "client/menus/cl_uivisibility.lua",
 
  "client/menus/cl_vehiclemenu.lua",
  "client/menus/cl_vipclub.lua",
  "client/menus/cl_vkint.lua",
 
  "client/menus/cl_wagers.lua",
  
  "client/ui/cl_warningsystem.lua",
 
  -- End of all client scripts.
  "cfg/client.lua",
  'client/menus/cl_kitmenu.lua',
}

server_exports { 
	"GetDiscordRoles",
	"GetRoleIdFromRoleName",
	"GetDiscordAvatar",
	"GetDiscordName",
	"IsDiscordEmailVerified",
  "getOwnedHouses",
	"GetDiscordNickname",
	"GetGuildIcon",
	"GetGuildSplash",
	"GetGuildName",
	"GetGuildDescription",
	"GetGuildMemberCount",
	"GetGuildOnlineMemberCount",
	"GetGuildRoleList",
  "getPlayerName",
	"ResetCaches",
	"CheckEqual",
	"SetNickname",
  "setPlayerCall",
}

data_file "PED_METADATA_FILE" "cfg/peds.meta"
data_file "AUDIO_GAMEDATA" "audio/dlcvinewood_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/dlcvinewood_sounds.dat"
data_file "AUDIO_DYNAMIXDATA" "audio/dlcvinewood_mix.dat"
data_file "AUDIO_SYNTHDATA" "audio/dlcVinewood_amp.dat"
data_file "AUDIO_SPEECHDATA" "audio/dlcvinewood_speech.dat"
data_file "AUDIO_WAVEPACK" "audio/sfx/dlc_vinewood"
server_export "getCurrentGameType"
server_export "getCurrentMap"
server_export "changeGameType"
server_export "changeMap"
server_export "doesMapSupportGameType"
server_export "getMaps"
server_export "roundEnded"
export "getRandomSpawnPoint"
export "spawnPlayer"
export "addSpawnPoint"
export "removeSpawnPoint"
export "loadSpawns"
export "setAutoSpawn"
export "setAutoSpawnCallback"
export "forceRespawn"
experimental_features_enabled "0"
