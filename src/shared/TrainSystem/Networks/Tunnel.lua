local Module = {}

Module[1] = {
	Position = Vector3.new(0, 50, 0),
	Tangent = Vector3.new(-1, 0, 0),
	ZRotation = math.rad(0),
	Pre = nil,
	Fol = 2,
}

Module[2] = {
	Position = Vector3.new(1000, 50, 0),
	Tangent = Vector3.new(1, 0, 0),
	ZRotation = math.rad(0),
	Pre = 1,
	Fol = nil,
}

return Module
