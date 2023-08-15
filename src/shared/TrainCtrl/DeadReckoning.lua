local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local Navigation = require(game.ReplicatedStorage.source.TrainCtrl.Navigation)
local Networks = require(game.ReplicatedStorage.source.TrainCtrl.Networks)
type self = {
	CurrentPosition: Types.TrainPosType,
	CurrentVelocity: number,
	CurrentAcceleration: number,
	TargetPosition: Types.TrainPosType | nil,
	TargetVelocity: number?,
	TargetAcceleration: number?,
	Path: { { any } }?,
	PathLength: number?,
	UpdateTime: number,
}
local DeadReckoning = {}
DeadReckoning.__index = DeadReckoning
export type DeadReckoning = typeof(setmetatable({} :: self, DeadReckoning))

function DeadReckoning:Update(Snapshot: Types.SnapshotType): Types.TrainPosType
	self = self :: self
	self.UpdateTime = 0
	if self.CurrentPosition.Network ~= Snapshot.Position.Network then
		Snapshot.TP = true
	end
	local NavigationPath
	local function CalculatePath()
		NavigationPath = Navigation:ComputeShortestPath(self.TargetPosition, self.CurrentPosition)
		return NavigationPath == nil
	end
	if Snapshot.TP or CalculatePath() then
		self.CurrentPosition = Snapshot.Position
		self.CurrentVelocity = Snapshot.Velocity
		self.CurrentAcceleration = Snapshot.Acceleraction
		self.TargetPosition = nil
		self.Path = nil
		self.PathLength = nil
		return Snapshot.Position
	end
	self.TargetPosition = Snapshot.Position
	self.TargetVelocity = Snapshot.Velocity
	self.TargetAcceleration = Snapshot.Acceleraction
	local PathLength = 0
	local Path = {}
	local Network = Networks:GetNetwork(self.TargetPosition.Network)
	local function DidReverse(Index): boolean
		local NodeId = NavigationPath[Index]
		if Index == 1 then
			if NodeId == "nil" then
				return false
			end
			return NavigationPath[Index] == self.TargetPosition.To
		end
		if NavigationPath[Index - 1] == "nil" or NavigationPath[Index - 1] == nil then
			return false
		end
		if NavigationPath[Index + 1] == "nil" or NavigationPath[Index + 1] == nil then
			return false
		end
		local NextNodeId = NavigationPath[Index + 1]
		local PreviousNodeId = NavigationPath[Index - 1]
		local Direction = false
		if type(Network[NodeId].Fol) == "table" then
			for i, v in next, Network[NodeId] do
				if v == NextNodeId then
					Direction = true
					break
				end
			end
		else
			if Network[NodeId].Fol == NextNodeId then
				return false
			end
		end
		local ToSearch = Direction and Network[NodeId].Fol or Network[NodeId].Pre
		if type(ToSearch) == "table" then
			for i, v in next, ToSearch do
				if v == PreviousNodeId then
					return true
				end
			end
		else
			return false
		end
	end
	for i = 1, #NavigationPath do
		local Node: number | string = NavigationPath[i]
		if i == #NavigationPath then
			Path[i] = { Node }
		end
		local IsReverse = DidReverse(i)
		if NavigationPath[i - 1] then
			local PreviousReverse = NavigationPath[i - 1][3]
			IsReverse = (PreviousReverse and not IsReverse) or (not PreviousReverse and IsReverse)
		end
	end
end

local Constructors = {}

function Constructors.new(Position: Types.TrainPosType, Velocity: number, Acceleraction: number): DeadReckoning
	local self = setmetatable({
		CurrentPosition = Position,
		CurrentVelocity = Velocity,
		CurrentAcceleration = Acceleraction,
		UpdateTime = 0,
	} :: self, DeadReckoning)
	return self
end

return Constructors
