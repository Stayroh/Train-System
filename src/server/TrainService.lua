local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {
		MovementStream = Knit.CreateSignal(),
		OnTrainEvents = Knit.CreateSignal(),
		OnSwitchUpdates = Knit.CreateSignal(),
	},
})

function TrainService.Client:RequestTrainStates()
	return
end

function TrainService.Client:RequestSwitchStates()
	return
end

return TrainService
