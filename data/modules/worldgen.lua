worldgen = {}

worldgen.generatePlanet = function(config)
    defaultConfig = {
        scale = 16,
        colors = {
            deepWater = Color(18, 39, 74),
            water = Color(34, 63, 110),
            beach = Color(140, 123, 65),
            grass = Color(56, 120, 49),
            forest = Color(59, 94, 45),
            hills = Color(68, 107, 64),
            mountains = Color(62, 71, 70)
        },
        zoom = 0.01
    }

    local scale = config.scale or defaultConfig.scale
    local colors = config.colors or defaultConfig.colors
    local zoom = config.zoom or defaultConfig.zoom

    planet = MutableShape(Items.nanskip.v)

    local getBl = function(x, y, z)
        local num = perlin.get(x*zoom, y*zoom, z*zoom)

        if num < -0.5 then
            local col = colors.deepWater
        elseif num >= -0.5 and num < -0.2 then
            local col = colors.water
        elseif num >= -0.2 and num < -0.1 then
            local col = colors.beach
        elseif num >= -0.1 and num < 0.2 then
            local col = colors.grass
        elseif num >= 0.2 and num < 0.4 then
            local col = colors.forest
        elseif num >= 0.4 and num < 0.5 then
            local col = colors.hills
        elseif num >= 0.5 then
            local col = colors.mountains
        else
            local col = Color(255, 255, 255)
        end

        return Block(col, Number3(x, y, z))
    end

    for x=scale*-2, scale do
        local block = getBl(x, scale*-2, scale*-2)

        planet:AddBlock(block)
    end
end

return worldgen