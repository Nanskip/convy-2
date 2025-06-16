Modules = {
    worldgen = "modules/worldgen.lua",
    loading_screen = "modules/loading_screen.lua",
    debug = "modules/debug.lua",
    mathlib = "modules/mathlib.lua",
    advanced_ui = "modules/advanced_ui.lua",
    perlin = "modules/perlin.lua",
    temporary = "modules/temporary.lua",
    scenes = "modules/scenes.lua",
    game_manager = "modules/game_manager.lua",
}

Models = {

}

Textures = {
    intro_logo = "textures/intro_logo.png",
    tile_atlas = "textures/tile_atlas.png",
}

Sounds = {
    loading_completed = "sounds/loading_completed.mp3",
    intro = "sounds/intro.mp3",
    music_day1 = "sounds/convy2_day1.mp3",
}

Data = {
    tiles = "data/world_tiles.json",
}

Other = {
    vcr_font = "other/vcr_font.ttf",
}

_ON_START = function()
    loading_screen:intro()
    _UI:init()

    temporary:init()
    game_manager:init()
    game_manager:switch("game")
    game_manager:init_scene()
end

_ON_START_CLIENT = function()
    _UIKIT = require("uikit")
    _UI = advanced_ui

    loading_screen:start()
end
