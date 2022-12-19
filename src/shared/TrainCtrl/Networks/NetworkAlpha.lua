local Module = {
	[1] = {
		["Position"] = Vector3.one,
		["Tangent"] = Vector3.new(1, 0, 0.5),
		["UpVector"] = Vector3.new(0, 1, 0),
		["Pre"] = 4,
		["Fol"] = 2,
	},
	[2] = {
		["Position"] = Vector3.one,
		["Tangent"] = Vector3.new(1, -1, 0.1),
		["UpVector"] = Vector3.new(0.5, 1, 0),
		["Pre"] = 1,
		["Fol"] = 3,
	},
	[3] = {
		["Position"] = Vector3.one,
		["Tangent"] = Vector3.new(1, -1, 0.1),
		["UpVector"] = Vector3.new(0.5, 1, 0),
		["Pre"] = 2,
		["Fol"] = 4,
	},
	[4] = {
		["Position"] = Vector3.one,
		["Tangent"] = Vector3.new(1, -1, 0.1),
		["UpVector"] = Vector3.new(0.5, 1, 0),
		["Pre"] = 3,
		["Fol"] = 1,
	},
}

return Module
