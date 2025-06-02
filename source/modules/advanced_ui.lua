local advanced_ui = {}
advanced_ui.version = "0.1"

advanced_ui.init = function(self)
    -- logs to check if everything is ok
    debug.log("-- ADVANCED UI --")
    debug.log("Version: " .. self.version)
    debug.log("Made for NaN-GDK.")
    debug.log("Advanced UI Module initialized.")
end

advanced_ui.createWindow = function(config)
    -- default config
    local defaultConfig = {
        title = "Window",
        title_size = 14,
        width = 300,
        height = 200,
        topbar_height = 20,
        topbar_color = Color(92, 101, 105),
        topbar_text_color = Color(218, 224, 227),
        background_color = Color(200, 216, 224),
        border_color = Color(31, 34, 36),
        border_width = 1,
        pos = {0, 0},
    }

    -- config merging
    local cfg = {}
    for k, v in pairs(defaultConfig) do
        if config[k] ~= nil then
            cfg[k] = config[k]
        else
            cfg[k] = v
        end
    end

    -- creating window
    local window = _UIKIT:createFrame()
    window.left_border = _UIKIT:createFrame()
    window.right_border = _UIKIT:createFrame()
    window.bottom_border = _UIKIT:createFrame()
    window.top_border = _UIKIT:createFrame()

    -- topbar + events
    window.topbar = _UIKIT:createFrame()
    window.title = _UIKIT:createText(cfg.title)
    window.topbar.onPress = function(self, pointerEvent)
        debug.log("Pressed top border of window " .. window.config.title)
        self.latest_pointer_position = {X = pointerEvent.X, Y = pointerEvent.Y}
    end
    window.topbar.onRelease = function(self)
        debug.log("Released top border of window " .. window.config.title)
    end
    window.topbar.onDrag = function(self, pointerEvent)
        if self.latest_pointer_position.X ~= nil and self.latest_pointer_position.Y ~= nil then
            local pos_diff = {
                X = pointerEvent.X - self.latest_pointer_position.X,
                Y = pointerEvent.Y - self.latest_pointer_position.Y
            }
            local final_pos = {
                self.pos.X + pos_diff.X,
                self.pos.Y + pos_diff.Y
            }
            self:setPos(final_pos)
        end
    end

    -- SAVE CONFIG
    window.config = cfg

    -- -- -- FUNCTIONS -- -- --

    window.updateConfig = function(self, config)
        -- merging old config with new one
        local mergedConfig = {}
        for k, v in pairs(self.config) do
            mergedConfig[k] = v
        end

        -- merging new config with old one
        for k, v in pairs(config) do
            mergedConfig[k] = v
        end

        -- updating config
        self.config = mergedConfig

        -- updating window
        self:update()
    end

    window.setPos = function(self, pos)
        self.config.pos = pos
        self:update()
    end

    window.setSize = function(self, size)
        self.config.width = size[1]
        self.config.height = size[2]
        self:update()
    end

    window.update = function(self)
        -- updating window
        self.Color = self.config.background_color
        self.Size = {self.config.width, self.config.height}
        self.pos = self.config.pos

        -- updating topbar
        self.topbar.Color = self.config.topbar_color
        self.topbar.Size = {self.config.width, self.config.topbar_height}
        self.topbar.pos = {self.pos.X, self.pos.Y + self.config.height - self.topbar.Height}

        -- updating title
        self.title.Color = self.config.topbar_text_color
        self.title.object.FontSize = self.config.title_size
        self.title.pos = {
            self.topbar.pos.X + (self.config.topbar_height-self.config.title_size)/2,
            self.topbar.pos.Y + (self.config.topbar_height-self.config.title_size)/2
        }

        -- updating left border
        self.left_border.Color = self.config.border_color
        self.left_border.Size = {self.config.border_width, self.config.height}
        self.left_border.pos = {self.pos.X-self.config.border_width, self.pos.Y}

        -- updating right border
        self.right_border.Color = self.config.border_color
        self.right_border.Size = {self.config.border_width, self.config.height}
        self.right_border.pos = {self.pos.X+self.config.width, self.pos.Y}

        -- updating bottom border
        self.bottom_border.Color = self.config.border_color
        self.bottom_border.Size = {self.config.width + (self.config.border_width * 2), self.config.border_width}
        self.bottom_border.pos = {self.pos.X- self.config.border_width, self.pos.Y-self.config.border_width}

        -- updating top border
        self.top_border.Color = self.config.border_color
        self.top_border.Size = {self.config.width + (self.config.border_width * 2), self.config.border_width}
        self.top_border.pos = {self.pos.X - self.config.border_width, self.pos.Y + self.config.height}
    end

    window:update()

    return window
end

return advanced_ui