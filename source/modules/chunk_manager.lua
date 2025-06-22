local chunk_manager = {}

chunk_manager.init = function(self, map)
    debug.log("Initializing Chunk Manager...")

    self.chunks = {}
    self.chunk_size = 8

    _STATS_CHUNKS = 0

    -- check map data
    for chunkX = 1, (map.size+(self.chunk_size-1))/self.chunk_size do
        self.chunks[chunkX] = {}
        for chunkY = 1, (map.size+(self.chunk_size-1))/self.chunk_size do
            local chunk = {}

            for x = 1, self.chunk_size do
                chunk[x] = {}
                for y = 1, self.chunk_size do
                    local realX = chunkX*self.chunk_size + x
                    local realY = chunkY*self.chunk_size + y
                    if realX > map.size or realY > map.size then
                        --debug.log("Data read out of bounds: " .. realX .. ", " .. realY)
                        chunk[x][y] = {
                            height = 0
                        }
                    else
                        chunk[x][y] = {
                            height = map[realY][realX]
                        }
                    end
                end
            end

            self.chunks[chunkX][chunkY] = chunk
        end
    end

    debug.log("Importing tile atlas...")
    self.tile_atlas = JSON:Decode(data.world_tiles)["tiles"]

    debug.log("Chunk Manager initialized.")
end

-- rendering full map is so unefficient
-- used only for testing
chunk_manager.renderFullMap = function(self)
    for chunkX = 1, #self.chunks do
        for chunkY = 1, #self.chunks[chunkX] do
            for x = 1, self.chunk_size do
                for y = 1, self.chunk_size do
                    self:showQuad(chunkX, chunkY, x, y)
                end
            end
        end
    end
end

chunk_manager.renderNearbyChunks = function(self, chunkX, chunkY)
    -- list of chunks being rendered
    local showingChunks = {
        {-3,  2}, {-2,  2}, {-1,  2}, {0,  2}, {1,  2}, {2,  2}, {3,  2},
        {-3,  1}, {-2,  1}, {-1,  1}, {0,  1}, {1,  1}, {2,  1}, {3,  1},
        {-3,  0}, {-2,  0}, {-1,  0}, {0,  0}, {1,  0}, {2,  0}, {3,  0},
        {-3, -1}, {-2, -1}, {-1, -1}, {0, -1}, {1, -1}, {2, -1}, {3, -1},
        {-3, -2}, {-2, -2}, {-1, -2}, {0, -2}, {1, -2}, {2, -2}, {3, -2},
    }

    -- list of chunks should be hidden, just a bounding box of rendered ones
    local hidingChunks = {
        {-4,  3}, {-3,  3}, {-2,  3}, {-1,  3}, {0,  3}, {1,  3}, {2,  3}, {3,  3}, {4,  3},
        {-4,  2}, --[[------------------------there are--------------------------]] {4,  2},
        {-4,  1}, --[[----------------chunks-------------------------------------]] {4,  1},
        {-4,  0}, --[[-------------------------------being-----------------------]] {4,  0},
        {-4, -1}, --[[-----------------------rendered----------------------------]] {4, -1},
        {-4, -2}, --[[-------------------------dayuuumm--------------------------]] {4, -2},
        {-4, -3}, {-3, -3}, {-2, -3}, {-1, -3}, {0, -3}, {1, -3}, {2, -3}, {3, -3}, {4, -3},
    }
    
    for _, chunk in ipairs(showingChunks) do
        self:showChunk(chunkX + chunk[1], chunkY + chunk[2])
    end

    for _, chunk in ipairs(hidingChunks) do
        self:hideChunk(chunkX + chunk[1], chunkY + chunk[2])
    end
end

