local Bogies = require(game.ReplicatedStorage.source.TrainCtrl.Bogies)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)
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

function Bogie:SetPosition(Position: Types.TrainPosType)
	self.Position = Position
	self:SetCFrame(NetNav:GetCFrame(Position))
end

function Bogie:SetCFrame(CF: CFrame)
	self.CFrame = CF
	print(self.Model.Name .. tostring(self.Reversed))
	self.Model:SetPrimaryPartCFrame(self.Reversed and CF * CFrame.Angles(0, math.pi, 0) or CF)
end

local Cons = {}
function Cons.new(Series: number, Reference: Model, IsReversed: boolean?)
	local self = setmetatable({}, Bogie)
	IsReversed = IsReversed or false
	self.Reversed = IsReversed
	assert(Bogies[Series], Series .. " was not found in the list of train bogies!")
	local FrontPivot = Bogies[Series].frontPivot
	local RearPivot = Bogies[Series].rearPivot
	assert(FrontPivot, "Bogie does at least to have a front pivot")
	if RearPivot then
		self.frontPivot = IsReversed and MirrorZ(RearPivot) or FrontPivot
		self.rearPivot = IsReversed and MirrorZ(FrontPivot) or RearPivot
	else
		self.frontPivot = IsReversed and MirrorZ(FrontPivot) or FrontPivot
	end
	self.Model = Reference
	return self
end

return Cons
