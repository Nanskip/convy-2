local game_manager = {}

game_manager.init = function(self)
    debug.log("Initializing Game Manager...")

    self.scenes = {
        game = "game",
    }
    self.scene = "game"

    debug.log("Game Manager initialized.")
end

game_manager.switch = function(self, scene)
    for k, v in pairs(self.scenes) do
        if v == scene then
            -- just remove the tick object if it exists
            if self.tick_object ~= nil then
                self.tick_object:Remove()
            end

            -- apply scene
            self.scene = scene
            debug.log("Game Manager: Switched to scene " .. scene)
            return
        end
    end

    debug.log("Game Manager: Scene " .. scene .. " not found.")
end

game_manager.init_scene = function(self)
    debug.log("Game Manager: Initializing scene " .. self.scene)

    scenes[self.scene](self)
end

game_manager.setControls = function(self, type)
    if type == "none" then
        Client.DirectionalPad = nil
    elseif type == "keyboard" then
        Client.DirectionalPad = function(dx, dy)
            _CAMERA_VEL = Number3(dx*0.5, 0, dy*0.5)
        end
    end
end

return game_manager