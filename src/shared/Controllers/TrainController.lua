local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.knit)
local SwitchModule = require(ReplicatedStorage.src.TrainSystem.Switch)
local RunService = game:GetService("RunService")
local TrainClass = require(game.ReplicatedStorage.src.TrainSystem.TrainClass)
local Types = require(game.ReplicatedStorage.src.TrainSystem.Types)

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

function TrainController:Stepped(DeltaTime)
	for TrainId, Train in pairs(self.Trains) do
		Train:Step(DeltaTime, 2)
	end
end

function TrainController:ApplySnapshot(Snapshot: Types.SnapshotType, TrainId: number)
	self.Trains[TrainId]:ApplySnapshot(Snapshot)
end

function TrainController:CreateTrain(Description: Types.TrainDescription, Position: Types.TrainPosType)
	if self.Trains[Description.Id] then
		warn("An already existing train has been overridden")
	end
	local Train = TrainClass.fromDescription(Description, Position)
	self.Trains[Description.Id] = Train
end

function TrainController:KnitInit()
	self.TrainService = Knit.GetService("TrainService")
	self.TrainService:RequestSwitchStates():andThen(function(UpdateState)
		self:SwitchUpdates(UpdateState)
		self.TrainService.OnSwitchUpdates:Connect(function(update)
			TrainController:SwitchUpdates(update)
		end)
	end)

	RunService.Heartbeat:Connect(function(DeltaTime)
		self:Stepped(DeltaTime)
	end)
end

function TrainController:KnitStart() end

return TrainController
