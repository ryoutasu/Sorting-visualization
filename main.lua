local N = 100
local array = {}
local W, H = 1280, 720
local co
local time = 0.01
local running = false
local current

local function prnt_table(t)
    local s = ''
    for i, v in ipairs(t) do
        s = s .. v.i .. ', '
    end
    print(s)
end

local function fill_array(n)
    array = {}
    for i = 1, n do
        table.insert(array, math.random(#array+1), { i = i, c = { 0, 0, 0 } })
    end
end

function love.load()
    love.window.setMode(W, H)
    love.graphics.setBackgroundColor(191/256, 209/256, 229/256)
    math.randomseed(os.time())

    current = sort
    -- local total = 0
    -- local n = 10
    -- for j = 1, n do
        fill_array(N)
        co = coroutine.create(current)
        
        -- local start = love.timer.getTime()
        -- sort(array)
        -- local result = love.timer.getTime() - start
        -- print( string.format( "It took %.3f milliseconds (%.3f sec, %.3f min) to sort", result * 1000, result, result / 60 ))
    -- --     total = total + result
    -- end
    -- print( string.format( "Total time: %.3f sec; estimated time for sort: %.3f milliseconds (%.3f sec, %.3f min)", total, total/n*1000, total/n, total/n/60 ))
end
    
function partition(values, l, r)
    values[r].c = { 1, 0, 0 }
    local x = values[r].i
    local i = l
    values[i].c = { 0, 1, 0 }

    for j = l, r-1 do
        values[j].c = { 0, 0, 1 }
        if values[j].i <= x then
            coroutine.yield()
            values[i].c = { 0, 0, 0 }

            values[i].i, values[j].i = values[j].i, values[i].i

            i = i + 1
            values[i].c = { 0, 1, 0 }
        end
        coroutine.yield()
        values[j].c = { 0, 0, 0 }
        values[i].c = { 0, 1, 0 }
    end

    local s = values[r].i
    values[r].i = values[i].i
    values[i].i = s

    values[r].c = { 0, 0, 0 }
    values[i].c = { 0, 0, 0 }

    return i
end

function quicksort(values, l, r)
    if l < r then
        local q = partition(values, l, r)
        quicksort(values, q+1, r)
        quicksort(values, l, q-1)
    end
end

function sort(values)
    quicksort(values, 1, #values)
end

function sort1(values)
    for i = 1, #values do
        for j = 1, #values - i do
            values[j].c = { 0, 1, 0 }
            values[j+1].c = { 0, 0, 1 }
            if values[j].i > values[j+1].i then
                values[j].i, values[j+1].i = values[j+1].i, values[j].i
            end
            coroutine.yield()
            values[j+1].c = { 0, 0, 0 }
            values[j].c = { 0, 0, 0 }
        end
    end
end

function sort2(values)
    local l = 1
    local r = #values-1
    while l <= r do
        local nl, nr = l, r
        for i = l, r do
            values[i].c = { 0, 1, 0 }
            values[i+1].c = { 0, 0, 1 }

            if values[i].i > values[i+1].i then
                values[i].i, values[i+1].i = values[i+1].i, values[i].i
                nr = i
            end

            coroutine.yield()
            values[i+1].c = { 0, 0, 0 }
            values[i].c = { 0, 0, 0 }
        end
        r = nr - 1

        for j = r, l, -1 do
            values[j].c = { 0, 1, 0 }
            values[j+1].c = { 0, 0, 1 }
            
            if values[j].i > values[j+1].i then
                values[j].i, values[j+1].i = values[j+1].i, values[j].i
                nl = j
            end

            coroutine.yield()
            values[j+1].c = { 0, 0, 0 }
            values[j].c = { 0, 0, 0 }
        end
        l = nl + 1
    end
end

local t = 0
function love.update(dt)
    if running then
        t = t + dt
        if t >= time then
            if co and coroutine.status(co) ~= "dead" then
                coroutine.resume(co, array)
            end
            t = 0
        end
    end
end

function love.draw()
    local w = W/N
    local x = 0
    for i, v in ipairs(array) do
        local h = H/N*v.i
        love.graphics.setColor(v.c)
        love.graphics.rectangle('fill', x, H-h, w, h)
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle('line', x, H-h, w, h)
        -- love.graphics.setColor(1, 1, 1)
        -- love.graphics.print(v.i, x+5, H-20)
        x = x + w
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print('Press space to start/pause, N to next iteration, R to restart\n1 - quicksort\n2 - bubble sort\n3 - cocktail shaker sort', 0, 0)
end

function love.keypressed( key )
    if key == 'space' then
        -- sort(array)
        running = not running
    elseif key == 'n' then
        if co and coroutine.status(co) ~= "dead" then
            coroutine.resume(co, array)
        end
    elseif key == 'r' then
        running = false
        fill_array(N)
        -- coroutine.close(co)
        co = coroutine.create(current)
    elseif key == '1' then
        current = sort
    elseif key == '2' then
        current = sort1
    elseif key == '3' then
        current = sort2
    end
end