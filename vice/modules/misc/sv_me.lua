local emojis = {
    [":sob:"] = "😭",
    [":smile:"] = "😄",
    [":laugh:"] = "😂",
    [":thumbs_up:"] = "👍",
    [":thumbs_down:"] = "👎",
    [":heart:"] = "❤️",
    [":broken_heart:"] = "💔",
    [":sunglasses:"] = "😎",
    [":angry:"] = "😠",
    [":astonished:"] = "😲",
    [":blush:"] = "😊",
    [":confused:"] = "😕",
    [":cry:"] = "😢",
    [":lemon:"] = "🍋",
    [":fearful:"] = "😨",
    [":fire:"] = "🔥",
    [":grin:"] = "😁",
    [":joy:"] = "😂",
    [":kiss:"] = "😘",
    [":like:"] = "👍",
    [":dislike:"] = "👎",
    [":love:"] = "❤️",
    [":sad:"] = "😔",
    [":surprise:"] = "😮",
    [":tongue:"] = "😛",
    [":wink:"] = "😉",
    [":100:"] = "💯",
    [":clap:"] = "👏",
    [":muscle:"] = "💪",
    [":peace:"] = "✌️",
    [":punch:"] = "👊",
    [":ok_hand:"] = "👌",
    [":wave:"] = "👋",
    [":victory:"] = "✌️",
    [":point_up:"] = "☝️",
    [":raised_hand:"] = "✋",
    [":fist:"] = "✊",
    [":facepalm:"] = "🤦",
    [":shrug:"] = "🤷",
    [":star:"] = "⭐",
    [":zap:"] = "⚡",
    [":boom:"] = "💥",
    [":ghost:"] = "👻",
    [":alien:"] = "👽",
    [":robot:"] = "🤖",
    [":poop:"] = "💩",
    [":eyes:"] = "👀",
    [":tada:"] = "🎉",
    [":gift:"] = "🎁",
    [":birthday:"] = "🎂",
    [":christmas_tree:"] = "🎄",
    [":santa:"] = "🎅",
    [":balloon:"] = "🎈",
    [":camera:"] = "📷",
    [":phone:"] = "📱",
    [":computer:"] = "💻",
    [":video_game:"] = "🎮",
    [":rocket:"] = "🚀",
    [":airplane:"] = "✈️",
    [":car:"] = "🚗",
    [":train:"] = "🚂",
    [":bus:"] = "🚌",
    [":bike:"] = "🚲",
    [":ambulance:"] = "🚑",
    [":police_car:"] = "🚓",
    [":taxi:"] = "🚕",
    [":stop_sign:"] = "🛑",
    [":construction:"] = "🚧",
    [":fuelpump:"] = "⛽",
    [":hospital:"] = "🏥",
    [":bank:"] = "🏦",
    [":hotel:"] = "🏨",
    [":school:"] = "🏫",
    [":church:"] = "⛪",
    [":mosque:"] = "🕌",
    [":synagogue:"] = "🕍",
    [":kaaba:"] = "🕋",
    [":fountain:"] = "⛲",
    [":tent:"] = "⛺",
    [":bridge_at_night:"] = "🌉",
    [":carousel_horse:"] = "🎠",
    [":ferris_wheel:"] = "🎡",
    [":roller_coaster:"] = "🎢",
    [":ship:"] = "🚢",
}

local blockedWords = {
    "nigger",
    "nigga",
    "wog",
    "coon",
    "paki",
    "faggot",
    "anal",
    "kys",
    "homosexual",
    "lesbian",
    "suicide",
    "negro",
    "queef",
    "queer",
    "allahu akbar",
    "terrorist",
    "wanker",
    "n1gger",
    "f4ggot",
    "n0nce",
    "d1ck",
    "h0m0",
    "n1gg3r",
    "h0m0s3xual",
    "nazi",
    "hitler",
	"fag",
	"fa5",
    "hdn",
    "cmg",
}

RegisterCommand("me", function(source, args)
    local source = source
     user_id = VICE.getUserId(source)
    local name = VICE.getPlayerName(user_id)
    local text = table.concat(args, " ")

    for code, emoji in pairs(emojis) do
        text = text:gsub(code, emoji)
    end

    for _, word in ipairs(blockedWords) do
        if(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(text:lower(), "-", ""), ",", ""), "%.", ""), " ", ""), "*", ""), "+", ""):find(word)) then
            TriggerClientEvent('VICE:chatFilterScaleform', source, 10, 'That word is not allowed.', name, user_id)
            VICE.sendDCLog('filtered-message', 'VICE Banned Words Logs', "Filtered Message!\n```" .. text.. "```\n> Player Name: **".. name .."**\n> Player PermID: **".. user_id .. "**")   
            CancelEvent()
            return
        end
    end

    TriggerClientEvent('VICE:sendLocalChat', -1, source, VICE.getPlayerName(user_id), text)
    VICE.sendDCLog('slash-me', 'VICE /me Logs', "> Player Name: **" .. VICE.getPlayerName(user_id) .. "**\n > Player PermID: **" .. user_id .. "**\n > Player TempID: **" .. source .. "**\n > Text: **" .. text .. "**")
end)