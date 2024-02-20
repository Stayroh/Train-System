local Module = {}

Module[1] = {
	Position = Vector3.new(0, 0, -500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 5, 1).Unit,
	Pre = nil,
	Fol = 2,
}

Module[2] = {
	Position = Vector3.new(500, 0, 0),
	Tangent = Vector3.new(0, 0, 1),
	UpVector = Vector3.new(-1, 5, 0).Unit,
	Pre = 1,
	Fol = 3,
}
Module[3] = {
	Position = Vector3.new(0, 0, 500),
	Tangent = Vector3.new(-1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
	Pre = 2,
	Fol = 4,
}
Module[4] = {
	Position = Vector3.new(-500, 0, 1000),
	Tangent = Vector3.new(0, 0, 1),
	UpVector = Vector3.new(1, 5, 0).Unit,
	Pre = 3,
	Fol = 5,
}
Module[5] = {
	Position = Vector3.new(0, 0, 1500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
	Pre = 4,
	Fol = 6,
}

Module[6] = {
	Position = Vector3.new(500, 0, 1500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
	Pre = 5,
	Fol = 7,
}

Module[7] = {
	Position = Vector3.new(1000, 0, 1000),
	Tangent = Vector3.new(0, 0, -1),
	UpVector = Vector3.new(0, 1, 0),
	Pre = 6,
	Fol = 8,
}

Module[8] = {
	Position = Vector3.new(1000, 0, 0),
	Tangent = Vector3.new(0, 0, -1),
	UpVector = Vector3.new(0, 1, 0),
	Pre = 7,
	Fol = nil,
}

return Module