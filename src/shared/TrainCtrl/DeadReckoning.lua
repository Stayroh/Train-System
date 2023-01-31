local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
type SnapQueueElement = {
	Position: Types.TrainPosType,
	Velocity: number,
	Acceleraction: number,
	PassedNodes: { [number]: number },
}
local DR = {}
DR.__index = DR

function DR:AddSnapshot(Snapshot: Types.SnapshotType)
	local Element: SnapQueueElement = {}
	Element.Position = Snapshot.Position
	Element.Velocity = Snapshot.Velocity
	Element.Acceleraction = Snapshot.Acceleraction
	Element.PassedNodes = Snapshot.PassedNodes
	self.IsTP = self.IsTP or Snapshot.TP
	self.InBound[#self.InBound + 1] = Element
end

local Cons = {}

function Cons.new(TrainId: number, Position: Types.TrainPosType, Velocity: number?, Acceleraction: number?)
	local self = setmetatable({}, DR)
	self.InBound = {}
	self.IsTP = false
	self.LastPosition = Position
	self.LastVelocity = Velocity or 0
	self.LastAcceleration = Acceleraction or 0
	self.TrainId = TrainId
	return self
end

return Cons
