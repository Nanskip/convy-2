Modules = {
    worldgen = "modules/worldgen.lua",
    loading_screen = "modules/loading_screen.lua",
    debug = "modules/debug.lua",
}

Models = {

}

Textures = {

}

Sounds = {
    loading_completed = "sounds/loading_completed.mp3",
}

Data = {

}

Other = {
    vcr_font = "other/vcr_font.ttf",
}

_ON_START = function()
    worldgen.test()

    loading_screen:finish()
end

_ON_START_CLIENT = function()
    _UIKIT = require("uikit")

    loading_screen:start()
end