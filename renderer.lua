local renderer = {}

function renderer.drawWallTile(row, col, config)
    local tileSize = config.tileSize
    local wallPadding = config.wallPadding
    local colors = config.colors

    local x = (col - 1) * tileSize
    local y = (row - 1) * tileSize
    love.graphics.setColor(colors.wall)
    love.graphics.rectangle(
        "fill",
        x + wallPadding,
        y + wallPadding,
        tileSize - wallPadding * 2,
        tileSize - wallPadding * 2
    )
end

function renderer.drawPellet(row, col, config)
    local tileSize = config.tileSize
    local pelletRadius = config.pelletRadius
    local colors = config.colors

    local x = (col - 0.5) * tileSize
    local y = (row - 0.5) * tileSize
    love.graphics.setColor(colors.pellet)
    love.graphics.circle("fill", x, y, pelletRadius)
end

function renderer.drawPowerPellet(row, col, config)
    local tileSize = config.tileSize
    local powerRadius = config.powerRadius
    local colors = config.colors

    local x = (col - 0.5) * tileSize
    local y = (row - 0.5) * tileSize
    love.graphics.setColor(colors.power)
    love.graphics.circle("fill", x, y, powerRadius)
end

function renderer.drawMaze(maze, config)
    local rows = #maze
    local cols = #maze[1]
    local colors = config.colors;
    local tileSize = config.tileSize;

    for row = 1, rows do
        for col = 1, cols do
            local tile = maze[row][col]
            if tile == 2 then 
                love.graphics.setColor(.5,0,0);
                love.graphics.line((col-1) * tileSize, (row-1) * tileSize, (col-1) * tileSize + tileSize, (row-1) * tileSize + tileSize)
                love.graphics.line((col-1) * tileSize + tileSize, (row-1) * tileSize, (col-1) * tileSize, (row * tileSize))
            end
            if tile ~= 1 and tile ~= 2 then
                if mazeVal(row-1, col) == 1 or mazeVal(row-1,col) == 2 or mazeVal(row+1, col) == 1 or mazeVal(row+1,col) == 2 then
                    if mazeVal(row, col-1) == 0 or mazeVal(row, col-1) == 3 then
                        if mazeVal(row, col) == 0 then
                            love.graphics.setColor(colors.wall)
                        else
                            love.graphics.setColor(.9, .5, .9)
                        end
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x, y + tileSize / 2                   -- middle-left of tile
                        )
                    end
                    if mazeVal(row, col+1) == 0 or mazeVal(row, col+1) == 3 then
                        if mazeVal(row, col) == 0 then
                            love.graphics.setColor(colors.wall)
                        else
                            love.graphics.setColor(.9, .5, .9)
                        end
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x + tileSize, y + tileSize / 2                   -- middle-left of tile
                        )
                    end
                end
                if mazeVal(row, col-1) == 1 or mazeVal(row,col-1) == 2 or mazeVal(row, col+1) == 1 or mazeVal(row,col+1) == 2 then
                    if mazeVal(row - 1, col) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x + tileSize / 2, y                   -- middle-left of tile
                        )
                    end
                    if mazeVal(row + 1, col) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x + tileSize / 2, y + tileSize                   -- middle-left of tile
                        )
                    end
                end
                if mazeVal(row-1, col-1) == 1 or mazeVal(row-1,col-1) == 2 then
                    if mazeVal(row - 1, col) == 0 and mazeVal(row, col-1) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x + tileSize / 2, y                   -- middle-left of tile
                        )
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,   -- middle of tile
                            x, y + tileSize / 2                   -- middle-left of tile
                        )
                    end
                end
                -- Top-right corner (already present, keep)
                if mazeVal(row-1, col+1) == 1 or mazeVal(row-1, col+1) == 2 then
                    if mazeVal(row - 1, col) == 0 and mazeVal(row, col + 1) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x + tileSize / 2, y
                        )
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x + tileSize, y + tileSize / 2
                        )
                    end
                end

                -- Bottom-left corner
                if mazeVal(row+1, col-1) == 1 or mazeVal(row+1, col-1) == 2 then
                    if mazeVal(row + 1, col) == 0 and mazeVal(row, col - 1) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x + tileSize / 2, y + tileSize
                        )
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x, y + tileSize / 2
                        )
                    end
                end

                -- Bottom-right corner
                if mazeVal(row+1, col+1) == 1 or mazeVal(row+1, col+1) == 2 then
                    if mazeVal(row + 1, col) == 0 and mazeVal(row, col + 1) == 0 then
                        love.graphics.setColor(colors.wall)
                        local tileSize = config.tileSize
                        local x = (col - 1) * tileSize
                        local y = (row - 1) * tileSize
                        love.graphics.setLineWidth(3)
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x + tileSize / 2, y + tileSize
                        )
                        love.graphics.line(
                            x + tileSize / 2, y + tileSize / 2,
                            x + tileSize, y + tileSize / 2
                        )
                    end
                end
            end
        end
    end
end

function renderer.drawGhosts(ghosts, config)
    local tileSize = config.tileSize
    local pixelSize = config.pixelSize

    for i,ghost in ipairs(ghosts) do
        if (ghost.mode ~= "dead") then
            if (ghost.mode == "frightened") then
                love.graphics.setColor(.3,.3,1);
            else 
                love.graphics.setColor(ghost.color[1], ghost.color[2], ghost.color[3]);
            end
            love.graphics.rectangle("fill", ghost.x * pixelSize - (tileSize * .75), ghost.y * pixelSize - (tileSize * .75), tileSize * 1.5, tileSize * 1.5);
        end
        if (gameState.ateGhost ~= ghost.name) then
            love.graphics.setColor(1,1,1);
            love.graphics.circle("fill", ghost.x * pixelSize - (tileSize / 3), ghost.y * pixelSize - (tileSize / 3), tileSize * .3);
            love.graphics.circle("fill", ghost.x * pixelSize + (tileSize / 3), ghost.y * pixelSize - (tileSize / 3), tileSize * .3);
            love.graphics.setColor(0,0,0);
            love.graphics.circle("fill", ghost.x * pixelSize - (tileSize / 3), ghost.y * pixelSize - (tileSize / 3), tileSize * .15);
            love.graphics.circle("fill", ghost.x * pixelSize + (tileSize / 3), ghost.y * pixelSize - (tileSize / 3), tileSize * .15);
        end
    end
end

function renderer.drawPacman(pac, config)
    local tileSize = config.tileSize
    local colors = config.colors

    -- Get a random number between 0 and 50
    local x = (pac.x) * config.pixelSize
    local y = (pac.y) * config.pixelSize
    local radius = tileSize * .8
    local mouthAngle = math.abs(math.rad((timer.t % .15) * 600) -.50)

    -- Determine rotation based on direction
    local direction = pac.direction or "left"
    local rotation = math.pi
    if direction == "left" then
        rotation = math.pi
    elseif direction == "right" then
        rotation = 0
    elseif direction == "up" then
        rotation = -math.pi / 2
    elseif direction == "down" then
        rotation = math.pi / 2
    end

    love.graphics.setColor(colors.pacman)
    love.graphics.arc(
        "fill",
        x, y,
        radius,
        mouthAngle + rotation,
        (math.pi * 2) - mouthAngle + rotation
    )

end

return renderer

