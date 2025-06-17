local chunk_manager = {}

chunk_manager.init = function(self, map)
    debug.log("Initializing Chunk Manager...")

    self.chunks = {}
    self.chunk_size = 8

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

    -- setting tile atlas
    quad.Image = {data = textures.tile_atlas, filtering=false}
    quad.Rotation.X = math.pi/2
    quad.Scale = 1/128 -- reset scale

    block.quad = quad
    -- mask for neighbour tiles that are different from the current one
    block.masks = {}

    -- checking neighbours
    local neighbour_tiles = chunk_manager:checkNeighbours(chunkX, chunkY, x, y)
    for key, value in ipairs(neighbour_tiles) do
        if self.tile_atlas["mask" .. key] == nil then
            debug.log("Mask not found: mask" .. key)
        end
        local direction = "left"
        if key == 1 then
            direction = "left"
        elseif key == 2 then
            direction = "up"
        elseif key == 3 then
            direction = "right"
        elseif key == 4 then
            direction = "down"
        end
        block.masks[key] = Quad()
        block.masks[key].Position = Number3(
            chunkX*self.chunk_size + x + 1,
            0.1,
            chunkY*self.chunk_size + y + 1
        )
        block.masks[key]:SetParent(World)
        block.masks[key].Width = 128
        block.masks[key].Height = 128
        block.masks[key].Tiling = Number2(1/16, 1/16)
        local cords = {
            self.tile_atlas["mask_" .. direction].pos[1]/8,
            self.tile_atlas["mask_" .. direction].pos[2]/8
        }
        -- no variations for masks
        quad.Offset = Number2(cords[1]/16, cords[2]/16)
        block.masks[key].Image = {data = textures.tile_atlas, filtering=false, alpha=true}
        block.masks[key].Rotation.X = math.pi/2
        block.masks[key].Scale = 1/128
    end
end

chunk_manager.showQuad = function(self, chunkX, chunkY, x, y)
    local chunk = self.chunks[chunkX][chunkY]
    local block = chunk[x][y]

    if block.quad ~= nil then
        block.quad:Remove()
    end

    self:createQuad(chunkX, chunkY, x, y)
end

chunk_manager.hideQuad = function(self, chunkX, chunkY, x, y)
    local chunk = self.chunks[chunkX][chunkY]
    local block = chunk[x][y]

    if block.quad ~= nil then
        block.quad:Remove()
    end
end

chunk_manager.getTile = function(self, h)
    local tile_name = "deep_water"
    if h == nil then
        return tile_name
    end
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
    local neighbour_tiles = {}

    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 1, 0)
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 0, 1)
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, -1, 0)
    self:checkNeighbour(chunkX, chunkY, x, y, neighbour_tiles, 0, -1)

    return neighbour_tiles
end

chunk_manager.checkNeighbour = function(self, chunkX, chunkY, x, y, neighbour_tiles, x_offset, y_offset)
    local newChunk = self.chunks[chunkX][chunkY]
    if newChunk[x+x_offset] == nil then
        newChunk = self.chunks[chunkX+x_offset][chunkY]
    end
    local neighbourBlock = newChunk[x+x_offset][y+y_offset]
    if neighbourBlock == nil then
        return
    end
    local neighbourH = neighbourBlock.height

    local neighbour_tile = chunk_manager:getTile(neighbourH)
    local original_tile = chunk_manager:getTile(self.chunks[chunkX][chunkY][x][y].height)
    if neighbour_tile ~= original_tile then
        neighbour_tiles[#neighbour_tiles+1] = neighbour_tile
    end
end