local temporary = {}

temporary.init = function()
    debug.log("Temporary module initialized.")
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
    -- create cube button
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

    -- create plane button
    debugwindow.createPlane = debugwindow:createFrame({
            pos = {50, 100},
            size = {200, 50},
            color = Color(255, 255, 255),
        })
    debugwindow.createPlaneText = debugwindow:createText({
            pos = {0, 0},
            color = Color(0, 0, 0),
            fontsize = 30,
            text = "Generate Plane",
        })
    debugwindow.createPlaneText.config.pos = {
        (debugwindow.createPlane.config.pos[1] + debugwindow.createPlane.Width/2)
        - (debugwindow.createPlaneText.Width/2),

        (debugwindow.createPlane.config.pos[2] + debugwindow.createPlane.Height/2)
        - (debugwindow.createPlaneText.Height/2)
    }
    debugwindow.createPlaneText:update()

    debugwindow.createPlane.onPress = function(self)
        self.config.color = Color(200, 200, 200)
        self:update()
        if _PLANE == nil then
            seed = os.time()
            _PLANE = worldgen.diamondSquare({seed = seed})
            _PLANE:SetParent(World)
            _PLANE.Position = Number3(-_PLANE.Width/4, -_PLANE.Height/4, -_PLANE.Depth/4)
            _PLANE.Scale = 0.5
            debug.log("Plane generated.")
        else
            _PLANE:Destroy()
            _PLANE = nil

            seed = seed + 1
            _PLANE = worldgen.diamondSquare({seed = seed})
            _PLANE:SetParent(World)
            _PLANE.Position = Number3(-_PLANE.Width/4, -_PLANE.Height/4, -_PLANE.Depth/4)
            _PLANE.Scale = 0.5
            debug.log("Plane regenerated.")
        end
    end

    local a = AudioSource()
    a.Sound = sounds.convy2_day1
    a.Loop = true
    a:SetParent(Camera)
    a.Volume = 0.15
    --a:Play()
    -- temporary test
end

return temporary