chunk_manager.createQuad = function(self, chunkX, chunkY, x, y)
    local chunk = self.chunks[chunkX][chunkY]
    local block = chunk[x][y]
    local h = block.height

    if h == nil then
        return
    end
    local tile_name = chunk_manager:getTile(h)
    -- creating quad
    local pos = Number3(
        chunkX*self.chunk_size + x,
        0,
        chunkY*self.chunk_size + y
    )
    local quad = Quad()

    quad.Position = pos
    quad:SetParent(World)
    -- tile texture atlas is 128x128
    quad.Width = 128
    quad.Height = 128
    -- changing properties
    -- quad.Tiling (Number2) -- default is 1, 1, but if set to 0.5, 0.5
    -- the fourth part of image will be seen (damn, it's a cutout btw)
    -- quad.Offset (Number2 -- default is 0, 0, max is 1, 1 and can be used
    -- to offset the image (even if cutout used)
    quad.Tiling = Number2(1/16, 1/16) -- 8x8 tiles on 128x128 map (16x16 tiles)
    local cords = {
        self.tile_atlas[tile_name].pos[1]/8,
        self.tile_atlas[tile_name].pos[2]/8
    }
    if self.tile_atlas[tile_name].variations ~= nil then
        local rand = math.random(0, self.tile_atlas[tile_name].variations-1)
        cords[2] = cords[2] + rand
    end
    quad.Offset = Number2(cords[1]/16, cords[2]/16) -- offset of the texture

    if self.tile_atlas[tile_name].animated == true then
        self.chunks[chunkX][chunkY].animatedObjects[#self.chunks[chunkX][chunkY].animatedObjects+1] = quad
    end
    quad.name = tile_name

    -- setting tile atlas
    quad.Image = {data = textures.tile_atlas, filtering=false}
    quad.Rotation.X = math.pi/2
    quad.Scale = 1/128 -- reset scale

    block.quad = quad
    -- mask for neighbour tiles that are different from the current one
    
    block.masks = {}

    -- checking neighbours
    local neighbour_tiles = chunk_manager:checkNeighbours(chunkX, chunkY, x, y)
    local num_neighbours = 0
    for key, value in pairs(neighbour_tiles) do
        num_neighbours = num_neighbours + 1
    end
    for key, value in pairs(neighbour_tiles) do
        if value == nil or self.tile_atlas[value] == nil then
            debug.log("Invalid neighbour tile:", tostring(value))
            return
        end
        local direction = key

        -- create half opacity mask with neighbours texture to blend borders
        local mask = Quad()
        mask:SetParent(World)
        -- tile texture atlas is 128x128
        mask.Position = Number3(
            chunkX*self.chunk_size + x,
            0.05,
            chunkY*self.chunk_size + y
        )
        mask.Width = 128
        mask.Height = 128
        mask.Tiling = Number2(1/16, 1/16)
        local cords_quad = {
            self.tile_atlas[value].pos[1]/8,
            self.tile_atlas[value].pos[2]/8
        }
        if self.tile_atlas[value].variations ~= nil then
            local rand = math.random(0, self.tile_atlas[value].variations-1)
            cords_quad[2] = cords_quad[2] + rand
        end
        mask.Offset = Number2(cords_quad[1]/16, cords_quad[2]/16)
        mask.Color.A = 0.1/num_neighbours
        mask.IsUnlit = true
        mask.Shadow = false
        mask.Rotation.X = math.pi/2
        mask.Scale = 1/128

        mask.Image = {data = textures.tile_atlas, filtering=false}
        block.masks[key] = mask
    end
end

chunk_manager.showChunk = function(self, chunkX, chunkY)
    if self.chunks[chunkX] == nil or self.chunks[chunkX][chunkY] == nil then
        return
    end
    if self.chunks[chunkX][chunkY].rendered then
        return
    end
    self.chunks[chunkX][chunkY].rendered = true
    self.chunks[chunkX][chunkY].animatedObjects = {}
    self.chunks[chunkX][chunkY].tickObject = Object()
    self.chunks[chunkX][chunkY].tickObject.Tick = function(_)
        for _, obj in ipairs(self.chunks[chunkX][chunkY].animatedObjects) do
            if obj.frame == nil then obj.frame = 0 end -- ensure that frame is initialized
            if math.random(0, 5) == 0 then
                obj.frame = obj.frame + 1
            end
            if obj.frame >= 8 then obj.frame = 0 end -- reset frame if it reaches 8

            -- calculate frame coords
            local coords = {
                self.tile_atlas[obj.name].pos[1]/8,
                (self.tile_atlas[obj.name].pos[2]/8) + (obj.frame)
            }

            -- apply frame offset
            obj.Offset = Number2(coords[1]/16, coords[2]/16)
        end
    end
    _STATS_CHUNKS = _STATS_CHUNKS + 1
    for x = 1, self.chunk_size do
        for y = 1, self.chunk_size do
            self:showQuad(chunkX, chunkY, x, y)
        end
    end
end

chunk_manager.hideChunk = function(self, chunkX, chunkY)
    if self.chunks[chunkX] == nil or self.chunks[chunkX][chunkY] == nil then
        return
    end
    if not self.chunks[chunkX][chunkY].rendered then
        return
    end
    self.chunks[chunkX][chunkY].rendered = false
    self.chunks[chunkX][chunkY].animatedObjects = nil
    self.chunks[chunkX][chunkY].tickObject.Tick = nil
    self.chunks[chunkX][chunkY].tickObject = nil
    _STATS_CHUNKS = _STATS_CHUNKS - 1
    for x = 1, self.chunk_size do
        for y = 1, self.chunk_size do
            self:hideQuad(chunkX, chunkY, x, y)
        end
    end
end

chunk_manager.showQuad = function(self, chunkX, chunkY, x, y)
    local chunk = self.chunks[chunkX][chunkY]
    local block = chunk[x][y]

    if block.quad ~= nil then
        for key, value in pairs(block.masks) do
            value:Destroy()
            value = nil
        end

        block.quad:Destroy()
        block.quad = nil
    end

    self:createQuad(chunkX, chunkY, x, y)
end

chunk_manager.hideQuad = function(self, chunkX, chunkY, x, y)
    if self.chunks[chunkX] == nil or self.chunks[chunkX][chunkY] == nil then
        return
    end
    local chunk = self.chunks[chunkX][chunkY]
    local block = chunk[x][y]

    if block.quad ~= nil then
        for key, value in pairs(block.masks) do
            value:Destroy()
            value = nil
        end

        block.quad:Destroy()
        block.quad = nil
    end
end

chunk_manager.getTile = function(self, h)
    local tile_name = "deep_water"
    if h < 0.07 then
        tile_name = "deep_water"
    elseif h < 0.14 then
        tile_name = "water"
    elseif h < 0.21 then
        tile_name = "low_water"
    elseif h < 0.28 then
        tile_name = "soft_sand"
    elseif h < 0.35 then
        tile_name = "hard_sand"
    elseif h < 0.42 then
        tile_name = "gravel"
    elseif h < 0.49 then
        tile_name = "low_grass"
    elseif h < 0.56 then
        tile_name = "grass"
    elseif h < 0.63 then
        tile_name = "high_grass"
    elseif h < 0.7 then
        tile_name = "spores"
    elseif h < 0.77 then
        tile_name = "dense_spores"
    elseif h < 0.84 then
        tile_name = "low_rocks"
    elseif h < 0.91 then
        tile_name = "rocks"
    else
        tile_name = "frozen_rocks"
    end

    return tile_name
end

chunk_manager.checkNeighbours = function(self, chunkX, chunkY, x, y)
    local neighbour_tiles = {
        left = nil,
        up = nil,
        right = nil,
        down = nil
    }

    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, -1, 0, "left")
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 0, 1, "up")
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 1, 0, "right")
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 0, -1, "down")

    return neighbour_tiles
