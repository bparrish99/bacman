local setup = {}
local Maze = require("maze")

setup.startGame = function()

    local colors = {
        wall = {0.3, 0.2, 0.6},
        pellet = {1.0, 0.86, 0.58},
        background = {0.0, 0.00, 0.00},
        power = {1.0, 0.86, 0.58, 0.9},
        pacman = {1.0, 0.9, 0.2},
        sunglasses = {0.05, 0.05, 0.05}
    }
    
    local renderConfig = {
        tileSize = TILE_SIZE,
        wallPadding = WALL_PADDING,
        pelletRadius = PELLET_RADIUS,
        powerRadius = POWER_RADIUS,
        colors = colors,
        pixelsPerTile = PIXELS_PER_TILE,
        pixelSize = PIXEL_SIZE
    }
    
    local pac = {
        x = 16 * PIXELS_PER_TILE,
        y = 25.5 * PIXELS_PER_TILE,
        xTile, yTile = pixelToTile(14 * PIXELS_PER_TILE, 23.5 * PIXELS_PER_TILE),
        direction = "left",
        startX = 16 * PIXELS_PER_TILE,
        startY = 25.5 * PIXELS_PER_TILE,
        mouf = 4
    }
    
    local ghosts = {
        {
            name = "Blinky",
            color = { 1, 0, 0 },
            x = 16 * PIXELS_PER_TILE,
            y = 13.5 * PIXELS_PER_TILE,
            startX = 16 * PIXELS_PER_TILE,
            startY = 13.5 * PIXELS_PER_TILE,
            direction = "left",
            scatterX=30,scatterY=3,
            setTarget = function(self, pac)
                -- Example: Blinky targets Pac-Man's current tile
                self.targetX = pac.xTile
                self.targetY = pac.yTile
            end,
        },
        {
            name = "Pinky",
            color = { 1, .7, 1 },
            x = 14 * PIXELS_PER_TILE,
            y = 13.5 * PIXELS_PER_TILE,
            startX = 14 * PIXELS_PER_TILE,
            startY = 13.5 * PIXELS_PER_TILE,
            direction = "left",
            scatterX=3, scatterY=3,
            setTarget = function(self, pac)
                -- Example: Blinky targets Pac-Man's current tile
                if pac.direction == "left" then
                    self.targetX = pac.xTile - 4
                    self.targetY = pac.yTile
                elseif pac.direction == "right" then
                    self.targetX = pac.xTile + 4
                    self.targetY = pac.yTile
                elseif pac.direction == "up" then
                    self.targetX = pac.xTile - 4 -- maintain overflow bug
                    self.targetY = pac.yTile - 4
                elseif pac.direction == "down" then
                    self.targetX = pac.xTile
                    self.targetY = pac.yTile + 4
                else
                    self.targetX = pac.xTile - 4
                    self.targetY = pac.yTile
                end
            end,
        },
        {
            name = "Inky",
            color = { .5, .7, 1 },
            x = 18 * PIXELS_PER_TILE,
            y = 13.5 * PIXELS_PER_TILE,
            startX = 18 * PIXELS_PER_TILE,
            startY = 13.5 * PIXELS_PER_TILE,
            direction = "left",
            scatterX = 30,
            scatterY = 33,
            setTarget = function(self, pac, ghosts)
                local anchorX, anchorY;
                -- Example: Blinky targets Pac-Man's current tile
                if pac.direction == "left" then
                    anchorX = pac.xTile - 2
                    anchorY = pac.yTile
                elseif pac.direction == "right" then
                    anchorX = pac.xTile + 2
                    anchorY = pac.yTile
                elseif pac.direction == "up" then
                    anchorX = pac.xTile - 2 -- preserve lookup bug
                    anchorY = pac.yTile - 2
                elseif pac.direction == "down" then
                    anchorX = pac.xTile
                    anchorY = pac.yTile + 2
                else
                    anchorX = pac.xTile - 2
                    anchorY = pac.yTile
                end
    
                local blinky = nil
                for i, ghost in ipairs(ghosts) do
                    if ghost.name == "Blinky" then
                        blinky = ghost
                        break
                    end
                end
    
                local blinkyX, blinkyY = pixelToTile(blinky.x, blinky.y);
    
                local vx = anchorX - blinkyX
                local vy = anchorY - blinkyY
                self.targetX = blinkyX + 2 * vx
                self.targetY = blinkyY + 2 * vy
            end,
        },
        {
            name = "Clyde",
            color = { 1, .5, .2 },
            x = 20 * PIXELS_PER_TILE,
            y = 13.5 * PIXELS_PER_TILE,
            startX = 20 * PIXELS_PER_TILE,
            startY = 13.5 * PIXELS_PER_TILE,
            direction = "left",
            setTarget = function(self, pac)
                -- Note: self.xTile/yTile are not updated during movement, 
                --   use pixelToTile(self.x, self.y) to get Clyde's current tile position.
                local xTile, yTile = pixelToTile(self.x, self.y)
                local dx = xTile - pac.xTile
                local dy = yTile - pac.yTile
                local distance = math.sqrt(dx * dx + dy * dy)
                if (distance >= 8) then
                    self.targetX = pac.xTile
                    self.targetY = pac.yTile
                else
                    self.targetX = 1
                    self.targetY = 31
                end
            end,
            scatterX = 3,
            scatterY = 33,
        },
    }
    local dots = Maze.dots()
    local powerPellets = Maze.powerPellets()
    gameState.lives = 3
    gameState.score = 0
    timer.startup = 2
    gameState.halted = true
    gameState.level = 1
    gameState.ghostMode = "scatter"

    pac.speed = Maze.getPacSpeed(gameState.level, "norm")
    for i, ghost in ipairs(ghosts) do
        ghost.speed = Maze.getGhostSpeed(gameState.level, "norm")
    end

    return colors, renderConfig, pac, ghosts, dots, powerPellets
end

return setup
