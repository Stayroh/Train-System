local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {
		MovementStream = Knit.CreateSignal(),
		TrainEventBroadcast = Knit.CreateSignal(),
	},
})

return TrainService
