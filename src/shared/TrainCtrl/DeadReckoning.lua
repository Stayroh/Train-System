local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local Config = require(game.ReplicatedStorage.source.TrainCtrl.Config)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)
type SnapQueueElement = {
	Position: Types.TrainPosType,
	Velocity: number,
	Acceleraction: number,
	PassedNodes: { [number]: number },
}
local DR = {}
DR.__index = DR

function DR:Update(DeltaTime)
	if #self.InBound > 0 then
		--New Snapshot
	end
	self.Time += DeltaTime
	self.Alpha = self.Time / (1 / Config.TrainSnapshotsPerSec)
	local Lenght
	local Velocity
	if self.Lenght ~= nil then
		local ClampedAlpha = math.min(self.Alpha, 1)
		local VelBlend = (self.StartVelocity or 0) * (1 - ClampedAlpha) + (self.EndVelocity or 0) * ClampedAlpha
		local StartLenght = VelBlend * self.Time + self.Time ^ 2 * (self.Acceleraction or 0) / 2
		local EndLeght = self.Lenght
			+ (self.EndVelocity or 0) * self.Time
			+ self.Time ^ 2 * (self.Acceleraction or 0) / 2
		Lenght = StartLenght * (1 - ClampedAlpha) + EndLeght * ClampedAlpha
		Velocity = VelBlend * (1 - ClampedAlpha)
			+ (self.EndVelocity or 0) * ClampedAlpha
			+ (self.Acceleraction or 0) * self.Time
	else
		Lenght = (self.StartVelocity or 0) * self.Time + self.Time ^ 2 * (self.Acceleraction or 0) / 2
		Velocity = (self.Acceleraction or 0) * self.Time + (self.StartVelocity or 0)
	end
	self.CurrentVelocity = Velocity

	return self.CurrentPosition
end

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
	self.CurrentPosition = Position
	self.CurrentVelocity = Velocity or 0
	self.LastVelocity = Velocity or 0
	self.LastAcceleration = Acceleraction or 0
	self.TrainId = TrainId
	self.LastTime = 0
	self.T = 0
	return self
end

return Cons
