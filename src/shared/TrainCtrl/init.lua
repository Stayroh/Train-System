local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local TrainController = Knit.CreateController({
	Name = "TrainController",
})

function TrainController.KnitInit()
	print("TrainController Initialized")
end

function TrainController.KnitStart()
	print("TrainController Started")
end

return TrainController
