local DEBUG=false

local PIXEL_SIZE= 3
local TILE_SIZE = PIXEL_SIZE * 8
local WALL_PADDING = 1
local PELLET_RADIUS = 2
local POWER_RADIUS = 5
local PIXELS_PER_TILE = 8
local Renderer = require("renderer")
local Maze = require("maze")
local timer = { powerBlink = 0 }

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
    xTile = 0,
    yTile = 0,
    speed = 1,
    direction = "none",
}

local function getTile(row, col)
    local line = maze[row]
    if not line then
        return nil
    end
    return line:sub(col, col)
end

local function isWall(row, col)
    return getTile(row, col) == "#"
end

function love.load()
    love.window.setTitle("Pinbac-Man")
    love.window.setMode(windowWidth, windowHeight, {resizable = false})
    love.graphics.setBackgroundColor(colors.background)
end

local pressedKeys = {}

function love.keypressed(key)
    pressedKeys[key] = true
end

function love.keyreleased(key)
    pressedKeys[key] = false
end

function love.update(dt)
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
            if (pac.direction == "right" or (pac.y % PIXELS_PER_TILE == PIXELS_PER_TILE / 2 and maze[pac.yTile][pac.xTile-1] == 1)) then
                pac.direction = "left"
            end
        elseif pressedKeys["right"] then
            if (pac.direction == "left" or (pac.y % PIXELS_PER_TILE == PIXELS_PER_TILE / 2 and maze[pac.yTile][pac.xTile+1] == 1)) then
                pac.direction = "right"
            end
        elseif pressedKeys["up"] then
            if (pac.direction == "down" or (pac.x % PIXELS_PER_TILE == PIXELS_PER_TILE / 2 and maze[pac.yTile - 1][pac.xTile] == 1)) then
                pac.direction = "up"
            end
        elseif pressedKeys["down"] then
            if (pac.direction == "up" or (pac.x % PIXELS_PER_TILE == PIXELS_PER_TILE / 2 and maze[pac.yTile + 1][pac.xTile] == 1)) then
                pac.direction = "down"
            end
        end
    end

    -- Update animation timers
    timer.powerBlink = (timer.powerBlink + dt) % 0.30

end

function love.draw()
    Renderer.drawMaze(maze, renderConfig)
    Renderer.drawPacman(pac, renderConfig)

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
    if (DEBUG) then
        local colTile, rowTile = pixelToTile(pac.x, pac.y);
        love.graphics.print("Pac tile: " .. colTile .. "." .. rowTile, 10, 300);
        love.graphics.print("Dots left: " .. #dots, 10, 310)
        if maze[rowTile][colTile] == 1 then
            love.graphics.setColor(1,.1,.1,.5);
            love.graphics.rectangle("fill", (colTile - 1) * TILE_SIZE, (rowTile - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE);
        end
    end
end

function mazeVal(row, col)
    if row < 1 or col < 1 or row > #maze or col > #maze[1] then
        return 0
    end
    return maze[row][col]
end