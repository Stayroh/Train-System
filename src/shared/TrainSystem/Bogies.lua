local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)
local Bogies: Types.BogiesDataListType = {}

Bogies.FreightFront = {
	frontPivot = Vector3.new(0, 5.5, 3),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.FreightRear = {
	frontPivot = Vector3.new(0, 5.5, 4.5),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.ClassicCarriageBogie = {
	frontPivot = Vector3.new(0, 4.75, 0),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.LocomotiveJB = {
	frontPivot = Vector3.new(0, 3.75, 0),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.TestAlpha = {
	frontPivot = Vector3.new(0, 3.5, -2),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.TestBeta = {
	frontPivot = Vector3.new(0, 3.5, -6),
	rearPivot = Vector3.new(0, 3.5, 4),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.TestGamma = {
	frontPivot = Vector3.new(0, 3.5, -4),
	rearPivot = Vector3.new(0, 3.5, 4),
	Stiffness = 5,
	Damping = 10,
	SpringOffset = 0.5,
}

Bogies.SovietCarriageB = {
	frontPivot = Vector3.new(0, 3.668, 0),
	Stiffness = 5,
	Damping = 6,
	SpringOffset = 0.5,
	WheelCircumference = 1.5,
}

return Bogies
