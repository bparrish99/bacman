local DEBUG=false
local PIXEL_SIZE=4
local TILE_SIZE = PIXEL_SIZE * 8
local WALL_PADDING = 1
local PELLET_RADIUS = 2
local POWER_RADIUS = 5
local PIXELS_PER_TILE = 8
local Renderer = require("renderer")
local Maze = require("maze")

timer = { powerBlink = 0, ghostMode = 0, t = 0 }
gameState = {
    halted = false
}
-- Convert pixel coordinates to tile coordinates (1-indexed)
local function pixelToTile(x, y)
    local col = math.floor(x / PIXELS_PER_TILE) + 1
    local row = math.floor(y / PIXELS_PER_TILE) + 1
    return col, row
end

-- Load maze data from separate module
local maze = Maze.layout
local dots = Maze.dots
local powerPellets = Maze.powerPellets

local rows = #maze
local cols = #maze[1]
local windowWidth = cols * TILE_SIZE
local windowHeight = rows * TILE_SIZE

local colors = {
    wall = {0.05, 0.27, 0.9},
    pellet = {1.0, 0.86, 0.58},
    background = {0.02, 0.02, 0.05},
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
    x = 14 * PIXELS_PER_TILE,
    y = 23.5 * PIXELS_PER_TILE,
    xTile, yTile = pixelToTile(14 * PIXELS_PER_TILE, 23.5 * PIXELS_PER_TILE),
    speed = 1,
    direction = "left",
    startX = 14 * PIXELS_PER_TILE,
    startY = 23.5 * PIXELS_PER_TILE
}

local ghosts = {
    {
        name = "Blinky",
        color = { 1, 0, 0 },
        x = 14 * PIXELS_PER_TILE,
        y = 11.5 * PIXELS_PER_TILE,
        startX = 14 * PIXELS_PER_TILE,
        startY = 11.5 * PIXELS_PER_TILE,
        direction = "left",
        mode = "scatter",
        speed = .85,
        scatterX=28,scatterY=1,
        setTarget = function(self, pac)
            -- Example: Blinky targets Pac-Man's current tile
            self.targetX = pac.xTile
            self.targetY = pac.yTile
        end,
    },
    {
        name = "Pinky",
        color = { 1, .7, 1 },
        x = 12 * PIXELS_PER_TILE,
        y = 11.5 * PIXELS_PER_TILE,
        startX = 12 * PIXELS_PER_TILE,
        startY = 11.5 * PIXELS_PER_TILE,
        direction = "left",
        mode = "scatter",
        speed = .85,
        scatterX=1, scatterY=1,
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
        x = 16 * PIXELS_PER_TILE,
        y = 11.5 * PIXELS_PER_TILE,
        startX = 16 * PIXELS_PER_TILE,
        startY = 11.5 * PIXELS_PER_TILE,
        direction = "left",
        mode = "scatter",
        speed = .85,
        scatterX = 28,
        scatterY = 31,
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
        x = 18 * PIXELS_PER_TILE,
        y = 11.5 * PIXELS_PER_TILE,
        startX = 18 * PIXELS_PER_TILE,
        startY = 11.5 * PIXELS_PER_TILE,
        direction = "left",
        mode = "scatter",
        speed = .85,
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
        scatterX = 1,
        scatterY = 31,
    },
}

local function isWall(row, col)
    return getTile(row, col) == "#"
end

function love.load()
    love.window.setTitle("Pinbac-Man")
    love.window.setMode(windowWidth, windowHeight, {resizable = false})
    love.graphics.setBackgroundColor(colors.background)
    timer.startup = 2
    gameState.halted = true
end

local pressedKeys = {}

function love.keypressed(key)
    pressedKeys[key] = true
end

function love.keyreleased(key)
    pressedKeys[key] = false
end

