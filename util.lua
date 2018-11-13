local mx = require"matrix/matrix"

local UtilityFunctions = {}

-- Flat a number to 0 or 1
UtilityFunctions.flat = function(x)
    if x < 0.5 then return 0
    else return 1 end
end

UtilityFunctions.randomizeLayers = function(model)
  for i,v in next,model.Layers,nil do
    mx.random(v)
  end

  return model
end

return UtilityFunctions
