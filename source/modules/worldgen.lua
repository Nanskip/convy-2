local worldgen = {}

worldgen.generateCube = function(config)
    local defaultConfig = {
        size = {10, 10, 10},
        chunkSize = 10,
        zoom = 20,
        octaves = 4
    }

    local cfg = {}
    for k, v in pairs(defaultConfig) do
        if config[k] ~= nil then
            cfg[k] = config[k]
        else
            cfg[k] = v
        end
    end

    -- creating cube
    local cube = MutableShape()
    
    -- generate cube without filling insides
    -- generate cube without filling insides

    local width = cfg.size[1] * cfg.chunkSize
    local height = cfg.size[2] * cfg.chunkSize
    local depth = cfg.size[3] * cfg.chunkSize

    local function setBlock(x, y, z)
        local total = 0
        local amplitude = 1
        local frequency = 1
        local maxAmplitude = 0
        local persistence = 0.5
        local lacunarity = 2.0

        for i = 1, cfg.octaves do
            local nx = x * frequency / cfg.zoom
            local ny = y * frequency / cfg.zoom
            local nz = z * frequency / cfg.zoom
            total = total + perlin.get(nx + 250, ny + 250, nz + 250) * amplitude
            maxAmplitude = maxAmplitude + amplitude
            amplitude = amplitude * persistence
            frequency = frequency * lacunarity
        end

        local perlinValue = total / (maxAmplitude/cfg.octaves)

        local color = Color(255, 255, 255)
        if perlinValue > 0.9 then
            color = Color(213, 219, 227)
        elseif perlinValue > 0.7 then
            color = Color(176, 191, 184)
        elseif perlinValue > 0.2 then
            color = Color(43, 120, 64)
        elseif perlinValue > -0.1 then
            color = Color(56, 150, 82)
        elseif perlinValue > -0.4 then
            color = Color(192, 196, 102)
        elseif perlinValue > -0.7 then
            color = Color(45, 59, 145)
        elseif perlinValue > -0.9 then
            color = Color(32, 44, 115)
        else
            color = Color(23, 33, 89)
        end

        cube:AddBlock(color, x, y, z)
    end

    debug.log("Filling front...")
    -- front
    for x = 0, width do
        for y = 0, height do
            setBlock(x, y, depth)
        end
    end

    debug.log("Filling back...")
    -- back
    for x = 0, width do
        for y = 0, height do
            setBlock(x, y, 0)
        end
    end

    debug.log("Filling left...")
    -- left
    for z = 0, depth do
        for y = 0, height do
            setBlock(0, y, z)
        end
    end

    debug.log("Filling right...")
    -- right
    for z = 0, depth do
        for y = 0, height do
            setBlock(width, y, z)
        end
    end

    debug.log("Filling top...")
    -- top
    for x = 0, width do
        for z = 0, depth do
            setBlock(x, 0, z)
        end
    end

    debug.log("Filling bottom...")
    -- bottom
    for x = 0, width do
        for z = 0, depth do
            setBlock(x, height, z)
        end
    end

    return cube
end