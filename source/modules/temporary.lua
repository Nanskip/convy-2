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

    -- frametime graph to display some info
    debugwindow.frametime_graph = {}
    debugwindow.frametime_graph.tick = Object()
    debugwindow.frametime_graph.tick.Tick = function(self)
        debugwindow.frametime_graph:update()
    end
    debugwindow.frametime_graph.update = function(self)
        local graph = debugwindow.frametime_graph.graph

        for i = 1, 99 do
            graph[i].pos.Y = graph[i + 1].pos.Y
        end

        graph[100].pos.Y = _DT * (63/2)
    end


    debugwindow.frametime_graph.graph = {}
    for i = 1, 100 do
        local part = _UIKIT:createFrame()

        part.Size = {3, 3}
        part.Color = Color(255, 0, 0)
        part:setParent(debugwindow.mask)
        part.pos = {(i-1)*3, 0}

        debugwindow.frametime_graph.graph[i] = part
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