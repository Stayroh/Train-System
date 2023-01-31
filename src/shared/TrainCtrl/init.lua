local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local SwitchModule = require(script.Switch)
local RunService = game:GetService("RunService")
require(script.Networks)

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
	end
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
