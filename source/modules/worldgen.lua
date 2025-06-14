local worldgen = {}

worldgen.perlinCube = function(config)
    local defaultConfig = {
        size = {10, 10, 10},
        chunkSize = 4,
        zoom = 20,
        octaves = 4,
        seed = 1
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

    local width = cfg.size[1] * cfg.chunkSize
    local height = cfg.size[2] * cfg.chunkSize
    local depth = cfg.size[3] * cfg.chunkSize

    local terrainPerlin = perlin.new(cfg.seed)
    local riverPerlin = perlin.new(cfg.seed + 1000)

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
            total = total + terrainPerlin.get(nx + 250, ny + 250, nz + 250) * amplitude
            maxAmplitude = maxAmplitude + amplitude
            amplitude = amplitude * persistence
            frequency = frequency * lacunarity
        end

        local perlinValue = total / (maxAmplitude/cfg.octaves)

        -- adding rivers
        local riverValue = riverPerlin.get(x / cfg.zoom * 1.5, y / cfg.zoom * 1.5, z / cfg.zoom * 1.5)

        -- normalized value: from [-1, 1] to [0, 1]
        local riverNorm = (riverValue + 1) / 2

        local riverRadius = 0.15

        if math.abs(riverNorm - 0.5) < riverRadius then
            local distanceFromCenter = math.abs(riverNorm - 0.5) / riverRadius
            local riverDepth = math.sin((1 - distanceFromCenter) * math.pi * 0.5)

            -- assigning river depth to perlin value
            perlinValue = perlinValue - riverDepth
        end

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
        elseif perlinValue > -0.99 then
            color = Color(23, 33, 89)
        else
            color = Color(19, 28, 77)
        end

        cube:AddBlock(color, x, y, z)
    end

    -- front
    for x = 0, width do
        for y = 0, height do
            setBlock(x, y, depth)
        end
    end

    -- back
    for x = 0, width do
        for y = 0, height do
            setBlock(x, y, 0)
        end
    end

    -- left
    for z = 0, depth do
        for y = 0, height do
            setBlock(0, y, z)
        end
    end

    -- right
    for z = 0, depth do
        for y = 0, height do
            setBlock(width, y, z)
        end
    end

    -- top
    for x = 0, width do
        for z = 0, depth do
            setBlock(x, 0, z)
        end
    end

    -- bottom
    for x = 0, width do
        for z = 0, depth do
            setBlock(x, height, z)
        end
    end

    return cube
end

-- diamond square algorithm to generate a plane
worldgen.diamondSquare = function(config)
    local defaultConfig = {
        size = 257, -- should be 2^n + 1
        seed = os.time(), -- Use os.time() for varied maps, or a fixed number for reproducible ones
        randomMin = -0.8,
        randomMax = 0.8,
        roughness = 0.5,
        baseData = nil, -- replaced with 2x2 map that actually scales up to corners
    }

    local cfg = {}
    for k, v in pairs(defaultConfig) do
        cfg[k] = config[k] or v
    end

    math.randomseed(cfg.seed)
    math.random(); math.random(); math.random()

    local function isPowerOfTwoPlusOne(n)
        local x = n - 1
        if x <= 0 then return false end -- Powers of 2 are positive
        return (x ~= 0) and (math.floor(math.log(x, 2)) == math.log(x, 2))
    end

    if not isPowerOfTwoPlusOne(cfg.size) then
        error("Size must be 2^n + 1")
    end

    local function getScaledRandomOffset(minVal, maxVal)
        return math.random() * (maxVal - minVal) + minVal
    end

    local size = cfg.size
    local map = {}
    for y = 1, size do
        map[y] = {}
        for x = 1, size do
            map[y][x] = 0
        end
    end

    local function seedCorners()
        map[1][1] = math.random()
        map[1][size] = math.random()
        map[size][1] = math.random()
        map[size][size] = math.random()
    end

    if cfg.baseData == nil then
        seedCorners()
    else
        for y = 1, size do
            for x = 1, size do
                map[y][x] = cfg.baseData[y][x]
            end
        end
    end

    local function get(x, y)
        if x < 1 or x > size or y < 1 or y > size then
            return nil
        end
        return map[y][x]
    end

    local function set(x, y, value)
        if x >= 1 and x <= size and y >= 1 and y <= size then
            map[y][x] = value
        end
    end

    local stepSize = size - 1

    while stepSize > 1 do
        local halfStep = stepSize // 2

        local currentRandomAmplitude = (cfg.randomMax - cfg.randomMin) * cfg.roughness * (stepSize / (size - 1))
        local currentOffsetMin = -currentRandomAmplitude / 2
        local currentOffsetMax = currentRandomAmplitude / 2

        -- Diamond Step
        for y = 1, size - 1, stepSize do
            for x = 1, size - 1, stepSize do
                local c1 = get(x, y)
                local c2 = get(x + stepSize, y)
                local c3 = get(x, y + stepSize)
                local c4 = get(x + stepSize, y + stepSize)

                local avg = (c1 + c2 + c3 + c4) / 4
                local offset = getScaledRandomOffset(currentOffsetMin, currentOffsetMax)
                set(x + halfStep, y + halfStep, avg + offset)
            end
        end

        for y = halfStep + 1, size - 1, stepSize do
            for x = 1, size, halfStep do
                if get(x, y) == 0 then -- Only fill if not already set
                    local values = {}
                    table.insert(values, get(x, y - halfStep))
                    table.insert(values, get(x + halfStep, y))
                    table.insert(values, get(x, y + halfStep))
                    table.insert(values, get(x - halfStep, y))

                    local count, sum = 0, 0
                    for _, v in ipairs(values) do
                        if v then
                            sum = sum + v
                            count = count + 1
                        end
                    end

                    local avg = sum / count
                    local offset = getScaledRandomOffset(currentOffsetMin, currentOffsetMax)
                    set(x, y, avg + offset)
                end
            end
        end

        for y = 1, size, halfStep do
            for x = halfStep + 1, size - 1, stepSize do
                 if get(x, y) == 0 then -- Only fill if not already set
                    local values = {}
                    table.insert(values, get(x, y - halfStep))
                    table.insert(values, get(x + halfStep, y))
                    table.insert(values, get(x, y + halfStep))
                    table.insert(values, get(x - halfStep, y))

                    local count, sum = 0, 0
                    for _, v in ipairs(values) do
                        if v then
                            sum = sum + v
                            count = count + 1
                        end
                    end

                    local avg = sum / count
                    local offset = getScaledRandomOffset(currentOffsetMin, currentOffsetMax)
                    set(x, y, avg + offset)
                end
            end
        end

        cfg.randomMin = cfg.randomMin * (cfg.randomLowering or 1)
        cfg.randomMax = cfg.randomMax * (cfg.randomLowering or 1)
        stepSize = halfStep
    end

    -- normalization
    local minVal, maxVal = math.huge, -math.huge
    for y = 1, size do
        for x = 1, size do
            local v = map[y][x]
            if v < minVal then minVal = v end
            if v > maxVal then maxVal = v end
        end
    end

    if maxVal == minVal then
        for y = 1, size do
            for x = 1, size do
                map[y][x] = 0.5
            end
        end
    else
        for y = 1, size do
            for x = 1, size do
                map[y][x] = (map[y][x] - minVal) / (maxVal - minVal)
            end
        end
    end

    -- creating shape
    local shape = MutableShape()
    for y = 1, size do
        for x = 1, size do
            local h = map[y][x]
            local z = math.floor(h * 20) -- height (20 blocs max)

            local color = Color(255, 255, 255)
            if h > 0.9 then
                color = Color(213, 219, 227)
            elseif h > 0.8 then
                color = Color(176, 191, 184)
            elseif h > 0.6 then
                color = Color(54, 107, 68)
            elseif h > 0.4 then
                color = Color(43, 120, 64)
            elseif h > 0.25 then
                color = Color(56, 150, 82)
            elseif h > 0.2 then
                color = Color(222, 202, 87)
            elseif h > 0.1 then
                color = Color(45, 59, 145)
            else
                color = Color(37, 36, 120)
            end

            shape:AddBlock(color, x - 1, 0, y - 1)
        end
    end

    return shape
end