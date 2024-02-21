local Module = {}

for i = 0,9 do
    local d = i * 241.42*4
    Module[i*4+1] = {
        Position = Vector3.new(d,100,0),
        Tangent = Vector3.new(1,0,0),
        ZRotation = 0,
    }
    Module[i*4+2] = {
        Position = Vector3.new(d + 241.42,0,0),
        Tangent = Vector3.new(1,-1,0).Unit,
        ZRotation = 0,
    }
    Module[i*4+3] = {
        Position = Vector3.new(d + 2 * 241.42,-100,0),
        Tangent = Vector3.new(1,0,0),
        ZRotation = 0,
    }
    Module[i*4+4] = {
        Position = Vector3.new(d + 3 * 241.42,0,0),
        Tangent = Vector3.new(1,1,0).Unit,
        ZRotation = 0,
    }
end

for i,v in pairs(Module) do
    v.Fol = i ~= #Module and i + 1 or nil
    v.Pre = i ~= 1 and i - 1 or nil
end

return Module