end

chunk_manager.checkNeighbour = function(self, chunkX, chunkY, x, y, neighbour_tiles, dx, dy, direction)
    local nx, ny = x + dx, y + dy
    local nChunkX, nChunkY = chunkX, chunkY

    -- correction of chunk coordinates if out of bounds
    if nx < 1 then
        nChunkX = chunkX - 1
        nx = self.chunk_size
    elseif nx > self.chunk_size then
        nChunkX = chunkX + 1
        nx = 1
    end

    if ny < 1 then
        nChunkY = chunkY - 1
        ny = self.chunk_size
    elseif ny > self.chunk_size then
        nChunkY = chunkY + 1
        ny = 1
    end

    -- checking for existence of neighbour chunk
    if not self.chunks[nChunkX] or not self.chunks[nChunkX][nChunkY] then
        return
    end

    local neighbourChunk = self.chunks[nChunkX][nChunkY]
    local neighbourBlock = neighbourChunk[nx] and neighbourChunk[nx][ny]

    if not neighbourBlock then return end

    local neighbour_tile = chunk_manager:getTile(neighbourBlock.height)
    local current_tile = chunk_manager:getTile(self.chunks[chunkX][chunkY][x][y].height)

    if neighbour_tile ~= current_tile then
        neighbour_tiles[direction] = neighbour_tile
    end
end
