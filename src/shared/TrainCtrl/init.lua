local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local SwitchModule = require(script.Switch)
local NetworkModule = require(script.Networks)

local TrainController = Knit.CreateController({
	Name = "TrainController",
})

function TrainController:SwitchUpdates(UpdateState)
	if not UpdateState then
		return
	end
	SwitchModule:Update(UpdateState)
end

function TrainController:KnitInit()
	self.TrainService = Knit.GetService("TrainService")
	self.TrainService:RequestSwitchStates():andThen(function(UpdateState)
		self:SwitchUpdates(UpdateState)
		self.TrainService.OnSwitchUpdates:Connect(function(update)
			TrainController:SwitchUpdates(update)
		end)
	end)
end

function TrainController:KnitStart() end

return TrainController
