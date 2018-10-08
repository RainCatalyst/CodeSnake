--Special functions
function lerp(a,b,t) return a * (1-t) + b * t end

--Load
function love.load()
    font = love.graphics.newFont('pixfont.ttf', 36)
    love.graphics.setFont(font)
    noise = love.graphics.newImage('noise.png')
    local source = love.filesystem.read("hacker.fsh")
    linearShader = love.graphics.newShader(source)
    linearShader:send('noise', noise)

    actions = {'up', 'down', 'right', 'left'}

    gridX = 20
    gridY = 15
    cellSize = 20
    lastdt = 0
    alpha = 0
    up = true

    icon = love.image.newImageData('icon.png')

    love.window.setMode(gridX*cellSize, (gridY+5)*cellSize)
    love.window.setIcon(icon)
    canvas = love.graphics.newCanvas(gridX*cellSize, (gridY+5)*cellSize)
 
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
    love.graphics.setCanvas()

    function moveFood()
        local possibleFoodPositions = {}

        for foodX = 1, gridX do
            for foodY = 1, gridY do
                local possible = true

                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        foodPosition = possibleFoodPositions[love.math.random(1, #possibleFoodPositions)]
    end

    function reset()
        snakeSegments = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x = 1, y = 1},
        }
        power = 0
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
        score = 0
        w = ''
        moveFood()
    end

    reset()
end

--Update tail segments
function update()
    if #directionQueue > 1 then
        table.remove(directionQueue, 1)
    end

    local nextX = snakeSegments[1].x
    local nextY = snakeSegments[1].y

    if directionQueue[1] == 'right' then
        nextX = nextX + 1
        if nextX > gridX then
            nextX = 1
        end
    elseif directionQueue[1] == 'left' then
        nextX = nextX - 1
        if nextX < 1 then
            nextX = gridX
        end
    elseif directionQueue[1] == 'down' then
        nextY = nextY + 1
        if nextY > gridY then
            nextY = 1
        end
    elseif directionQueue[1] == 'up' then
        nextY = nextY - 1
        if nextY < 1 then
            nextY = gridY
    end
    end

    local canMove = true

    for segmentIndex, segment in ipairs(snakeSegments) do
        if segmentIndex ~= #snakeSegments
        and nextX == segment.x 
        and nextY == segment.y then
            canMove = false
        end
    end

    if canMove then
        table.insert(snakeSegments, 1, {x = nextX, y = nextY})

        if snakeSegments[1].x == foodPosition.x
        and snakeSegments[1].y == foodPosition.y then
            score = score + 1
            power = 0.3
            moveFood()
        else
            table.remove(snakeSegments)
        end
    else
        snakeAlive = false
    end
end

--Update timers and effects
function love.update(dt)
    timer = timer + dt
    if up then
        alpha = lerp(alpha, 1, dt*5)
        if 1-alpha<0.05 then up = false end
    else
        alpha = lerp(alpha, 0, dt*5)
        if alpha<0.05 then up = true end
    end

    if snakeAlive then
        local timerLimit = 0.2
        if timer >= timerLimit then
            timer = timer - timerLimit
            update()
        end
    elseif timer >= 2 then
        reset()
    end
    power = lerp(power, 0, dt*4)
    lastdt = dt
end

--Draw everything
function love.draw()
    love.graphics.setColor(0.1,0.1,0.1,1)
    love.graphics.setCanvas(canvas)
        love.graphics.clear()
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridX * cellSize,
        gridY * cellSize
    )
    

    local function drawCell(x, y)
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    for segmentIndex, segment in ipairs(snakeSegments) do
        if snakeAlive then
            if segmentIndex%2==0 then
                love.graphics.setColor(.09, .65, 0)
            else
                love.graphics.setColor(.13, .76, .05)
            end
        else
            love.graphics.setColor(.3, .3, .3)
        end
        drawCell(segment.x, segment.y, cellSize)
    end

    love.graphics.setColor(1, 0, 0, 1-alpha)
    drawCell(foodPosition.x, foodPosition.y, cellSize, cellSize)
    --
    love.graphics.setColor(.11, .76, .05, alpha)
    love.graphics.print('>', 10, gridY*cellSize+5)
    love.graphics.print('>', 10, gridY*cellSize+50)--, 100, 'center')
    love.graphics.setColor(.11, .76, .05, 1)
    love.graphics.print(w, 40, gridY*cellSize+5)
    love.graphics.print('score '..score, 40, gridY*cellSize+50)
    love.graphics.setCanvas()
    love.graphics.setShader(linearShader)
    linearShader:send("seed", {math.cos(love.timer.getTime()*2+lastdt), math.sin(love.timer.getTime()*3)})
    linearShader:send("power", power)
    love.graphics.draw(canvas)
    love.graphics.setShader()
end

function love.keypressed(key, scancode, isrepeat)
    if scancode~='space' and scancode~='backspace' then
        if string.len(scancode)==1 then
            w = w .. scancode
            if w == 'right' then w = '' if directionQueue[#directionQueue] ~= 'right'
            and directionQueue[#directionQueue] ~= 'left' then
                table.insert(directionQueue, 'right')
            end
            elseif w == 'left' then w = '' if directionQueue[#directionQueue] ~= 'left'
            and directionQueue[#directionQueue] ~= 'right' then
                table.insert(directionQueue, 'left')
            end
            elseif w == 'up' then w = '' if directionQueue[#directionQueue] ~= 'up'
            and directionQueue[#directionQueue] ~= 'down' then
                table.insert(directionQueue, 'up')
            end
            elseif w == 'down' then w = '' if directionQueue[#directionQueue] ~= 'down'
            and directionQueue[#directionQueue] ~= 'up' then
                table.insert(directionQueue, 'down')
            end
            end
            if string.len(w)>5 then
                w = ''
            end
        end
    else
        w = ''
    end
end