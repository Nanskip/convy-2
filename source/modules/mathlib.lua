local mathlib = {}

function mathlib.lerp(a, b, t)
    return a + (b - a) * t
end

function mathlib.lcg(seed)
    local current_seed = seed
    return function()
        current_seed = (1103515245 * current_seed + 12345) % 2147483648
        return current_seed / 2147483648
    end
end