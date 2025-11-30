local maze = {}

-- 0 = wall, 1 = pellet, 2 = empty, 3 = power pellet
maze.layout = {
    {9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
    {9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9},
    {9,9,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,1,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0,9,9},
    {9,9,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,9,9},
    {9,9,9,9,9,9,9,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,0,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,0,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,0,1,0,0,1,0,0,0,3,3,0,0,0,1,0,0,1,0,9,9,9,9,9,9,9},
    {0,0,0,0,0,0,0,0,1,0,0,1,0,1,1,1,1,1,1,0,1,0,0,1,0,0,0,0,0,0,0,0},
    {2,2,2,2,2,2,2,2,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,2,2,2,2,2,2,2,2},
    {0,0,0,0,0,0,0,0,1,0,0,1,0,1,1,1,1,1,1,0,1,0,0,1,0,0,0,0,0,0,0,0},
    {9,9,9,9,9,9,9,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,0,1,0,0,1,1,1,1,1,1,1,1,1,1,0,0,1,0,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,9,9,9,9,9,9,9},
    {9,9,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,9,9},
    {9,9,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,0,0,0,0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,1,0,9,9},
    {9,9,0,1,1,1,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,0,9,9},
    {9,9,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,9,9},
    {9,9,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,0,0,0,9,9},
    {9,9,0,1,1,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0,9,9},
    {9,9,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,9,9},
    {9,9,0,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0,9,9},
    {9,9,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,9,9},
    {9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9},
    {9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
    {9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9},
}

maze.dots = function() 
    return {
    {4,4},{5,4},{6,4},{7,4},{8,4},{9,4},{10,4},{11,4},{12,4},{13,4},{14,4},{15,4},{18,4},{19,4},{20,4},{21,4},{22,4},{23,4},{24,4},{25,4},{26,4},{27,4},{28,4},{29,4},
    {4,5},{9,5},{15,5},{18,5},{24,5},{29,5},
    {9,6},{15,6},{18,6},{24,6},
    {4,7},{9,7},{15,7},{18,7},{24,7},{29,7},
    {4,8},{5,8},{6,8},{7,8},{8,8},{9,8},{10,8},{11,8},{12,8},{13,8},{14,8},{15,8},{16,8},{17,8},{18,8},{19,8},{20,8},{21,8},{22,8},{23,8},{24,8},{25,8},{26,8},{27,8},{28,8},{29,8},
    {4,9},{9,9},{12,9},{21,9},{24,9},{29,9},
    {4,10},{9,10},{12,10},{21,10},{24,10},{29,10},
    {4,11},{5,11},{6,11},{7,11},{8,11},{9,11},{12,11},{13,11},{14,11},{15,11},{18,11},{19,11},{20,11},{21,11},{24,11},{25,11},{26,11},{27,11},{28,11},{29,11},
    {9,12},{24,12},
    {9,13},{24,13},
    {9,14},{24,14},
    {9,15},{24,15},
    {9,16},{24,16},
    {9,17},{24,17},
    {9,18},{24,18},
    {9,19},{24,19},
    {9,20},{24,20},
    {9,21},{24,21},
    {9,22},{24,22},
    {4,23},{5,23},{6,23},{7,23},{8,23},{9,23},{10,23},{11,23},{12,23},{13,23},{14,23},{15,23},{18,23},{19,23},{20,23},{21,23},{22,23},{23,23},{24,23},{25,23},{26,23},{27,23},{28,23},{29,23},
    {4,24},{9,24},{15,24},{18,24},{24,24},{29,24},
    {4,25},{9,25},{15,25},{18,25},{24,25},{29,25},
    {5,26},{6,26},{9,26},{10,26},{11,26},{12,26},{13,26},{14,26},{15,26},{18,26},{19,26},{20,26},{21,26},{22,26},{23,26},{24,26},{27,26},{28,26},
    {6,27},{9,27},{12,27},{21,27},{24,27},{27,27},
    {6,28},{9,28},{12,28},{21,28},{24,28},{27,28},
    {4,29},{5,29},{6,29},{7,29},{8,29},{9,29},{12,29},{13,29},{14,29},{15,29},{18,29},{19,29},{20,29},{21,29},{24,29},{25,29},{26,29},{27,29},{28,29},{29,29},
    {4,30},{15,30},{18,30},{29,30},
    {4,31},{15,31},{18,31},{29,31},
    {4,32},{5,32},{6,32},{7,32},{8,32},{9,32},{10,32},{11,32},{12,32},{13,32},{14,32},{15,32},{16,32},{17,32},{18,32},{19,32},{20,32},{21,32},{22,32},{23,32},{24,32},{25,32},{26,32},{27,32},{28,32},{29,32},

}
end

maze.powerPellets = function()
    return {
    {4, 6}, {29, 6}, {4, 26}, {29, 26}
}
end

local fruits = {
    cherry = {
        name = "Cherry",
        score = 100,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    strawberry = {
        name = "Strawberry",
        score = 300,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    peach = {
        name = "Peach",
        score = 500,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    apple = {
        name = "Apple",
        score = 700,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    melon = {
        name = "Melon",
        score = 1000,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    galaxian = {
        name = "Galaxian",
        score = 2000,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    bell = {
        name = "Bell",
        score = 3000,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    },
    key = {
        name = "Key",
        score = 5000,
        x = 16 * PIXELS_PER_TILE,
        y = 19.5 * PIXELS_PER_TILE
    }
}

-- Define level configurations with ranges
local fruitConfigs = {
    { range = {1, 1}, fruit = fruits.cherry },
    { range = {2, 2}, fruit = fruits.strawberry },
    { range = {3, 4}, fruit = fruits.peach },
    { range = {5, 6}, fruit = fruits.apple },
    { range = {7, 8}, fruit = fruits.melon },
    { range = {9, 10}, fruit = fruits.galaxian },
    { range = {11, 12}, fruit = fruits.bell },
    { range = {13, math.huge}, fruit = fruits.key },
}

local levelTimings = {
    { range = {1, 1}, timings = {
        [0] = "scatter",
        [7] = "chase",
        [27] = "scatter",
        [34] = "chase",
        [54] = "scatter",
        [59] = "chase",
        [79] = "scatter",
        [84] = "chase"
    }},
    { range = {2, 4}, timings = {
        [0] = "scatter",
        [7] = "chase",
        [27] = "scatter",
        [34] = "chase",
        [54] = "scatter",
        [59] = "chase",
    }},
    { range = {5, math.huge}, timings = {
        [0] = "scatter",
        [5] = "chase",
        [25] = "scatter",
        [30] = "chase",
        [50] = "scatter",
        [55] = "chase",
    }}
}

local pacSpeeds = {
    { range = {1, 1}, speed = { norm = .8, frightened = .9 } },
    { range = {2, 4}, speed = { norm = .9, frightened = .95 } },
    { range = {5, 20}, speed = { norm = 1, frightened = 1 } },
    { range = {21, math.huge}, speed = { norm = .9, frightened = .9 } }
}

local ghostSpeeds = {
    { range = {1, 1}, speed = { norm = .75, frightened = .5, tunnel = .4, leaving = .4 } },
    { range = {2, 4}, speed = { norm = .85, frightened = .55, tunnel = .45, leaving = .4 } },
    { range = {5, 20}, speed = { norm = .95, frightened = .6, tunnel = .5, leaving = .4 } },
    { range = {21, math.huge}, speed = { norm = .95, frightened = .95, tunnel = .5, leaving = .4 } }
}

local frightenedTimes = {
    { range = {1, 1}, time = 6 },
    { range = {2, 2}, time = 5 },
    { range = {3, 3}, time = 4 },
    { range = {4, 4}, time = 3 },
    { range = {5, 5}, time = 2 },
    { range = {6, 6}, time = 5 },
    { range = {7, 8}, time = 2 },
    { range = {9, 9}, time = 1 },
    { range = {10, 10}, time = 5 },
    { range = {11, 11}, time = 2 },
    { range = {12, 13}, time = 1 },
    { range = {14, 14}, time = 3 },
    { range = {15, 16}, time = 1 },
    { range = {18, 18}, time = 1 },
}

local leavingTimes = {
    { range = {1, 1}, time = { Blinky = 0, Pinky = 1, Inky = 5, Clyde = 8 }},
    { range = {2, 2}, time = { Blinky = 0, Pinky = 1, Inky = 2, Clyde = 8 }},
    { range = {3, math.huge}, time = { Blinky = 0, Pinky = 1, Inky = 2, Clyde = 3 }},
}

maze.getLeavingTimer = function(level, name)
    for _, leavingTime in ipairs(leavingTimes) do
        if level >= leavingTime.range[1] and level <= leavingTime.range[2] then
            return leavingTime.time[name]
        end
    end
end

maze.getFrightenedTime = function(level)
    for _, frightenedTime in ipairs(frightenedTimes) do
        if level >= frightenedTime.range[1] and level <= frightenedTime.range[2] then
            return frightenedTime.time
        end
    end
end

maze.getGhostSpeed = function(level, mode)
    for _, ghostSpeed in ipairs(ghostSpeeds) do
        if level >= ghostSpeed.range[1] and level <= ghostSpeed.range[2] then
            return ghostSpeed.speed[mode] * SPEED_FACTOR
        end
    end
end

maze.getPacSpeed = function(level, mode)
    for _, pacSpeed in ipairs(pacSpeeds) do
        if level >= pacSpeed.range[1] and level <= pacSpeed.range[2] then
            return pacSpeed.speed[mode] * SPEED_FACTOR
        end
    end
end

maze.getGhostMode = function(level, seconds)
    seconds = seconds
    for _, timingConfig in ipairs(levelTimings) do
        if level >= timingConfig.range[1] and level <= timingConfig.range[2] then
            local timings = timingConfig.timings;
            if (timings[seconds]) then
--                print("switching to " .. timings[seconds] .. " at second " .. seconds)
                return timings[seconds]
            end
        end
    end
end

maze.getFruit = function(level)
    for _, config in ipairs(fruitConfigs) do
        if level >= config.range[1] and level <= config.range[2] then
            return config.fruit
        end
    end
    -- Default config if no match (should not happen)
    return fruits.cherry
end

return maze

