local Module = {
	[1] = {
		Position = Vector3.new(0, 0, 0),
		Tangent = Vector3.new(-1, 0, 0),
		ZRotation = 0,
		Pre = nil,
		Fol = 2,
	},
	[2] = {
		Position = Vector3.new(200, 0, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = 0,
		Pre = 1,
		Fol = 3,
	},
	[3] = {
		Position = Vector3.new(250, 0, 0),
		Tangent = Vector3.new(1, 0, 0),
		ZRotation = -math.rad(10),
		Pre = 2,
		Fol = 4,
	},
	[4] = {
		Position = Vector3.new(450, 0, 200),
		Tangent = Vector3.new(0, 0, 1),
		ZRotation = -math.rad(10),
		Pre = 3,
		Fol = 5,
	},
	[5] = {
		Position = Vector3.new(450, 0, 250),
		Tangent = Vector3.new(0, 0, 1),
		ZRotation = 0,
		Pre = 6,
		Fol = nil,
	},
	[6] = {
		Position = Vector3.new(450, 0, 450),
		Tangent = Vector3.new(0, 0, 1),
		ZRotation = 0,
		Pre = 5,
		Fol = nil,
	},
}

return Module
