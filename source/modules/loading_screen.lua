local loading_screen = {}

loading_screen.start = function(self)
    debug.log("Loading screen initialized.")

    self.background = _UIKIT:frame()
    self.background.Color = Color(0, 0, 0)
    self.background.Width = Screen.Width
    self.background.Height = Screen.Height

    self.game_title = _UIKIT:createText("Convy 2")
    self.title = _UIKIT:createText("Powered by NaN-GDK")
    self.text = _UIKIT:createText("Downloading assets...")

    self.game_title.Color = Color(255, 255, 255)
    self.title.Color = Color(255, 255, 255)
end

loading_screen.updateText = function(text)

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

    Timer(1, false, 
        function()
            sound:Remove()
        end)
end

return loading_screen