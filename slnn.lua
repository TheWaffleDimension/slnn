local mx = require 'game/matrix/matrix'
local Library = {}

Library.ActivationFunctions = {}
Library.UtilityFunctions = {}

---------------------------------------------------------------------
-- All Auxiliar functions -------------------------------------------
---------------------------------------------------------------------
-- Activation function of the neuron
Library.ActivationFunctions.sigmoid = function(x)
    return 1 / (1 + math.exp(-x))
end
-- Flat a number to 0 or 1
Library.UtilityFunctions.flat = function(x)
    if x < 0.5 then return 0
    else return 1 end
end
-- Neural Network foward propagation and flat the result
local function Forward(model, input, activationFunc)
    -- The input is the distant to the center rigth of the gap of the pipe
    local result = mx{input}
	for i = 1, #model.hiddenLayers, 1 do
		result = mx.replace(mx.mul(result, model.hiddenLayers[i]), activationFunc)
	end
    result = mx.replace(mx.mul(result, bird.output), activationFunc)
    result = flat(mx.getelement(result, 1, 1))
    return result
end
----------------------------------------------------------------------
----------------------------------------------------------------------

function game:load()

    input = require('simpleKey')
    input:keyInit({'k','s','q'})
    
    -- Set the seed
    --math.randomseed(1)
    math.randomseed(os.time())
    generation = 1
    best = 0
    alive = 10

    -- Create the pipe
    pipe = {}
    pipe.x = 500
    pipe.y = love.math.random( 50, 400)
    pipe.g = 150
    pipe.w = 80

    -- Canvas Ui
    canvasUi = {}
    canvasUi.canvas = love.graphics.newCanvas(220,600)
    function canvasUi.update()
        love.graphics.setCanvas(canvasUi.canvas)
            love.graphics.clear()
            love.graphics.setColor(108, 107, 233)
            love.graphics.rectangle('fill',0,0,220,600)
            love.graphics.setColor(255,255,255)
            love.graphics.print('Genetation ' .. generation, 10, 10)
            love.graphics.print('Alive ' .. alive, 10, 60)
            love.graphics.print('Best Fitnest = ' .. math.floor(best), 10, 110)
            love.graphics.print('Commands:', 10, 480)
            love.graphics.print('"S"-Fast/Slow', 10, 500)
            love.graphics.print('"K"-Kill all', 10, 520)
            love.graphics.print('"Q"-Quit', 10, 540)
        love.graphics.setCanvas()
    end
    canvasUi.update()


    -- Create te base population
    bird = {}
    for i=1, 10 do
        bird[i] = {}
        -- Bird variables
        bird[i].x = 40
        bird[i].y = 280
        bird[i].speed = 0
        -- Neuron input x Amount of neurons
        -- Hiden layer
        bird[i].hiden = mx(2, 6)
        mx.random(bird[i].hiden)
        -- Output layer
        bird[i].output = mx(6, 1)
        mx.random(bird[i].output)
        -- Fitnes
        bird[i].fitnes = 0
        bird[i].alive = true
        bird[i].color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}
    end

end

function game:update(dt)

    input:updateInput()

    -- Kill the current generation
    if input:isReleased('k') then killAndReproduce(bird) end
    -- Enable or disable vsync
    if input:isReleased('s') then
        local ww, wh, mode = love.window.getMode( )
        love.window.setMode(ww, wh, { fullscreen = mode.fullscreen, vsync= not mode.vsync})
    end
    -- Exit main menu
    if input:isReleased('q') then
        function game:update(dt) return 'menu' end
    end

    -- Every frame the game is going to move foward 0.005 sec
    local dt = 0.005
    local dead = 0
    -- Pipe movement
    pipe.x = pipe.x - (175 * dt)
    if pipe.x < -pipe.w then
        pipe.x = 500
        pipe.y = love.math.random( 50, 400)
    end
    for i=1, 10 do
        if bird[i].alive then
            local result
            -- Foward propagation in the neural network of the bird
            result = think(bird[i], pipe)
            -- If the result of that fp is 1 the bird is going to flap
            if result == 1 then
                bird[i].speed = -250
            end
            -- Bird muvement
            bird[i].speed = bird[i].speed + (250*dt)
            bird[i].y = bird[i].y + (bird[i].speed*dt)
            bird[i].fitnes = bird[i].fitnes + dt
            colition(bird[i], pipe)
        else
            dead = dead + 1
        end
    end
    alive = 10 - dead
    -- Sort the birds by fitnes
    table.sort(bird, sortB)
    best = bird[1].fitnes
    canvasUi.update()
    -- If every bird is dead make a new generation
    if dead >= 10 then
        killAndReproduce(bird)
    end

end

function game:draw()
    -- Draw bird
    for i=1, 10 do
        if bird[i].alive then
            love.graphics.setColor(bird[i].color[1], bird[i].color[2], bird[i].color[3])
            love.graphics.rectangle('fill', bird[i].x, bird[i].y, 40, 40)
        end
    end
    -- Draw pipe
    love.graphics.setColor(0,155,0)
    love.graphics.rectangle('fill', pipe.x, 0, pipe.w, pipe.y)
    love.graphics.rectangle('fill', pipe.x, pipe.y + pipe.g, pipe.w, 600 - pipe.y - pipe.g)
    -- Draw info
    love.graphics.setColor(255,255,255)
    love.graphics.draw(canvasUi.canvas, 580, 0)
end

return game