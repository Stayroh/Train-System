local TrainSystem = game.ReplicatedStorage.source.TrainSystem
local Types = require(TrainSystem.Types)
local Cars = require(TrainSystem.Cars)
local Car = {}
Car.__index = Car

function MirrorZ(V: Vector3): Vector3
	return V * Vector3.new(1, 1, -1)
end

function Car:Update()
	local FrontCFrame: CFrame = self.frontBogie.CFrame
	local RearCFrame: CFrame = self.rearBogie.CFrame
	local IsDouble = self.frontBogie:GetPivot(false) and true or false
	local FrontPoint = FrontCFrame:PointToWorldSpace(self.frontBogie:GetPivot(not IsDouble))
	local RearPoint = RearCFrame:PointToWorldSpace(self.rearBogie:GetPivot(true))
	local FCF = CFrame.lookAt(Vector3.zero, FrontPoint - RearPoint, FrontCFrame.UpVector) + FrontPoint
	local RCF = CFrame.lookAt(Vector3.zero, FrontPoint - RearPoint, RearCFrame.UpVector) + RearPoint
	local CF = FCF:Lerp(RCF, 0.5) * self.InverseOffset
	CF = self.Reversed and CF * CFrame.Angles(0, math.pi, 0) or CF
	self.CFrame = CF
	self.Model:PivotTo(self.CFrame)
end

local Cons = {}

function Cons.fromDescription(Description: Types.CarDescription, frontBogie, rearBogie, IsReversed: boolean?)
	IsReversed = IsReversed or false
	local self = setmetatable({}, Car)
	self.Reversed = IsReversed
	self.frontBogie = frontBogie
	self.rearBogie = rearBogie
	self.Model = Description.Reference
	self.Series = Description.Series
	local FrontJoint = Cars[self.Series].Front
	local RearJoint = Cars[self.Series].Rear
	self.frontJoint = IsReversed and MirrorZ(RearJoint) or FrontJoint
	self.rearJoint = IsReversed and MirrorZ(FrontJoint) or RearJoint
	self.InverseOffset = (CFrame.lookAt(Vector3.zero, self.frontJoint - self.rearJoint) + self.frontJoint:Lerp(
		self.rearJoint,
		0.5
	)):Inverse()
	return self
end

return Cons
