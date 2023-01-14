local Bogies = require(game.ReplicatedStorage.source.TrainCtrl.Bogies)
local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)
local Bogie = {}
Bogie.__index = Bogie

function Bogie:GetPivot(IsFront: boolean): Vector3?
	if self.rearPivot then
		print("Has rear bogie!")
		local Direction = self.Reversed and not IsFront or IsFront
		local Pivot = Direction and self.frontPivot or self.rearPivot
		Pivot = self.Reverse and Vector3.new(Pivot.X, Pivot.Y, -Pivot.Z) or Pivot
		return Pivot
	end
	if not IsFront then
		return nil
	end
	local Pivot = self.frontPivot
	Pivot = self.Reverse and Vector3.new(Pivot.X, Pivot.Y, -Pivot.Z) or Pivot
	return Pivot
end

function Bogie:SetPosition(Position: Types.TrainPosType)
	self.Position = Position
	self:SetCFrame(NetNav:GetCFrame(Position))
end

function Bogie:SetCFrame(CFrame: CFrame)
	self.CFrame = CFrame
	self.Model:SetPrimaryPartCFrame(CFrame)
end

local Cons = {}
function Cons.new(Series: number, Reference: Model)
	local self = setmetatable({}, Bogie)
	self.Reversed = false
	assert(Bogies[Series], Series .. " was not found in the list of train bogies!")
	self.Model = Reference
	self.frontPivot = Bogies[Series].frontPivot
	assert(self.frontPivot, "Bogie does at least to have a front pivot")
	self.rearPivot = Bogies[Series].rearPivot
	return self
end

return Cons
