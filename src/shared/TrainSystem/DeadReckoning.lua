local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)
local Navigation = require(TrainSystem.Navigation)
local Networks = require(TrainSystem.Networks)
local NetNav = require(TrainSystem.NetNav)
local Config = require(TrainSystem.Config)
local NetPosition = require(TrainSystem.NetPosition)
type self = {
	TrainId: number,
	CurrentPosition: Types.TrainPosType,
	CurrentVelocity: number,
	CurrentAcceleration: number,
	StartPosition: Types.TrainPosType,
	StartVelocity: number,
	TargetPosition: Types.TrainPosType | nil,
	TargetVelocity: number?,
	Path: { { any } }?,
	PathLength: number?,
	UpdateTime: number,
}
local DeadReckoning = {}
DeadReckoning.__index = DeadReckoning
export type DeadReckoning = typeof(setmetatable({} :: self, DeadReckoning))

function DeadReckoning:Update(Snapshot: Types.SnapshotType)
	self = self :: self
	self.UpdateTime = 0
	if self.CurrentPosition.Network ~= Snapshot.Position.Network then
		Snapshot.TP = true
	end
	self.StartPosition = self.CurrentPosition
	self.StartVelocity = self.CurrentVelocity
	self.TargetPosition = Snapshot.Position
	self.TargetVelocity = Snapshot.Velocity
	self.CurrentAcceleration = Snapshot.Acceleraction
	local NavigationPath
	local function CalculatePath()
		NavigationPath = Navigation:ComputeShortestPath(self.TargetPosition, self.CurrentPosition)
		return NavigationPath == nil
	end
	if Snapshot.TP or CalculatePath() then
		self.CurrentPosition = Snapshot.Position
		self.CurrentVelocity = Snapshot.Velocity
		self.CurrentAcceleration = Snapshot.Acceleraction
		self.StartPosition = Snapshot.Position
		self.StartVelocity = Snapshot.Velocity
		self.TargetPosition = nil
		self.TargetVelocity = nil
		self.Path = nil
		self.PathLength = nil
		print(self)
		return Snapshot.Position
	end
	local PathLength = 0
	local Path = {}
	local Network = Networks:GetNetwork(self.TargetPosition.Network)
	local function DidReverse(Index): boolean
		local NodeId = NavigationPath[Index]
		if Index == 1 then
			if NodeId == "nil" then
				return self.TargetPosition.To == nil
			end
			return NodeId == self.TargetPosition.To
		end
		if NavigationPath[Index - 1] == "nil" then
			if NavigationPath[Index + 1] == "nil" then
				return true
			end
			return false
		end
		if NavigationPath[Index + 1] == "nil" then
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
	local Inverse = false
	local Single = false
	if #NavigationPath == 2 and NavigationPath[1] == "nil" then
		Single = true
		local IsReverse = DidReverse(1)
		local TargetDistance = self.TargetPosition.T
		local CurrentDistance = self.CurrentPosition.T
		local Delta = TargetDistance - CurrentDistance
		if math.sign(Delta) == -1 then
			Inverse = true
		end
		local Length = math.abs(Delta)
		Path[1] = { "nil", Length, IsReverse }
		Path[2] = { NavigationPath[2] }
		PathLength = Length
	elseif #NavigationPath == 2 then
		Single = true
		local IsReverse = DidReverse(1)
		local TargetDistance = IsReverse and 1 - self.TargetPosition.T or self.TargetPosition.T
		local CurrentDistance = NavigationPath[1] == self.CurrentPosition.From and self.CurrentPosition.T
			or 1 - self.CurrentPosition.T
		local Delta = CurrentDistance - TargetDistance
		if math.sign(Delta) == -1 then
			Inverse = true
		end
		local Length = NetNav:GetArcLenght(NavigationPath[1], NavigationPath[2], self.TargetPosition.Network)
		Length *= math.abs(Delta)
		Path[1] = { NavigationPath[1], Length, IsReverse }
		Path[2] = { NavigationPath[2] }
		PathLength = Length
	else
		for i = 1, #NavigationPath do
			local NodeId: number | string = NavigationPath[i]
			if i == #NavigationPath then
				Path[i] = { NodeId }
				continue
			end
			local IsReverse = DidReverse(i)
			if NavigationPath[i - 1] then
				local PreviousReverse = Path[i - 1][3]
				IsReverse = (PreviousReverse and not IsReverse) or (not PreviousReverse and IsReverse)
			end
			local Length = 1
			if NodeId ~= "nil" and NavigationPath[i + 1] ~= "nil" then
				Length = NetNav:GetArcLenght(NodeId, NavigationPath[i + 1], self.TargetPosition.Network)
			end

			if i == 1 then
				Length = (IsReverse or NodeId == "nil") and Length * self.TargetPosition.T
					or Length * (1 - self.TargetPosition.T)
			elseif i == #NavigationPath - 1 then
				local StartMatch = NodeId == self.CurrentPosition.From
				Length = (StartMatch or NavigationPath[i + 1] == "nil") and Length * self.CurrentPosition.T
					or Length * (1 - self.CurrentPosition.T)
			end
			Path[i] = { NodeId, Length, IsReverse }
			PathLength += Length
		end
	end
	if Path[#Path - 1][1] == self.CurrentPosition.From then
		self.StartVelocity *= -1
	end
	if not Path[#Path - 1][3] then
		self.CurrentVelocity = -self.StartVelocity
	end
	self.PathLength = PathLength
	self.Path = Path
	print(self)
end

function DeadReckoning:Step(DeltaTime: number): Types.TrainPosType
	self = self :: self
	self.UpdateTime += DeltaTime
	local TimeSquared = self.UpdateTime ^ 2
	local AlphaTime = math.clamp(self.UpdateTime / (1 / Config.TrainSnapshotsPerSec), 0, 1)
	local Position
	local CurrentVelocity
	if self.PathLength and AlphaTime ~= 1 then
		local VelocityBlend = self.StartVelocity + (self.TargetVelocity - self.StartVelocity) * AlphaTime
		local StartProjection = (TimeSquared * self.CurrentAcceleration) / 2 + VelocityBlend * self.UpdateTime
		local TargetProjection = (TimeSquared * self.CurrentAcceleration) / 2
			+ self.TargetVelocity * self.UpdateTime
			+ self.PathLength
		Position = StartProjection + (TargetProjection - StartProjection) * AlphaTime
		CurrentVelocity = VelocityBlend + self.CurrentAcceleration * self.UpdateTime
		print(VelocityBlend, StartProjection, TargetProjection)
	else
		Position = (TimeSquared * self.CurrentAcceleration) / 2
			+ (self.TargetVelocity or self.StartVelocity) * self.UpdateTime
			+ (self.PathLength or 0)
		CurrentVelocity = (self.TargetVelocity or self.StartVelocity) + self.CurrentAcceleration * self.UpdateTime
	end

	if self.PathLength and (self.PathLength - Position) > 0 then
		local ReversedPosition = self.PathLength - Position
		local ToGo = ReversedPosition
		local Index = 0
		local SegmentPosition = 0
		while ToGo > 0 and Index < #self.Path - 1 do
			Index += 1
			local SegmentLength = self.Path[Index][2]
			SegmentPosition = math.min(ToGo, SegmentLength)
			ToGo -= SegmentPosition
		end
		local Start = self.Path[Index]
		local End = self.Path[Index + 1]
		local StepStart = Start
		local StepEnd = End
		local T = SegmentPosition
		local StepDistance = ToGo
		if Start == nil or End == nil then
			if Start[3] then
				StepStart, StepEnd = StepEnd, StepStart
				StepDistance *= -1
			else
				CurrentVelocity *= -1
			end
		else
			local SegmentLength = NetNav:GetArcLenght(Start[1], End[1], self.TargetPosition.Network)
			T = T / SegmentLength
			if Start[3] then
				StepStart, StepEnd = StepEnd, StepStart
				T = 1 - T
				StepDistance *= -1
			else
				CurrentVelocity *= -1
			end
		end
		local StepPosition = NetPosition.new(StepStart[1], StepEnd[1], T, self.TargetPosition.Network)
		if StepDistance == 0 then
			self.CurrentPosition = StepPosition
			self.CurrentVelocity = CurrentVelocity
		end
	else
		local StepStart = self.TargetPosition or self.StartPosition
		local StepDistance = self.PathLength and Position - self.PathLength or Position
		self.CurrentPosition = NetNav:StepDistance(StepStart, StepDistance, self.TrainId)
		self.CurrentVelocity = CurrentVelocity
	end
	return self.CurrentPosition
end

local Constructors = {}

function Constructors.new(
	Position: Types.TrainPosType,
	Velocity: number,
	Acceleraction: number,
	TrainId: number
): DeadReckoning
	local self = setmetatable({
		TrainId = TrainId,
		CurrentPosition = Position,
		CurrentVelocity = Velocity,
		CurrentAcceleration = Acceleraction,
		StartPosition = Position,
		StartVelocity = Velocity,
		UpdateTime = 0,
	} :: self, DeadReckoning)
	return self
end

return Constructors
