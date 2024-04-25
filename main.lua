Config = {
    Items = {
        "nanskip.v"
    }
}

start = function()
    Camera:SetParent(World)
    worldgen.generatePlanet()
end

tick = function()
    
end

Client.OnStart = function()
    ui = require("uikit")
    loadingScreen.show()
    Camera:SetParent(nil)
    githubScriptsCount = 0
    loadGitHub()
end

Client.Tick = function(dt)
    deltaTime = 62/(1/dt)
    if githubScriptsCount == loadCount then
        loadingScreen:hide()
        start()
        githubScriptsCount = nil
    elseif githubScriptsCount == nil then
        tick()
    end
end

-- load everything
loadGitHub = function()
    loadCount = 2
    
    worldgen = loadFromGitHub("data/modules/worldgen.lua", true)
    perlin = loadFromGitHub("data/modules/perlin.lua", true)
end

-- loading function
loadFromGitHub = function(url, isCode)
    url = "https://raw.githubusercontent.com/Nanskipp/convy-2/main/" .. url
    local fileName = url:match("[^/]-$")
    loadingText.Text = "Loading: " .. fileName
    local ret = HTTP:Get(url, function(res)
        if res.StatusCode ~= 200 then
            print("Error on " .. fileName .." loading. Code: " .. res.StatusCode)
            return
        end
        local obj = load(res.Body:ToString(), nil, "bt", _ENV)

        githubScriptsCount = githubScriptsCount + 1
        if isCode then return obj() else return obj end
        end)
    return ret
end

loadingScreen = {}

loadingScreen.show = function()
    blackScreen = ui:createFrame(Color(0, 0, 0))

    blackScreen.Width = Screen.Width
    blackScreen.Height = Screen.Height

    loadingText = ui:createText("Loading: {placeholder}", Color(255, 255, 255))
    loadingText.pos.X = Screen.Width/2 - loadingText.Width/2
    loadingText.pos.Y = Screen.Height/2 - loadingText.Height/2
    loadingText.Tick = function(self)
        self.pos.X = Screen.Width/2 - self.Width/2
        self.pos.Y = Screen.Height/2 - self.Height/2
    end
end

loadingScreen.hide = function(self)
    blackScreen:setParent(nil) blackScreen = nil
    loadingText:setParent(nil) loadingText.Tick = nil loadingText = nil
    self = nil
end