local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Bogies = require(TrainSystem.Bogies)
local Types = require(TrainSystem.Types)
local NetNav = require(TrainSystem.NetNav)
local Bogie = {}
Bogie.__index = Bogie

function MirrorZ(V: Vector3): Vector3
	return V * Vector3.new(1, 1, -1)
end

function Bogie:GetPivot(IsFront: boolean): Vector3?
	if IsFront then
		return self.frontPivot
	else
		return self.rearPivot
	end
end

function Bogie:GetSpringPivot(IsFront: boolean): Vector3?
	if IsFront then
		return self.frontPivot + Vector3.new(0, 1, 0) * self.SpringDelta
	else
		if not self.rearPivot then
			return
		end
		return self.rearPivot + Vector3.new(0, 1, 0) * self.SpringDelta
	end
end

function Bogie:SetPosition(Position: Types.TrainPosType, DeltaTime: number?)
	self.Position = Position
	self:SetCFrame(NetNav:GetCFrame(Position), DeltaTime)
end

function Bogie:SetCFrame(CF: CFrame, DeltaTime: number?)
	self.CFrame = CF
	self.Model:PivotTo(self.Reversed and CF * CFrame.Angles(0, math.pi, 0) or CF)
	if not DeltaTime then
		return
	end
	self:UpdatePhysics(DeltaTime)
end

function Bogie:UpdatePhysics(DeltaTime)
	if not self.SpringPivot then
		self.SpringPivot = self.CFrame.UpVector * self.SpringDelta + self.CFrame.Position
	end
	local DeltaHeight = self.CFrame.UpVector:Dot(self.SpringPivot - self.CFrame.Position)
	if DeltaHeight > 10 or DeltaHeight < -10 then
		self.SpringVelocity = 0
		DeltaHeight = math.clamp(DeltaHeight, -10, 10)
		return
	end
	local SpringAcceleration = -DeltaHeight * self.Stiffness
	local DampingAcceleration = -self.SpringVelocity * self.Damping
	local GravityAcceleration = -4 * Vector3.new(0, 1, 0):Dot(self.CFrame.UpVector)
	local TotalAccerelation = SpringAcceleration + DampingAcceleration + GravityAcceleration
	local Distance = TotalAccerelation * DeltaTime ^ 2 / 2 + self.SpringVelocity + DeltaTime
	self.SpringVelocity += TotalAccerelation * DeltaTime
	self.SpringDelta = DeltaHeight + Distance
	self.SpringPivot = self.CFrame.UpVector * self.SpringDelta + self.CFrame.Position
end

local Cons = {}
function Cons.new(Series: number, Reference: Model, IsReversed: boolean?)
	local self = setmetatable({}, Bogie)
	IsReversed = IsReversed or false
	self.Reversed = IsReversed
	assert(Bogies[Series], Series .. " was not found in the list of train bogies!")
	local FrontPivot = Bogies[Series].frontPivot
	local RearPivot = Bogies[Series].rearPivot
	self.Stiffness = Bogies[Series].Stiffness
	self.Damping = Bogies[Series].Damping
	self.SpringVelocity = 0
	self.SpringDelta = 0
	assert(FrontPivot, "Bogie does at least to have a front pivot")
	if RearPivot then
		self.frontPivot = IsReversed and MirrorZ(RearPivot) or FrontPivot
		self.rearPivot = IsReversed and MirrorZ(FrontPivot) or RearPivot
	else
		self.frontPivot = IsReversed and MirrorZ(FrontPivot) or FrontPivot
	end
	self.SpringPivot = nil
	self.Model = Reference
	return self
end

return Cons
