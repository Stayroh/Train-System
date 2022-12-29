local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local SwitchModule = require(script.Switch)
local NetworkModule = require(script.Networks)

local TrainController = Knit.CreateController({
	Name = "TrainController",
})

function TrainController:KnitInit() end

function TrainController:KnitStart()
	--[[
	self.TrainService = Knit.GetService("TrainService")
	self.TrainService:RequestSwitchStates():andThen(function(Update)
		print(type(Update))
		SwitchModule:Update(Update)
		self.TrainService.OnSwitchUpdates:Connect(function(update)
			SwitchModule:Update(update)
		end)
	end)
	]]
end

function TrainController:Test()
	print(self, self == TrainController)
end

return TrainController
