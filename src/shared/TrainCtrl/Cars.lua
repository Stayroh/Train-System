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

return Cars
