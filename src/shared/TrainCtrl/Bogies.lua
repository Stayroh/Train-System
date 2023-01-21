local Bogies = {}
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)

Bogies.ICE_Main = {
	frontPivot = Vector3.new(0, 1, 2),
}

Bogies.TGV_Double = {
	frontPivot = Vector3.new(0, 1, 0.5),
	rearPivot = Vector3.new(0, 1, -0.5),
}

Bogies.test = {
	frontPivot = Vector3.new(0, 3, 0),
}

Bogies.test_double = {
	frontPivot = Vector3.new(0, 3, 4),
	rearPivot = Vector3.new(0, 3, -4),
}

Bogies.test2 = {
	frontPivot = Vector3.new(0, 3.5, 0),
}

Bogies.test_double2 = {
	frontPivot = Vector3.new(0, 3.5, -5),
	rearPivot = Vector3.new(0, 3.5, 5),
}

Bogies.FreightFront = {
	frontPivot = Vector3.new(0, 5.5, 3),
}

Bogies.FreightRear = {
	frontPivot = Vector3.new(0, 5.5, 4.5),
}

Bogies.Sub = {
	frontPivot = Vector3.zero,
}

Bogies.LocomotiveJB = {
	frontPivot = Vector3.new(0, 3.75, 0),
}

return Bogies
