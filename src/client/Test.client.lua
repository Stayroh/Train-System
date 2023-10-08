local Knit = require(game.ReplicatedStorage.Packages.knit)
Knit.OnStart():await()
local TrainController = Knit.GetController("TrainController")
local Pos = require(game.ReplicatedStorage.src.TrainSystem.NetPosition).new(1, 2, 0.5, 1)
local T = workspace.Trains
local Description = {
	Bogies = { T.FrontBogie1, T.RearBogie1 },
	Cars = { { Series = "FreightTrain", Reference = T.FreightTrain1 } },
	Id = 1,
}
TrainController:CreateTrain(Description, Pos)
print("EEEE")
local Event = Instance.new("BindableEvent", game.ReplicatedStorage)
Event.Event:Connect(function(Snapshot)
	TrainController:ApplySnapshot(Snapshot, 1)
end)
