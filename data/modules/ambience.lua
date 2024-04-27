ambience = {}

ambience.space = function()
    require("ambience"):set({
        sky = {
            skyColor = Color(0,0,0),
            horizonColor = Color(0,0,0),
            abyssColor = Color(0,0,0),
            lightColor = Color(255, 255, 255),
            lightIntensity = 0.600000,
        },
        fog = {
            color = Color(0,0,0),
            near = 1000,
            far = 1000,
            lightAbsorbtion = 0.400000,
        },
        sun = {
            color = Color(197,201,177),
            intensity = 1.000000,
            rotation = Number3(1.061163, 3.595367, 0.000000),
        },
        ambient = {
            skyLightFactor = 0.100000,
            dirLightFactor = 0.200000,
        }
    })
end

return ambience