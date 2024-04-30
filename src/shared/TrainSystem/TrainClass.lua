local TrainSystem = game.ReplicatedStorage.src.TrainSystem
local Types = require(TrainSystem.Types)
local CarClass = require(TrainSystem.Car)
local BogieClass = require(TrainSystem.Bogie)
local Cars = require(TrainSystem.Cars)
local NetNav = require(TrainSystem.NetNav)
local DeadReckoning = require(game.ReplicatedStorage.src.TrainSystem.DeadReckoning)

local Train = {}
Train.__index = Train

function Train:Update(Position: Types.TrainPosType, DeltaTime: number)
	self.Position = Position
	local ProjectionLength = 0
	local StartHeight = 0
	local EndHeight = 0
	local LastCalculatedPoint: Vector2?
	local function CalcNewProjectionDistance(P: Vector3)
		local P_Projection = Vector2.new(P.X, P.Z)
		if LastCalculatedPoint then
			local Distance = (P_Projection - LastCalculatedPoint).Magnitude
			LastCalculatedPoint = P_Projection
			ProjectionLength += Distance
		else
			LastCalculatedPoint = P_Projection
		end
	end
	for i, Car in pairs(self.Cars) do
		local WasDouble = false
		if i == 1 then
			local WorldCFrame = NetNav:GetCFrame(Position)
			Car.frontBogie:SetCFrame(WorldCFrame, DeltaTime)
			Car.frontBogie.Position = Position
			CalcNewProjectionDistance(WorldCFrame.Position)
			StartHeight = WorldCFrame.Position.Y
		elseif self.Cars[i - 1].rearBogie == Car.frontBogie then
			WasDouble = true
		else
			local Lastfront = self.Cars[i - 1].frontBogie.CFrame
			local Lastrear = self.Cars[i - 1].rearBogie.CFrame
			local PriPart = self.Cars[i - 1].Model.PrimaryPart
			local GlobalPos = (Lastrear.Position - Lastfront.Position).Unit
					* (PriPart.Size.Z / 2 - self.Cars[i - 1].rearJoint.Z + self.Cars[i - 1].rearBogie.frontPivot.Z)
				+ Lastrear.Position
			local AlternatePos = self.Cars[i - 1].rearBogie.Position
			local Radius = math.abs(Car.Model.PrimaryPart.Size.Z / 2 + Car.frontJoint.Z - Car.frontBogie.frontPivot.Z)
			local AlternateRadius = Radius
				+ (PriPart.Size.Z / 2 - self.Cars[i - 1].rearJoint.Z + self.Cars[i - 1].rearBogie.frontPivot.Z)
			local RadiusIntersectionPos =
				NetNav:PositionInRadiusBackwards(AlternatePos, GlobalPos, Radius, AlternateRadius, self.TrainId)
			local WorldCFrame = NetNav:GetCFrame(RadiusIntersectionPos)
			Car.frontBogie:SetCFrame(WorldCFrame, DeltaTime)
			Car.frontBogie.Position = RadiusIntersectionPos
			CalcNewProjectionDistance(WorldCFrame.Position)
		end
		local Radius = math.abs(
			(Car.frontJoint.Z - Car.frontBogie:GetPivot(not WasDouble).Z)
				- (Car.rearJoint.Z - Car.rearBogie:GetPivot(true).Z)
		)
		local RearPosition = NetNav:PositionInRadiusBackwards(Car.frontBogie.Position, nil, nil, Radius, self.TrainId)
		local WorldCFrame = NetNav:GetCFrame(RearPosition)
		Car.rearBogie:SetCFrame(WorldCFrame, DeltaTime)
		Car.rearBogie.Position = RearPosition
		CalcNewProjectionDistance(WorldCFrame.Position)
		if i == #self.Cars then
			EndHeight = WorldCFrame.Position.Y
		end
		Car:Update()
	end
	local DeltaHeight = StartHeight - EndHeight
	self.Angle = math.atan(DeltaHeight / ProjectionLength)
end

function Train:Step(DeltaTime: number, Acceleration: number)
	local StepDistance = (DeltaTime ^ 2 * Acceleration) / 2 + self.Velocity * DeltaTime
	local GravityAcceleration = math.sin(self.Angle) * -40
	self.Velocity += (Acceleration + GravityAcceleration) * DeltaTime
	local NewPosition = NetNav:StepDistance(self.Position, StepDistance, self.TrainId)
	if NewPosition == self.Position then
		return
	end
	self:Update(NewPosition, DeltaTime)
end

--[[
function Train:ApplySnapshot(Snapshot: Types.SnapshotType)
	self.NetworkController:Update(Snapshot)
end
]]

local Constructors = {}

function Constructors.fromDescription(Description: Types.TrainDescription, Position: Types.TrainPosType)
	local self = setmetatable({}, Train)
	self.Cars = {}
	self.TrainId = Description.Id
	local requiredBogies = 1
	self.Velocity = 100
	self.Angle = 0

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
	--	self.NetworkController = DeadReckoning.new(self.Position, 0, 0, self.TrainId)
	self:Update(Position)
	return self
end

return Constructors
