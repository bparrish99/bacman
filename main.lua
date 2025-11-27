DEBUG=false
PIXEL_SIZE=2
TILE_SIZE = PIXEL_SIZE * 8
WALL_PADDING = 1
PELLET_RADIUS = 2
POWER_RADIUS = 5
PIXELS_PER_TILE = 8
Renderer = require("renderer")
Maze = require("maze")
Setup = require("setup")

timer = { powerBlink = 0, ghostMode = 0, t = 0 }

gameState = {
    mode = "attract",
    highScore = 0
}
-- Convert pixel coordinates to tile coordinates (1-indexed)
function pixelToTile(x, y)
    local col = math.floor(x / PIXELS_PER_TILE) + 1
    local row = math.floor(y / PIXELS_PER_TILE) + 1
    return col, row
end

-- Load maze data from separate module
local maze = Maze.layout
local dots = Maze.dots()
local powerPellets = Maze.powerPellets()

local rows = #maze
local cols = #maze[1]
local windowWidth = cols * TILE_SIZE
local windowHeight = rows * TILE_SIZE

local function isWall(row, col)
    return getTile(row, col) == "#"
end

function love.load()
    love.window.setTitle("Pinbac-Man")
    love.window.setMode(windowWidth, windowHeight, {resizable = false})
    love.graphics.setBackgroundColor({.05, .05, .1})
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
    if (gameState.mode == "attract") then 
        if pressedKeys["z"] then
            gameState.mode = "playing"
            colors, renderConfig, pac, ghosts, dots, powerPellets = Setup.startGame()
        end
    else

        timer.t = timer.t + dt
        pac.moved = false
        local oldScore = gameState.score
        if gameState.halted then
            if (timer.gameover and timer.gameover > 0) then
                timer.gameover = timer.gameover - dt
                if timer.gameover <= 0 then
                    gameState.mode = "attract"
                end
            end
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
                        ghost.speed = 0.85
                    end
                    timer.startup = 2
                    for i, ghost in ipairs(ghosts) do
                        ghost.mode = "scatter"
                    end
                    timer.ghostMode = 0
                    
                    -- New round
                    if #dots == 0 and #powerPellets == 0 then
                        dots = Maze.dots()
                        powerPellets = Maze.powerPellets()
                        gameState.betweenRounds = false
                        gameState.level = gameState.level + 1
                    end
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
            if (timer.roundOver and timer.roundOver > 0) then
                timer.roundOver = timer.roundOver - dt
                if timer.roundOver <= 0 then timer.restart = 1 end
            end
        else

            -- tunnel
            if pac.x < PIXELS_PER_TILE and pac.direction == "left" then pac.x = (#maze[1]-1)*PIXELS_PER_TILE end
            if pac.x > (#maze[1]-1)*PIXELS_PER_TILE and pac.direction == "right" then pac.x=PIXELS_PER_TILE end

            
            -- animation or future logic hooks could go here
            local dotEaten = false;
            pacXTile, pacYTile = pixelToTile(pac.x, pac.y);

            if (pacXTile ~= pac.xTile or pacYTile ~= pac.yTile) then -- pac-man in new tile
                pac.xTile = pacXTile;
                pac.yTile = pacYTile;

                for i, dot in ipairs(dots) do
                    if dot[1] == pacXTile and dot[2] == pacYTile then
                        table.remove(dots, i);
                        gameState.score = gameState.score + 10;
                        dotEaten = true;
                    end
                end
                for i, powerPellet in ipairs(powerPellets) do
                    if powerPellet[1] == pacXTile and powerPellet[2] == pacYTile then
                        table.remove(powerPellets, i);
                        gameState.score = gameState.score + 50;
                        dotEaten = true;
                        for i, ghost in ipairs(ghosts) do
                            gameState.ghostValue = 200
                            if ghost.mode ~= "dead" then 
                                ghost.mode = "frightened"
                                ghost.speed = .5
                                if ghost.direction == "left" then ghost.direction = "right"
                                elseif ghost.direction == "right" then ghost.direction = "left"
                                elseif ghost.direction == "up" then ghost.direction = "down"
                                else ghost.direction = "up"
                                end
                            end
                        end
                        timer.ghostMode = 1 -- right now, this should force 8 seconds, refactor
                    end
                end
            end

            -- Is round clear?
            if #dots == 0 and #powerPellets == 0 then
                timer.roundOver = 2.5
                gameState.halted = true
                gameState.betweenRounds = true
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
                    if ghost.mode == "chase" or ghost.mode == "frightened" then 
                        ghost.mode = "scatter"
                        ghost.speed = .85
                    elseif ghost.mode == "scatter" then 
                        ghost.mode = "chase"
                        ghost.speed = .85
                    end
                end
            end
        
            for i, ghost in ipairs(ghosts) do

                -- tunnel
                if ghost.x < PIXELS_PER_TILE and ghost.direction == "left" then ghost.x = (#maze[1]-1)*PIXELS_PER_TILE end
                if ghost.x > (#maze[1]-1)*PIXELS_PER_TILE and ghost.direction == "right" then ghost.x=PIXELS_PER_TILE end
                ghost.xTile, ghost.yTile = pixelToTile(ghost.x, ghost.y)
        
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
                        if ((maze[ghost.yTile][ghost.xTile - 1] ~= 1 and maze[ghost.yTile][ghost.xTile - 1] ~= 2) or ghost.nextDir == "up" or ghost.nextDir == "down") then
                            ghost.x = ghost.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                            ghost.direction = ghost.nextDir
                        end
                    end  
                elseif ghost.direction == "right" then
                    ghost.x = ghost.x + ghost.speed
                    if (ghost.x % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                        if ((maze[ghost.yTile][ghost.xTile + 1] ~= 1 and maze[ghost.yTile][ghost.xTile + 1] ~= 2) or ghost.nextDir == "up" or ghost.nextDir == "down") then
                            ghost.x = ghost.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                            ghost.direction = ghost.nextDir
                        end
                    end  
                elseif ghost.direction == "up" then
                    ghost.y = ghost.y - ghost.speed
                    if (ghost.y % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                        if ((maze[ghost.yTile - 1][ghost.xTile] ~= 1 and maze[ghost.yTile - 1][ghost.xTile] ~= 2) or ghost.nextDir == "left" or ghost.nextDir == "right") then
                            ghost.y = ghost.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                            ghost.direction = ghost.nextDir
                        end
                    end  
                elseif ghost.direction == "down" then
                    ghost.y = ghost.y + ghost.speed
                    if (ghost.y % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                        if ((maze[ghost.yTile + 1][ghost.xTile] ~= 1 and maze[ghost.yTile + 1][ghost.xTile] ~= 2) or ghost.nextDir == "left" or ghost.nextDir == "right") then
                            ghost.y = ghost.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                            ghost.direction = ghost.nextDir
                        end
                    end  
                end
                local newXTile, newYTile = pixelToTile(ghost.x, ghost.y)
                if maze[ghost.yTile][ghost.xTile] == 1 and maze[newYTile][newXTile] == 2 and ghost.mode ~= "dead" then
                    ghost.preTunnelSpeed = ghost.speed
                    ghost.speed = .5
                end
                if maze[ghost.yTile][ghost.xTile] == 2 and maze[newYTile][newXTile] == 1 and ghost.speed == .5 then
                    ghost.speed = ghost.preTunnelSpeed
                end
                local startXTile, startYTile = pixelToTile(ghost.startX, ghost.startY)
                if ghost.mode == "dead" and newXTile == startXTile and newYTile == startYTile then
                    ghost.mode = "chase"
                    ghost.speed=.85
                end

                -- check for eating or been eaten
                if newXTile == pac.xTile and newYTile == pac.yTile then
                    if ghost.mode == "frightened" and not gameState.ateGhost then
                        ghost.direction = "left"
                        gameState.halted = true
                        gameState.ateGhost = ghost.name
                        ghost.mode = "dead"
                        ghost.speed = 2
                        timer.ateGhost = 1
                        gameState.score = gameState.score + gameState.ghostValue
                        gameState.ghostValue = gameState.ghostValue * 2
                    elseif ghost.mode ~= "dead" then -- ate pacman
                        gameState.halted = true
                        gameState.lives = gameState.lives - 1
                        if gameState.lives == 0 then
                            if gameState.score > gameState.highScore then gameState.highScore = gameState.score end
                            gameState.mode = "gameover"
                            timer.gameover = 2
                        else
                            timer.restart = 2
                        end
                    end
                end
                if (newXTile ~= ghost.xTile or newYTile ~= ghost.yTile) then
                    ghost.xTile = newXTile
                    ghost.yTile = newYTile
                    local candidates = {}
                    if (maze[ghost.yTile - 1][ghost.xTile] == 1 or maze[ghost.yTile - 1][ghost.xTile] == 2)and ghost.direction ~= "down" then
                        candidates[#candidates + 1] = {ghost.xTile, ghost.yTile-1}
                    end
                    if (maze[ghost.yTile + 1][ghost.xTile] == 1 or maze[ghost.yTile + 1][ghost.xTile] == 2) and ghost.direction ~= "up" then
                        candidates[#candidates + 1] = {ghost.xTile, ghost.yTile+1}
                    end
                    if (maze[ghost.yTile][ghost.xTile - 1] == 1 or maze[ghost.yTile][ghost.xTile - 1] == 2) and ghost.direction ~= "right" then
                        candidates[#candidates + 1] = {ghost.xTile-1, ghost.yTile}
                    end
                    if (maze[ghost.yTile][ghost.xTile + 1] == 1 or maze[ghost.yTile][ghost.xTile + 1] == 2) and ghost.direction ~= "left" then
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
                        -- In tunnels or corners it's possible to have no valid candidate tiles.
                        -- Guard against that so we don't pass a nil target to setDirection.
                        if #candidates > 0 then
                            local idx = math.random(1, #candidates)
                            local chosen = candidates[idx]
                            if chosen then
                                setDirection(ghost, chosen, "randomly ")
                            end
                        end
                    end
                end
            end
            
            local oldX, oldY = pac.x, pac.y
            if (not dotEaten) then
                if (pac.direction == "left") then
                    pac.x = pac.x - pac.speed;
                    if (maze[pac.yTile][pac.xTile - 1] ~= 1 and maze[pac.yTile][pac.xTile -1] ~= 2) then
                        if (pac.x % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                            pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        end
                    end             
                end
            
                if (pac.direction == "right") then
                    pac.x = pac.x + pac.speed;
                    if (maze[pac.yTile][pac.xTile + 1] ~= 1 and maze[pac.yTile][pac.xTile +1] ~= 2) then
                        if (pac.x % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                            pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        end
                    end             
                end

                if (pac.direction == "up") then
                    pac.y = pac.y - pac.speed;
                    if (maze[pac.yTile - 1][pac.xTile] ~= 1 and maze[pac.yTile-1][pac.xTile] ~= 2) then
                        if (pac.y % PIXELS_PER_TILE <= PIXELS_PER_TILE / 2) then 
                            pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        end
                    end             
                end

                if (pac.direction == "down") then
                    pac.y = pac.y + pac.speed;
                    if (maze[pac.yTile + 1][pac.xTile] ~= 1 and maze[pac.yTile + 1][pac.xTile] ~= 2) then
                        if (pac.y % PIXELS_PER_TILE >= PIXELS_PER_TILE / 2) then 
                            pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2);
                        end
                    end             
                end

                if pressedKeys["left"] then
                    if (pac.direction == "right") then
                        pac.direction = "left"
                    elseif (pac.y % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.y % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and (maze[pac.yTile][pac.xTile-1] == 1 or maze[pac.yTile][pac.xTile-1] == 2)) then
                        pac.direction = "left"
                        pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                    end
                elseif pressedKeys["right"] then
                    if (pac.direction == "left") then
                        pac.direction = "right"
                    elseif (pac.y % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.y % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and (maze[pac.yTile][pac.xTile+1] == 1 or maze[pac.yTile][pac.xTile+1] == 2)) then
                        pac.direction = "right"
                        pac.y = pac.yTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                    end
                elseif pressedKeys["up"] then
                    if (pac.direction == "down") then
                        pac.direction = "up"
                    elseif (pac.x % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.x % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and (maze[pac.yTile-1][pac.xTile] == 1 or maze[pac.yTile-1][pac.xTile] == 2)) then
                        pac.direction = "up"
                        pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                    end
                elseif pressedKeys["down"] then
                    if (pac.direction == "up") then
                        pac.direction = "down"
                    elseif (pac.x % PIXELS_PER_TILE > (PIXELS_PER_TILE / 2 - pac.speed / 1) and pac.x % PIXELS_PER_TILE < (PIXELS_PER_TILE / 2 + pac.speed /1) and (maze[pac.yTile+1][pac.xTile] == 1 or maze[pac.yTile+1][pac.xTile] == 2)) then
                        pac.direction = "down"
                        pac.x = pac.xTile * PIXELS_PER_TILE - (PIXELS_PER_TILE / 2)
                    end
                end
                if pac.x ~= oldX or pac.y ~= oldY then pac.moved = true end

                
            end


            timer.ghostMode = timer.ghostMode + dt
        end
        -- Update animation timers
        timer.powerBlink = (timer.powerBlink + dt) % 0.30
        if oldScore < 10000 and gameState.score >= 10000 then
            gameState.lives = gameState.lives + 1
        end
    end
end

function love.draw()

    if (gameState.mode == "attract") then

        -- Make the background pulse with a dark purple color in attract mode (about 4x faster)
        local pulseTime = love.timer.getTime() * 1.4 * 4
        local pulse = (math.sin(pulseTime) + 1)
        local base_r, base_g, base_b = 0.07, 0.03, 0.11
        local max_r, max_g, max_b = 0.13, 0.06, 0.22
        local r = base_r + (max_r - base_r) * pulse
        local g = base_g + (max_g - base_g) * pulse
        local b = base_b + (max_b - base_b) * pulse
        love.graphics.clear(r, g, b)

        -- Animate a vertical bounce for attract mode elements
        local bounce = math.sin(love.timer.getTime() * 2) * 80

        local logo = love.graphics.newImage("logo.png")
        local logoWidth = logo:getWidth()
        local logoHeight = logo:getHeight()
        local logoScale = windowWidth / (logoWidth * 2)
        local logoX = (windowWidth - logoWidth * logoScale) / 2
        local logoYBase = (windowHeight * .8 - logoHeight * logoScale) / 2
        local logoY = logoYBase + bounce
        love.graphics.setColor(1,1,1)
        love.graphics.draw(logo, logoX, logoY, 0, logoScale, logoScale)
        love.graphics.setColor(math.random(), math.random(), math.random())
        local scoreFont = love.graphics.newFont(PIXEL_SIZE * 12)
        love.graphics.setFont(scoreFont)
        local message = "Press Z to start game"
        local textWidth = scoreFont:getWidth(message)
        local textYBase = windowHeight / 2 + 50
        local x = (windowWidth / 2) - (textWidth / 2)
        local textY = textYBase + bounce
        love.graphics.print(message, x, textY)
    else
        local originalMazeColor = renderConfig.colors.wall
        local mazeColor = renderConfig.colors.wall
        if timer.roundOver then
            if timer.roundOver > 1 then mazeColor = originalMazeColor
            elseif timer.roundOver > .7 then mazeColor = {1,1,1}
            elseif timer.roundOver > .4 then mazeColor = originalMazeColor
            elseif timer.roundOver > .1 then mazeColor = {1,1,1}
            end

        end
        renderConfig.colors.wall = mazeColor
        Renderer.drawMaze(maze, renderConfig)
        renderConfig.colors.wall = originalMazeColor;
        love.graphics.setColor(.9, .6, .3);
        
        for _,dot in ipairs(dots) do
            love.graphics.rectangle("fill", ((dot[1] - 1) * TILE_SIZE + TILE_SIZE / 2) - PIXEL_SIZE, ((dot[2] - 1) * TILE_SIZE + TILE_SIZE / 2) - PIXEL_SIZE, PIXEL_SIZE * 2, PIXEL_SIZE * 2);
        end
        
        if (timer.powerBlink < .15) then
            for _,powerPellet in ipairs(powerPellets) do
                love.graphics.circle("fill", (powerPellet[1] - 1) * TILE_SIZE + TILE_SIZE / 2, (powerPellet[2] - 1) * TILE_SIZE + TILE_SIZE / 2, PIXEL_SIZE * 4);
            end
        end

        if (not gameState.ateGhost) then
            Renderer.drawPacman(pac, renderConfig)
        else
            love.graphics.setColor(1,1,1);
            local scoreFont = love.graphics.newFont(PIXEL_SIZE * 6)
            love.graphics.setFont(scoreFont)
            love.graphics.print(gameState.ghostValue / 2, (pac.xTile - 1.2) * TILE_SIZE, pac.yTile * TILE_SIZE - (TILE_SIZE));
        end
        
        if (not gameState.betweenRounds or timer.roundOver > 1) then 
            Renderer.drawGhosts(ghosts, renderConfig);
        end

        love.graphics.setScissor()
        -- Start a font where each letter is TILE_SIZE high and wide
        if not font or font:getHeight() ~= TILE_SIZE then
            font = love.graphics.newFont(TILE_SIZE * 2)
            love.graphics.setFont(font)
        end

        -- scores
        love.graphics.setColor(.5,1,.5);
        love.graphics.print(gameState.score, TILE_SIZE * 3, PIXEL_SIZE)
        love.graphics.setColor(1,.8,.8);
        love.graphics.print(gameState.highScore, TILE_SIZE * (#maze[1]/1.5), PIXEL_SIZE)
        love.graphics.setColor(.2,.2,1);
        love.graphics.print(Maze.getLevelConfig(gameState.level).fruit.name, TILE_SIZE * (#maze[1]/1.5), (#maze - 2) * TILE_SIZE - (PIXEL_SIZE * 4))

        -- lives left
        local mouthAngle = math.rad(50)

        love.graphics.setColor(colors.pacman)
        for i = 1, gameState.lives - 1 do
            love.graphics.arc(
                "fill",
                TILE_SIZE * (2 + i*2), (#maze - 1) * TILE_SIZE,
                TILE_SIZE * .8,
                mouthAngle,
                (math.pi * 2) - mouthAngle
            )
        end

        if (DEBUG) then
            local colTile, rowTile = pixelToTile(pac.x, pac.y);
            love.graphics.setColor(1,1,1);
            love.graphics.print(colTile .. "/" .. rowTile, 100,100)
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
        if (gameState.mode == "gameover") then
            love.graphics.setColor(math.random(), math.random(), math.random())
            local goText = "GAME OVER"
            local font = love.graphics.newFont(TILE_SIZE * 2)
            love.graphics.setFont(font)
            local textWidth = font:getWidth(goText)
            local textHeight = font:getHeight()
            love.graphics.print(
                goText,
                (windowWidth - textWidth) / 2,
                (windowHeight - textHeight) / 2 + TILE_SIZE * 2
            )
            love.graphics.setFont(love.graphics.getFont()) -- reset if needed
        end
    end
end

function mazeVal(row, col)
    if row < 1 or col < 1 or row > #maze or col > #maze[1] then
        return 0
    end
    return maze[row][col]
end