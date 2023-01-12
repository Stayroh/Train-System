local Bogies = require(game.ReplicatedStorage.source.TrainCtrl.Bogies)
local Bogie = {}
Bogie.__index = Bogie

function Bogie:GetPivot(IsFront: boolean): Vector3?
	local Direction = self.Reversed and not IsFront or IsFront
	if IsFront and self.Reversed and self.rearPivot == nil then
		Direction = true
	end
	local Pivot = Direction and self.frontPivot or self.rearPivot
	if not Pivot then
		return
	end
	Pivot = self.Reverse and Vector3.new(Pivot.X, Pivot.Y, -Pivot.Z) or Pivot
	return Pivot
end

local Cons = {}
function Cons.new(Series: number, Reference: Model)
	local self = setmetatable({}, Bogie)
	assert(Bogies[Series], Series .. " was not found in the list of train bogies!")
	Bogie.Model = Reference
	Bogie.frontPivot = Bogies[Series].frontPivot
	assert(Bogie.frontPivot, "Bogie does at least to have a front pivot")
	Bogie.rearPivot = Bogies[Series].rearPivot
	return Bogie
end

return Cons
