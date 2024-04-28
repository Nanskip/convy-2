worldgen = {}

worldgen.generatePlanet = function(config)
    defaultConfig = {
        scale = 32,
        colors = {
            deepWater = Color(26, 51, 92),
            water = Color(34, 63, 110),
            beach = Color(140, 123, 65),
            grass = Color(56, 120, 49),
            forest = Color(59, 94, 45),
            hills = Color(71, 74, 73),
            mountains = Color(59, 64, 63)
        },
        zoom = 0.075*2/2
    }

    local scale = config.scale or defaultConfig.scale
    local colors = config.colors or defaultConfig.colors
    local zoom = config.zoom or defaultConfig.zoom

    planet = MutableShape(Items.nanskip.v)
    planet.layer2 = MutableShape(Items.nanskip.v)
    planet.layer2.Scale = planet.Scale + (planet.Scale*0.02*(16/scale))
    planet.layer2:SetParent(planet)
    planet.layer3 = MutableShape(Items.nanskip.v)
    planet.layer3.Scale = planet.Scale + (planet.Scale*0.04*(16/scale))
    planet.layer3:SetParent(planet)
    planet.cloudLayer1 = MutableShape(Items.nanskip.v)
    planet.cloudLayer1:SetParent(planet)
    planet.cloudLayer1.Scale = planet.Scale + (planet.Scale*0.08*(16/scale))
    planet.cloudLayer2 = MutableShape(Items.nanskip.v)
    planet.cloudLayer2:SetParent(planet)
    planet.cloudLayer2.Scale = planet.Scale + (planet.Scale*0.12*(16/scale))
    
    local getBl = function(x, y, z)
        local num = perlin.get(x*zoom, y*zoom, z*zoom) + perlin.get(x*zoom/2+515, y*zoom/2+515, z*zoom/2+546) - perlin.get(x*zoom/4+572, y*zoom/4+60, z*zoom/4+520)
        local riverNum = perlin.get(x*zoom/5+260, y*zoom/5+3671, z*zoom/5+1610)
        if riverNum > -0.2/2 and riverNum < -0.1/2 then
            if num >= -0.2 and num < 0.4 then num = -0.3 end
        elseif (riverNum <= -0.2/2 and riverNum > -0.25/2) or (riverNum >= -0.1/2 and riverNum < -0.05/2) then
            if num >= -0.05 and num < 0.4  then num = -0.1 end
        end

        local col = Color(255, 255, 255)

        if num < -0.5 then
            col = colors.deepWater
        elseif num >= -0.5 and num < -0.2 then
            col = colors.water
        elseif num >= -0.2 and num < -0.05 then
            col = colors.beach
        elseif num >= -0.05 and num < 0.2 then
            col = colors.grass
        elseif num >= 0.2 and num < 0.4 then
            col = colors.forest
        elseif num >= 0.4 and num < 0.6 then
            col = colors.hills
        elseif num >= 0.6 then
            col = colors.mountains
        else
            col = Color(255, 255, 255)
        end

        return Block(col, Number3(x, y, z))
    end

    local genBlock = function(x, y, z)
        local block = getBl(x, y, z)
        local block2 = Block(block.Color, Number3(x, y, z))
        block2.Color = block2.Color + Color(math.floor(math.random(-5, 5)/2)*0.01, math.floor(math.random(-5, 5)/2)*0.01, math.floor(math.random(-5, 5)/2)*0.01)

        if block.Color == colors.grass or block.Color == colors.forest or block.Color == colors.hills or block.Color == colors.mountains then
            if math.random(0, 5) ~= 0 then planet.layer2:AddBlock(block2) end
        end
        if block.Color == colors.hills or block.Color == colors.mountains then
            if math.random(0, 5) ~= 0 then planet.layer3:AddBlock(block2) end
        end
        planet:AddBlock(block2)

        local cloudNum = perlin.get(x*zoom, y*zoom, z*zoom) + perlin.get(x*zoom/2+50215, y*zoom/2+515, z*zoom/2+546) - perlin.get(x*zoom/4+5260, y*zoom/4+56200, z*zoom/4+5067100)
        cloudNum = math.floor((cloudNum + 1)*4)/4/16
        local cloudBlock = Block(Color(255, 255, 255, cloudNum), Number3(x, y, z))
        planet.cloudLayer1:AddBlock(cloudBlock)

        local cloudNum = perlin.get(x*zoom, y*zoom, z*zoom) + perlin.get(x*zoom/2+5115, y*zoom/2+5615, z*zoom/2+5676) - perlin.get(x*zoom/4+1560, y*zoom/4+5634, z*zoom/4+502600)
        cloudNum = math.floor((cloudNum + 1)*4)/4/16
        local cloudBlock = Block(Color(255, 255, 255, cloudNum), Number3(x, y, z))
        planet.cloudLayer2:AddBlock(cloudBlock)
    end

    Timer(0.1, false, function()
        for x=scale*-0.5, scale do
            for y=scale*-0.5, scale do
                genBlock(x, y, scale*-0.5)
            end
        end
    end)
    Timer(0.2, false, function()
        for x=scale*-0.5, scale do
            for z=scale*-0.5, scale do
                genBlock(x, scale*-0.5, z)
            end
        end
    end)
    Timer(0.3, false, function()
        for y=scale*-0.5, scale do
            for z=scale*-0.5, scale do
                genBlock(scale*-0.5, y, z)
            end
        end
    end)
    Timer(0.4, false, function()
        for x=scale*-0.5, scale do
            for y=scale*-0.5, scale do
                genBlock(x, y, scale)
            end
        end
    end)
    Timer(0.5, false, function()
        for x=scale*-0.5, scale do
            for z=scale*-0.5, scale do
                genBlock(x, scale, z)
            end
        end
    end)
    Timer(0.6, false, function()
        for y=scale*-0.5, scale do
            for z=scale*-0.5, scale do
                genBlock(scale, y, z)
            end
        end    
    end)
    Timer(0.7, false, function()
        planet.Pivot = Number3(planet.Width/planet.Scale.X, planet.Height/planet.Scale.Y, planet.Depth/planet.Scale.Z)/5
        planet.Scale = 0.5
        planet:SetParent(World)
    end)
