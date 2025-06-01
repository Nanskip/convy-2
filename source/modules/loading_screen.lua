local loading_screen = {}

loading_screen.start = function(self)
    debug.log("Loading screen initialized.")

    self.background = _UIKIT:frame()
    self.background.Color = Color(0, 0, 0)
    self.background.Width = Screen.Width
    self.background.Height = Screen.Height

    -- creating game title
    self.game_title = _UIKIT:createText("Convy 2")
    self.title = _UIKIT:createText("Powered by NaN-GDK")
    self.loading_text = _UIKIT:createText("Downloading assets...")

    self.game_title.Color = Color(255, 255, 255)
    self.game_title.object.FontSize = 40
    self.title.Color = Color(255, 255, 255)
    self.title.object.FontSize = 30
    self.loading_text.Color = Color(255, 255, 255)
    self.loading_text.object.FontSize = 20

    self:update()
end

loading_screen.update = function(self)
    local basePos = {Screen.Width/2, Screen.Height/2}
    self.game_title.pos = {
        basePos[1] - self.game_title.Width/2,
        basePos[2] - self.game_title.Height/2 + self.game_title.Height + 5
    }
    self.title.pos = {
        basePos[1] - self.title.Width/2,
        basePos[2] - self.title.Height/2
    }
    self.loading_text.pos = {
        basePos[1] - self.loading_text.Width/2,
        basePos[2] - self.loading_text.Height/2 - self.loading_text.Height - 5
    }
end

loading_screen.loading_text_update = function(self, text)
    if self.loading_text ~= nil then
        self.loading_text.Text = text
    end
end

loading_screen.intro = function(self)
    debug.log("Intro initialized.")

    -- removing game title
    self.game_title:remove()
    self.game_title = nil

    self.title:remove()
    self.title = nil

    self.loading_text:remove()
    self.loading_text = nil

    -- showing intro logo
    self.intro_logo = _UIKIT:createFrame()
    self.intro_logo.Color = Color(255, 255, 255)
    self.intro_logo:setImage(textures.intro_logo)
    self.intro_logo.Size = {256, 256}
    self.intro_logo.pos = {
        Screen.Width/2 - self.intro_logo.Width/2,
        Screen.Height/2 - self.intro_logo.Height/2
    }

    for i=1, 60*5 do
        Timer(i/60, false,
            function()
                self.intro_logo.Color.A = mathlib.lerp(0, 255, i/60)
            end)
    end

    -- play intro sound
    local sound = AudioSource()
    sound:SetParent(Camera)
    sound.Sound = sounds.intro
    sound:Play()

    Timer(5, false, 
        function()
            sound:Destroy()
        end)
end

loading_screen.finish = function(self)
    debug.log("Loading screen removed.")
    self.background:remove()
    self.background = nil

    -- play loading completed sound
    local sound = AudioSource()
    sound:SetParent(Camera)
    sound.Sound = sounds.loading_completed
    sound:Play()

    Timer(3, false, 
        function()
            sound:Destroy()
        end)
end

return loading_screen