local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)
local CarClass = require(TrainSystem.Car)
local BogieClass = require(TrainSystem.Bogie)
local Cars = require(TrainSystem.Cars)
local NetNav = require(TrainSystem.NetNav)
local DeadReckoning = require(game.ReplicatedStorage.src.TrainSystem.DeadReckoning)

local Train = {}
Train.__index = Train

function Train:Update(Position: Types.TrainPosType)
	for i, Car in pairs(self.Cars) do
		local WasDouble = false
		if i == 1 then
			Car.frontBogie:SetPosition(Position)
		elseif self.Cars[i - 1].rearBogie == Car.frontBogie then
			WasDouble = true
		else
			local Lastfront = self.Cars[i - 1].frontBogie.CFrame
			local Lastrear = self.Cars[i - 1].rearBogie.CFrame
			local PriPart = self.Cars[i - 1].Model.PrimaryPart
			local GlobalPos = (Lastrear.Position - Lastfront.Position).Unit
					* (PriPart.Size.Z / 2 - self.Cars[i - 1].rearJoint.Z + self.Cars[i - 1].rearBogie.frontPivot.Z)
				+ Lastrear.Position
			workspace.Marker.Position = GlobalPos
			local AlternatePos = self.Cars[i - 1].rearBogie.Position
			local Radius = math.abs(Car.Model.PrimaryPart.Size.Z / 2 + Car.frontJoint.Z - Car.frontBogie.frontPivot.Z)
			local AlternateRadius = Radius
				+ (PriPart.Size.Z / 2 - self.Cars[i - 1].rearJoint.Z + self.Cars[i - 1].rearBogie.frontPivot.Z)
			Car.frontBogie:SetPosition(
				NetNav:PositionInRadiusBackwards(AlternatePos, GlobalPos, Radius, AlternateRadius, self.TrainId)
			)
		end
		local Radius = math.abs(
			(Car.frontJoint.Z - Car.frontBogie:GetPivot(not WasDouble).Z)
				- (Car.rearJoint.Z - Car.rearBogie:GetPivot(true).Z)
		)

		Car.rearBogie:SetPosition(
			NetNav:PositionInRadiusBackwards(Car.frontBogie.Position, nil, nil, Radius, self.TrainId)
		)
		Car:Update()
	end
end

function Train:Step(DeltaTime: number)
	self:Update(self.NetworkController:Step(DeltaTime))
end

function Train:ApplySnapshot(Snapshot: Types.SnapshotType)
	self.NetworkController:Update(Snapshot)
end

local Constructors = {}

function Constructors.fromDescription(Description: Types.TrainDescription, Position: Types.TrainPosType)
	local self = setmetatable({}, Train)
	self.Cars = {}
	self.TrainId = Description.Id
	local requiredBogies = 1

	for i, CarDescription in pairs(Description.Cars) do
		local IsReversed = CarDescription.Reversed or false
		local frontBogie, rearBogie = nil, nil
		local CarData = Cars[CarDescription.Series]
		local FrontBogieSeries = IsReversed and CarData.rearBogie or CarData.frontBogie
		local RearBogieSeries = IsReversed and CarData.frontBogie or CarData.rearBogie
		local FrontReversed = IsReversed and not (CarData.rearReversed or false) or (CarData.frontReversed or false)
		local RearReversed = IsReversed and not (CarData.frontReversed or false) or (CarData.rearReversed or false)
		if self.Cars[i - 1] and self.Cars[i - 1].rearBogie:GetPivot(false) then
			frontBogie = self.Cars[i - 1].rearBogie
		else
			frontBogie = BogieClass.new(FrontBogieSeries, Description.Bogies[requiredBogies], FrontReversed)
			requiredBogies += 1
		end
		rearBogie = BogieClass.new(RearBogieSeries, Description.Bogies[requiredBogies], RearReversed)
		requiredBogies += 1

		local Car = CarClass.fromDescription(CarDescription, frontBogie, rearBogie, IsReversed)
		self.Cars[i] = Car
	end
	self.Position = Position
	self.NetworkController = DeadReckoning.new(self.Position, 0, 0, self.TrainId)
	self:Update(Position)
	return self
end

return Constructors
