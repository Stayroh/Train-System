local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local SwitchModule = require(ReplicatedStorage.src.TrainSystem.Switch)
local RunService = game:GetService("RunService")
local TrainClass = require(game.ReplicatedStorage.src.TrainSystem.TrainClass)

local TrainController = Knit.CreateController({
	Name = "TrainController",
	Trains = {},
})

function TrainController:SwitchUpdates(UpdateState)
	if not UpdateState then
		return
	end
	SwitchModule:Update(UpdateState)
end

function TrainController:Stepped(time, deltaTime)
	for TrainId, Train in pairs(self.Trains) do
		Train:Step(deltaTime)
	end
end

function TrainController:CreateTrain(Description: Types.TrainDescription)
	if self.Trains[CarDescription.Id] then
		warn("An already existing train was overridden")
	end
	self.Trains[Description.Id] = TrainClass.fromDescription(Description)
end

function TrainController:KnitInit()
	self.TrainService = Knit.GetService("TrainService")
	self.TrainService:RequestSwitchStates():andThen(function(UpdateState)
		self:SwitchUpdates(UpdateState)
		self.TrainService.OnSwitchUpdates:Connect(function(update)
			TrainController:SwitchUpdates(update)
		end)
	end)
	RunService.Stepped:Connect(function(time, deltaTime)
		self:Stepped(time, deltaTime)
	end)
end

function TrainController:KnitStart() end

return TrainController
