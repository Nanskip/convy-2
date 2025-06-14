local scenes = {}

-- main game scene
scenes.game = function(self)
    -- CAMERA --
    Camera:SetModeFree()
    Camera.Position = Number3(0, 0, 0)
    Camera.Rotation = Rotation(1.2, 0, 0)
    Camera.FOV = 30

    Camera.Position = -Camera.Forward * 35
    _CAMERA_POS = Number3(0, 0, 0)
    _CAMERA_VEL = Number3(0, 0, 0)

    game_manager:setControls("keyboard")

    -- TICK OBJECT --
    -- Don't forget to remove it when switching to another scene!
    self.tick_object = Object()
    self.tick_object.Tick = function(self)
        Camera.Position = -Camera.Forward * 35
        _CAMERA_POS = _CAMERA_POS + _CAMERA_VEL
        if _CAMERA_POS ~= nil then
            Camera.Position = mathlib.lerp(
                Camera.Position,
                Camera.Position + _CAMERA_POS,
                0.5
            )
        end
    end

    -- MAP --
    local cfg = {
        size = 65,
        seed = os.time(),
        randomMin = -0.3,
        randomMax = 0.3,
        roughness = 0.5,
        baseData = nil,
    }
    _MAP = worldgen.diamondSquare(cfg)
    _MAP:SetParent(World)
end

return scenes