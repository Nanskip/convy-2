worldgen = {}

worldgen.generatePlanet = function(config)
    defaultConfig = {
        scale = 16,
        colors = {
            deepWater = Color(26, 51, 92),
            water = Color(34, 63, 110),
            beach = Color(140, 123, 65),
            grass = Color(56, 120, 49),
            forest = Color(59, 94, 45),
            hills = Color(71, 74, 73),
            mountains = Color(59, 64, 63)
        },
        zoom = 0.075*2
    }

    local scale = config.scale or defaultConfig.scale
    local colors = config.colors or defaultConfig.colors
    local zoom = config.zoom or defaultConfig.zoom

    planet = MutableShape(Items.nanskip.v)
    planet.layer2 = MutableShape(Items.nanskip.v)
    planet.layer2.Scale = planet.Scale + (planet.Scale*0.02)
    planet.layer2:SetParent(planet)
    planet.layer3 = MutableShape(Items.nanskip.v)
    planet.layer3.Scale = planet.Scale + (planet.Scale*0.04)
    planet.layer3:SetParent(planet)
    
    local getBl = function(x, y, z)
        local num = perlin.get(x*zoom, y*zoom, z*zoom) + perlin.get(x*zoom/2+5015, y*zoom/2+50215, z*zoom/2+50346) - perlin.get(x*zoom/4+50, y*zoom/4+500, z*zoom/4+5000)
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
    end

    for x=scale*-0.5, scale do
        for y=scale*-0.5, scale do
            genBlock(x, y, scale*-0.5)
        end
    end
    for x=scale*-0.5, scale do
        for z=scale*-0.5, scale do
            genBlock(x, scale*-0.5, z)
        end
    end
    for y=scale*-0.5, scale do
        for z=scale*-0.5, scale do
            genBlock(scale*-0.5, y, z)
        end
    end
    for x=scale*-0.5, scale do
        for y=scale*-0.5, scale do
            genBlock(x, y, scale)
        end
    end
    for x=scale*-0.5, scale do
        for z=scale*-0.5, scale do
            genBlock(x, scale, z)
        end
    end
    for y=scale*-0.5, scale do
        for z=scale*-0.5, scale do
            genBlock(scale, y, z)
        end
    end

    planet:SetParent(World)
end

return worldgen