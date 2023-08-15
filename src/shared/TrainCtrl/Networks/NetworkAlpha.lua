local Module = {
	[1] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 2,
		Fol = nil,
	},
	[2] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 3,
		Fol = 1,
	},
	[3] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 4,
		Fol = 2,
	},
	[4] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 5,
		Fol = 3,
	},
	[5] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 6,
		Fol = 4,
	},
	[6] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = 7,
		Fol = 5,
	},
	[7] = {
		Position = Vector3.new(0, 1, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = math.rad(-10),
		Pre = nil,
		Fol = 6,
	},
}

return Module