end

worldgen.generateSector = function(config)
    local defaultConfig = {
        colors = {
            deepWater = Color(26, 51, 92),
            water = Color(34, 63, 110),
            beach = Color(140, 123, 65),
            grass = Color(56, 120, 49),
            forest = Color(59, 94, 45),
            hills = Color(71, 74, 73),
            mountains = Color(59, 64, 63)
        },
        scale = 129,
        roughness = 30,
        mapSize = 129,
    }

    local mergedConfig = {}
    for k, v in pairs(defaultConfig) do
        mergedConfig[k] = config[k] or v
    end

    local colors = mergedConfig.colors
    local mapSize = mergedConfig.mapSize
    local roughness = mergedConfig.roughness
    local scale = mergedConfig.scale

    map = {}
    for i = 0, mapSize do
        map[i] = {}
        for j = 0, mapSize do
            map[i][j] = 0
        end
    end

    local function randomRange(min, max)
        return math.random() * (max - min) + min
    end

    local function diamondSquare(map, size, roughness)
        local halfSize = size / 2

        if halfSize < 1 then
            return
            final()
        end

        for y = halfSize, mapSize - 1, size do
            for x = halfSize, mapSize - 1, size do
                
                local average = (map[y - halfSize][x - halfSize] +
                                 map[y - halfSize][x + halfSize] +
                                 map[y + halfSize][x - halfSize] +
                                 map[y + halfSize][x + halfSize]) / 4
                map[y][x] = average + randomRange(-roughness, roughness)
            end
        end

        for y = 0, mapSize - 1, halfSize do
            for x = (y + halfSize) % size, mapSize - 1, size do
                local sum = 0
                local count = 0
                if y - halfSize >= 0 then
                    sum = sum + map[y - halfSize][x]
                    count = count + 1
                end
                if y + halfSize < mapSize then
                    sum = sum + map[y + halfSize][x]
                    count = count + 1
                end
                if x - halfSize >= 0 then
                    sum = sum + map[y][x - halfSize]
                    count = count + 1
                end
                if x + halfSize < mapSize then
                    sum = sum + map[y][x + halfSize]
                    count = count + 1
                end
                map[y][x] = sum / count + randomRange(-roughness, roughness)
            end
        end

        Timer(0.1, false, function()
            diamondSquare(map, halfSize, roughness*0.75)
        end)
    end

    map[1][1] = randomRange(-scale, scale)
    map[1][mapSize] = randomRange(-scale, scale)
    map[mapSize][1] = randomRange(-scale, scale)
    map[mapSize][mapSize] = randomRange(-scale, scale)

    diamondSquare(map, mapSize - 1, roughness)

    final = function()

        Timer(0.1, false, function()
            for abob=1, 4 do
                for x=0, mapSize do
                    for y=0, mapSize do

                        local neighbours = {
                            {-1, 0},
                            {0, -1},
                            {1, 0},
                            {0, 1},
                            {-1, -1},
                            {-1, 1},
                            {1, -1},
                            {1, 1}
                        }
                        local count = 0
                        local avg = 0
                        for i=1, #neighbours do
                            if map[x+neighbours[i][1]][y+neighbours[i][2]] ~= nil then
                                count = count + 1
                                avg = avg + map[x+neighbours[i][1]][y+neighbours[i][2]]
                            end
                        end
                        if count == 0 then count = 1 end
                        avg = avg / count

                        map[x][y] = (map[x][y] * 0.7 + avg * 0.3)
                    end
                end
            end
        end)


        Timer(0.2, false, function()
            
            local sector = {}
            for y = 1, mapSize do
                sector[y] = {}
                Timer(0.02*y, false, function()
                    for x = 1, mapSize do
                        local value = map[y][x]

                        if value < -30 then
                            sector[y][x] = colors.deepWater
                        elseif value < -10 then
                            sector[y][x] = colors.water
                        elseif value < 5 then
                            sector[y][x] = colors.beach
                        elseif value < 20 then
                            sector[y][x] = colors.grass
                        elseif value < 40 then
                            sector[y][x] = colors.forest
                        elseif value < 60 then
                            sector[y][x] = colors.hills
                        else
                            sector[y][x] = colors.mountains
                        end

                        local col = sector[y][x] or Color.Black
                        local block = Block(col, Number3(x, y, 0))
                        a:AddBlock(block)
                    end
                end)
            end
        end)
    end
    return sector
end

return worldgen