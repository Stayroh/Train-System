--Spawns a train composed of four freight trains.
local Test = require(game.ReplicatedStorage.source.Test)
local Trains = workspace.Trains
local Description = {
	Id = 1,
	Cars = {
		{ Series = "FreightTrain", Reference = Trains.FreightTrain1, Reverse = false },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain2, Reverse = true },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain3, Reverse = false },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain4, Reverse = true },
	},
	Bogies = {
		Trains.FrontBogie1,
		Trains.RearBogie1,
		Trains.RearBogie2,
		Trains.FrontBogie2,
		Trains.FrontBogie3,
		Trains.RearBogie3,
		Trains.RearBogie4,
		Trains.FrontBogie4,
	},
}
Test.Alpha(1, 2, 0.5, Description)

--Spawns a train composed of four freight trains and moves it.
local Test = require(game.ReplicatedStorage.source.Test)
local Trains = workspace.Trains
local Description = {
	Id = 1,
	Cars = {
		{ Series = "FreightTrain", Reference = Trains.FreightTrain1, Reverse = false },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain2, Reverse = true },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain3, Reverse = false },
		{ Series = "FreightTrain", Reference = Trains.FreightTrain4, Reverse = true },
	},
	Bogies = {
		Trains.FrontBogie1,
		Trains.RearBogie1,
		Trains.RearBogie2,
		Trains.FrontBogie2,
		Trains.FrontBogie3,
		Trains.RearBogie3,
		Trains.RearBogie4,
		Trains.FrontBogie4,
	},
}
Test.Beta(1, 2, 10, false, Description)
