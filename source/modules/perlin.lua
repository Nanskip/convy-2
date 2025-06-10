local perlin = {}

-- Simple deterministic random number generator (Linear Congruential Generator)
local function lcg(seed)
    local current_seed = seed
    return function()
        current_seed = (1103515245 * current_seed + 12345) % 2147483648
        return current_seed / 2147483648
    end
end

-- Create a new Perlin noise instance
function perlin.new(seed)
    local self = {}

    self.permutation = {}

    local function shuffle(seed)
        local rand = lcg(seed)
        for i = 0, 255 do
            self.permutation[i] = i
        end
        for i = 1, #self.permutation do
            local j = math.floor(rand() * (#self.permutation - 1)) + 1
            local a = self.permutation[i]
            local b = self.permutation[j]
            self.permutation[i] = b
            self.permutation[j] = a
        end
    end

    function self.seed(seed)
        for _ = 0, 5 do
            shuffle(seed)
            for i = 0, 255 do
                self.permutation[256 + i] = self.permutation[i]
            end
        end
    end

    function self.get(x, y, z)
        x = x % 256
        y = y % 256
        if z == nil then z = 0 end
        z = z % 256

        local X = math.floor(x) % 256
        local Y = math.floor(y) % 256
        local Z = math.floor(z) % 256

        x = x - math.floor(x)
        y = y - math.floor(y)
        z = z - math.floor(z)

        local u = self.fade(x)
        local v = self.fade(y)
        local w = self.fade(z)

        local p = self.permutation

        local A  = p[X] + Y
        local AA = p[A] + Z
        local AB = p[A + 1] + Z
        local B  = p[X + 1] + Y
        local BA = p[B] + Z
        local BB = p[B + 1] + Z

        return self.lerp(w,
            self.lerp(v,
                self.lerp(u, self.grad(p[AA  ], x  , y  , z   ), self.grad(p[BA  ], x-1, y  , z   )),
                self.lerp(u, self.grad(p[AB  ], x  , y-1, z   ), self.grad(p[BB  ], x-1, y-1, z   ))
            ),
            self.lerp(v,
                self.lerp(u, self.grad(p[AA+1], x  , y  , z-1 ), self.grad(p[BA+1], x-1, y  , z-1 )),
                self.lerp(u, self.grad(p[AB+1], x  , y-1, z-1 ), self.grad(p[BB+1], x-1, y-1, z-1 ))
            )
        )
    end

    function self.lerp(t, a, b)
        return a + t * (b - a)
    end

    function self.fade(t)
        return t * t * t * (t * (t * 6 - 15) + 10)
    end

    function self.grad(hash, x, y, z)
        local h = hash % 16
        local u = h < 8 and x or y
        local v = h < 4 and y or (h == 12 or h == 14) and x or z
        return ((h % 2) == 0 and u or -u) + ((h % 4) < 2 and v or -v)
    end

    self.seed(seed or os.time())

    return self
end

perlin.version = "0.2"
