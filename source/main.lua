Modules = {
    worldgen = "modules/worldgen.lua",
    loading_screen = "modules/loading_screen.lua",
    debug = "modules/debug.lua",
    mathlib = "modules/mathlib.lua",
    advanced_ui = "modules/advanced_ui.lua",
    perlin = "modules/perlin.lua",
    temporary = "modules/temporary.lua",
}

Models = {

}

Textures = {
    intro_logo = "textures/intro_logo.png",
}

Sounds = {
    loading_completed = "sounds/loading_completed.mp3",
    intro = "sounds/intro.mp3",
    music_day1 = "sounds/convy2-day1.mp3",
}

Data = {

}

Other = {
    vcr_font = "other/vcr_font.ttf",
}

_ON_START = function()
    loading_screen:intro()
    _UI:init()

    temporary:init()
end

_ON_START_CLIENT = function()
    _UIKIT = require("uikit")
    _UI = advanced_ui

    loading_screen:start()
end
