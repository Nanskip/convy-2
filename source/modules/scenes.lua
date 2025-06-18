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
            _POINT_POS = Camera.Position + (Camera.Forward * 35)

            if _MAP_DONE then
                -- rendering nearby chunks
                -- center one
                local chunkX = math.floor(_POINT_POS.X / 8)
                local chunkY = math.floor(_POINT_POS.Z / 8)
                chunk_manager:renderNearbyChunks(chunkX, chunkY)
            end
        end
    end

    -- MAP --
    local cfg = {
        size = 129,
        seed = os.time(),
        randomMin = -0.3,
        randomMax = 0.3,
        roughness = 0.5,
        baseData = nil,
    }
    _MAP = worldgen.diamondSquare(cfg, true)
    chunk_manager:init(_MAP)
    _MAP_DONE = true
    -- don't use it please
    --chunk_manager:renderFullMap()
end

return scenes