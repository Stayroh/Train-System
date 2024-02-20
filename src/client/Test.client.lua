local Knit = require(game.ReplicatedStorage.Packages.knit)
Knit.OnStart():await()
local TrainController = Knit.GetController("TrainController")
local T = Instance.new("Folder")
T.Name = "Trains"
T.Parent = workspace
local Assets = game.ReplicatedStorage.assets.Trains
local Test = require(game.ReplicatedStorage.src.Test)
local NetworkId = 1
local Pos = require(game.ReplicatedStorage.src.TrainSystem.NetPosition).new(1, 2, 0.5, NetworkId)
local Bogies = {}
local Cars = {}

local function InsertCar(Car, FrontBogie,RearBogie, Series,Reversed)
	local CarClone = Car:Clone()
	CarClone.Parent = T
	Cars[#Cars + 1] = { Series = Series, Reference = CarClone, Reversed = Reversed}
	local frontBogieClone = FrontBogie:Clone()
	frontBogieClone.Parent = T
	Bogies[#Bogies + 1] = frontBogieClone
	local rearBogieClone = RearBogie:Clone()
	rearBogieClone.Parent = T
	Bogies[#Bogies + 1] = rearBogieClone
end

InsertCar(Assets.FreightTrain,Assets.FreightTrainFront,Assets.FreightTrainRear, "FreightTrain")

for i = 1,4 do
	InsertCar(Assets.ClassicCarriage,Assets.ClassicCarriageBogie,Assets.ClassicCarriageBogie,"ClassicCarriage")
end

local Description = {
	Bogies = Bogies,
	Cars = Cars,
	Id = 1,
}
TrainController:CreateTrain(Description, Pos)
TrainController.Trains[1].Velocity = 2
print("EEEE")
local Event = Instance.new("BindableEvent", game.ReplicatedStorage)
Event.Event:Connect(function(Velocity)
	TrainController.Trains[1].Velocity = Velocity
end)
