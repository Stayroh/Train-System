local Module = {
	[1] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(-1, 0, -1).Unit,
		ZRotation = math.rad(-10),
		Pre = nil,
		Fol = 2,
	},
	[2] = {
		Position = Vector3.new(10, 11, 10),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(0),
		Pre = 1,
		Fol = nil,
	},
}

return Module
