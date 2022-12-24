local Module = {
	[1] = {
		["Position"] = Vector3.new(1, 0, 0),
		["Tangent"] = Vector3.new(0, 0, -1),
		["UpVector"] = Vector3.new(0, 1, 0),
		["Pre"] = nil,
		["Fol"] = 2,
	},
	[2] = {
		["Position"] = Vector3.new(0, 0, 1),
		["Tangent"] = Vector3.new(1, 0, 0),
		["UpVector"] = Vector3.new(0.5, 1, 0),
		["Pre"] = 1,
		["Fol"] = 3,
	},
	[3] = {
		["Position"] = Vector3.new(-2, 0, 3),
		["Tangent"] = Vector3.new(0, 0, 1),
		["UpVector"] = Vector3.new(0.5, 1, 0),
		["Pre"] = 2,
		["Fol"] = nil,
	},
}

return Module
