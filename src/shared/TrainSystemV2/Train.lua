--!strict
local Car = require(game.ReplicatedStorage.src.TrainSystemV2.Car)
local Bogie = require(game.ReplicatedStorage.src.TrainSystemV2.Bogie)
local Configuration = require(game.ReplicatedStorage.src.TrainSystemV2.Configuration)
local RouteNetwork = require(game.ReplicatedStorage.src.TrainSystemV2.RouteNetwork)

export type TrainLayout = {
	{
		car: string,
		reversed: boolean,
	}
}

local Train: TrainClass = {} :: TrainClass
Train.__index = Train

type TrainClass = {
	__index: TrainClass,
	new: (
		carArray: { Car.Car },
		location: RouteNetwork.RouteNetworkLocation,
		routeNetwork: RouteNetwork.RouteNetwork,
		switchSelection: { RouteNetwork.SwitchSelectionOverride }
	) -> Train,
	fromLayout: (
		layout: TrainLayout,
		location: RouteNetwork.RouteNetworkLocation,
		routeNetwork: RouteNetwork.RouteNetwork,
		switchSelection: { RouteNetwork.SwitchSelectionOverride }
	) -> Train,
	setLocation: (self: Train, location: RouteNetwork.RouteNetworkLocation, speed: number?, deltaTime: number?) -> (),
	updateSlope: (self: Train) -> (),
	getBogieAndCarIndexFromModel: (self: Train, model: Model) -> (number?, boolean?), -- Returns nil if not found. isFrontBogie is nil if it's a car otherwise it's true if it's a front bogie and false if it's a rear bogie.
}

export type Train = typeof(setmetatable(
	{} :: {
		cars: { Car.Car },
		model: Model,
		location: RouteNetwork.RouteNetworkLocation,
		routeNetwork: RouteNetwork.RouteNetwork,
		speed: number,
		length: number,
		averageSlopeSine: number,
		endLocation: RouteNetwork.RouteNetworkLocation,
		switchSelection: { RouteNetwork.SwitchSelectionOverride },
	},
	Train
))

function Train:getBogieAndCarIndexFromModel(model: Model): (number?, boolean?)
	for i, car in ipairs(self.cars) do
		if car.model == model then
			return i
		elseif car.frontBogie.model == model then
			return i, true
		elseif car.rearBogie.model == model then
			return i, false
		end
	end
	return nil
end

function Train:updateSlope()
	local frontElevation = self.cars[1].frontBogie.cf.Position.Y
	local rearElevation = self.cars[#self.cars].rearBogie.cf.Position.Y
	self.averageSlopeSine = (frontElevation - rearElevation) / self.length
end

function Train:setLocation(location: RouteNetwork.RouteNetworkLocation, speed: number?, deltaTime: number?)
	self.location = location
	for i, car in ipairs(self.cars) do
		local thisLocation
		if i == 1 then
			thisLocation = location
		elseif self.cars[i - 1].rearBogie.shared then
			thisLocation = self.cars[i - 1].rearBogie.location
		else
			thisLocation = self.routeNetwork:intersectSphere(
				self.cars[i - 1].rearBogie.cf.Position,
				car.interCarDistance,
				self.cars[i - 1].rearBogie.location,
				3,
				true,
				self.switchSelection
			) or self.routeNetwork:stepDistance(
				self.cars[i - 1].rearBogie.location,
				-car.interCarDistance,
				self.switchSelection
			)
		end
		if speed and deltaTime then
			car:setLocationPhysics(thisLocation, speed, deltaTime)
		else
			car:setLocation(thisLocation)
		end
	end
	self:updateSlope()
end

function Train.new(
	cars: { Car.Car },
	location: RouteNetwork.RouteNetworkLocation,
	routeNetwork: RouteNetwork.RouteNetwork,
	switchSelection: { RouteNetwork.SwitchSelectionOverride }
): Train
	local self = setmetatable({}, Train) :: Train
	self.cars = cars
	for i, v in ipairs(cars) do
		v.train = self
	end
	self.location = location
	self.routeNetwork = routeNetwork
	self.switchSelection = switchSelection
	self.speed = 0
	self.length = 0
	self.averageSlopeSine = 0
	self.endLocation = location
	self.model = Instance.new("Model")
	self.model.Name = "Train"
	self.switchSelection = {}
	for i, car in ipairs(cars) do
		self.length += car.length
		car.model.Parent = self.model
		car.rearBogie.model.Parent = self.model
		if i == 1 or not car.frontBogie.shared then
			car.frontBogie.model.Parent = self.model
		end
	end
	return self
end

function Train.fromLayout(
	layout: TrainLayout,
	location: RouteNetwork.RouteNetworkLocation,
	routeNetwork: RouteNetwork.RouteNetwork,
	switchSelection: { RouteNetwork.SwitchSelectionOverride }
): Train
	local self = setmetatable({}, Train) :: Train
	self.cars = {}
	self.location = location
	self.routeNetwork = routeNetwork
	self.switchSelection = switchSelection
	self.speed = 0
	self.length = 0
	self.averageSlopeSine = 0
	self.endLocation = location
	self.model = Instance.new("Model")
	self.model.Name = "Train"
	for i, carLayout in ipairs(layout) do
		local car = Car.new(carLayout.car, routeNetwork, location, carLayout.reversed, self, self.cars[i - 1])
		self.cars[i] = car
		self.length += car.length
		car.model.Parent = self.model
		car.rearBogie.model.Parent = self.model
		if i == 1 or not car.frontBogie.shared then
			car.frontBogie.model.Parent = self.model
		end
	end

	return self
end

return Train
