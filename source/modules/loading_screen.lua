local loading_screen = {}

loading_screen.start = function(self)
    debug.log("Loading screen initialized.")
    local ui = _UIKIT

    self.background = ui:frame()
    self.background.Color = Color(0, 0, 0)
    self.background.Width = Screen.Width
    self.background.Height = Screen.Height

    self.title = ui:createText("Powered by NaN-GDK")
    self.text = ui:createText("Downloading assets...")
end

loading_screen.updateText = function(text)

end

loading_screen.finish = function(self)
    debug.log("Loading screen removed.")
    self.background:remove()
    self.background = nil

    self.gif = ui:createFrame()
    self.gif.Image = textures.nanskip
end

return loading_screen