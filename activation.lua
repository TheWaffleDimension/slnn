local ActivationFunctions = {}

-- Activation function of the neuron
ActivationFunctions.sigmoid = function(x)
    return 1 / (1 + math.exp(-x))
end

return ActivationFunctions