function love.update(dt)
    timer.t = timer.t + dt
    if gameState.halted then
        if (timer.restart and timer.restart > 0) then
            timer.restart = timer.restart - dt
            if timer.restart <= 0 then
                pac.x = pac.startX
                pac.y = pac.startY
                pac.direction = "left"
                for i, ghost in ipairs(ghosts) do
                    ghost.x = ghost.startX
                    ghost.y = ghost.startY
                    ghost.direction = "left"
                end
                timer.startup = 2
                for i, ghost in ipairs(ghosts) do
                    ghost.mode = "scatter"
                end
                timer.ghostMode = 0
            end
        end
        if (timer.startup and timer.startup > 0) then
            timer.startup = timer.startup - dt
            if timer.startup <= 0 then gameState.halted = false end
        end
        if (timer.ateGhost and timer.ateGhost > 0) then
            timer.ateGhost = timer.ateGhost - dt
            if timer.ateGhost <=0 then 
                gameState.halted = false
                gameState.ateGhost = false
            end
        end
    else
        -- animation or future logic hooks could go here
        local dotEaten = false;
        pacXTile, pacYTile = pixelToTile(pac.x, pac.y);
        if (pacXTile ~= pac.xTile or pacYTile ~= pac.yTile) then -- pac-man in new tile
            pac.xTile = pacXTile;
            pac.yTile = pacYTile;
            for i, dot in ipairs(dots) do
                if dot[1] == pacXTile and dot[2] == pacYTile then
                    table.remove(dots, i);
                    dotEaten = true;
                end
            end
            for i, powerPellet in ipairs(powerPellets) do
                if powerPellet[1] == pacXTile and powerPellet[2] == pacYTile then
                    table.remove(powerPellets, i);
                    dotEaten = true;
                    for i, ghost in ipairs(ghosts) do
                        ghost.mode = "frightened"
                        if ghost.direction == "left" then ghost.direction = "right"
                        elseif ghost.direction == "right" then ghost.direction = "left"
                        elseif ghost.direction == "up" then ghost.direction = "down"
                        else ghost.direction = "up"
                        end
                    end
                    timer.ghostMode = 1 -- right now, this should force 8 seconds, refactor
                end
            end
        end

        if (timer.ghostMode > 9) then
            timer.ghostMode = 0;
            for i, ghost in ipairs(ghosts) do
                if (ghost.mode ~= "frightened" and ghost.mode ~= "dead") then
                    if ghost.direction == "left" then ghost.direction = "right"
                    elseif ghost.direction == "right" then ghost.direction = "left"
                    elseif ghost.direction == "up" then ghost.direction = "down"
                    else ghost.direction = "up"
                    end
                end
                if ghost.mode == "chase" or ghost.mode == "frightened" then ghost.mode = "scatter"
                elseif ghost.mode == "scatter" then ghost.mode = "chase"
                end
            end
        end
    
        for i, ghost in ipairs(ghosts) do
            if (ghost.mode == "scatter") then
                ghost.targetX = ghost.scatterX
                ghost.targetY = ghost.scatterY
            elseif ghost.mode == "dead" then
                ghost.targetX, ghost.targetY = pixelToTile(ghost.startX, ghost.startY)
            else
                ghost:setTarget(pac, ghosts)
            end
            ghost.xTile, ghost.yTile = pixelToTile(ghost.x, ghost.y);
            if ghost.direction == "left" then
                ghost.x = ghost.x - ghost.speed
                if (ghost.x % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                    if (maze[ghost.yTile][ghost.xTile - 1] ~= 1 or ghost.nextDir == "up" or ghost.nextDir == "down") then
                        ghost.x = ghost.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        ghost.direction = ghost.nextDir
                    end
                end  
            elseif ghost.direction == "right" then
                ghost.x = ghost.x + ghost.speed
                if (ghost.x % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                    if (maze[ghost.yTile][ghost.xTile + 1] ~= 1 or ghost.nextDir == "up" or ghost.nextDir == "down") then
                        ghost.x = ghost.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        ghost.direction = ghost.nextDir
                    end
                end  
            elseif ghost.direction == "up" then
                ghost.y = ghost.y - ghost.speed
                if (ghost.y % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                    if (maze[ghost.yTile - 1][ghost.xTile] ~= 1 or ghost.nextDir == "left" or ghost.nextDir == "right") then
                        ghost.y = ghost.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        ghost.direction = ghost.nextDir
                    end
                end  
            elseif ghost.direction == "down" then
                ghost.y = ghost.y + ghost.speed
                if (ghost.y % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                    if (maze[ghost.yTile + 1][ghost.xTile] ~= 1 or ghost.nextDir == "left" or ghost.nextDir == "right") then
                        ghost.y = ghost.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        ghost.direction = ghost.nextDir
                    end
                end  
            end
            local newXTile, newYTile = pixelToTile(ghost.x, ghost.y)

            local startXTile, startYTile = pixelToTile(ghost.startX, ghost.startY)
            if ghost.mode == "dead" and newXTile == startXTile and newYTile == startYTile then
                ghost.mode = "chase"
            end

            -- check for eating or been eaten
            if newXTile == pac.xTile and newYTile == pac.yTile then
                if ghost.mode == "frightened" and not gameState.ateGhost then
                    ghost.direction = "left"
                    gameState.halted = true
                    gameState.ateGhost = ghost.name
                    ghost.mode = "dead"
                    timer.ateGhost = 1
                    
                elseif ghost.mode ~= "dead" then -- ate pacman
                    gameState.halted = true
                    timer.restart = 2
                end
            end
            if (newXTile ~= ghost.xTile or newYTile ~= ghost.yTile) then
                ghost.xTile = newXTile
                ghost.yTile = newYTile
                local candidates = {}
                if maze[ghost.yTile - 1][ghost.xTile] == 1 and ghost.direction ~= "down" then
                    candidates[#candidates + 1] = {ghost.xTile, ghost.yTile-1}
                end
                if maze[ghost.yTile + 1][ghost.xTile] == 1 and ghost.direction ~= "up" then
                    candidates[#candidates + 1] = {ghost.xTile, ghost.yTile+1}
                end
                if maze[ghost.yTile][ghost.xTile - 1] == 1 and ghost.direction ~= "right" then
                    candidates[#candidates + 1] = {ghost.xTile-1, ghost.yTile}
                end
                if maze[ghost.yTile][ghost.xTile + 1] == 1 and ghost.direction ~= "left" then
                    candidates[#candidates + 1] = {ghost.xTile+1, ghost.yTile}
                end
                ghost.latestCandidateCount = #candidates
                
                local function setDirection(from, to, prefix)
                    local dir, msg
                    if to[1] < from.xTile then
                        dir, msg = "left", "went left"
                    elseif to[1] > from.xTile then
                        dir, msg = "right", "went right"
                    elseif to[2] < from.yTile then
                        dir, msg = "up", "went up"
                    elseif to[2] > from.yTile then
                        dir, msg = "down", "went down"
                    end
                    if dir then
                        from.report = "Entered tile "..newXTile.."/"..newYTile..", " .. prefix .. msg
                        from.nextDir = dir
                    end
                end
    
                if (ghost.mode == "chase" or ghost.mode == "scatter" or ghost.mode == "dead") then
                    local closest
                    local closestDist = math.huge
                    for _, cand in ipairs(candidates) do
                        local dx = cand[1] - ghost.targetX
                        local dy = cand[2] - ghost.targetY
                        local dist = dx * dx + dy * dy -- distance squared for efficiency
                        if dist < closestDist then
                            closestDist = dist
                            closest = cand
                        end
                    end
                    if closest then
                        setDirection(ghost, closest, "decided to ")
                    end
                elseif ghost.mode == "frightened" then
                    local idx = math.random(1, #candidates)
                    local chosen = candidates[idx]
                    setDirection(ghost, chosen, "randomly ")
                end
            end
        end
        
        if (not dotEaten) then
            if (pac.direction == "left") then
                pac.x = pac.x - pac.speed;
                if (maze[pac.yTile][pac.xTile - 1] ~= 1) then
                    if (pac.x % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                        pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                    end
                end             
            end
        
            if (pac.direction == "right") then
                pac.x = pac.x + pac.speed;
                if (maze[pac.yTile][pac.xTile + 1] ~= 1) then
                    if (pac.x % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                        pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                    end
                end             
            end

            if (pac.direction == "up") then
                pac.y = pac.y - pac.speed;
                if (maze[pac.yTile - 1][pac.xTile] ~= 1) then
                    if (pac.y % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                        pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                    end
                end             
            end

            if (pac.direction == "down") then
                pac.y = pac.y + pac.speed;
                if (maze[pac.yTile + 1][pac.xTile] ~= 1) then
                    if (pac.y % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                        pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                    end
                end             
            end

            if pressedKeys["left"] then
                if (pac.direction == "right") then
                    pac.direction = "left"
                elseif (pac.y % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.y % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and maze[pac.yTile][pac.xTile-1] == 1) then
                    pac.direction = "left"
                    pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                end
            elseif pressedKeys["right"] then
                if (pac.direction == "left") then
                    pac.direction = "right"
                elseif (pac.y % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.y % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and maze[pac.yTile][pac.xTile+1] == 1) then
                    pac.direction = "right"
                    pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                end
            elseif pressedKeys["up"] then
                if (pac.direction == "down") then
                    pac.direction = "up"
                elseif (pac.x % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.x % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and maze[pac.yTile-1][pac.xTile] == 1) then
                    pac.direction = "up"
                    pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                end
            elseif pressedKeys["down"] then
                if (pac.direction == "up") then
                    pac.direction = "down"
                elseif (pac.x % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.x % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and maze[pac.yTile+1][pac.xTile] == 1) then
                    pac.direction = "down"
                    pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                end
            end
        end


        timer.ghostMode = timer.ghostMode + dt
    end
    -- Update animation timers
    timer.powerBlink = (timer.powerBlink + dt) % 0.30

end

function love.draw()
    Renderer.drawMaze(maze, renderConfig)
    love.graphics.setColor(.9, .9, .9);
    
    for _,dot in ipairs(dots) do
        love.graphics.rectangle("fill", ((dot[1] - 1) * TILE_SIZE + TILE_SIZE / 2) - PIXEL_SIZE, ((dot[2] - 1) * TILE_SIZE + TILE_SIZE / 2) - PIXEL_SIZE, PIXEL_SIZE * 2, PIXEL_SIZE * 2);
    end
    
    if (timer.powerBlink < .15) then
        for _,powerPellet in ipairs(powerPellets) do
            love.graphics.circle("fill", (powerPellet[1] - 1) * TILE_SIZE + TILE_SIZE / 2, (powerPellet[2] - 1) * TILE_SIZE + TILE_SIZE / 2, PIXEL_SIZE * 4);
        end
    end

    if #dots == 0 then
        local winText = "OMG YOU WINNED!111!1"
        local fontSize = 48
        local font = love.graphics.newFont(fontSize)
        love.graphics.setFont(font)
        local textWidth = font:getWidth(winText)
        local textHeight = font:getHeight()
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.print(
            winText, 
            (windowWidth - textWidth) / 2, 
            (windowHeight - textHeight) / 2
        )
        love.graphics.setColor(1, 1, 1, 1)
    end

    if (not gameState.ateGhost) then
        Renderer.drawPacman(pac, renderConfig)
    else
        love.graphics.setColor(1,1,1);
        love.graphics.print("CHOMP!!", (pac.xTile - 1) * TILE_SIZE, pac.yTile * TILE_SIZE - (TILE_SIZE/2));
    end
    Renderer.drawGhosts(ghosts, renderConfig);



    if (DEBUG) then
        love.graphics.setColor(1,1,1);
        local colTile, rowTile = pixelToTile(pac.x, pac.y);
        if maze[rowTile][colTile] == 1 then
            love.graphics.setColor(.1,1,.1,.5);
            love.graphics.rectangle("fill", (colTile - 1) * TILE_SIZE, (rowTile - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        end
        for i, ghost in ipairs(ghosts) do
            love.graphics.setColor(ghost.color[1], ghost.color[2], ghost.color[3], .5);
            --love.graphics.rectangle("fill", (ghost.targetX - 1) * TILE_SIZE, (ghost.targetY - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
            love.graphics.setColor(1,1,1);
            love.graphics.print(ghost.name, 10, i*150)
            love.graphics.print('x/y: ' .. ghost.x .. "/" .. ghost.y, 10, i*150 + 15)
            --love.graphics.print('xTile/yTile: ' .. ghost.xTile .. "/" .. ghost.yTile, 10, i*150 + 30)
            --love.graphics.print('targetX/targetY: ' .. ghost.targetX .. "/" .. ghost.targetY, 10, i*150 + 45)
            love.graphics.print('direction: ' .. ghost.direction, 10, i*150 + 60)
            if(ghost.nextDir) then
                love.graphics.print('nextDir: ' .. ghost.nextDir, 10, i*150 + 75)
            end
            love.graphics.print('mode: ' .. ghost.mode, 10, i*150 + 90)
            if(ghost.report) then
                love.graphics.print('Report: ' .. ghost.report, 10, i*150 + 105)
            end

        end
    end
end

function mazeVal(row, col)
    if row < 1 or col < 1 or row > #maze or col > #maze[1] then
        return 0
    end
    return maze[row][col]
end