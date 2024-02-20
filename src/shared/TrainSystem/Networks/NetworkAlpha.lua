local Module = {}

Module.IsCircle = false

Module[1] = {
	Position = Vector3.new(0, 0, -500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 5, 1).Unit,
}

Module[2] = {
	Position = Vector3.new(500, 0, 0),
	Tangent = Vector3.new(0, 0, 1),
	UpVector = Vector3.new(-1, 5, 0).Unit,
}
Module[3] = {
	Position = Vector3.new(0, 0, 500),
	Tangent = Vector3.new(-1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
}
Module[4] = {
	Position = Vector3.new(-500, 0, 1000),
	Tangent = Vector3.new(0, 0, 1),
	UpVector = Vector3.new(1, 5, 0).Unit,
}
Module[5] = {
	Position = Vector3.new(0, 0, 1500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
}

Module[6] = {
	Position = Vector3.new(500, 0, 1500),
	Tangent = Vector3.new(1, 0, 0),
	UpVector = Vector3.new(0, 1, 0),
}

Module[7] = {
	Position = Vector3.new(1000, 0, 1000),
	Tangent = Vector3.new(0, 0, -1),
	UpVector = Vector3.new(0, 1, 0),
}

Module[8] = {
	Position = Vector3.new(1000, 0, 0),
	Tangent = Vector3.new(0, 0, -1),
	UpVector = Vector3.new(0, 1, 0),
}

return Module