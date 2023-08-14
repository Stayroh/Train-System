local Module = {
	[1] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = nil,
		Fol = 2,
	},
	[2] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 1,
		Fol = 3,
	},
	[3] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 2,
		Fol = 4,
	},
	[4] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 3,
		Fol = nil,
	},
}

return Module
