local Cars = {}
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)

Cars.TGV_Loc = {
	Front = Vector3.new(0, -0.5, 24),
	Rear = Vector3.new(0, -0.5, -30),
	frontBogie = "ICE_Main",
	rearBogie = "TGV_Double",
}

Cars.TestCarAlpha = {
	Front = Vector3.new(0, -0.5, 24),
	Rear = Vector3.new(0, -0.5, -30),
	frontBogie = "test",
	rearBogie = "test_double",
}

Cars.TestCarBeta = {
	Front = Vector3.new(0, -0.5, 30),
	Rear = Vector3.new(0, -0.5, -24),
	frontBogie = "test_double",
	rearBogie = "test",
}

Cars.TestCarAlpha2 = {
	Front = Vector3.new(0, -0.5, -24),
	Rear = Vector3.new(0, -0.5, 29),
	frontBogie = "test2",
	rearBogie = "test_double2",
}

Cars.TestCarBeta2 = {
	Front = Vector3.new(0, -0.5, -29),
	Rear = Vector3.new(0, -0.5, 24),
	frontBogie = "test_double2",
	rearBogie = "test2",
}

Cars.TestCarGamma2 = {
	Front = Vector3.new(0, -0.5, -29),
	Rear = Vector3.new(0, -0.5, 29),
	frontBogie = "test_double2",
	rearBogie = "test_double2",
}

Cars.FreightTrain = {
	Front = Vector3.new(0, -4.5, -24.75),
	Rear = Vector3.new(0, -4.5, 22.25),
	frontBogie = "FreightFront",
	rearBogie = "FreightRear",
	frontReversed = false,
	rearReversed = true,
}

Cars.Submarine = {
	Front = Vector3.new(0, 0, -80),
	Rear = Vector3.new(0, 0, 80),
	frontBogie = "Sub",
	rearBogie = "Sub",
}

Cars.LocomotiveJB = {
	Front = Vector3.new(0, 3.75, -22.714),
	Rear = Vector3.new(0, 3.75, 22.714),
	frontBogie = "LocomotiveJB",
	rearBogie = "LocomotiveJB",
	frontReversed = true,
	rearReversed = true,
}

return Cars
