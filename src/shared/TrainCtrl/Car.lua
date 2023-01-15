local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local Cars = require(game.ReplicatedStorage.source.TrainCtrl.Cars)
local Car = {}
Car.__index = Car

function Car:Update()
	local FrontCFrame: CFrame = self.frontBogie.CFrame
	local RearCFrame: CFrame = self.rearBogie.CFrame
	local IsDouble = self.frontBogie:GetPivot(false) and true or false
	local FrontPoint = FrontCFrame:PointToWorldSpace(self.frontBogie:GetPivot(not IsDouble))
	local RearPoint = RearCFrame:PointToWorldSpace(self.rearBogie:GetPivot(true))
	local FCF = CFrame.lookAt(Vector3.zero, FrontPoint - RearPoint, FrontCFrame.UpVector) + FrontPoint
	local RCF = CFrame.lookAt(Vector3.zero, FrontPoint - RearPoint, RearCFrame.UpVector) + RearPoint
	self.CFrame = FCF:Lerp(RCF, 0.5) * self.InverseOffset
	self.Model:SetPrimaryPartCFrame(self.CFrame)
end

local Cons = {}

function Cons.fromDescription(Description: Types.CarDescription, frontBogie, rearBogie)
	local self = setmetatable({}, Car)
	self.frontBogie = frontBogie
	self.rearBogie = rearBogie
	self.Model = Description.CarReference
	self.Series = Description.CarSeries
	self.frontJoint = Cars[self.Series].Front
	self.rearJoint = Cars[self.Series].Rear
	self.InverseOffset = (CFrame.lookAt(Vector3.zero, self.frontJoint - self.rearJoint) + self.frontJoint:Lerp(
		self.rearJoint,
		0.5
	)):Inverse()
	return self
end

return Cons
