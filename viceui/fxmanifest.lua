fx_version "bodacious"
game "gta5"


ui_page "ui/index.html"

loadscreen_manual_shutdown "yes"

client_scripts{
    "client/*.lua",
    "loading/*.lua",
}

files{
    "ui/*.ttf",
    "ui/*.otf",
    "ui/*.woff",
    "ui/*.woff2",
    "ui/*.css",
    "ui/*.png",
    "ui/main.js",
    "ui/index.html",
    "loading/loadscreen.html",
    -- Loading Screen
    "loading/terminal/*",
    "loading/*",
    -- "loading/images/main_background.png",
    -- "loading/images/background_1.png",
    -- "loading/images/background_2.png",
    -- "loading/images/background_3.png",
    -- "loading/images/background_4.png",
    -- "loading/images/image_1.png",
    -- "loading/images/image_2.png",
    -- "loading/images/image_3.png",
    -- "loading/images/image_4.png",
    -- "loading/images/image_5.png",
    -- "loading/images/image_6.png",
    -- "loading/images/loading.gif",
    -- "loading/music/tune.webm"
}

loadscreen 'loading/loadscreen.html'