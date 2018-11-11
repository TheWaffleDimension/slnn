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
    for i = 1, #model.Layers, 1 do
        result = mx.replace(mx.mul(result, model.hiddenLayers[i]), activationFunc)
    end
    
    return result
end
----------------------------------------------------------------------

-- layers : Table {inputs, ...hiddens..., outputs}
function Library.CreateModel(layers, activationFunc)
    activationFunc = activationFunc or Library.ActivationFunctions.sigmoid
    layers = layers or {1, 1}

    local model = {LayerCount = layers, ActivationFunction = activationFunc, Layers = {}}
    
    for i = math.min(#layers, 2), #layers, 1 do
        local layer = mx(layers[i-1], layers[i])
        mx.random(layer)
        table.insert(model.Layers, layer)
    end
    
    model.Forward = Forward
    
    return model
end

return Library
