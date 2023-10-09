local Module = {
	[1] = {
		Position = Vector3.new(0, 200, 0),
		Tangent = Vector3.new(0, -1, 0),
		ZRotation = 0,
		Pre = 4,
		Fol = 2,
	},
	[2] = {
		Position = Vector3.new(200, 0, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = -math.rad(0),
		Pre = 1,
		Fol = 3,
	},
	[3] = {
		Position = Vector3.new(400, 200, 0),
		Tangent = Vector3.new(0, 1, 0),
		ZRotation = -math.rad(0),
		Pre = 2,
		Fol = 4,
	},
	[4] = {
		Position = Vector3.new(200, 400, 0),
		Tangent = Vector3.new(-1, 0, 0),
		ZRotation = -math.rad(0),
		Pre = 3,
		Fol = 1,
	},
}

return Module
