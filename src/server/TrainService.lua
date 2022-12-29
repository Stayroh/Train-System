local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local Types = require(ReplicatedStorage.source.TrainCtrl.Types)

local TrainService = Knit.CreateService({
	Name = "TrainService",
	Client = {
		MovementStream = Knit.CreateSignal(),
		OnTrainEvents = Knit.CreateSignal(),
		OnSwitchUpdates = Knit.CreateSignal(),
	},
})

function TrainService.Client:RequestTrainStates()
	return nil
end

function TrainService.Client:RequestSwitchStates()
	return nil
end

return TrainService
