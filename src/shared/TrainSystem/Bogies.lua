local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)
local Bogies: Types.BogiesDataListType = {}

Bogies.FreightFront = {
	frontPivot = Vector3.new(0, 5.5, 3),
}

Bogies.FreightRear = {
	frontPivot = Vector3.new(0, 5.5, 4.5),
}

Bogies.ClassicCarriageBogie = {
	frontPivot = Vector3.new(0, 4.75, 0),
}

Bogies.LocomotiveJB = {
	frontPivot = Vector3.new(0, 3.75, 0),
}

Bogies.TestAlpha = {
	frontPivot = Vector3.new(0, 3.5, -2),
}

Bogies.TestBeta = {
	frontPivot = Vector3.new(0, 3.5, -6),
	rearPivot = Vector3.new(0, 3.5, 4),
}

Bogies.TestGamma = {
	frontPivot = Vector3.new(0, 3.5, -4),
	rearPivot = Vector3.new(0, 3.5, 4),
}

return Bogies
