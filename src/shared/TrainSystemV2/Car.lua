--!strict
local Configuration = require(game.ReplicatedStorage.src.TrainSystemV2.Configuration)
local Bogie = require(game.ReplicatedStorage.src.TrainSystemV2.Bogie)
local RouteNetwork = require(game.ReplicatedStorage.src.TrainSystemV2.RouteNetwork)
type Train = typeof(require(game.ReplicatedStorage.src.TrainSystemV2.Train))

local Car: CarClass = {} :: CarClass
Car.__index = Car

type CarClass = {
	__index: CarClass,
	new: (
		name: string,
		routeNetwork: RouteNetwork.RouteNetwork,
		location: RouteNetwork.RouteNetworkLocation,
		reversed: boolean,
		train: Train,
		previousCar: Car?
	) -> Car,
	setLocation: (self: Car, location: RouteNetwork.RouteNetworkLocation) -> (),
	setBogiesLocation: (self: Car, location: RouteNetwork.RouteNetworkLocation) -> (),
	alignToBogies: (self: Car) -> (),
	setLocationPhysics: (
		self: Car,
		location: RouteNetwork.RouteNetworkLocation,
		speed: number,
		deltaTime: number
	) -> (),
}

export type Car = typeof(setmetatable(
	{} :: {
		name: string, -- Unique identifier for the car.
		reversed: boolean, -- If the car is reversed.
		model: Model, -- The model of the car.
		cf: CFrame, -- The CFrame of the car's base part. Its primary part.
		train: Train, -- The train the car is on.
		routeNetwork: RouteNetwork.RouteNetwork, -- The route network the car is on.
		location: RouteNetwork.RouteNetworkLocation, -- The location of the car on the route network.
		length: number, -- The length of the car.
		wheelbase: number, --Distance between the front and rear bogies alignment points. Used for the calculation of the next bogie location.
		interCarDistance: number, -- Distance between the last bogie of the previous car and the first bogie of this car. Used for the inter car alignment. Is 0 for shared bogies.
		frontBogie: Bogie.Bogie,
		rearBogie: Bogie.Bogie,
		frontConnection: Vector3, -- The connection point of the front bogie to the car.
		rearConnection: Vector3, -- The connection point of the rear bogie to the car.
		connectionOffset: CFrame, -- The offset between the center of the connection point and the center of the car's base part.
	},
	Car
))

function mirrorZAxis(v: Vector3): Vector3
	return v * Vector3.new(1, 1, -1)
end

function Car:setLocation(location: RouteNetwork.RouteNetworkLocation)
	self:setBogiesLocation(location)
	self:alignToBogies()
end

function Car:setBogiesLocation(location: RouteNetwork.RouteNetworkLocation)
	self.location = location
	if not self.frontBogie.shared then -- Checks wether it's a shared bogie, and if so don't update it, because it already has beed updated by the previous car.
		self.frontBogie:setLocation(location)
	end
	local rearLocation = self.routeNetwork:intersectSphere(
		self.frontBogie.cf.Position,
		-self.wheelbase,
		location,
		5,
		true,
		self.train.switchSelection
	)
	self.rearBogie:setLocation(
		rearLocation or self.routeNetwork:stepDistance(location, -self.wheelbase, self.train.switchSelection)
	)
end

function Car:setLocationPhysics(location: RouteNetwork.RouteNetworkLocation, speed: number, deltaTime: number)
	self:setBogiesLocation(location)
	if not self.frontBogie.shared then -- Checks wether it's a shared bogie, and if so don't update it, because it already has beed updated by the previous car.
		self.frontBogie:updatePhysics(speed, deltaTime)
	end
	self.rearBogie:updatePhysics(speed, deltaTime)
	self:alignToBogies()
end

function Car:alignToBogies()
	local frontCFrame = self.frontBogie:getConnection()
	local rearCFrame = self.rearBogie:getConnection()
	local combinedUpVector = (frontCFrame.UpVector + rearCFrame.UpVector).Unit or Vector3.new(0, 1, 0)
	local middlePosition = (frontCFrame.Position + rearCFrame.Position) / 2
	self.cf = CFrame.lookAt(middlePosition, frontCFrame.Position, combinedUpVector)
	--[[
	if self.name == "TGVEngine" then
		local clonePoint = workspace.TestPoint:Clone()
		clonePoint.CFrame = frontCFrame
		clonePoint.Parent = workspace.TestPoints
	end
	]]
	self.cf = self.cf * self.connectionOffset
	self.cf = self.reversed and self.cf * CFrame.Angles(0, math.pi, 0) or self.cf
	self.model:PivotTo(self.cf)
end

function Car.new(
	name: string,
	routeNetwork: RouteNetwork.RouteNetwork,
	location: RouteNetwork.RouteNetworkLocation,
	reversed: boolean,
	train: Train,
	previousCar: Car?
): Car
	local self = setmetatable({}, Car) :: Car
	local thisConfig = Configuration.cars[name]
	self.name = name
	self.train = train
	self.length = thisConfig.length
	self.reversed = reversed
	self.location = location
	self.routeNetwork = routeNetwork
	self.model = game.ReplicatedStorage.assets.Trains:findFirstChild(name, true):Clone()
	self.cf = CFrame.new(0, 0, 0)
	if self.reversed then
		if previousCar and previousCar.rearBogie.shared then
			self.frontBogie = previousCar.rearBogie
		else
			self.frontBogie = Bogie.new(thisConfig.bogie2, routeNetwork, location, not thisConfig.bogie2Reversed, train)
		end
		self.rearBogie = Bogie.new(thisConfig.bogie1, routeNetwork, location, not thisConfig.bogie1Reversed)
		self.frontConnection = mirrorZAxis(thisConfig.rearConnection)
		self.rearConnection = mirrorZAxis(thisConfig.frontConnection)
	else
		if previousCar and previousCar.rearBogie.shared then
			self.frontBogie = previousCar.rearBogie
		else
			self.frontBogie = Bogie.new(thisConfig.bogie1, routeNetwork, location, thisConfig.bogie1Reversed)
		end
		self.rearBogie = Bogie.new(thisConfig.bogie2, routeNetwork, location, thisConfig.bogie2Reversed)
		self.frontConnection = thisConfig.frontConnection
		self.rearConnection = thisConfig.rearConnection
	end
	--Calculate self.wheelbase
	self.wheelbase = math.abs(
		self.rearConnection.Z - self.frontConnection.Z + self.frontBogie:getZOffset() - self.rearBogie:getZOffset()
	)
	--Calculate self.interCarDistance
	self.interCarDistance = 0
	if previousCar and not previousCar.rearBogie.shared then
		self.interCarDistance = math.abs(
			previousCar.length / 2
				- previousCar.rearConnection.Z
				+ previousCar.rearBogie:getZOffset()
				+ self.length / 2
				+ self.frontConnection.Z
				- self.frontBogie:getZOffset()
		)
	end
	self.connectionOffset = CFrame.lookAt(self.rearConnection:Lerp(self.frontConnection, 0.5), self.frontConnection)
		:Inverse()
	return self
end

return Car
