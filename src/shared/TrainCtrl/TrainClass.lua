local Types = require(game.ReplicatedStorage.source.TrainCtrl.Types)
local CarClass = require(game.ReplicatedStorage.source.TrainCtrl.Car)
local Bogies = require(game.ReplicatedStorage.source.TrainCtrl.Bogies)
local BogieClass = require(game.ReplicatedStorage.source.TrainCtrl.Bogie)
local Cars = require(game.ReplicatedStorage.source.TrainCtrl.Cars)
local NetNav = require(game.ReplicatedStorage.source.TrainCtrl.NetNav)

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
			print("Get FrontBogie of next Car")
			local Lastfront = self.Cars[i - 1].frontBogie
			local Lastrear = self.Cars[i - 1].rearBogie
			local MiddleCFrame = (CFrame.lookAt(
				Vector3.zero,
				Lastrear.CFrame.Position - Lastfront.CFrame.Position,
				Lastfront.CFrame.UpVector
			) + Lastfront.CFrame.Position):Lerp(
				(
					CFrame.lookAt(
						Vector3.zero,
						Lastrear.CFrame.Position - Lastfront.CFrame.Position,
						Lastrear.CFrame.UpVector
					) + Lastrear.CFrame.Position
				),
				0.5
			)
			local PriPart = self.Cars[i - 1].Model.PrimaryPart
			local LocalPos = MiddleCFrame:PointToObjectSpace(
				PriPart.CFrame.Position + PriPart.CFrame.LookVector * (-PriPart.Size.Z / 2)
			)
			local GlobalPos = MiddleCFrame:PointToWorldSpace(Vector3.new(LocalPos.X, 0, LocalPos.Z))
			workspace.Marker.Position = GlobalPos
			local AlternatePos = self.Cars[i - 1].rearBogie.Position
			local Radius =
				math.abs(Car.Model.PrimaryPart.Size.Z / 2 + Car.frontJoint.Z - Car.frontBogie:GetPivot(true).Z)
			local AlternateRadius = Radius
				+ (PriPart.Size.Z / 2 - self.Cars[i - 1].rearJoint.Z + self.Cars[i - 1].rearBogie:GetPivot(true).Z)
			Car.frontBogie:SetPosition(
				NetNav:PositionInRadiusBackwards(AlternatePos, GlobalPos, Radius, AlternateRadius, self.TrainId)
			)
		end
		local Radius = math.abs(Car.frontJoint.Z - Car.rearJoint.Z)
			+ Car.frontBogie:GetPivot(not WasDouble).Z
			- Car.rearBogie:GetPivot(true).Z

		Car.rearBogie:SetPosition(
			NetNav:PositionInRadiusBackwards(Car.frontBogie.Position, nil, nil, Radius, self.TrainId)
		)
		Car:Update()
	end
end

local Constructors = {}

function Constructors.fromDescription(Description: Types.TrainDescription, Position: Types.TrainPosType)
	local self = setmetatable({}, Train)
	self.Cars = {}
	self.TrainId = Description.TrainId
	local requiredBogies = 1
	for i, CarDescription in pairs(Description.Cars) do
		local frontBogie = nil
		if self.Cars[i - 1] and self.Cars[i - 1].rearBogie:GetPivot(false) then
			frontBogie = self.Cars[i - 1].rearBogie
		else
			frontBogie = BogieClass.new(Cars[CarDescription.CarSeries].frontBogie, Description.Bogies[requiredBogies])
			requiredBogies += 1
		end
		local rearBogie = BogieClass.new(Cars[CarDescription.CarSeries].rearBogie, Description.Bogies[requiredBogies])
		requiredBogies += 1
		if rearBogie:GetPivot(false) == nil then
			rearBogie.Reversed = true
		end
		local Car = CarClass.fromDescription(CarDescription, frontBogie, rearBogie)

		self.Cars[i] = Car
	end
	self.Position = Position
	print(self)
	self:Update(Position)
	return self
end

return Constructors
