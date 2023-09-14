local TrainSystem = game.ReplicatedStorage.source.TrainSystem
local Types = require(TrainSystem.Types)
local Cars: Types.CarsDataListType = {}

Cars.FreightTrain = {
	Front = Vector3.new(0, -4.5, -24.75),
	Rear = Vector3.new(0, -4.5, 22.25),
	frontBogie = "FreightFront",
	rearBogie = "FreightRear",
	frontReversed = false,
	rearReversed = true,
}

Cars.LocomotiveJB = {
	Front = Vector3.new(0, 3.75, -22.714),
	Rear = Vector3.new(0, 3.75, 22.714),
	frontBogie = "LocomotiveJB",
	rearBogie = "LocomotiveJB",
	frontReversed = false,
	rearReversed = true,
}

Cars.TestAlpha = {
	Front = Vector3.new(0, -0.5, -28),
	Rear = Vector3.new(0, -0.5, 30),
	frontBogie = "TestAlpha",
	rearBogie = "TestBeta",
	frontReversed = false,
	rearReversed = false,
}

Cars.TestBeta = {
	Front = Vector3.new(0, -0.5, -28),
	Rear = Vector3.new(0, -0.5, 30),
	frontBogie = "TestBeta",
	rearBogie = "TestGamma",
	frontReversed = false,
	rearReversed = false,
}

return Cars
