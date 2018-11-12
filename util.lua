local UtilityFunctions = {}

-- Flat a number to 0 or 1
UtilityFunctions.flat = function(x)
    if x < 0.5 then return 0
    else return 1 end
end

return UtilityFunctions