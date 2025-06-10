Modules = {
    worldgen = "modules/worldgen.lua",
    loading_screen = "modules/loading_screen.lua",
    debug = "modules/debug.lua",
    mathlib = "modules/mathlib.lua",
    advanced_ui = "modules/advanced_ui.lua",
    perlin = "modules/perlin.lua",
}

Models = {

}

Textures = {
    intro_logo = "textures/intro_logo.png",
}

Sounds = {
    loading_completed = "sounds/loading_completed.mp3",
    intro = "sounds/intro.mp3",
}

Data = {

}

Other = {
    vcr_font = "other/vcr_font.ttf",
}

_ON_START = function()
    loading_screen:intro()
    _UI:init()

    -- temporary test
    debugwindow = advanced_ui.createWindow({
        title = "Debug",
        width = 300,
        height = 200,
        pos = {Screen.Width - 350, Screen.Height - 250},
        topbar_buttons = {
            {
                text = "X",
                func = "close",
                size = 14,
                color = Color(237, 66, 24),
                textcolor = Color(255, 255, 255)
            }
        }
    })
    debugwindow.createCube = debugwindow:createFrame({
            pos = {50, 25},
            size = {200, 50},
            color = Color(255, 255, 255),
        })
    debugwindow.createCubeText = debugwindow:createText({
            pos = {0, 0},
            color = Color(0, 0, 0),
            fontsize = 30,
            text = "Generate Cube",
        })
    debugwindow.createCubeText.config.pos = {
        (debugwindow.createCube.config.pos[1] + debugwindow.createCube.Width/2)
        - (debugwindow.createCubeText.Width/2),

        (debugwindow.createCube.config.pos[2] + debugwindow.createCube.Height/2)
        - (debugwindow.createCubeText.Height/2)
    }
    debugwindow.createCubeText:update()

    debugwindow.createCube.onPress = function(self)
        self.config.color = Color(200, 200, 200)
        self:update()
        if _CUBE == nil then
            seed = os.time()
            _CUBE = worldgen.perlinCube({seed = seed})
            _CUBE:SetParent(World)
            debug.log("Cube generated.")
        else
            _CUBE:Destroy()
            _CUBE = nil

            seed = seed + 1
            _CUBE = worldgen.perlinCube({seed = seed})
            _CUBE:SetParent(World)
            debug.log("Cube regenerated.")
        end
    end
    -- temporary test
end

_ON_START_CLIENT = function()
    _UIKIT = require("uikit")
    _UI = advanced_ui

    loading_screen:start()
end
