local Module = {}

Module[1] = {
    Position = Vector3.new(100,100,0),
    Tangent = Vector3.new(0,0,1),
    ZRotation = 0,
    Pre = nil,
    Fol = 2,
}

Module[2] = {
    Position = Vector3.new(79.06,50,-79.06),
    Tangent = Vector3.new(-0.6937,-0.1937,-0.6937),
    ZRotation = 0,
    Pre = 1,
    Fol = 3,
}

Module[3] = {
    Position = Vector3.new(0,0,-100),
    Tangent = Vector3.new(-1,0,0),
    ZRotation = 0,
    Pre = 2,
    Fol = 4,
}

Module[4] = {
    Position = Vector3.new(-79.06,50,-79.06),
    Tangent = Vector3.new(-0.6937,0.1937,0.6937),
    ZRotation = 0,
    Pre = 3,
    Fol = 5,
}

Module[5] = {
    Position = Vector3.new(-100,100,0),
    Tangent = Vector3.new(0,0,1),
    ZRotation = 0,
    Pre = 4,
    Fol = nil,
}

return Module